import QtQuick
import QtQuick.Layouts
import "../../services"

/**
 * GothamNotificationPopup — Gotham 2.0 Taktiksel Uyari Seridi.
 *
 * Sag kenara sifir yaslanan, sol 3px durum bandi ve teknik [ UYGULAMA // SAAT ]
 * baslik satirina sahip endustriyel bildirim uyari modulu.
 */
Rectangle {
    id: card

    property var popup: null
    property bool isCritical: false

    implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
    color: Theme.bgPanel
    radius: 0

    // Sol 3px dikey durum bandi
    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 3
        color: card.isCritical ? Theme.danger : Theme.accent
    }

    // Ust ve alt 1px soguk grafit sinir hatlari
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: Theme.borderSubtle
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.borderSubtle
    }

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
            topMargin: Theme.spacingMedium
            bottomMargin: Theme.spacingMedium
            leftMargin: Theme.spacingMedium + 3
            rightMargin: Theme.spacingMedium
        }
        spacing: Theme.spacingSmall

        // Teknik baslik satiri: [ UYGULAMA // SAAT ] + Kapat
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            Text {
                text: card.isCritical ? "󰀨" : "󰂚"
                color: card.isCritical ? Theme.danger : Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
            }

            Text {
                Layout.fillWidth: true
                text: "[ "
                    + (card.popup ? (card.popup.appName || "SİSTEM").toUpperCase() : "")
                    + (card.popup && card.popup.time ? (" // " + card.popup.time) : "")
                    + " ]"
                color: card.isCritical ? Theme.danger : Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeXS + 1
                font.bold: true
                font.letterSpacing: 1
                elide: Text.ElideRight
            }

            Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                radius: 0
                color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationState.dismissPopup()
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
            spacing: Theme.spacingXS
            visible: !!card.popup && card.popup.actions && card.popup.actions.length > 0

            Repeater {
                model: card.popup ? card.popup.actions : []
                delegate: Rectangle {
                    required property var modelData
                    implicitWidth: actTxt.implicitWidth + 16
                    implicitHeight: 24
                    radius: Theme.radiusSmall
                    color: actMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.width: 1
                    border.color: actMa.containsMouse ? Theme.accent : Theme.borderSubtle

                    Text {
                        id: actTxt
                        anchors.centerIn: parent
                        text: modelData.text || modelData.identifier
                        color: actMa.containsMouse ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeXS
                        font.bold: true
                    }

                    MouseArea {
                        id: actMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.popup)
                                NotificationState.invokeAction(card.popup.id, modelData.identifier)
                        }
                    }
                }
            }
        }
    }
}

