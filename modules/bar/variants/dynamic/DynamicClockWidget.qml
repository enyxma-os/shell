import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: TimeState.isPanelOpen || TimeState.isMenuOpen

    // Sol Tik: Harmonik Bento Hub paneli
    onClicked: TimeState.togglePanel()

    // Sag Tik: Hizli Format ve Ayar Menusu
    onRightClicked: TimeState.toggleMenu()

    // Hava durumu mikro glifi
    Text {
        text: WeatherState.conditionGlyph
        font.pixelSize: 12
        Layout.alignment: Qt.AlignVCenter
    }

    // Canli Saat
    Text {
        text: TimeState.formattedTime
        color: root.isActive ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        Layout.alignment: Qt.AlignVCenter
    }

    // Ayrac nokta
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

    // Sicaklik
    Text {
        text: WeatherState.displayTemp
        color: Theme.textMuted
        font.family: Theme.fontMono
        font.pixelSize: 10
        Layout.alignment: Qt.AlignVCenter
    }
}

