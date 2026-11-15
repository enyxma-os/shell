pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var workspaces: Hyprland.workspaces
    readonly property string activeWindowTitle: Hyprland.activeToplevel?.title ?? ""

    // Acik pencereleri olan calisma alanlari kumesi
    readonly property var occupiedWorkspaceIds: {
        const ids = {}
        const count = Hyprland.toplevels ? Hyprland.toplevels.count : 0
        const tl = Hyprland.toplevels ? Hyprland.toplevels.values : []
        for (let i = 0; i < tl.length; i++) {
            const t = tl[i]
            if (t && t.workspace && t.workspace.id > 0) {
                ids[t.workspace.id] = true
            }
        }
        return ids
    }

    function isOccupied(wsId) {
        return !!root.occupiedWorkspaceIds[wsId]
    }

    function switchWorkspace(id) {
        Hyprland.dispatch("workspace " + id)
    }
}

