import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-action-chips"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 48
        right: 16
    }

    implicitWidth: 420
    implicitHeight: chipColumn.implicitHeight + (chipColumn.children.length > 0 ? 24 : 0)
    color: "transparent"

    visible: ThornhillState.actionChips.length > 0

    ColumnLayout {
        id: chipColumn
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: ThornhillState.actionChips

            ActionChipCard {
                required property var modelData
                chip: modelData
                Layout.fillWidth: true
            }
        }
    }
}
