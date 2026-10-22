pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * BluetoothState — BlueZ adaptör durumu (kontrol merkezi karosu için).
 *
 * R1/B2: ControlCenter'daki Bluetooth karosu tamamen ölüydü — MouseArea vardı
 * ama `onClicked` yoktu, alt metin sabit "Hazır" yazıyordu.
 *
 * Tasarım:
 *  • Polling YOK. Durum yalnızca: shell açılışında 1 kez, panel açıldığında
 *    ve toggle sonrası (tek doğrulama) sorgulanır.
 *  • `bluetoothctl show` çıktısı ayrıştırılır (Powered/Discoverable).
 *  • `bluetoothctl` yoksa durum "unsupported" olur ve karo bunu dürüstçe
 *    yazar — sahte "Hazır" göstermez.
 */
Singleton {
    id: root

    // "unknown" | "on" | "off" | "unsupported"
    property string state: "unknown"
    property bool busy: false
    property string lastError: ""
    property string adapter: ""

    readonly property bool enabled: root.state === "on"
    readonly property bool supported: root.state !== "unsupported"

    readonly property string statusText: {
        if (root.state === "unsupported") return "bluetoothctl yok"
        if (root.state === "unknown") return "Sorgulanıyor…"
        if (root.state === "on") return root.adapter !== "" ? root.adapter : "Açık"
        return "Kapalı"
    }

    Process {
        id: showProc
        running: false
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { id: out }
        onExited: (code) => {
            root.busy = false
            if (code !== 0) {
                root.state = "unsupported"
                root.lastError = "bluetoothctl bulunamadı"
                return
            }
            const text = out.text || ""
            let powered = "unknown"
            let name = ""
            const lines = text.split("\n")
            for (let i = 0; i < lines.length; i++) {
                const mP = lines[i].match(/^\s*Powered:\s*(\w+)/i)
                if (mP) powered = mP[1].toLowerCase()
                const mN = lines[i].match(/^\s*Name:\s*(.+)$/i)
                if (mN) name = mN[1].trim()
            }
            root.adapter = name
            root.state = powered === "yes" ? "on" : "off"
            root.lastError = ""
        }
    }

    function refresh() {
        if (showProc.running) return
        root.busy = true
        showProc.running = true
    }

    Timer {
        id: verifyTimer
        interval: 300
        repeat: false
        onTriggered: root.refresh()
    }

    function togglePower() {
        if (!root.supported || root.busy) {
            if (!root.supported) root.lastError = "BlueZ aracı yok"
            return
        }
        root.busy = true
        root.state = root.enabled ? "off" : "on"   // iyimser
        powerProc.exec(["bluetoothctl", "power", root.enabled ? "off" : "on"])
        verifyTimer.restart()
    }

    Process {
        id: powerProc
        running: false
        onExited: (code) => {
            if (code !== 0) {
                root.lastError = "Güç değiştirilemedi (kod " + code + ")"
                root.refresh()
            }
        }
    }

    Component.onCompleted: root.refresh()

    IpcHandler {
        target: "bluetooth"
        function toggle(): void { root.togglePower() }
        function refresh(): void { root.refresh() }
        function status(): string { return root.state }
    }
}
