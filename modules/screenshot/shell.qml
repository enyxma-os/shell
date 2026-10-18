import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Singletons"
import "lib/coords.js" as Coords
import "lib/AnnotationModel.js" as Ann
import "lib/hittest.js" as Hit
import "lib/constrain.js" as Constrain

ShellRoot {
    id: root

    property var globalSel: null
    property var pressPoint: null
    property bool capturing: false
    property string phase: "selecting" // selecting | editing | beautify
    property string activeTool: "rect"
    property color activeColor: Theme.accent
    property int activeWidth: 4
    property bool activeFill: false
    property bool activeRough: false

    property var model: Ann.create()
    property var draft: null
    property int annRevision: 0
    property bool shortcutsOpen: false
    property bool textEditing: false
    property string openPopover: ""

    property var selectedIndex: null
    property var moveOffset: null
    property var resizing: null
    property var hoverWindow: null

    property real toolbarDX: 0
    property real toolbarDY: 0
    property var overlays: []

    property string beautifySrc: ""
    property string beautifyBgImage: ""
    property bool fromFile: false
    property bool exported: false

    readonly property string openPath: Quickshell.env("ENYXMA_SHOT_OPEN") || ""

    readonly property string saveRoot: (Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures")) + "/Screenshots"

    function makeTimestamp() {
        var d = new Date();
        function pad(n) { return (n < 10 ? "0" : "") + n; }
        return d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + "_"
            + pad(d.getHours()) + pad(d.getMinutes()) + pad(d.getSeconds());
    }

    function generateSavePath() {
        return root.saveRoot + "/enyxma_" + makeTimestamp() + ".png";
    }

    function exitApp() {
        Quickshell.execDetached(["kill", "-TERM", String(Quickshell.processId)]);
    }

    readonly property string defaultPath: generateSavePath()

    readonly property var toolDescriptors: [
        { id: "select",   key: "s", icon: "select",   label: "Kırp" },
        { id: "rect",     key: "r", icon: "rect",     label: "Kutu" },
        { id: "ellipse",  key: "e", icon: "ellipse",  label: "Daire" },
        { id: "arrow",    key: "a", icon: "arrow",    label: "Ok" },
        { id: "line",     key: "l", icon: "line",     label: "Çizgi" },
        { id: "pen",      key: "p", icon: "pen",      label: "Kalem" },
        { id: "marker",   key: "m", icon: "marker",   label: "Vurgula" },
        { id: "counter",  key: "n", icon: "counter",  label: "Numara" },
        { id: "text",     key: "t", icon: "text",     label: "Metin" },
        { id: "redact",   key: "x", icon: "redact",   label: "Sansür" }
    ]

    function toolHasFill(tool) {
        return tool === "rect" || tool === "ellipse";
    }

    function selectTool(t) {
        if (textEditing) commitText();
        activeTool = t;
        clearSelection();
    }

    function clearSelection() {
        selectedIndex = null;
        moveOffset = null;
        bumpAnn();
    }

    function bumpAnn() {
        annRevision += 1;
    }

    function setToolColor(c) {
        activeColor = c;
        if (selectedIndex !== null && selectedIndex >= 0 && selectedIndex < model.items.length) {
            model.commit();
            model.items[selectedIndex].color = c;
            bumpAnn();
        }
    }

    function setToolWidth(w) {
        activeWidth = w;
        if (selectedIndex !== null && selectedIndex >= 0 && selectedIndex < model.items.length) {
            model.commit();
            model.items[selectedIndex].width = w;
            bumpAnn();
        }
    }

    function setToolFill(f) {
        activeFill = f;
        if (selectedIndex !== null && selectedIndex >= 0 && selectedIndex < model.items.length) {
            model.commit();
            model.items[selectedIndex].filled = f;
            bumpAnn();
        }
    }

    function deleteSelected() {
        if (selectedIndex === null) return;
        model.remove(selectedIndex);
        selectedIndex = null;
        moveOffset = null;
        bumpAnn();
    }

    function undo() {
        if (model.undo()) {
            selectedIndex = null;
            moveOffset = null;
            bumpAnn();
        }
    }

    function redo() {
        if (model.redo()) {
            selectedIndex = null;
            moveOffset = null;
            bumpAnn();
        }
    }

    function anchorOverlay() {
        if (!globalSel) return overlays.length ? overlays[0] : null;
        var cx = globalSel.x + globalSel.w / 2;
        var cy = globalSel.y + globalSel.h / 2;
        for (var i = 0; i < overlays.length; i++) {
            var m = overlays[i].modelData;
            if (cx >= m.x && cx < m.x + m.width && cy >= m.y && cy < m.y + m.height)
                return overlays[i];
        }
        return overlays.length ? overlays[0] : null;
    }

    function openForBeautify(path) {
        var scr = Quickshell.screens;
        if (scr.length > 0)
            globalSel = { x: scr[0].x, y: scr[0].y, w: scr[0].width, h: scr[0].height };
        fromFile = true;
        beautifySrc = path;
        phase = "beautify";
    }

    Component.onCompleted: {
        if (openPath.length > 0) openForBeautify(openPath);
    }

    function beginSelection(gx, gy) {
        pressPoint = { x: gx, y: gy };
        capturing = true;
        globalSel = { x: gx, y: gy, w: 0, h: 0 };
    }

    function updateSelection(gx, gy, mods) {
        if (!pressPoint) return;
        var p = { x: gx, y: gy };
        if (mods & Qt.ShiftModifier) p = Constrain.square(pressPoint, p);
        globalSel = Coords.rectFromPoints(pressPoint, p);
    }

    function endSelection() {
        capturing = false;
        pressPoint = null;
        if (globalSel && globalSel.w > 4 && globalSel.h > 4) {
            phase = "editing";
        } else {
            globalSel = null;
        }
    }

    function wholeMonitor() {
        var w = anchorOverlay();
        if (!w || !w.modelData) return;
        globalSel = { x: w.modelData.x, y: w.modelData.y, w: w.modelData.width, h: w.modelData.height };
        phase = "editing";
    }

    function beginResize(role, gx, gy) {
        resizing = role;
    }

    function updateResize(gx, gy) {
        if (resizing === null || !globalSel) return;
        globalSel = Hit.resizeRect(globalSel, resizing, gx, gy, 8);
    }

    function endResize() {
        resizing = null;
    }

    function beginDraw(gx, gy) {
        if (!globalSel) return;
        if (activeTool === "text") {
            placeText(gx, gy);
            return;
        }
        var p = { x: gx, y: gy };
        if (activeTool === "counter") {
            var n = 1;
            for (var i = 0; i < model.items.length; i++)
                if (model.items[i].type === "counter") n += 1;
            model.add({ type: "counter", points: [p], n: n, color: activeColor, width: activeWidth });
            bumpAnn();
            return;
        }
        draft = {
            type: activeTool,
            points: [p, p],
            color: activeColor,
            width: activeWidth,
            filled: activeFill,
            rough: activeRough
        };
        bumpAnn();
    }

    function updateDraw(gx, gy, mods) {
        if (!draft) return;
        var p = { x: gx, y: gy };
        if (mods & Qt.ShiftModifier) p = Constrain.constrain(draft.type, draft.points[0], p);
        if (draft.type === "pen") {
            draft.points.push(p);
        } else {
            draft.points[draft.points.length - 1] = p;
        }
        bumpAnn();
    }

    function endDraw() {
        if (!draft) return;
        var d = draft;
        draft = null;
        if (d.points.length >= 2) {
            var p0 = d.points[0], p1 = d.points[d.points.length - 1];
            if (Math.hypot(p1.x - p0.x, p1.y - p0.y) > 2 || d.type === "pen") {
                model.add(d);
            }
        }
        bumpAnn();
    }

    function placeText(gx, gy) {
        draft = {
            type: "text",
            points: [{ x: gx, y: gy }],
            text: "",
            color: activeColor,
            size: Math.max(14, activeWidth * 4)
        };
        textEditing = true;
        bumpAnn();
    }

    function commitText() {
        if (!draft || draft.type !== "text") return;
        if (draft.text && draft.text.trim().length > 0) model.add(draft);
        draft = null;
        textEditing = false;
        bumpAnn();
    }

    function cancelText() {
        draft = null;
        textEditing = false;
        bumpAnn();
    }

    function pointerPressed(gx, gy, mods) {
        openPopover = "";
        shortcutsOpen = false;
        if (phase === "selecting") beginSelection(gx, gy);
        else beginDraw(gx, gy);
    }

    function pointerMoved(gx, gy, mods) {
        if (phase === "selecting") updateSelection(gx, gy, mods);
        else updateDraw(gx, gy, mods);
    }

    function pointerReleased() {
        if (phase === "selecting") endSelection();
        else endDraw();
    }

    function grabTo(path, after) {
        var plan = Coords.stitchPlan(globalSel, Quickshell.screens);
        if (plan.slices.length === 0) { if (after) after(false); return; }
        overlays[plan.slices[0].screen].grabExport(path, after);
    }

    function copyImageAndQuit(file) {
        if (root.exported) return;
        root.exported = true;
        var cmd = "(wl-copy --type image/png < '" + file + "' 2>/dev/null || wl-copy < '" + file + "' 2>/dev/null || true)";
        cmd += " && (notify-send -a 'Enyxma Shot' -i '" + file + "' '✦ Ekran Görüntüsü Kopyalandı' 'Görsel panoya aktarıldı.' 2>/dev/null || true)";
        Quickshell.execDetached(["sh", "-c", cmd]);
        quitTimer.restart();
    }

    function saveToScreenshots(file) {
        if (root.exported) return;
        root.exported = true;
        var target = root.generateSavePath();
        var cmd = "mkdir -p '" + root.saveRoot + "' && cp -f '" + file + "' '" + target + "'";
        cmd += " && (wl-copy --type image/png < '" + target + "' 2>/dev/null || true)";
        cmd += " && (notify-send -a 'Enyxma Shot' -i '" + target + "' '✦ Ekran Görüntüsü Kaydedildi' '" + target + "' 2>/dev/null || true)";
        cmd += " && (quickshell ipc call media-browser refresh 2>/dev/null || true)";
        Quickshell.execDetached(["sh", "-c", cmd]);
        quitTimer.restart();
    }

    function doCopy() {
        var tmp = "/tmp/enyxma-shot-copy.png";
        grabTo(tmp, function (ok) {
            if (ok) copyImageAndQuit(tmp);
            else root.exitApp();
        });
    }

    function doSave() {
        var tmp = "/tmp/enyxma-shot-save.png";
        grabTo(tmp, function (ok) {
            if (ok) saveToScreenshots(tmp);
            else root.exitApp();
        });
    }

    function openBeautify() {
        if (textEditing) commitText();
        clearSelection();
        beautifySrc = "";
        grabTo("/tmp/enyxma-shot-beautify-src.png", function (ok) {
            if (!ok) return;
            beautifySrc = "/tmp/enyxma-shot-beautify-src.png";
            phase = "beautify";
        });
    }

    function escapeStep() {
        if (textEditing) { cancelText(); return; }
        if (openPopover.length > 0) { openPopover = ""; return; }
        if (shortcutsOpen) { shortcutsOpen = false; return; }
        if (phase === "beautify") {
            if (fromFile) root.exitApp();
            else phase = "editing";
            return;
        }
        root.exitApp();
    }

    function editKey(e) {
        var ctrl = (e.modifiers & Qt.ControlModifier) !== 0;
        var shift = (e.modifiers & Qt.ShiftModifier) !== 0;
        if (ctrl) {
            if (e.key === Qt.Key_C) { doCopy(); return true; }
            if (e.key === Qt.Key_S) { doSave(); return true; }
            if (e.key === Qt.Key_B) { openBeautify(); return true; }
            if (e.key === Qt.Key_Z) { if (shift) redo(); else undo(); return true; }
            if (e.key === Qt.Key_Y) { redo(); return true; }
            return false;
        }
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { doSave(); return true; }
        if (e.key === Qt.Key_Delete || e.key === Qt.Key_Backspace) { deleteSelected(); return true; }
        if (e.key === Qt.Key_F) { setToolFill(!activeFill); return true; }
        if (e.key === Qt.Key_K) { activeRough = !activeRough; return true; }
        if (e.key === Qt.Key_Question || (shift && e.key === Qt.Key_Slash)) {
            shortcutsOpen = !shortcutsOpen;
            return true;
        }
        var ch = String.fromCharCode(e.key).toLowerCase();
        for (var i = 0; i < toolDescriptors.length; i++) {
            if (toolDescriptors[i].key === ch) {
                selectTool(toolDescriptors[i].id);
                return true;
            }
        }
        return false;
    }

    function selectKey(e) {
        if (e.key === Qt.Key_A && (e.modifiers & Qt.ControlModifier)) { wholeMonitor(); return true; }
        if (e.key === Qt.Key_Question) { shortcutsOpen = !shortcutsOpen; return true; }
        return false;
    }

    Timer {
        id: quitTimer
        interval: 200
        onTriggered: root.exitApp()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true; bottom: true }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "enyxma-shot"

            readonly property bool showToolbar: root.phase === "editing" && root.anchorOverlay() === win && root.globalSel !== null

            readonly property var selLocal: root.globalSel
                ? Coords.intersectRect(root.globalSel, { x: win.modelData.x, y: win.modelData.y, width: win.width, height: win.height })
                : null

            FocusScope {
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: root.escapeStep()
                Keys.onPressed: (e) => {
                    if (root.textEditing) return;
                    var handled = root.phase === "selecting" ? root.selectKey(e) : root.editKey(e);
                    if (handled) e.accepted = true;
                }

                Overlay {
                    id: ov
                    anchors.fill: parent
                    screenData: win.modelData
                    globalSel: root.globalSel
                    capturing: root.capturing
                    model: root.model
                    draft: root.draft
                    annRevision: root.annRevision
                    textEditing: root.textEditing
                    selectedIndex: root.selectedIndex
                    moveOffset: root.moveOffset
                    resizable: root.phase === "editing"

                    onPressedAt: (gx, gy, mods) => root.pointerPressed(gx, gy, mods)
                    onMovedTo: (gx, gy, mods) => root.pointerMoved(gx, gy, mods)
                    onReleased: root.pointerReleased()
                    onTextChanged: (t) => { if (root.draft && root.draft.type === "text") { root.draft.text = t; root.bumpAnn(); } }
                    onTextCommitted: root.commitText()
                    onResizeStarted: (role, gx, gy) => root.beginResize(role, gx, gy)
                    onResizeMoved: (gx, gy) => root.updateResize(gx, gy)
                    onResizeEnded: root.endResize()
                }

                Toolbar {
                    id: toolbar
                    visible: win.showToolbar && win.selLocal !== null
                    tools: root.toolDescriptors
                    activeTool: root.activeTool
                    activeColor: root.activeColor
                    activeWidth: root.activeWidth
                    activeFill: root.activeFill
                    activeRough: root.activeRough
                    hasFill: root.toolHasFill(root.activeTool)
                    openPopover: root.openPopover
                    canUndo: { root.annRevision; return root.model ? root.model.canUndo() : false; }
                    canRedo: { root.annRevision; return root.model ? root.model.canRedo() : false; }

                    x: {
                        if (!win.selLocal) return 0;
                        var cx = win.selLocal.x + win.selLocal.w / 2 - width / 2 + root.toolbarDX;
                        return Math.max(8, Math.min(cx, win.width - width - 8));
                    }
                    y: {
                        if (!win.selLocal) return 0;
                        var below = win.selLocal.y + win.selLocal.h + 12;
                        if (below + height > win.height - 8) below = win.selLocal.y - height - 12;
                        return Math.max(8, Math.min(below + root.toolbarDY, win.height - height - 8));
                    }

                    onToolPicked: (t) => root.selectTool(t)
                    onColorButtonClicked: root.openPopover = root.openPopover === "color" ? "" : "color"
                    onWidthButtonClicked: root.openPopover = root.openPopover === "width" ? "" : "width"
                    onFillToggled: root.setToolFill(!root.activeFill)
                    onRoughToggled: root.activeRough = !root.activeRough
                    onUndoRequested: root.undo()
                    onRedoRequested: root.redo()
                    onCopyRequested: root.doCopy()
                    onSaveRequested: root.doSave()
                    onBeautifyRequested: root.openBeautify()
                    onCancelRequested: root.escapeStep()
                    onDragged: (dx, dy) => { root.toolbarDX += dx; root.toolbarDY += dy; }
                }

                ColorPopover {
                    visible: toolbar.visible && root.openPopover === "color"
                    selected: root.activeColor
                    x: Math.max(8, Math.min(toolbar.x + toolbar.colorCenterX - width / 2, win.width - width - 8))
                    y: toolbar.y - height - 6
                    onPicked: (c) => root.setToolColor(c)
                    onCloseRequested: root.openPopover = ""
                }

                WidthPopover {
                    visible: toolbar.visible && root.openPopover === "width"
                    selected: root.activeWidth
                    x: Math.max(8, Math.min(toolbar.x + toolbar.widthCenterX - width / 2, win.width - width - 8))
                    y: toolbar.y - height - 6
                    onPicked: (w) => root.setToolWidth(w)
                    onCloseRequested: root.openPopover = ""
                }

                ShortcutSheet {
                    anchors.centerIn: parent
                    visible: root.shortcutsOpen && root.anchorOverlay() === win
                    tools: root.toolDescriptors
                    onCloseRequested: root.shortcutsOpen = false
                }

                Rectangle {
                    anchors.fill: parent
                    visible: root.phase === "beautify" && root.anchorOverlay() !== win
                    color: Theme.bgDark
                }

                Beautify {
                    anchors.fill: parent
                    visible: root.phase === "beautify" && root.anchorOverlay() === win
                    srcPath: root.beautifySrc
                    bgImagePath: root.beautifyBgImage
                    onCopyRequested: (p) => root.copyImageAndQuit(p)
                    onSaveRequested: (p) => root.saveToScreenshots(p)
                    onCloseRequested: {
                        if (root.fromFile) root.exitApp();
                        else root.phase = "editing";
                    }
                }
            }

            Component.onCompleted: root.overlays.push(win)

            function grabExport(path, cb, targetSize) {
                ov.grabExport(path, cb, targetSize);
            }
        }
    }
}
