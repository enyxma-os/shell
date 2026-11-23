pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * BrightnessState — brightnessctl köprüsü.
 *
 * P0 GÜVENLİK DÜZELTMESİ:
 *   Eski kod parlaklığı `('bash', '-c', 'brightnessctl set...')`
 *   ile yazıyordu: sayısal görünse de değer bir zamanlar dışarıdan
 *   (IPC `set`, OSD sürüklemesi) geldiği için string birleştirme
 *   prensip olarak enjeksiyona açıktı ve her tuş vuruşunda fazladan
 *   bir bash süreci çatallıyordu.
 *
 *   Artık:
 *   • Okuma: `brightnessctl -m` (makine biçimi) → tek Process, kabuk yok.
 *     Çıktı `device,class,current,max,percent%`; yüzde alanı JS'te ayrıştırılır.
 *   • Yazma: `["brightnessctl","set","42%"]` → execve, kabuk yok.
 *   • Değer zaten `Math.max/min` ile [0.05, 1.0] aralığına kırpılır ve
 *     `Math.round` ile tamsayıya çevrilir; argüman dizisi olduğu için
 *     "%" dışında hiçbir meta karakter yorumlanmaz.
 */
Singleton {
    id: root

    // Parlaklık Seviyesi (0.05 - 1.00 arası)
    property real level: 0.85
    property bool hasDevice: false
    property string backend: "none" // none | brightnessctl | ddcutil
    readonly property string ddcBus: Quickshell.env("ENYXMA_DDC_BUS") || ""
    property int _pendingPct: 85

    // Başlangıçta mevcut parlaklığı tespit et (kabuksuz, tek seferlik).
    Process {
        id: readProc
        running: true
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                // device,class,current,max,percent%
                const f = data.trim().split(",")
                if (f.length < 5) return
                const val = parseInt(f[4])
                if (!isNaN(val) && val > 0) {
                    root.hasDevice = true
                    root.backend = "brightnessctl"
                    root.level = Math.max(0.05, Math.min(1.0, val / 100.0))
                }
            }
        }
        onExited: (code) => {
            if (code !== 0 || !root.hasDevice) {
                if (root.ddcBus.length > 0 && /^\d+$/.test(root.ddcBus)) {
                    ddcReadProc.running = true
                } else {
                    root.hasDevice = false
                    root.backend = "none"
                }
            }
        }
    }

    // Harici monitör başlangıç parlaklığı: yalnızca ENYXMA_DDC_BUS tanımlıysa tek veriyolundan okur
    Process {
        id: ddcReadProc
        running: false
        command: ["ddcutil", "-b", root.ddcBus, "getvcp", "10", "--brief"]
        stdout: SplitParser {
            onRead: data => {
                // VCP 10 C <current> <max>
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 5 && parts[0] === "VCP" && parts[1] === "10") {
                    const cur = parseInt(parts[3])
                    const max = parseInt(parts[4])
                    if (!isNaN(cur) && !isNaN(max) && max > 0) {
                        root.hasDevice = true
                        root.backend = "ddcutil"
                        root.level = Math.max(0.05, Math.min(1.0, cur / max))
                    }
                }
            }
        }
        onExited: (code) => {
            if (code !== 0 && root.backend !== "ddcutil") {
                root.hasDevice = false
                root.backend = "none"
            }
        }
    }

    Process {
        id: setProc
        running: false
    }

    Process {
        id: ddcSetProc
        running: false
    }

    Timer {
        id: ddcDebounceTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (root.backend !== "ddcutil" || root.ddcBus.length === 0) return
            if (ddcSetProc.running) {
                ddcDebounceTimer.restart()
                return
            }
            ddcSetProc.exec(["ddcutil", "-b", root.ddcBus, "setvcp", "10", String(root._pendingPct)])
        }
    }

    function setBrightness(val) {
        const clamped = Math.max(0.05, Math.min(1.0, Number(val)))
        root.level = clamped
        const pct = Math.round(clamped * 100)

        // Donanım yoksa bile level güncellenir ve OSD tetiklenir.
        if (!root.hasDevice) return
        if (root.backend === "ddcutil") {
            root._pendingPct = pct
            ddcDebounceTimer.restart()
            return
        }
        setProc.exec(["brightnessctl", "set", pct + "%"])
    }

    function stepUp() {
        root.setBrightness(root.level + 0.05)
    }

    function stepDown() {
        root.setBrightness(root.level - 0.05)
    }

    IpcHandler {
        target: "brightness"

        function set(val: real): void { root.setBrightness(val) }
        function stepUp(): void { root.stepUp() }
        function stepDown(): void { root.stepDown() }
        function get(): real { return root.level }
    }
}
