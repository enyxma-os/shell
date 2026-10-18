pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Panel Görünürlük Durumu
    property bool isOpen: false

    function toggle() {
        isOpen = !isOpen
        if (isOpen) {
            refreshDetails()
        } else if (speedRunning) {
            cancelSpeedTest()
        }
    }

    function open() {
        isOpen = true
        refreshDetails()
    }

    function close() {
        isOpen = false
        if (speedRunning)
            cancelSpeedTest()
    }

    // Ağ Durumu ve Arayüz Bilgileri
    property bool isConnected: false
    property string connectionType: "none" // "ethernet" | "wifi" | "none"
    property string connectionName: ""
    property string interfaceName: ""
    property string ipAddress: ""
    property int signalStrength: 0
    property string frequency: ""
    property string linkSpeed: ""

    // DNS Durumu ve Yönetimi
    property string dnsProvider: "dhcp" // "dhcp" | "cloudflare" | "google" | "custom"
    property var dnsServers: []
    property bool dnsBusy: false
    property string dnsError: ""

    // Ağ Trafik Metrikleri (RX / TX)
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

    function refreshDetails() {
        detailProc.running = false
        detailProc.running = true
    }

    // İlk yükleme ve olay tabanlı ağ izleme (nmcli monitor)
    Process {
        id: initProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "dev"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root.refreshDetails()
        }
    }

    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root.refreshDetails()
        }
    }

    Process {
        id: detailProc
        command: ["bash", "-c",
            "IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"dev\"){print $(i+1); exit}}'); " +
            "if [ -z \"$IFACE\" ]; then echo NONE; exit; fi; " +
            "IPADDR=$(ip -o -4 addr show dev \"$IFACE\" 2>/dev/null | awk '{split($4,a,\"/\"); print a[1]; exit}'); " +
            "CONN=$(nmcli -t -f NAME,DEVICE con show --active 2>/dev/null | grep \":$IFACE$\" | cut -d: -f1 | head -n1); " +
            "SPEED=$(cat /sys/class/net/$IFACE/speed 2>/dev/null); " +
            "DNS=$(nmcli dev show \"$IFACE\" 2>/dev/null | awk '/IP4.DNS/ {print $2}' | tr '\\n' ',' | sed 's/,$//'); " +
            "if [ -d \"/sys/class/net/$IFACE/wireless\" ]; then " +
            "  LINK=$(iw dev \"$IFACE\" link 2>/dev/null); " +
            "  SSID=$(printf '%s\\n' \"$LINK\" | sed -n 's/^\\s*SSID: //p' | head -1); " +
            "  SIG=$(printf '%s\\n' \"$LINK\" | awk '/signal:/ {print int($2); exit}'); " +
            "  FRQ=$(printf '%s\\n' \"$LINK\" | awk '/freq:/ {print $2 \" MHz\"; exit}'); " +
            "  QUAL=$(awk -v s=\"$SIG\" 'BEGIN{q=int((s+110)*100/70);if(q<0)q=0;if(q>100)q=100;print q}'); " +
            "  printf 'WIFI\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' \"$CONN\" \"$IFACE\" \"$IPADDR\" \"$SSID\" \"$QUAL\" \"$FRQ\" \"$DNS\"; " +
            "else " +
            "  printf 'ETHERNET\\t%s\\t%s\\t%s\\t%s\\t%s\\n' \"$CONN\" \"$IFACE\" \"$IPADDR\" \"$SPEED\" \"$DNS\"; " +
            "fi"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (!raw || raw === "NONE") {
                    root.isConnected = false
                    root.connectionType = "none"
                    root.connectionName = ""
                    root.interfaceName = ""
                    root.ipAddress = ""
                    root.signalStrength = 0
                    root.frequency = ""
                    root.linkSpeed = ""
                    return
                }

                var parts = raw.split("\t")
                root.isConnected = true
                if (parts[0] === "WIFI") {
                    root.connectionType = "wifi"
                    root.connectionName = parts[1] || parts[4] || "Wi-Fi"
                    root.interfaceName = parts[2] || ""
                    root.ipAddress = parts[3] || ""
                    root.signalStrength = parseInt(parts[5]) || 0
                    root.frequency = parts[6] || ""
                    root.linkSpeed = ""
                    root.parseDns(parts[7] || "")
                } else if (parts[0] === "ETHERNET") {
                    root.connectionType = "ethernet"
                    root.connectionName = parts[1] || "Ethernet"
                    root.interfaceName = parts[2] || ""
                    root.ipAddress = parts[3] || ""
                    var sp = parseInt(parts[4]) || 0
                    root.linkSpeed = sp > 0 ? (sp >= 1000 ? (sp / 1000).toFixed(1).replace(/\.0$/, "") + " Gbit/s" : sp + " Mbit/s") : ""
                    root.signalStrength = 100
                    root.frequency = ""
                    root.parseDns(parts[5] || "")
                }
            }
        }
    }

    function parseDns(dnsStr) {
        if (!dnsStr) {
            root.dnsServers = []
            root.dnsProvider = "dhcp"
            return
        }
        var list = dnsStr.split(",").filter(function(s) { return s.trim().length > 0 })
        root.dnsServers = list
        var str = list.join(" ")
        if (str.indexOf("1.1.1.1") >= 0) {
            root.dnsProvider = "cloudflare"
        } else if (str.indexOf("8.8.8.8") >= 0) {
            root.dnsProvider = "google"
        } else if (list.length > 0 && list[0] !== "192.168.122.1" && list[0] !== "127.0.0.53") {
            root.dnsProvider = "custom"
        } else {
            root.dnsProvider = "dhcp"
        }
    }

    // Periyodik trafik sorgulama (2 saniye)
    Timer {
        id: trafficTimer
        interval: 2000
        running: root.isConnected
        repeat: true
        onTriggered: {
            trafficProc.running = false
            trafficProc.running = true
        }
    }

    Process {
        id: trafficProc
        command: ["bash", "-c",
            "IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"dev\"){print $(i+1); exit}}'); " +
            "[ -n \"$IFACE\" ] && awk -v i=\"$IFACE:\" '$1==i{print $2 \"\\t\" $10}' /proc/net/dev"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var line = this.text.trim()
                if (!line) return
                var parts = line.split("\t")
                if (parts.length >= 2) {
                    var rx = parseFloat(parts[0]) || 0
                    var tx = parseFloat(parts[1]) || 0
                    root.updateSpeeds(rx, tx, Date.now())
                }
            }
        }
    }

    // DNS Değiştirme
    function setDnsProvider(provider, customServers) {
        if (dnsBusy || !connectionName) return
        dnsBusy = true
        dnsError = ""
        dnsProvider = provider

        var dnsArgs = ""
        var ignoreAuto = "no"
        if (provider === "cloudflare") {
            dnsArgs = "'1.1.1.1 1.0.0.1'"
            ignoreAuto = "yes"
        } else if (provider === "google") {
            dnsArgs = "'8.8.8.8 8.8.4.4'"
            ignoreAuto = "yes"
        } else if (provider === "custom" && customServers && customServers.length > 0) {
            dnsArgs = "'" + customServers.join(" ") + "'"
            ignoreAuto = "yes"
        } else {
            dnsArgs = "''"
            ignoreAuto = "no"
        }

        var cmd = "nmcli con mod '" + connectionName + "' ipv4.dns " + dnsArgs + " ipv4.ignore-auto-dns " + ignoreAuto + " && nmcli con up '" + connectionName + "'"
        dnsProc.command = ["bash", "-c", cmd]
        dnsProc.running = false
        dnsProc.running = true
    }

    Process {
        id: dnsProc
        running: false
        onExited: (exitCode, exitStatus) => {
            root.dnsBusy = false
            if (exitCode === 0) {
                root.refreshDetails()
            } else {
                root.dnsError = "DNS değiştirilemedi"
            }
        }
    }

    // Ağ Ayarlarını Aç
    function openSettings() {
        settingsProc.running = false
        settingsProc.running = true
    }

    Process {
        id: settingsProc
        command: ["bash", "-c", "which nm-connection-editor >/dev/null 2>&1 && nm-connection-editor || foot -e nmtui || kitty -e nmtui"]
        running: false
    }

    // ─────────────────────────────────────────────────────────────
    // Cloudflare Hız Testi Motoru (Saf JavaScript / XMLHttpRequest)
    // ─────────────────────────────────────────────────────────────
    property string speedPhase: "idle" // "idle", "latency", "download", "upload", "success", "error", "cancelled", "offline"
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
        if (!isConnected) {
            speedPhase = "offline"
            return
        }

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
                if (elapsed > 0 && isFinite(elapsed))
                    latencySamples.push(elapsed)
            }

            if (latencyStep < 6) {
                ++latencyStep
                runLatencyRequest()
            } else {
                speedPingMs = median(latencySamples)
                startDownload()
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

    function startDownload() {
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
            startUpload()
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

    function startUpload() {
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
        function speedtest(): void { root.startSpeedTest() }
        function setdns(provider: string): void { root.setDnsProvider(provider, []) }
    }
}
