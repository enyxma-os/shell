import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../services"
import "../../widgets"

/**
 * Tray — StatusNotifierItem tepsisi.
 * Her tepsi öğesi için 24x24 EnyxmaPill içinde 16x16 sınırlandırılmış ikon.
 */
RowLayout {
    id: root
    spacing: Theme.spacingXS

    Repeater {
        model: SystemTray.items

        EnyxmaPill {
            id: trayPill
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            implicitWidth: 24
            implicitHeight: 24
            clip: true
            visible: !!modelData

            onRightClicked: {
                if (modelData) {
                    modelData.display(trayPill, 0, trayPill.height)
                }
            }

            onClicked: {
                if (modelData) {
                    modelData.activate()
                }
            }

            onMiddleClicked: {
                if (modelData) {
                    modelData.secondaryActivate()
                }
            }

            Image {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignCenter
                sourceSize.width: 16
                sourceSize.height: 16
                width: 16
                height: 16
                source: modelData?.icon ?? ""
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
            }

            Text {
                visible: !!(modelData && !modelData.icon)
                text: "•"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}
