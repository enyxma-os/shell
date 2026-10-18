pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isOpen: false
    property string mode: "screenshots" // "screenshots" or "videos"
    property var items: []
    property bool isScanning: false
    property string toastText: ""

    Timer {
        id: toastTimer
        interval: 2200
        repeat: false
        onTriggered: root.toastText = ""
    }

    function showToast(msg) {
        toastText = msg
        toastTimer.restart()
    }

    function toggle(targetMode) {
        var m = targetMode || "screenshots"
        if (isOpen && mode === m) {
            isOpen = false
            return
        }
        mode = m
        isOpen = true
        scanMedia()
    }

    function open(targetMode) {
        mode = targetMode || "screenshots"
        isOpen = true
        scanMedia()
    }

    function close() {
        isOpen = false
    }

    function formatLabel(path) {
        if (!path) return ""
        var name = String(path).split("/").pop().replace(/\.[^.]+$/, "")
        // 2026_10_18_11_30_42_screenshot veya 20261018_113042 formatlarını yakala
        var m1 = name.match(/(\d{4})_(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})/)
        if (m1) {
            return m1[1] + "-" + m1[2] + "-" + m1[3] + "  " + m1[4] + ":" + m1[5] + ":" + m1[6]
        }
        var m2 = name.match(/(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/)
        if (m2) {
            return m2[1] + "-" + m2[2] + "-" + m2[3] + "  " + m2[4] + ":" + m2[5] + ":" + m2[6]
        }
        return name
    }

    // Taramayı gerçekleştiren süreç
    Process {
        id: scanProc
        command: []
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.isScanning = false
                var lines = this.text.split("\n")
                var res = []
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim()
                    if (!p) continue
                    var fn = p.substring(p.lastIndexOf("/") + 1)
                    if (seen[p]) continue
                    seen[p] = true
                    res.push({
                        filePath: "file://" + p,
                        rawPath: p,
                        fileName: fn,
                        label: root.formatLabel(p),
                        isVideo: root.mode === "videos"
                    })
                }
                root.items = res
            }
        }
    }

    function scanMedia() {
        if (isScanning) return
        isScanning = true
        if (mode === "videos") {
            scanProc.command = [
                "bash", "-c",
                "DIRS=(\"$HOME/Videos/Recordings\" \"$HOME/Videos\"); " +
                "for d in \"${DIRS[@]}\"; do " +
                "  [ -d \"$d\" ] || continue; " +
                "  find \"$d\" -maxdepth 1 -type f " +
                "  \\( -iname \x27*.mp4\x27 -o -iname \x27*.mkv\x27 -o -iname \x27*.webm\x27 -o -iname \x27*.mov\x27 \\) " +
                "  -printf \x27%T@\\t%p\\n\x27 2>/dev/null; " +
                "done | sort -rn | head -100 | cut -f2-"
            ]
        } else {
            scanProc.command = [
                "bash", "-c",
                "DIRS=(\"$HOME/Pictures/Screenshots\" \"$HOME/Pictures\"); " +
                "for d in \"${DIRS[@]}\"; do " +
                "  [ -d \"$d\" ] || continue; " +
                "  find \"$d\" -maxdepth 1 -type f " +
                "  \\( -iname \x27*.png\x27 -o -iname \x27*.jpg\x27 -o -iname \x27*.jpeg\x27 -o -iname \x27*.webp\x27 \\) " +
                "  -printf \x27%T@\\t%p\\n\x27 2>/dev/null; " +
                "done | sort -rn | head -100 | cut -f2-"
            ]
        }
        scanProc.running = false
        scanProc.running = true
    }

    // Dosyayı sistemin varsayılan uygulamasıyla aç
    Process {
        id: openProc
        command: []
    }
    function openItem(path) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        openProc.command = ["xdg-open", p]
        openProc.running = false
        openProc.running = true
        root.close()
    }

    // Panoya kopyalama
    Process {
        id: copyProc
        command: []
        onExited: function(code) {
            if (code === 0) {
                root.showToast("Panoya kopyalandı! 📋")
            } else {
                root.showToast("Kopyalanamadı (wl-copy gerekli)")
            }
        }
    }
    function copyItem(path, isVideo) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        if (isVideo) {
            copyProc.command = ["bash", "-c", "printf \x27%s\x27 \x22" + p + "\x22 | wl-copy"]
        } else {
            copyProc.command = ["bash", "-c", "wl-copy --type image/png < \x22" + p + "\x22"]
        }
        copyProc.running = false
        copyProc.running = true
    }

    // Çöp kutusuna taşıma
    Process {
        id: deleteProc
        command: []
        onExited: function(code) {
            root.showToast("Dosya silindi 🗑️")
            root.scanMedia()
        }
    }
    function deleteItem(path) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        deleteProc.command = ["bash", "-c", "gio trash -- \x22" + p + "\x22 2>/dev/null || trash-put -- \x22" + p + "\x22 2>/dev/null || rm -f -- \x22" + p + "\x22"]
        deleteProc.running = false
        deleteProc.running = true
    }

    IpcHandler {
        target: "media-browser"

        function screenshots(): void {
            root.open("screenshots")
        }

        function videos(): void {
            root.open("videos")
        }

        function toggle(): void {
            root.toggle(root.mode)
        }

        function close(): void {
            root.close()
        }
    }

    IpcHandler {
        target: "screenshots"

        function open(): void {
            root.open("screenshots")
        }

        function toggle(): void {
            root.toggle("screenshots")
        }
    }

    Component.onCompleted: {
        root.scanMedia()
    }
}
