import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * AISidebar — Enyxma AI ve ORACLE Kenar Cubugu Yonlendiricisi.
 *
 * Disariya tiklama ve Esc ile kapatma saglar;
 * aktif temaya gore DynamicAISidebar veya GothamAISidebar yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-ai"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: AIState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: AIState
        function onIsOpenChanged() {
            if (AIState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: AIState.isOpen
        opacity: AIState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            AIState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: AIState.close()
        }

        Loader {
            id: aiLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamAiComponent : dynamicAiComponent
        }

        Component {
            id: dynamicAiComponent
            DynamicAISidebar {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamAiComponent
            GothamAISidebar {
                anchors.fill: parent
            }
        }
    }
}
