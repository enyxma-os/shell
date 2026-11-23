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
        width: 376
        height: Math.min(parent.height - 64, contentCol.implicitHeight + Theme.spacingMedium * 2)

        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacingMedium
            spacing: Theme.spacingSmall

            // ── Baslik: Sistem & Cekirdek & Kapat ────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Sistem"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                }

                Text {
                    visible: PerformanceState.kernel.length > 0
                    text: PerformanceState.kernel
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item {
                    visible: PerformanceState.kernel.length === 0
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
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

            // ── Sekme Cubugu: Performans | Depolama ──────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { key: "performance", label: "Performans" },
                        { key: "storage", label: "Depolama" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: PerformanceState.activeTab === modelData.key
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusButton
                        color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: active ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.active ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: parent.active
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
                spacing: Theme.spacingSmall

                // Islemci
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: PerformanceState.cpuModel
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: PerformanceState.cpuTempC > 0
                        text: PerformanceState.cpuTempC + "°C"
                        color: PerformanceState.cpuTempC > 80 ? Theme.danger : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    Text {
                        text: PerformanceState.cpuPercent + "%"
                        color: PerformanceState.cpuPercent > 80 ? Theme.danger : Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 3
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

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                // Bellek
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "Bellek"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true; Layout.fillWidth: true }
                    Text {
                        text: PerformanceState.memUsedGiB.toFixed(1) + " / " + PerformanceState.memTotalGiB.toFixed(1) + " GB"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    Text { text: PerformanceState.memPercent + "%"; color: PerformanceState.memPercent > 85 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 3
                        color: PerformanceState.memPercent > 85 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.memPercent)) / 100
                    }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                // Ekran Karti
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: PerformanceState.gpuModel; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text {
                        visible: PerformanceState.gpuTempC > 0
                        text: PerformanceState.gpuTempC + "°C"
                        color: PerformanceState.gpuTempC > 82 ? Theme.danger : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    Text { text: PerformanceState.gpuPercent + "%"; color: PerformanceState.gpuPercent > 80 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.surfaceActive
                    Rectangle {
                        height: parent.height
                        radius: 3
                        color: PerformanceState.gpuPercent > 80 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.gpuPercent)) / 100
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "VRAM"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    Text {
                        text: PerformanceState.vramTotalGiB > 0 ? (PerformanceState.vramUsedGiB.toFixed(1) + " / " + PerformanceState.vramTotalGiB.toFixed(1) + " GB") : "-"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    Text {
                        text: PerformanceState.vramPercent + "%"
                        color: PerformanceState.vramPercent > 85 ? Theme.danger : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                // Uygulamalar (Gruplanmis, Siralanabilir, Kapatilabilir)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Uygulamalar"
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: [
                            { key: "cpu", label: "CPU" },
                            { key: "mem", label: "RAM" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active: PerformanceState.sortBy === modelData.key
                            implicitWidth: 42
                            implicitHeight: 20
                            radius: Theme.radiusButton
                            color: active ? Theme.surfaceActive : Theme.surface1
                            border.color: active ? Theme.accent : Theme.borderSubtle
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: parent.active ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: parent.active
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PerformanceState.setSortBy(modelData.key)
                            }
                        }
                    }
                }

                // Sutun Basliklari
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "Uygulama"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10; Layout.fillWidth: true }
                    Text { text: "CPU"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 42 }
                    Text { text: "RAM"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 56 }
                    Item { Layout.preferredWidth: 20 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Repeater {
                        model: PerformanceState.topProcesses
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 26
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: 6

                                Text {
                                    text: modelData.name
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.cpuText
                                    color: PerformanceState.sortBy === "cpu" ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 42
                                }

                                Text {
                                    text: modelData.memText
                                    color: PerformanceState.sortBy === "mem" ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 56
                                }

                                Rectangle {
                                    implicitWidth: 20
                                    implicitHeight: 18
                                    radius: Theme.radiusButton
                                    visible: modelData.canKill
                                    color: killMa.containsMouse ? Theme.surfaceHover : "transparent"
                                    border.color: killMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: killMa.containsMouse ? Theme.danger : Theme.textMuted
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                    }
                                    MouseArea {
                                        id: killMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: PerformanceState.killApp(modelData.pids)
                                    }
                                }

                                Item {
                                    visible: !modelData.canKill
                                    Layout.preferredWidth: 20
                                }
                            }
                        }
                    }
                }
            }

            // ── SEKME 2: DEPOLAMA ────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: PerformanceState.activeTab === "storage"
                spacing: Theme.spacingSmall

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: rootSumCol.implicitHeight + 14
                    radius: Theme.radiusButton
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        id: rootSumCol
                        anchors.fill: parent
                        anchors.margins: 7
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Ana Disk · " + StorageState.rootMount; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true; Layout.fillWidth: true }
                            Text { text: StorageState.rootPercent + "%"; color: StorageState.rootPercent > 85 ? Theme.danger : Theme.accent; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 6
                            radius: 3
                            color: Theme.surfaceActive
                            Rectangle {
                                height: parent.height
                                radius: 3
                                color: StorageState.rootPercent > 85 ? Theme.danger : Theme.accent
                                width: parent.width * Math.max(0, Math.min(100, StorageState.rootPercent)) / 100
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Kullanılan: " + StorageState.rootUsedGiB.toFixed(1) + " GiB"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.fillWidth: true }
                            Text { text: "Boş: " + StorageState.rootFreeGiB.toFixed(1) + " GiB"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10 }
                            Text { text: "/ " + StorageState.rootTotalGiB.toFixed(1) + " GiB"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Sürücüler (" + StorageState.driveCount + ")"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 54
                        implicitHeight: 20
                        radius: Theme.radiusButton
                        color: refMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "Yenile"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
                        MouseArea { id: refMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: StorageState.refresh() }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: StorageState.actionError.length > 0
                    text: StorageState.actionError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                ListView {
                    id: driveList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(260, Math.max(48, contentHeight))
                    clip: true
                    spacing: 6
                    model: StorageState.drives

                    delegate: Rectangle {
                        required property var modelData
                        width: driveList.width
                        implicitHeight: drvCol.implicitHeight + 12
                        radius: Theme.radiusButton
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
                                    text: modelData.media + (modelData.fileSystems ? (" · " + modelData.fileSystems) : "") + " · " + modelData.state + (modelData.mounted && modelData.percent >= 0 ? (" · %" + modelData.percent) : "")
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    visible: modelData.mounted && modelData.freeBytes >= 0
                                    text: StorageState.formatFree(modelData.freeBytes)
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: modelData.removable && modelData.partPath !== ""
                                spacing: 6

                                Rectangle {
                                    implicitWidth: 64
                                    implicitHeight: 20
                                    radius: Theme.radiusButton
                                    color: Theme.surfaceActive
                                    border.color: Theme.accent
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.mounted ? "Ayır" : "Bağla"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
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
                                    implicitWidth: 80
                                    implicitHeight: 20
                                    radius: Theme.radiusButton
                                    color: Theme.surfaceActive
                                    border.color: Theme.borderSubtle
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "Güvenli Çıkar"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10 }
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
