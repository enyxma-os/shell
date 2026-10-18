import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-ai"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: AIState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 400
    color: "transparent"

    margins.right: AIState.isOpen ? 0 : -implicitWidth
    visible: AIState.isOpen || margins.right > -implicitWidth + 1

    Behavior on margins.right {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Easing.OutQuint
        }
    }

    Connections {
        target: AIState
        function onIsOpenChanged() {
            if (AIState.isOpen) {
                Qt.callLater(() => inputField.forceActiveFocus())
            }
        }
    }

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: Theme.bgGlass

        // Sol kenarlık (1px subtle border)
        Rectangle {
            id: leftBorder
            width: Theme.borderWidth
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            color: Theme.borderSubtle
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingMedium
            spacing: Theme.spacingMedium

            // Başlık Çubuğu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "✦"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeLarge
                }

                Text {
                    text: "Enyxma AI"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                Rectangle {
                    implicitHeight: 18
                    implicitWidth: statusText.implicitWidth + Theme.spacingSmall * 2
                    radius: height / 2
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: AIState.isStreaming ? "Akışta..." : "Hazır"
                        color: AIState.isStreaming ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                EnyxmaPill {
                    id: clearButton
                    implicitHeight: 26
                    visible: AIState.messages.length > 0
                    onClicked: AIState.clearHistory()

                    Text {
                        text: "Temizle"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                EnyxmaPill {
                    id: closeButton
                    implicitHeight: 26
                    implicitWidth: 26
                    onClicked: AIState.close()

                    Text {
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // Mesaj Alanı
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Boş Durum (Empty State)
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall
                    visible: AIState.messages.length === 0
                    width: parent.width * 0.85

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "✦"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 32
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Enyxma AI Asistanı"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        font.bold: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: "Sistem, Hyprland komutları veya iş akışları hakkında soru sorun."
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                // Mesaj Listesi
                ListView {
                    id: messageListView
                    anchors.fill: parent
                    clip: true
                    spacing: Theme.spacingMedium
                    model: AIState.messages

                    onCountChanged: {
                        Qt.callLater(() => {
                            messageListView.positionViewAtEnd()
                        })
                    }

                    delegate: Item {
                        id: messageDelegate
                        required property var modelData
                        required property int index

                        readonly property bool isUser: modelData.role === "user"

                        width: messageListView.width
                        implicitHeight: bubbleRect.implicitHeight

                        Rectangle {
                            id: bubbleRect
                            width: Math.min(contentCol.implicitWidth + Theme.spacingMedium * 2, messageListView.width * 0.85)
                            implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
                            anchors.right: isUser ? parent.right : undefined
                            anchors.left: isUser ? undefined : parent.left

                            radius: Theme.radiusWidget
                            color: isUser ? Theme.surfaceActive : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: Theme.borderWidth

                            ColumnLayout {
                                id: contentCol
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingXS

                                Text {
                                    text: isUser ? "Sen" : "Enyxma AI"
                                    color: isUser ? Theme.textSecondary : Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.content || (AIState.isStreaming && index === AIState.messages.length - 1 ? "..." : "")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }

            // Giriş Alanı (Kapsül)
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    placeholderText: "Bir mesaj yazın... (Enter ile gönder)"
                    placeholderTextColor: Theme.textMuted
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: Theme.spacingMedium
                    rightPadding: Theme.spacingMedium

                    background: Rectangle {
                        radius: Theme.radiusWidget
                        color: Theme.surface1
                        border.color: inputField.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Behavior on border.color {
                            enabled: !Theme.reduceMotion
                            ColorAnimation {
                                duration: Theme.animFast
                                easing.type: Easing.OutQuint
                            }
                        }
                    }

                    onAccepted: {
                        if (text.trim().length > 0) {
                            AIState.sendMessage(text.trim())
                            text = ""
                        }
                    }

                    Keys.onEscapePressed: {
                        AIState.close()
                    }
                }

                EnyxmaPill {
                    id: sendButton
                    implicitHeight: 40
                    implicitWidth: 44
                    onClicked: {
                        if (inputField.text.trim().length > 0) {
                            AIState.sendMessage(inputField.text.trim())
                            inputField.text = ""
                        }
                    }

                    Text {
                        text: "➤"
                        color: inputField.text.trim().length > 0 ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }
            }
        }
    }
}
