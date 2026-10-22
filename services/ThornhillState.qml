pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * ThornhillState — Enyxma OS "Bilişsel Çekirdek" köprüsü (RFC-001).
 *
 * Tasarım kararları:
 *  1. POLLING YOK. Durum yalnızca:
 *       • shell açılışında bir kez,
 *       • panel/widget görünür olduğunda (onVisibleChanged → refresh),
 *       • kullanıcı toggle/refresh istediğinde
 *     sorgulanır. `systemctl --user` çağrısı başına ~2 ms; sürekli timer yok.
 *  2. Kabuk yok: `systemctl` argüman dizisiyle çağrılır.
 *  3. Toggle asenkron: `start`/`stop` sonrası 250 ms gecikmeli tek doğrulama,
 *     sonsuz yeniden deneme yok.
 *  4. UDS (thornhill.sock) dinleyicisi BİLİNÇLİ OLARAK STUB'DIR.
 *     Soket protokolü (JSON şeması) bu repoda tanımlı değil; uydurulmuş bir
 *     ayrıştırıcı yazmak yerine arayüz hazır bırakıldı. `ingestActionChip()`
 *     tek giriş noktasıdır; protokol netleşince burası doldurulur.
 */
Singleton {
    id: root

    // "unknown" | "active" | "inactive" | "failed" | "activating" | "deactivating" | "absent"
    property string state: "unknown"
    property string subState: ""
    property bool busy: false
    property string lastError: ""
    property string lastChecked: ""

    readonly property bool running: state === "active" || state === "activating"
    readonly property bool installed: state !== "absent"

    readonly property string label: {
        if (root.state === "absent") return "Yok"
        if (root.state === "active") return "Çalışıyor"
        if (root.state === "activating") return "Başlıyor"
        if (root.state === "deactivating") return "Duruyor"
        if (root.state === "failed") return "Hata"
        if (root.state === "inactive") return "Uykuda"
        return "Bilinmiyor"
    }

    readonly property color color: {
        if (root.state === "active") return Theme.success
        if (root.state === "failed") return Theme.danger
        if (root.state === "absent") return Theme.textMuted
        return Theme.textSecondary
    }

    // ── Action Chip gelen kutusu (STUB) ──────────────────────────────
    // Beklenen zarf (thornhilld ile mutabakat sonrası kesinleşecek):
    //   { id, kind, severity, title, detail, actions[], ts }
    property var actionChips: []
    property int unreadChips: 0

    function ingestActionChip(chip) {
        if (!chip || !chip.id) return
        if (root.actionChips.some(c => c.id === chip.id)) return
        const list = root.actionChips.slice()
        list.unshift(chip)
        // Bellek tavanı: en yeni 20 çip tutulur.
        root.actionChips = list.slice(0, 20)
        root.unreadChips = root.unreadChips + 1
    }

    function clearChips() {
        root.actionChips = []
        root.unreadChips = 0
    }

    function markChipsRead() {
        root.unreadChips = 0
    }

    // ── Durum sorgusu ────────────────────────────────────────────────
    Process {
        id: probeProc
        running: false
        command: ["systemctl", "--user", "show", "thornhilld",
                  "--property=ActiveState,SubState,LoadState", "--no-pager"]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim()
                if (text.length === 0) {
                    root.state = "unknown"
                    root.lastError = "systemctl çıktısı boş"
                    return
                }
                const map = {}
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const eq = lines[i].indexOf("=")
                    if (eq > 0) map[lines[i].substring(0, eq)] = lines[i].substring(eq + 1)
                }
                if (map.LoadState === "not-found") {
                    root.state = "absent"
                    root.subState = ""
                } else {
                    root.state = map.ActiveState || "unknown"
                    root.subState = map.SubState || ""
                }
                root.busy = false
                root.lastError = ""
                root.lastChecked = Qt.formatTime(new Date(), "hh:mm:ss")
            }
        }
        onExited: (code) => {
            if (code !== 0 && root.state === "unknown") {
                root.state = "absent"
                root.lastError = "thornhilld birimi bulunamadı (çıkış kodu " + code + ")"
            }
            root.busy = false
        }
    }

    function refresh() {
        if (probeProc.running) return
        probeProc.running = true
    }

    // Toggle sonrası tek doğrulama (polling değil, tek atış).
    Timer {
        id: verifyTimer
        interval: 250
        repeat: false
        onTriggered: root.refresh()
    }

    function toggle() {
        if (root.busy) return
        if (root.state === "absent") {
            root.lastError = "thornhilld kurulu değil"
            return
        }
        root.busy = true
        const verb = root.running ? "stop" : "start"
        root.state = root.running ? "deactivating" : "activating" // iyimser ara durum
        controlProc.exec(["systemctl", "--user", verb, "thornhilld", "--no-block"])
        verifyTimer.restart()
    }

    Process {
        id: controlProc
        running: false
        onExited: (code) => {
            if (code !== 0) {
                root.lastError = "systemctl " + (root.running ? "stop" : "start") +
                                 " başarısız (çıkış kodu " + code + ")"
                root.busy = false
                root.refresh()
            }
        }
    }

    // ── Yerel konsol (:9099) ────────────────────────────────────────
    function openConsole() {
        Quickshell.execDetached(["xdg-open", "http://127.0.0.1:9099"])
    }

    IpcHandler {
        target: "thornhill"

        function refresh(): void { root.refresh() }
        function toggle(): void { root.toggle() }
        function openConsole(): void { root.openConsole() }
        function status(): string { return root.state }
    }

    Component.onCompleted: root.refresh()
}
