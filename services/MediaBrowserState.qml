pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * MediaBrowserState — ekran görüntüsü / video tarayıcısı.
 *
 * P0 DÜZELTMELERİ:
 *  1. `scanMedia()`: `bash -c` + dizi döngüsü yerine doğrudan `find`
 *     (çoklu başlangıç dizini destekler; kabuk yok).
 *  2. `deleteItem()`: `rm -f` fallback'i KALDIRILDI. Önce `gio trash`,
 *     başarısızsa `trash-put`; ikisi de başarısızsa kullanıcıya hata.
 *     Eski kod çıkış kodunu yok sayıp her durumda "Dosya silindi 🗑️"
 *     diyordu (silinemeyen dosya için sahte başarı).
 *  3. `copyItem()`: dosya yolu stdin ile `wl-copy`'ye yazılır (kabuk yok).
 *     Görsel *piksel* kopyası bu repoda desteklenmiyor — .jpg'yi
 *     `--type image/png` ile kopyalamak bozuk panoya yol açıyordu.
 *  4. `openInMockupStudio()`: `sh -c` kaldırıldı, env objesiyle execDetached.
 */
Singleton {
    id: root

    property bool isOpen: false
    property string mode: "screenshots"
    property var items: []
    property bool isScanning: false
    property string toastText: ""

    readonly property string home: Quickshell.env("HOME") || ""

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
        if (isOpen && mode === m) { isOpen = false; return }
        mode = m
        isOpen = true
        scanMedia()
    }

    function open(targetMode) {
        mode = targetMode || "screenshots"
        isOpen = true
        scanMedia()
    }

    function close() { isOpen = false }

    function formatLabel(path) {
        if (!path) return ""
        var name = String(path).split("/").pop().replace(/\.[^.]+$/, "")
        var m1 = name.match(/(\d{4})_(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})/)
        if (m1) return m1[1] + "-" + m1[2] + "-" + m1[3] + "  " + m1[4] + ":" + m1[5] + ":" + m1[6]
        var m2 = name.match(/(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/)
        if (m2) return m2[1] + "-" + m2[2] + "-" + m2[3] + "  " + m2[4] + ":" + m2[5] + ":" + m2[6]
        return name
    }

    Process {
        id: scanProc
        command: []
        running: false
        stdout: StdioCollector { id: scanOut }
        onExited: (code) => {
            root.isScanning = false
            // `find` eksik dizinde 1 döner ama stdout yine geçerlidir.
            root.consumeScan(scanOut.text)
        }
    }

    function consumeScan(text) {
        var lines = String(text || "").split("\n")
        var res = []
        var seen = {}
        for (var i = 0; i < lines.length && res.length < 100; i++) {
            var line = lines[i]
            if (!line) continue
            var tab = line.indexOf("\t")
            var p = tab >= 0 ? line.substring(tab + 1) : line
            if (!p) continue
            if (seen[p]) continue
            seen[p] = true
            var fn = p.substring(p.lastIndexOf("/") + 1)
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

    function scanMedia() {
        if (isScanning) return
        isScanning = true
        var args = []
        var dirs = []
        if (root.mode === "videos") {
            dirs = [root.home + "/Videos/Recordings", root.home + "/Videos"]
            args = ["find"].concat(dirs)
                .concat(["-maxdepth", "1", "-type", "f", "(",
                         "-iname", "*.mp4", "-o", "-iname", "*.mkv", "-o",
                         "-iname", "*.webm", "-o", "-iname", "*.mov", ")",
                         "-printf", "%T@\t%p\n"])
        } else {
            dirs = [root.home + "/Pictures/Screenshots", root.home + "/Pictures"]
            args = ["find"].concat(dirs)
                .concat(["-maxdepth", "1", "-type", "f", "(",
                         "-iname", "*.png", "-o", "-iname", "*.jpg", "-o",
                         "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")",
                         "-printf", "%T@\t%p\n"])
        }
        scanProc.exec(args)
    }

    Process {
        id: openProc
        command: []
    }
    function openItem(path) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        openProc.exec(["xdg-open", p])
        root.close()
    }

    function openInMockupStudio(path) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        var shellDir = Quickshell.env("ENYXMA_SHELL_DIR")
        var base = (shellDir && shellDir.length > 0)
            ? shellDir
            : (Quickshell.env("HOME") + "/.config/quickshell")
        Quickshell.execDetached({
            command: ["quickshell", "-p", base + "/modules/screenshot/shell.qml"],
            environment: ({ ENYXMA_SHOT_OPEN: p })
        })
        root.close()
    }

    // ── Panoya kopyalama (kabuk yok) ─────────────────────────────────
    Process {
        id: copyProc
        running: false
        stdinEnabled: true
        onExited: (code) => {
            if (code === 0) root.showToast("Dosya yolu panoya kopyalandı 📋")
            else root.showToast("Kopyalanamadı (wl-copy gerekli)")
        }
    }

    function copyItem(path, isVideo) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        copyProc.exec(["wl-copy"])
        copyProc.write(p + "\n")
        copyProc.stdinEnabled = false
    }

    // ── Çöp kutusu (P0: sessiz rm YOK) ───────────────────────────────
    Process {
        id: trashProc
        running: false
        stderr: StdioCollector { id: trashErr }
        onExited: (code) => {
            if (code === 0) {
                root.showToast("Çöp kutusuna taşındı 🗑️")
                root.scanMedia()
            } else {
                // gio yok/başarısız → trash-put dene
                trashFallback.exec(["trash-put", "--", root.pendingPath])
            }
        }
    }

    Process {
        id: trashFallback
        running: false
        stderr: StdioCollector { id: fallbackErr }
        onExited: (code) => {
            if (code === 0) {
                root.showToast("Çöp kutusuna taşındı 🗑️")
                root.scanMedia()
            } else {
                // Niyetli olarak `rm -f` YOK: geri alınamaz silme yapılmaz.
                var msg = (fallbackErr.text || "").trim().split("\n")[0]
                root.showToast("Silinemedi: " + (msg !== "" ? msg : "çöp kutusu aracı bulunamadı"))
            }
        }
    }

    property string pendingPath: ""

    function deleteItem(path) {
        if (!path) return
        var p = String(path).replace(/^file:\/\//, "")
        root.pendingPath = p
        trashProc.exec(["gio", "trash", "--", p])
    }

    IpcHandler {
        target: "media-browser"
        function screenshots(): void { root.open("screenshots") }
        function videos(): void { root.open("videos") }
        function toggle(): void { root.toggle(root.mode) }
        function close(): void { root.close() }
        function refresh(): void { root.scanMedia() }
    }

    IpcHandler {
        target: "screenshots"
        function open(): void { root.open("screenshots") }
        function toggle(): void { root.toggle("screenshots") }
        function refresh(): void { root.scanMedia() }
    }

    // NOT: eski kod Component.onCompleted'de kapalı panel için de ~/Pictures
    // taraması yapıyordu (her shell açılışında fazladan `find`). Artık tarama
    // yalnızca panel gerçekten açıldığında çalışır (open() içinde).
}
