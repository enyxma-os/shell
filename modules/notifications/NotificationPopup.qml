import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * NotificationPopup — anlık bildirim kartı.
 *
 * DÜZELTMELER:
 *  • Kuyruk: `NotificationState` sıralar; burada ezme yok (R1/B6).
 *  • Otomatik kapanma artık servis tarafında (urgency + expireTimeout).
 *    Kartta sadece hover ile duraklatma var. `critical` bildirim kapanmaz.
 *  • `image` alanı gösterilir (sunucu imageSupported ilan ediyordu ama
 *    hiçbir yerde okunmuyordu — R1/B12).
 *  • Gövde `PlainText` (bodyMarkupSupported: false ile tutarlı).
 */
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
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
    }

    readonly property var popup: NotificationState.activePopup
    readonly property bool isCritical: !!popup && popup.urgency === NotificationUrgency.Critical

    Rectangle {
        id: card
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: root.isCritical ? Theme.danger : Theme.borderSubtle
        border.width: root.isCritical ? 2 : Theme.borderWidth

        opacity: NotificationState.hasActivePopup ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            // Hover: zamanlayıcıyı durdur (kullanıcı okuyor).
            onEntered: NotificationState.pauseAutoDismiss()
            onExited: NotificationState.resumeAutoDismiss()
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

            // Başlık: uygulama ikonu / adı / saat / kapat
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    visible: !!root.popup && (root.popup.appIcon || "").length > 0
                    source: root.popup ? (root.popup.appIcon || "") : ""
                    sourceSize.width: 16
                    sourceSize.height: 16
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    visible: !root.popup || (root.popup.appIcon || "").length === 0
                    text: root.isCritical ? "󰀨" : "󰂚"
                    color: root.isCritical ? Theme.danger : Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                }

                Text {
                    text: root.popup ? root.popup.appName : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.popup ? root.popup.time : ""
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

            Text {
                Layout.fillWidth: true
                text: root.popup ? root.popup.summary : ""
                color: Theme.textPrimary
                textFormat: Text.PlainText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Text {
                Layout.fillWidth: true
                text: root.popup ? root.popup.body : ""
                color: Theme.textSecondary
                textFormat: Text.PlainText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                visible: text.length > 0
            }

            // image hint'i (imageSupported: true ilan edilmişti)
            Image {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                visible: !!root.popup && (root.popup.image || "").length > 0
                source: root.popup ? (root.popup.image || "") : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall
                visible: !!root.popup && root.popup.actions && root.popup.actions.length > 0

                Repeater {
                    model: root.popup ? root.popup.actions : []
                    delegate: EnyxmaPill {
                        required property var modelData
                        implicitHeight: 24

                        onClicked: {
                            if (root.popup)
                                NotificationState.invokeAction(root.popup.id, modelData.identifier)
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
