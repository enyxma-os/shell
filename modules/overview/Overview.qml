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
    WlrLayershell.keyboardFocus: OverviewState.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
        Keys.onTabPressed: (event) => {
            if (event.modifiers & Qt.AltModifier) {
                OverviewState.cycleWorkspace(1)
            } else if (event.modifiers & Qt.ShiftModifier) {
                OverviewState.prev()
            } else {
                OverviewState.next()
            }
        }
        Keys.onBacktabPressed: OverviewState.prev()
        Keys.onReturnPressed: OverviewState.activateSelected()
        Keys.onEnterPressed: OverviewState.activateSelected()
        Keys.onDeletePressed: OverviewState.closeSelected()
        Keys.onLeftPressed: OverviewState.prev()
        Keys.onRightPressed: OverviewState.next()
        Keys.onUpPressed: OverviewState.cycleWorkspace(-1)
        Keys.onDownPressed: OverviewState.cycleWorkspace(1)
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

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                if (event.angleDelta.y < 0) {
                    OverviewState.next()
                } else if (event.angleDelta.y > 0) {
                    OverviewState.prev()
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: Theme.spacingLarge

            // ── ÜST BAR: SOLDA BAŞLIK, ORTADA DESKTOP STRIP, SAĞDA SAYAÇ ──
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                // Sol: Brand Mark & Genel Bakış Başlığı
                RowLayout {
                    spacing: Theme.spacingMedium

                    Text {
                        text: "✦"
                        color: Theme.accent
                        font.pixelSize: Theme.fontSizeLarge + 6
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "GENEL BAKIŞ"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: true
                            font.letterSpacing: 3
                        }

                        Text {
                            text: "MASAÜSTÜ " + ("0" + OverviewState.viewedWorkspaceId).slice(-2)
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.letterSpacing: 2
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Orta: Desktop Strip (Çalışma Alanları Seçici)
                DesktopStrip {
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillWidth: true }

                // Sağ: Pencere Sayacı Rozeti
                Rectangle {
                    implicitHeight: 28
                    implicitWidth: countText.implicitWidth + 20
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: OverviewState.clients.length + " Açık Pencere"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                }
            }

            // ── ORTA BÖLÜM: ÇALIŞMA ALANLARI VE MİNİ MASAÜSTÜ KARTLARI ──
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    id: wsFlickable
                    anchors.centerIn: parent
                    width: Math.min(parent.width, wsRow.implicitWidth)
                    height: Math.min(parent.height - 20, 360)
                    contentWidth: wsRow.implicitWidth
                    contentHeight: wsRow.implicitHeight
                    clip: true

                    Row {
                        id: wsRow
                        spacing: Theme.spacingLarge
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: OverviewState.workspaces

                            delegate: Rectangle {
                                id: wsCard
                                required property var modelData
                                required property int index

                                readonly property bool isViewed: OverviewState.viewedWorkspaceId === wsCard.modelData.id
                                readonly property bool isActive: OverviewState.activeWorkspaceId === wsCard.modelData.id
                                readonly property var wsClients: OverviewState.clientsForWorkspace(wsCard.modelData.id)

                                width: 440
                                height: 280
                                radius: Theme.radiusPanel

                                color: wsCard.isViewed ? Theme.surface2 : Theme.surface1
                                border.width: wsCard.isViewed ? 2 : Theme.borderWidth
                                border.color: wsCard.isViewed ? Theme.accent : Theme.borderSubtle

                                scale: wsCard.isViewed ? 1.02 : 1.0

                                Behavior on scale {
                                    enabled: !Theme.reduceMotion
                                    NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: Theme.animFast }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingMedium
                                    spacing: Theme.spacingSmall

                                    // Kart Başlığı: Çalışma Alanı Numarası ve Durumu
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Rectangle {
                                            implicitHeight: 22
                                            implicitWidth: 32
                                            radius: Theme.radiusSmall
                                            color: wsCard.isViewed ? Theme.accent : Theme.surfaceActive

                                            Text {
                                                anchors.centerIn: parent
                                                text: ("0" + wsCard.modelData.id).slice(-2)
                                                color: wsCard.isViewed ? Theme.bgDark : Theme.textPrimary
                                                font.family: Theme.fontMono
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: wsCard.isActive ? "Aktif" : (wsCard.wsClients.length + " Pencere")
                                            color: wsCard.isActive ? Theme.accent : Theme.textMuted
                                            font.family: Theme.fontMono
                                            font.pixelSize: 10
                                        }
                                    }

                                    // Çalışma Alanı İçi: Pencereler Izgarası
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        // Boş Çalışma Alanı Görünümü
                                        Item {
                                            anchors.fill: parent
                                            visible: wsCard.wsClients.length === 0

                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: Theme.spacingSmall

                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: "+"
                                                    color: Theme.textMuted
                                                    font.pixelSize: 32
                                                }

                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: "Boş Masaüstü"
                                                    color: Theme.textMuted
                                                    font.family: Theme.fontMono
                                                    font.pixelSize: 11
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: OverviewState.switchWorkspace(wsCard.modelData.id)
                                            }
                                        }

                                        // Dolu Çalışma Alanı Pencereleri (Grid)
                                        Flow {
                                            anchors.fill: parent
                                            spacing: Theme.spacingSmall
                                            visible: wsCard.wsClients.length > 0

                                            Repeater {
                                                model: wsCard.wsClients

                                                delegate: Rectangle {
                                                    id: winItem
                                                    required property var modelData
                                                    required property int index

                                                    readonly property int globalIndex: OverviewState.clients.indexOf(winItem.modelData)
                                                    readonly property bool isSelected: OverviewState.selectedIndex === winItem.globalIndex

                                                    width: wsCard.wsClients.length === 1 ? parent.width : (parent.width - Theme.spacingSmall) / 2
                                                    height: wsCard.wsClients.length <= 2 ? parent.height : (parent.height - Theme.spacingSmall) / 2
                                                    radius: Theme.radiusWidget

                                                    color: (winMa.containsMouse || winItem.isSelected) ? Theme.surfaceHover : Theme.surfaceActive
                                                    border.width: winItem.isSelected ? 2 : Theme.borderWidth
                                                    border.color: winItem.isSelected ? Theme.accent : (winMa.containsMouse ? Theme.borderFocus : Theme.borderSubtle)

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: Theme.spacingSmall
                                                        spacing: 2

                                                        // Pencere Üst Barı: Sınıf ve Kapatma Butonu (✕)
                                                        RowLayout {
                                                            Layout.fillWidth: true

                                                            Text {
                                                                text: winItem.modelData["class"] || "Pencere"
                                                                color: Theme.textPrimary
                                                                font.family: Theme.fontFamily
                                                                font.pixelSize: 11
                                                                font.bold: true
                                                                Layout.fillWidth: true
                                                                elide: Text.ElideRight
                                                            }

                                                            // Kapat Butonu
                                                            Rectangle {
                                                                implicitWidth: 18
                                                                implicitHeight: 18
                                                                radius: 9
                                                                color: closeMa.containsMouse ? Theme.danger : "transparent"

                                                                Text {
                                                                    anchors.centerIn: parent
                                                                    text: "✕"
                                                                    color: closeMa.containsMouse ? Theme.textPrimary : Theme.textMuted
                                                                    font.pixelSize: 10
                                                                }

                                                                MouseArea {
                                                                    id: closeMa
                                                                    anchors.fill: parent
                                                                    hoverEnabled: true
                                                                    cursorShape: Qt.PointingHandCursor
                                                                    onClicked: OverviewState.closeClient(winItem.modelData.address)
                                                                }
                                                            }
                                                        }

                                                        Item { Layout.fillHeight: true }

                                                        // Pencere Başlığı
                                                        Text {
                                                            text: winItem.modelData.title || ""
                                                            color: Theme.textSecondary
                                                            font.family: Theme.fontMono
                                                            font.pixelSize: 9
                                                            Layout.fillWidth: true
                                                            elide: Text.ElideRight
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: winMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: OverviewState.focusClient(winItem.modelData.address)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    onClicked: OverviewState.switchWorkspace(wsCard.modelData.id)
                                }
                            }
                        }

                        // Trailing "YENİ MASAÜSTÜ EKLE" Kartı
                        Rectangle {
                            id: newWsCard
                            width: 220
                            height: 280
                            radius: Theme.radiusPanel

                            color: newWsMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.width: Theme.borderWidth
                            border.color: newWsMa.containsMouse ? Theme.accent : Theme.borderSubtle

                            scale: newWsMa.containsMouse ? 1.02 : 1.0

                            Behavior on scale {
                                enabled: !Theme.reduceMotion
                                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Theme.spacingMedium

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "+"
                                    color: newWsMa.containsMouse ? Theme.accent : Theme.textSecondary
                                    font.pixelSize: 42
                                    font.bold: true
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "YENİ MASAÜSTÜ"
                                    color: newWsMa.containsMouse ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 2
                                }
                            }

                            MouseArea {
                                id: newWsMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: OverviewState.createWorkspace()
                            }
                        }
                    }
                }
            }

            // ── ALT LEJANT / KISAYOL İPUCU BARI ──
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 30

                Text {
                    text: "KAYDIR / TAB  DÖNGÜ      ALT+TAB  MASAÜSTÜ      ✕  KAPAT      ENTER  GİT      ESC  KAPAT"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 2
                    opacity: 0.85
                }
            }
        }
    }
}
