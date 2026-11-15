import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../services"

RowLayout {
    id: root
    spacing: 3

    Repeater {
        model: HyprlandState.workspaces

        Rectangle {
            id: wsCell
            property int wsId: modelData?.id ?? 0
            readonly property bool isFocused: wsId === HyprlandState.focusedWorkspaceId
            readonly property bool isOccupied: HyprlandState.isOccupied(wsId)

            implicitWidth: 26
            implicitHeight: 20
            radius: 2

            // Zemin: Odakliysa kehribar dolgu, doluysa grafit zemin, bossa seffaf
            color: isFocused
                ? Theme.accent
                : (isOccupied
                    ? (cellMouse.containsMouse ? Theme.surfaceActive : Theme.surface1)
                    : (cellMouse.containsMouse ? Theme.surfaceHover : "transparent"))

            // Cerceve: Odakliysa kehribar, doluysa belirgin grafit, bossa soluk grafit
            border.color: isFocused
                ? Theme.accent
                : (isOccupied ? Theme.borderSubtle : Qt.rgba(0.20, 0.24, 0.30, 0.40))
            border.width: 1

            // Sayisal hucre metni: 01, 02 ve benzeri
            Text {
                anchors.centerIn: parent
                text: wsCell.wsId < 10 ? ("0" + wsCell.wsId) : ("" + wsCell.wsId)
                color: wsCell.isFocused
                    ? Theme.accentOn
                    : (wsCell.isOccupied ? Theme.textPrimary : Theme.textMuted)
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.bold: wsCell.isFocused || wsCell.isOccupied
            }

            // Dolu calisma alani durum isareti: sag ustte 3x3 piksel kehribar ledi
            Rectangle {
                visible: wsCell.isOccupied && !wsCell.isFocused
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: 2
                }
                width: 3
                height: 3
                radius: 1
                color: Theme.accent
            }

            MouseArea {
                id: cellMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsCell.wsId > 0) {
                        HyprlandState.switchWorkspace(wsCell.wsId)
                    }
                }
            }
        }
    }
}

