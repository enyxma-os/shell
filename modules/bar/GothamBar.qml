import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

/**
 * GothamBar — Enyxma Shell Gotham 2.0 Brutalist Bar Paneli.
 *
 * Yekpare endustriyel obsidyen kiris, soguk grafit ayiricilar,
 * teknik telemetri bloklari ve kontrollu kehribar vurgular.
 */
Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.bgDark
    radius: 0

    // ── MERKEZ: Iki Katmanli Taktiksel Kronometre ──
    GothamClockWidget {
        id: clockWidget
        anchors.centerIn: parent
        z: 2
    }

    // ── SOL KUME: Mimari Sektor Hucreleri ve Yaratici Araclar ──
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
                text: "󰈈 ENYXMA"
                color: LauncherState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Soguk Grafit Ayirici
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: Theme.borderSubtle
        }

        // Calisma Alanlari: Gotham Mimari Hucre Izgarasi
        GothamWorkspaces {
            id: workspaces
        }

        // Soguk Grafit Ayirici
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: Theme.borderSubtle
        }

        // Duvar Kagidi Koleksiyon Secici
        WallpaperWidget {
            id: wallpaperWidget
        }

        // Ekran Goruntusu ve Medya Tarayicisi
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

    // ── SAG KUME: Telemetri, Sistem Kontrolu ve Bildirim Konsolu ──
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

        // 1. Telemetri Grubu: CPU, RAM, Disk ve Ag
        PerformanceWidget {
            id: performanceWidget
        }

        StorageWidget {
            id: storageWidget
        }

        NetworkWidget {
            id: networkWidget
        }

        // Soguk Grafit Ayirici
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: Theme.borderSubtle
        }

        // 2. Kontrol ve Sistem Grubu
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

        SystemMetrics {
            id: systemMetrics
        }

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

        // Soguk Grafit Ayirici
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: Theme.borderSubtle
        }

        // 3. Bildirim ve Sistem Tepsisi
        NotificationWidget {
            id: notificationWidget
        }

        Tray {
            id: tray
        }
    }

    // Gotham 2.0 alt ayrim hatti: 1 piksel keskin grafit
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.borderSubtle
    }
}
