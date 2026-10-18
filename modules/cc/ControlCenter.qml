import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-cc"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: SystemState.isControlCenterOpen ? 42 : 20
        right: 12
    }

    implicitWidth: 320
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

        opacity: SystemState.isControlCenterOpen ? 1.0 : 0.0

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
            spacing: Theme.spacingMedium

            // Üst Bölüm: Kullanıcı & Oturum Bilgisi
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: 18
                    color: Theme.surfaceActive
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 16
                    }
                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Enyxma"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        font.bold: true
                    }

                    Text {
                        text: TimeState.formattedDate + " • " + TimeState.formattedTime
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                EnyxmaPill {
                    implicitHeight: 26
                    implicitWidth: 26
                    onClicked: SystemState.closeControlCenter()

                    Text {
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // Orta Bölüm: Hızlı Aç/Kapat Kartları (Ağ ve Bluetooth)
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                // Ağ Kartı
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: Theme.radiusWidget
                    color: SystemState.isConnected ? Theme.surfaceActive : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            NetworkState.open()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: SystemState.isConnected ? "󰤨" : "󰤭"
                            color: SystemState.isConnected ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Ağ"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: SystemState.isConnected ? (SystemState.wifiSSID || "Bağlı") : "Bağlı Değil"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Bluetooth Kartı
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: Theme.radiusWidget
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰂯"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Bluetooth"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: "Hazır"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            // Alt Bölüm: Ses ve Parlaklık Slider Kartı
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: sliderCol.implicitHeight + Theme.spacingMedium * 2
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                ColumnLayout {
                    id: sliderCol
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: Theme.spacingMedium
                    }
                    spacing: Theme.spacingMedium

                    // Ses Kaydırıcısı
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: AudioState.muted ? "󰝟 Ses" : "󰕾 Ses"
                                color: AudioState.muted ? Theme.danger : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: AudioState.muted ? "Sessiz" : Math.round(AudioState.volume * 100) + "%"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        Slider {
                            id: volumeSlider
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: AudioState.muted ? 0.0 : AudioState.volume

                            // Gotcha #7: Sürükleme anında animasyonu devre dışı bırak
                            Behavior on value {
                                enabled: !volumeSlider.pressed && !Theme.reduceMotion
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutQuint
                                }
                            }

                            onMoved: AudioState.setVolume(value)

                            background: Rectangle {
                                x: volumeSlider.leftPadding
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: volumeSlider.availableWidth
                                height: implicitHeight
                                radius: height / 2
                                color: Theme.surfaceActive

                                Rectangle {
                                    width: volumeSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: AudioState.muted ? Theme.danger : Theme.accent
                                    radius: height / 2
                                }
                            }

                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: width / 2
                                color: Theme.textPrimary
                            }
                        }
                    }

                    // Parlaklık Kaydırıcısı (Mockup Slider)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "󰃠 Parlaklık"
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Math.round(brightSlider.value * 100) + "%"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        Slider {
                            id: brightSlider
                            Layout.fillWidth: true
                            from: 0.05
                            to: 1.0
                            value: 0.85

                            // Gotcha #7: Sürükleme anında animasyonu devre dışı bırak
                            Behavior on value {
                                enabled: !brightSlider.pressed && !Theme.reduceMotion
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutQuint
                                }
                            }

                            background: Rectangle {
                                x: brightSlider.leftPadding
                                y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: brightSlider.availableWidth
                                height: implicitHeight
                                radius: height / 2
                                color: Theme.surfaceActive

                                Rectangle {
                                    width: brightSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.accent
                                    radius: height / 2
                                }
                            }

                            handle: Rectangle {
                                x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                                y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: width / 2
                                color: Theme.textPrimary
                            }
                        }
                    }
                }
            }

        }
    }
}
