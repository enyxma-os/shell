import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-notify"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: NotificationState.hasActivePopup ? 48 : 20
        right: 12
    }

    implicitWidth: 340
    implicitHeight: card.implicitHeight
    color: "transparent"

    visible: card.opacity > 0.0

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    Timer {
        id: dismissTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: NotificationState.dismissPopup()
    }

    Connections {
        target: NotificationState
        function onPopupTriggered() {
            dismissTimer.restart()
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: NotificationState.hasActivePopup ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: dismissTimer.stop()
            onExited: {
                if (NotificationState.hasActivePopup) {
                    dismissTimer.restart()
                }
            }
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            // Başlık Satırı: İkon / Uygulama Adı + Zaman + Kapat Butonu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "󰂚"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                }

                Text {
                    text: NotificationState.activePopup ? NotificationState.activePopup.appName : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: NotificationState.activePopup ? NotificationState.activePopup.time : ""
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }

                EnyxmaPill {
                    implicitHeight: 22
                    implicitWidth: 22
                    onClicked: NotificationState.dismissPopup()

                    Text {
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // Asıl Bildirim Başlığı (Summary)
            Text {
                Layout.fillWidth: true
                text: NotificationState.activePopup ? NotificationState.activePopup.summary : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text.length > 0
            }

            // Bildirim Gövdesi (Body)
            Text {
                Layout.fillWidth: true
                text: NotificationState.activePopup ? NotificationState.activePopup.body : ""
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                visible: text.length > 0
            }

            // Eylem Butonları (Actions)
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall
                visible: NotificationState.activePopup && NotificationState.activePopup.actions && NotificationState.activePopup.actions.length > 0

                Repeater {
                    model: NotificationState.activePopup ? NotificationState.activePopup.actions : []
                    delegate: EnyxmaPill {
                        required property var modelData
                        implicitHeight: 24

                        onClicked: {
                            if (NotificationState.activePopup) {
                                NotificationState.invokeAction(NotificationState.activePopup.id, modelData.identifier)
                            }
                        }

                        Text {
                            text: modelData.text || modelData.identifier
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
        }
    }
}
