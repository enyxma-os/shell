pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root
    implicitHeight: 24
    isActive: WallpaperState.pickerVisible

    onClicked: WallpaperState.togglePicker()

    Text {
        text: "󰏘"
        color: WallpaperState.pickerVisible ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
    }
}
