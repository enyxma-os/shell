import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"
import "."

Rectangle {
    id: root
    color: Theme.bgGlass
    radius: Theme.radiusPanel
    border.color: Theme.borderSubtle
    border.width: Theme.borderWidth

    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            leftMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
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
        spacing: Theme.spacingSmall

        Tray {
            id: tray
        }

        MediaWidget {
            id: mediaWidget
        }

        EnyxmaPill {
            id: aiTogglePill
            implicitHeight: 24
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

            onClicked: AudioState.toggleMute()

            Text {
                text: AudioState.muted ? "MUTED" : Math.round(AudioState.volume * 100) + "%"
                color: AudioState.muted ? Theme.danger : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
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

    // Orta Alan: Sol ve Sağ arasındaki alana kilitlenmiş, asla taşmayan Pencere Başlığı
    Item {
        id: centerContainer
        anchors {
            left: leftLayout.right
            right: rightLayout.left
            leftMargin: Theme.spacingMedium
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        height: parent.height
        clip: true

        Text {
            id: windowTitleText
            anchors.centerIn: parent
            width: Math.min(implicitWidth, parent.width)
            text: HyprlandState.activeWindowTitle.length > 0 ? HyprlandState.activeWindowTitle : "Enyxma OS"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
