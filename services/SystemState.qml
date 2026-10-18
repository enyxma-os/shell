pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "."

Singleton {
    id: root

    // Kontrol Merkezi Görünürlük Durumu
    property bool isControlCenterOpen: false

    function toggleControlCenter() {
        isControlCenterOpen = !isControlCenterOpen
    }

    function openControlCenter() {
        isControlCenterOpen = true
    }

    function closeControlCenter() {
        isControlCenterOpen = false
    }

    // Pil ve Güç Durumu (Quickshell UPower Servisi)
    readonly property bool isBatteryPresent: UPower.displayDevice?.isPresent ?? false
    readonly property int batteryPercent: isBatteryPresent ? Math.round(UPower.displayDevice?.percentage ?? 100) : 100
    readonly property bool isCharging: isBatteryPresent ? (UPower.displayDevice?.state === UPowerDeviceState.Charging || UPower.displayDevice?.state === UPowerDeviceState.FullyCharged) : true

    // Ağ (Network) Durumu - NetworkState singleton üzerinden bağlanır
    readonly property bool isConnected: NetworkState.isConnected
    readonly property string wifiSSID: NetworkState.connectionType === "wifi" ? (NetworkState.connectionName || "Wi-Fi") : (NetworkState.connectionName || "Ethernet")

    IpcHandler {
        target: "system"

        function toggle(): void { root.toggleControlCenter() }
        function toggleControlCenter(): void { root.toggleControlCenter() }
        function open(): void { root.openControlCenter() }
        function openControlCenter(): void { root.openControlCenter() }
        function close(): void { root.closeControlCenter() }
        function closeControlCenter(): void { root.closeControlCenter() }
    }

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
}
