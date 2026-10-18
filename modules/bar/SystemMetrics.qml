import QtQuick
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    implicitWidth: rowContent.implicitWidth + Theme.spacingSmall * 2
    onClicked: SystemState.toggleControlCenter()

    Row {
        id: rowContent
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        // Pil / Güç Durumu
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: (SystemState.isBatteryPresent ? ("󰁹 %" + SystemState.batteryPercent) : "AC") + (SystemState.isCharging ? " ⚡" : "")
            color: Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
