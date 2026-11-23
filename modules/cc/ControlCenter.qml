import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "../../services"

/**
 * ControlCenter — Enyxma Shell Kontrol Merkezi Yonlendiricisi.
 *
 * Ekran kaplayan saydam overlay katmani olarak calisir; disariya tiklama ve Esc
 * ile kapatma ergononomisini saglar, gece isigi durumunu tutar ve temaya gore
 * Dynamic veya Gotham varyantini yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-cc"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: SystemState.isControlCenterOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: contentHost.opacity > 0.0

    // Gece Isigi durumu — SettingsState uzerinden merkezi yonetilir

    Connections {
        target: SystemState
        function onIsControlCenterOpenChanged() {
            if (SystemState.isControlCenterOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: SystemState.isControlCenterOpen
        opacity: SystemState.isControlCenterOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            SystemState.closeControlCenter()
            event.accepted = true
        }

        // Kart disina tiklaninca Kontrol Merkezini kapat
        MouseArea {
            anchors.fill: parent
            onClicked: SystemState.closeControlCenter()
        }

        Loader {
            id: ccLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamCcComponent : dynamicCcComponent
        }

        Component {
            id: dynamicCcComponent
            DynamicControlCenter {
                anchors.fill: parent
                nightLightActive: SettingsState.nightLightEnabled
                onToggleNightLightRequested: SettingsState.toggleNightLight()
            }
        }

        Component {
            id: gothamCcComponent
            GothamControlCenter {
                anchors.fill: parent
                nightLightActive: SettingsState.nightLightEnabled
                onToggleNightLightRequested: SettingsState.toggleNightLight()
            }
        }
    }
}
