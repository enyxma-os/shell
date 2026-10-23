import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

/**
 * Bar — Enyxma Shell Üst Paneli.
 *
 * Mimari Dağılım:
 *  - Sol Küme (Masaüstü & Yaratıcı Araçlar):
 *      Workspaces, Duvar Kağıdı Seçici, Ekran Görüntüsü/Video Galerisi, Medya Oynatıcı
 *  - Merkez (Zaman & Bento Hub):
 *      ClockWidget (Hava Durumu, Saat, Tarih, Sıcaklık) — Kesin geometrik koruma, asla çakışma olamaz.
 *  - Sağ Küme (Donanım Telemetrisi, AI, Çekirdek, Sistem Kontrolü & Bildirim):
 *      Performans (CPU/RAM), Depolama (Disk), Ağ (RX/TX), Ses, Pil/Güç, AI Hub, Thornhill, Bildirimler, Tray
 */
Rectangle {
    id: root
    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    // ── MERKEZ: Saat, Tarih, Hava Durumu & Bento Hub ──
    ClockWidget {
        id: clockWidget
        anchors.centerIn: parent
        z: 2
    }

    // ── SOL KÜME: Masaüstü, Görsel & Medya Hub'ı ──
    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            leftMargin: Theme.spacingMedium
            right: clockWidget.left
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacingSmall

        // 1. Çalışma Alanları (Hyprland Workspaces)
        Workspaces {
            id: workspaces
        }

        // 2. Duvar Kağıdı Seçici (WallpaperWidget)
        WallpaperWidget {
            id: wallpaperWidget
        }

        // 3. Ekran Görüntüsü & Kayıt Galerisi (MediaBrowserWidget)
        MediaBrowserWidget {
            id: mediaBrowserWidget
        }

        // 4. Çalan Medya / Canlı Ritim Dalgaları (MediaWidget)
        MediaWidget {
            id: mediaWidget
        }

        // Kalan boşluğu sağa doğru it
        Item {
            Layout.fillWidth: true
        }
    }

    // ── SAĞ KÜME: Donanım Telemetrisi, AI, Bilişsel Çekirdek, Sistem & Bildirimler ──
    RowLayout {
        id: rightLayout
        anchors {
            left: clockWidget.right
            leftMargin: Theme.spacingMedium
            right: parent.right
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacingXS

        // Sol tarafı boş bırakıp bileşenleri sağa yasla
        Item {
            Layout.fillWidth: true
        }

        // 5. Performans (CPU / RAM İzleyici)
        PerformanceWidget {
            id: performanceWidget
        }

        // 6. Depolama (Kök Disk Doluluk)
        StorageWidget {
            id: storageWidget
        }

        // 7. Ağ Durumu & RX/TX İndikatörü
        NetworkWidget {
            id: networkWidget
        }

        // 8. Ses Düzeyi & Mute
        EnyxmaPill {
            id: volumePill
            implicitHeight: 24
            isActive: AudioState.muted

            onClicked: AudioState.toggleMute()

            Text {
                text: AudioState.muted ? "MUTED" : Math.round(AudioState.volume * 100) + "%"
                color: AudioState.muted ? Theme.danger : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // 9. Pil & Güç Durumu / Kontrol Merkezi
        SystemMetrics {
            id: systemMetrics
        }

        // 10. Enyxma AI Asistanı
        EnyxmaPill {
            id: aiTogglePill
            implicitHeight: 24
            isActive: AIState.isOpen
            onClicked: AIState.toggle()

            Text {
                text: "✦ AI"
                color: AIState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
            }
        }



        // 12. Bildirim Merkezi & Rozet
        NotificationWidget {
            id: notificationWidget
        }

        // 13. Sistem Tepsisi (StatusNotifierItem)
        Tray {
            id: tray
        }
    }
}
