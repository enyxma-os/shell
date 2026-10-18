pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isOpen: false
    property bool isStreaming: false
    property var messages: []
    property string activeTab: "chat" // chat | usage | tools

    function setTab(tab) {
        if (tab === "chat" || tab === "usage" || tab === "tools") {
            activeTab = tab
            if (!isOpen) open()
        }
    }

    function newChat() {
        if (isStreaming && aiProcess.running) {
            aiProcess.running = false
            isStreaming = false
        }
        messages = []
        saveHistory()
    }

    onIsOpenChanged: {
        WallpaperState.dimLevel = (isOpen || LauncherState.isOpen) ? 0.3 : 0.0
    }

    function toggle() {
        isOpen = !isOpen
    }

    function open() {
        isOpen = true
    }

    function close() {
        isOpen = false
    }

    IpcHandler {
        target: "ai"

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function clear(): void {
            root.clearHistory()
        }

        function close(): void {
            root.close()
        }

        function send(text: string): void {
            root.sendMessage(text)
        }

        function tab(t: string): void {
            root.setTab(t)
        }

        function newChat(): void {
            root.newChat()
        }
    }

    FileView {
        id: historyFile
        path: Quickshell.statePath("ai-history.json")
        printErrors: false
        onLoaded: root.loadHistory()
    }

    function loadHistory() {
        try {
            const raw = historyFile.text()
            if (raw && raw.trim().length > 0) {
                const data = JSON.parse(raw)
                if (Array.isArray(data)) {
                    root.messages = data
                }
            }
        } catch (e) {
            console.warn("AIState: Geçmiş yüklenirken hata oluştu:", e)
        }
    }

    function saveHistory() {
        try {
            historyFile.setText(JSON.stringify(root.messages, null, 2))
        } catch (e) {
            console.warn("AIState: Geçmiş kaydedilirken hata oluştu:", e)
        }
    }

    function clearHistory() {
        root.messages = []
        root.saveHistory()
    }

    Process {
        id: aiProcess
        command: ["enyxma-ai-client", "--stream"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                root.handleStreamLine(data)
            }
        }

        onRunningChanged: {
            if (!running && root.isStreaming) {
                Qt.callLater(() => {
                    if (root.isStreaming) {
                        root.isStreaming = false
                        let list = root.messages.slice()
                        if (list.length > 0 && list[list.length - 1].role === "assistant" && list[list.length - 1].content === "") {
                            list[list.length - 1].content = "⚠️ [AI servisine bağlanılamadı veya `enyxma-ai-client` bulunamadı.]"
                            root.messages = list
                        }
                        root.saveHistory()
                    }
                })
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.isStreaming = false
            if (exitCode !== 0) {
                let list = root.messages.slice()
                if (list.length > 0 && list[list.length - 1].role === "assistant" && list[list.length - 1].content === "") {
                    list[list.length - 1].content = "⚠️ [AI servisine bağlanılamadı veya `enyxma-ai-client` bulunamadı.]"
                    root.messages = list
                }
            }
            root.saveHistory()
        }
    }

    function handleStreamLine(line) {
        if (!line || line.trim().length === 0) return

        try {
            const parsed = JSON.parse(line.trim())
            const chunk = parsed.token || parsed.content || parsed.response || parsed.delta || (parsed.choices && parsed.choices[0]?.delta?.content) || ""
            if (chunk) {
                root.appendAssistantChunk(chunk)
            }
            if (parsed.done) {
                root.isStreaming = false
                root.saveHistory()
            }
        } catch (e) {
            // Eğer düz metin satırı gelmişse
            root.appendAssistantChunk(line)
        }
    }

    function appendAssistantChunk(chunk) {
        if (!chunk) return
        let list = root.messages.slice()
        if (list.length === 0 || list[list.length - 1].role !== "assistant") {
            list.push({ role: "assistant", content: chunk })
        } else {
            let last = Object.assign({}, list[list.length - 1])
            last.content += chunk
            list[list.length - 1] = last
        }
        root.messages = list
    }

    function sendMessage(text) {
        if (typeof text !== "string") return

        // 1. Prompt Injection Koruması & Sanitization
        // Kontrol karakterlerini ve null baytları temizle (yeni satır ve sekme hariç)
        const sanitized = text.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "").trim()
        if (sanitized.length === 0) return

        // Maksimum girdi uzunluğu sınırı (Buffer/DDoS koruması)
        const safeText = sanitized.length > 8192 ? sanitized.substring(0, 8192) : sanitized

        // 2. Kullanıcı mesajını listeye ekle
        let list = root.messages.slice()
        list.push({ role: "user", content: safeText })

        // 3. Asistan yanıtı için başlangıç öğesi ekle
        list.push({ role: "assistant", content: "" })
        root.messages = list

        // 4. Akış sürecini başlat
        root.isStreaming = true
        if (aiProcess.running) {
            aiProcess.running = false
        }

        // Doğrudan süreç çalıştırma - bash alt kabuğu kullanılmaz, argümanlar doğrudan execve edilir
        aiProcess.command = ["enyxma-ai-client", "--stream", safeText]
        aiProcess.running = true
    }

    Component.onCompleted: {
        root.loadHistory()
    }
}
