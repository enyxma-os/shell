pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

/**
 * ToolsState: Medya indirme, dönüştürme ve uygulama yönetimi servisi.
 *
 * GÜVENLİK SÖZLEŞMESİ (P0):
 *   Bu dosyada `bash -c` / `sh -c` ile string komut birleştirme YASAKTIR.
 *   Tüm harici çağrılar `Process.command: [...]` dizisi (execve, kabuk yok)
 *   veya `Process.exec([...])` ile yapılır. Kullanıcı girdisi daima
 *   argümanın kendisi olarak geçer, asla komut metnine gömülmez.
 *   Yeni bir komut eklerken `"` + değişken + `"` deseni kullanmayın.
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

    // ── URL doğrulama ────────────────────────────────────────────────
    // Sadece http/https; boşluk, tırnak, ters bölü, $, ;, |, <, >, ` yasak.
    // Bu karakter seti, bir gün yanlışlıkla kabuk kullanılsa bile enjeksiyonu
    // engelleyen ikinci savunma hattıdır (defense in depth).
    readonly property var urlPattern: /^https?:\/\/[^\s"'`$\\<>|;&{}()]+$/i

    function isSafeUrl(u) {
        if (typeof u !== "string") return false
        if (u.length === 0 || u.length > 2048) return false
        return root.urlPattern.test(u)
    }

    function startDownload() {
        const u = root.urlText.trim()
        if (root.isDownloading) return
        if (!root.isSafeUrl(u)) {
            root.downloadStatus = I18n.t("Geçersiz URL — yalnızca http/https adresleri kabul edilir", "Invalid URL — only http/https addresses are accepted")
            return
        }

        root.isDownloading = true
        root.downloadStatus = I18n.t("İndiriliyor...", "Downloading...")

        // Argüman dizisi: her öğe ayrı bir execve argümanı.
        const args = ["--no-playlist", "--no-mtime", "-P", root.downloadDir]
        if (root.dlMode === "audio") {
            args.push("-x", "--audio-format", "mp3")
        } else if (root.dlMode === "mute") {
            args.push("-f", "bestvideo")
        }
        // "--" optparse'ı sonlandırır: sonraki her şey konumsal argüman.
        args.push("--", u)

        // Process.exec(...) = running=false → command → running=true tek çağrıda.
        // (Eski `running=false; running=true` deseni asenkron kapanış yüzünden yarışıyordu.)
        downloadProc.exec(["yt-dlp"].concat(args))
        root.urlText = ""
    }

    Process {
        id: downloadProc
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.lastOutput = this.text
        }
        onExited: (code, status) => {
            root.isDownloading = false
            if (code === 0) {
                root.downloadStatus = I18n.t("Tamamlandı", "Completed")
                root.refreshRecent()
                root.notify(I18n.t("İndirme Tamamlandı", "Download Completed"), I18n.t("Dosya İndirilenler klasörüne kaydedildi.", "File saved to Downloads folder."))
            } else {
                root.downloadStatus = I18n.t("Hata oluştu, çıkış kodu: ", "Error occurred, exit code: ") + code
                root.notify(I18n.t("İndirme Hatası", "Download Error"), I18n.t("Bağlantı indirilemedi.", "Could not download link."))
            }
        }
    }

    property string lastOutput: ""

    function notify(title, body) {
        Quickshell.execDetached(["notify-send", "-a", "Enyxma", title, body])
    }

    // ── Video sıkıştırma ─────────────────────────────────────────────
    // zenity ile dosya seç → ayrı Process ile ffmpeg (kabuk yok).
    property string pendingVideo: ""

    Process {
        id: pickVideoProc
        running: false
        command: [
            "zenity", "--file-selection",
            "--title=Sıkıştırılacak Videoyu Seçin",
            "--file-filter=Video | *.mp4 *.mkv *.webm *.mov *.avi"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.pendingVideo = this.text.trim()
        }
        onExited: (code) => {
            if (code !== 0 || root.pendingVideo.length === 0) return
            const src = root.pendingVideo
            const dot = src.lastIndexOf(".")
            const out = (dot > src.lastIndexOf("/") ? src.substring(0, dot) : src) + "_compressed.mp4"
            root.notify(I18n.t("Video Sıkıştırma", "Video Compression"), I18n.t("Başladı → ", "Started → ") + out)
            compressProc.exec([
                "ffmpeg", "-y", "-i", src,
                "-vcodec", "libx264", "-crf", "28",
                "-pix_fmt", "yuv420p", out
            ])
        }
    }

    Process {
        id: compressProc
        running: false
        onExited: (code) => {
            if (code === 0) root.notify(I18n.t("Video Sıkıştırma", "Video Compression"), I18n.t("Tamamlandı.", "Completed."))
            else root.notify(I18n.t("Video Sıkıştırma", "Video Compression"), I18n.t("Başarısız, çıkış kodu: ", "Failed, exit code: ") + code)
        }
    }

    function compressVideo() {
        root.pendingVideo = ""
        pickVideoProc.running = true
    }

    // ── Uygulama kurma ───────────────────────────────────────────────
    // Uzantı JS'te ayrıştırılır; her dal kendi argüman dizisini kullanır.
    property string pendingPackage: ""

    Process {
        id: pickPkgProc
        running: false
        command: [
            "zenity", "--file-selection",
            "--title=Kurulacak Paketi Seçin",
            "--file-filter=Paket | *.AppImage *.deb *.rpm *.tar.gz *.tar.xz"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.pendingPackage = this.text.trim()
        }
        onExited: (code) => {
            if (code !== 0 || root.pendingPackage.length === 0) return
            root.installPath(root.pendingPackage)
        }
    }

    function installApp() {
        root.pendingPackage = ""
        pickPkgProc.running = true
    }

    function installPath(p) {
        const lower = p.toLowerCase()
        if (lower.endsWith(".appimage")) {
            chmodProc.exec(["chmod", "+x", p])
            root.notify("AppImage", I18n.t("Çalıştırılabilir yapıldı: ", "Made executable: ") + p)
        } else if (lower.endsWith(".deb") || lower.endsWith(".rpm")) {
            // Enyxma OS = NixOS. Debian/RPM paketleri burada kurulamaz; sessizce
            // dpkg çağırmak yerine dürüst hata ver.
            root.notify(I18n.t("Desteklenmeyen Paket", "Unsupported Package"),
                        I18n.t("NixOS üzerinde .deb/.rpm kurulamaz. Paketi Nix ifadesine dönüştürün.", ".deb/.rpm cannot be installed on NixOS. Convert the package to a Nix expression."))
        } else {
            Quickshell.execDetached(["enyxma-launch", "xdg-open", p.substring(0, p.lastIndexOf("/")) || p])
        }
    }

    Process {
        id: chmodProc
        running: false
    }

    function openFile(path) {
        if (!path) return
        Quickshell.execDetached(["enyxma-launch", "xdg-open", path])
    }

    function removeFile(path) {
        root.recentDownloads = root.recentDownloads.filter(f => f.path !== path)
    }

    // ── Son indirilenler ─────────────────────────────────────────────
    // `ls | while read` yerine `find -printf`: kabuk yok, dosya adındaki
    // boşluk/tırnak/newline güvenli, sıralama JS tarafında yapılır.
    Process {
        id: recentProc
        running: false
        command: ["find", root.downloadDir, "-maxdepth", "1", "-type", "f",
                  "-printf", "%T@\\t%p\\n"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                const entries = []
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i]
                    if (!line) continue
                    const tab = line.indexOf("\t")
                    if (tab < 0) continue
                    const mtime = parseFloat(line.substring(0, tab)) || 0
                    const full = line.substring(tab + 1)
                    if (!full) continue
                    const name = full.substring(full.lastIndexOf("/") + 1)
                    entries.push({ name: name, path: full, mtime: mtime })
                }
                entries.sort((a, b) => b.mtime - a.mtime)
                root.recentDownloads = entries.slice(0, 6)
            }
        }
    }

    function refreshRecent() {
        root.recentDownloads = []
        recentProc.running = true
    }

    Component.onCompleted: root.refreshRecent()
}
