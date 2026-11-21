import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

/**
 * DynamicBar — Enyxma Shell Dinamik Tema Ustu Paneli.
 *
 * Yuvarlatilmis cam paneller, Matugen renk uyumu ve yuzen bar karakteri.
 */
Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    // ── MERKEZ: Dinamik Saat ve Tarih Bileseni ──
    DynamicClockWidget {
        id: clockWidget
        anchors.centerIn: parent
        z: 2
    }

    // ── SOL KUME: Masaustu, Gorsel ve Medya Kumesi ──
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

        // Enyxma Sistem ve Komut Menusu
        EnyxmaPill {
            id: menuPill
            implicitHeight: 24
            isActive: LauncherState.isOpen
            onClicked: LauncherState.toggle()
            onRightClicked: LauncherState.openMode("actions")

            Text {
                text: "✦"
                color: LauncherState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fontSizeNormal
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Calisma Alanlari
        DynamicWorkspaces {
            id: workspaces
        }

        // Duvar Kagidi Secici
        WallpaperWidget {
            id: wallpaperWidget
        }

        // Ekran Goruntusu ve Kayit Galerisi
        MediaBrowserWidget {
            id: mediaBrowserWidget
        }

        // Calan Medya
        MediaWidget {
            id: mediaWidget
        }

        // Kalan boslugu saga dogru it
        Item {
            Layout.fillWidth: true
        }
    }

    // ── SAG KUME: Donanim Telemetrisi, AI, Sistem Kontrolu ve Bildirimler ──
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

        // Sol tarafi bos birakip bilesenleri saga yasla
        Item {
            Layout.fillWidth: true
        }

        // Performans: CPU ve RAM
        PerformanceWidget {
            id: performanceWidget
        }

        // Depolama: Kok Disk
        StorageWidget {
            id: storageWidget
        }

        // Ag Durumu ve RX/TX
        NetworkWidget {
            id: networkWidget
        }

        // Ses Duzeyi ve Mute
        EnyxmaPill {
            id: volumePill
            implicitHeight: 24
            isActive: AudioState.muted

            onClicked: AudioState.toggleMute()
            onRightClicked: SystemState.toggleControlCenter()

            Text {
                text: AudioState.muted
                    ? "󰝟 SESSİZ"
                    : ((AudioState.volume > 0.66 ? "󰕾 " : (AudioState.volume > 0.33 ? "󰖀 " : "󰕿 ")) + Math.round(AudioState.volume * 100) + "%")
                color: AudioState.muted ? Theme.danger : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Pil ve Guc Durumu / Kontrol Merkezi
        SystemMetrics {
            id: systemMetrics
        }

        // Enyxma AI Asistani
        EnyxmaPill {
            id: aiTogglePill
            implicitHeight: 24
            isActive: AIState.isOpen
            onClicked: AIState.toggle()

            Text {
                text: Theme.aiLabel
                color: AIState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
            }
        }

        // Bildirim Merkezi
        NotificationWidget {
            id: notificationWidget
        }

        // Sistem Tepsisi
        Tray {
            id: tray
        }
    }
}
