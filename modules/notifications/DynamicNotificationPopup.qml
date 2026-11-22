import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * DynamicNotificationPopup — Dinamik Tema Yuvarlatilmis Cam Bildirim Karti.
 */
Rectangle {
    id: card

    property var popup: null
    property bool isCritical: false

    implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: card.isCritical ? Theme.danger : Theme.borderSubtle
    border.width: card.isCritical ? 2 : Theme.borderWidth

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
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

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            Image {
                Layout.alignment: Qt.AlignVCenter
                visible: !!card.popup && (card.popup.appIcon || "").length > 0
                source: card.popup ? (card.popup.appIcon || "") : ""
                sourceSize.width: 16
                sourceSize.height: 16
                fillMode: Image.PreserveAspectFit
            }

            Text {
                visible: !card.popup || (card.popup.appIcon || "").length === 0
                text: card.isCritical ? "󰀨" : "󰂚"
                color: card.isCritical ? Theme.danger : Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
            }

            Text {
                text: card.popup ? card.popup.appName : ""
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: card.popup ? card.popup.time : ""
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
            text: card.popup ? card.popup.summary : ""
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
            text: card.popup ? card.popup.body : ""
            color: Theme.textSecondary
            textFormat: Text.PlainText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            visible: text.length > 0
        }

        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            visible: !!card.popup && (card.popup.image || "").length > 0
            source: card.popup ? (card.popup.image || "") : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall
            visible: !!card.popup && card.popup.actions && card.popup.actions.length > 0

            Repeater {
                model: card.popup ? card.popup.actions : []
                delegate: EnyxmaPill {
                    required property var modelData
                    implicitHeight: 24

                    onClicked: {
                        if (card.popup)
                            NotificationState.invokeAction(card.popup.id, modelData.identifier)
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

