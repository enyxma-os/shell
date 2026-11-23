import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * TimePanel — Zaman, Takvim ve Meteoroloji Paneli Yonlendiricisi.
 *
 * Disariya tiklama ve Esc ile kapatma ergononomisini saglar;
 * aktif temaya gore DynamicTimePanel veya GothamTimePanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-time-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: TimeState.isPanelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: TimeState
        function onIsPanelOpenChanged() {
            if (TimeState.isPanelOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: TimeState.isPanelOpen
        opacity: TimeState.isPanelOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            TimeState.isPanelOpen = false
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: TimeState.isPanelOpen = false
        }

        Loader {
            id: timeLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamTimeComponent : dynamicTimeComponent
        }

        Component {
            id: dynamicTimeComponent
            DynamicTimePanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamTimeComponent
            GothamTimePanel {
                anchors.fill: parent
            }
        }
    }
}
