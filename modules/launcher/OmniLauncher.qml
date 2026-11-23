import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * OmniLauncher — Uygulama, Komut ve Pano Baslatici Yonlendiricisi.
 *
 * Scrim kapatma ve klavye odagini yonetir; aktif temaya gore
 * DynamicOmniLauncher veya GothamOmniLauncher yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LauncherState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: contentHost.opacity > 0.0

    Item {
        id: contentHost
        anchors.fill: parent
        opacity: LauncherState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: LauncherState.close()
        }

        Loader {
            id: launcherLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamLauncherComponent : dynamicLauncherComponent
        }

        Component {
            id: dynamicLauncherComponent
            DynamicOmniLauncher {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamLauncherComponent
            GothamOmniLauncher {
                anchors.fill: parent
            }
        }
    }
}
