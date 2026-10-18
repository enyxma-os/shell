import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    implicitHeight: 24
    onClicked: SystemState.toggleControlCenter()

    // Pil / Güç Durumu
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: (SystemState.isBatteryPresent ? ("󰁹 %" + SystemState.batteryPercent) : "AC") + (SystemState.isCharging ? " ⚡" : "")
        color: Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
    }
}
