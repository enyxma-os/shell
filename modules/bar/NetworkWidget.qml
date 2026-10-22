import QtQuick
import "../../services"
import "../../widgets"

/**
 * NetworkWidget — RX/TX aktivite göstergesi (bkz. NetworkState rxLevel/txLevel).
 * Bu dosya Bar.qml içinden kullanılır.
 */
EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: NetworkState.isOpen
    onClicked: NetworkState.toggle()

    Text {
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

    Item {
        implicitWidth: 10
        implicitHeight: 14

        Column {
            anchors.centerIn: parent
            spacing: 2

            Rectangle {
                width: 8
                height: 3
                radius: 1
                color: NetworkState.rxLevel > 0.08 ? Theme.accent : Theme.surfaceActive
            }

            Rectangle {
                width: 8
                height: 3
                radius: 1
                color: NetworkState.txLevel > 0.08 ? Theme.accent : Theme.surfaceActive
            }
        }
    }
}
