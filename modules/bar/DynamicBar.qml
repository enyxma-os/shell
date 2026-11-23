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
        visible: SettingsState.showClock
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
            visible: SettingsState.showWorkspaces
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

        // Performans ve Depolama: CPU, RAM ve Disk
        PerformanceWidget {
            id: performanceWidget
            visible: SettingsState.showSystemStats
        }

        // Ag Durumu ve RX/TX
        NetworkWidget {
            id: networkWidget
            visible: SettingsState.showNetwork
        }

        // Ses Duzeyi ve Karistirici
        EnyxmaPill {
            id: volumePill
            visible: SettingsState.showVolume
            implicitHeight: 24
            isActive: AudioState.isOpen || AudioState.muted

            onClicked: {
                if (SettingsState.enableAudioMixer) AudioState.toggle()
                else AudioState.toggleMute()
            }
            onRightClicked: AudioState.toggleMute()

            Text {
                text: AudioState.muted
                    ? "󰝟 SESSİZ"
                    : ((AudioState.volume > 0.66 ? "󰕾 " : (AudioState.volume > 0.33 ? "󰖀 " : "󰕿 ")) + Math.round(AudioState.volume * 100) + "%")
                color: AudioState.muted ? Theme.danger : (AudioState.isOpen ? Theme.accent : Theme.textPrimary)
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Pil ve Guc Durumu / Kontrol Merkezi
        SystemMetrics {
            id: systemMetrics
            visible: SettingsState.showPower
        }

        // Odak Zamanlayici
        EnyxmaPill {
            id: focusPill
            visible: SettingsState.enableFocusTimer
            implicitHeight: 24
            isActive: FocusState.running

            onClicked: FocusState.toggle()
            onRightClicked: FocusState.cycleMode()

            Text {
                text: "󰔟 " + FocusState.displayText
                color: FocusState.running ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Konteyner Izleyici
        EnyxmaPill {
            id: containerPill
            visible: SettingsState.enableContainerMonitor
            implicitHeight: 24
            isActive: ContainerState.isOpen

            onClicked: ContainerState.toggle()

            Text {
                text: "󰡨 " + ContainerState.runningCount
                color: ContainerState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Enyxma AI Asistani
        EnyxmaPill {
            id: aiTogglePill
            visible: SettingsState.showAi
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
            visible: SettingsState.showNotifications
        }

        // Sistem Tepsisi
        Tray {
            id: tray
            visible: SettingsState.showTray && implicitWidth > 0
        }
    }
}
