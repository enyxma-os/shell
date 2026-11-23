pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * BluetoothState — BlueZ adaptor ve cihaz yoneticisi.
 *
 * Polling YOKTUR: yalnizca acilista, panel acildiginda ve kullanici
 * eylemlerinden sonra `bluetoothctl` uzerinden guncellenir.
 */
Singleton {
    id: root

    // "unknown" | "on" | "off" | "unsupported"
    property string state: "unknown"
    property bool busy: false
    property string lastError: ""
    property string adapter: ""

    // Panel ve cihaz durumu
    property bool isOpen: false
    property bool isScanning: false
    property string busyMac: ""
    property var devices: []

    readonly property bool enabled: root.state === "on"
    readonly property bool supported: root.state !== "unsupported"

    readonly property int connectedCount: {
        var c = 0
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected) c++
        }
        return c
    }

    readonly property string statusText: {
        if (root.state === "unsupported") return "bluetoothctl yok"
        if (root.state === "unknown") return "Sorgulanıyor…"
        if (root.state === "on") return root.adapter !== "" ? root.adapter : "Açık"
        return "Kapalı"
    }

    readonly property string connectedSummary: {
        if (!root.enabled) return root.statusText
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected) {
                var bat = devices[i].battery >= 0 ? (" · %" + devices[i].battery) : ""
                return devices[i].name + bat
            }
        }
        return root.statusText
    }

    function open() {
        isOpen = true
        refresh()
    }

    function close() {
        isOpen = false
    }

    function toggle() {
        if (isOpen) close()
        else open()
    }

    Process {
        id: showProc
        running: false
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { id: out }
        onExited: (code) => {
            root.busy = false
            if (code !== 0) {
                root.state = "unsupported"
                root.lastError = "bluetoothctl bulunamadı"
                root.devices = []
                return
            }
            const text = out.text || ""
            let powered = "unknown"
            let name = ""
            const lines = text.split("\n")
            for (let i = 0; i < lines.length; i++) {
                const mP = lines[i].match(/^\s*Powered:\s*(\w+)/i)
                if (mP) powered = mP[1].toLowerCase()
                const mN = lines[i].match(/^\s*Name:\s*(.+)$/i)
                if (mN) name = mN[1].trim()
            }
            root.adapter = name
            root.state = powered === "yes" ? "on" : "off"
            root.lastError = ""
            if (root.state === "on") {
                root.refreshDevices()
            } else {
                root.devices = []
            }
        }
    }

    function refresh() {
        if (showProc.running) return
        root.busy = true
        showProc.running = true
    }

    // ── Cihaz Listesi ve Bilgi Hatti ─────────────────────────────────
    property var _queue: []
    property var _collected: []
    property var _currentTarget: null

    function refreshDevices() {
        if (!root.enabled || devicesProc.running || infoProc.running) return
        devicesProc.running = true
    }

    Process {
        id: devicesProc
        running: false
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector { id: devicesOut }
        onExited: (code) => {
            if (code !== 0) return
            var lines = (devicesOut.text || "").split("\n")
            var q = []
            for (var i = 0; i < lines.length; i++) {
                var m = lines[i].match(/^Device\s+([0-9A-Fa-f:]{17})\s+(.+)$/)
                if (m) {
                    q.push({ mac: m[1].toUpperCase(), name: m[2].trim() })
                }
            }
            root._queue = q
            root._collected = []
            root.fetchNextDeviceInfo()
        }
    }

    function fetchNextDeviceInfo() {
        if (root._queue.length === 0) {
            root._collected.sort(function(a, b) {
                if (a.connected !== b.connected) return a.connected ? -1 : 1
                if (a.paired !== b.paired) return a.paired ? -1 : 1
                return a.name.localeCompare(b.name)
            })
            root.devices = root._collected
            return
        }
        var next = root._queue.shift()
        root._currentTarget = next
        infoProc.command = ["bluetoothctl", "info", next.mac]
        infoProc.running = true
    }

    Process {
        id: infoProc
        running: false
        stdout: StdioCollector { id: infoOut }
        onExited: (code) => {
            var target = root._currentTarget
            if (target && code === 0) {
                var text = infoOut.text || ""
                var name = target.name
                var paired = false
                var trusted = false
                var connected = false
                var icon = ""
                var battery = -1
                var lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim()
                    if (l.indexOf("Alias:") === 0) {
                        var al = l.substring(6).trim()
                        if (al !== "") name = al
                    } else if (l.indexOf("Paired:") === 0) {
                        paired = l.toLowerCase().indexOf("yes") >= 0
                    } else if (l.indexOf("Trusted:") === 0) {
                        trusted = l.toLowerCase().indexOf("yes") >= 0
                    } else if (l.indexOf("Connected:") === 0) {
                        connected = l.toLowerCase().indexOf("yes") >= 0
                    } else if (l.indexOf("Icon:") === 0) {
                        icon = l.substring(5).trim()
                    } else if (l.indexOf("Battery Percentage:") === 0) {
                        var bm = l.match(/\((\d+)\)/)
                        if (bm) battery = parseInt(bm[1], 10)
                    }
                }
                root._collected.push({
                    mac: target.mac,
                    name: name,
                    paired: paired,
                    trusted: trusted,
                    connected: connected,
                    icon: icon,
                    battery: battery
                })
            }
            root.fetchNextDeviceInfo()
        }
    }

    // ── Tarama ve Cihaz Eylemleri ────────────────────────────────────
    function startScan() {
        if (!root.enabled || scanProc.running) return
        root.isScanning = true
        scanProc.running = true
    }

    Process {
        id: scanProc
        running: false
        command: ["bluetoothctl", "--timeout", "10", "scan", "on"]
        onExited: {
            root.isScanning = false
            root.refreshDevices()
        }
    }

    function runDeviceAction(mac, args) {
        if (actionProc.running) return
        root.busyMac = mac
        actionProc.command = args
        actionProc.running = true
    }

    function connectDevice(mac) { runDeviceAction(mac, ["bluetoothctl", "connect", mac]) }
    function disconnectDevice(mac) { runDeviceAction(mac, ["bluetoothctl", "disconnect", mac]) }
    function pairDevice(mac) { runDeviceAction(mac, ["bluetoothctl", "pair", mac]) }
    function removeDevice(mac) { runDeviceAction(mac, ["bluetoothctl", "remove", mac]) }

    Process {
        id: actionProc
        running: false
        onExited: (code) => {
            root.busyMac = ""
            if (code !== 0) {
                root.lastError = "Bluetooth işlemi başarısız"
            } else {
                root.lastError = ""
            }
            root.refreshDevices()
        }
    }

    Timer {
        id: verifyTimer
        interval: 350
        repeat: false
        onTriggered: root.refresh()
    }

    function togglePower() {
        if (!root.supported || root.busy) {
            if (!root.supported) root.lastError = "BlueZ aracı yok"
            return
        }
        root.busy = true
        root.state = root.enabled ? "off" : "on"
        powerProc.exec(["bluetoothctl", "power", root.enabled ? "off" : "on"])
        verifyTimer.restart()
    }

    Process {
        id: powerProc
        running: false
        onExited: (code) => {
            if (code !== 0) {
                root.lastError = "Güç değiştirilemedi"
                root.refresh()
            }
        }
    }

    Component.onCompleted: root.refresh()

    IpcHandler {
        target: "bluetooth"
        function toggle(): void { root.togglePower() }
        function refresh(): void { root.refresh() }
        function status(): string { return root.state }
        function openPanel(): void { root.open() }
        function closePanel(): void { root.close() }
        function togglePanel(): void { root.toggle() }
    }
}
