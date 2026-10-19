pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Parlaklık Seviyesi (0.05 - 1.00 arası)
    property real level: 0.85
    property bool hasDevice: false

    // Başlangıçta mevcut parlaklığı tespit et
    Process {
        id: readProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | head -n1 | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data.trim())
                if (!isNaN(val) && val > 0) {
                    root.hasDevice = true
                    root.level = Math.max(0.05, Math.min(1.0, val / 100.0))
                }
            }
        }
    }

    // Parlaklık ayarlama süreci
    Process {
        id: setProc
        running: false
    }

    function setBrightness(val) {
        var clamped = Math.max(0.05, Math.min(1.0, val))
        root.level = clamped
        var pct = Math.round(clamped * 100)

        // Donanım varsa brightnessctl ile yaz, yoksa bile level güncellenip OSD tetiklenir
        setProc.command = ["bash", "-c", "brightnessctl set " + pct + "% >/dev/null 2>&1 || true"]
        setProc.running = false
        setProc.running = true
    }

    function stepUp() {
        setBrightness(root.level + 0.05)
    }

    function stepDown() {
        setBrightness(root.level - 0.05)
    }

    IpcHandler {
        target: "brightness"

        function set(val: real): void { root.setBrightness(val) }
        function stepUp(): void { root.stepUp() }
        function stepDown(): void { root.stepDown() }
        function get(): real { return root.level }
    }
}
