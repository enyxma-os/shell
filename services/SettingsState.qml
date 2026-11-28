pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * SettingsState — Enyxma Shell merkezi kalici ayar ve sistem kontrol yoneticisi.
 *
 * Tek kaynak: ~/.config/enyxma/settings.json
 * Faz 3: Genel bakis, canli Hyprland pencere geometrisi, ekran/monitor,
 * klavye/fare ayarlari, global arama dizini ve tek tikla Geri Al destegi.
 */
Singleton {
    id: root

    property bool isOpen: false
    property string activeTab: "overview" // overview | appearance | bar | display | input | shortcuts | system

    // ── Gorunum ve Bar ───────────────────────────────────────────────
    property string language: "tr" // tr | en
    property bool reduceMotion: false
    property bool barVisible: true
    property int barHeightOffset: 0

    // ── Hyprland Pencere Geometrisi ──────────────────────────────────
    property bool customHyprStyle: false
    property int hyprRounding: 8
    property int hyprGapsIn: 4
    property int hyprGapsOut: 8
    property int hyprBorderSize: 2
    property bool hyprBlur: true
    property real hyprActiveOpacity: 1.0
    property real hyprInactiveOpacity: 0.95
    property bool hyprShadow: true
    property bool hyprAnimations: true
    property int hyprVrr: 0 // 0=Kapali, 1=Her Zaman, 2=Tam Ekran

    // ── Ekran, Gece Isigi ve Monitorler ──────────────────────────────
    property var monitors: []
    property bool nightLightEnabled: false
    property int nightLightTemp: 4500

    // ── Bildirim, Guc ve Varsayilan Uygulamalar ──────────────────────
    property int notifTimeoutSec: 5
    property string defaultTerminal: "kitty"
    property string defaultFileManager: "nautilus"
    property bool idleEnabled: true
    property int idleLockMin: 5
    property int idleScreenOffMin: 10
    property int idleSuspendMin: 0

    // ── Klavye ve Fare ───────────────────────────────────────────────
    property string kbLayout: "tr"
    property int kbRepeatRate: 35
    property int kbRepeatDelay: 250
    property real mouseSensitivity: 0.0
    property bool naturalScroll: false

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

    // ── Yerlesik Eklenti Anahtarlari ─────────────────────────────────
    property bool enableAudioMixer: true
    property bool enableBluetoothPanel: true
    property bool enableWifiQr: true
    property bool enableFocusTimer: false
    property bool enableContainerMonitor: false
    property var enabledPlugins: []
    property var disabledPlugins: []
    property var _pendingDefaultPlugins: []

    // ── Geri Al / Undo ───────────────────────────────────────────────
    property string undoLabel: ""
    property var _undoSnapshot: null

    Timer {
        id: undoTimer
        interval: 5500
        repeat: false
        onTriggered: root.undoLabel = ""
    }

    // ── Global Ayar Arama Dizini ─────────────────────────────────────
    readonly property var searchEntries: root.language === "en" ? [
        { tab: "overview",   title: "Overview",                  keywords: "system hardware cpu gpu ram disk summary network" },
        { tab: "appearance", title: "Theme — Dynamic / Gotham",  keywords: "theme matugen gotham brutalist appearance colors" },
        { tab: "appearance", title: "Wallpaper Gallery",         keywords: "wallpaper background gallery" },
        { tab: "appearance", title: "Hyprland Window Style",     keywords: "rounding gaps border blur opacity shadow animations" },
        { tab: "appearance", title: "Motion and Bar Height",     keywords: "animation reduce motion top bar height" },
        { tab: "bar",        title: "Top Bar Modules",           keywords: "workspaces clock telemetry network audio power ai notifications tray" },
        { tab: "display",    title: "Display, VRR & Night Light",keywords: "resolution refresh rate hz scale monitor vrr adaptive sync night light hyprsunset kelvin" },
        { tab: "display",    title: "Auto Lock & Sleep",         keywords: "hypridle lock screen off suspend timeout power" },
        { tab: "input",      title: "Keyboard & Mouse",          keywords: "keyboard layout tr us de repeat rate delay mouse sensitivity scroll" },
        { tab: "shortcuts",  title: "Keyboard Shortcuts",        keywords: "shortcuts keybinds binds super" },
        { tab: "system",     title: "System, Language & Apps",   keywords: "language english turkish settings.json reset audio mixer bluetooth qr focus container notification timeout dnd terminal" }
    ] : [
        { tab: "overview",   title: "Genel Bakış",               keywords: "sistem donanım cpu gpu ram disk özet ağ" },
        { tab: "appearance", title: "Tema — Dinamik / Gotham",   keywords: "tema matugen gotham brutalist görünüm renk" },
        { tab: "appearance", title: "Duvar Kağıdı Galerisi",     keywords: "wallpaper duvar kağıdı arka plan" },
        { tab: "appearance", title: "Hyprland Pencere Stili",    keywords: "köşe yuvarlaklık rounding boşluk gaps kenarlık border bulanıklık blur opaklık opacity gölge shadow animasyon" },
        { tab: "appearance", title: "Hareket ve Bar Yüksekliği", keywords: "animasyon reduce motion üst çubuk yükseklik" },
        { tab: "bar",        title: "Üst Çubuk Modülleri",       keywords: "çalışma alanları saat telemetri ağ ses güç ai bildirim tepsi" },
        { tab: "display",    title: "Ekran, VRR ve Gece Işığı",  keywords: "çözünürlük yenileme hızı hz ölçek scale monitör vrr adaptive sync gece ışığı hyprsunset kelvin" },
        { tab: "display",    title: "Otomatik Kilit ve Uyku",    keywords: "hypridle kilit ekran kapat uyku suspend timeout güç" },
        { tab: "input",      title: "Klavye ve Fare",            keywords: "klavye düzeni tr us de tekrar hızı gecikme fare hassasiyet kaydırma" },
        { tab: "shortcuts",  title: "Klavye Kısayolları",        keywords: "kısayol tuş atama binds super" },
        { tab: "system",     title: "Sistem, Dil ve Uygulamalar", keywords: "dil türkçe ingilizce settings.json sıfırla ses karıştırıcı bluetooth qr odak konteyner bildirim süresi dnd varsayılan terminal" }
    ]

    // ── Kisayol Rehberi ──────────────────────────────────────────────
    property var shortcuts: defaultShortcuts()

    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string configDir: homeDir + "/.config/enyxma"
    readonly property string configPath: configDir + "/settings.json"
    readonly property string bindsPath: homeDir + "/.config/hypr/lua/wm/binds.lua"
    property bool _loaded: false

    function defaultShortcuts() {
        var en = root.language === "en"
        return [
            { keys: "SUPER + Return", action: en ? "Open terminal" : "Terminal aç" },
            { keys: "SUPER + Grave", action: en ? "Toggle special workspace" : "Özel çalışma alanını aç / kapat" },
            { keys: "SUPER + Space", action: en ? "App & command launcher" : "Uygulama ve komut başlatıcısı" },
            { keys: "SUPER + I", action: en ? "Enyxma Settings window" : "Enyxma Ayarlar penceresi" },
            { keys: "SUPER + T", action: en ? "Cycle theme — Dynamic / Gotham" : "Tema değiştir — Dinamik / Gotham" },
            { keys: "SUPER + SHIFT + T", action: en ? "Wallpaper gallery" : "Duvar kağıdı galerisi" },
            { keys: "SUPER + SHIFT + S", action: en ? "Screenshot & annotation studio" : "Ekran alıntısı ve çizim stüdyosu" },
            { keys: "SUPER + ALT + S", action: en ? "Save full-screen capture" : "Tam ekran görüntüsü kaydet" },
            { keys: "SUPER + Tab", action: en ? "Overview — workspace strip" : "Genel bakış — masaüstü şeridi" },
            { keys: "SUPER + D", action: en ? "Control Center" : "Kontrol Merkezi" },
            { keys: "SUPER + S", action: en ? "Enyxma AI sidebar" : "Enyxma AI kenar çubuğu" },
            { keys: "SUPER + N", action: en ? "Notification center" : "Bildirim merkezi" },
            { keys: "SUPER + SHIFT + V", action: en ? "Clipboard history" : "Pano geçmişi" },
            { keys: "SUPER + B", action: en ? "Toggle top bar" : "Üst çubuğu gizle / göster" },
            { keys: "SUPER + E", action: en ? "File manager" : "Dosya yöneticisi" },
            { keys: "SUPER + W", action: en ? "Web browser" : "Web tarayıcı" },
            { keys: "SUPER + L", action: en ? "Lock screen" : "Ekranı kilitle" },
            { keys: "SUPER + Q", action: en ? "Close active window" : "Aktif pencereyi kapat" },
            { keys: "SUPER + F", action: en ? "Toggle fullscreen" : "Tam ekran aç / kapat" },
            { keys: "SUPER + V", action: en ? "Toggle floating mode" : "Yüzen pencere modu" },
            { keys: "SUPER + G", action: en ? "Gaming mode" : "Oyun modu" },
            { keys: "SUPER + ALT + R", action: en ? "Screen recording studio" : "Ekran kaydı stüdyosu" },
            { keys: "SUPER + CTRL + R", action: en ? "Quick start / stop recording" : "Hızlı ekran kaydı başlat / durdur" },
            { keys: "SUPER + CTRL + P", action: en ? "Pause / resume recording" : "Ekran kaydını duraklat / devam et" },
            { keys: "SUPER + ALT + BackSpace", action: en ? "Save recent moment clip" : "Son an klibini kaydet" },
            { keys: en ? "SUPER + CTRL + SHIFT + Arrows" : "SUPER + CTRL + SHIFT + Ok Tuşları", action: en ? "Resize active window" : "Aktif pencereyi boyutlandır" },
            { keys: en ? "SUPER + Arrows" : "SUPER + Ok Tuşları", action: en ? "Move window focus" : "Pencereler arası odak" },
            { keys: "SUPER + 1..0", action: en ? "Switch workspace" : "Çalışma alanına geç" }
        ]
    }

    function open(tab) {
        if (tab && String(tab).length > 0) activeTab = String(tab)
        isOpen = true
        refreshMonitors()
    }

    function toggle() {
        if (isOpen) close()
        else open("")
    }

    function close() {
        isOpen = false
    }

    // ── Undo Yardimcilari ────────────────────────────────────────────
    function snapshotPayload() {
        return {
            language: root.language,
            reduceMotion: root.reduceMotion,
            barVisible: root.barVisible,
            barHeightOffset: root.barHeightOffset,
            customHyprStyle: root.customHyprStyle,
            hyprRounding: root.hyprRounding,
            hyprGapsIn: root.hyprGapsIn,
            hyprGapsOut: root.hyprGapsOut,
            hyprBorderSize: root.hyprBorderSize,
            hyprBlur: root.hyprBlur,
            hyprActiveOpacity: root.hyprActiveOpacity,
            hyprInactiveOpacity: root.hyprInactiveOpacity,
            hyprShadow: root.hyprShadow,
            hyprAnimations: root.hyprAnimations,
            hyprVrr: root.hyprVrr,
            nightLightEnabled: root.nightLightEnabled,
            nightLightTemp: root.nightLightTemp,
            notifTimeoutSec: root.notifTimeoutSec,
            defaultTerminal: root.defaultTerminal,
            defaultFileManager: root.defaultFileManager,
            idleEnabled: root.idleEnabled,
            idleLockMin: root.idleLockMin,
            idleScreenOffMin: root.idleScreenOffMin,
            idleSuspendMin: root.idleSuspendMin,
            enabledPlugins: root.enabledPlugins,
            disabledPlugins: root.disabledPlugins,
            kbLayout: root.kbLayout,
            kbRepeatRate: root.kbRepeatRate,
            kbRepeatDelay: root.kbRepeatDelay,
            mouseSensitivity: root.mouseSensitivity,
            naturalScroll: root.naturalScroll,
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
    }

    function recordUndo(label) {
        root._undoSnapshot = snapshotPayload()
        root.undoLabel = String(label || I18n.t("Ayar güncellendi", "Setting updated"))
        undoTimer.restart()
    }

    function undoLast() {
        if (!root._undoSnapshot) return
        var snap = root._undoSnapshot
        root._undoSnapshot = null
        root.undoLabel = ""
        undoTimer.stop()
        loadFromJson(JSON.stringify(snap))
        if (root.customHyprStyle) applyHyprStyle()
        else Quickshell.execDetached(["hyprctl", "reload"])
        applyInputSettings()
        save()
    }

    // ── Ayar Degistirme Fonksiyonlari ────────────────────────────────
    function toggleBoolSetting(prop, label) {
        recordUndo(label)
        root[prop] = !root[prop]
        save()
    }

    function adjustBarHeight(delta) {
        var next = Math.max(-4, Math.min(8, root.barHeightOffset + delta))
        if (next !== root.barHeightOffset) {
            recordUndo(I18n.t("Üst çubuk yüksekliği değişti", "Top bar height changed"))
            root.barHeightOffset = next
            root.save()
        }
    }

    function setHyprSetting(prop, value, label) {
        recordUndo(label)
        root.customHyprStyle = true
        root[prop] = value
        applyHyprStyle()
        save()
    }

    function escapeLuaStr(s) {
        return String(s || "").replace(/\\/g, "\\\\").replace(/"/g, "\\\"")
    }

    Process {
        id: hyprStyleProc
        running: false
        property string fallbackBatch: ""
        stdout: StdioCollector { id: hyprStyleOut }
        onExited: (code) => {
            if (code === 0 && (hyprStyleOut.text || "").trim() === "ok") return
            if (fallbackBatch !== "") {
                Quickshell.execDetached(["hyprctl", "--batch", fallbackBatch])
            }
        }
    }

    function applyHyprStyle() {
        if (!root.customHyprStyle) return
        var actOp = Number(root.hyprActiveOpacity).toFixed(2)
        var inactOp = Number(root.hyprInactiveOpacity).toFixed(2)
        var luaExpr = "hl.config({ general = { gaps_in = " + root.hyprGapsIn
            + ", gaps_out = " + root.hyprGapsOut
            + ", border_size = " + root.hyprBorderSize
            + " }, decoration = { rounding = " + root.hyprRounding
            + ", active_opacity = " + actOp
            + ", inactive_opacity = " + inactOp
            + ", shadow = { enabled = " + (root.hyprShadow ? "true" : "false")
            + " }, blur = { enabled = " + (root.hyprBlur ? "true" : "false")
            + " } }, animations = { enabled = " + (root.hyprAnimations ? "true" : "false")
            + " }, misc = { vrr = " + root.hyprVrr + " } })"
        var cmds = [
            "keyword decoration:rounding " + root.hyprRounding,
            "keyword general:gaps_in " + root.hyprGapsIn,
            "keyword general:gaps_out " + root.hyprGapsOut,
            "keyword general:border_size " + root.hyprBorderSize,
            "keyword decoration:active_opacity " + actOp,
            "keyword decoration:inactive_opacity " + inactOp,
            "keyword decoration:shadow:enabled " + (root.hyprShadow ? "true" : "false"),
            "keyword decoration:blur:enabled " + (root.hyprBlur ? "true" : "false"),
            "keyword animations:enabled " + (root.hyprAnimations ? "true" : "false"),
            "keyword misc:vrr " + root.hyprVrr
        ]
        hyprStyleProc.fallbackBatch = cmds.join(" ; ")
        hyprStyleProc.command = ["hyprctl", "eval", luaExpr]
        hyprStyleProc.running = false
        hyprStyleProc.running = true
    }

    Process {
        id: hyprVrrProc
        running: false
        property int fallbackMode: 0
        stdout: StdioCollector { id: hyprVrrOut }
        onExited: (code) => {
            if (code === 0 && (hyprVrrOut.text || "").trim() === "ok") return
            Quickshell.execDetached(["hyprctl", "keyword", "misc:vrr", String(fallbackMode)])
        }
    }

    function applyVrr(mode) {
        var next = Math.max(0, Math.min(2, Math.round(mode)))
        recordUndo(I18n.t("VRR modu güncellendi", "VRR mode updated"))
        root.hyprVrr = next
        save()
        hyprVrrProc.fallbackMode = next
        hyprVrrProc.command = ["hyprctl", "eval", "hl.config({ misc = { vrr = " + next + " } })"]
        hyprVrrProc.running = false
        hyprVrrProc.running = true
    }

    Process {
        id: nightLightKillProc
        running: false
        command: ["pkill", "-x", "hyprsunset"]
        onExited: {
            if (root.nightLightEnabled) {
                Quickshell.execDetached(["hyprsunset", "-t", String(root.nightLightTemp)])
            }
        }
    }

    function applyNightLight() {
        nightLightKillProc.running = false
        nightLightKillProc.running = true
    }

    function toggleNightLight() {
        recordUndo(root.nightLightEnabled ? I18n.t("Gece ışığı kapatıldı", "Night light disabled") : I18n.t("Gece ışığı açıldı", "Night light enabled"))
        root.nightLightEnabled = !root.nightLightEnabled
        applyNightLight()
        save()
    }

    function setNightLightTemp(kelvin) {
        var next = Math.max(3000, Math.min(6000, Math.round(kelvin)))
        recordUndo(I18n.t("Gece ışığı sıcaklığı güncellendi", "Night light temperature updated"))
        root.nightLightTemp = next
        if (!root.nightLightEnabled) root.nightLightEnabled = true
        applyNightLight()
        save()
    }

    function setNotifTimeout(sec) {
        recordUndo(I18n.t("Bildirim süresi güncellendi", "Notification timeout updated"))
        root.notifTimeoutSec = Math.max(2, Math.min(20, Math.round(sec)))
        save()
    }

    function setDefaultApp(prop, value, label) {
        recordUndo(label)
        root[prop] = String(value)
        save()
    }

    function isPluginEnabled(id) {
        var list = root.enabledPlugins || []
        return list.indexOf(String(id)) >= 0
    }

    function registerDefaultPlugin(id) {
        var pid = String(id || "")
        if (pid === "") return
        if (!root._loaded) {
            if (root._pendingDefaultPlugins.indexOf(pid) < 0) {
                root._pendingDefaultPlugins.push(pid)
            }
            return
        }
        var enList = (root.enabledPlugins || []).slice()
        var disList = root.disabledPlugins || []
        if (enList.indexOf(pid) < 0 && disList.indexOf(pid) < 0) {
            enList.push(pid)
            root.enabledPlugins = enList
            save()
        }
    }

    function togglePluginEnabled(id, title) {
        var pid = String(id || "")
        if (pid === "") return
        recordUndo((title || pid) + I18n.t(" eklentisi güncellendi", " plugin updated"))
        var list = (root.enabledPlugins || []).slice()
        var disList = (root.disabledPlugins || []).slice()
        var idx = list.indexOf(pid)
        if (idx >= 0) {
            list.splice(idx, 1)
            if (disList.indexOf(pid) < 0) disList.push(pid)
        } else {
            list.push(pid)
            var dIdx = disList.indexOf(pid)
            if (dIdx >= 0) disList.splice(dIdx, 1)
        }
        root.enabledPlugins = list
        root.disabledPlugins = disList
        save()
    }

    // ── Hypridle Canli Guc ve Otomatik Kilit ─────────────────────────
    FileView {
        id: hypridleFile
        path: root.configDir + "/hypridle.conf"
        printErrors: false
        blockLoading: false
    }

    function buildHypridleConf() {
        var lines = [
            "# Enyxma OS — Otomatik uretilen hypridle yapilandirmasi",
            "general {",
            "    lock_cmd = pidof hyprlock || hyprlock",
            "    before_sleep_cmd = loginctl lock-session",
            "    after_sleep_cmd = hyprctl dispatch dpms on",
            "    ignore_dbus_inhibit = false",
            "}",
            ""
        ]
        if (root.idleLockMin > 0) {
            lines.push("listener {")
            lines.push("    timeout = " + (root.idleLockMin * 60))
            lines.push("    on-timeout = loginctl lock-session")
            lines.push("}")
            lines.push("")
        }
        if (root.idleScreenOffMin > 0) {
            lines.push("listener {")
            lines.push("    timeout = " + (root.idleScreenOffMin * 60))
            lines.push("    on-timeout = hyprctl dispatch dpms off")
            lines.push("    on-resume = hyprctl dispatch dpms on")
            lines.push("}")
            lines.push("")
        }
        if (root.idleSuspendMin > 0) {
            lines.push("listener {")
            lines.push("    timeout = " + (root.idleSuspendMin * 60))
            lines.push("    on-timeout = systemctl suspend")
            lines.push("}")
            lines.push("")
        }
        return lines.join("\n")
    }

    Process {
        id: idleKillProc
        running: false
        command: ["pkill", "-x", "hypridle"]
        onExited: {
            if (root.idleEnabled) {
                Quickshell.execDetached(["hypridle", "-c", root.configDir + "/hypridle.conf"])
            }
        }
    }

    function applyIdleSettings() {
        try {
            hypridleFile.setText(buildHypridleConf())
        } catch (e) {
            console.warn("SettingsState: hypridle.conf yazilamadi:", e)
        }
        idleKillProc.running = false
        idleKillProc.running = true
    }

    function setIdleSetting(prop, value, label) {
        recordUndo(label)
        root[prop] = value
        applyIdleSettings()
        save()
    }

    function resetHyprStyle() {
        recordUndo(I18n.t("Pencere stili tema varsayılanına döndü", "Window style reset to theme default"))
        root.customHyprStyle = false
        save()
        Quickshell.execDetached(["hyprctl", "reload"])
    }

    function setInputSetting(prop, value, label) {
        recordUndo(label)
        root[prop] = value
        applyInputSettings()
        save()
    }

    Process {
        id: hyprInputProc
        running: false
        property string fallbackBatch: ""
        stdout: StdioCollector { id: hyprInputOut }
        onExited: (code) => {
            if (code === 0 && (hyprInputOut.text || "").trim() === "ok") return
            if (fallbackBatch !== "") {
                Quickshell.execDetached(["hyprctl", "--batch", fallbackBatch])
            }
        }
    }

    function applyInputSettings() {
        var sens = Number(root.mouseSensitivity).toFixed(2)
        var luaExpr = "hl.config({ input = { kb_layout = \"" + escapeLuaStr(root.kbLayout)
            + "\", repeat_rate = " + root.kbRepeatRate
            + ", repeat_delay = " + root.kbRepeatDelay
            + ", sensitivity = " + sens
            + ", touchpad = { natural_scroll = " + (root.naturalScroll ? "true" : "false") + " } } })"
        var cmds = [
            "keyword input:kb_layout " + root.kbLayout,
            "keyword input:repeat_rate " + root.kbRepeatRate,
            "keyword input:repeat_delay " + root.kbRepeatDelay,
            "keyword input:sensitivity " + sens,
            "keyword input:touchpad:natural_scroll " + (root.naturalScroll ? "true" : "false")
        ]
        hyprInputProc.fallbackBatch = cmds.join(" ; ")
        hyprInputProc.command = ["hyprctl", "eval", luaExpr]
        hyprInputProc.running = false
        hyprInputProc.running = true
    }

    // ── Ekran ve Monitor Yonetimi ────────────────────────────────────
    function refreshMonitors() {
        if (monitorsProc.running) return
        monitorsProc.running = true
    }

    Timer {
        id: monitorRefreshDelay
        interval: 350
        repeat: false
        onTriggered: root.refreshMonitors()
    }

    Process {
        id: hyprMonitorProc
        running: false
        property string fallbackSpec: ""
        stdout: StdioCollector { id: hyprMonitorOut }
        onExited: (code) => {
            if (!(code === 0 && (hyprMonitorOut.text || "").trim() === "ok") && fallbackSpec !== "") {
                Quickshell.execDetached(["hyprctl", "keyword", "monitor", fallbackSpec])
            }
            monitorRefreshDelay.restart()
        }
    }

    function applyMonitorMode(name, modeSpec, posX, posY, scaleVal) {
        var scaleStr = Number(scaleVal).toFixed(2)
        var posStr = posX + "x" + posY
        var luaExpr = "hl.monitor({ output = \"" + escapeLuaStr(name)
            + "\", mode = \"" + escapeLuaStr(modeSpec)
            + "\", position = \"" + posStr
            + "\", scale = " + scaleStr + " })"
        hyprMonitorProc.fallbackSpec = name + "," + modeSpec + "," + posStr + "," + scaleStr
        hyprMonitorProc.command = ["hyprctl", "eval", luaExpr]
        hyprMonitorProc.running = false
        hyprMonitorProc.running = true
    }

    function setMonitorScale(name, width, height, hz, posX, posY, scaleVal) {
        applyMonitorMode(name, width + "x" + height + "@" + Math.round(hz), posX, posY, scaleVal)
    }

    Process {
        id: monitorsProc
        running: false
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector { id: monitorsOut }
        onExited: (code) => {
            if (code !== 0) return
            try {
                var arr = JSON.parse(monitorsOut.text || "[]")
                if (!Array.isArray(arr)) return
                var out = []
                for (var i = 0; i < arr.length; i++) {
                    var m = arr[i]
                    var rawModes = Array.isArray(m.availableModes) ? m.availableModes : []
                    var seenModes = {}
                    var topModes = []
                    for (var j = 0; j < rawModes.length; j++) {
                        var raw = String(rawModes[j])
                        var pm = raw.match(/^(\d+x\d+)@([0-9.]+)Hz$/)
                        if (!pm) continue
                        var label = pm[1] + " @ " + Math.round(parseFloat(pm[2])) + "Hz"
                        var spec = pm[1] + "@" + Math.round(parseFloat(pm[2]))
                        if (seenModes[spec]) continue
                        seenModes[spec] = true
                        topModes.push({ label: label, spec: spec })
                        if (topModes.length >= 6) break
                    }
                    out.push({
                        name: m.name || "",
                        model: m.model || m.description || "",
                        width: m.width || 1920,
                        height: m.height || 1080,
                        refreshRate: m.refreshRate || 60,
                        scale: m.scale || 1.0,
                        x: m.x || 0,
                        y: m.y || 0,
                        modes: topModes
                    })
                }
                root.monitors = out
            } catch (e) {
                console.warn("SettingsState: monitor JSON okunamadi:", e)
            }
        }
    }

    function setLanguage(code) {
        var next = (String(code || "").toLowerCase() === "en") ? "en" : "tr"
        if (next === root.language) return
        recordUndo(next === "en" ? "Language: English" : "Arayüz dili: Türkçe")
        root.language = next
        root.shortcuts = defaultShortcuts()
        bindsFile.reload()
        save()
    }

    function resetDefaults() {
        recordUndo(root.language === "en" ? "Reset to defaults" : "Varsayılan ayarlara dönüldü")
        language = "tr"
        reduceMotion = false
        barVisible = true
        barHeightOffset = 0
        customHyprStyle = false
        hyprRounding = 8
        hyprGapsIn = 4
        hyprGapsOut = 8
        hyprBorderSize = 2
        hyprBlur = true
        hyprActiveOpacity = 1.0
        hyprInactiveOpacity = 0.95
        hyprShadow = true
        hyprAnimations = true
        hyprVrr = 0
        nightLightEnabled = false
        nightLightTemp = 4500
        notifTimeoutSec = 5
        defaultTerminal = "kitty"
        defaultFileManager = "nautilus"
        idleEnabled = true
        idleLockMin = 5
        idleScreenOffMin = 10
        idleSuspendMin = 0
        kbLayout = "tr"
        kbRepeatRate = 35
        kbRepeatDelay = 250
        mouseSensitivity = 0.0
        naturalScroll = false
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
        enabledPlugins = []
        disabledPlugins = []
        applyInputSettings()
        Quickshell.execDetached(["hyprctl", "reload"])
        save()
    }

    function openConfigFile() {
        save()
        Quickshell.execDetached(["enyxma-launch", "xdg-open", root.configPath])
    }

    // Dizin hazirligi
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
            if (d.language === "en" || d.language === "tr") root.language = d.language
            if (typeof d.reduceMotion === "boolean") root.reduceMotion = d.reduceMotion
            if (typeof d.barVisible === "boolean") root.barVisible = d.barVisible
            if (typeof d.barHeightOffset === "number") root.barHeightOffset = Math.max(-4, Math.min(8, Math.round(d.barHeightOffset)))
            if (typeof d.customHyprStyle === "boolean") root.customHyprStyle = d.customHyprStyle
            if (typeof d.hyprRounding === "number") root.hyprRounding = Math.max(0, Math.min(24, Math.round(d.hyprRounding)))
            if (typeof d.hyprGapsIn === "number") root.hyprGapsIn = Math.max(0, Math.min(24, Math.round(d.hyprGapsIn)))
            if (typeof d.hyprGapsOut === "number") root.hyprGapsOut = Math.max(0, Math.min(32, Math.round(d.hyprGapsOut)))
            if (typeof d.hyprBorderSize === "number") root.hyprBorderSize = Math.max(0, Math.min(6, Math.round(d.hyprBorderSize)))
            if (typeof d.hyprBlur === "boolean") root.hyprBlur = d.hyprBlur
            if (typeof d.hyprActiveOpacity === "number") root.hyprActiveOpacity = Math.max(0.70, Math.min(1.0, d.hyprActiveOpacity))
            if (typeof d.hyprInactiveOpacity === "number") root.hyprInactiveOpacity = Math.max(0.65, Math.min(1.0, d.hyprInactiveOpacity))
            if (typeof d.hyprShadow === "boolean") root.hyprShadow = d.hyprShadow
            if (typeof d.hyprAnimations === "boolean") root.hyprAnimations = d.hyprAnimations
            if (typeof d.hyprVrr === "number") root.hyprVrr = Math.max(0, Math.min(2, Math.round(d.hyprVrr)))
            if (typeof d.nightLightEnabled === "boolean") root.nightLightEnabled = d.nightLightEnabled
            if (typeof d.nightLightTemp === "number") root.nightLightTemp = Math.max(3000, Math.min(6000, Math.round(d.nightLightTemp)))
            if (typeof d.notifTimeoutSec === "number") root.notifTimeoutSec = Math.max(2, Math.min(20, Math.round(d.notifTimeoutSec)))
            if (typeof d.defaultTerminal === "string" && d.defaultTerminal.length > 0) root.defaultTerminal = d.defaultTerminal
            if (typeof d.defaultFileManager === "string" && d.defaultFileManager.length > 0) root.defaultFileManager = d.defaultFileManager
            if (typeof d.idleEnabled === "boolean") root.idleEnabled = d.idleEnabled
            if (typeof d.idleLockMin === "number") root.idleLockMin = Math.max(0, Math.min(60, Math.round(d.idleLockMin)))
            if (typeof d.idleScreenOffMin === "number") root.idleScreenOffMin = Math.max(0, Math.min(120, Math.round(d.idleScreenOffMin)))
            if (typeof d.idleSuspendMin === "number") root.idleSuspendMin = Math.max(0, Math.min(240, Math.round(d.idleSuspendMin)))
            if (typeof d.kbLayout === "string" && d.kbLayout.length > 0) root.kbLayout = d.kbLayout
            if (typeof d.kbRepeatRate === "number") root.kbRepeatRate = Math.max(15, Math.min(80, Math.round(d.kbRepeatRate)))
            if (typeof d.kbRepeatDelay === "number") root.kbRepeatDelay = Math.max(150, Math.min(600, Math.round(d.kbRepeatDelay)))
            if (typeof d.mouseSensitivity === "number") root.mouseSensitivity = Math.max(-0.8, Math.min(0.8, d.mouseSensitivity))
            if (typeof d.naturalScroll === "boolean") root.naturalScroll = d.naturalScroll
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
            if (Array.isArray(d.enabledPlugins)) root.enabledPlugins = d.enabledPlugins
            if (Array.isArray(d.disabledPlugins)) root.disabledPlugins = d.disabledPlugins
            while (root._pendingDefaultPlugins.length > 0) {
                root.registerDefaultPlugin(root._pendingDefaultPlugins.shift())
            }
            if (root.customHyprStyle) root.applyHyprStyle()
            root.applyInputSettings()
            if (root.nightLightEnabled) root.applyNightLight()
            root.applyIdleSettings()
        } catch (e) {
            console.warn("SettingsState: JSON okunamadi:", e)
        }
    }

    function save() {
        try {
            settingsFile.setText(JSON.stringify(snapshotPayload(), null, 2))
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
        var en = root.language === "en"
        if (s.indexOf("terminal") >= 0) return en ? "Open terminal" : "Terminal aç"
        if (s.indexOf("app_launcher") >= 0 || s.indexOf("\"launcher\", \"toggle\"") >= 0) return en ? "App & command launcher" : "Uygulama ve komut başlatıcısı"
        if (s.indexOf("\"launcher\", \"menu\"") >= 0) return en ? "Command palette" : "Komut paleti"
        if (s.indexOf("clipboard") >= 0) return en ? "Clipboard history" : "Pano geçmişi"
        if (s.indexOf("\"settings\"") >= 0) return en ? "Enyxma Settings window" : "Enyxma Ayarlar penceresi"
        if (s.indexOf("\"wallpaper\", \"cycle\"") >= 0) return en ? "Cycle theme — Dynamic / Gotham" : "Tema değiştir — Dinamik / Gotham"
        if (s.indexOf("\"wallpaper\", \"toggle\"") >= 0) return en ? "Wallpaper gallery" : "Duvar kağıdı galerisi"
        if (s.indexOf("screenshot_studio") >= 0) return en ? "Screenshot & annotation studio" : "Ekran alıntısı ve çizim stüdyosu"
        if (s.indexOf("screenshot_save_full") >= 0) return en ? "Save full-screen capture" : "Tam ekran görüntüsü kaydet"
        if (s.indexOf("screenshot_screen") >= 0) return en ? "Copy full-screen capture" : "Tam ekran görüntüsü panoya"
        if (s.indexOf("file_manager") >= 0) return en ? "File manager" : "Dosya yöneticisi"
        if (s.indexOf("tui_file_manager") >= 0) return en ? "Yazi file manager" : "Yazi dosya yöneticisi"
        if (s.indexOf("web_browser") >= 0) return en ? "Web browser" : "Web tarayıcı"
        if (s.indexOf("screen_lock") >= 0) return en ? "Lock screen" : "Ekranı kilitle"
        if (s.indexOf("\"overview\"") >= 0) return en ? "Overview — workspace strip" : "Genel bakış — masaüstü şeridi"
        if (s.indexOf("\"dashboard\"") >= 0) return en ? "Control Center" : "Kontrol Merkezi"
        if (s.indexOf("\"ai\"") >= 0) return en ? "Enyxma AI sidebar" : "Enyxma AI kenar çubuğu"
        if (s.indexOf("\"notifications\"") >= 0) return en ? "Notification center" : "Bildirim merkezi"
        if (s.indexOf("\"bar\"") >= 0) return en ? "Toggle top bar" : "Üst çubuğu gizle / göster"
        if (s.indexOf("window.close") >= 0) return en ? "Close active window" : "Aktif pencereyi kapat"
        if (s.indexOf("window.kill") >= 0) return en ? "Force-kill active window" : "Aktif pencereyi zorla sonlandır"
        if (s.indexOf("fullscreen") >= 0 && s.indexOf("maximized") >= 0) return en ? "Maximize window" : "Pencereyi büyüt"
        if (s.indexOf("fullscreen") >= 0) return en ? "Toggle fullscreen" : "Tam ekran aç / kapat"
        if (s.indexOf("float") >= 0) return en ? "Toggle floating mode" : "Yüzen pencere modu"
        if (s.indexOf("window.pin") >= 0) return en ? "Pin window" : "Pencereyi sabitle"
        if (s.indexOf("window.center") >= 0) return en ? "Center floating window" : "Yüzen pencereyi ortala"
        if (s.indexOf("GamingMode") >= 0) return en ? "Gaming mode" : "Oyun modu"
        if (s.indexOf("enyxma-record panel") >= 0) return en ? "Screen recording studio" : "Ekran kaydı stüdyosu"
        if (s.indexOf("enyxma-record pause") >= 0) return en ? "Pause / resume recording" : "Ekran kaydını duraklat / devam et"
        if (s.indexOf("enyxma-record replay save") >= 0) return en ? "Save recent moment clip" : "Son an klibini kaydet"
        if (s.indexOf("enyxma-record") >= 0) return en ? "Quick start / stop recording" : "Hızlı ekran kaydı başlat / durdur"
        if (s.indexOf("hyprctl reload") >= 0) return en ? "Reload Hyprland config" : "Hyprland yapılandırmasını yenile"
        if (s.indexOf("hyprshutdown") >= 0) return en ? "Exit session" : "Oturumu kapat"
        if (s.indexOf("togglesplit") >= 0) return en ? "Toggle split direction" : "Bölme yönünü değiştir"
        if (s.indexOf("group.toggle") >= 0) return en ? "Tabbed window group" : "Sekmeli pencere grubu"
        if (s.indexOf("toggle_special") >= 0) return en ? "Toggle special workspace" : "Özel çalışma alanını aç / kapat"
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
        function setLanguage(code: string): void { root.setLanguage(code) }
    }
}
