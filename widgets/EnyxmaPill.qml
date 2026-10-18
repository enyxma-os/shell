import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root

    property alias mouseArea: mouseArea
    property bool isActive: false
    signal clicked()
    signal rightClicked()

    implicitHeight: 24
    implicitWidth: Math.max(containerLayout.implicitWidth + Theme.spacingMedium * 2, height)

    radius: height / 2
    color: isActive ? Theme.surfaceHover : (mouseArea.containsMouse ? Theme.surfaceHover : Theme.surface1)
    border.color: isActive ? Theme.accent : Theme.borderSubtle
    border.width: Theme.borderWidth

    default property alias content: containerLayout.data

    Behavior on color {
        enabled: !Theme.reduceMotion
        ColorAnimation {
            duration: Theme.animFast
            easing.type: Easing.OutQuint
        }
    }

    Behavior on border.color {
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else {
                root.clicked();
            }
        }
    }
}
