import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * BluetoothPanel — BlueZ Bluetooth Yonetim Paneli Yonlendiricisi.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-bluetooth"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: BluetoothState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: BluetoothState
        function onIsOpenChanged() {
            if (BluetoothState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: BluetoothState.isOpen
        opacity: BluetoothState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            BluetoothState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: BluetoothState.close()
        }

        Loader {
            id: btLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamBtComponent : dynamicBtComponent
        }

        Component {
            id: dynamicBtComponent
            DynamicBluetoothPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamBtComponent
            GothamBluetoothPanel {
                anchors.fill: parent
            }
        }
    }
}

