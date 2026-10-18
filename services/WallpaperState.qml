pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string currentWallpaper: ""
    property real dimLevel: 0.0
    property bool pickerVisible: false
    property var wallpapers: []
    property bool isScanning: false

    function togglePicker() {
        pickerVisible = !pickerVisible
        if (pickerVisible && wallpapers.length === 0) {
            scanWallpapers()
        }
    }

    function openPicker() {
        pickerVisible = true
        if (wallpapers.length === 0) {
            scanWallpapers()
        }
    }

    function closePicker() {
        pickerVisible = false
    }

    function formatLabel(fileName) {
        if (!fileName) return ""
        var name = String(fileName).replace(/\.[^/.]+$/, "")
        name = name.replace(/^enyxma[-_]/i, "")
        return name.replace(/[-_]+/g, " ").replace(/\b\w/g, function(m) {
            return m.toUpperCase()
        })
    }

    function setWallpaper(path) {
        if (!path || String(path).trim().length === 0) {
            currentWallpaper = ""
            saveState()
            return
        }
        var p = String(path).trim()
        if (!p.startsWith("file://") && !p.startsWith("http://") && !p.startsWith("https://") && !p.startsWith("qrc:/")) {
            p = "file://" + p
        }
        currentWallpaper = p
        saveState()
    }

    function setDim(level) {
        dimLevel = Math.max(0.0, Math.min(1.0, level))
    }

    FileView {
        id: stateFile
        path: Quickshell.statePath("wallpaper.json")
        printErrors: false
        onLoaded: root.loadState()
    }

    function loadState() {
        try {
            var raw = stateFile.text()
            if (raw && raw.trim().length > 0) {
                var data = JSON.parse(raw)
                if (data && typeof data === "object") {
                    if (typeof data.wallpaper === "string" && data.wallpaper.trim().length > 0) {
                        root.currentWallpaper = data.wallpaper.trim()
                    }
                    if (typeof data.dimLevel === "number") {
                        root.dimLevel = Math.max(0.0, Math.min(1.0, data.dimLevel))
                    }
                }
            }
        } catch (e) {
            console.warn("WallpaperState: Durum yüklenirken hata oluştu:", e)
        }
    }

    function saveState() {
        try {
            stateFile.setText(JSON.stringify({
                wallpaper: root.currentWallpaper,
                dimLevel: root.dimLevel
            }, null, 2))
        } catch (e) {
            console.warn("WallpaperState: Durum kaydedilirken hata oluştu:", e)
        }
    }

    // Duvar kağıtlarını sistemden tarayan süreç
    Process {
        id: scanProc
        command: [
            "bash", "-c",
            "shopt -s nullglob nocaseglob; " +
            "DIRS=(\"$HOME/.config/quickshell/assets/wallpapers\" \"$HOME/Pictures/Wallpapers\" \"$HOME/.local/share/wallpapers\"); " +
            "for d in \"${DIRS[@]}\"; do " +
            "  [ -d \"$d\" ] || continue; " +
            "  for f in \"$d\"/*.{jpg,jpeg,png,webp}; do " +
            "    [ -f \"$f\" ] && echo \"$f\"; " +
            "  done; " +
            "done | sort -u"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.isScanning = false
                var lines = this.text.split("\n")
                var list = []
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim()
                    if (!p) continue
                    var fileName = p.substring(p.lastIndexOf("/") + 1)
                    if (seen[fileName]) continue
                    seen[fileName] = true
                    list.push({
                        filePath: "file://" + p,
                        rawPath: p,
                        fileName: fileName,
                        label: root.formatLabel(fileName)
                    })
                }
                root.wallpapers = list
                // Eğer kayıtlı bir duvar kağıdı yoksa ilk bulunanı varsayılan yap
                if ((!root.currentWallpaper || root.currentWallpaper.length === 0) && list.length > 0) {
                    root.setWallpaper(list[0].filePath)
                }
            }
        }
    }

    function scanWallpapers() {
        if (isScanning) return
        isScanning = true
        scanProc.running = false
        scanProc.running = true
    }

    IpcHandler {
        target: "wallpaper"

        function set(path: string): void {
            root.setWallpaper(path)
        }

        function dim(level: real): void {
            root.setDim(level)
        }

        function toggle(): void {
            root.togglePicker()
        }

        function picker(): void {
            root.togglePicker()
        }
    }

    IpcHandler {
        target: "enyxma-wallpaper"

        function set(path: string): void {
            root.setWallpaper(path)
        }

        function dim(level: real): void {
            root.setDim(level)
        }

        function toggle(): void {
            root.togglePicker()
        }

        function picker(): void {
            root.togglePicker()
        }
    }

    Component.onCompleted: {
        root.loadState()
        root.scanWallpapers()
    }
}
