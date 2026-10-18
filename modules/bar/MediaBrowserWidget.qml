pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root
    implicitHeight: 24
    isActive: MediaBrowserState.isOpen

    mouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: MediaBrowserState.toggle("screenshots")
    onRightClicked: MediaBrowserState.toggle("videos")

    Text {
        text: "󰋩"
        color: MediaBrowserState.isOpen ? Theme.accent : Theme.textPrimary
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
    }
}
