import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * OSD — Enyxma Shell Ses ve Parlaklik Gostergesi Yonlendiricisi.
 *
 * Ses ve parlaklik olaylarini tek yerde dinler; temaya gore DynamicOSD
 * veya 16 segmentli GothamOSD varyantini yukler.
 */
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
        bottom: Theme.isGotham ? 48 : 60
    }

    implicitWidth: Theme.isGotham ? 320 : 260
    implicitHeight: Theme.isGotham ? 58 : 52
    color: "transparent"
    visible: root.osdOpacity > 0.0

    property bool isReady: false
    property bool shown: false
    property string osdMode: "audio" // "audio" | "brightness"

    property real osdOpacity: root.shown ? 1.0 : 0.0
    Behavior on osdOpacity {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    Timer {
        id: initTimer
        interval: 300
        running: true
        onTriggered: root.isReady = true
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.shown = false
    }

    function show() {
        if (!isReady) return
        root.shown = true
        hideTimer.restart()
    }

    Connections {
        target: AudioState
        function onVolumeChanged() {
            root.osdMode = "audio"
            root.show()
        }
        function onMutedChanged() {
            root.osdMode = "audio"
            root.show()
        }
    }

    Connections {
        target: BrightnessState
        function onLevelChanged() {
            root.osdMode = "brightness"
            root.show()
        }
    }

    Loader {
        id: osdLoader
        anchors.fill: parent
        opacity: root.osdOpacity
        sourceComponent: Theme.isGotham ? gothamOsdComponent : dynamicOsdComponent
    }

    Component {
        id: dynamicOsdComponent
        DynamicOSD {
            anchors.fill: parent
            osdMode: root.osdMode
        }
    }

    Component {
        id: gothamOsdComponent
        GothamOSD {
            anchors.fill: parent
            osdMode: root.osdMode
        }
    }
}
