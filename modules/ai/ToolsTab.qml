import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

Item {
    id: root

    implicitHeight: col.implicitHeight + Theme.spacingLarge * 2

    Flickable {
        anchors.fill: parent
        anchors.margins: Theme.spacingMedium
        contentWidth: width
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: parent.width
            spacing: Theme.spacingMedium

            // ── BÖLÜM: İNDİR ──
            Text {
                text: "İNDİR"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: 8.5
                font.bold: true
                font.letterSpacing: 1.5
            }

            // Cobalt Motoru Kartı
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: cobaltRow.implicitHeight + Theme.spacingSmall * 2
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                RowLayout {
                    id: cobaltRow
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSmall
                    spacing: Theme.spacingSmall

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Cobalt motoru"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }

                        Text {
                            text: "Docker gerekli. `enyxma update` yükler"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    // Anahtar (Toggle Switch)
                    Rectangle {
                        implicitWidth: 38
                        implicitHeight: 20
                        radius: 10
                        color: ToolsState.cobaltEnabled ? Theme.accent : Theme.surface2

                        Behavior on color {
                            enabled: !Theme.reduceMotion
                            ColorAnimation { duration: Theme.animFast }
                        }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: ToolsState.cobaltEnabled ? parent.width - width - 2 : 2
                            color: ToolsState.cobaltEnabled ? Theme.bgDark : Theme.textSecondary

                            Behavior on x {
                                enabled: !Theme.reduceMotion
                                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ToolsState.cobaltEnabled = !ToolsState.cobaltEnabled
                        }
                    }
                }
            }

            // Bağlantı Giriş Alanı
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 34
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: urlInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                border.width: Theme.borderWidth

                Behavior on border.color {
                    enabled: !Theme.reduceMotion
                    ColorAnimation { duration: Theme.animFast }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingSmall
                    anchors.rightMargin: Theme.spacingSmall
                    spacing: Theme.spacingSmall

                    Text {
                        text: "󰌷"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                    }

                    TextInput {
                        id: urlInput
                        Layout.fillWidth: true
                        text: ToolsState.urlText
                        onTextChanged: ToolsState.urlText = text
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        selectByMouse: true
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: urlInput.text.length === 0
                            text: "İndirmek için bir bağlantı yapıştırın"
                            color: Theme.textMuted
                            font: urlInput.font
                        }

                        onAccepted: ToolsState.startDownload()
                    }
                }
            }

            // Mod Hapları: Otomatik | Ses | Sessiz
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Repeater {
                    model: [
                        { id: "auto", label: "Otomatik" },
                        { id: "audio", label: "Ses" },
                        { id: "mute", label: "Sessiz" }
                    ]

                    delegate: Rectangle {
                        id: modePill
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusWidget
                        readonly property bool active: ToolsState.dlMode === modelData.id
                        color: active ? Theme.textPrimary : Theme.surface1
                        border.color: active ? "transparent" : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Behavior on color {
                            enabled: !Theme.reduceMotion
                            ColorAnimation { duration: Theme.animFast }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modePill.modelData.label
                            color: modePill.active ? Theme.bgDark : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: modePill.active
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ToolsState.dlMode = modePill.modelData.id
                        }
                    }
                }
            }

            // İndir Butonu
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Theme.radiusWidget
                readonly property bool canDownload: ToolsState.urlText.trim().length > 0 && !ToolsState.isDownloading
                color: canDownload ? (dlBtnMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive) : Theme.surface1
                border.color: canDownload ? Theme.accent : Theme.borderSubtle
                border.width: Theme.borderWidth

                Behavior on color {
                    enabled: !Theme.reduceMotion
                    ColorAnimation { duration: Theme.animFast }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Text {
                        text: "󰇚"
                        color: parent.parent.canDownload ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                    }

                    Text {
                        text: ToolsState.isDownloading ? "İndiriliyor..." : "İndir"
                        color: parent.parent.canDownload ? Theme.textPrimary : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                MouseArea {
                    id: dlBtnMa
                    anchors.fill: parent
                    cursorShape: parent.canDownload ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (parent.canDownload) {
                            ToolsState.startDownload()
                        }
                    }
                }
            }

            // YT-DLP Bilgi Kartı
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: infoCol.implicitHeight + Theme.spacingSmall * 2
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                ColumnLayout {
                    id: infoCol
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSmall
                    spacing: 4

                    RowLayout {
                        spacing: Theme.spacingXS

                        Text {
                            text: "🌐"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "YT-DLP TARAFINDAN YAPILDI"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 7.5
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "YouTube, Twitter/X, Reddit, TikTok ve daha birçoğu da dahil 1000+ sitede çalışır."
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.Wrap
                        lineHeight: 1.2
                    }
                }
            }

            // ── BÖLÜM: SON İNDİRİLENLER ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "SON İNDİRİLENLER"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 8.5
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Text {
                    visible: ToolsState.recentDownloads.length === 0
                    text: "Henüz bir şey indirilmedi. Aldığınız bağlantılar buraya gelir."
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Repeater {
                    model: ToolsState.recentDownloads
                    delegate: Rectangle {
                        id: fileRow
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusWidget
                        color: fileMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: Theme.borderWidth

                        MouseArea {
                            id: fileMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ToolsState.openFile(fileRow.modelData.path)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingSmall
                            anchors.rightMargin: Theme.spacingSmall
                            spacing: Theme.spacingSmall

                            Text {
                                text: "󰈔"
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 12
                            }

                            Text {
                                Layout.fillWidth: true
                                text: fileRow.modelData.name
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideMiddle
                            }

                            Text {
                                text: "✕"
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ToolsState.removeFile(fileRow.modelData.path)
                                }
                            }
                        }
                    }
                }
            }

            // ── BÖLÜM: DÖNÜŞTÜR VE YÜKLE ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "DÖNÜŞTÜR VE YÜKLE"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 8.5
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                // Videoyu Sıkıştır Butonu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Theme.radiusWidget
                    color: compMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰑮"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 13
                        }

                        Text {
                            text: "Videoyu sıkıştır..."
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    MouseArea {
                        id: compMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ToolsState.compressVideo()
                    }
                }

                // Uygulama Kur Butonu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Theme.radiusWidget
                    color: instMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰍹"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 13
                        }

                        Text {
                            text: "Uygulama kur..."
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    MouseArea {
                        id: instMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ToolsState.installApp()
                    }
                }
            }
        }
    }
}
