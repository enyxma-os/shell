import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: StorageState.isOpen
    onClicked: StorageState.toggle()

    // Depolama / Disk İkonu
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: "󰋊"
        color: StorageState.isOpen ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
    }

    // Kök Doluluk Yüzdesi
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: StorageState.rootPercent + "%"
        color: Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
    }
}
