pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

/**
 * AudioState — varsayılan çıkış düğümü (Pipewire).
 *
 * NOT: `PwObjectTracker` KORUNMUŞTUR. O olmadan `Pipewire.defaultAudioSink`
 * nesnesi izlenmez ve `audio.volume` / `audio.muted` güncellenmez — yani
 * bar yüzdesi donar. (Bu, sadeleştirme sırasında kolayca kaybedilen bir
 * bağımlılıktır; kaldırmayın.)
 */
Singleton {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    readonly property string sinkName: Pipewire.defaultAudioSink?.description ?? "Dahili Ses"

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

    IpcHandler {
        target: "audio"
        function toggleMute(): void { root.toggleMute() }
        function up(): void { root.setVolume(root.volume + 0.05) }
        function down(): void { root.setVolume(root.volume - 0.05) }
        function set(v: real): void { root.setVolume(v) }
    }
}
