import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

Item {
    id: root

    Rectangle {
        id: mainCard
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 42
        anchors.rightMargin: 12
        width: 368
        height: Math.min(parent.height - 64, contentCol.implicitHeight + 28)

        color: Theme.bgGlass
        radius: 0
        border.color: Theme.borderSubtle
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // Ust 2px Gotham kehribar vurgu seridi
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.accent
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            spacing: 8

            // ── Baslik: SISTEM // cekirdek ───────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: PerformanceState.kernel ? ("SİSTEM // " + PerformanceState.kernel) : "SİSTEM"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 1
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PerformanceState.close()
                    }
                }
            }

            // ── Keskin Sekme Cubugu: PERFORMANS | DEPOLAMA ───────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        { key: "performance", label: "PERFORMANS" },
                        { key: "storage", label: "DEPOLAMA" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: PerformanceState.activeTab === modelData.key
                        Layout.fillWidth: true
                        implicitHeight: 26
                        radius: 0
                        color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: active ? Theme.accent : Theme.borderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.active ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.bold: parent.active
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PerformanceState.openTab(modelData.key)
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

            // ── SEKME 1: PERFORMANS ──────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: PerformanceState.activeTab === "performance"
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: PerformanceState.cpuModel; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text { visible: PerformanceState.cpuCores > 0; text: PerformanceState.cpuCores + "T"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11 }
                    Text { text: PerformanceState.cpuPercent + "%"; color: PerformanceState.cpuPercent > 80 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 4
                    radius: 0
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 0
                        color: PerformanceState.cpuPercent > 80 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.cpuPercent)) / 100
                    }
                }

                Sparkline {
                    Layout.fillWidth: true
                    implicitHeight: 22
                    value: PerformanceState.cpuPercent
                    active: PerformanceState.isOpen && PerformanceState.activeTab === "performance"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "YÜK 1 · 5 · 15"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.fillWidth: true }
                    Text { text: PerformanceState.load1 + " · " + PerformanceState.load5 + " · " + PerformanceState.load15; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: PerformanceState.topProcesses.length > 0
                    spacing: 2
                    Repeater {
                        model: PerformanceState.topProcesses
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Text { text: modelData.name; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: modelData.cpu; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11 }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "BELLEK"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    Text { text: PerformanceState.memPercent + "%"; color: PerformanceState.memPercent > 85 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 4
                    radius: 0
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 0
                        color: PerformanceState.memPercent > 85 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.memPercent)) / 100
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "KULLANILAN: " + PerformanceState.memUsedGiB.toFixed(1) + "G"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.fillWidth: true }
                    Text { text: "BOŞ: " + PerformanceState.memAvailGiB.toFixed(1) + "G"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10 }
                    Text { text: "/ " + PerformanceState.memTotalGiB.toFixed(1) + "G"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: PerformanceState.gpuModel; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text { text: PerformanceState.gpuPercent + "%"; color: PerformanceState.gpuPercent > 80 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 4
                    radius: 0
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 0
                        color: PerformanceState.gpuPercent > 80 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.gpuPercent)) / 100
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "VRAM"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    Text {
                        text: PerformanceState.vramTotalGiB > 0 ? (PerformanceState.vramUsedGiB.toFixed(1) + " / " + PerformanceState.vramTotalGiB.toFixed(1) + " GiB") : (PerformanceState.vramPercent + "%")
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 0
                    color: btopMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                    border.color: btopMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "[BTOP'U AÇ]"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                    MouseArea { id: btopMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: PerformanceState.openBtop() }
                }
            }

            // ── SEKME 2: DEPOLAMA ────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: PerformanceState.activeTab === "storage"
                spacing: 7

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: rootSumCol.implicitHeight + 12
                    radius: 0
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        id: rootSumCol
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "ANA DİSK // " + StorageState.rootMount; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                            Text { text: StorageState.rootPercent + "%"; color: StorageState.rootPercent > 85 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 0
                            color: Theme.surfaceActive
                            Rectangle {
                                height: parent.height
                                radius: 0
                                color: StorageState.rootPercent > 85 ? Theme.danger : Theme.accent
                                width: parent.width * Math.max(0, Math.min(100, StorageState.rootPercent)) / 100
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "KULLANILAN: " + StorageState.rootUsedGiB.toFixed(1) + "G"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.fillWidth: true }
                            Text { text: "BOŞ: " + StorageState.rootFreeGiB.toFixed(1) + "G"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10 }
                            Text { text: "/ " + StorageState.rootTotalGiB.toFixed(1) + "G"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "SÜRÜCÜLER // " + StorageState.driveCount; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 56
                        implicitHeight: 20
                        radius: 0
                        color: refMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: refMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "[YENİLE]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9 }
                        MouseArea { id: refMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: StorageState.refresh() }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: StorageState.actionError.length > 0
                    text: "! " + StorageState.actionError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                ListView {
                    id: driveList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(240, Math.max(44, contentHeight))
                    clip: true
                    spacing: 4
                    model: StorageState.drives

                    delegate: Rectangle {
                        required property var modelData
                        width: driveList.width
                        implicitHeight: drvCol.implicitHeight + 10
                        radius: 0
                        color: drvMa.containsMouse && modelData.mounted ? Theme.surfaceHover : Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        MouseArea {
                            id: drvMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.mounted ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: if (modelData.mounted) StorageState.openMount(modelData.mountPoint)
                        }

                        ColumnLayout {
                            id: drvCol
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 3

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: StorageState.driveTypeIcon(modelData.driveType) + " " + modelData.model
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text { text: StorageState.formatCapacity(modelData.size); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.media + (modelData.fileSystems ? (" · " + modelData.fileSystems) : "") + " · " + modelData.state + (modelData.percent >= 0 ? (" · %" + modelData.percent) : "")
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text { visible: modelData.freeBytes >= 0; text: StorageState.formatFree(modelData.freeBytes); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: modelData.removable && modelData.partPath !== ""
                                spacing: 4

                                Rectangle {
                                    implicitWidth: 64
                                    implicitHeight: 20
                                    radius: 0
                                    color: Theme.surfaceActive
                                    border.color: Theme.accent
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.mounted ? "[AYIR]" : "[BAĞLA]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: !StorageState.actionBusy
                                        onClicked: {
                                            if (modelData.mounted) StorageState.unmountDrive(modelData.partPath)
                                            else StorageState.mountDrive(modelData.partPath)
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: modelData.diskPath !== ""
                                    implicitWidth: 68
                                    implicitHeight: 20
                                    radius: 0
                                    color: Theme.surfaceActive
                                    border.color: Theme.borderSubtle
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "[ÇIKAR]"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 9 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: !StorageState.actionBusy
                                        onClicked: StorageState.ejectDrive(modelData.diskPath, modelData.mounted ? modelData.partPath : "")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

