pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    readonly property string sinkName: Pipewire.defaultAudioSink?.description ?? "Dahili Ses"

    function setVolume(val) {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.0, val))
        }
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
        }
    }
}
