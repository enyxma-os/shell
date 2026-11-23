import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * PerformancePanel — Birlesik Sistem Paneli Yonlendiricisi (Performans & Depolama).
 *
 * Disariya tiklama ve Esc ile kapatma ergonomisini saglar;
 * aktif temaya gore DynamicPerformancePanel veya GothamPerformancePanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-performance"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: PerformanceState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: PerformanceState
        function onIsOpenChanged() {
            if (PerformanceState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: PerformanceState.isOpen
        opacity: PerformanceState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            PerformanceState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: PerformanceState.close()
        }

        Loader {
            id: perfLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamPerfComponent : dynamicPerfComponent
        }

        Component {
            id: dynamicPerfComponent
            DynamicPerformancePanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamPerfComponent
            GothamPerformancePanel {
                anchors.fill: parent
            }
        }
    }
}
