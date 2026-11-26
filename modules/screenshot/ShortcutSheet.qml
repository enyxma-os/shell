import QtQuick
import QtQuick.Layouts
import "Singletons"

Item {
    id: sheet

    property var tools: []
    signal closeRequested()

    readonly property var actions: {
        var _l = Theme.lang;
        return [
            { key: "Ctrl+C", label: Theme.t("Panoya Kopyala", "Copy to Clipboard") },
            { key: "Ctrl+S", label: Theme.t("Diske Kaydet", "Save to Disk") },
            { key: "Ctrl+B", label: Theme.t("✦ Mockup Stüdyosu", "✦ Mockup Studio") },
            { key: "Enter",  label: Theme.t("Kopyala ve Kaydet", "Copy and Save") },
            { key: "Ctrl+Z", label: Theme.t("Geri Al", "Undo") },
            { key: "Ctrl+Y", label: Theme.t("Yinele", "Redo") },
            { key: "Ctrl+A", label: Theme.t("Tüm Ekranı Seç", "Select Whole Screen") },
            { key: "Space",  label: Theme.t("Pencere / Bölge Değiştir", "Switch Window / Region") },
            { key: "f",      label: Theme.t("Şekil Dolgusu Aç/Kapat", "Toggle Shape Fill") },
            { key: "k",      label: Theme.t("Serbest Çizim Dalgası", "Sketchy Line Mode") },
            { key: "[ / ]",  label: Theme.t("Çizgi Kalınlığı", "Stroke Width") },
            { key: "1..8",   label: Theme.t("Renk Paleti", "Color Palette") },
            { key: "Del",    label: Theme.t("Seçili Öğeyi Sil", "Delete Selected") },
            { key: "Esc",    label: Theme.t("Kapat / Geri Dön", "Close / Back") }
        ];
    }

    focus: visible

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.bgGlass
        border.color: Theme.borderSubtle
        border.width: 1
        radius: Theme.radiusPanel
        implicitWidth: 380
        implicitHeight: col.implicitHeight + 36

        ColumnLayout {
            id: col
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: Theme.t("✦ Kısayol Rehberi", "✦ Shortcut Guide")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.DemiBold
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Esc"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.borderSubtle
            }

            Repeater {
                model: sheet.actions

                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: parent.modelData.label
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    Rectangle {
                        radius: Theme.radiusSmall
                        color: Theme.surface2
                        border.color: Theme.borderSubtle
                        border.width: 1
                        implicitWidth: cap.implicitWidth + 12
                        implicitHeight: cap.implicitHeight + 4

                        Text {
                            id: cap
                            anchors.centerIn: parent
                            text: parent.parent.modelData.key
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: sheet.closeRequested()
    }
}
