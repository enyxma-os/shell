import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isOpen: PerformanceState.isOpen && PerformanceState.activeTab === "performance"

    implicitHeight: 24
    onClicked: PerformanceState.toggle()

    Behavior on implicitWidth {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: Theme.spacingXS

        // ── CPU Bölümü ──
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "󰍛"
            color: root.isOpen ? Theme.accent : (PerformanceState.cpuPercent > 80 ? Theme.danger : Theme.textPrimary)
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall

            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: PerformanceState.cpuPercent + "%" + (root.isHovered && PerformanceState.cpuCores > 0 ? (" (" + PerformanceState.cpuCores + "T)") : "")
            color: Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }

        // İnce Ayırıcı Nokta
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "·"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }

        // ── Bellek (RAM) Bölümü ──
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "󰾆"
            color: root.isOpen ? Theme.accent : (PerformanceState.memPercent > 85 ? Theme.danger : Theme.textPrimary)
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall

            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.isHovered
                ? (PerformanceState.memUsedGiB.toFixed(1) + "/" + PerformanceState.memTotalGiB.toFixed(0) + "G")
                : (PerformanceState.memPercent + "%")
            color: Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
