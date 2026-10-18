pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string currentWallpaper: ""
    property real dimLevel: 0.0

    function setWallpaper(path: string) {
        if (!path || path.trim().length === 0) {
            currentWallpaper = ""
            saveState()
            return
        }
        let p = path.trim()
        if (!p.startsWith("file://") && !p.startsWith("http://") && !p.startsWith("https://") && !p.startsWith("qrc:/")) {
            p = "file://" + p
        }
        currentWallpaper = p
        saveState()
    }

    function setDim(level: real) {
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
            const raw = stateFile.text()
            if (raw && raw.trim().length > 0) {
                const data = JSON.parse(raw)
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

    IpcHandler {
        target: "wallpaper"

        function set(path: string): void {
            root.setWallpaper(path)
        }

        function dim(level: real): void {
            root.setDim(level)
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
    }

    Component.onCompleted: {
        root.loadState()
    }
}
