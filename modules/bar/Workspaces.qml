import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../services"

RowLayout {
    id: root
    spacing: Theme.spacingXS

    Repeater {
        model: HyprlandState.workspaces

        Rectangle {
            id: wsItem
            property int wsId: modelData?.id ?? 0
            readonly property bool isFocused: wsId === HyprlandState.focusedWorkspaceId

            implicitWidth: isFocused ? (Theme.isGotham ? 26 : 28) : 10
            implicitHeight: Theme.isGotham ? 16 : 10
            radius: Theme.isGotham ? 1 : (height / 2)

            color: isFocused ? Theme.accent : (wsMouse.containsMouse ? Theme.surfaceHover : Theme.surface1)
            border.color: isFocused ? Theme.accent : Theme.borderSubtle
            border.width: Theme.borderWidth

            Text {
                visible: Theme.isGotham && wsItem.isFocused
                anchors.centerIn: parent
                text: wsItem.wsId < 10 ? ("0" + wsItem.wsId) : ("" + wsItem.wsId)
                color: Theme.accentOn
                font.family: Theme.fontMono
                font.pixelSize: 9
                font.bold: true
            }

            Behavior on implicitWidth {
                enabled: !Theme.reduceMotion
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on color {
                enabled: !Theme.reduceMotion
                ColorAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutQuint
                }
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsItem.wsId > 0) {
                        HyprlandState.switchWorkspace(wsItem.wsId)
                    }
                }
            }
        }
    }
}
