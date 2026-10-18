import QtQuick
import "Singletons"

Item {
    id: dial

    property real angle: 90
    property string label: ""
    signal moved(real a)

    implicitWidth: 56
    implicitHeight: 70

    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: dial.label
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
    }

    Rectangle {
        id: face
        width: 52
        height: 52
        radius: 26
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.surface1
        border.width: 1
        border.color: Theme.borderSubtle

        Rectangle {
            anchors.centerIn: parent
            width: 4
            height: 4
            radius: 2
            color: Theme.borderSubtle
        }

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: Theme.accent
            x: face.width / 2 - width / 2 + Math.cos(dial.angle * Math.PI / 180) * (face.width / 2 - 8)
            y: face.height / 2 - height / 2 + Math.sin(dial.angle * Math.PI / 180) * (face.height / 2 - 8)
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            function update(m) {
                var dx = m.x - face.width / 2;
                var dy = m.y - face.height / 2;
                var a = Math.round(Math.atan2(dy, dx) * 180 / Math.PI);
                if (a < 0) a += 360;
                dial.moved(a);
            }
            onPressed: (m) => update(m)
            onPositionChanged: (m) => { if (pressed) update(m); }
        }
    }
}
