import QtQuick
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    implicitWidth: rowContent.implicitWidth + Theme.spacingSmall * 2
    onClicked: StorageState.toggle()

    Row {
        id: rowContent
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        // Depolama / Disk İkonu
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰋊"
            color: StorageState.isOpen ? Theme.accent : Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }

        // Kök Doluluk Yüzdesi
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: StorageState.rootPercent + "%"
            color: Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
