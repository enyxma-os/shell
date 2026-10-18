pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isOpen: false
    property var clients: []
    property var workspaces: []
    property int activeWorkspaceId: 1
    property int viewedWorkspaceId: 1
    property int selectedIndex: 0

    function toggle(): void {
        if (root.isOpen) {
            root.close()
        } else {
            root.open()
        }
    }

    function open(): void {
        root.isOpen = true
        root.selectedIndex = 0
        refreshProc.running = true
    }

    function close(): void {
        root.isOpen = false
    }

    function next(): void {
        if (!root.isOpen) {
            root.open()
            root.selectedIndex = 1
        } else {
            if (root.clients.length > 0) {
                root.selectedIndex = (root.selectedIndex + 1) % root.clients.length
            }
        }
    }

    function prev(): void {
        if (!root.isOpen) {
            root.open()
        } else {
            if (root.clients.length > 0) {
                root.selectedIndex = (root.selectedIndex - 1 + root.clients.length) % root.clients.length
            }
        }
    }

    function activateSelected(): void {
        if (root.clients.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.clients.length) {
            root.focusClient(root.clients[root.selectedIndex].address)
        } else {
            root.close()
        }
    }

    function closeSelected(): void {
        if (root.clients.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.clients.length) {
            var addr = root.clients[root.selectedIndex].address
            root.closeClient(addr)
        }
    }

    function focusClient(addr): void {
        root.close()
        Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + addr])
    }

    function closeClient(addr): void {
        Quickshell.execDetached(["hyprctl", "dispatch", "closewindow", "address:" + addr])
        refreshProc.running = true
    }

    function switchWorkspace(id): void {
        root.close()
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(id)])
    }

    function createWorkspace(): void {
        var nextId = 1
        for (var i = 0; i < root.workspaces.length; i++) {
            if (root.workspaces[i].id >= nextId) {
                nextId = root.workspaces[i].id + 1
            }
        }
        root.switchWorkspace(nextId)
    }

    function cycleWorkspace(delta): void {
        if (root.workspaces.length === 0) return
        var curIdx = 0
        for (var i = 0; i < root.workspaces.length; i++) {
            if (root.workspaces[i].id === root.viewedWorkspaceId) {
                curIdx = i
                break
            }
        }
        var nextIdx = ((curIdx + delta) % root.workspaces.length + root.workspaces.length) % root.workspaces.length
        root.viewedWorkspaceId = root.workspaces[nextIdx].id
    }

    function clientsForWorkspace(wsId) {
        var res = []
        for (var i = 0; i < root.clients.length; i++) {
            var c = root.clients[i]
            if (c.workspace && c.workspace.id === wsId) {
                res.push(c)
            }
        }
        return res
    }

    Process {
        id: refreshProc
        command: ["bash", "-c", "printf '{\"clients\":%s,\"workspaces\":%s,\"active\":%s}\\n' \"$(hyprctl clients -j 2>/dev/null || echo '[]')\" \"$(hyprctl workspaces -j 2>/dev/null || echo '[]')\" \"$(hyprctl activeworkspace -j 2>/dev/null || echo '{}')\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim())

                    // Filter valid clients
                    var rawClients = data.clients || []
                    var validClients = []
                    for (var i = 0; i < rawClients.length; i++) {
                        var c = rawClients[i]
                        if (c.mapped && c.workspace && c.workspace.id > 0) {
                            validClients.push(c)
                        }
                    }
                    root.clients = validClients

                    // Workspaces
                    var rawWs = data.workspaces || []
                    rawWs.sort(function(a, b) { return a.id - b.id })
                    
                    // If no workspaces reported, provide at least active
                    if (rawWs.length === 0 && data.active && data.active.id) {
                        rawWs.push(data.active)
                    }
                    root.workspaces = rawWs

                    // Active workspace
                    if (data.active && data.active.id) {
                        root.activeWorkspaceId = data.active.id
                        if (!root.viewedWorkspaceId || root.viewedWorkspaceId <= 0) {
                            root.viewedWorkspaceId = data.active.id
                        }
                    }
                } catch (e) {
                    console.log("[OverviewState] JSON parse error: " + e)
                }
            }
        }
    }

    IpcHandler {
        target: "overview"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function next(): void { root.next() }
        function prev(): void { root.prev() }
        function activate(): void { root.activateSelected() }
    }

    IpcHandler {
        target: "enyxma-overview"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function next(): void { root.next() }
        function prev(): void { root.prev() }
        function activate(): void { root.activateSelected() }
    }
}
