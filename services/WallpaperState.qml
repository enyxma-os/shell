pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * WallpaperState — duvar kağıdı, karartma ve matugen tema zinciri.
 *
 * P0 DÜZELTMELERİ:
 *  1. `dimLevel` ARTIK DİSKE YAZILMIYOR. Eski kod launcher/AI açıkken
 *     dimLevel=0.3'ü kaydediyordu; shell o anda çökerse sonraki oturum
 *     ekranı %30 siyah örtüyle açıyordu. Yeni oturum daima 0.0 ile başlar.
 *  2. `generateThemeFromImage/Color`: `bash -c` kaldırıldı → argüman dizisi.
 *     matugen yolu `ENYXMA_SHELL_DIR` (paket) veya geliştirme yolu.
 *  3. `scanWallpapers`: `bash -c` + brace expansion yerine `find` dizisi.
 *  4. Durum yükleme tek noktadan (`onLoaded`), çift yükleme yarışı yok.
 *  5. İlk bulunan duvar kağıdı artık körlemesine uygulanmıyor; yalnızca
 *     kullanıcı seçtiğinde tema üretilir (kurulumda gereksiz matugen yok).
 */
Singleton {
    id: root

    property string currentWallpaper: ""
    property string currentTheme: "dynamic"
    property var themeWallpapers: ({})
    property real dimLevel: 0.0
    property bool pickerVisible: false
    property var wallpapers: []
    property bool isScanning: false
    property string scannedTheme: ""
    property bool stateLoaded: false

    readonly property string home: Quickshell.env("HOME") || ""

    // Paketlenmiş kurulumda assets $out/share/enyxma-shell altındadır.
    readonly property string shellDir: {
        const env = Quickshell.env("ENYXMA_SHELL_DIR")
        if (env && env.length > 0) return env
        return root.home + "/.config/quickshell"
    }

    readonly property string matugenConfig: root.shellDir + "/matugen.toml"
    readonly property string themeApplyBin: root.shellDir + "/enyxma-theme-apply"
    readonly property string defaultWallpaper: "file://" + root.shellDir + "/assets/wallpapers/enyxma-obsidian-monolith.jpg"
    readonly property string defaultGothamWallpaper: "file://" + root.shellDir + "/assets/wallpapers/gotham/gotham-dark-city.png"

    function togglePicker() {
        if (pickerVisible) { pickerVisible = false; return }
        openPicker()
    }
    function openPicker() {
        pickerVisible = true
        if (wallpapers.length === 0 || scannedTheme !== currentTheme) scanWallpapers()
    }
    function closePicker() { pickerVisible = false }

    function formatLabel(fileName) {
        if (!fileName) return ""
        var name = String(fileName).replace(/\.[^/.]+$/, "")
        name = name.replace(/^enyxma[-_]/i, "")
        return name.replace(/[-_]+/g, " ").replace(/\b\w/g, function(m) { return m.toUpperCase() })
    }

    function setWallpaper(path) {
        if (!path || String(path).trim().length === 0) {
            currentWallpaper = ""
            saveState()
            return
        }
        var p = String(path).trim()
        if (!p.startsWith("file://") && !p.startsWith("http://") &&
            !p.startsWith("https://") && !p.startsWith("qrc:/")) {
            p = "file://" + p
        }
        currentWallpaper = p
        var map = Object.assign({}, root.themeWallpapers || {})
        map[root.currentTheme] = p
        root.themeWallpapers = map
        saveState()
        if (root.currentTheme === "dynamic") {
            generateThemeFromImage(p.replace(/^file:\/\//, ""))
        }
    }

    function setThemePreset(presetName) {
        var name = String(presetName || "").trim().toLowerCase()
        if (name !== "gotham") name = "dynamic"

        var prevTheme = root.currentTheme || "dynamic"
        var map = Object.assign({}, root.themeWallpapers || {})
        if (root.currentWallpaper && root.currentWallpaper.length > 0) {
            map[prevTheme] = root.currentWallpaper
        }

        root.currentTheme = name
        var nextWp = map[name]
        if (!nextWp || String(nextWp).trim().length === 0) {
            nextWp = (name === "gotham") ? root.defaultGothamWallpaper : root.defaultWallpaper
        }
        map[name] = nextWp
        root.themeWallpapers = map
        root.currentWallpaper = nextWp
        root.saveState()
        root.scanWallpapers()

        if (name === "gotham") {
            matugenProc.exec([root.themeApplyBin, "preset", "gotham"])
        } else {
            root.generateThemeFromImage(String(nextWp).replace(/^file:\/\//, ""))
        }
    }

    function cycleTheme() {
        var next = (root.currentTheme === "gotham") ? "dynamic" : "gotham"
        var label = (next === "gotham") ? "Gotham — Brutalist Mimari" : "✦ Dinamik — Matugen"
        setThemePreset(next)
        Quickshell.execDetached(["notify-send", "-t", "2200", "Enyxma Tema Motoru", label])
    }

    function setDim(level) {
        dimLevel = Math.max(0.0, Math.min(1.0, level))
    }

    // Matugen kabuksuz doğrudan süreç çağrısı
    Process {
        id: matugenProc
        workingDirectory: root.shellDir
        running: false
        onExited: (code) => {
            if (code === 0) {
                root.reloadTheme()
            } else {
                console.warn("WallpaperState: matugen başarısız, çıkış kodu: " + code)
            }
        }
    }

    function generateThemeFromImage(rawPath) {
        if (!rawPath || rawPath.length === 0) return
        matugenProc.exec([
            root.themeApplyBin, "image", rawPath
        ])
    }

    function generateThemeFromColor(hexColor) {
        if (!hexColor || hexColor.length === 0) return
        var hex = String(hexColor).trim()
        if (!/^#?[0-9a-fA-F]{6}$/.test(hex)) return
        matugenProc.exec([
            root.themeApplyBin, "color", hex
        ])
    }

    Timer {
        id: reloadTimer
        interval: 120
        repeat: false
        onTriggered: Quickshell.reload(false)
    }

    function reloadTheme() {
        reloadTimer.restart()
    }

    // ── Kalıcı durum: yalnızca duvar kağıdı ──────────────────────────
    FileView {
        id: stateFile
        path: Quickshell.statePath("wallpaper.json")
        printErrors: false
        onLoaded: root.loadState()
        onLoadFailed: root.loadState()
    }

    function normalizeWallpaperUrl(rawUrl) {
        var s = String(rawUrl || "").trim()
        if (!s) return ""
        var marker = "/assets/wallpapers/"
        var markerIdx = s.indexOf(marker)
        if (s.indexOf("/enyxma-shell/") !== -1 && markerIdx !== -1) {
            var rel = s.substring(markerIdx + marker.length)
            if (rel === "enyxma-dark-city.png") {
                rel = "gotham/gotham-dark-city.png"
            }
            s = "file://" + root.shellDir + marker + rel
        }
        return s
    }

    function loadState() {
        if (root.stateLoaded) return
        root.stateLoaded = true
        var migrated = false
        try {
            var raw = stateFile.text()
            if (raw && raw.trim().length > 0) {
                var data = JSON.parse(raw)
                if (data && typeof data === "object" &&
                    typeof data.wallpaper === "string" && data.wallpaper.trim().length > 0) {
                    var orig = data.wallpaper.trim()
                    var saved = root.normalizeWallpaperUrl(orig)
                    if (saved !== orig) migrated = true
                    root.currentWallpaper = saved
                }
                if (data && typeof data === "object" &&
                    typeof data.theme === "string" && data.theme.trim().length > 0) {
                    var loadedTheme = data.theme.trim().toLowerCase()
                    root.currentTheme = (loadedTheme === "gotham") ? "gotham" : "dynamic"
                }
                if (data && typeof data === "object" &&
                    data.themeWallpapers && typeof data.themeWallpapers === "object") {
                    var normMap = {}
                    var keys = Object.keys(data.themeWallpapers)
                    for (var i = 0; i < keys.length; i++) {
                        var k = keys[i]
                        var v = data.themeWallpapers[k]
                        if (typeof v === "string" && v.trim().length > 0) {
                            var nv = root.normalizeWallpaperUrl(v)
                            if (nv !== v) migrated = true
                            normMap[k] = nv
                        }
                    }
                    root.themeWallpapers = normMap
                }
            }
        } catch (e) {
            console.warn("WallpaperState: Durum yüklenemedi:", e)
        }
        if (!root.currentWallpaper || root.currentWallpaper.length === 0) {
            root.currentWallpaper = (root.currentTheme === "gotham")
                ? root.defaultGothamWallpaper
                : root.defaultWallpaper
        } else if (migrated) {
            root.saveState()
        }
        // dimLevel bilinçli olarak yüklenmez, kara ekran korumasıdır.
        root.dimLevel = 0.0
        if (root.scannedTheme !== root.currentTheme && !root.isScanning) {
            root.scanWallpapers()
        }
    }

    function saveState() {
        try {
            stateFile.setText(JSON.stringify({
                wallpaper: root.currentWallpaper,
                theme: root.currentTheme,
                themeWallpapers: root.themeWallpapers
            }, null, 2))
        } catch (e) {
            console.warn("WallpaperState: Durum kaydedilemedi:", e)
        }
    }

    // ── Tarama (kabuksuz find) ───────────────────────────────────────
    Process {
        id: scanProc
        command: []
        running: false
        stdout: StdioCollector { id: scanOut }
        onExited: (code) => {
            root.isScanning = false
            root.consumeScan(scanOut.text)
            if (root.scannedTheme !== root.currentTheme) {
                root.scanWallpapers()
            }
        }
    }

    function consumeScan(text) {
        var lines = String(text || "").split("\n")
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
        list.sort(function(a, b) {
            return String(a.label).localeCompare(String(b.label))
        })
        root.wallpapers = list
    }

    function scanWallpapers() {
        if (isScanning) return
        isScanning = true
        root.scannedTheme = root.currentTheme
        var dirs = (root.currentTheme === "gotham")
            ? [root.shellDir + "/assets/wallpapers/gotham"]
            : [
                root.shellDir + "/assets/wallpapers",
                root.home + "/Pictures/Wallpapers",
                root.home + "/.local/share/wallpapers"
            ]
        scanProc.exec(["find"].concat(dirs).concat([
            "-maxdepth", "1", "-type", "f", "(",
            "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o",
            "-iname", "*.png", "-o", "-iname", "*.webp", ")",
            "-printf", "%p\n"
        ]))
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { root.setWallpaper(path) }
        function dim(level: real): void { root.setDim(level) }
        function toggle(): void { root.togglePicker() }
        function picker(): void { root.togglePicker() }
        function color(hex: string): void { root.generateThemeFromColor(hex) }
        function preset(name: string): void { root.setThemePreset(name) }
        function cycle(): void { root.cycleTheme() }
        function refresh(): void { root.scanWallpapers() }
    }

    Component.onCompleted: {
        // Yalnızca duvar kağıdı listesini hazırla; tema üretme.
        root.scanWallpapers()
    }
}
