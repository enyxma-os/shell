import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * GothamAudioPanel — Gotham 2.0 Brutalist Ses Karistirici Paneli.
 */
Item {
    id: root

    component GothamSlider: Item {
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
            radius: 0
            color: Theme.surface2
            border.color: Theme.borderSubtle
            border.width: 1

            Rectangle {
                height: parent.height
                radius: 0
                color: sl.muted ? Theme.danger : Theme.accent
                width: Math.max(0, Math.min(parent.width, parent.width * (sl.value / sl.maxValue)))
            }
        }

        Rectangle {
            width: 8
            height: 14
            radius: 0
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * (sl.value / sl.maxValue)))
            color: sl.muted ? Theme.danger : Theme.textPrimary
            border.color: Theme.bgDark
            border.width: 1
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
        anchors.topMargin: Theme.barHeight + 6
        anchors.rightMargin: 12
        width: 396
        height: Math.min(parent.height - Theme.barHeight - 24, 540)
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.accent
            z: 10
        }

        // Baslik
        Item {
            id: headerArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 46

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "󰓃"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 15
                }

                Text {
                    text: I18n.t("SES // KARIŞTIRICI", "AUDIO // MIXER")
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "×"; color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 14 }
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

        // Sekme cubugu
        RowLayout {
            id: tabBar
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: 30
            spacing: 6

            Repeater {
                model: [
                    { key: "devices", label: I18n.t("CİHAZLAR", "DEVICES") },
                    { key: "apps",    label: "UYGULAMALAR · " + AudioState.streams.length }
                ]
                delegate: Rectangle {
                    id: tabBtn
                    required property var modelData
                    readonly property bool active: AudioState.activeTab === modelData.key
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 0
                    color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: active ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: tabBtn.modelData.label
                        color: tabBtn.active ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
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

        // Icerik alani
        Item {
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            clip: true

            // ── SEKME 1: CIHAZLAR ────────────────────────────────────────
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

                    // Cikis Ana Kontrol
                    Rectangle {
                        width: parent.width
                        height: 68
                        radius: 0
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
                                    implicitWidth: 24
                                    implicitHeight: 22
                                    radius: 0
                                    color: AudioState.muted ? Theme.danger : Theme.surface2
                                    border.color: AudioState.muted ? Theme.danger : Theme.borderSubtle
                                    border.width: 1

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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: AudioState.muted ? I18n.t("SESSİZ", "MUTE") : (Math.round(AudioState.volume * 100) + "%")
                                    color: AudioState.muted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            GothamSlider {
                                Layout.fillWidth: true
                                value: AudioState.volume
                                muted: AudioState.muted
                                onMoved: (v) => AudioState.setVolume(v)
                            }
                        }
                    }

                    // Giris Mikrofon Ana Kontrol
                    Rectangle {
                        width: parent.width
                        height: 68
                        radius: 0
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
                                    implicitWidth: 24
                                    implicitHeight: 22
                                    radius: 0
                                    color: AudioState.micMuted ? Theme.danger : Theme.surface2
                                    border.color: AudioState.micMuted ? Theme.danger : Theme.borderSubtle
                                    border.width: 1

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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: AudioState.micMuted ? I18n.t("SESSİZ", "MUTE") : (Math.round(AudioState.micVolume * 100) + "%")
                                    color: AudioState.micMuted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            GothamSlider {
                                Layout.fillWidth: true
                                value: AudioState.micVolume
                                muted: AudioState.micMuted
                                onMoved: (v) => AudioState.setMicVolume(v)
                            }
                        }
                    }

                    Text {
                        text: I18n.t("ÇIKIŞ CİHAZLARI", "OUTPUT DEVICES")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Repeater {
                        model: AudioState.sinks
                        delegate: Rectangle {
                            id: sinkRow
                            required property var modelData
                            width: devicesCol.width
                            height: 36
                            radius: 0
                            color: modelData.isDefault ? Theme.surfaceActive : (sinkMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.isDefault ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
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
                        text: I18n.t("GİRİŞ CİHAZLARI", "INPUT DEVICES")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Repeater {
                        model: AudioState.sources
                        delegate: Rectangle {
                            id: srcRow
                            required property var modelData
                            width: devicesCol.width
                            height: 36
                            radius: 0
                            color: modelData.isDefault ? Theme.surfaceActive : (srcMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.isDefault ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
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

            // ── SEKME 2: UYGULAMA AKISLARI ───────────────────────────────
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
                        height: 68
                        radius: 0
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
                                    implicitWidth: 24
                                    implicitHeight: 22
                                    radius: 0
                                    color: streamRow.modelData.muted ? Theme.danger : Theme.surface2
                                    border.color: streamRow.modelData.muted ? Theme.danger : Theme.borderSubtle
                                    border.width: 1

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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: streamRow.modelData.muted ? I18n.t("SESSİZ", "MUTE") : (Math.round(streamRow.modelData.volume * 100) + "%")
                                    color: streamRow.modelData.muted ? Theme.danger : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            GothamSlider {
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
                        text: I18n.t("Aktif ses akışı yok", "No active audio streams")
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}

