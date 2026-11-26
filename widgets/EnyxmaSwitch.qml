import QtQuick
import "../services"

Rectangle {
    id: root

    property bool checked: false
    property bool gotham: Theme.isGotham

    implicitWidth: 42
    implicitHeight: gotham ? 20 : 22
    radius: gotham ? 0 : 11
    color: checked ? Theme.accent : Theme.surface2
    border.color: checked ? Theme.accent : Theme.borderSubtle
    border.width: 1

    Behavior on color {
        enabled: !Theme.reduceMotion
        ColorAnimation { duration: Theme.animFast }
    }

    Rectangle {
        width: root.gotham ? 14 : 16
        height: root.gotham ? 14 : 16
        radius: root.gotham ? 0 : 8
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? Theme.accentOn : Theme.textSecondary

        Behavior on x {
            enabled: !Theme.reduceMotion
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }
    }
}
