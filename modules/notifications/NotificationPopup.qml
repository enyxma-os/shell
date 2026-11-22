import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import "../../services"

/**
 * NotificationPopup — Anlik Bildirim Karti Yonlendiricisi.
 *
 * Bildirim kuyrugu, aciliyet ve hover duraklatma mantigini yonetir;
 * temaya gore DynamicNotificationPopup veya GothamNotificationPopup yukler.
 */
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-notify"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: NotificationState.hasActivePopup ? (Theme.isGotham ? Theme.barHeight : 48) : 20
        right: Theme.isGotham ? 0 : 12
    }

    implicitWidth: Theme.isGotham ? 360 : 340
    implicitHeight: popupLoader.item ? popupLoader.item.implicitHeight : 1
    color: "transparent"

    property real popupOpacity: NotificationState.hasActivePopup ? 1.0 : 0.0
    Behavior on popupOpacity {
        enabled: !Theme.reduceMotion
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
    }

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
    }

    visible: root.popupOpacity > 0.0

    readonly property var popup: NotificationState.activePopup
    readonly property bool isCritical: !!popup && popup.urgency === NotificationUrgency.Critical

    Loader {
        id: popupLoader
        width: parent.width
        opacity: root.popupOpacity
        sourceComponent: Theme.isGotham ? gothamPopupComponent : dynamicPopupComponent
    }

    Component {
        id: dynamicPopupComponent
        DynamicNotificationPopup {
            width: popupLoader.width
            popup: root.popup
            isCritical: root.isCritical
        }
    }

    Component {
        id: gothamPopupComponent
        GothamNotificationPopup {
            width: popupLoader.width
            popup: root.popup
            isCritical: root.isCritical
        }
    }
}
