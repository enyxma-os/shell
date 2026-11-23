pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * NetworkState — ağ durumu, trafik ve hız testi.
 *
 * P0: `bash -c` ve string komut birleştirme TAMAMEN kaldırıldı.
 *   • Arayüz keşfi: `ip -j route get 1.1.1.1` (JSON) → dev
 *   • Bağlantı adı: `nmcli -t -f NAME,DEVICE con show --active`
 *   • IP: `ip -j -4 addr show dev <if>` (JSON)
 *   • SSID/sinyal: `iw dev <if> link`
 *   • DNS: `nmcli -t -f IP4.DNS dev show <if>`
 *   • Trafik: `/proc/net/dev` FileView ile okunur → SIFIR fork.
 *   • DNS değiştirme: `nmcli con mod <ad> ipv4.dns <ip...>` argüman dizisi.
 *     SSID/bağlantı adı artık bir kabuğa gömülmediği için tırnak kaçışı
 *     (`Kafe'$(...)`) enjeksiyonu yapısal olarak imkânsız.
 */
Singleton {
    id: root

    property bool isOpen: false

    function toggle() {
        isOpen = !isOpen
        if (isOpen) refreshDetails()
        else if (speedRunning) cancelSpeedTest()
    }
    function open() { isOpen = true; refreshDetails() }
    function close() { isOpen = false; if (speedRunning) cancelSpeedTest() }

    // ── Ağ durumu ────────────────────────────────────────────────────
    property bool isConnected: false
    property string connectionType: "none" // ethernet | wifi | none
    property string connectionName: ""
    property string interfaceName: ""
    property string ipAddress: ""
    property int signalStrength: 0
    property string frequency: ""
    property string linkSpeed: ""

    // ── DNS ──────────────────────────────────────────────────────────
    property string dnsProvider: "dhcp"
    property var dnsServers: []
    property bool dnsBusy: false
    property string dnsError: ""

    // ── Trafik ───────────────────────────────────────────────────────
    property real rxRate: 0
    property real txRate: 0
    property real rxLevel: 0
    property real txLevel: 0
    property real prevRx: -1
    property real prevTx: -1
    property real prevMs: 0

    function trafficLevel(bps) {
        var value = Math.max(0, Number(bps) || 0)
        if (value <= 0) return 0
        return Math.min(1.0, Math.log(1 + value / 1024) / Math.log(1 + 102400))
    }

    function updateSpeeds(rx, tx, now) {
        if (prevRx >= 0 && prevMs > 0) {
            var dt = (now - prevMs) / 1000
            if (dt > 0) {
                rxRate = Math.max(0, (rx - prevRx) / dt)
                txRate = Math.max(0, (tx - prevTx) / dt)
                rxLevel = trafficLevel(rxRate)
                txLevel = trafficLevel(txRate)
            }
        }
        prevRx = rx
        prevTx = tx
        prevMs = now
    }

    // ── Arayüz keşif hattı (sıralı, kabuksuz) ────────────────────────
    property int _step: 0
    property string _iface: ""
    property string _conn: ""
    property string _ip: ""
    property string _ssid: ""
    property int _sig: -1
    property string _freq: ""
    property string _speed: ""
    property var _dns: []

    function refreshDetails() {
        if (pipeProc.running) return
        root._step = 0
        root._iface = ""
        root._conn = ""
        root._ip = ""
        root._ssid = ""
        root._sig = -1
        root._freq = ""
        root._speed = ""
        root._dns = []
        pipeProc.command = ["ip", "-j", "route", "get", "1.1.1.1"]
        pipeProc.running = true
    }

    function advance(code, text) {
        var t = (text || "").trim()
        switch (root._step) {
        case 0: // route
            root._iface = parseRouteDev(t)
            if (root._iface === "") { root.applyDisconnected(); return }
            root._step = 1
            pipeProc.command = ["nmcli", "-t", "-f", "NAME,DEVICE,STATE", "con", "show", "--active"]
            pipeProc.running = true
            return
        case 1: // nmcli active connections
            root._conn = parseConnForDevice(t, root._iface)
            root._step = 2
            pipeProc.command = ["ip", "-j", "-4", "addr", "show", "dev", root._iface]
            pipeProc.running = true
            return
        case 2: // address
            root._ip = parseAddr(t)
            root._step = 3
            pipeProc.command = ["nmcli", "-t", "-f", "IP4.DNS", "dev", "show", root._iface]
            pipeProc.running = true
            return
        case 3: // dns
            root._dns = parseDnsLines(t)
            root._step = 4
            pipeProc.command = ["cat", "/sys/class/net/" + root._iface + "/speed"]
            pipeProc.running = true
            return
        case 4: // link speed
            root._speed = t
            // Eğer arayüz ethernet ise (wl* değilse veya iw yoksa) iw çalıştırma
            if (!root._iface.startsWith("wl")) {
                root._ssid = ""
                root._sig = -1
                root._freq = ""
                root.applyConnected()
                return
            }
            root._step = 5
            pipeProc.command = ["iw", "dev", root._iface, "link"]
            pipeProc.running = true
            return
        case 5: // wifi link
            parseIwLink(t)
            root.applyConnected()
            return
        }
    }

    Process {
        id: pipeProc
        running: false
        stdout: StdioCollector { id: pipeOut }
        onExited: (code, status) => root.advance(code, pipeOut.text)
    }

    function parseRouteDev(text) {
        try {
            var arr = JSON.parse(text)
            if (arr && arr.length > 0 && arr[0].dev) return String(arr[0].dev)
        } catch (e) {}
        return ""
    }

    function parseConnForDevice(text, iface) {
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            // nmcli -t: AD:DEVICE:STATE → ad içinde ':' olabilir, sondan böl
            var parts = lines[i].split(":")
            if (parts.length >= 3 && parts[parts.length - 2] === iface) {
                return parts.slice(0, parts.length - 2).join(":")
            }
        }
        return ""
    }

    function parseAddr(text) {
        try {
            var arr = JSON.parse(text)
            if (arr && arr.length > 0 && arr[0].addr_info && arr[0].addr_info.length > 0) {
                return String(arr[0].addr_info[0].local || "")
            }
        } catch (e) {}
        return ""
    }

    function parseDnsLines(text) {
        var out = []
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var s = lines[i].trim()
            if (s === "") continue
            var idx = s.lastIndexOf(":")
            var val = idx >= 0 ? s.substring(idx + 1).trim() : s
            if (val !== "" && out.indexOf(val) < 0) out.push(val)
        }
        return out
    }

    function parseIwLink(text) {
        var ssid = ""
        var sig = -1
        var freq = ""
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i]
            var mSsid = l.match(/^\s*SSID:\s*(.+)$/)
            if (mSsid) ssid = mSsid[1].trim()
            var mSig = l.match(/^\s*signal:\s*(-?\d+(?:\.\d+)?)/)
            if (mSig) sig = parseFloat(mSig[1])
            var mFreq = l.match(/^\s*freq:\s*([\d.]+)/)
            if (mFreq) freq = mFreq[1] + " MHz"
        }
        root._ssid = ssid
        root._sig = sig
        root._freq = freq
    }

    function qualityFromRssi(rssi) {
        // -110 dBm = 0 %, -40 dBm = 100 %
        var q = Math.round((rssi + 110) * 100 / 70)
        return Math.max(0, Math.min(100, q))
    }

    function applyDisconnected() {
        isConnected = false
        connectionType = "none"
        connectionName = ""
        interfaceName = ""
        ipAddress = ""
        signalStrength = 0
        frequency = ""
        linkSpeed = ""
        dnsServers = []
    }

    function applyConnected() {
        var isWifi = root._ssid !== "" || root._sig > -200 && root._freq !== ""
        isConnected = true
        interfaceName = root._iface
        ipAddress = root._ip
        connectionName = root._conn !== "" ? root._conn : (isWifi ? root._ssid : root._iface)
        dnsServers = root._dns
        parseDnsProvider()
        if (isWifi) {
            connectionType = "wifi"
            signalStrength = root._sig > -200 ? qualityFromRssi(root._sig) : 0
            frequency = root._freq
            linkSpeed = ""
        } else {
            connectionType = "ethernet"
            var sp = parseInt(root._speed) || 0
            linkSpeed = sp > 0
                ? (sp >= 1000 ? (sp / 1000).toFixed(1).replace(/\.0$/, "") + " Gbit/s" : sp + " Mbit/s")
                : ""
            signalStrength = 100
            frequency = ""
        }
    }

    function parseDnsProvider() {
        var list = root.dnsServers
        if (list.length === 0) { dnsProvider = "dhcp"; return }
        var str = list.join(" ")
        if (str.indexOf("1.1.1.1") >= 0) dnsProvider = "cloudflare"
        else if (str.indexOf("8.8.8.8") >= 0) dnsProvider = "google"
        else if (list[0] !== "127.0.0.53") dnsProvider = "custom"
        else dnsProvider = "dhcp"
    }

    // İlk yükleme + olay tabanlı izleme (nmcli monitor → olay, polling değil)
    Process {
        id: initProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "dev"]
        running: true
        stdout: SplitParser { splitMarker: "\n"; onRead: line => root.refreshDetails() }
    }

    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser { splitMarker: "\n"; onRead: line => root.refreshDetails() }
    }

    // ── Trafik: /proc/net/dev (fork YOK) ─────────────────────────────
    FileView {
        id: netDevFile
        path: "/proc/net/dev"
        printErrors: false
        blockLoading: false
        onLoaded: root.parseNetDev(netDevFile.text())
    }

    function parseNetDev(text) {
        if (!root.interfaceName) return
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
            var idx = lines[i].indexOf(":")
            if (idx < 0) continue
            var name = lines[i].substring(0, idx).trim()
            if (name !== root.interfaceName) continue
            var f = lines[i].substring(idx + 1).trim().split(/\s+/)
            if (f.length < 9) return
            root.updateSpeeds(parseFloat(f[0]) || 0, parseFloat(f[8]) || 0, Date.now())
            return
        }
    }

    Timer {
        interval: 2000
        running: root.isConnected
        repeat: true
        onTriggered: netDevFile.reload()
    }

    // ── DNS değiştirme (P0) ──────────────────────────────────────────
    readonly property var ipv4Pattern: /^(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}$/

    function sanitizeServers(list) {
        var out = []
        if (!list) return out
        for (var i = 0; i < list.length && out.length < 3; i++) {
            var s = String(list[i]).trim()
            if (root.ipv4Pattern.test(s)) out.push(s)
        }
        return out
    }

    function setDnsProvider(provider, customServers) {
        if (dnsBusy) return
        if (!connectionName) { dnsError = "Aktif bağlantı yok"; return }

        var servers = []
        if (provider === "cloudflare") servers = ["1.1.1.1", "1.0.0.1"]
        else if (provider === "google") servers = ["8.8.8.8", "8.8.4.4"]
        else if (provider === "custom") {
            servers = root.sanitizeServers(customServers)
            if (servers.length === 0) { dnsError = "Geçersiz DNS adresi"; return }
        }

        dnsBusy = true
        dnsError = ""

        // Argüman dizisi: bağlantı adı tek bir argüman, IP'ler tek bir argüman.
        var args = ["con", "mod", connectionName]
        if (servers.length === 0) {
            args = args.concat(["ipv4.dns", "", "ipv4.ignore-auto-dns", "no"])
        } else {
            args = args.concat(["ipv4.dns", servers.join(" "), "ipv4.ignore-auto-dns", "yes"])
        }
        dnsProc.exec(["nmcli"].concat(args))
    }

    Process {
        id: dnsProc
        running: false
        stderr: StdioCollector { id: dnsErrOut }
        onExited: (code, status) => {
            root.dnsBusy = false
            if (code === 0) {
                root.dnsError = ""
                // NOT: `nmcli con up` bilinçli olarak çağrılmıyor — aktif
                // bağlantıyı düşürüp kullanıcıya haber vermeden kesinti
                // yaratıyordu. Yeni DNS bir sonraki bağlanmada etkin olur;
                // kullanıcı isterse panelden "Yeniden bağlan" aksiyonu alır.
                root.refreshDetails()
            } else {
                var msg = (dnsErrOut.text || "").trim()
                root.dnsError = msg !== "" ? msg.split("\n")[0] : ("DNS değiştirilemedi (kod " + code + ")")
            }
        }
    }

    function reconnect() {
        if (!connectionName) return
        dnsBusy = true
        reconnectProc.exec(["nmcli", "con", "up", connectionName])
    }

    Process {
        id: reconnectProc
        running: false
        onExited: (code) => { root.dnsBusy = false; root.refreshDetails() }
    }

    // ── Ağ ayarları ──────────────────────────────────────────────────
    function openSettings() {
        // nm-connection-editor yoksa nmtui'ye düş: `sh -c` yerine sıralı deneme.
        settingsProc.exec(["nm-connection-editor"])
    }

    Process {
        id: settingsProc
        running: false
        onExited: (code) => {
            if (code !== 0) Quickshell.execDetached(["enyxma-launch", "foot", "-e", "nmtui"])
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Cloudflare hız testi (saf JS/XMLHttpRequest — değişmedi)
    // ─────────────────────────────────────────────────────────────────
    property string speedPhase: "idle"
    readonly property bool speedRunning: speedPhase === "latency" || speedPhase === "download" || speedPhase === "upload"
    property real speedPingMs: 0
    property real speedDownloadMbps: 0
    property real speedUploadMbps: 0
    property string speedEdgeCode: ""
    property string speedCountryCode: ""
    property string speedLastStamp: ""
    property string speedErrorText: ""

    readonly property string downloadEndpoint: "https://speed.cloudflare.com/__down"
    readonly property string uploadEndpoint: "https://speed.cloudflare.com/__up"

    property int runGeneration: 0
    property var activeRequest: null
    property var requestTimeoutHandler: null

    property int latencyStep: 0
    property var latencySamples: []
    property var downloadSizes: [1000000, 5000000, 10000000, 25000000]
    property int downloadIndex: 0
    property int downloadRepeats: 0
    property int selectedDownloadBytes: 0
    property var downloadSamples: []
    property var uploadSizes: [250000, 1000000, 5000000, 10000000]
    property int uploadIndex: 0
    property int uploadRepeats: 0
    property int selectedUploadBytes: 0
    property var uploadSamples: []

    function flagForCountry(code) {
        var value = (code || "").toUpperCase()
        if (!/^[A-Z]{2}$/.test(value)) return ""
        return String.fromCharCode(0xD83C, 0xDDE6 + value.charCodeAt(0) - 65, 0xD83C, 0xDDE6 + value.charCodeAt(1) - 65)
    }

    readonly property string speedEdgeText: {
        if (speedPhase === "idle" || speedPhase === "cancelled") return "Test Edilmedi"
        if (speedPhase === "offline") return "Çevrimdışı"
        if (speedPhase === "error" || speedPhase === "timeout") return "Kullanılamıyor"
        if (speedPhase === "latency") return "Sunucu aranıyor..."
        var edge = speedEdgeCode !== "" ? ("Cloudflare · " + speedEdgeCode) : "Cloudflare Edge"
        var flag = flagForCountry(speedCountryCode)
        return edge + (flag !== "" ? (" " + flag) : "")
    }

    function median(values) {
        var sorted = values.slice()
        sorted.sort(function(a, b) { return a - b })
        return sorted[Math.floor(sorted.length / 2)]
    }

    function readHeader(xhr, names) {
        for (var i = 0; i < names.length; ++i) {
            var value = xhr.getResponseHeader(names[i])
            if (value) return value
        }
        return ""
    }

    function captureLocation(result) {
        var edge = (result.edge || "").trim().toUpperCase()
        var country = (result.country || "").trim().toUpperCase()
        if (/^[A-Z]{3}$/.test(edge)) speedEdgeCode = edge
        if (/^[A-Z]{2}$/.test(country)) speedCountryCode = country
    }

    function finishSpeedFailure(nextPhase, message) {
        ++runGeneration
        speedRequestTimer.stop()
        speedOverallTimer.stop()
        requestTimeoutHandler = null
        var request = activeRequest
        activeRequest = null
        if (request) request.abort()
        speedErrorText = message
        speedPhase = nextPhase
    }

    function finishSpeedSuccess() {
        speedRequestTimer.stop()
        speedOverallTimer.stop()
        activeRequest = null
        requestTimeoutHandler = null
        speedErrorText = ""
        speedPhase = "success"
        speedLastStamp = Qt.formatTime(new Date(), "hh:mm")
    }

    function sendSpeedRequest(method, url, body, binary, onSuccess, attempt) {
        var generation = runGeneration
        var xhr = new XMLHttpRequest()
        var startedAt = 0
        var headersAt = 0
        var timedOut = false

        xhr.onreadystatechange = function() {
            if (generation !== runGeneration || timedOut) return
            if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED && headersAt === 0)
                headersAt = Date.now()
            if (xhr.readyState !== XMLHttpRequest.DONE) return

            speedRequestTimer.stop()
            requestTimeoutHandler = null
            if (activeRequest === xhr) activeRequest = null
            var finishedAt = Date.now()

            if (xhr.status !== 200 || headersAt === 0) {
                xhr.onreadystatechange = null
                if (attempt < 1) {
                    var gen = runGeneration
                    Qt.callLater(function() {
                        if (gen === runGeneration && speedRunning)
                            sendSpeedRequest(method, url, body, binary, onSuccess, attempt + 1)
                    })
                } else {
                    finishSpeedFailure("error", xhr.status === 0 ? "Bağlantı hatası" : "Sunucu yanıt vermedi")
                }
                return
            }

            var responseBytes = 0
            if (binary && xhr.response) responseBytes = xhr.response.byteLength || 0
            var result = {
                startedAt: startedAt,
                headersAt: headersAt,
                finishedAt: finishedAt,
                responseBytes: responseBytes,
                edge: readHeader(xhr, ["cf-meta-colo", "colo"]),
                country: readHeader(xhr, ["cf-meta-country", "country"])
            }
            xhr.onreadystatechange = null
            onSuccess(result)
        }

        xhr.open(method, url, true)
        if (binary) xhr.responseType = "arraybuffer"
        if (method === "POST") xhr.setRequestHeader("Content-Type", "application/octet-stream")

        activeRequest = xhr
        requestTimeoutHandler = function() {
            if (generation !== runGeneration) return
            timedOut = true
            speedRequestTimer.stop()
            if (activeRequest === xhr) activeRequest = null
            xhr.abort()
            if (attempt < 1) {
                sendSpeedRequest(method, url, body, binary, onSuccess, attempt + 1)
            } else {
                finishSpeedFailure("timeout", "Zaman aşımı")
            }
        }

        startedAt = Date.now()
        speedRequestTimer.restart()
        if (body === null || body === undefined) xhr.send()
        else xhr.send(body)
    }

    function startSpeedTest() {
        if (speedRunning) return
        if (!isConnected) { speedPhase = "offline"; return }

        ++runGeneration
        speedEdgeCode = ""
        speedCountryCode = ""
        speedPingMs = 0
        speedDownloadMbps = 0
        speedUploadMbps = 0
        speedErrorText = ""
        latencyStep = 0
        latencySamples = []
        speedOverallTimer.restart()
        speedPhase = "latency"
        runLatencyRequest()
    }

    function cancelSpeedTest() {
        if (!speedRunning) return
        ++runGeneration
        speedRequestTimer.stop()
        speedOverallTimer.stop()
        requestTimeoutHandler = null
        var request = activeRequest
        activeRequest = null
        if (request) request.abort()
        speedErrorText = ""
        speedPhase = "cancelled"
    }

    function runLatencyRequest() {
        sendSpeedRequest("GET", downloadEndpoint + "?bytes=0", null, false, function(result) {
            captureLocation(result)
            if (latencyStep > 0) {
                var elapsed = result.headersAt - result.startedAt
                if (elapsed > 0 && isFinite(elapsed)) latencySamples.push(elapsed)
            }
            if (latencyStep < 6) {
                ++latencyStep
                runLatencyRequest()
            } else {
                speedPingMs = median(latencySamples)
                startDownloadTest()
            }
        }, 0)
    }

    function measureDownload(bytes, onSuccess, attempt) {
        sendSpeedRequest("GET", downloadEndpoint + "?bytes=" + bytes, null, true, function(result) {
            captureLocation(result)
            var payloadTime = result.finishedAt - result.headersAt
            var value = result.responseBytes * 8 / (speedPingMs + payloadTime) / 1000
            if (!(payloadTime > 0) || !(result.responseBytes > 0) || !(value > 0) || !isFinite(value)) {
                if (attempt < 1) measureDownload(bytes, onSuccess, attempt + 1)
                else finishSpeedFailure("error", "İndirme ölçüm hatası")
                return
            }
            onSuccess(value, payloadTime)
        }, 0)
    }

    function startDownloadTest() {
        speedPhase = "download"
        downloadIndex = 0
        downloadSamples = []
        runDownloadCalibration()
    }

    function runDownloadCalibration() {
        var bytes = downloadSizes[downloadIndex]
        measureDownload(bytes, function(value, duration) {
            if (duration >= 400 || downloadIndex === downloadSizes.length - 1) {
                selectedDownloadBytes = bytes
                downloadSamples = [value]
                downloadRepeats = 2
                runDownloadRepeat()
            } else {
                ++downloadIndex
                runDownloadCalibration()
            }
        }, 0)
    }

    function runDownloadRepeat() {
        if (downloadRepeats === 0) {
            speedDownloadMbps = median(downloadSamples)
            startUploadTest()
            return
        }
        measureDownload(selectedDownloadBytes, function(value) {
            downloadSamples.push(value)
            --downloadRepeats
            runDownloadRepeat()
        }, 0)
    }

    function measureUpload(bytes, onSuccess, attempt) {
        var body = "0".repeat(bytes)
        sendSpeedRequest("POST", uploadEndpoint + "?bytes=" + bytes, body, false, function(result) {
            captureLocation(result)
            var ttfb = result.headersAt - result.startedAt
            var value = bytes * 8 / ttfb / 1000
            body = null
            if (!(ttfb > 0) || !(value > 0) || !isFinite(value)) {
                if (attempt < 1) measureUpload(bytes, onSuccess, attempt + 1)
                else finishSpeedFailure("error", "Yükleme ölçüm hatası")
                return
            }
            onSuccess(value, ttfb - speedPingMs)
        }, 0)
    }

    function startUploadTest() {
        speedPhase = "upload"
        uploadIndex = 0
        uploadSamples = []
        runUploadCalibration()
    }

    function runUploadCalibration() {
        var bytes = uploadSizes[uploadIndex]
        measureUpload(bytes, function(value, duration) {
            if (duration >= 400 || uploadIndex === uploadSizes.length - 1) {
                selectedUploadBytes = bytes
                uploadSamples = [value]
                uploadRepeats = 2
                runUploadRepeat()
            } else {
                ++uploadIndex
                runUploadCalibration()
            }
        }, 0)
    }

    function runUploadRepeat() {
        if (uploadRepeats === 0) {
            speedUploadMbps = median(uploadSamples)
            finishSpeedSuccess()
            return
        }
        measureUpload(selectedUploadBytes, function(value) {
            uploadSamples.push(value)
            --uploadRepeats
            runUploadRepeat()
        }, 0)
    }

    Timer {
        id: speedRequestTimer
        interval: 15000
        repeat: false
        onTriggered: if (root.requestTimeoutHandler) root.requestTimeoutHandler()
    }

    Timer {
        id: speedOverallTimer
        interval: 60000
        repeat: false
        onTriggered: root.finishSpeedFailure("timeout", "Hız testi zaman aşımına uğradı")
    }

    IpcHandler {
        target: "network"

        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function refresh(): void { root.refreshDetails() }
        function speedtest(): void { root.startSpeedTest() }
        function setdns(provider: string): void { root.setDnsProvider(provider, []) }
    }
}
