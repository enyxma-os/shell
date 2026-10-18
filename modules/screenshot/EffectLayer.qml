import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "Singletons"
import "lib/redact.js" as Redact

Item {
    id: fx

    required property Item frame
    required property int sx
    required property int sy

    property var model: null
    property var draft: null
    property int revision: 0

    readonly property var kinds: ["blur", "pixelate", "redact", "magnify", "spotlight"]

    function isEffect(t) { return fx.kinds.indexOf(t) !== -1; }

    function items() {
        var src = fx.model ? fx.model.items : [];
        var out = [];
        for (var i = 0; i < src.length; i++)
            if (src[i] && fx.isEffect(src[i].type)) out.push(src[i]);
        if (fx.draft && fx.isEffect(fx.draft.type)) out.push(fx.draft);
        return out;
    }

    function blockFor(w, h) {
        var wanted = 12;
        return Math.max(wanted, Math.ceil(Math.sqrt(Math.max(1, w * h) / 4000)));
    }

    Repeater {
        id: effects
        model: { fx.revision; return fx.items(); }

        Item {
            id: cell
            required property var modelData
            readonly property var a: modelData
            readonly property bool valid: a !== undefined && a !== null
                && a.points !== undefined && a.points.length >= 2
            readonly property real rx: valid ? Math.min(a.points[0].x, a.points[1].x) - fx.sx : 0
            readonly property real ry: valid ? Math.min(a.points[0].y, a.points[1].y) - fx.sy : 0
            readonly property real rw: valid ? Math.abs(a.points[1].x - a.points[0].x) : 0
            readonly property real rh: valid ? Math.abs(a.points[1].y - a.points[0].y) : 0
            readonly property string kind: valid ? a.type : ""
            readonly property bool isRedact: kind === "redact" || kind === "pixelate"
            readonly property bool isMosaic: isRedact && a.style !== "solid"
            readonly property bool isMag: kind === "magnify"
            readonly property real magD: Math.min(rw, rh)
            readonly property real magZoom: 2.0

            x: rx
            y: ry
            width: rw
            height: rh
            visible: valid && rw > 0 && rh > 0 && kind !== "spotlight"
            clip: true

            ShaderEffectSource {
                id: blurSrc
                anchors.fill: parent
                sourceItem: fx.frame
                live: false
                onSourceRectChanged: scheduleUpdate()
                recursive: false
                sourceRect: Qt.rect(cell.rx, cell.ry, cell.rw, cell.rh)
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: blurSrc
                blurEnabled: true
                blur: 1.0
                blurMax: 32
                visible: cell.kind === "blur"
            }

            Rectangle {
                anchors.fill: parent
                visible: cell.isRedact && (!cell.isMosaic || !cell.a.pal || cell.a.pal.length === 0)
                color: Theme.redactSolid
            }

            Repeater {
                model: {
                    if (!cell.isMosaic || !cell.a.pal || cell.a.pal.length === 0) return [];
                    var block = fx.blockFor(cell.rw, cell.rh);
                    var seed = cell.a.seed || Redact.seedFor({ x: cell.rx, y: cell.ry, w: cell.rw, h: cell.rh });
                    return Redact.blockPlan(cell.rw, cell.rh, block, seed, cell.a.pal.length);
                }

                Rectangle {
                    required property var modelData
                    x: modelData.x
                    y: modelData.y
                    width: modelData.w
                    height: modelData.h
                    color: cell.a.pal[modelData.index % cell.a.pal.length]
                }
            }

            ShaderEffectSource {
                id: magSrc
                width: cell.magD
                height: cell.magD
                anchors.centerIn: parent
                sourceItem: fx.frame
                live: false
                onSourceRectChanged: scheduleUpdate()
                recursive: false
                sourceRect: Qt.rect(cell.rx + cell.rw / 2 - cell.magD / (2 * cell.magZoom),
                                    cell.ry + cell.rh / 2 - cell.magD / (2 * cell.magZoom),
                                    cell.magD / cell.magZoom, cell.magD / cell.magZoom)
                visible: false
            }

            Rectangle {
                id: magMask
                width: cell.magD
                height: cell.magD
                anchors.centerIn: parent
                radius: cell.magD / 2
                visible: false
                layer.enabled: true
            }

            MultiEffect {
                width: cell.magD
                height: cell.magD
                anchors.centerIn: parent
                source: magSrc
                maskEnabled: true
                maskSource: magMask
                visible: cell.isMag
            }

            Rectangle {
                width: cell.magD
                height: cell.magD
                anchors.centerIn: parent
                radius: cell.magD / 2
                color: "transparent"
                border.color: Theme.textPrimary
                border.width: 2
                visible: cell.isMag
            }
        }
    }
}
