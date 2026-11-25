import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Singletons"
import "lib/coords.js" as Coords
import "lib/hittest.js" as Hit

Item {
    id: overlay
    anchors.fill: parent

    required property var screenData
    property var globalSel: null
    property bool capturing: false
    property bool ready: false
    property bool resizable: false
    property bool eyedropArmed: false

    property var model: null
    property var draft: null
    property int annRevision: 0
    property bool textEditing: false
    property var selectedIndex: null
    property var moveOffset: null
    property var hoverWindow: null

    signal pressedAt(real gx, real gy, int mods)
    signal movedTo(real gx, real gy, int mods)
    signal hovered(real gx, real gy)
    signal released()
    signal wheeled(int dir)
    signal frozen()
    signal textChanged(string text)
    signal textCommitted()
    signal resizeStarted(string role, real gx, real gy)
    signal resizeMoved(real gx, real gy)
    signal resizeEnded()
    signal sampled(color c)

    readonly property int sx: screenData ? screenData.x : 0
    readonly property int sy: screenData ? screenData.y : 0
    readonly property string scrName: screenData ? screenData.name : ""

    readonly property var localSel: globalSel
        ? Coords.intersectRect(globalSel, { x: overlay.sx, y: overlay.sy, width: overlay.width, height: overlay.height })
        : null

    function selectionBox() {
        if (!model || selectedIndex === null || selectedIndex < 0 || selectedIndex >= model.items.length)
            return null;
        var a = model.items[selectedIndex];
        var b = Hit.bboxOf(a);
        var dx = (moveOffset && moveOffset.x) ? moveOffset.x : 0;
        var dy = (moveOffset && moveOffset.y) ? moveOffset.y : 0;
        var pad = Math.max(a.width || 4, 8) / 2 + 3;
        var x0 = b.x + dx - overlay.sx;
        var y0 = b.y + dy - overlay.sy;
        var x1 = x0 + b.w;
        var y1 = y0 + b.h;
        return {
            x: x0 - pad,
            y: y0 - pad,
            w: (x1 - x0) + pad * 2,
            h: (y1 - y0) + pad * 2
        };
    }

    readonly property var selBox: { annRevision; return selectionBox(); }

    Item {
        id: scene
        anchors.fill: parent

        Item {
            id: plate
            anchors.fill: parent

            ScreencopyView {
                id: shot
                anchors.fill: parent
                captureSource: overlay.screenData
                live: false
                paintCursor: false
            }
        }

        EffectLayer {
            anchors.fill: parent
            frame: plate
            sx: overlay.sx
            sy: overlay.sy
            model: overlay.model
            draft: overlay.draft
            revision: overlay.annRevision
        }

        AnnLayer {
            anchors.fill: parent
            sx: overlay.sx
            sy: overlay.sy
            model: overlay.model
            draft: overlay.draft
            revision: overlay.annRevision
            selectedIndex: overlay.selectedIndex
            moveOffset: overlay.moveOffset
        }
    }

    Timer {
        id: capTimer
        interval: 40
        repeat: true
        running: true
        property int tries: 0
        onTriggered: {
            tries += 1;
            if (shot.hasContent) {
                running = false;
                overlay.ready = true;
                overlay.frozen();
            } else if (tries > 60) {
                running = false;
                overlay.ready = true;
                overlay.frozen();
            } else if (tries >= 2) {
                shot.captureFrame();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: 0.65
        visible: overlay.ready && overlay.localSel === null
    }

    Item {
        anchors.fill: parent
        visible: overlay.ready && overlay.localSel !== null

        Rectangle {
            color: Theme.scrim
            opacity: 0.65
            x: 0; y: 0; width: parent.width
            height: overlay.localSel ? overlay.localSel.y : 0
        }
        Rectangle {
            color: Theme.scrim
            opacity: 0.65
            x: 0; width: parent.width
            y: overlay.localSel ? overlay.localSel.y + overlay.localSel.h : 0
            height: overlay.localSel ? parent.height - (overlay.localSel.y + overlay.localSel.h) : 0
        }
        Rectangle {
            color: Theme.scrim
            opacity: 0.65
            x: 0
            y: overlay.localSel ? overlay.localSel.y : 0
            width: overlay.localSel ? overlay.localSel.x : 0
            height: overlay.localSel ? overlay.localSel.h : 0
        }
        Rectangle {
            color: Theme.scrim
            opacity: 0.65
            x: overlay.localSel ? overlay.localSel.x + overlay.localSel.w : 0
            y: overlay.localSel ? overlay.localSel.y : 0
            width: overlay.localSel ? parent.width - (overlay.localSel.x + overlay.localSel.w) : 0
            height: overlay.localSel ? overlay.localSel.h : 0
        }
    }

    Item {
        id: chrome
        visible: overlay.ready && overlay.localSel !== null
        x: overlay.localSel ? overlay.localSel.x : 0
        y: overlay.localSel ? overlay.localSel.y : 0
        width: overlay.localSel ? overlay.localSel.w : 0
        height: overlay.localSel ? overlay.localSel.h : 0

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Theme.accent
            border.width: 1.5
        }

        Rectangle {
            anchors.bottom: parent.top
            anchors.bottomMargin: 6
            anchors.left: parent.left
            width: dimText.implicitWidth + 14
            height: dimText.implicitHeight + 6
            radius: Theme.radiusSmall
            color: Theme.bgPanel
            border.color: Theme.borderSubtle
            border.width: 1

            Text {
                id: dimText
                anchors.centerIn: parent
                text: overlay.globalSel
                    ? Math.round(overlay.globalSel.w) + " × " + Math.round(overlay.globalSel.h)
                    : ""
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
            }
        }
    }

    ResizeHandles {
        anchors.fill: parent
        z: 20
        visible: overlay.ready && overlay.resizable && overlay.globalSel !== null
        globalRect: overlay.globalSel
        sx: overlay.sx
        sy: overlay.sy
        onStarted: (role, gx, gy) => overlay.resizeStarted(role, gx, gy)
        onMoved: (gx, gy) => overlay.resizeMoved(gx, gy)
        onEnded: overlay.resizeEnded()
    }

    Item {
        id: annSelection
        visible: overlay.ready && overlay.selBox !== null
        x: overlay.selBox ? overlay.selBox.x : 0
        y: overlay.selBox ? overlay.selBox.y : 0
        width: overlay.selBox ? overlay.selBox.w : 0
        height: overlay.selBox ? overlay.selBox.h : 0

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Theme.accent
            border.width: 1
            antialiasing: true
        }

        Repeater {
            model: [
                { hx: 0, hy: 0 },
                { hx: 1, hy: 0 },
                { hx: 0, hy: 1 },
                { hx: 1, hy: 1 }
            ]
            Rectangle {
                required property var modelData
                width: 7; height: 7
                radius: 1
                color: Theme.accent
                x: modelData.hx * (annSelection.width - width)
                y: modelData.hy * (annSelection.height - height)
            }
        }
    }

    ClipGrab {
        id: exportClip
        source: scene
        ready: overlay.ready
        rect: overlay.localSel
    }

    ClipGrab {
        id: regionClip
        source: scene
        ready: overlay.ready
        rect: null
    }

    ClipGrab {
        id: plateClip
        source: plate
        ready: overlay.ready
        rect: null
    }

    function grabExport(path, cb, targetSize) {
        exportClip.grab(path, cb, targetSize || null);
    }

    function grabRegion(rect, path, cb) {
        regionClip.rect = rect;
        regionClip.grab(path, cb);
    }

    function grabPlate(rect, path, cb, targetSize) {
        plateClip.rect = rect;
        plateClip.grab(path, cb, targetSize || null);
    }

    MouseArea {
        id: input
        anchors.fill: parent
        enabled: true
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: overlay.ready ? Qt.CrossCursor : Qt.BlankCursor
        onPressed: (m) => {
            if (!overlay.ready) return;
            overlay.pressedAt(m.x + overlay.sx, m.y + overlay.sy, m.modifiers);
        }
        onPositionChanged: (m) => {
            if (!overlay.ready) return;
            if (overlay.capturing || pressed) overlay.movedTo(m.x + overlay.sx, m.y + overlay.sy, m.modifiers);
            else overlay.hovered(m.x + overlay.sx, m.y + overlay.sy);
        }
        onReleased: {
            if (!overlay.ready) return;
            overlay.released();
        }
        onWheel: (w) => {
            if (!overlay.ready) return;
            if (w.angleDelta.y === 0) return;
            overlay.wheeled(w.angleDelta.y > 0 ? 1 : -1);
            w.accepted = true;
        }
    }

    TextInput {
        id: textEdit
        readonly property bool mine: overlay.textEditing && overlay.draft
            && overlay.draft.type === "text" && overlay.localSel !== null
            && (overlay.draft.points[0].x >= overlay.sx) && (overlay.draft.points[0].x < overlay.sx + overlay.width)
            && (overlay.draft.points[0].y >= overlay.sy) && (overlay.draft.points[0].y < overlay.sy + overlay.height)
        visible: mine
        enabled: mine
        x: mine ? overlay.draft.points[0].x - overlay.sx : 0
        y: mine ? overlay.draft.points[0].y - overlay.sy : 0
        color: mine ? overlay.draft.color : "transparent"
        font.family: Theme.fontFamily
        font.pixelSize: mine ? overlay.draft.size : 16
        renderType: Text.NativeRendering
        cursorVisible: mine
        autoScroll: false
        onTextEdited: overlay.textChanged(text)
        onMineChanged: if (mine) { text = overlay.draft.text || ""; forceActiveFocus(); }
        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { overlay.textCommitted(); e.accepted = true; }
            else if (e.key === Qt.Key_Escape) { e.accepted = false; }
        }
    }
}
