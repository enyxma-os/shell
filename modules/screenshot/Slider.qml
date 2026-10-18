import QtQuick
import "Singletons"

Item {
    id: sl

    property string label: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property int decimals: 0
    property string suffix: ""
    property bool bipolar: false
    signal moved(real v)
    signal released()

    implicitWidth: 240
    implicitHeight: 44

    readonly property real frac: sl.to > sl.from ? Math.max(0, Math.min(1, (sl.value - sl.from) / (sl.to - sl.from))) : 0

    function fmt(v) {
        return (sl.decimals > 0 ? v.toFixed(sl.decimals) : String(Math.round(v))) + sl.suffix;
    }

    function setFromX(x) {
        var t = track.width > 0 ? Math.max(0, Math.min(1, x / track.width)) : 0;
        sl.moved(sl.from + t * (sl.to - sl.from));
    }

    Text {
        id: lab
        anchors.left: parent.left
        anchors.top: parent.top
        text: sl.label
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        text: sl.fmt(sl.value)
        color: ma.pressed ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        height: 4
        radius: 2
        color: Theme.surface2

        Rectangle {
            height: parent.height
            radius: 2
            color: Theme.accent
            visible: !sl.bipolar
            width: parent.width * sl.frac
        }

        Rectangle {
            height: parent.height
            radius: 2
            color: Theme.accent
            visible: sl.bipolar
            x: Math.min(parent.width * 0.5, parent.width * sl.frac)
            width: Math.abs(parent.width * sl.frac - parent.width * 0.5)
        }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(track.width - width, track.width * sl.frac - width / 2))
            color: ma.pressed ? Theme.accent : Theme.textPrimary
            border.width: 2
            border.color: Theme.accent
            scale: ma.containsMouse ? 1.15 : 1.0

            Behavior on scale {
                NumberAnimation { duration: Theme.animFast }
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        onPressed: (m) => sl.setFromX(m.x - track.x)
        onPositionChanged: (m) => { if (pressed) sl.setFromX(m.x - track.x); }
        onReleased: sl.released()
    }
}
