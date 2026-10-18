pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * ToolsState: Medya indirme, dönüştürme ve uygulama yönetimi servisi.
 * yt-dlp ve cobalt motorunu yönetir, video sıkıştırma ve uygulama yükleme işlemlerini koordine eder.
 */
Singleton {
    id: root

    readonly property string downloadDir: Quickshell.env("HOME") + "/Downloads"
    property string urlText: ""
    property string dlMode: "auto" // auto | audio | mute
    property bool cobaltEnabled: false
    property bool isDownloading: false
    property string downloadStatus: ""
    property var recentDownloads: []

    function startDownload() {
        const u = root.urlText.trim()
        if (u.length === 0 || root.isDownloading) return

        root.isDownloading = true
        root.downloadStatus = "İndiriliyor..."

        let cmd = ""
        if (root.dlMode === "audio") {
            cmd = "yt-dlp -x --audio-format mp3 --no-playlist -P \"" + root.downloadDir + "\" \"" + u + "\""
        } else if (root.dlMode === "mute") {
            cmd = "yt-dlp -f \"bestvideo\" --no-playlist -P \"" + root.downloadDir + "\" \"" + u + "\""
        } else {
            cmd = "yt-dlp --no-playlist -P \"" + root.downloadDir + "\" \"" + u + "\""
        }

        downloadProc.command = ["bash", "-c", cmd]
        downloadProc.running = true
        root.urlText = ""
    }

    Process {
        id: downloadProc
        running: false
        onExited: (code) => {
            root.isDownloading = false
            if (code === 0) {
                root.downloadStatus = "Tamamlandı"
                root.refreshRecent()
                notifyProc.command = ["notify-send", "İndirme Tamamlandı", "Dosya İndirilenler klasörüne kaydedildi."]
                notifyProc.running = true
            } else {
                root.downloadStatus = "Hata oluştu"
                notifyProc.command = ["notify-send", "İndirme Hatası", "Bağlantı indirilemedi."]
                notifyProc.running = true
            }
        }
    }

    Process {
        id: notifyProc
        running: false
    }

    // Video sıkıştırma işlevi: zenity ile video seçtirir ve ffmpeg ile crf 28 sıkıştırır
    function compressVideo() {
        const helperCmd = "file=$(zenity --file-selection --title=\"Sıkıştırılacak Videoyu Seçin\" 2>/dev/null); " +
                          "if [ -n \"$file\" ] && [ -f \"$file\" ]; then " +
                          "  notify-send \"Video Sıkıştırma\" \"$(basename \"$file\") sıkıştırılıyor...\"; " +
                          "  out=\"${file%.*}_compressed.mp4\"; " +
                          "  ffmpeg -y -i \"$file\" -vcodec libx264 -crf 28 \"$out\" && " +
                          "  notify-send \"Video Sıkıştırma\" \"Tamamlandı: $(basename \"$out\")\"; " +
                          "fi"
        Quickshell.execDetached(["bash", "-c", helperCmd])
    }

    // Uygulama kurma işlevi: zenity ile AppImage / deb / paket seçtirir
    function installApp() {
        const helperCmd = "file=$(zenity --file-selection --title=\"Kurulacak Paketi Seçin\" 2>/dev/null); " +
                          "if [ -n \"$file\" ] && [ -f \"$file\" ]; then " +
                          "  case \"$file\" in " +
                          "    *.AppImage) chmod +x \"$file\" && notify-send \"AppImage\" \"Çalıştırılıyor...\" && \"$file\" & ;; " +
                          "    *.deb) kitty -e bash -c \"sudo dpkg -i '$file' || sudo apt-get install -f; read -p 'Bitti... Enter tuşuna basın'\" & ;; " +
                          "    *) notify-send \"Seçilen Dosya\" \"$(basename \"$file\")\"; xdg-open \"$(dirname \"$file\")\" & ;; " +
                          "  esac; " +
                          "fi"
        Quickshell.execDetached(["bash", "-c", helperCmd])
    }

    function openFile(path) {
        if (!path) return
        Quickshell.execDetached(["xdg-open", path])
    }

    function removeFile(path) {
        root.recentDownloads = root.recentDownloads.filter(f => f.path !== path)
    }

    Process {
        id: recentProc
        command: ["bash", "-c", "mkdir -p \"$HOME/Downloads\"; ls -t \"$HOME/Downloads\" 2>/dev/null | head -n 6 | while IFS= read -r f; do [ -f \"$HOME/Downloads/$f\" ] && printf \"%s\\t%s\\n\" \"$f\" \"$HOME/Downloads/$f\"; done"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                const parts = line.split("\t")
                if (parts.length >= 2 && parts[0].trim().length > 0) {
                    const name = parts[0].trim()
                    const path = parts[1].trim()
                    const arr = root.recentDownloads.slice()
                    if (!arr.some(item => item.path === path)) {
                        arr.push({ name: name, path: path })
                        root.recentDownloads = arr
                    }
                }
            }
        }
    }

    function refreshRecent() {
        root.recentDownloads = []
        recentProc.running = true
    }

    Component.onCompleted: {
        root.refreshRecent()
    }
}
