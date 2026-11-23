pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

/**
 * AudioState — varsayilan cikis/giris dugumu ve canli PipeWire ses karistiricisi.
 *
 * NOT: `PwObjectTracker` hem defaultAudioSink hem defaultAudioSource icin korunur.
 * Mixer listeleri yalnizca AudioPanel acikken `wpctl status` ile guncellenir;
 * kapali iken arka planda polling yapilmaz.
 */
Singleton {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
    }

    // ── Cikis (Hoparlor / Kulaklik) ──────────────────────────────────
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    readonly property string sinkName: Pipewire.defaultAudioSink?.description ?? "Dahili Ses"

    // ── Giris (Mikrofon) ─────────────────────────────────────────────
    readonly property real micVolume: Pipewire.defaultAudioSource?.audio?.volume ?? 0.0
    readonly property bool micMuted: Pipewire.defaultAudioSource?.audio?.muted ?? false
    readonly property string sourceName: Pipewire.defaultAudioSource?.description ?? "Mikrofon"

    // ── Panel Durumu ve Karistirici Listeleri ────────────────────────
    property bool isOpen: false
    property string activeTab: "devices" // devices | apps
    property var sinks: []
    property var sources: []
    property var streams: []

    function open(tab) {
        if (tab && String(tab).length > 0) activeTab = String(tab)
        isOpen = true
        refreshMixer()
    }

    function close() {
        isOpen = false
    }

    function toggle() {
        if (isOpen) close()
        else open("")
    }

    function setVolume(val) {
        const sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        sink.audio.volume = Math.max(0.0, Math.min(1.0, val))
        if (sink.audio.muted && val > 0) sink.audio.muted = false
    }

    function toggleMute() {
        const sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        sink.audio.muted = !sink.audio.muted
    }

    function setMicVolume(val) {
        const src = Pipewire.defaultAudioSource
        if (!src || !src.audio) return
        src.audio.volume = Math.max(0.0, Math.min(1.0, val))
        if (src.audio.muted && val > 0) src.audio.muted = false
    }

    function toggleMicMute() {
        const src = Pipewire.defaultAudioSource
        if (!src || !src.audio) return
        src.audio.muted = !src.audio.muted
    }

    // ── Dugum Bazli wpctl Eylemleri ──────────────────────────────────
    Timer {
        id: refreshDelayTimer
        interval: 150
        repeat: false
        onTriggered: root.refreshMixer()
    }

    function setDefaultNode(id) {
        Quickshell.execDetached(["wpctl", "set-default", String(id)])
        refreshDelayTimer.restart()
    }

    function setNodeVolume(id, val) {
        var clamped = Math.max(0.0, Math.min(1.5, Number(val) || 0))
        Quickshell.execDetached(["wpctl", "set-volume", String(id), clamped.toFixed(2)])
        // Iyimser akis guncellemesi
        var nextStreams = []
        for (var i = 0; i < streams.length; i++) {
            var st = streams[i]
            if (st.id === id) {
                nextStreams.push({ id: st.id, name: st.name, volume: clamped, muted: clamped > 0 ? false : st.muted })
            } else {
                nextStreams.push(st)
            }
        }
        streams = nextStreams
        refreshDelayTimer.restart()
    }

    function toggleNodeMute(id) {
        Quickshell.execDetached(["wpctl", "set-mute", String(id), "toggle"])
        var nextStreams = []
        for (var i = 0; i < streams.length; i++) {
            var st = streams[i]
            if (st.id === id) {
                nextStreams.push({ id: st.id, name: st.name, volume: st.volume, muted: !st.muted })
            } else {
                nextStreams.push(st)
            }
        }
        streams = nextStreams
        refreshDelayTimer.restart()
    }

    // ── wpctl status Ayristirma ──────────────────────────────────────
    function refreshMixer() {
        if (wpctlProc.running) return
        wpctlProc.running = true
    }

    Timer {
        interval: 2000
        running: root.isOpen
        repeat: true
        onTriggered: root.refreshMixer()
    }

    Process {
        id: wpctlProc
        running: false
        command: ["wpctl", "status"]
        stdout: StdioCollector { id: wpctlOut }
        onExited: (code) => {
            if (code !== 0) return
            root.parseWpctlStatus(wpctlOut.text || "")
        }
    }

    function parseWpctlStatus(raw) {
        var lines = String(raw || "").split("\n")
        var inAudio = false
        var section = ""
        var outSinks = []
        var outSources = []
        var outStreams = []

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var trimmed = line.replace(/[│├└─]/g, "").trim()

            if (trimmed === "Audio") {
                inAudio = true
                section = ""
                continue
            }
            if (inAudio && (trimmed === "Video" || trimmed === "Settings")) {
                break
            }
            if (!inAudio) continue

            if (trimmed === "Sinks:") { section = "sinks"; continue }
            if (trimmed === "Sources:") { section = "sources"; continue }
            if (trimmed === "Streams:") { section = "streams"; continue }
            if (trimmed === "Devices:" || trimmed === "Filters:") { section = ""; continue }

            if (section === "sinks" || section === "sources") {
                var m = trimmed.match(/^(\*?)\s*(\d+)\.\s+(.+?)(?:\s+\[vol:\s*([0-9.]+)(\s+MUTED)?\])?$/)
                if (!m) continue
                var item = {
                    id: parseInt(m[2], 10),
                    name: m[3].trim(),
                    isDefault: m[1] === "*",
                    volume: m[4] ? parseFloat(m[4]) : 1.0,
                    muted: !!m[5]
                }
                if (section === "sinks") outSinks.push(item)
                else outSources.push(item)
            } else if (section === "streams") {
                // Alt port satirlarini atla (orn. "151. output_FL > USB Audio:playback_FL")
                if (trimmed.indexOf(">") >= 0) continue
                var sm = trimmed.match(/^(\d+)\.\s+(.+?)(?:\s+\[vol:\s*([0-9.]+)(\s+MUTED)?\])?$/)
                if (!sm) continue
                var sid = parseInt(sm[1], 10)
                // Mevcut iyimser ses bilgisini koru
                var prevVol = 1.0
                var prevMuted = false
                for (var j = 0; j < root.streams.length; j++) {
                    if (root.streams[j].id === sid) {
                        prevVol = root.streams[j].volume
                        prevMuted = root.streams[j].muted
                        break
                    }
                }
                outStreams.push({
                    id: sid,
                    name: sm[2].trim(),
                    volume: sm[3] ? parseFloat(sm[3]) : prevVol,
                    muted: sm[4] ? true : (sm[3] ? false : prevMuted)
                })
            }
        }

        root.sinks = outSinks
        root.sources = outSources
        root.streams = outStreams
    }

    IpcHandler {
        target: "audio"
        function toggleMute(): void { root.toggleMute() }
        function up(): void { root.setVolume(root.volume + 0.05) }
        function down(): void { root.setVolume(root.volume - 0.05) }
        function set(v: real): void { root.setVolume(v) }
        function togglePanel(): void { root.toggle() }
        function openPanel(): void { root.open("") }
        function closePanel(): void { root.close() }
    }
}
