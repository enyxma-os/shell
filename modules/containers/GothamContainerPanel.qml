import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * GothamContainerPanel — Gotham 2.0 Konteyner Izleyici Paneli.
 */
Item {
    id: root

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + 6
        anchors.rightMargin: 12
        width: 396
        height: Math.min(parent.height - Theme.barHeight - 24, 500)
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 2; color: Theme.accent; z: 10 }

        Item {
            id: headerArea
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 46

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 12; spacing: 8

                Text { text: "󰡨"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 15 }
                Text {
                    text: "KONTEYNER // " + (ContainerState.engine !== "" && ContainerState.engine !== "none" ? ContainerState.engine.toUpperCase() : "YOK")
                    color: Theme.textPrimary; font.family: Theme.fontDisplay; font.pixelSize: Theme.fontSizeNormal; font.bold: true; font.letterSpacing: 1; Layout.fillWidth: true
                }

                Rectangle {
                    visible: ContainerState.engine !== "none"
                    implicitWidth: 24; implicitHeight: 24; radius: 0
                    color: refMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: refMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                    Text { anchors.centerIn: parent; text: "↻"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 12 }
                    MouseArea { id: refMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ContainerState.refresh() }
                }

                Rectangle {
                    implicitWidth: 24; implicitHeight: 24; radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                    Text { anchors.centerIn: parent; text: "×"; color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 14 }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ContainerState.close() }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.borderSubtle }
        }

        Item {
            anchors.top: headerArea.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 14; clip: true

            Rectangle {
                anchors.centerIn: parent; width: parent.width; height: 90
                visible: ContainerState.engine === "none"
                radius: 0; color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                Text { anchors.centerIn: parent; text: I18n.t("Docker veya Podman kurulu değil", "Docker or Podman is not installed"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11 }
            }

            ListView {
                anchors.fill: parent
                visible: ContainerState.engine !== "none"
                clip: true; spacing: 6; boundsBehavior: Flickable.StopAtBounds
                model: ContainerState.containers

                delegate: Rectangle {
                    id: cRow
                    required property var modelData
                    readonly property bool isBusy: ContainerState.busyId === modelData.id
                    width: ListView.view.width; height: 60; radius: 0
                    color: modelData.running ? Theme.surfaceActive : Theme.surface1
                    border.color: modelData.running ? Theme.accent : Theme.borderSubtle; border.width: 1

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; spacing: 10

                        Rectangle { width: 8; height: 8; radius: 0; color: cRow.modelData.running ? Theme.success : Theme.textMuted }

                        Column {
                            Layout.fillWidth: true; spacing: 2
                            Text { width: parent.width; text: cRow.modelData.name; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                            Text { width: parent.width; text: cRow.modelData.image + " · " + cRow.modelData.status; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; elide: Text.ElideRight }
                        }

                        Rectangle {
                            implicitWidth: actTxt.implicitWidth + 14; implicitHeight: 26; radius: 0
                            color: actMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                            border.color: cRow.modelData.running ? Theme.danger : Theme.accent; border.width: 1
                            Text {
                                id: actTxt; anchors.centerIn: parent
                                text: cRow.isBusy ? "..." : (cRow.modelData.running ? I18n.t("DURDUR", "STOP") : I18n.t("BAŞLAT", "START"))
                                color: cRow.modelData.running ? Theme.danger : Theme.accent
                                font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true
                            }
                            MouseArea {
                                id: actMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (cRow.modelData.running) ContainerState.stopContainer(cRow.modelData.id)
                                    else ContainerState.startContainer(cRow.modelData.id)
                                }
                            }
                        }

                        Rectangle {
                            visible: cRow.modelData.running
                            implicitWidth: 26; implicitHeight: 26; radius: 0
                            color: rstMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                            border.color: rstMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                            Text { anchors.centerIn: parent; text: "↻"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12 }
                            MouseArea { id: rstMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ContainerState.restartContainer(cRow.modelData.id) }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: ContainerState.containers.length === 0
                    text: ContainerState.lastError !== "" ? ContainerState.lastError : I18n.t("Konteyner bulunamadı", "No containers found")
                    color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11
                }
            }
        }
    }
}
