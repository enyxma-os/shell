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

    WlrLayershell.namespace: "enyxma-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: NotificationState.isPanelOpen ? 42 : 20
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

        opacity: NotificationState.isPanelOpen ? 1.0 : 0.0

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

            // ── BAŞLIK BÖLÜMÜ (BİLDİRİMLER, TEMİZLE, KAPAT) ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "BİLDİRİMLER"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 2
                }

                Text {
                    visible: NotificationState.notifications.length > 0
                    text: " · " + NotificationState.notifications.length
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                // Tümünü Temizle Butonu
                EnyxmaPill {
                    implicitHeight: 22
                    visible: NotificationState.notifications.length > 0
                    onClicked: NotificationState.clearAll()

                    Text {
                        text: "Temizle"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                // Kapat Butonu (✕)
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
                        onClicked: NotificationState.close()
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── BOŞ DURUM (BİLDİRİM YOK) ──
            ColumnLayout {
                Layout.fillWidth: true
                implicitHeight: 70
                visible: NotificationState.notifications.length === 0
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰂚"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 22
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Yeni bildirim yok"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            // ── BİLDİRİM LİSTESİ (KAYDIRILABİLİR) ──
            Flickable {
                Layout.fillWidth: true
                implicitHeight: Math.min(360, listCol.implicitHeight)
                contentHeight: listCol.implicitHeight
                clip: true
                interactive: listCol.implicitHeight > 360
                boundsBehavior: Flickable.StopAtBounds
                visible: NotificationState.notifications.length > 0

                ColumnLayout {
                    id: listCol
                    width: parent.width
                    spacing: Theme.spacingXS

                    Repeater {
                        model: NotificationState.notifications

                        delegate: Rectangle {
                            id: notifDelegate
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitHeight: notifCardCol.implicitHeight + Theme.spacingSmall * 2
                            radius: Theme.radiusWidget
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: Theme.borderWidth

                            ColumnLayout {
                                id: notifCardCol
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: Theme.spacingSmall
                                }
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.spacingSmall

                                    Text {
                                        text: notifDelegate.modelData.appName
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: notifDelegate.modelData.time
                                        color: Theme.textMuted
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        implicitHeight: 18
                                        implicitWidth: 18
                                        radius: 9
                                        color: itemCloseMa.containsMouse ? Theme.surfaceHover : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            color: itemCloseMa.containsMouse ? Theme.danger : Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            id: itemCloseMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: NotificationState.dismissNotification(notifDelegate.modelData.id)
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notifDelegate.modelData.summary
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notifDelegate.modelData.body
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    visible: text.length > 0
                                }

                                // Aksiyon Butonları (Varsa)
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: notifDelegate.modelData.actions && notifDelegate.modelData.actions.length > 0

                                    Repeater {
                                        model: notifDelegate.modelData.actions || []

                                        delegate: EnyxmaPill {
                                            id: actionDelegate
                                            required property var modelData
                                            implicitHeight: 20

                                            onClicked: NotificationState.invokeAction(notifDelegate.modelData.id, actionDelegate.modelData.identifier)

                                            Text {
                                                text: actionDelegate.modelData.text
                                                color: Theme.accent
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
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
    }
}
