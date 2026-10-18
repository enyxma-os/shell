import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../services"
import "../../widgets"

RowLayout {
    id: root
    spacing: Theme.spacingXS

    Repeater {
        model: SystemTray.items

        EnyxmaPill {
            id: trayPill
            implicitHeight: 24
            implicitWidth: 24

            onClicked: {
                if (modelData) {
                    modelData.activate()
                }
            }

            Image {
                source: modelData?.icon ?? ""
                width: 14
                height: 14
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
