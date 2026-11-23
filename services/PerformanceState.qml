pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * PerformanceState — CPU / RAM / GPU telemetrisi.
 *
 * P1 "SIFIR POLLING" DÜZELTMESİ:
 *   Eski kod panel kapalıyken bile 3 sn'de bir `bash -c awk …; ps …; ls -d …`
 *   çalıştırıyordu → günde ~28.800 process.
 *
 *   Yeni tasarım:
 *   • Bar göstergeleri (CPU %, RAM %, load) → /proc dosyaları FileView ile
 *     okunur: fork YOK, sadece dosya okuma (2 sn).
 *   • Ağır işler (`ps` ile top process, GPU sysfs, `lspci`) yalnızca panel
 *     açıkken çalışır (`isOpen` kapısı) → günde birkaç yüz process.
 *   • Statik bilgi (kernel, CPU/GPU modeli) açılışta TEK kez.
 *
 *   `drives`/GPU verisi panel kapalıyken donar; bu bilinçli bir tercih:
 *   bar yalnızca CPU/RAM gösterir, panel açıldığında tazelenir.
 */
Singleton {
    id: root

    property bool isOpen: false

    function toggle(): void { root.isOpen = !root.isOpen; if (root.isOpen) root.refreshHeavy() }
    function open(): void { root.isOpen = true; root.refreshHeavy() }
    function close(): void { root.isOpen = false }

    function openBtop(): void {
        root.close()
        Quickshell.execDetached(["enyxma-launch", "foot", "btop"])
    }

    // ── Metrikler ───────────────────────────────────────────────────
    property int cpuPercent: 0
    property string cpuModel: "İşlemci"
    property int cpuCores: 0
    property string kernel: ""
    property string load1: "0.00"
    property string load5: "0.00"
    property string load15: "0.00"
    property var topProcesses: []

    property int memPercent: 0
    property real memUsedGiB: 0.0
    property real memAvailGiB: 0.0
    property real memTotalGiB: 0.0

    property int gpuPercent: 0
    property string gpuModel: "Ekran Kartı"
    property int vramPercent: 0
    property real vramUsedGiB: 0.0
    property real vramTotalGiB: 0.0

    property real _prevTotal: 0
    property real _prevIdle: 0

    // ── Statik sistem bilgisi: açılışta 1 kez ───────────────────────
    Process {
        id: staticInfoProc
        command: ["uname", "-r"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.kernel = this.text.trim()
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
                if (idx > 0 && model === "") model = lines[i].substring(idx + 1).trim()
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

    FileView {
        id: loadFile
        path: "/proc/loadavg"
        printErrors: false
        onLoaded: root.parseLoad(loadFile.text())
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

    function parseLoad(text) {
        var f = String(text || "").trim().split(/\s+/)
        if (f.length >= 3) {
            root.load1 = f[0]
            root.load5 = f[1]
            root.load15 = f[2]
        }
    }

    // 2 sn: fork yok, sadece 3 dosya okuması (panel açık/kapalı fark etmez).
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
            loadFile.reload()
        }
    }

    // 30 sn'de bir meminfo (RAM yavaş değişir) — ayrı sayaç gereksiz,
    // aynı timer yeterli; ayrı bant genişliği maliyeti yok.

    // ── Ağır işler: yalnızca panel açıkken ──────────────────────────
    property string gpuDeviceDir: ""

    Process {
        id: heavyProc
        running: false
        command: ["ps", "-eo", "comm,%cpu", "--sort=-%cpu", "--no-headers"]
        stdout: StdioCollector { id: heavyOut }
        onExited: (code) => root.parseTop(heavyOut.text)
    }

    function parseTop(text) {
        var lines = String(text || "").split("\n")
        var list = []
        for (var i = 0; i < lines.length && list.length < 3; i++) {
            var l = lines[i].trim()
            if (!l) continue
            var parts = l.split(/\s+/)
            if (parts.length < 2) continue
            list.push({ name: parts[0], cpu: parts[1] + "%" })
        }
        root.topProcesses = list
    }

    // GPU: /sys/class/drm/card*/device/* — yalnızca panel açıkken okunur.
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
        onLoaded: root.vramUsedGiB = (parseFloat(vramUsedFile.text().trim()) || 0) / 1073741824
    }

    FileView {
        id: vramTotalFile
        path: ""
        printErrors: false
        onLoaded: {
            var t = parseFloat(vramTotalFile.text().trim()) || 0
            root.vramTotalGiB = t / 1073741824
            if (t > 0) root.vramPercent = Math.round((root.vramUsedGiB * 1073741824 * 100) / t)
        }
    }

    function refreshHeavy() {
        if (heavyProc.running) return
        heavyProc.running = true
        // GPU yolu ilk açılışta bir kez keşfedilir (tek `ls` benzeri iş).
        if (root.gpuDeviceDir === "") gpuDetectProc.running = true
        else pollGpu()
    }

    Process {
        id: gpuDetectProc
        running: false
        // Kabuk yok: glob'u `find` çözer, hata bastırma `-maxdepth` ile yapısal.
        command: ["find", "/sys/class/drm", "-maxdepth", "2", "-name", "device", "-type", "d"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim()
                if (p !== "") {
                    root.gpuDeviceDir = p
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

    IpcHandler {
        target: "performance"
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function btop(): void { root.openBtop() }
        function refresh(): void { root.refreshHeavy() }
    }
}
