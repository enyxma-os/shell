import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * NetworkPanel — Ag, Wi-Fi, VPN ve Hiz Testi Paneli Yonlendiricisi.
 *
 * Disariya tiklama ve Esc ile kapatma ergonomisini saglar;
 * aktif temaya gore DynamicNetworkPanel veya GothamNetworkPanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-network"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: NetworkState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: NetworkState
        function onIsOpenChanged() {
            if (NetworkState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: NetworkState.isOpen
        opacity: NetworkState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            NetworkState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: NetworkState.close()
        }

        Loader {
            id: networkLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamNetworkComponent : dynamicNetworkComponent
        }

        Component {
            id: dynamicNetworkComponent
            DynamicNetworkPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamNetworkComponent
            GothamNetworkPanel {
                anchors.fill: parent
            }
        }
    }
}
