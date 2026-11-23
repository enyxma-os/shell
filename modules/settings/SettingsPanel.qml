import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * SettingsPanel — Enyxma Ayarlar Penceresi Yonlendiricisi.
 *
 * Disariya tiklama ve Esc ile kapatma ergonomisini saglar;
 * aktif temaya gore DynamicSettingsPanel veya GothamSettingsPanel yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: SettingsState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
        target: SettingsState
        function onIsOpenChanged() {
            if (SettingsState.isOpen) {
                contentHost.forceActiveFocus()
            }
        }
    }

    Item {
        id: contentHost
        anchors.fill: parent
        focus: SettingsState.isOpen
        opacity: SettingsState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Keys.onEscapePressed: (event) => {
            SettingsState.close()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: SettingsState.close()
        }

        Loader {
            id: settingsLoader
            anchors.fill: parent
            sourceComponent: Theme.isGotham ? gothamSettingsComponent : dynamicSettingsComponent
        }

        Component {
            id: dynamicSettingsComponent
            DynamicSettingsPanel {
                anchors.fill: parent
            }
        }

        Component {
            id: gothamSettingsComponent
            GothamSettingsPanel {
                anchors.fill: parent
            }
        }
    }
}
