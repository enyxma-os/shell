import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-storage"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: StorageState.isOpen ? 42 : 20
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

        opacity: StorageState.isOpen ? 1.0 : 0.0

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

            // ── BAŞLIK BÖLÜMÜ (DEPOLAMA, SÜRÜCÜLER, KAPAT) ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "DEPOLAMA"
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
                    text: "SÜRÜCÜLER: " + StorageState.driveCount
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
                        onClicked: StorageState.close()
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── KÖK (ROOT) DOLULUK ÇUBUĞU ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: "KÖK"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
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
                        color: Theme.accent
                        width: parent.width * Math.max(0, Math.min(100, StorageState.rootPercent)) / 100

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
                    text: StorageState.rootPercent + "%"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            // ── KULLANILAN / BOŞ / TOPLAM METRİKLERİ ──
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
                        text: StorageState.rootUsedGiB.toFixed(1) + " GiB"
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
                        text: "BOŞ"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        text: StorageState.rootFreeGiB.toFixed(1) + " GiB"
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
                        text: StorageState.rootTotalGiB.toFixed(1) + " GiB"
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

            // ── FİZİKSEL SÜRÜCÜ LİSTESİ ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall
                visible: StorageState.drives.length > 0

                Repeater {
                    model: StorageState.drives

                    delegate: ColumnLayout {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSmall

                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: Theme.radiusButton
                                color: Theme.surfaceActive
                                border.color: Theme.borderSubtle
                                border.width: Theme.borderWidth

                                Text {
                                    anchors.centerIn: parent
                                    text: StorageState.driveTypeIcon(modelData.driveType)
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
                                }
                            }

                            Text {
                                text: modelData.name
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: StorageState.formatCapacity(modelData.size)
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.media + (modelData.fileSystems.length > 0 ? (" · " + modelData.fileSystems) : "") + " · " + modelData.state + (modelData.percent >= 0 ? (" · " + modelData.percent + "%") : "")
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: modelData.freeBytes >= 0
                                text: StorageState.formatFree(modelData.freeBytes)
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        // Sürücüler arası ince ayırıcı çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: Theme.borderSubtle
                            visible: index < StorageState.drives.length - 1
                        }
                    }
                }
            }

            // Boş durum
            Text {
                Layout.fillWidth: true
                visible: StorageState.drives.length === 0
                horizontalAlignment: Text.AlignHCenter
                text: "Sürücü bilgisi okunuyor..."
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: 10
            }
        }
    }
}
