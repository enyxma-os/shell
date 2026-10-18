import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow {
    id: root
    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
    }
    margins {
        bottom: 60
    }

    implicitWidth: 260
    implicitHeight: 52
    color: "transparent"
    visible: container.opacity > 0.0

    property bool isReady: false

    Timer {
        id: initTimer
        interval: 300
        running: true
        onTriggered: root.isReady = true
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: container.opacity = 0.0
    }

    function show() {
        if (!isReady) return
        container.opacity = 1.0
        hideTimer.restart()
    }

    Connections {
        target: AudioState
        function onVolumeChanged() { root.show() }
        function onMutedChanged() { root.show() }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth
        opacity: 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingMedium
            anchors.rightMargin: Theme.spacingMedium
            spacing: Theme.spacingMedium

            Text {
                text: AudioState.muted ? "MUTED" : "VOL"
                color: AudioState.muted ? Theme.danger : Theme.textPrimary
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
                    width: parent.width * (AudioState.muted ? 0.0 : Math.max(0.0, Math.min(1.0, AudioState.volume)))
                    radius: height / 2
                    color: AudioState.muted ? Theme.danger : Theme.accent

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
                text: Math.round(AudioState.volume * 100) + "%"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
