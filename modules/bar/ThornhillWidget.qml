import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * ThornhillWidget — bilişsel çekirdek durum hapı.
 * Sol tık: başlat/durdur · Sağ tık: durumu yenile · Orta tık: :9099 konsolu
 */
EnyxmaPill {
    id: root

    implicitHeight: 24
    isActive: ThornhillState.running
    onClicked: ThornhillState.toggle()
    onRightClicked: ThornhillState.refresh()
    onMiddleClicked: ThornhillState.openConsole()

    // Bar göründüğünde tek seferlik doğrulama (polling yok).
    Component.onCompleted: ThornhillState.refresh()

    Text {
        Layout.alignment: Qt.AlignVCenter
        // 👁️ + durum noktası. Renk tek kaynaktan: ThornhillState.color
        text: Theme.isGotham ? "󰈈" : "👁"
        color: ThornhillState.color
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
        opacity: ThornhillState.running ? 1.0 : 0.55
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: ThornhillState.busy ? "…" : ThornhillState.label
        color: ThornhillState.color
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSizeSmall
        font.bold: ThornhillState.running
    }

    // Okunmamış Action Chip sayacı (STUB veri kaynağı: ThornhillState.actionChips)
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        visible: ThornhillState.unreadChips > 0
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: Theme.danger

        Text {
            anchors.centerIn: parent
            text: ThornhillState.unreadChips > 9 ? "9+" : String(ThornhillState.unreadChips)
            color: Theme.accentOn
            font.family: Theme.fontMono
            font.pixelSize: 9
            font.bold: true
        }
    }


}
