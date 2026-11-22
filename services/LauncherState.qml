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

    readonly property var modes: [
        { id: "apps",      label: "Uygulamalar", icon: "󰀻" },
        { id: "actions",   label: "Komutlar",    icon: "󰘳" },
        { id: "clipboard", label: "Pano",        icon: "󰅍" }
    ]

    readonly property var systemActions: [
        { id: "theme-cycle",       title: "Tema Değiştir — Dynamic / Gotham",      subtitle: "Aktif masaüstü tasarım kimliğini ve renk motorunu değiştirir",      icon: "󰏘", badge: "SUPER + T" },
        { id: "wallpaper-picker",  title: "Duvar Kağıdı Koleksiyonu",              subtitle: "Temaya özel duvar kağıdı galerisini açar",                         icon: "󰸉", badge: "SUPER + SHIFT + T" },
        { id: "screenshot-studio", title: "Ekran Alıntısı ve Çizim Stüdyosu",      subtitle: "Bölge seçimi, ok, kutu, sansür ve çerçeveleme aracı",              icon: "󰄀", badge: "SUPER + SHIFT + S" },
        { id: "overview",          title: "Genel Bakış — Masaüstü Şeridi",         subtitle: "Tüm açık pencereleri ve çalışma alanlarını yönetir",               icon: "󰕮", badge: "SUPER + TAB" },
        { id: "control-center",    title: "Kontrol Merkezi",                       subtitle: "Ses, parlaklık, gece ışığı, Bluetooth ve hızlı ayarlar",           icon: "󰒓", badge: "SUPER + D" },
        { id: "ai-assistant",      title: "Enyxma AI Kenar Çubuğu",                subtitle: "Yapay zeka sohbet, araçlar ve kullanım paneli",                    icon: "󰧑", badge: "SUPER + S" },
        { id: "performance-panel", title: "Sistem Performans ve Telemetri Paneli",  subtitle: "Canlı CPU, RAM ve süreç kaynak kullanımı",                         icon: "󰍛", badge: "TELEMETRİ" },
        { id: "network-panel",     title: "Ağ ve Bağlantı Yönetimi",               subtitle: "Wi-Fi, Ethernet ve veri akışı bilgileri",                          icon: "󰤨", badge: "AĞ" },
        { id: "storage-panel",     title: "Depolama ve Disk Durumu",               subtitle: "Btrfs bölümleri ve disk doluluk analizi",                          icon: "󰋊", badge: "DİSK" },
        { id: "media-gallery",     title: "Ekran Görüntüsü ve Medya Galerisi",     subtitle: "Kaydedilen ekran alıntılarını ve videoları görüntüler",            icon: "󰋩", badge: "GALERİ" },
        { id: "system-update",     title: "Enyxma OS Sistem Güncellemesi",         subtitle: "Uzak depodan son değişiklikleri çeker ve sistemi yeni nesle yükseltir", icon: "󰚰", badge: "enyxma update" },
        { id: "clipboard-wipe",    title: "Pano Geçmişini Temizle",                subtitle: "Kaydedilen tüm cliphist pano kayıtlarını sıfırlar",                icon: "󰃢", badge: "TEMİZLE" },
        { id: "lock-screen",       title: "Ekranı Kilitle",                        subtitle: "Hyprlock ile oturumu güvenli şekilde kilitler",                    icon: "󰌾", badge: "SUPER + L" },
        { id: "suspend-system",    title: "Uyku Moduna Geç",                       subtitle: "Sistemi düşük güç tüketimli askı durumuna alır",                   icon: "󰒲", badge: "UYKU" },
        { id: "reboot-system",     title: "Sistemi Yeniden Başlat",                subtitle: "Bilgisayarı güvenli biçimde yeniden başlatır",                     icon: "󰑓", badge: "REBOOT" },
        { id: "poweroff-system",   title: "Sistemi Kapat",                         subtitle: "Tüm servisleri durdurup bilgisayarı kapatır",                      icon: "⏻", badge: "KAPAT" }
    ]

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
            Quickshell.execDetached(["kitty", "-e", "enyxma", "update"])
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
                        preview: preview.length > 0 ? preview : "İkili veya boş içerik"
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
                    Quickshell.execDetached(["notify-send", "-t", "1800", "Pano", "Seçilen öğe panoya kopyalandı"])
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
                Quickshell.execDetached(["notify-send", "-t", "1800", "Pano", "Pano geçmişi temizlendi"])
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
                subtitle: "Pano kaydı #" + clip.id,
                iconName: "",
                iconGlyph: "󰅍",
                badge: "KOPYALA",
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
