import QtQuick
import QtQuick.Layouts
import "../../services"

/**
 * GothamOSD — Gotham 2.0 16 Segmentli Taktiksel HUD OSD Gostergesi.
 */
Rectangle {
    id: container

    property string osdMode: "audio"

    readonly property bool isMutedAudio: osdMode === "audio" && AudioState.muted
    readonly property real levelRatio: osdMode === "brightness"
        ? Math.max(0.0, Math.min(1.0, BrightnessState.level))
        : (AudioState.muted ? 0.0 : Math.max(0.0, Math.min(1.0, AudioState.volume)))
    readonly property int filledSegments: Math.round(levelRatio * 16)

    color: Theme.bgPanel
    radius: 0
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    // Ust 1px durum vurgu hatti
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: container.isMutedAudio ? Theme.danger : Theme.accent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMedium
        anchors.rightMargin: Theme.spacingMedium
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 6

        // Ust teknik etiket ve sayisal deger
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: container.osdMode === "brightness" ? "BRT // PARLAKLIK" : "VOL // SES"
                color: container.isMutedAudio ? Theme.danger : Theme.textPrimary
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fontSizeXS + 1
                font.bold: true
                font.letterSpacing: 1.5
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: valTxt.implicitWidth + 12
                implicitHeight: 16
                radius: 0
                color: Theme.surface1
                border.width: 1
                border.color: container.isMutedAudio ? Theme.danger : Theme.borderSubtle

                Text {
                    id: valTxt
                    anchors.centerIn: parent
                    text: container.osdMode === "brightness"
                        ? ("[ " + Math.round(BrightnessState.level * 100) + "% ]")
                        : (AudioState.muted ? "[ SESSİZ ]" : ("[ " + Math.round(AudioState.volume * 100) + "% ]"))
                    color: container.isMutedAudio ? Theme.danger : Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }
            }
        }

        // 16 Segmentli Blok Metre
        RowLayout {
            Layout.fillWidth: true
            spacing: 3

            Repeater {
                model: 16

                delegate: Rectangle {
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: 10
                    radius: 0
                    color: index < container.filledSegments
                        ? (container.isMutedAudio ? Theme.danger : Theme.accent)
                        : Theme.surfaceActive
                }
            }
        }
    }
}

