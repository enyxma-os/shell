import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * DynamicAudioPanel — Enyxma Dinamik Ses Karistirici Paneli.
 */
Item {
    id: root

    component DynamicSlider: Item {
        id: sl
        property real value: 0.0
        property bool muted: false
        property real maxValue: 1.0
        signal moved(real newValue)

        implicitHeight: 18

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: 6
            radius: 3
            color: Theme.surface2

            Rectangle {
                height: parent.height
                radius: 3
                color: sl.muted ? Theme.danger : Theme.accent
                width: Math.max(0, Math.min(parent.width, parent.width * (sl.value / sl.maxValue)))
            }
        }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * (sl.value / sl.maxValue)))
            color: sl.muted ? Theme.danger : Theme.textPrimary
            border.color: Theme.bgDark
            border.width: 2
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            function updateFromX(mx) {
                var ratio = Math.max(0.0, Math.min(1.0, mx / Math.max(1, width)))
                sl.moved(ratio * sl.maxValue)
            }
            onPressed: (mouse) => updateFromX(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) updateFromX(mouse.x) }
        }
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + Theme.barMarginTop + 8
        anchors.rightMargin: 12
        width: 396
        height: Math.min(parent.height - Theme.barHeight - 28, 540)
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
                spacing: 8

                Text {
                    text: "󰓃"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 16
                }

                Text {
                    text: "Ses Karıştırıcı"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "✕"; color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary; font.pixelSize: 11 }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: AudioState.close() }
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

        RowLayout {
            id: tabBar
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: 32
            spacing: 6

            Repeater {
                model: [
                    { key: "devices", label: "Cihazlar" },
                    { key: "apps",    label: "Uygulamalar · " + AudioState.streams.length }
                ]
                delegate: Rectangle {
                    id: tabBtn
                    required property var modelData
                    readonly property bool active: AudioState.activeTab === modelData.key
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusButton
                    color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: active ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: tabBtn.modelData.label
                        color: tabBtn.active ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: tabBtn.active
                    }

                    MouseArea {
                        id: tabMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioState.activeTab = tabBtn.modelData.key
                    }
                }
            }
        }

        Item {
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            clip: true

            Flickable {
                anchors.fill: parent
                visible: AudioState.activeTab === "devices"
                contentHeight: devicesCol.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: devicesCol
                    width: parent.width
                    spacing: 10

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    implicitWidth: 26
                                    implicitHeight: 24
                                    radius: Theme.radiusSmall
                                    color: AudioState.muted ? Theme.danger : Theme.surface2

                                    Text {
                                        anchors.centerIn: parent
                                        text: AudioState.muted ? "󰝟" : "󰕾"
                                        color: AudioState.muted ? Theme.accentOn : Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                    }

                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: AudioState.toggleMute() }
                                }

                                Text {
                                    text: AudioState.sinkName
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: AudioState.muted ? "Sessiz" : (Math.round(AudioState.volume * 100) + "%")
                                    color: AudioState.muted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            DynamicSlider {
                                Layout.fillWidth: true
                                value: AudioState.volume
                                muted: AudioState.muted
                                onMoved: (v) => AudioState.setVolume(v)
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    implicitWidth: 26
                                    implicitHeight: 24
                                    radius: Theme.radiusSmall
                                    color: AudioState.micMuted ? Theme.danger : Theme.surface2

                                    Text {
                                        anchors.centerIn: parent
                                        text: AudioState.micMuted ? "󰍭" : "󰍬"
                                        color: AudioState.micMuted ? Theme.accentOn : Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                    }

                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: AudioState.toggleMicMute() }
                                }

                                Text {
                                    text: AudioState.sourceName
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: AudioState.micMuted ? "Sessiz" : (Math.round(AudioState.micVolume * 100) + "%")
                                    color: AudioState.micMuted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            DynamicSlider {
                                Layout.fillWidth: true
                                value: AudioState.micVolume
                                muted: AudioState.micMuted
                                onMoved: (v) => AudioState.setMicVolume(v)
                            }
                        }
                    }

                    Text {
                        text: "Çıkış Cihazları"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Repeater {
                        model: AudioState.sinks
                        delegate: Rectangle {
                            id: sinkRow
                            required property var modelData
                            width: devicesCol.width
                            height: 38
                            radius: Theme.radiusButton
                            color: modelData.isDefault ? Theme.surfaceActive : (sinkMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.isDefault ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: sinkRow.modelData.isDefault ? "●" : "○"
                                    color: sinkRow.modelData.isDefault ? Theme.accent : Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: sinkRow.modelData.name
                                    color: sinkRow.modelData.isDefault ? Theme.textPrimary : Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: sinkRow.modelData.isDefault
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: Math.round(sinkRow.modelData.volume * 100) + "%"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: sinkMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioState.setDefaultNode(sinkRow.modelData.id)
                            }
                        }
                    }

                    Text {
                        text: "Giriş Cihazları"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Repeater {
                        model: AudioState.sources
                        delegate: Rectangle {
                            id: srcRow
                            required property var modelData
                            width: devicesCol.width
                            height: 38
                            radius: Theme.radiusButton
                            color: modelData.isDefault ? Theme.surfaceActive : (srcMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.isDefault ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: srcRow.modelData.isDefault ? "●" : "○"
                                    color: srcRow.modelData.isDefault ? Theme.accent : Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: srcRow.modelData.name
                                    color: srcRow.modelData.isDefault ? Theme.textPrimary : Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: srcRow.modelData.isDefault
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: Math.round(srcRow.modelData.volume * 100) + "%"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: srcMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioState.setDefaultNode(srcRow.modelData.id)
                            }
                        }
                    }
                }
            }

            Item {
                anchors.fill: parent
                visible: AudioState.activeTab === "apps"

                ListView {
                    anchors.fill: parent
                    clip: true
                    spacing: 8
                    boundsBehavior: Flickable.StopAtBounds
                    model: AudioState.streams

                    delegate: Rectangle {
                        id: streamRow
                        required property var modelData
                        width: ListView.view.width
                        height: 70
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    implicitWidth: 26
                                    implicitHeight: 24
                                    radius: Theme.radiusSmall
                                    color: streamRow.modelData.muted ? Theme.danger : Theme.surface2

                                    Text {
                                        anchors.centerIn: parent
                                        text: streamRow.modelData.muted ? "󰝟" : "󰕾"
                                        color: streamRow.modelData.muted ? Theme.accentOn : Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: AudioState.toggleNodeMute(streamRow.modelData.id)
                                    }
                                }

                                Text {
                                    text: streamRow.modelData.name
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: streamRow.modelData.muted ? "Sessiz" : (Math.round(streamRow.modelData.volume * 100) + "%")
                                    color: streamRow.modelData.muted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            DynamicSlider {
                                Layout.fillWidth: true
                                value: streamRow.modelData.volume
                                muted: streamRow.modelData.muted
                                onMoved: (v) => AudioState.setNodeVolume(streamRow.modelData.id, v)
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: AudioState.streams.length === 0
                        text: "Aktif ses akışı yok"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}

