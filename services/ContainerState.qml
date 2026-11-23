pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

/**
 * ContainerState — Docker / Podman konteyner izleme ve kontrol servisi.
 *
 * Yalnizca SettingsState.enableContainerMonitor acikken motoru algilar
 * ve yalnizca panel acikken 5 saniyelik yenileme yapar.
 */
Singleton {
    id: root

    property bool isOpen: false
    property string engine: "" // "" | "docker" | "podman" | "none"
    property var containers: []
    property string busyId: ""
    property string lastError: ""

    readonly property int runningCount: {
        var c = 0
        for (var i = 0; i < containers.length; i++) {
            if (containers[i].running) c++
        }
        return c
    }

    function open() {
        isOpen = true
        if (engine === "") detectEngine()
        else refresh()
    }

    function close() {
        isOpen = false
    }

    function toggle() {
        if (isOpen) close()
        else open()
    }

    function detectEngine() {
        if (!SettingsState.enableContainerMonitor || detectProc.running) return
        detectProc.command = ["which", "docker"]
        detectProc._step = 0
        detectProc.running = true
    }

    Process {
        id: detectProc
        running: false
        property int _step: 0
        onExited: (code) => {
            if (code === 0) {
                root.engine = (_step === 0) ? "docker" : "podman"
                root.refresh()
                return
            }
            if (_step === 0) {
                _step = 1
                command = ["which", "podman"]
                running = true
            } else {
                root.engine = "none"
                root.containers = []
            }
        }
    }

    function refresh() {
        if (!SettingsState.enableContainerMonitor) return
        if (root.engine === "") { detectEngine(); return }
        if (root.engine === "none" || psProc.running) return
        psProc.command = [root.engine, "ps", "-a", "--format", "{{.ID}}|{{.Names}}|{{.Image}}|{{.State}}|{{.Status}}"]
        psProc.running = true
    }

    Process {
        id: psProc
        running: false
        stdout: StdioCollector { id: psOut }
        onExited: (code) => {
            if (code !== 0) {
                root.lastError = root.engine + " servisine erişilemedi"
                root.containers = []
                return
            }
            root.lastError = ""
            var lines = (psOut.text || "").split("\n")
            var out = []
            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim()
                if (!l) continue
                var parts = l.split("|")
                if (parts.length < 5) continue
                var st = parts[3].trim().toLowerCase()
                out.push({
                    id: parts[0].trim(),
                    name: parts[1].trim(),
                    image: parts[2].trim(),
                    state: st,
                    status: parts[4].trim(),
                    running: st === "running"
                })
            }
            out.sort(function(a, b) {
                if (a.running !== b.running) return a.running ? -1 : 1
                return a.name.localeCompare(b.name)
            })
            root.containers = out
        }
    }

    Timer {
        interval: 5000
        running: root.isOpen && SettingsState.enableContainerMonitor && root.engine !== "none" && root.engine !== ""
        repeat: true
        onTriggered: root.refresh()
    }

    function runAction(id, verb) {
        if (root.engine === "none" || root.engine === "" || actionProc.running) return
        root.busyId = id
        actionProc.command = [root.engine, verb, id]
        actionProc.running = true
    }

    function startContainer(id) { runAction(id, "start") }
    function stopContainer(id) { runAction(id, "stop") }
    function restartContainer(id) { runAction(id, "restart") }

    Process {
        id: actionProc
        running: false
        onExited: (code) => {
            root.busyId = ""
            if (code !== 0) root.lastError = "Konteyner işlemi başarısız"
            root.refresh()
        }
    }

    Component.onCompleted: {
        if (SettingsState.enableContainerMonitor) detectEngine()
    }

    IpcHandler {
        target: "containers"
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function refresh(): void { root.refresh() }
    }
}
