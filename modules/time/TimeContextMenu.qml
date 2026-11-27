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

    WlrLayershell.namespace: "enyxma-time-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: menuCard.opacity > 0.0

    // Dışarı tıklandığında kapat (Scrim)
    MouseArea {
        anchors.fill: parent
        onClicked: TimeState.isMenuOpen = false
    }

    Rectangle {
        id: menuCard
        width: 250
        implicitHeight: contentColumn.implicitHeight + 24

        anchors.top: parent.top
        anchors.topMargin: 44
        anchors.horizontalCenter: parent.horizontalCenter

        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: TimeState.isMenuOpen ? 1.0 : 0.0
        scale: TimeState.isMenuOpen ? 1.0 : 0.94

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            // Menü içi tıklamaların scrim'e düşmesini engelle
            preventStealing: true
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
            }
            spacing: 8

            // Başlık
            Text {
                text: I18n.t("HIZLI AYARLAR & FORMAT", "QUICK SETTINGS & FORMAT")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.borderSubtle
            }

            // 1. 24 Saat / 12 Saat Seçimi
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: Theme.radiusSmall
                color: h24Ma.containsMouse ? Theme.surfaceHover : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: I18n.t("24 Saat Biçimi", "24-Hour Format")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: TimeState.use24h ? Theme.accent : Theme.surface1
                        border.color: TimeState.use24h ? Theme.accent : Theme.borderSubtle

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Theme.bgGlass
                            font.pixelSize: 11
                            font.bold: true
                            visible: TimeState.use24h
                        }
                    }
                }

                MouseArea {
                    id: h24Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: TimeState.toggle24h()
                }
            }

            // 2. Saniyeleri Göster
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: Theme.radiusSmall
                color: secMa.containsMouse ? Theme.surfaceHover : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: I18n.t("Saniyeleri Göster", "Show Seconds")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: TimeState.showSeconds ? Theme.accent : Theme.surface1
                        border.color: TimeState.showSeconds ? Theme.accent : Theme.borderSubtle

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Theme.bgGlass
                            font.pixelSize: 11
                            font.bold: true
                            visible: TimeState.showSeconds
                        }
                    }
                }

                MouseArea {
                    id: secMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: TimeState.toggleSeconds()
                }
            }

            // 3. Sıcaklık Birimi (°C / °F)
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: Theme.radiusSmall
                color: unitMa.containsMouse ? Theme.surfaceHover : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: I18n.t("Sıcaklık Birimi", "Temperature Unit")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }

                    Text {
                        text: WeatherState.useCelsius ? "°C" : "°F"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                MouseArea {
                    id: unitMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WeatherState.toggleUnit()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.borderSubtle
            }

            // 4. Hızlı Pomodoro / Odak Sayacı
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: Theme.radiusSmall
                color: Theme.surface1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: I18n.t("⏱️ Odak:", "⏱️ Focus:")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    Text {
                        text: TimeState.pomodoroDisplay
                        color: TimeState.pomodoroActive ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 50
                        height: 22
                        radius: 4
                        color: TimeState.pomodoroActive ? Theme.danger : Theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: TimeState.pomodoroActive ? I18n.t("Durdur", "Stop") : I18n.t("Başlat", "Start")
                            color: Theme.bgGlass
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: TimeState.togglePomodoro()
                        }
                    }
                }
            }

            // 5. Hava Durumunu Güncelle
            Rectangle {
                Layout.fillWidth: true
                height: 30
                radius: Theme.radiusSmall
                color: refreshMa.containsMouse ? Theme.surfaceHover : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "🔄"
                        font.pixelSize: 11
                    }

                    Text {
                        text: I18n.t("Hava Durumunu Güncelle", "Refresh Weather")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: refreshMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        WeatherState.fetchWeather();
                        TimeState.isMenuOpen = false;
                    }
                }
            }
        }
    }
}
