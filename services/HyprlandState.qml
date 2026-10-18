pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var workspaces: Hyprland.workspaces
    readonly property string activeWindowTitle: Hyprland.activeToplevel?.title ?? ""

    function switchWorkspace(id) {
        Hyprland.dispatch("workspace " + id)
    }
}
