pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "."

/**
 * SystemState — kontrol merkezi görünürlüğü, pil, ağ özeti, uptime.
 *
 * P1 DÜZELTMESİ:
 *   Uptime için her 60 sn'de bir `bash -c awk /proc/uptime` çalışıyordu
 *   (günde 1.440 process). Artık `/proc/uptime` doğrudan FileView ile
 *   okunuyor ve hesaplama JS'te yapılıyor → fork yok.
 *
 *   Ayrıca `wifiSSID` bağlantı yokken "Ethernet" döndürüyordu (R1/B28);
 *   artık boş bağlantıda boş dize döner.
 */
Singleton {
    id: root

    property bool isControlCenterOpen: false
    property bool isBarVisible: true

    function toggleBar() { isBarVisible = !isBarVisible }

    function toggleControlCenter() { isControlCenterOpen = !isControlCenterOpen }
    function openControlCenter() { isControlCenterOpen = true }
    function closeControlCenter() { isControlCenterOpen = false }

    // ── Pil / güç ───────────────────────────────────────────────────
    readonly property bool isBatteryPresent: UPower.displayDevice?.isPresent ?? false
    readonly property int batteryPercent: isBatteryPresent ? Math.round(UPower.displayDevice?.percentage ?? 100) : 100
    readonly property bool isCharging: isBatteryPresent
        ? (UPower.displayDevice?.state === UPowerDeviceState.Charging ||
           UPower.displayDevice?.state === UPowerDeviceState.FullyCharged)
        : true

    // ── Ağ özeti ────────────────────────────────────────────────────
    readonly property bool isConnected: NetworkState.isConnected
    readonly property string wifiSSID: {
        if (!root.isConnected || !NetworkState.connectionName) return ""
        return NetworkState.connectionName
    }

    // ── Uptime (fork yok) ───────────────────────────────────────────
    property string uptime: ""

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        printErrors: false
        onLoaded: root.parseUptime(uptimeFile.text())
    }

    function parseUptime(text) {
        const s = Math.floor(parseFloat(String(text || "").trim()) || 0)
        if (s <= 0) return
        const d = Math.floor(s / 86400)
        const h = Math.floor((s % 86400) / 3600)
        const m = Math.floor((s % 3600) / 60)
        if (d > 0) root.uptime = d + "g " + h + "s"
        else if (h > 0) root.uptime = h + "s " + m + "d"
        else root.uptime = m + "d"
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: uptimeFile.reload()
    }

    IpcHandler {
        target: "system"
        function toggle(): void { root.toggleControlCenter() }
        function open(): void { root.openControlCenter() }
        function close(): void { root.closeControlCenter() }
    }

    // Eski IPC adları (geriye dönük uyumluluk — R1'de "şişkin" bulundu ama
    // kullanıcı anahtarları yeniden bağlamak zorunda kalmasın diye tutuluyor).
    IpcHandler {
        target: "dashboard"
        function toggle(): void { root.toggleControlCenter() }
        function open(): void { root.openControlCenter() }
        function close(): void { root.closeControlCenter() }
    }

    IpcHandler {
        target: "enyxma-dashboard"
        function toggle(): void { root.toggleControlCenter() }
        function open(): void { root.openControlCenter() }
        function close(): void { root.closeControlCenter() }
    }

    IpcHandler {
        target: "bar"
        function toggle(): void { root.toggleBar() }
        function show(): void { root.isBarVisible = true }
        function hide(): void { root.isBarVisible = false }
    }

    IpcHandler {
        target: "enyxma-bar"
        function toggle(): void { root.toggleBar() }
        function show(): void { root.isBarVisible = true }
        function hide(): void { root.isBarVisible = false }
    }
}
