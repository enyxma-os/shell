import QtQuick
import QtQuick.Layouts
import "../../services"

Row {
    id: root

    spacing: Theme.spacingSmall

    Repeater {
        model: OverviewState.workspaces

        delegate: Rectangle {
            id: deskCard
            required property var modelData
            required property int index

            readonly property bool isViewed: OverviewState.viewedWorkspaceId === deskCard.modelData.id
            readonly property bool isActive: OverviewState.activeWorkspaceId === deskCard.modelData.id
            readonly property var wsClients: OverviewState.clientsForWorkspace(deskCard.modelData.id)

            width: 84
            height: 44
            radius: Theme.radiusWidget

            color: deskCard.isViewed ? Theme.surfaceActive : (cardMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
            border.width: (deskCard.isViewed || deskCard.isActive) ? 2 : Theme.borderWidth
            border.color: deskCard.isViewed ? Theme.accent : (deskCard.isActive ? Theme.borderFocus : Theme.borderSubtle)

            scale: cardMa.containsMouse ? (Theme.isGotham ? 1.0 : 1.04) : 1.0

            Behavior on scale {
                enabled: !Theme.reduceMotion
                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
            }

            Behavior on border.color {
                ColorAnimation { duration: Theme.animFast }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: ("0" + deskCard.modelData.id).slice(-2)
                    color: deskCard.isViewed ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 3
                    visible: deskCard.wsClients.length > 0

                    Repeater {
                        model: Math.min(deskCard.wsClients.length, 5)

                        delegate: Rectangle {
                            width: Theme.isGotham ? 8 : 4
                            height: Theme.isGotham ? 2 : 4
                            radius: Theme.isGotham ? 0 : 2
                            color: deskCard.isViewed ? Theme.accent : Theme.textSecondary
                        }
                    }
                }
            }

            MouseArea {
                id: cardMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: OverviewState.viewedWorkspaceId = deskCard.modelData.id
            }
        }
    }

    // Trailing "YENİ +" Kartı
    Rectangle {
        id: addCard
        width: 68
        height: 44
        radius: Theme.radiusWidget

        color: addMa.containsMouse ? Theme.surfaceHover : Theme.surface1
        border.width: Theme.borderWidth
        border.color: addMa.containsMouse ? Theme.accent : Theme.borderSubtle

        scale: addMa.containsMouse ? (Theme.isGotham ? 1.0 : 1.04) : 1.0

        Behavior on scale {
            enabled: !Theme.reduceMotion
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.spacingXS

            Text {
                text: "+"
                color: addMa.containsMouse ? Theme.accent : Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
            }

            Text {
                text: "YENİ"
                color: addMa.containsMouse ? Theme.accent : Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.bold: true
            }
        }

        MouseArea {
            id: addMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: OverviewState.createWorkspace()
        }
    }
}
