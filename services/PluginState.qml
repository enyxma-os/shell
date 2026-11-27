pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

/**
 * PluginState — ~/.config/enyxma/plugins/ altindaki yerel QML eklentilerini kesfeder.
 *
 * Her eklenti klasorunde manifest.json beklenir:
 * { "id": "ornek", "name": "Ornek", "description": "...", "slot": "bar", "entry": "Main.qml" }
 * Acik eklentiler SettingsState.enabledPlugins icinde kalici saklanir.
 */
Singleton {
    id: root

    readonly property string pluginsDir: (Quickshell.env("HOME") || "") + "/.config/enyxma/plugins"
    property var plugins: []

    readonly property var activeBarPlugins: {
        var out = []
        var _dep = SettingsState.enabledPlugins
        for (var i = 0; i < plugins.length; i++) {
            var p = plugins[i]
            if (p.slot === "bar" && SettingsState.isPluginEnabled(p.id)) {
                out.push(p)
            }
        }
        return out
    }

    property var _queue: []
    property var _collected: []
    property string _currentManifest: ""

    function refresh() {
        if (mkdirProc.running || findProc.running) return
        mkdirProc.running = true
    }

    function openPluginsDir() {
        openDirProc.running = true
    }

    Process {
        id: openDirProc
        running: false
        command: ["mkdir", "-p", root.pluginsDir]
        onExited: {
            Quickshell.execDetached(["enyxma-launch", "xdg-open", root.pluginsDir])
        }
    }

    Process {
        id: mkdirProc
        running: true
        command: ["mkdir", "-p", root.pluginsDir]
        onExited: {
            findProc.running = true
        }
    }

    Process {
        id: findProc
        running: false
        command: ["find", "-L", root.pluginsDir, "-maxdepth", "2", "-name", "manifest.json"]
        stdout: StdioCollector { id: findOut }
        onExited: (code) => {
            if (code !== 0) {
                root.plugins = []
                return
            }
            var lines = (findOut.text || "").split("\n")
            var q = []
            for (var i = 0; i < lines.length; i++) {
                var p = lines[i].trim()
                if (p !== "") q.push(p)
            }
            root._queue = q
            root._collected = []
            root.readNextManifest()
        }
    }

    function readNextManifest() {
        if (root._queue.length === 0) {
            root.plugins = root._collected
            return
        }
        root._currentManifest = root._queue.shift()
        manifestFile.path = root._currentManifest
        manifestFile.reload()
    }

    FileView {
        id: manifestFile
        path: ""
        printErrors: false
        blockLoading: false
        onLoaded: {
            try {
                var raw = String(manifestFile.text() || "").trim()
                if (raw !== "") {
                    var d = JSON.parse(raw)
                    if (d && typeof d === "object" && d.id && d.entry) {
                        var dir = root._currentManifest.replace(/\/manifest\.json$/, "")
                        var cleanEntry = String(d.entry).replace(/^\/+/, "")
                        if (cleanEntry.indexOf("..") < 0) {
                            var pid = String(d.id)
                            var defOn = d.defaultEnabled === true
                            if (defOn) {
                                SettingsState.registerDefaultPlugin(pid)
                            }
                            root._collected.push({
                                id: pid,
                                name: String(d.name || d.id),
                                description: String(d.description || "Yerel Enyxma eklentisi"),
                                slot: String(d.slot || "bar"),
                                entryPath: dir + "/" + cleanEntry,
                                defaultEnabled: defOn
                            })
                        }
                    }
                }
            } catch (e) {
                console.warn("PluginState: manifest okunamadi:", root._currentManifest, e)
            }
            root.readNextManifest()
        }
        onLoadFailed: root.readNextManifest()
    }

    IpcHandler {
        target: "plugins"
        function refresh(): void { root.refresh() }
    }
}
