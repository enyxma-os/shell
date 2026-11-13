pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

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

    // Action Chip koleksiyonu ve sayaç
    property var actionChips: []
    property int unreadChips: 0
    property bool socketConnected: false

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    readonly property string socketPath: Quickshell.env("THORNHILL_SOCK") || (runtimeDir + "/thornhill/thornhill.sock")

    property bool shouldConnect: true
    property int backoffMs: 1000

    property Socket _socket: Socket {
        path: root.socketPath
        connected: root.shouldConnect

        parser: SplitParser {
            splitMarker: "\n"
            onRead: data => root._onLine(data)
        }

        onConnectedChanged: {
            root.socketConnected = connected
            if (connected) {
                root.backoffMs = 1000
                root._handshake()
            } else {
                root._scheduleReconnect()
            }
        }
    }

    function _send(line) {
        if (!root.socketConnected) return
        root._socket.write(line + "\n")
        root._socket.flush()
    }

    function _handshake() {
        root._send(JSON.stringify({
            op: "hello", req: "ui-hello", client: "enyxma-shell", v: 1
        }))
        root._send(JSON.stringify({
            op: "sub", req: "ui-sub", filter: { kinds: [], srcs: [], chips: true }
        }))
    }

    function _onLine(data) {
        let msg
        try {
            msg = JSON.parse(data)
        } catch (e) {
            return
        }

        if (msg.op === "chip.push" && msg.chip) {
            const c = msg.chip
            const entry = {
                id: c.id,
                title: c.title || "",
                why: c.why || "",
                trigger: c.trigger || "",
                labels: c.labels || [],
                actions: c.actions || [],
                ttlMs: c.ttl_ms || 60000,
                conf: c.conf !== undefined ? c.conf : 1.0,
                deadline: Date.now() + (c.ttl_ms || 60000),
                execCmd: (c.actions || []).filter(a => a.action_type === "exec")
                            .map(a => a.payload && a.payload.cmd ? a.payload.cmd : "").join("")
            }
            root.ingestActionChip(entry)
        }
    }

    function ingestActionChip(chip) {
        if (!chip || !chip.id) return
        if (root.actionChips.some(c => c.id === chip.id)) return
        const list = root.actionChips.slice()
        list.unshift(chip)
        root.actionChips = list.slice(0, 20)
        root.unreadChips = root.unreadChips + 1
    }

    function act(chipId, actionLabel, confirm) {
        const msg = {
            op: "chip.act",
            req: "ui-" + Date.now(),
            chip_id: chipId,
            action_label: actionLabel,
            confirm: confirm
        }
        root._send(JSON.stringify(msg))
        if (confirm) {
            root.dismissChip(chipId)
        }
    }

    function dismissChip(chipId) {
        root.actionChips = root.actionChips.filter(c => c.id !== chipId)
    }

    function clearChips() {
        root.actionChips = []
        root.unreadChips = 0
    }

    function markChipsRead() {
        root.unreadChips = 0
    }

    // TTL süresi dolan çipleri temizleyen zamanlayıcı
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const now = Date.now()
            const filtered = root.actionChips.filter(c => !c.deadline || c.deadline > now)
            if (filtered.length !== root.actionChips.length) {
                root.actionChips = filtered
            }
        }
    }

    // Soket yeniden bağlanma zamanlayıcısı
    Timer {
        id: reconnectTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (!root.socketConnected && root.shouldConnect) {
                root._socket.connected = true
            }
        }
    }

    function _scheduleReconnect() {
        const wait = root.backoffMs
        root.backoffMs = Math.min(root.backoffMs * 2, 30000)
        reconnectTimer.interval = wait
        reconnectTimer.restart()
    }

    // Durum sorgusu
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
                root.lastError = "thornhilld birimi bulunamadı, çıkış kodu: " + code
            }
            root.busy = false
        }
    }

    function refresh() {
        if (probeProc.running) return
        probeProc.running = true
    }

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
        root.state = root.running ? "deactivating" : "activating"
        controlProc.exec(["systemctl", "--user", verb, "thornhilld", "--no-block"])
        verifyTimer.restart()
    }

    Process {
        id: controlProc
        running: false
        onExited: (code) => {
            if (code !== 0) {
                root.lastError = "systemctl " + (root.running ? "stop" : "start") +
                                 " başarısız, çıkış kodu: " + code
                root.busy = false
                root.refresh()
            }
        }
    }

    property bool _pendingOpenConsole: false

    FileView {
        id: tokenFile
        path: root.runtimeDir + "/thornhill/http.token"
        printErrors: false
        onLoaded: if (root._pendingOpenConsole) root._launchConsole(tokenFile.text())
        onLoadFailed: if (root._pendingOpenConsole) root._launchConsole("")
    }

    function _launchConsole(rawToken) {
        root._pendingOpenConsole = false
        var t = String(rawToken || "").trim()
        var url = t.length > 0 ? ("http://127.0.0.1:9099/?token=" + t) : "http://127.0.0.1:9099"
        Quickshell.execDetached(["xdg-open", url])
    }

    // Yerel konsol bağlantısı ve otomatik token aktarımı
    function openConsole() {
        root._pendingOpenConsole = true
        tokenFile.reload()
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
