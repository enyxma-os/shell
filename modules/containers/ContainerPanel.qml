import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * ContainerPanel — Docker / Podman Konteyner Izleyici Yonlendiricisi.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-containers"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ContainerState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: ContainerState
        function onIsOpenChanged() {
            if (ContainerState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: ContainerState.isOpen
        opacity: ContainerState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            ContainerState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: ContainerState.close()
        }

        Loader {
            id: containerLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamContainerComponent : dynamicContainerComponent
        }

        Component {
            id: dynamicContainerComponent
            DynamicContainerPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamContainerComponent
            GothamContainerPanel {
                anchors.fill: parent
            }
        }
    }
}
