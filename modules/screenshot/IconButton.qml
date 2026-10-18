import QtQuick
import "Singletons"

Rectangle {
    id: btn
    property string icon: ""
    property bool active: false
    property bool dim: false
    property string tooltip: ""
    property real iconSize: 18

    signal clicked()

    readonly property bool hovered: ma.containsMouse

    width: 32
    height: 32
    radius: Theme.radiusSmall
    color: active ? Theme.accent : (hovered && !dim ? Theme.surfaceHover : "transparent")

    Icon {
        anchors.centerIn: parent
        name: btn.icon
        size: btn.iconSize
        tint: btn.active ? Theme.bgDark : (btn.dim ? Theme.textMuted : Theme.textSecondary)
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: !btn.dim
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }

    Timer {
        id: tipDelay
        interval: 400
        onTriggered: tip.opacity = 1
    }

    onHoveredChanged: {
        if (hovered && tooltip.length > 0 && !dim)
            tipDelay.restart()
        else {
            tipDelay.stop()
            tip.opacity = 0
        }
    }

    Rectangle {
        id: tip
        enabled: false
        visible: btn.tooltip.length > 0
        opacity: 0
        z: 100
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: tipText.implicitWidth + 14
        height: tipText.implicitHeight + 8
        radius: Theme.radiusSmall
        color: Theme.bgPanel
        border.color: Theme.borderSubtle
        border.width: 1

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast }
        }

        Text {
            id: tipText
            anchors.centerIn: parent
            text: btn.tooltip
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }
}
