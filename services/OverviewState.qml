pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isOpen: false
    property var clients: []

    function toggle(): void {
        if (root.isOpen) {
            root.close()
        } else {
            root.open()
        }
    }

    function open(): void {
        root.isOpen = true
        refreshProc.running = true
    }

    function close(): void {
        root.isOpen = false
    }

    function focusClient(addr): void {
        root.close()
        Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + addr])
    }

    Process {
        id: refreshProc
        command: ["bash", "-c", "hyprctl clients -j 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(this.text.trim())
                    var valid = []
                    for (var i = 0; i < parsed.length; i++) {
                        var c = parsed[i]
                        if (c.mapped && c.workspace && c.workspace.id > 0) {
                            valid.push(c)
                        }
                    }
                    root.clients = valid
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
    }

    IpcHandler {
        target: "enyxma-overview"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
    }
}
