import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: NetworkState.isOpen
    onClicked: NetworkState.toggle()

    // Ağ İkonu (Ethernet / Wi-Fi / Bağlantı Yok)
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: {
            if (!NetworkState.isConnected) return "󰤭"
            if (NetworkState.connectionType === "ethernet") return "󰈀"
            if (NetworkState.signalStrength > 75) return "󰤨"
            if (NetworkState.signalStrength > 50) return "󰤥"
            if (NetworkState.signalStrength > 25) return "󰤢"
            return "󰤟"
        }
        color: NetworkState.isOpen ? Theme.accent : (NetworkState.isConnected ? Theme.textPrimary : Theme.textMuted)
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
    }

    // RX/TX Mini Aktivite Göstergesi
    Item {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 10
        implicitHeight: 14

        Column {
            anchors.centerIn: parent
            spacing: 2

            // RX
            Rectangle {
                width: 8
                height: 3
                radius: 1
                color: NetworkState.rxSpeedBytes > 1024 ? Theme.accent : Theme.surfaceActive
            }

            // TX
            Rectangle {
                width: 8
                height: 3
                radius: 1
                color: NetworkState.txSpeedBytes > 1024 ? Theme.accent : Theme.surfaceActive
            }
        }
    }
}
