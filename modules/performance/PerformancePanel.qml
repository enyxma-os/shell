import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"
import "."

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-performance"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: PerformanceState.isOpen ? 42 : 20
        right: 12
    }

    implicitWidth: 340
    implicitHeight: mainCard.implicitHeight
    color: "transparent"

    visible: mainCard.opacity > 0.0

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: PerformanceState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            // ── BAŞLIK BÖLÜMÜ (PERFORMANS, ÇEKİRDEK, KAPAT) ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "PERFORMANS"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 2
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    visible: PerformanceState.kernel.length > 0
                    text: "ÇEKİRDEK " + PerformanceState.kernel
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Rectangle {
                    implicitHeight: 24
                    implicitWidth: 24
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

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── CPU BÖLÜMÜ ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: PerformanceState.cpuModel
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    visible: PerformanceState.cpuCores > 0
                    text: PerformanceState.cpuCores + "C / " + PerformanceState.cpuCores + "T"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }
            }

            // CPU İlerleme Çubuğu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "KULLANIM"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.surfaceActive

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: PerformanceState.cpuPercent > 80 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.cpuPercent)) / 100

                        Behavior on width {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: Theme.animNormal
                                easing.type: Easing.OutQuint
                            }
                        }
                    }
                }

                Text {
                    text: PerformanceState.cpuPercent + "%"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            // CPU Canlı Çizgi Dalga Grafiği (Sparkline)
            Sparkline {
                Layout.fillWidth: true
                implicitHeight: 36
                value: PerformanceState.cpuPercent
                active: PerformanceState.isOpen
            }

            // Yük Ortalamaları
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Yük 1 · 5 · 15"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: PerformanceState.load1 + " · " + PerformanceState.load5 + " · " + PerformanceState.load15
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // En Çok Tüketen İşlemler
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                visible: PerformanceState.topProcesses.length > 0

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "EN ÜST İŞLEMLER"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "CPU"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                    }
                }

                Repeater {
                    model: PerformanceState.topProcesses

                    delegate: RowLayout {
                        id: procDelegate
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true

                        Text {
                            text: "0" + (procDelegate.index + 1)
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                        }

                        Text {
                            text: procDelegate.modelData.name
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: procDelegate.modelData.cpu
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── BELLEK (RAM) BÖLÜMÜ ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "BELLEK"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.surfaceActive

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: PerformanceState.memPercent > 85 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.memPercent)) / 100

                        Behavior on width {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: Theme.animNormal
                                easing.type: Easing.OutQuint
                            }
                        }
                    }
                }

                Text {
                    text: PerformanceState.memPercent + "%"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            // Bellek 3 Sütunlu Metrik Alanı
            Row {
                Layout.fillWidth: true
                height: 32

                Item {
                    width: parent.width / 3
                    height: parent.height

                    Text {
                        anchors.top: parent.top
                        text: "KULLANILAN"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        text: PerformanceState.memUsedGiB.toFixed(1) + " GiB"
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                Item {
                    width: parent.width / 3
                    height: parent.height

                    Text {
                        anchors.top: parent.top
                        text: "KULLANILABİLİR"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        text: PerformanceState.memAvailGiB.toFixed(1) + " GiB"
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                Item {
                    width: parent.width / 3
                    height: parent.height

                    Text {
                        anchors.top: parent.top
                        text: "TOPLAM"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        text: PerformanceState.memTotalGiB.toFixed(1) + " GiB"
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── GRAFİK İŞLEMCİ (GPU & VRAM) BÖLÜMÜ ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: PerformanceState.gpuModel
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: "GPU"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }
            }

            // GPU İlerleme Çubuğu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "YÜK"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.surfaceActive

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: PerformanceState.gpuPercent > 80 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.gpuPercent)) / 100

                        Behavior on width {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: Theme.animNormal
                                easing.type: Easing.OutQuint
                            }
                        }
                    }
                }

                Text {
                    text: PerformanceState.gpuPercent + "%"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            // VRAM İlerleme Çubuğu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "VRAM"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.surfaceActive

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: PerformanceState.vramPercent > 85 ? Theme.danger : Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, PerformanceState.vramPercent)) / 100

                        Behavior on width {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: Theme.animNormal
                                easing.type: Easing.OutQuint
                            }
                        }
                    }
                }

                Text {
                    text: PerformanceState.vramTotalGiB > 0 ? (PerformanceState.vramUsedGiB.toFixed(1) + " / " + PerformanceState.vramTotalGiB.toFixed(1) + " GiB") : (PerformanceState.vramPercent + "%")
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── ALT BUTON (btop'u aç) ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 28
                radius: Theme.radiusButton
                color: btopMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }

                Text {
                    anchors.centerIn: parent
                    text: "btop'u aç"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }

                MouseArea {
                    id: btopMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PerformanceState.openBtop()
                }
            }
        }
    }
}
