pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    property bool isOpen: false
    property string activeTab: "performance" // performance | storage
    property string sortBy: "cpu" // cpu | mem

    function openTab(tab): void {
        var next = (tab === "storage") ? "storage" : "performance"
        root.activeTab = next
        root.isOpen = true
        if (next === "storage") {
            StorageState.refresh()
        } else {
            root.refreshHeavy()
        }
    }

    function toggleTab(tab): void {
        var next = (tab === "storage") ? "storage" : "performance"
        if (root.isOpen && root.activeTab === next) {
            root.close()
        } else {
            root.openTab(next)
        }
    }

    function setSortBy(mode): void {
        var next = (mode === "mem") ? "mem" : "cpu"
        if (root.sortBy === next) return
        root.sortBy = next
        if (root._lastPsText !== "") {
            root.parseTop(root._lastPsText)
        }
    }

    function toggle(): void { root.toggleTab("performance") }
    function open(): void { root.openTab("performance") }
    function close(): void { root.isOpen = false }

    // ── Donanim Metrikleri ──────────────────────────────────────────
    property int cpuPercent: 0
    property string cpuModel: "İşlemci"
    property int cpuCores: 0
    property int cpuTempC: 0
    property string kernel: ""
    property var topProcesses: []
    property string _lastPsText: ""

    property int memPercent: 0
    property real memUsedGiB: 0.0
    property real memAvailGiB: 0.0
    property real memTotalGiB: 0.0

    property int gpuPercent: 0
    property string gpuModel: "Ekran Kartı"
    property int gpuTempC: 0
    property int vramPercent: 0
    property real vramUsedGiB: 0.0
    property real vramTotalGiB: 0.0

    property real _prevTotal: 0
    property real _prevIdle: 0
    property real _vramUsedBytes: 0
    property real _vramTotalBytes: 0

    function formatMemKiB(kib) {
        var mb = (Number(kib) || 0) / 1024.0
        if (mb >= 1024.0) return (mb / 1024.0).toFixed(1) + " GB"
        return Math.round(mb) + " MB"
    }

    function updateVramPercent() {
        if (root._vramTotalBytes > 0) {
            root.vramPercent = Math.max(0, Math.min(100, Math.round((root._vramUsedBytes * 100) / root._vramTotalBytes)))
        }
    }

    // ── Statik sistem bilgisi: acilista 1 kez ───────────────────────
    Process {
        id: staticInfoProc
        command: ["uname", "-r"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.kernel = this.text.trim()
        }
    }

    Process {
        id: gpuModelProc
        command: ["lspci", "-mm", "-d", "::0300"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = String(this.text || "").trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i]
                    var cols = l.match(/"([^"]*)"/g)
                    if (!cols || cols.length < 3) continue
                    var vendor = cols[1].replace(/"/g, "")
                    var dev = cols[2].replace(/"/g, "")
                    var bracketMatch = dev.match(/\[([^\]]+)\]/)
                    var cleanDev = bracketMatch ? bracketMatch[1].trim() : dev.trim()
                    var prefix = vendor.indexOf("AMD") >= 0 ? "AMD "
                        : (vendor.indexOf("NVIDIA") >= 0 ? "NVIDIA "
                        : (vendor.indexOf("Intel") >= 0 ? "Intel " : ""))
                    root.gpuModel = prefix + cleanDev
                    return
                }
            }
        }
    }

    property string _cpuTempPath: ""
    property string _gpuTempPath: ""

    Process {
        id: hwmonDetectProc
        command: ["find", "-L", "/sys/class/hwmon", "-maxdepth", "2", "-name", "name", "-exec", "head", "-n", "1", "{}", "+"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = String(this.text || "").split("\n")
                var curDir = ""
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim()
                    if (l.indexOf("==> ") === 0) {
                        var pathPart = l.substring(4, l.length - 4).trim()
                        curDir = pathPart.replace(/\/name$/, "")
                    } else if (curDir !== "" && l !== "") {
                        var name = l.toLowerCase()
                        if ((name === "k10temp" || name === "coretemp" || name === "zenpower" || name === "cpu_thermal") && root._cpuTempPath === "") {
                            root._cpuTempPath = curDir + "/temp1_input"
                        } else if ((name === "amdgpu" || name === "nouveau" || name === "i915" || name === "xe") && root._gpuTempPath === "") {
                            root._gpuTempPath = curDir + "/temp1_input"
                        }
                        curDir = ""
                    }
                }
                if (root.isOpen) root.pollTemps()
            }
        }
    }

    FileView {
        id: cpuInfoFile
        path: "/proc/cpuinfo"
        printErrors: false
        onLoaded: root.parseCpuInfo(cpuInfoFile.text())
    }

    function parseCpuInfo(text) {
        var lines = String(text || "").split("\n")
        var model = ""
        var cores = 0
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf("model name") === 0 || lines[i].indexOf("model name\t") === 0) {
                var idx = lines[i].indexOf(":")
                if (idx > 0 && model === "") {
                    model = lines[i].substring(idx + 1).replace(/\s+\d+-Core Processor/i, "").trim()
                }
            } else if (lines[i].indexOf("processor") === 0) {
                cores++
            }
        }
        if (model !== "") root.cpuModel = model
        if (cores > 0) root.cpuCores = cores
    }

    // ── CPU / RAM: /proc (fork yok) ─────────────────────────────────
    FileView {
        id: statFile
        path: "/proc/stat"
        printErrors: false
        onLoaded: root.parseStat(statFile.text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        printErrors: false
        onLoaded: root.parseMem(memFile.text())
    }

    function parseStat(text) {
        var first = String(text || "").split("\n")[0]
        if (!first || first.indexOf("cpu") !== 0) return
        var f = first.trim().split(/\s+/)
        if (f.length < 8) return
        var total = 0
        for (var i = 1; i < 8; i++) total += parseFloat(f[i]) || 0
        var idle = (parseFloat(f[4]) || 0) + (parseFloat(f[5]) || 0)
        if (root._prevTotal > 0 && total > root._prevTotal) {
            var dTot = total - root._prevTotal
            var dIdl = idle - root._prevIdle
            if (dTot > 0)
                root.cpuPercent = Math.max(0, Math.min(100, Math.round(((dTot - dIdl) * 100) / dTot)))
        }
        root._prevTotal = total
        root._prevIdle = idle
    }

    function parseMem(text) {
        var lines = String(text || "").split("\n")
        var total = 0
        var avail = 0
        for (var i = 0; i < lines.length; i++) {
            var m
            if ((m = lines[i].match(/^MemTotal:\s+(\d+)/))) total = parseFloat(m[1])
            else if ((m = lines[i].match(/^MemAvailable:\s+(\d+)/))) avail = parseFloat(m[1])
        }
        if (total <= 0) return
        var used = total - avail
        root.memPercent = Math.round((used * 100) / total)
        root.memUsedGiB = used / 1048576
        root.memAvailGiB = avail / 1048576
        root.memTotalGiB = total / 1048576
    }

    // 2 sn: fork yok, sadece dosya okuma
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
        }
    }

    // ── Agir isler: yalnizca panel acikken ──────────────────────────
    property string gpuDeviceDir: ""

    Process {
        id: heavyProc
        running: false
        command: ["ps", "-eo", "pid=,comm=,%cpu=,rss="]
        stdout: StdioCollector { id: heavyOut }
        onExited: (code) => {
            root._lastPsText = heavyOut.text
            root.parseTop(heavyOut.text)
        }
    }

    function humanAppName(comm) {
        var c = String(comm || "").trim()
        var low = c.toLowerCase()
        if (low === "chromium" || low === "chrome" || low.indexOf("chromium-") === 0) return "Chromium"
        if (low === "antigravity-ide" || low.indexOf("antigravity") === 0) return "Antigravity IDE"
        if (low === ".quickshell-wra" || low === "quickshell") return "Enyxma Shell"
        if (low === "firefox" || low === ".firefox-wrappe") return "Firefox"
        if (low === "kitty") return "Kitty"
        if (low === "foot") return "Foot"
        if (low === "hyprland" || low.indexOf(".hyprland-wrap") === 0) return "Hyprland"
        if (low.indexOf(".blueman-tray") === 0) return "Blueman"
        if (low.indexOf(".libvirtd-wrap") === 0) return "libvirtd"
        if (low === "thunar") return "Thunar"
        if (low === "keepassxc") return "KeePassXC"
        if (low === "discord" || low === "vesktop") return "Discord"
        if (low === "obs") return "OBS Studio"
        if (low === "mpv") return "mpv"
        return c
    }

    function parseTop(text) {
        var lines = String(text || "").split("\n")
        var groups = {}
        var threadCount = Math.max(1, root.cpuCores)
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i].trim()
            if (!l) continue
            var parts = l.split(/\s+/)
            if (parts.length < 4) continue
            var pid = parts[0]
            var comm = parts[1]
            var rawCpu = parseFloat(parts[2]) || 0
            var rssKiB = parseFloat(parts[3]) || 0
            if (rawCpu <= 0 && rssKiB < 10240) continue

            var appName = root.humanAppName(comm)
            var low = comm.toLowerCase()
            var protectedApp = (low === "hyprland" || low.indexOf(".hyprland-wrap") === 0 || low === ".quickshell-wra" || low === "quickshell" || low === "systemd" || low === "dbus-daemon")

            if (!groups[appName]) {
                groups[appName] = {
                    name: appName,
                    cpu: 0,
                    rssKiB: 0,
                    pids: [],
                    canKill: !protectedApp
                }
            }
            groups[appName].cpu += (rawCpu / threadCount)
            groups[appName].rssKiB += rssKiB
            groups[appName].pids.push(pid)
            if (protectedApp) groups[appName].canKill = false
        }

        var list = []
        var keys = Object.keys(groups)
        for (var k = 0; k < keys.length; k++) {
            var g = groups[keys[k]]
            list.push({
                name: g.name,
                cpuVal: g.cpu,
                cpuText: (g.cpu >= 10 ? g.cpu.toFixed(0) : g.cpu.toFixed(1)) + "%",
                rssKiB: g.rssKiB,
                memText: root.formatMemKiB(g.rssKiB),
                pids: g.pids,
                canKill: g.canKill
            })
        }

        list.sort(function(a, b) {
            if (root.sortBy === "mem") return b.rssKiB - a.rssKiB
            return b.cpuVal - a.cpuVal
        })

        root.topProcesses = list.slice(0, 6)
    }

    function killApp(pids) {
        if (!pids || pids.length === 0 || killProc.running) return
        killProc.exec(["kill", "-TERM"].concat(pids))
    }

    Process {
        id: killProc
        running: false
        onExited: (code) => root.refreshHeavy()
    }

    // GPU & Sicaklik: yalnizca panel acikken okunur
    FileView {
        id: gpuBusyFile
        path: ""
        printErrors: false
        onLoaded: root.gpuPercent = parseInt(gpuBusyFile.text().trim()) || 0
    }

    FileView {
        id: vramUsedFile
        path: ""
        printErrors: false
        onLoaded: {
            root._vramUsedBytes = parseFloat(vramUsedFile.text().trim()) || 0
            root.vramUsedGiB = root._vramUsedBytes / 1073741824
            root.updateVramPercent()
        }
    }

    FileView {
        id: vramTotalFile
        path: ""
        printErrors: false
        onLoaded: {
            root._vramTotalBytes = parseFloat(vramTotalFile.text().trim()) || 0
            root.vramTotalGiB = root._vramTotalBytes / 1073741824
            root.updateVramPercent()
        }
    }

    FileView {
        id: cpuTempFile
        path: ""
        printErrors: false
        onLoaded: {
            var mc = parseInt(cpuTempFile.text().trim()) || 0
            if (mc > 0) root.cpuTempC = Math.round(mc / 1000)
        }
    }

    FileView {
        id: gpuTempFile
        path: ""
        printErrors: false
        onLoaded: {
            var mc = parseInt(gpuTempFile.text().trim()) || 0
            if (mc > 0) root.gpuTempC = Math.round(mc / 1000)
        }
    }

    function refreshHeavy() {
        if (!heavyProc.running) heavyProc.running = true
        if (root.gpuDeviceDir === "") gpuDetectProc.running = true
        else pollGpu()
        pollTemps()
    }

    Timer {
        interval: 2500
        running: root.isOpen && root.activeTab === "performance"
        repeat: true
        onTriggered: root.refreshHeavy()
    }

    Process {
        id: gpuDetectProc
        running: false
        command: ["find", "-L", "/sys/class/drm", "-maxdepth", "2", "-name", "device", "-type", "d"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = String(this.text || "").trim().split("\n")
                var chosen = ""
                for (var i = 0; i < lines.length; i++) {
                    var cand = lines[i].trim()
                    if (/^\/sys\/class\/drm\/card\d+\/device$/.test(cand)) {
                        chosen = cand
                        if (cand.indexOf("card0") < 0) break
                    }
                }
                if (chosen !== "") {
                    root.gpuDeviceDir = chosen
                    root.pollGpu()
                }
            }
        }
    }

    function pollGpu() {
        if (root.gpuDeviceDir === "") return
        gpuBusyFile.path = root.gpuDeviceDir + "/gpu_busy_percent"
        vramUsedFile.path = root.gpuDeviceDir + "/mem_info_vram_used"
        vramTotalFile.path = root.gpuDeviceDir + "/mem_info_vram_total"
        gpuBusyFile.reload()
        vramUsedFile.reload()
        vramTotalFile.reload()
    }

    function pollTemps() {
        if (root._cpuTempPath !== "") {
            cpuTempFile.path = root._cpuTempPath
            cpuTempFile.reload()
        }
        if (root._gpuTempPath !== "") {
            gpuTempFile.path = root._gpuTempPath
            gpuTempFile.reload()
        }
    }

    IpcHandler {
        target: "performance"
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function refresh(): void { root.refreshHeavy() }
    }
}
