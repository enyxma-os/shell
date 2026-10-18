import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: overlayRect.opacity > 0.0

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: OverviewState.isOpen

        Keys.onEscapePressed: OverviewState.close()
    }

    Rectangle {
        id: overlayRect
        anchors.fill: parent
        color: Theme.bgGlass
        opacity: OverviewState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        // Dışarıya tıklayınca kapat
        MouseArea {
            anchors.fill: parent
            onClicked: OverviewState.close()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacingLarge
            width: Math.min(parent.width - 80, 1100)

            // ── BAŞLIK BÖLÜMÜ ──
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacingMedium

                Text {
                    text: "✦"
                    color: Theme.accent
                    font.pixelSize: Theme.fontSizeLarge + 4
                }

                Text {
                    text: "GENEL BAKIŞ"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    font.letterSpacing: 3
                }

                Text {
                    text: "• " + OverviewState.clients.length + " Açık Pencere"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                }
            }

            // Pencereler Akışı (Flow Grid)
            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacingMedium
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: OverviewState.clients

                    delegate: Rectangle {
                        id: clientCard
                        required property var modelData
                        required property int index

                        width: 250
                        height: 150
                        radius: Theme.radiusPanel
                        color: cardMa.containsMouse ? Theme.surfaceHover : Theme.bgGlass
                        border.color: cardMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: cardMa.containsMouse ? 2 : Theme.borderWidth

                        scale: cardMa.containsMouse ? 1.04 : 1.0

                        Behavior on scale {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: Theme.animFast
                                easing.type: Easing.OutQuint
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: Theme.animFast }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingMedium
                            spacing: Theme.spacingSmall

                            // Üst Etiket: Workspace Rozeti
                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    implicitHeight: 20
                                    implicitWidth: wsText.implicitWidth + 12
                                    radius: Theme.radiusSmall
                                    color: Theme.surfaceActive
                                    border.color: Theme.borderSubtle
                                    border.width: Theme.borderWidth

                                    Text {
                                        id: wsText
                                        anchors.centerIn: parent
                                        text: "Alan " + (clientCard.modelData.workspace ? clientCard.modelData.workspace.id : "?")
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: clientCard.modelData.floating ? "Yüzer" : "Döşeli"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Uygulama Sınıfı (Class)
                            Text {
                                text: clientCard.modelData["class"] || "Uygulama"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Pencere Başlığı (Title)
                            Text {
                                text: clientCard.modelData.title || ""
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: cardMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: OverviewState.focusClient(clientCard.modelData.address)
                        }
                    }
                }
            }

            // Boş Durum
            Item {
                Layout.fillWidth: true
                implicitHeight: 120
                visible: OverviewState.clients.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "✦"
                        color: Theme.accent
                        font.pixelSize: 28
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Açık pencere bulunamadı"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }
            }
        }
    }
}
