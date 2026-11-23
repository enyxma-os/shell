import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * AudioPanel — Ses Karistirici Paneli Yonlendiricisi.
 *
 * Disariya tiklama ve Esc ile kapatma ergonomisini saglar;
 * aktif temaya gore DynamicAudioPanel veya GothamAudioPanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-audio"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: AudioState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: contentHost.opacity > 0.0

    Connections {
        target: AudioState
        function onIsOpenChanged() {
            if (AudioState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: AudioState.isOpen
        opacity: AudioState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            AudioState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: AudioState.close()
        }

        Loader {
            id: audioLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamAudioComponent : dynamicAudioComponent
        }

        Component {
            id: dynamicAudioComponent
            DynamicAudioPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamAudioComponent
            GothamAudioPanel {
                anchors.fill: parent
            }
        }
    }
}

