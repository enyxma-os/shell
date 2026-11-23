pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * SettingsState — Enyxma Shell merkezi kalici ayar yoneticisi.
 *
 * Tek kaynak: ~/.config/enyxma/settings.json
 * Yalnizca SettingsState okur ve yazar; her degisiklik canli uygulanir.
 */
Singleton {
    id: root

    property bool isOpen: false
    property string activeTab: "appearance" // appearance | bar | shortcuts | system

    // ── Gorunum ve Bar ───────────────────────────────────────────────
    property bool reduceMotion: false
    property bool barVisible: true
    property int barHeightOffset: 0

    // ── Ust Cubuk Modulleri ──────────────────────────────────────────
    property bool showWorkspaces: true
    property bool showClock: true
    property bool showSystemStats: true
    property bool showNetwork: true
    property bool showVolume: true
    property bool showPower: true
    property bool showAi: true
    property bool showNotifications: true
    property bool showTray: true

    // ── Yerlesik Eklenti Anahtarlari (gelecek moduller icin hazir) ────
    property bool enableAudioMixer: true
    property bool enableBluetoothPanel: true
    property bool enableWifiQr: true
    property bool enableFocusTimer: false
    property bool enableContainerMonitor: false

    // ── Kisayol Rehberi ──────────────────────────────────────────────
    property var shortcuts: defaultShortcuts()

    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string configDir: homeDir + "/.config/enyxma"
    readonly property string configPath: configDir + "/settings.json"
    readonly property string bindsPath: homeDir + "/.config/hypr/lua/wm/binds.lua"
    property bool _loaded: false

    function defaultShortcuts() {
        return [
            { keys: "SUPER + Return", action: "Terminal aç" },
            { keys: "SUPER + Space", action: "Uygulama ve komut başlatıcısı" },
            { keys: "SUPER + I", action: "Enyxma Ayarlar penceresi" },
            { keys: "SUPER + T", action: "Tema değiştir — Dinamik / Gotham" },
            { keys: "SUPER + SHIFT + T", action: "Duvar kağıdı galerisi" },
            { keys: "SUPER + SHIFT + S", action: "Ekran alıntısı ve çizim stüdyosu" },
            { keys: "SUPER + ALT + S", action: "Tam ekran görüntüsü kaydet" },
            { keys: "SUPER + Tab", action: "Genel bakış — masaüstü şeridi" },
            { keys: "SUPER + D", action: "Kontrol Merkezi" },
            { keys: "SUPER + S", action: "Enyxma AI kenar çubuğu" },
            { keys: "SUPER + N", action: "Bildirim merkezi" },
            { keys: "SUPER + SHIFT + V", action: "Pano geçmişi" },
            { keys: "SUPER + B", action: "Üst çubuğu gizle / göster" },
            { keys: "SUPER + E", action: "Dosya yöneticisi" },
            { keys: "SUPER + W", action: "Web tarayıcı" },
            { keys: "SUPER + L", action: "Ekranı kilitle" },
            { keys: "SUPER + Q", action: "Aktif pencereyi kapat" },
            { keys: "SUPER + F", action: "Tam ekran aç / kapat" },
            { keys: "SUPER + V", action: "Yüzen pencere modu" },
            { keys: "SUPER + G", action: "Oyun modu" },
            { keys: "SUPER + Ok Tuşları", action: "Pencereler arası odak" },
            { keys: "SUPER + 1..0", action: "Çalışma alanına geç" }
        ]
    }

    function open(tab) {
        if (tab && String(tab).length > 0) activeTab = String(tab)
        isOpen = true
    }

    function toggle() {
        isOpen = !isOpen
    }

    function close() {
        isOpen = false
    }

    function adjustBarHeight(delta) {
        var next = Math.max(-4, Math.min(8, root.barHeightOffset + delta))
        if (next !== root.barHeightOffset) {
            root.barHeightOffset = next
            root.save()
        }
    }

    function resetDefaults() {
        reduceMotion = false
        barVisible = true
        barHeightOffset = 0
        showWorkspaces = true
        showClock = true
        showSystemStats = true
        showNetwork = true
        showVolume = true
        showPower = true
        showAi = true
        showNotifications = true
        showTray = true
        enableAudioMixer = true
        enableBluetoothPanel = true
        enableWifiQr = true
        enableFocusTimer = false
        enableContainerMonitor = false
        save()
    }

    function openConfigFile() {
        save()
        Quickshell.execDetached(["enyxma-launch", "xdg-open", root.configPath])
    }

    // Dizin hazirligi (1 kez)
    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.configDir]
        running: true
        onExited: (code) => {
            settingsFile.reload()
            bindsFile.reload()
        }
    }

    FileView {
        id: settingsFile
        path: root.configPath
        printErrors: false
        blockLoading: false
        onLoaded: root.loadFromJson(settingsFile.text())
        onLoadFailed: {
            if (!root._loaded) {
                root._loaded = true
                root.save()
            }
        }
    }

    function loadFromJson(raw) {
        root._loaded = true
        try {
            var s = String(raw || "").trim()
            if (!s) { root.save(); return }
            var d = JSON.parse(s)
            if (!d || typeof d !== "object") return
            if (typeof d.reduceMotion === "boolean") root.reduceMotion = d.reduceMotion
            if (typeof d.barVisible === "boolean") root.barVisible = d.barVisible
            if (typeof d.barHeightOffset === "number") root.barHeightOffset = Math.max(-4, Math.min(8, Math.round(d.barHeightOffset)))
            if (typeof d.showWorkspaces === "boolean") root.showWorkspaces = d.showWorkspaces
            if (typeof d.showClock === "boolean") root.showClock = d.showClock
            if (typeof d.showSystemStats === "boolean") root.showSystemStats = d.showSystemStats
            if (typeof d.showNetwork === "boolean") root.showNetwork = d.showNetwork
            if (typeof d.showVolume === "boolean") root.showVolume = d.showVolume
            if (typeof d.showPower === "boolean") root.showPower = d.showPower
            if (typeof d.showAi === "boolean") root.showAi = d.showAi
            if (typeof d.showNotifications === "boolean") root.showNotifications = d.showNotifications
            if (typeof d.showTray === "boolean") root.showTray = d.showTray
            if (typeof d.enableAudioMixer === "boolean") root.enableAudioMixer = d.enableAudioMixer
            if (typeof d.enableBluetoothPanel === "boolean") root.enableBluetoothPanel = d.enableBluetoothPanel
            if (typeof d.enableWifiQr === "boolean") root.enableWifiQr = d.enableWifiQr
            if (typeof d.enableFocusTimer === "boolean") root.enableFocusTimer = d.enableFocusTimer
            if (typeof d.enableContainerMonitor === "boolean") root.enableContainerMonitor = d.enableContainerMonitor
        } catch (e) {
            console.warn("SettingsState: JSON okunamadi:", e)
        }
    }

    function save() {
        try {
            var payload = {
                reduceMotion: root.reduceMotion,
                barVisible: root.barVisible,
                barHeightOffset: root.barHeightOffset,
                showWorkspaces: root.showWorkspaces,
                showClock: root.showClock,
                showSystemStats: root.showSystemStats,
                showNetwork: root.showNetwork,
                showVolume: root.showVolume,
                showPower: root.showPower,
                showAi: root.showAi,
                showNotifications: root.showNotifications,
                showTray: root.showTray,
                enableAudioMixer: root.enableAudioMixer,
                enableBluetoothPanel: root.enableBluetoothPanel,
                enableWifiQr: root.enableWifiQr,
                enableFocusTimer: root.enableFocusTimer,
                enableContainerMonitor: root.enableContainerMonitor
            }
            settingsFile.setText(JSON.stringify(payload, null, 2))
        } catch (e) {
            console.warn("SettingsState: JSON yazilamadi:", e)
        }
    }

    // Canli binds.lua okuyucu
    FileView {
        id: bindsFile
        path: root.bindsPath
        printErrors: false
        blockLoading: false
        onLoaded: root.parseBindsLua(bindsFile.text())
    }

    function describeBindAction(rhs) {
        var s = String(rhs || "")
        if (s.indexOf("terminal") >= 0) return "Terminal aç"
        if (s.indexOf("app_launcher") >= 0 || s.indexOf("\"launcher\", \"toggle\"") >= 0) return "Uygulama ve komut başlatıcısı"
        if (s.indexOf("\"launcher\", \"menu\"") >= 0) return "Komut paleti"
        if (s.indexOf("clipboard") >= 0) return "Pano geçmişi"
        if (s.indexOf("\"settings\"") >= 0) return "Enyxma Ayarlar penceresi"
        if (s.indexOf("\"wallpaper\", \"cycle\"") >= 0) return "Tema değiştir — Dinamik / Gotham"
        if (s.indexOf("\"wallpaper\", \"toggle\"") >= 0) return "Duvar kağıdı galerisi"
        if (s.indexOf("screenshot_studio") >= 0) return "Ekran alıntısı ve çizim stüdyosu"
        if (s.indexOf("screenshot_save_full") >= 0) return "Tam ekran görüntüsü kaydet"
        if (s.indexOf("screenshot_screen") >= 0) return "Tam ekran görüntüsü panoya"
        if (s.indexOf("file_manager") >= 0) return "Dosya yöneticisi"
        if (s.indexOf("tui_file_manager") >= 0) return "Yazi dosya yöneticisi"
        if (s.indexOf("web_browser") >= 0) return "Web tarayıcı"
        if (s.indexOf("screen_lock") >= 0) return "Ekranı kilitle"
        if (s.indexOf("\"overview\"") >= 0) return "Genel bakış — masaüstü şeridi"
        if (s.indexOf("\"dashboard\"") >= 0) return "Kontrol Merkezi"
        if (s.indexOf("\"ai\"") >= 0) return "Enyxma AI kenar çubuğu"
        if (s.indexOf("\"notifications\"") >= 0) return "Bildirim merkezi"
        if (s.indexOf("\"bar\"") >= 0) return "Üst çubuğu gizle / göster"
        if (s.indexOf("window.close") >= 0) return "Aktif pencereyi kapat"
        if (s.indexOf("window.kill") >= 0) return "Aktif pencereyi zorla sonlandır"
        if (s.indexOf("fullscreen") >= 0 && s.indexOf("maximized") >= 0) return "Pencereyi büyüt"
        if (s.indexOf("fullscreen") >= 0) return "Tam ekran aç / kapat"
        if (s.indexOf("float") >= 0) return "Yüzen pencere modu"
        if (s.indexOf("window.pin") >= 0) return "Pencereyi sabitle"
        if (s.indexOf("window.center") >= 0) return "Yüzen pencereyi ortala"
        if (s.indexOf("GamingMode") >= 0) return "Oyun modu"
        if (s.indexOf("hyprctl reload") >= 0) return "Hyprland yapılandırmasını yenile"
        if (s.indexOf("hyprshutdown") >= 0) return "Oturumu kapat"
        if (s.indexOf("togglesplit") >= 0) return "Bölme yönünü değiştir"
        if (s.indexOf("group.toggle") >= 0) return "Sekmeli pencere grubu"
        if (s.indexOf("toggle_special") >= 0) return "Özel çalışma alanını aç / kapat"
        return ""
    }

    function parseBindsLua(text) {
        var lines = String(text || "").split("\n")
        var parsed = []
        var seen = {}
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i].trim()
            if (l.indexOf("hl.bind(") !== 0) continue
            var m = l.match(/^hl\.bind\((.+?),\s*(.+)\)$/)
            if (!m) continue
            var rawKey = m[1].replace(/MOD\s*\.\.\s*"\s*/g, "SUPER ").replace(/"/g, "").replace(/\s+/g, " ").trim()
            var desc = root.describeBindAction(m[2])
            if (desc === "" || seen[rawKey]) continue
            seen[rawKey] = true
            parsed.push({ keys: rawKey, action: desc })
        }
        if (parsed.length >= 8) {
            root.shortcuts = parsed
        }
    }

    IpcHandler {
        target: "settings"

        function toggle(): void { root.toggle() }
        function open(): void { root.open("") }
        function close(): void { root.close() }
        function reset(): void { root.resetDefaults() }
    }
}
