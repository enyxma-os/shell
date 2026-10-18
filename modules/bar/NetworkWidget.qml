import QtQuick
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    implicitWidth: rowContent.implicitWidth + Theme.spacingSmall * 2
    onClicked: NetworkState.toggle()

    Row {
        id: rowContent
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        // Ağ İkonu (Ethernet / Wi-Fi / Bağlantı Yok)
        Text {
            anchors.verticalCenter: parent.verticalCenter
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

        // RX / TX Mini Trafik Göstergesi (Ryoku Reverse-Engineered Meter)
        Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 26
            implicitHeight: 16
            visible: NetworkState.isConnected

            // RX Sütunu
            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "RX"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 6
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        width: 4
                        height: 2
                        radius: 1
                        color: NetworkState.rxLevel > (3 - index) / 4 ? Theme.accent : Theme.surfaceActive
                    }
                }
            }

            // TX Sütunu
            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "TX"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 6
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        width: 4
                        height: 2
                        radius: 1
                        color: NetworkState.txLevel > (3 - index) / 4 ? Theme.accent : Theme.surfaceActive
                    }
                }
            }
        }
    }
}
