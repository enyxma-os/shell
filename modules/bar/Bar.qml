import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

/**
 * Bar — üst panel.
 *
 * P1 DÜZELTMESİ: `clip: true`
 *   R1'de "Zero Overflow — clip:true ile sınırlandırıldı" iddiası vardı ama
 *   dosyada tek bir `clip` yoktu; saat `anchors.centerIn` ile sağ kümeye
 *   biniyordu. Artık iki RowLayout `clip: true`, ayrıca saat en son çocuk
 *   olduğu için üstte çiziliyor (z-order) — taşma görsel olarak kırpılır.
 */
Rectangle {
    id: root
    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth
    clip: true

    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            leftMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        // Sağ kümeyle çakışmayı önle: genişliğin %25'i
        width: Math.min(implicitWidth, root.width * 0.25)
        clip: true
        spacing: Theme.spacingSmall

        Workspaces {
            id: workspaces
        }
    }

    RowLayout {
        id: rightLayout
        anchors {
            right: parent.right
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        // Saat ile çakışmayı önle
        width: Math.min(implicitWidth, root.width * 0.62)
        layoutDirection: Qt.RightToLeft
        clip: true
        spacing: Theme.spacingSmall

        Tray {
            id: tray
        }

        // Bilişsel çekirdek durumu (Enyxma OS / Thornhill RFC-001)
        ThornhillWidget {
            id: thornhillWidget
        }

        MediaWidget {
            id: mediaWidget
        }

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

        MediaBrowserWidget {
            id: mediaBrowserWidget
        }

        WallpaperWidget {
            id: wallpaperWidget
        }

        PerformanceWidget {
            id: performanceWidget
        }

        NetworkWidget {
            id: networkWidget
        }

        StorageWidget {
            id: storageWidget
        }

        SystemMetrics {
            id: systemMetrics
        }

        NotificationWidget {
            id: notificationWidget
        }
    }

    // Tam merkez ekseninde saat (en son çocuk → üstte çizilir)
    ClockWidget {
        id: clockWidget
        anchors.centerIn: parent
    }
}
