import QtQuick
import QtQuick.Layouts
import "../../services"

/**
 * DynamicOSD — Dinamik Tema Yuvarlatilmis Cam OSD Gostergesi.
 */
Rectangle {
    id: container

    property string osdMode: "audio"

    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMedium
        anchors.rightMargin: Theme.spacingMedium
        spacing: Theme.spacingMedium

        Text {
            text: container.osdMode === "brightness"
                ? "󰃠 BRT"
                : (AudioState.muted ? "󰝟 MUTED" : "󰕾 VOL")
            color: container.osdMode === "brightness"
                ? Theme.accent
                : (AudioState.muted ? Theme.danger : Theme.textPrimary)
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }

        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: height / 2
            color: Theme.surface1

            Rectangle {
                height: parent.height
                width: parent.width * (
                    container.osdMode === "brightness"
                        ? Math.max(0.0, Math.min(1.0, BrightnessState.level))
                        : (AudioState.muted ? 0.0 : Math.max(0.0, Math.min(1.0, AudioState.volume)))
                )
                radius: height / 2
                color: (container.osdMode === "audio" && AudioState.muted) ? Theme.danger : Theme.accent

                Behavior on width {
                    enabled: !Theme.reduceMotion
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutQuint
                    }
                }
            }
        }

        Text {
            text: container.osdMode === "brightness"
                ? (Math.round(BrightnessState.level * 100) + "%")
                : (AudioState.muted ? "0%" : (Math.round(AudioState.volume * 100) + "%"))
            color: (container.osdMode === "audio" && AudioState.muted) ? Theme.danger : Theme.textSecondary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}

