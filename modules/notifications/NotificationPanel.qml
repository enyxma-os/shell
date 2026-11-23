import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * NotificationPanel — Bildirim Merkezi Yonlendiricisi.
 *
 * Ekran kaplayan seffaf overlay olarak disariya tiklama ve Esc ile kapatma
 * saglar; aktif temaya gore DynamicNotificationPanel veya GothamNotificationPanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: NotificationState.isPanelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: NotificationState
        function onIsPanelOpenChanged() {
            if (NotificationState.isPanelOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: NotificationState.isPanelOpen
        opacity: NotificationState.isPanelOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            NotificationState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: NotificationState.close()
        }

        Loader {
            id: notifLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamNotifComponent : dynamicNotifComponent
        }

        Component {
            id: dynamicNotifComponent
            DynamicNotificationPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamNotifComponent
            GothamNotificationPanel {
                anchors.fill: parent
            }
        }
    }
}
