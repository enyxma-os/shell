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
        color: Theme.scrim
        opacity: OverviewState.isOpen ? 0.92 : 0.0

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

        // ── SOL ÜST: MARKA & GENEL BAKIŞ BAŞLIĞI ──
        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 36
            anchors.topMargin: 24
            spacing: Theme.spacingMedium
            z: 10

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

        // ── ORTA ÜST: DESKTOP STRIP (TAM ORTALANMIŞ) ──
        DesktopStrip {
            id: deskStrip
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            z: 10
        }

        // ── SAĞ ÜST: AÇIK PENCERE SAYACI ──
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 36
            anchors.topMargin: 28
            implicitHeight: 28
            implicitWidth: countText.implicitWidth + 20
            radius: Theme.radiusSmall
            color: Theme.surface1
            border.color: Theme.borderSubtle
            border.width: Theme.borderWidth
            z: 10

            Text {
                id: countText
                anchors.centerIn: parent
                text: OverviewState.clients.length + " Açık Pencere"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: 11
            }
        }

        // ── ORTA BÖLÜM: ÇALIŞMA ALANLARI VE MİNİ MASAÜSTÜ KARTLARI ──
        Item {
            id: centerArea
            anchors.top: parent.top
            anchors.topMargin: 90
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            anchors.left: parent.left
            anchors.right: parent.right

            Flickable {
                id: wsFlickable
                anchors.fill: parent
                contentWidth: wsRow.implicitWidth + 80
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: wsRow
                    x: Math.max(40, (wsFlickable.width - implicitWidth) / 2)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingMedium

                    Repeater {
                        model: OverviewState.workspaces

                        delegate: Rectangle {
                            id: wsCard
                            required property var modelData
                            required property int index

                            readonly property bool isViewed: OverviewState.viewedWorkspaceId === wsCard.modelData.id
                            readonly property bool isActive: OverviewState.activeWorkspaceId === wsCard.modelData.id
                            readonly property var wsClients: OverviewState.clientsForWorkspace(wsCard.modelData.id)

                            width: 360
                            height: 230
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
                                anchors.margins: Theme.spacingSmall
                                spacing: Theme.spacingXS

                                // Kart Başlığı: Çalışma Alanı Numarası ve Durumu
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 26

                                    Rectangle {
                                        implicitHeight: 20
                                        implicitWidth: 30
                                        radius: Theme.radiusSmall
                                        color: wsCard.isViewed ? Theme.accent : Theme.surfaceActive

                                        Text {
                                            anchors.centerIn: parent
                                            text: ("0" + wsCard.modelData.id).slice(-2)
                                            color: wsCard.isViewed ? Theme.bgDark : Theme.textPrimary
                                            font.family: Theme.fontMono
                                            font.pixelSize: 10
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
                                            spacing: Theme.spacingXS

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: "+"
                                                color: Theme.textMuted
                                                font.pixelSize: 28
                                            }

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: "Boş Masaüstü"
                                                color: Theme.textMuted
                                                font.family: Theme.fontMono
                                                font.pixelSize: 10
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: OverviewState.switchWorkspace(wsCard.modelData.id)
                                        }
                                    }

                                    // Dolu Çalışma Alanı Pencereleri (RowLayout ile taşmayan yapı)
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: Theme.spacingXS
                                        visible: wsCard.wsClients.length > 0

                                        Repeater {
                                            model: wsCard.wsClients

                                            delegate: Rectangle {
                                                id: winItem
                                                required property var modelData
                                                required property int index

                                                readonly property int globalIndex: OverviewState.clients.indexOf(winItem.modelData)
                                                readonly property bool isSelected: OverviewState.selectedIndex === winItem.globalIndex

                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                radius: Theme.radiusWidget

                                                color: (winMa.containsMouse || winItem.isSelected) ? Theme.surfaceHover : Theme.surfaceActive
                                                border.width: winItem.isSelected ? 2 : Theme.borderWidth
                                                border.color: winItem.isSelected ? Theme.accent : (winMa.containsMouse ? Theme.borderFocus : Theme.borderSubtle)

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: Theme.spacingXS
                                                    spacing: 2

                                                    // Pencere Üst Barı: Sınıf ve Kapatma Butonu (✕)
                                                    RowLayout {
                                                        Layout.fillWidth: true

                                                        Text {
                                                            text: winItem.modelData["class"] || "Pencere"
                                                            color: Theme.textPrimary
                                                            font.family: Theme.fontFamily
                                                            font.pixelSize: 10
                                                            font.bold: true
                                                            Layout.fillWidth: true
                                                            elide: Text.ElideRight
                                                        }

                                                        // Kapat Butonu
                                                        Rectangle {
                                                            implicitWidth: 16
                                                            implicitHeight: 16
                                                            radius: 8
                                                            color: closeMa.containsMouse ? Theme.danger : "transparent"

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: "✕"
                                                                color: closeMa.containsMouse ? Theme.textPrimary : Theme.textMuted
                                                                font.pixelSize: 9
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
                        width: 180
                        height: 230
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
                            spacing: Theme.spacingSmall

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "+"
                                color: newWsMa.containsMouse ? Theme.accent : Theme.textSecondary
                                font.pixelSize: 36
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "YENİ MASAÜSTÜ"
                                color: newWsMa.containsMouse ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
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

        // ── ALT LEJANT / KISAYOL İPUCU BARI (TAM ORTALANMIŞ) ──
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            text: "KAYDIR / TAB  DÖNGÜ      ALT+TAB  MASAÜSTÜ      ✕  KAPAT      ENTER  GİT      ESC  KAPAT"
            color: Theme.textSecondary
            font.family: Theme.fontMono
            font.pixelSize: 10
            font.letterSpacing: 2
            opacity: 0.85
        }
    }
}
