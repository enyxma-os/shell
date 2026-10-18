import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../services"
import "../../widgets"

Item {
    id: root

    implicitHeight: 520

    // Zenity ile görsel seçme
    Process {
        id: pickImageProc
        command: ["zenity", "--file-selection", "--title=Görsel Seç", "--file-filter=Görseller | *.png *.jpg *.jpeg *.webp *.svg"]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text.trim()
                if (path.length > 0) {
                    inputField.text = inputField.text + " [Görsel: " + path.split("/").pop() + "] "
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMedium
        spacing: Theme.spacingSmall

        // ── ÜST BAŞLIK ALANI ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            Text {
                text: "ENYXMA AI"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                font.letterSpacing: 1.5
            }

            Item { Layout.fillWidth: true }

            // Geçmiş Temizle / Geçmiş Butonu
            Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: 13
                color: histMa.containsMouse ? Theme.surfaceHover : "transparent"
                visible: AIState.messages.length > 0

                Text {
                    anchors.centerIn: parent
                    text: "󰋚"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 13
                }

                MouseArea {
                    id: histMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AIState.clearHistory()
                }
            }

            // Yeni Sohbet Butonu
            Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: 13
                color: newChatMa.containsMouse ? Theme.surfaceHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰭹"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 13
                }

                MouseArea {
                    id: newChatMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        AIState.newChat()
                        inputField.forceActiveFocus()
                    }
                }
            }

            // Kapatma Butonu
            Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: 13
                color: closeMa.containsMouse ? Theme.surfaceHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AIState.close()
                }
            }
        }

        // ── MESAJ ALANI VEYA BOŞ DURUM ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Boş Durum (Ekran Görüntüsü 1 ile Birebir)
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.88
                spacing: Theme.spacingMedium
                visible: AIState.messages.length === 0

                // Beyin İkonu
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰧑"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 42
                }

                // Başlık: Bir YZ bağla
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Bir YZ bağla"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    font.bold: true
                }

                // Açıklama Metni
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: "Enyxma'nın yanıtlamak için bir yapay zekaya ihtiyacı var. Bir kez ayarlayın ve asistan hazır."
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    lineHeight: 1.3
                }

                Item { implicitHeight: 4 }

                // Kurulumu Aç Butonu
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: Theme.radiusWidget
                    color: setupMa.containsMouse ? Theme.surfaceHover : Theme.textPrimary

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation { duration: Theme.animFast }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall

                        Text {
                            text: "✦"
                            color: setupMa.containsMouse ? Theme.accent : Theme.bgDark
                            font.family: Theme.fontMono
                            font.pixelSize: 13
                        }

                        Text {
                            text: "Kurulumu aç"
                            color: setupMa.containsMouse ? Theme.textPrimary : Theme.bgDark
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: setupMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["kitty", "-e", "bash", "-c", "echo '=== Enyxma AI Kurulum Sihirbazı ==='; echo 'API anahtarınızı ~/.config/enyxma/ai.env içine ekleyebilirsiniz:'; echo 'OPENAI_API_KEY=... veya ANTHROPIC_API_KEY=... veya GEMINI_API_KEY=...'; read -p 'Devam etmek için Enter tuşuna basın...'"])
                        }
                    }
                }

                // Alt Açıklama / env dosyası yolu
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: "Veya ~/.config/enyxma/ai.env dosyasına bir API anahtarı ekleyin"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }
            }

            // Mesaj Akışı Listesi
            ListView {
                id: messageListView
                anchors.fill: parent
                clip: true
                spacing: Theme.spacingMedium
                model: AIState.messages
                visible: AIState.messages.length > 0

                onCountChanged: {
                    Qt.callLater(() => messageListView.positionViewAtEnd())
                }

                delegate: Item {
                    id: messageDelegate
                    required property var modelData
                    required property int index

                    readonly property bool isUser: modelData.role === "user"

                    width: messageListView.width
                    implicitHeight: bubbleRect.implicitHeight + 18

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 3

                        Text {
                            Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft
                            text: isUser ? "SEN" : "ENYXMA AI"
                            color: isUser ? Theme.textSecondary : Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Rectangle {
                            id: bubbleRect
                            Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft
                            width: Math.min(bubbleCol.implicitWidth + Theme.spacingMedium * 2, messageListView.width * 0.88)
                            implicitHeight: bubbleCol.implicitHeight + Theme.spacingMedium * 2
                            radius: Theme.radiusWidget
                            color: isUser ? Theme.surfaceActive : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: Theme.borderWidth

                            ColumnLayout {
                                id: bubbleCol
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMedium
                                spacing: Theme.spacingXS

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.content || (AIState.isStreaming && index === AIState.messages.length - 1 ? "Düşünüyor..." : "")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── ALT GİRİŞ KAPSÜLÜ ──
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Math.max(42, inputRow.implicitHeight + 10)
            radius: Theme.radiusWidget
            color: Theme.surface1
            border.color: inputField.activeFocus ? Theme.borderFocus : Theme.borderSubtle
            border.width: Theme.borderWidth

            Behavior on border.color {
                enabled: !Theme.reduceMotion
                ColorAnimation { duration: Theme.animFast }
            }

            RowLayout {
                id: inputRow
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingSmall
                anchors.rightMargin: Theme.spacingSmall
                spacing: Theme.spacingXS

                // Görsel Ekleme Butonu
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 15
                    color: imgBtnMa.containsMouse ? Theme.surfaceHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰋩"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                    }

                    MouseArea {
                        id: imgBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pickImageProc.running = true
                    }
                }

                // Metin Giriş Alanı
                TextArea {
                    id: inputField
                    Layout.fillWidth: true
                    wrapMode: TextArea.Wrap
                    placeholderText: "Enyxma'ya mesaj gönder"
                    placeholderTextColor: Theme.textMuted
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    background: null
                    leftPadding: 4
                    rightPadding: 4
                    topPadding: 8
                    bottomPadding: 8

                    Keys.onReturnPressed: (event) => {
                        if (!(event.modifiers & Qt.ShiftModifier)) {
                            if (text.trim().length > 0) {
                                AIState.sendMessage(text.trim())
                                text = ""
                            }
                            event.accepted = true
                        }
                    }
                }

                // Gönder Butonu (Dairesel Ok)
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 15
                    readonly property bool canSend: inputField.text.trim().length > 0
                    color: canSend ? Theme.accent : Theme.surface2

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation { duration: Theme.animFast }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁝"
                        color: parent.canSend ? Theme.bgDark : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (inputField.text.trim().length > 0) {
                                AIState.sendMessage(inputField.text.trim())
                                inputField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
