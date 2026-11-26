pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    property bool isOpen: false
    property string searchText: ""
    property string activeMode: "apps" // apps | actions | clipboard
    property var clipboardItems: []
    property bool clipboardLoading: false
    property string pendingClipId: ""

    readonly property var modes: {
        var _l = I18n.lang
        return [
            { id: "apps",      label: I18n.t("Uygulamalar", "Apps"),     icon: "󰀻" },
            { id: "actions",   label: I18n.t("Komutlar", "Commands"),    icon: "󰘳" },
            { id: "clipboard", label: I18n.t("Pano", "Clipboard"),       icon: "󰅍" }
        ]
    }

    readonly property var systemActions: {
        var _l = I18n.lang
        return [
            { id: "theme-cycle",       title: I18n.t("Tema Değiştir — Dynamic / Gotham", "Cycle Theme — Dynamic / Gotham"),         subtitle: I18n.t("Aktif masaüstü tasarım kimliğini ve renk motorunu değiştirir", "Switches active desktop visual identity and color engine"),      icon: "󰏘", badge: "SUPER + T" },
            { id: "wallpaper-picker",  title: I18n.t("Duvar Kağıdı Koleksiyonu", "Wallpaper Collection"),                            subtitle: I18n.t("Temaya özel duvar kağıdı galerisini açar", "Opens theme-specific wallpaper gallery"),                                         icon: "󰸉", badge: "SUPER + SHIFT + T" },
            { id: "screenshot-studio", title: I18n.t("Ekran Alıntısı ve Çizim Stüdyosu", "Screenshot & Annotation Studio"),          subtitle: I18n.t("Bölge seçimi, ok, kutu, sansür ve çerçeveleme aracı", "Region selection, arrows, boxes, redaction, and framing tool"),          icon: "󰄀", badge: "SUPER + SHIFT + S" },
            { id: "overview",          title: I18n.t("Genel Bakış — Masaüstü Şeridi", "Overview — Workspace Strip"),                 subtitle: I18n.t("Tüm açık pencereleri ve çalışma alanlarını yönetir", "Manages all open windows and workspaces"),                               icon: "󰕮", badge: "SUPER + TAB" },
            { id: "control-center",    title: I18n.t("Kontrol Merkezi", "Control Center"),                                           subtitle: I18n.t("Ses, parlaklık, gece ışığı, Bluetooth ve hızlı ayarlar", "Volume, brightness, night light, Bluetooth, and quick settings"),       icon: "󰒓", badge: "SUPER + D" },
            { id: "enyxma-settings",   title: I18n.t("Enyxma Ayarlar", "Enyxma Settings"),                                           subtitle: I18n.t("Görünüm, üst çubuk modülleri, kısayollar ve sistem tercihleri", "Appearance, top bar modules, shortcuts, and system preferences"),   icon: "󰒓", badge: "SUPER + I" },
            { id: "ai-assistant",      title: I18n.t("Enyxma AI Kenar Çubuğu", "Enyxma AI Sidebar"),                                 subtitle: I18n.t("Yapay zeka sohbet, araçlar ve kullanım paneli", "AI chat, tools, and usage panel"),                                                icon: "󰧑", badge: "SUPER + S" },
            { id: "performance-panel", title: I18n.t("Sistem Performans ve Telemetri Paneli", "System Performance & Telemetry"),     subtitle: I18n.t("Canlı CPU, RAM ve süreç kaynak kullanımı", "Live CPU, RAM, and process resource usage"),                                       icon: "󰍛", badge: I18n.t("TELEMETRİ", "TELEMETRY") },
            { id: "network-panel",     title: I18n.t("Ağ ve Bağlantı Yönetimi", "Network & Connection Manager"),                     subtitle: I18n.t("Wi-Fi, Ethernet ve veri akışı bilgileri", "Wi-Fi, Ethernet, and data flow details"),                                         icon: "󰤨", badge: I18n.t("AĞ", "NETWORK") },
            { id: "storage-panel",     title: I18n.t("Depolama ve Disk Durumu", "Storage & Disk Status"),                            subtitle: I18n.t("Btrfs bölümleri ve disk doluluk analizi", "Btrfs partitions and disk usage analysis"),                                       icon: "󰋊", badge: I18n.t("DİSK", "STORAGE") },
            { id: "media-gallery",     title: I18n.t("Ekran Görüntüsü ve Medya Galerisi", "Screenshot & Media Gallery"),             subtitle: I18n.t("Kaydedilen ekran alıntılarını ve videoları görüntüler", "Views saved screenshots and videos"),                                       icon: "󰋩", badge: I18n.t("GALERİ", "GALLERY") },
            { id: "system-update",     title: I18n.t("Enyxma OS Sistem Güncellemesi", "Enyxma OS System Update"),                    subtitle: I18n.t("Uzak depodan son değişiklikleri çeker ve sistemi yeni nesle yükseltir", "Pulls latest changes from remote and upgrades the system"), icon: "󰚰", badge: "enyxma update" },
            { id: "clipboard-wipe",    title: I18n.t("Pano Geçmişini Temizle", "Clear Clipboard History"),                           subtitle: I18n.t("Kaydedilen tüm cliphist pano kayıtlarını sıfırlar", "Resets all saved cliphist clipboard entries"),                                icon: "󰃢", badge: I18n.t("TEMİZLE", "CLEAR") },
            { id: "lock-screen",       title: I18n.t("Ekranı Kilitle", "Lock Screen"),                                               subtitle: I18n.t("Hyprlock ile oturumu güvenli şekilde kilitler", "Securely locks the session with Hyprlock"),                                       icon: "󰌾", badge: "SUPER + L" },
            { id: "suspend-system",    title: I18n.t("Uyku Moduna Geç", "Suspend System"),                                           subtitle: I18n.t("Sistemi düşük güç tüketimli askı durumuna alır", "Puts the system into low-power suspend state"),                                   icon: "󰒲", badge: I18n.t("UYKU", "SUSPEND") },
            { id: "reboot-system",     title: I18n.t("Sistemi Yeniden Başlat", "Reboot System"),                                     subtitle: I18n.t("Bilgisayarı güvenli biçimde yeniden başlatır", "Safely reboots the computer"),                                                      icon: "󰑓", badge: "REBOOT" },
            { id: "poweroff-system",   title: I18n.t("Sistemi Kapat", "Power Off System"),                                           subtitle: I18n.t("Tüm servisleri durdurup bilgisayarı kapatır", "Stops all services and powers off the computer"),                                     icon: "⏻", badge: I18n.t("KAPAT", "POWER OFF") }
        ]
    }

    onIsOpenChanged: {
        WallpaperState.dimLevel = (isOpen || AIState.isOpen) ? 0.3 : 0.0
    }

    function normalizeMode(mode) {
        if (mode === "actions" || mode === "clipboard") return mode
        return "apps"
    }

    function toggle() {
        if (isOpen) {
            close()
        } else {
            open("apps")
        }
    }

    function open(mode) {
        const target = normalizeMode(mode)
        activeMode = target
        searchText = ""
        isOpen = true
        if (target === "clipboard") {
            refreshClipboard()
        }
    }

    function openMode(mode) {
        const target = normalizeMode(mode)
        if (isOpen && activeMode === target) {
            close()
        } else {
            open(target)
        }
    }

    function setMode(mode) {
        const target = normalizeMode(mode)
        if (activeMode === target) return
        activeMode = target
        searchText = ""
        if (target === "clipboard") {
            refreshClipboard()
        }
    }

    function cycleMode(step) {
        const order = ["apps", "actions", "clipboard"]
        const idx = order.indexOf(activeMode)
        const next = (idx + (step || 1) + order.length) % order.length
        setMode(order[next])
    }

    function close() {
        isOpen = false
        searchText = ""
    }

    function launch(entry) {
        if (!entry) return
        close()
        try {
            var cmd = entry.command || []
            if (cmd && cmd.length > 0) {
                var argv = ["enyxma-launch"]
                if (entry.runInTerminal) {
                    argv.push("kitty", "-e")
                }
                for (var i = 0; i < cmd.length; i++) {
                    argv.push(String(cmd[i]))
                }
                if (entry.workingDirectory && String(entry.workingDirectory).length > 0) {
                    Quickshell.execDetached({ command: argv, workingDirectory: String(entry.workingDirectory) })
                } else {
                    Quickshell.execDetached(argv)
                }
                return
            }
            entry.execute()
        } catch (e) {
            console.warn("Launcher: Uygulama başlatılamadı:", e)
        }
    }

    function refreshClipboard() {
        clipboardLoading = true
        clipListProc.exec(["cliphist", "list"])
    }

    function selectClipboardItem(item) {
        if (!item || !item.id) return
        root.pendingClipId = String(item.id)
        close()
        clipDecodeProc.exec(["cliphist", "decode", root.pendingClipId])
    }

    function wipeClipboard() {
        close()
        clipboardItems = []
        clipWipeProc.exec(["cliphist", "wipe"])
    }

    function runSystemAction(actionId) {
        close()
        switch (actionId) {
        case "theme-cycle":
            WallpaperState.cycleTheme()
            break
        case "wallpaper-picker":
            WallpaperState.openPicker()
            break
        case "screenshot-studio":
            Quickshell.execDetached(["enyxma-shot"])
            break
        case "overview":
            OverviewState.open()
            break
        case "control-center":
            SystemState.openControlCenter()
            break
        case "enyxma-settings":
            SettingsState.open("")
            break
        case "ai-assistant":
            AIState.open()
            break
        case "performance-panel":
            PerformanceState.open()
            break
        case "network-panel":
            NetworkState.open()
            break
        case "storage-panel":
            StorageState.open()
            break
        case "media-gallery":
            MediaBrowserState.open("screenshots")
            break
        case "system-update":
            Quickshell.execDetached(["enyxma-launch", "kitty", "-e", "enyxma", "update"])
            break
        case "clipboard-wipe":
            clipboardItems = []
            clipWipeProc.exec(["cliphist", "wipe"])
            break
        case "lock-screen":
            Quickshell.execDetached(["hyprlock"])
            break
        case "suspend-system":
            Quickshell.execDetached(["systemctl", "suspend"])
            break
        case "reboot-system":
            Quickshell.execDetached(["systemctl", "reboot"])
            break
        case "poweroff-system":
            Quickshell.execDetached(["systemctl", "poweroff"])
            break
        }
    }

    function activateItem(item) {
        if (!item) return
        if (item.kind === "app") {
            launch(item.entry)
        } else if (item.kind === "action") {
            runSystemAction(item.id)
        } else if (item.kind === "clipboard") {
            selectClipboardItem(item)
        }
    }

    Process {
        id: clipListProc
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                const items = []
                for (let i = 0; i < lines.length && items.length < 60; i++) {
                    const line = lines[i]
                    if (!line) continue
                    const tab = line.indexOf("\t")
                    if (tab <= 0) continue
                    const id = line.substring(0, tab).trim()
                    const preview = line.substring(tab + 1).trim()
                    if (id.length === 0) continue
                    items.push({
                        id: id,
                        preview: preview.length > 0 ? preview : I18n.t("İkili veya boş içerik", "Binary or empty content")
                    })
                }
                root.clipboardItems = items
                root.clipboardLoading = false
            }
        }
        onExited: (code) => {
            if (code !== 0) {
                root.clipboardLoading = false
            }
        }
    }

    Process {
        id: clipDecodeProc
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text && this.text.length > 0) {
                    Quickshell.execDetached(["wl-copy", "--", this.text])
                    Quickshell.execDetached(["notify-send", "-a", "Enyxma", "-t", "1800", I18n.t("Pano", "Clipboard"), I18n.t("Seçilen öğe panoya kopyalandı", "Selected item copied to clipboard")])
                }
            }
        }
    }

    Process {
        id: clipWipeProc
        running: false
        onExited: (code) => {
            if (code === 0) {
                root.clipboardItems = []
                Quickshell.execDetached(["notify-send", "-a", "Enyxma", "-t", "1800", I18n.t("Pano", "Clipboard"), I18n.t("Pano geçmişi temizlendi", "Clipboard history cleared")])
            }
        }
    }

    // Sistemde kurulu tüm görüntülenebilir uygulamalar
    readonly property var allApps: {
        const raw = DesktopEntries.applications?.values ?? []
        return raw.filter(entry => entry && !entry.noDisplay && (entry.name || "").length > 0)
    }

    // Arama metnine göre filtrelenmiş uygulamalar
    readonly property var filteredApps: {
        const query = searchText.trim().toLowerCase()
        if (!query) {
            return allApps.slice().sort((a, b) => (a.name || "").localeCompare(b.name || ""))
        }

        return allApps.filter(entry => {
            const name = (entry.name || "").toLowerCase()
            const gen = (entry.genericName || "").toLowerCase()
            const comm = (entry.comment || "").toLowerCase()
            const id = (entry.id || "").toLowerCase()
            return name.includes(query) || gen.includes(query) || comm.includes(query) || id.includes(query)
        }).sort((a, b) => {
            const aStarts = (a.name || "").toLowerCase().startsWith(query)
            const bStarts = (b.name || "").toLowerCase().startsWith(query)
            if (aStarts && !bStarts) return -1
            if (!aStarts && bStarts) return 1
            return (a.name || "").localeCompare(b.name || "")
        })
    }

    // Arama metnine göre filtrelenmiş sistem komutları
    readonly property var filteredActions: {
        const query = searchText.trim().toLowerCase()
        if (!query) return systemActions
        return systemActions.filter(act =>
            act.title.toLowerCase().includes(query) ||
            act.subtitle.toLowerCase().includes(query) ||
            act.badge.toLowerCase().includes(query) ||
            act.id.toLowerCase().includes(query)
        )
    }

    // Arama metnine göre filtrelenmiş pano kayıtları
    readonly property var filteredClipboard: {
        const query = searchText.trim().toLowerCase()
        if (!query) return clipboardItems
        return clipboardItems.filter(item =>
            item.preview.toLowerCase().includes(query) ||
            item.id.toLowerCase().includes(query)
        )
    }

    // Aktif sekmeye göre tek tip liste öğeleri
    readonly property var currentItems: {
        if (activeMode === "actions") {
            return filteredActions.map(act => ({
                kind: "action",
                id: act.id,
                title: act.title,
                subtitle: act.subtitle,
                iconName: "",
                iconGlyph: act.icon,
                badge: act.badge,
                entry: null
            }))
        }
        if (activeMode === "clipboard") {
            return filteredClipboard.map(clip => ({
                kind: "clipboard",
                id: clip.id,
                title: clip.preview,
                subtitle: I18n.t("Pano kaydı #", "Clipboard entry #") + clip.id,
                iconName: "",
                iconGlyph: "󰅍",
                badge: I18n.t("KOPYALA", "COPY"),
                entry: null
            }))
        }
        return filteredApps.map(entry => ({
            kind: "app",
            id: entry.id || "",
            title: entry.name || "",
            subtitle: entry.genericName || entry.comment || entry.id || "",
            iconName: entry.icon || "",
            iconGlyph: "󰀻",
            badge: "↵",
            entry: entry
        }))
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle() }
        function open(): void { root.open("apps") }
        function close(): void { root.close() }
        function menu(): void { root.openMode("actions") }
        function clipboard(): void { root.openMode("clipboard") }
    }

    IpcHandler {
        target: "enyxma-launcher"

        function toggle(): void { root.toggle() }
        function open(): void { root.open("apps") }
        function close(): void { root.close() }
        function menu(): void { root.openMode("actions") }
        function clipboard(): void { root.openMode("clipboard") }
    }
}
