pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isOpen: false
    property string searchText: ""

    onIsOpenChanged: {
        WallpaperState.dimLevel = (isOpen || AIState.isOpen) ? 0.3 : 0.0
    }

    function toggle() {
        if (isOpen) {
            close()
        } else {
            open()
        }
    }

    function open() {
        searchText = ""
        isOpen = true
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

    // Sistemde kurulu tüm görüntülenebilir uygulamalar
    readonly property var allApps: {
        const raw = DesktopEntries.applications?.values ?? []
        return raw.filter(entry => entry && !entry.noDisplay && (entry.name || "").length > 0)
    }

    // Arama metnine göre filtrelenmiş liste
    readonly property var filteredApps: {
        const query = searchText.trim().toLowerCase()
        if (!query) {
            // Boşken alfabetik olarak sıralı göster
            return allApps.slice().sort((a, b) => (a.name || "").localeCompare(b.name || ""))
        }

        return allApps.filter(entry => {
            const name = (entry.name || "").toLowerCase()
            const gen = (entry.genericName || "").toLowerCase()
            const comm = (entry.comment || "").toLowerCase()
            const id = (entry.id || "").toLowerCase()
            return name.includes(query) || gen.includes(query) || comm.includes(query) || id.includes(query)
        }).sort((a, b) => {
            // İsimle tam başlayanlara öncelik ver
            const aStarts = (a.name || "").toLowerCase().startsWith(query)
            const bStarts = (b.name || "").toLowerCase().startsWith(query)
            if (aStarts && !bStarts) return -1
            if (!aStarts && bStarts) return 1
            return (a.name || "").localeCompare(b.name || "")
        })
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }
    }

    IpcHandler {
        target: "enyxma-launcher"

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }
    }
}
