import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    readonly property int notifCount: NotificationState.notifications.length

    implicitHeight: 24
    onClicked: NotificationState.toggle()

    Item {
        id: container
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: root.notifCount > 0 ? 24 : 16
        implicitHeight: 16

        // Çan / Bildirim İkonu
        Text {
            id: bellIcon
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.notifCount > 0 ? -3 : 0
            text: "󰂚"
            color: NotificationState.isPanelOpen ? Theme.accent
                 : (root.notifCount > 0 ? Theme.textPrimary : Theme.textSecondary)
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeNormal

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }

        // Bildirim Sayısı Rozeti (Badge - Sağ üst köşeye bindirilmiş)
        Rectangle {
            id: badge
            visible: root.notifCount > 0
            implicitHeight: 12
            implicitWidth: Math.max(12, badgeTxt.implicitWidth + 4)
            radius: Theme.isGotham ? 2 : 6
            color: Theme.accent

            anchors {
                verticalCenter: bellIcon.verticalCenter
                verticalCenterOffset: -6
                left: bellIcon.horizontalCenter
                leftMargin: 2
            }

            Text {
                id: badgeTxt
                anchors.centerIn: parent
                text: root.notifCount > 99 ? "99" : String(root.notifCount)
                color: Theme.scrim
                font.family: Theme.fontMono
                font.pixelSize: 7
                font.bold: true
            }
        }
    }
}
