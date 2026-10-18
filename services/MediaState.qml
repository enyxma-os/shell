pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    // Panel açık/kapalı ve sabitleme durumları
    property bool isPanelOpen: false
    property bool isPinned: false
    property bool isHovered: false

    // Fare ayrıldıktan sonra paneli yumuşakça kapatan zamanlayıcı
    Timer {
        id: hideTimer
        interval: 650
        repeat: false
        onTriggered: {
            if (!root.isPinned && !root.isHovered) {
                root.isPanelOpen = false
            }
        }
    }

    function setHovered(val) {
        root.isHovered = val
        if (val) {
            hideTimer.stop()
            root.isPanelOpen = true
        } else {
            if (!root.isPinned) {
                hideTimer.restart()
            }
        }
    }

    function togglePinned() {
        if (root.isPanelOpen && root.isPinned) {
            root.isPinned = false
            root.isPanelOpen = false
            hideTimer.stop()
        } else {
            root.isPinned = true
            root.isPanelOpen = true
            hideTimer.stop()
        }
    }

    function close() {
        root.isPinned = false
        root.isHovered = false
        hideTimer.stop()
        root.isPanelOpen = false
    }

    function open() {
        root.isPanelOpen = true
    }

    function toggle() {
        root.togglePinned()
    }

    // Mpris.players listesinden aktif olan oynatıcıyı reaktif olarak bul
    property var activePlayer: {
        const list = Mpris.players.values
        if (!list || list.length === 0) return null
        for (let i = 0; i < list.length; i++) {
            if (list[i] && (list[i].isPlaying || list[i].playbackState === MprisPlaybackState.Playing)) {
                return list[i]
            }
        }
        return list[0] || null
    }

    // Aktif oynatıcı veya oynatma durumu kontrolü
    readonly property bool hasMedia: activePlayer !== null && (trackTitle.length > 0 || isPlaying)
    readonly property string trackTitle: activePlayer?.trackTitle ?? activePlayer?.metadata?.title ?? ""
    readonly property string artist: activePlayer?.trackArtist ?? activePlayer?.metadata?.artist ?? ""
    readonly property string album: activePlayer?.trackAlbum ?? activePlayer?.metadata?.album ?? ""
    readonly property string artUrl: {
        if (!activePlayer) return ""
        if (activePlayer.trackArtUrl && activePlayer.trackArtUrl.length > 0) {
            return activePlayer.trackArtUrl
        }
        if (activePlayer.metadata && activePlayer.metadata["mpris:artUrl"]) {
            return activePlayer.metadata["mpris:artUrl"]
        }
        var url = activePlayer.metadata ? (activePlayer.metadata["xesam:url"] || "") : ""
        var m = String(url).match(/[?&]v=([A-Za-z0-9_-]{11})/) || String(url).match(/youtu\.be\/([A-Za-z0-9_-]{11})/)
        if (m && m[1]) {
            return "https://i.ytimg.com/vi/" + m[1] + "/mqdefault.jpg"
        }
        return ""
    }

    readonly property string identity: {
        if (!activePlayer) return ""
        var id = activePlayer.identity || activePlayer.desktopEntry || ""
        if (id.length > 0) return id
        var dbus = activePlayer.dbusName || ""
        return dbus.replace(/^org\.mpris\.MediaPlayer2\./, "")
    }

    readonly property bool isPlaying: activePlayer ? (activePlayer.isPlaying || activePlayer.playbackState === MprisPlaybackState.Playing) : false

    readonly property bool canControl: activePlayer?.canControl ?? true
    readonly property bool canGoNext: activePlayer?.canGoNext ?? true
    readonly property bool canGoPrevious: activePlayer?.canGoPrevious ?? true
    readonly property bool canSeek: activePlayer?.canSeek ?? false

    // Oynatıcı Ses Seviyesi (0.0 - 1.0)
    readonly property real playerVolume: activePlayer?.volume ?? 1.0

    // Canlı Süre Takibi (Extrapolation)
    property real curPos: 0
    property real curLen: 0
    property real _lastRead: -1

    Timer {
        id: posTimer
        interval: 500
        repeat: true
        running: root.hasMedia && root.isPlaying
        triggeredOnStart: true
        onTriggered: {
            if (!root.activePlayer) return
            var p = root.activePlayer.position || 0
            root.curLen = root.activePlayer.length || 0
            if (Math.abs(p - root._lastRead) > 0.05) {
                root.curPos = p
                root._lastRead = p
            } else if (root.isPlaying) {
                var cap = root.curLen > 0 ? root.curLen : (p + 1e6)
                root.curPos = Math.min(cap, root.curPos + 0.5)
            }
        }
    }

    onIsPlayingChanged: {
        _lastRead = -1
        if (activePlayer) {
            curPos = activePlayer.position || 0
            curLen = activePlayer.length || 0
        }
    }

    onActivePlayerChanged: {
        _lastRead = -1
        if (activePlayer) {
            curPos = activePlayer.position || 0
            curLen = activePlayer.length || 0
        } else {
            curPos = 0
            curLen = 0
            close()
        }
    }

    readonly property real shownPos: curLen > 0 ? Math.min(curPos, curLen) : curPos

    function formatTime(s) {
        if (!s || s <= 0 || isNaN(s)) return "0:00"
        var m = Math.floor(s / 60)
        var sec = Math.floor(s % 60)
        return m + ":" + (sec < 10 ? "0" + sec : "" + sec)
    }

    function seekToFraction(fraction) {
        if (!activePlayer || curLen <= 0) return
        var target = Math.max(0, Math.min(1, fraction)) * curLen
        curPos = target
        _lastRead = -1
        if (typeof activePlayer.setPosition === "function") {
            activePlayer.setPosition(target)
        } else if (typeof activePlayer.position !== "undefined") {
            activePlayer.position = target
        }
    }

    function setPlayerVolume(val) {
        if (!activePlayer) return
        var v = Math.max(0, Math.min(1, val))
        if (typeof activePlayer.volume !== "undefined") {
            activePlayer.volume = v
        }
    }

    function togglePlayPause() {
        if (!activePlayer) return
        if (typeof activePlayer.togglePlaying === "function") {
            activePlayer.togglePlaying()
        } else if (isPlaying) {
            activePlayer.pause()
        } else {
            activePlayer.play()
        }
    }

    function next() {
        if (activePlayer && typeof activePlayer.next === "function") {
            activePlayer.next()
        }
    }

    function previous() {
        if (activePlayer && typeof activePlayer.previous === "function") {
            activePlayer.previous()
        }
    }

    IpcHandler {
        target: "media"

        function toggle(): void {
            root.togglePlayPause()
        }

        function next(): void {
            root.next()
        }

        function previous(): void {
            root.previous()
        }

        function togglePanel(): void {
            root.toggle()
        }
    }
}
