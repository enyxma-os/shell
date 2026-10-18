pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Panel Görünürlük Durumu
    property bool isOpen: false

    function toggle() {
        isOpen = !isOpen
        if (isOpen)
            refresh()
    }

    function open() {
        isOpen = true
        refresh()
    }

    function close() {
        isOpen = false
    }

    function refresh() {
        telemetryProc.running = false
        telemetryProc.running = true
        inventoryProc.running = false
        inventoryProc.running = true
    }

    // Kök (Root) Dosya Sistemi Metrikleri
    property int rootPercent: 0
    property real rootUsedBytes: 0
    property real rootTotalBytes: 0
    readonly property real rootUsedGiB: rootUsedBytes / 1073741824
    readonly property real rootTotalGiB: rootTotalBytes / 1073741824
    readonly property real rootFreeGiB: Math.max(0, rootTotalGiB - rootUsedGiB)
    property bool isAvailable: false

    // Fiziksel Sürücüler (Drives) Listesi
    property var drives: []
    readonly property int driveCount: drives.length

    function formatCapacity(bytes) {
        var value = Number(bytes) || 0
        if (value >= 1000000000000)
            return (value / 1000000000000).toFixed(value >= 10000000000000 ? 0 : 1) + " TB"
        if (value >= 1000000000)
            return (value / 1000000000).toFixed(value >= 100000000000 ? 0 : 1) + " GB"
        return (value / 1000000).toFixed(0) + " MB"
    }

    function formatFree(bytes) {
        var value = Number(bytes) || 0
        if (value >= 1099511627776)
            return (value / 1099511627776).toFixed(1) + " TiB free"
        return (value / 1073741824).toFixed(1) + " GiB free"
    }

    function driveTypeIcon(driveType) {
        if (driveType === "nvme") return "󰢮"
        if (driveType === "ssd") return "󰭳"
        return "󰋊"
    }

    // Kök dosya sistemi kullanımı sorgusu
    Process {
        id: telemetryProc
        command: ["bash", "-c", "LC_ALL=C df -P -B1 / 2>/dev/null | awk 'NR == 2 { gsub(/%/, \"\", $5); printf \"%s|%s|%s\\n\", $5, $3, $2 }'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var fields = this.text.trim().split("|")
                if (fields.length >= 3) {
                    var pct = parseInt(fields[0])
                    var used = parseFloat(fields[1])
                    var total = parseFloat(fields[2])
                    if (!isNaN(pct) && !isNaN(used) && !isNaN(total) && total > 0) {
                        root.rootPercent = Math.max(0, Math.min(100, pct))
                        root.rootUsedBytes = Math.max(0, used)
                        root.rootTotalBytes = Math.max(0, total)
                        root.isAvailable = true
                    }
                }
            }
        }
    }

    // Fiziksel sürücü ve bölüm envanteri (lsblk JSON)
    Process {
        id: inventoryProc
        command: ["lsblk", "-J", "-b", "-o", "NAME,PATH,TYPE,SIZE,FSTYPE,FSUSED,FSAVAIL,FSUSE%,MOUNTPOINTS,MODEL,TRAN,ROTA,RM,HOTPLUG"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (!raw) return
                var parsed
                try {
                    parsed = JSON.parse(raw)
                } catch (e) {
                    return
                }

                var devices = parsed && parsed.blockdevices ? parsed.blockdevices : []
                var list = []

                function textValue(val) {
                    return val === null || val === undefined ? "" : String(val).trim()
                }

                function collectVolumes(node, target) {
                    var fs = textValue(node.fstype)
                    var mounts = node.mountpoints || []
                    var mountedAt = ""
                    for (var m = 0; m < mounts.length; m++) {
                        var cand = textValue(mounts[m])
                        if (cand === "/") {
                            mountedAt = "/"
                            break
                        }
                        if (mountedAt === "" && cand !== "" && cand !== "[SWAP]") {
                            mountedAt = cand
                        }
                    }
                    if (fs !== "") {
                        var pctStr = textValue(node["fsuse%"]).replace("%", "")
                        var pct = parseInt(pctStr)
                        var freeB = textValue(node.fsavail) === "" ? -1 : Number(node.fsavail)
                        var usedB = textValue(node.fsused) === "" ? -1 : Number(node.fsused)
                        target.push({
                            fs: fs,
                            mount: mountedAt,
                            percent: isNaN(pct) ? -1 : Math.max(0, Math.min(100, pct)),
                            freeBytes: isNaN(freeB) ? -1 : Math.max(0, freeB),
                            usedBytes: isNaN(usedB) ? -1 : Math.max(0, usedB)
                        })
                    }
                    var children = node.children || []
                    for (var c = 0; c < children.length; c++)
                        collectVolumes(children[c], target)
                }

                for (var i = 0; i < devices.length; i++) {
                    var dev = devices[i]
                    var name = textValue(dev.name)
                    if (dev.type !== "disk" || (Number(dev.size) || 0) <= 0
                            || name.indexOf("loop") === 0
                            || name.indexOf("ram") === 0
                            || name.indexOf("zram") === 0
                            || name.indexOf("nbd") === 0)
                        continue

                    var volumes = []
                    collectVolumes(dev, volumes)
                    var fsList = []
                    var primaryMount = ""
                    var usage = -1
                    var freeBytes = -1
                    var usedBytes = -1

                    for (var v = 0; v < volumes.length; v++) {
                        if (fsList.indexOf(volumes[v].fs) < 0)
                            fsList.push(volumes[v].fs)
                        // Kök dizini öncelikli al
                        if (volumes[v].mount === "/" || (primaryMount !== "/" && primaryMount === "" && volumes[v].mount !== "")) {
                            primaryMount = volumes[v].mount
                            usage = volumes[v].percent
                            freeBytes = volumes[v].freeBytes
                            usedBytes = volumes[v].usedBytes
                        } else if (volumes[v].mount === "/") {
                            primaryMount = "/"
                            usage = volumes[v].percent
                            freeBytes = volumes[v].freeBytes
                            usedBytes = volumes[v].usedBytes
                        }
                    }

                    var tran = textValue(dev.tran).toUpperCase()
                    var removable = dev.rm === true || dev.hotplug === true || tran === "USB"
                    var driveType = tran === "NVME" ? "nvme" : (dev.rota === true ? "hdd" : "ssd")
                    var media = removable ? "USB DRIVE"
                        : tran === "NVME" ? "NVME SSD"
                        : dev.rota === true ? (tran !== "" ? tran + " HDD" : "HDD")
                        : (tran !== "" ? tran + " SSD" : "SSD")
                    var state = primaryMount !== "" ? primaryMount
                        : (fsList.length > 0 ? "Bağlı değil" : "Dosya sistemi yok")

                    list.push({
                        name: name,
                        model: textValue(dev.model) || name,
                        size: Number(dev.size) || 0,
                        driveType: driveType,
                        media: media,
                        fileSystems: fsList.join(" + ").toUpperCase(),
                        state: state,
                        percent: usage,
                        freeBytes: freeBytes,
                        usedBytes: usedBytes
                    })
                }

                root.drives = list
            }
        }
    }

    // 30 saniyelik hafif periyodik yenileme
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "storage"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function refresh(): void { root.refresh() }
    }
}
