import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root

    property alias mouseArea: mouseArea
    signal clicked()

    implicitHeight: 24
    implicitWidth: Math.max(containerLayout.implicitWidth + Theme.spacingMedium * 2, height)

    radius: height / 2
    color: mouseArea.containsMouse ? Theme.surfaceHover : Theme.surface1
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    default property alias content: containerLayout.data

    Behavior on color {
        enabled: !Theme.reduceMotion
        ColorAnimation {
            duration: Theme.animFast
            easing.type: Easing.OutQuint
        }
    }

    RowLayout {
        id: containerLayout
        anchors.centerIn: parent
        spacing: Theme.spacingXS
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
