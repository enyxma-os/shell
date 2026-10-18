import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: TimeState.isPanelOpen || TimeState.isMenuOpen

    // Sol Tık: Harmonik Bento Hub (Takvim & Zaman Paneli)
    onClicked: TimeState.togglePanel()

    // Sağ Tık: Hızlı Format & Ayar Menüsü
    onRightClicked: TimeState.toggleMenu()

    // Hava durumu mikro glifi
    Text {
        text: WeatherState.conditionGlyph
        font.pixelSize: 12
        Layout.alignment: Qt.AlignVCenter
    }

    // Canlı Saat
    Text {
        text: TimeState.formattedTime
        color: root.isActive ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        Layout.alignment: Qt.AlignVCenter
    }

    // Ayraç nokta
    Text {
        text: "•"
        color: Theme.textMuted
        font.pixelSize: 10
        Layout.alignment: Qt.AlignVCenter
    }

    // Tarih
    Text {
        text: TimeState.formattedDate
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        Layout.alignment: Qt.AlignVCenter
    }

    // Sıcaklık (Kompakt)
    Text {
        text: WeatherState.displayTemp
        color: Theme.textMuted
        font.family: Theme.fontMono
        font.pixelSize: 10
        Layout.alignment: Qt.AlignVCenter
    }
}
