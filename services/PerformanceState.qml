pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Pop-up Paneli Durumu
    property bool isOpen: false

    function toggle(): void {
        root.isOpen = !root.isOpen
    }

    function open(): void {
        root.isOpen = true
    }

    function close(): void {
        root.isOpen = false
    }

    function openBtop(): void {
        root.close()
        Quickshell.execDetached(["foot", "btop"])
    }

    // CPU Metrikleri
    property int cpuPercent: 0
    property string cpuModel: "İşlemci"
    property int cpuCores: 0
    property string kernel: ""
    property string load1: "0.00"
    property string load5: "0.00"
    property string load15: "0.00"
    property var topProcesses: []

    // RAM Metrikleri
    property int memPercent: 0
    property real memUsedGiB: 0.0
    property real memAvailGiB: 0.0
    property real memTotalGiB: 0.0

    // GPU & VRAM Metrikleri
    property int gpuPercent: 0
    property string gpuModel: "Ekran Kartı"
    property int vramPercent: 0
    property real vramUsedGiB: 0.0
    property real vramTotalGiB: 0.0

    // Dahili CPU zaman damgası takibi
    property real _prevTotal: 0
    property real _prevIdle: 0

    // Statik sistem bilgilerini al (İşlemci Modeli, Çekirdek, Kernel, Ekran Kartı Modeli)
    Process {
        id: staticInfoProc
        command: ["bash", "-c", "uname -r && awk -F: '/model name/ {m=$2; gsub(/^[ \t]+/, \"\", m); if (!found) {name=m; found=1}} /processor/ {cores++} END {printf \"%s|%d\\n\", name, cores}' /proc/cpuinfo && (lspci 2>/dev/null | awk -F: '/VGA|3D/ {gsub(/^[ \t]+/, \"\", $3); print $3; exit}' || echo \"Ekran Kartı\")"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 2) {
                    root.kernel = lines[0].trim()
                    var parts = lines[1].split("|")
                    if (parts.length >= 2) {
                        root.cpuModel = parts[0].trim()
                        root.cpuCores = parseInt(parts[1]) || 0
                    }
                }
                if (lines.length >= 3) {
                    var rawGpu = lines[2].trim()
                    if (rawGpu.indexOf("[") !== -1 && rawGpu.indexOf("]") !== -1) {
                        var matches = rawGpu.match(/\[([^\]]+)\]/g)
                        if (matches && matches.length > 0) {
                            root.gpuModel = matches[matches.length - 1].replace(/[\[\]]/g, "")
                        } else {
                            root.gpuModel = rawGpu
                        }
                    } else {
                        root.gpuModel = rawGpu.replace(/\(rev .*\)/, "").trim()
                    }
                }
            }
        }
    }

    // Telemetri Process: CPU tick, Meminfo, Loadavg, En çok tüketen işlemler, GPU ve VRAM
    Process {
        id: telemetryProc
        command: ["bash", "-c", "LC_ALL=C awk 'BEGIN { while ((getline < \"/proc/stat\") > 0) { if ($1 == \"cpu\") { printf \"%d|%d|\", $2+$3+$4+$5+$6+$7+$8+$9, $5+$6; break } } close(\"/proc/stat\"); getline < \"/proc/loadavg\"; load1=$1; load5=$2; load15=$3; close(\"/proc/loadavg\"); while ((getline < \"/proc/meminfo\") > 0) { if ($1 == \"MemTotal:\") total=$2; else if ($1 == \"MemAvailable:\") avail=$2 } close(\"/proc/meminfo\"); used = total - avail; pct = (total > 0) ? int((used * 100) / total) : 0; printf \"%d|%.1f|%.1f|%.1f|%s|%s|%s\\n\", pct, used/1048576, avail/1048576, total/1048576, load1, load5, load15 }'; ps -eo comm,%cpu --sort=-%cpu --no-headers 2>/dev/null | head -n 3 | awk '{printf \"%s|%s;\", $1, $2}'; echo \"\"; dev=$(ls -d /sys/class/drm/card[1-9]/device 2>/dev/null | head -n1); [ -z \"$dev\" ] && dev=$(ls -d /sys/class/drm/card0/device 2>/dev/null | head -n1); gpu=$(cat \"$dev/gpu_busy_percent\" 2>/dev/null || echo 0); u=$(cat \"$dev/mem_info_vram_used\" 2>/dev/null || echo 0); t=$(cat \"$dev/mem_info_vram_total\" 2>/dev/null || echo 0); awk -v g=\"$gpu\" -v u=\"$u\" -v t=\"$t\" 'BEGIN { if (t > 0) printf \"%d|%d|%.1f|%.1f\\n\", g, (u/t)*100, u/1073741824, t/1073741824; else printf \"%d|0|0.0|0.0\\n\", g }'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (!raw) return
                var lines = raw.split("\n")
                if (lines.length >= 1) {
                    var parts = lines[0].split("|")
                    if (parts.length >= 9) {
                        var tot = parseFloat(parts[0])
                        var idl = parseFloat(parts[1])
                        if (root._prevTotal > 0 && tot > root._prevTotal) {
                            var dTot = tot - root._prevTotal
                            var dIdl = idl - root._prevIdle
                            var pct = Math.max(0, Math.min(100, Math.round(((dTot - dIdl) * 100) / dTot)))
                            root.cpuPercent = pct
                        }
                        root._prevTotal = tot
                        root._prevIdle = idl

                        root.memPercent = parseInt(parts[2]) || 0
                        root.memUsedGiB = parseFloat(parts[3]) || 0.0
                        root.memAvailGiB = parseFloat(parts[4]) || 0.0
                        root.memTotalGiB = parseFloat(parts[5]) || 0.0
                        root.load1 = parts[6] || "0.00"
                        root.load5 = parts[7] || "0.00"
                        root.load15 = parts[8] || "0.00"
                    }
                }
                if (lines.length >= 2) {
                    var procEntries = lines[1].split(";")
                    var list = []
                    for (var i = 0; i < procEntries.length; i++) {
                        var pe = procEntries[i].trim()
                        if (!pe) continue
                        var pParts = pe.split("|")
                        if (pParts.length >= 2) {
                            list.push({
                                name: pParts[0],
                                cpu: pParts[1] + "%"
                            })
                        }
                    }
                    root.topProcesses = list
                }
                if (lines.length >= 3) {
                    var gpuParts = lines[2].split("|")
                    if (gpuParts.length >= 4) {
                        root.gpuPercent = parseInt(gpuParts[0]) || 0
                        root.vramPercent = parseInt(gpuParts[1]) || 0
                        root.vramUsedGiB = parseFloat(gpuParts[2]) || 0.0
                        root.vramTotalGiB = parseFloat(gpuParts[3]) || 0.0
                    }
                }
            }
        }
    }

    // Telemetri Timer: Panel açıkken 1.5 saniyede bir, kapalıyken 3 saniyede bir güncelle
    Timer {
        id: pollTimer
        interval: root.isOpen ? 1500 : 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!telemetryProc.running) {
                telemetryProc.running = true
            }
        }
    }

    IpcHandler {
        target: "performance"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function btop(): void { root.openBtop() }
    }
}
