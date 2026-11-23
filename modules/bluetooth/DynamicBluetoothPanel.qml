import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * DynamicBluetoothPanel — Enyxma Dinamik Bluetooth Yonetim Paneli.
 */
Item {
    id: root

    function deviceGlyph(iconName) {
        var s = String(iconName || "").toLowerCase()
        if (s.indexOf("audio") >= 0 || s.indexOf("head") >= 0) return "󰋋"
        if (s.indexOf("keyboard") >= 0) return "󰌌"
        if (s.indexOf("mouse") >= 0) return "󰍽"
        if (s.indexOf("phone") >= 0) return "󰏲"
        return "󰂯"
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + Theme.barMarginTop + 8
        anchors.rightMargin: 12
        width: 380
        height: Math.min(parent.height - Theme.barHeight - 28, 520)
        color: Theme.bgPanel
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Item {
            id: headerArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 14
                spacing: 6

                Text {
                    text: "󰂯"
                    color: BluetoothState.enabled ? Theme.accent : Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 16
                }

                Text {
                    text: "Bluetooth"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: BluetoothState.supported
                    implicitWidth: pwrTxt.implicitWidth + 14
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: BluetoothState.enabled ? Theme.surfaceActive : Theme.surface1
                    border.color: BluetoothState.enabled ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        id: pwrTxt
                        anchors.centerIn: parent
                        text: BluetoothState.enabled ? "Açık" : "Kapalı"
                        color: BluetoothState.enabled ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothState.togglePower()
                    }
                }

                Rectangle {
                    visible: BluetoothState.enabled
                    implicitWidth: 28
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: scanMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: BluetoothState.isScanning ? "…" : "↻"
                        color: BluetoothState.isScanning ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: scanMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothState.startScan()
                    }
                }

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "✕"; color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary; font.pixelSize: 11 }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: BluetoothState.close() }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.borderSubtle
            }
        }

        Rectangle {
            id: errBanner
            visible: BluetoothState.lastError !== ""
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: 28
            radius: Theme.radiusSmall
            color: Theme.surface1
            border.color: Theme.danger
            border.width: 1

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                text: BluetoothState.lastError
                color: Theme.danger
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Item {
            anchors.top: errBanner.visible ? errBanner.bottom : headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            clip: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 110
                visible: !BluetoothState.supported || !BluetoothState.enabled
                radius: Theme.radiusButton
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: !BluetoothState.supported ? "BlueZ aracı bulunamadı" : "Bluetooth adaptörü kapalı"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Rectangle {
                        visible: BluetoothState.supported && !BluetoothState.enabled
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: 120
                        implicitHeight: 30
                        radius: Theme.radiusButton
                        color: Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Bluetooth'u Aç"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BluetoothState.togglePower()
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                visible: BluetoothState.supported && BluetoothState.enabled
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: BluetoothState.devices

                delegate: Rectangle {
                    id: devRow
                    required property var modelData
                    readonly property bool isBusy: BluetoothState.busyMac === modelData.mac
                    width: ListView.view.width
                    height: 54
                    radius: Theme.radiusButton
                    color: modelData.connected ? Theme.surfaceActive : Theme.surface1
                    border.color: modelData.connected ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: root.deviceGlyph(devRow.modelData.icon)
                            color: devRow.modelData.connected ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                width: parent.width
                                text: devRow.modelData.name
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: devRow.modelData.connected
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: {
                                    var st = devRow.modelData.connected ? "Bağlı" : (devRow.modelData.paired ? "Eşleştirilmiş" : "Bulunan")
                                    if (devRow.modelData.battery >= 0) st += " · Pil %" + devRow.modelData.battery
                                    return st
                                }
                                color: devRow.modelData.connected ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            implicitWidth: actTxt.implicitWidth + 16
                            implicitHeight: 26
                            radius: Theme.radiusSmall
                            color: actMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                            border.color: devRow.modelData.connected ? Theme.borderSubtle : Theme.accent
                            border.width: 1

                            Text {
                                id: actTxt
                                anchors.centerIn: parent
                                text: devRow.isBusy ? "…" : (devRow.modelData.connected ? "Ayır" : (devRow.modelData.paired ? "Bağlan" : "Eşle"))
                                color: devRow.modelData.connected ? Theme.textPrimary : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: actMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (devRow.modelData.connected) BluetoothState.disconnectDevice(devRow.modelData.mac)
                                    else if (devRow.modelData.paired) BluetoothState.connectDevice(devRow.modelData.mac)
                                    else BluetoothState.pairDevice(devRow.modelData.mac)
                                }
                            }
                        }

                        Rectangle {
                            visible: devRow.modelData.paired
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: Theme.radiusSmall
                            color: remMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                            border.color: remMa.containsMouse ? Theme.danger : Theme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰆴"
                                color: remMa.containsMouse ? Theme.danger : Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: remMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: BluetoothState.removeDevice(devRow.modelData.mac)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: BluetoothState.devices.length === 0
                    text: BluetoothState.isScanning ? "Cihazlar taranıyor..." : "Kayıtlı veya yakında cihaz yok"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }
}

