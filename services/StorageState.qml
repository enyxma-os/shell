pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    // Birlesik Sistem paneli uzerinden yonetilir
    readonly property bool isOpen: PerformanceState.isOpen && PerformanceState.activeTab === "storage"

    function toggle() {
        PerformanceState.toggleTab("storage")
    }

    function open() {
        PerformanceState.openTab("storage")
    }

    function close() {
        if (PerformanceState.activeTab === "storage") {
            PerformanceState.close()
        }
    }

    function refresh() {
        telemetryProc.exec(["df", "-PT", "-B1"])
        inventoryProc.exec(["lsblk", "-J", "-b", "-o",
            "NAME,PATH,TYPE,SIZE,FSTYPE,FSUSED,FSAVAIL,FSUSE%,MOUNTPOINTS,MODEL,TRAN,ROTA,RM,HOTPLUG"])
    }

    function refreshLight() {
        telemetryProc.exec(["df", "-PT", "-B1"])
    }

    // Ana fiziksel dosya sistemi metrikleri
    property int rootPercent: 0
    property real rootUsedBytes: 0
    property real rootTotalBytes: 0
    property string rootMount: "/"
    property string rootFsType: ""
    readonly property real rootUsedGiB: rootUsedBytes / 1073741824
    readonly property real rootTotalGiB: rootTotalBytes / 1073741824
    readonly property real rootFreeGiB: Math.max(0, rootTotalGiB - rootUsedGiB)
    property bool isAvailable: false

    // Fiziksel suruculer listesi
    property var drives: []
    readonly property int driveCount: drives.length

    // Surucu aksiyon durumu
    property bool actionBusy: false
    property string actionError: ""
    property string _pendingEjectDisk: ""

    function formatCapacity(bytes) {
        var value = Number(bytes) || 0
        if (value >= 1000000000000)
            return (value / 1000000000000).toFixed(value >= 10000000000000 ? 0 : 1) + " TB"
        if (value >= 1000000000)
            return (value / 1000000000).toFixed(value >= 100000000000 ? 0 : 1) + " GB"
        return (value / 1000000).toFixed(0) + " MB"
    }

    function formatFree(bytes) {
        var _l = I18n.lang
        var value = Number(bytes) || 0
        if (value >= 1099511627776)
            return (value / 1099511627776).toFixed(1) + I18n.t(" TiB boş", " TiB free")
        return (value / 1073741824).toFixed(1) + I18n.t(" GiB boş", " GiB free")
    }

    function driveTypeIcon(driveType) {
        if (driveType === "nvme") return "󰢮"
        if (driveType === "ssd") return "󰭳"
        return "󰋊"
    }

    function openMount(path) {
        if (!path || String(path).length === 0) return
        Quickshell.execDetached(["enyxma-launch", "xdg-open", String(path)])
    }

    function mountDrive(partPath) {
        if (!partPath || root.actionBusy) return
        root.actionBusy = true
        root.actionError = ""
        root._pendingEjectDisk = ""
        driveActionProc.exec(["udisksctl", "mount", "-b", String(partPath)])
    }

    function unmountDrive(partPath) {
        if (!partPath || root.actionBusy) return
        root.actionBusy = true
        root.actionError = ""
        root._pendingEjectDisk = ""
        driveActionProc.exec(["udisksctl", "unmount", "-b", String(partPath)])
    }

    function ejectDrive(diskPath, partPath) {
        if (!diskPath || root.actionBusy) return
        root.actionBusy = true
        root.actionError = ""
        if (partPath && String(partPath).length > 0) {
            root._pendingEjectDisk = String(diskPath)
            driveActionProc.exec(["udisksctl", "unmount", "-b", String(partPath)])
        } else {
            root._pendingEjectDisk = ""
            driveActionProc.exec(["udisksctl", "power-off", "-b", String(diskPath)])
        }
    }

    Process {
        id: driveActionProc
        running: false
        stderr: StdioCollector { id: driveActionErr }
        onExited: (code, status) => {
            if (code === 0 && root._pendingEjectDisk !== "") {
                var disk = root._pendingEjectDisk
                root._pendingEjectDisk = ""
                driveActionProc.exec(["udisksctl", "power-off", "-b", disk])
                return
            }
            root._pendingEjectDisk = ""
            root.actionBusy = false
            if (code === 0) {
                root.actionError = ""
                root.refresh()
            } else {
                var msg = (driveActionErr.text || "").trim()
                root.actionError = msg !== "" ? msg.split("\n")[0] : (I18n.t("Sürücü işlemi başarısız, kod ", "Drive action failed, code ") + code)
            }
        }
    }

    // Ana fiziksel dosya sistemi sorgusu (tmpfs / impermanence uyumlu)
    Process {
        id: telemetryProc
        command: ["df", "-PT", "-B1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = String(this.text || "").trim().split("\n")
                if (lines.length < 2) return
                var byMount = {}
                for (var i = 1; i < lines.length; i++) {
                    var f = lines[i].trim().split(/\s+/)
                    if (f.length < 7) continue
                    var fstype = f[1]
                    var total = parseFloat(f[2])
                    var used = parseFloat(f[3])
                    var pct = parseInt(String(f[5]).replace("%", ""))
                    var mnt = f.slice(6).join(" ")
                    if (isNaN(total) || total <= 0 || isNaN(used) || isNaN(pct)) continue
                    byMount[mnt] = {
                        fs: fstype,
                        total: total,
                        used: used,
                        pct: Math.max(0, Math.min(100, pct)),
                        mount: mnt
                    }
                }
                var chosen = byMount["/"] || null
                if (chosen && (chosen.fs === "tmpfs" || chosen.fs === "overlay" || chosen.fs === "ramfs" || chosen.fs === "devtmpfs")) {
                    var fallbacks = ["/persist", "/nix", "/home"]
                    for (var k = 0; k < fallbacks.length; k++) {
                        var cand = byMount[fallbacks[k]]
                        if (cand && cand.fs !== "tmpfs" && cand.fs !== "overlay" && cand.fs !== "ramfs") {
                            chosen = cand
                            break
                        }
                    }
                }
                if (chosen) {
                    root.rootPercent = chosen.pct
                    root.rootUsedBytes = Math.max(0, chosen.used)
                    root.rootTotalBytes = Math.max(0, chosen.total)
                    root.rootMount = chosen.mount
                    root.rootFsType = chosen.fs
                    root.isAvailable = true
                }
            }
        }
    }

    // Fiziksel surucu ve bolum envanteri (lsblk JSON)
    Process {
        id: inventoryProc
        command: ["lsblk", "-J", "-b", "-o", "NAME,PATH,TYPE,SIZE,FSTYPE,FSUSED,FSAVAIL,FSUSE%,MOUNTPOINTS,MODEL,TRAN,ROTA,RM,HOTPLUG"]
        running: false
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

                function isTruthy(val) {
                    if (val === true) return true
                    var s = textValue(val).toLowerCase()
                    return s === "1" || s === "true" || s === "yes"
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
                        if (cand !== "" && cand !== "[SWAP]") {
                            // /persist veya /home gibi ana baglama noktalarini /boot'a tercih et
                            if (mountedAt === "" || mountedAt === "/boot" || mountedAt === "/boot/efi") {
                                mountedAt = cand
                            }
                        }
                    }
                    if (fs !== "") {
                        var pctStr = textValue(node["fsuse%"]).replace("%", "")
                        var pct = parseInt(pctStr)
                        var freeB = textValue(node.fsavail) === "" ? -1 : Number(node.fsavail)
                        var usedB = textValue(node.fsused) === "" ? -1 : Number(node.fsused)
                        target.push({
                            path: textValue(node.path),
                            size: Number(node.size) || 0,
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
                    var primaryVol = null
                    var fallbackBoot = null
                    var firstMountable = null

                    for (var v = 0; v < volumes.length; v++) {
                        var vol = volumes[v]
                        if (fsList.indexOf(vol.fs) < 0)
                            fsList.push(vol.fs)
                        if (!firstMountable && vol.fs !== "swap" && vol.path !== "") {
                            firstMountable = vol
                        }
                        if (vol.mount === "/") {
                            primaryVol = vol
                        } else if (vol.mount !== "" && vol.mount !== "/boot" && vol.mount !== "/boot/efi") {
                            if (!primaryVol || (primaryVol.mount !== "/" && vol.size > primaryVol.size)) {
                                primaryVol = vol
                            }
                        } else if (vol.mount === "/boot" || vol.mount === "/boot/efi") {
                            if (!fallbackBoot) fallbackBoot = vol
                        }
                    }

                    var chosenVol = primaryVol || fallbackBoot || firstMountable
                    var primaryMount = chosenVol ? chosenVol.mount : ""
                    var usage = (chosenVol && primaryMount !== "") ? chosenVol.percent : -1
                    var freeBytes = (chosenVol && primaryMount !== "") ? chosenVol.freeBytes : -1
                    var usedBytes = (chosenVol && primaryMount !== "") ? chosenVol.usedBytes : -1
                    var partPath = chosenVol ? chosenVol.path : ""

                    // Ana sistem diskiyle (df) ayni Btrfs/kok havuzunu tutarli kil
                    if (root.isAvailable && primaryMount !== "" &&
                        (primaryMount === root.rootMount || primaryMount === "/home" || primaryMount === "/nix" || primaryMount === "/persist")) {
                        usage = root.rootPercent
                        freeBytes = Math.max(0, root.rootTotalBytes - root.rootUsedBytes)
                        usedBytes = root.rootUsedBytes
                    }

                    var tran = textValue(dev.tran).toUpperCase()
                    var removable = isTruthy(dev.rm) || isTruthy(dev.hotplug) || tran === "USB"
                    var rotational = isTruthy(dev.rota)
                    var driveType = tran === "NVME" ? "nvme" : (rotational ? "hdd" : "ssd")
                    var media = removable ? "USB DRIVE"
                        : tran === "NVME" ? "NVME SSD"
                        : rotational ? (tran !== "" ? tran + " HDD" : "HDD")
                        : (tran !== "" ? tran + " SSD" : "SSD")
                    var state = primaryMount !== "" ? primaryMount
                        : (fsList.length > 0 ? I18n.t("Bağlı değil", "Not mounted") : I18n.t("Dosya sistemi yok", "No filesystem"))

                    list.push({
                        name: name,
                        diskPath: textValue(dev.path),
                        partPath: partPath,
                        model: textValue(dev.model) || name,
                        size: Number(dev.size) || 0,
                        driveType: driveType,
                        media: media,
                        fileSystems: fsList.join(" + ").toUpperCase(),
                        state: state,
                        mountPoint: primaryMount,
                        mounted: primaryMount !== "",
                        removable: removable,
                        percent: usage,
                        freeBytes: freeBytes,
                        usedBytes: usedBytes
                    })
                }

                root.drives = list
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.isOpen) root.refresh()
            else root.refreshLight()
        }
    }

    IpcHandler {
        target: "storage"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function refresh(): void { root.refresh() }
    }
}
