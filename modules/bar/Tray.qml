import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../services"
import "../../widgets"

/**
 * Tray — StatusNotifierItem tepsisi.
 *
 * DÜZELTME NOTU (R1'deki B10 bulgusunun geri alınması):
 *   Quickshell 0.3 dokümanı SystemTrayItem.icon için "Icon source string,
 *   usable as an Image source" diyor — yani `modelData.icon` doğrudan
 *   Image.source olarak KULLANILABİLİR. R1'deki "icon bir addır, iconPath
 *   gerekir" tespiti yanlıştı; kod olduğu gibi doğruydu, burada değişiklik
 *   yalnızca sağ tık menüsü + eksik ikon fallback'i olarak eklendi.
 *   (quickshell.org/docs/v0.3.0/types/Quickshell.Services.SystemTray/SystemTrayItem)
 */
RowLayout {
    id: root
    spacing: Theme.spacingXS

    Repeater {
        model: SystemTray.items

        EnyxmaPill {
            id: trayPill
            implicitHeight: 24
            implicitWidth: 24
            visible: !!modelData
            onRightClicked: {
                if (modelData) {
                    // SNI platform menüsü: quickshell 0.3 `display(parent, x, y)`
                    modelData.display(trayPill, 0, trayPill.height)
                }
            }

            onClicked: {
                if (modelData) {
                    modelData.activate()
                }
            }

            // Orta tık = secondaryActivate (SNI sözleşmesi)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: if (modelData) modelData.secondaryActivate()
            }

            Image {
                source: modelData?.icon ?? ""
                width: 14
                height: 14
                fillMode: Image.PreserveAspectFit
                // İkon yoksa glif yerine boş kalmasın: küçük nötr nokta
                visible: status === Image.Ready
            }

            Text {
                visible: !!(modelData && !modelData.icon)
                text: "•"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
