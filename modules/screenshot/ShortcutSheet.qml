import QtQuick
import QtQuick.Layouts
import "Singletons"

Item {
    id: sheet

    property var tools: []
    signal closeRequested()

    readonly property var actions: [
        { key: "Ctrl+C", label: "Panoya Kopyala" },
        { key: "Ctrl+S", label: "Diske Kaydet" },
        { key: "Ctrl+B", label: "✦ Mockup Stüdyosu" },
        { key: "Enter",  label: "Kopyala ve Kaydet" },
        { key: "Ctrl+Z", label: "Geri Al" },
        { key: "Ctrl+Y", label: "Yinele" },
        { key: "Ctrl+A", label: "Tüm Ekranı Seç" },
        { key: "Space",  label: "Pencere / Bölge Değiştir" },
        { key: "f",      label: "Şekil Dolgusu (Aç/Kapat)" },
        { key: "k",      label: "Serbest Çizim Dalgası" },
        { key: "[ / ]",  label: "Çizgi Kalınlığı" },
        { key: "1..8",   label: "Renk Paleti" },
        { key: "Del",    label: "Seçili Öğeyi Sil" },
        { key: "Esc",    label: "Kapat / Geri Dön" }
    ]

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
                    text: "✦ Kısayol Rehberi"
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
