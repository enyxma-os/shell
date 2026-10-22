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
                    root.level = Math.max(0.05, Math.min(1.0, val / 100.0))
                }
            }
        }
        onExited: (code) => {
            // Cihaz yoksa (masaüstü) sessizce yazılımsal seviyeye düş.
            if (code !== 0) root.hasDevice = false
        }
    }

    Process {
        id: setProc
        running: false
    }

    function setBrightness(val) {
        const clamped = Math.max(0.05, Math.min(1.0, Number(val)))
        root.level = clamped
        const pct = Math.round(clamped * 100)

        // Donanım yoksa bile level güncellenir ve OSD tetiklenir.
        if (!root.hasDevice) return
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
