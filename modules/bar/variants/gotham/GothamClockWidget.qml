import QtQuick
import QtQuick.Layouts
import "../../../services"

Rectangle {
    id: root

    readonly property bool isActive: TimeState.isPanelOpen || TimeState.isMenuOpen

    implicitHeight: 28
    implicitWidth: contentCol.implicitWidth + 16
    radius: 2

    color: isActive
        ? Theme.surfaceActive
        : (clockMouse.containsMouse ? Theme.surfaceHover : Theme.surface1)
    border.color: isActive ? Theme.accent : Theme.borderSubtle
    border.width: 1

    ColumnLayout {
        id: contentCol
        anchors.centerIn: parent
        spacing: 1

        // Ust Katman: Saat, kontrollu mikro saniye ve meteoroloji
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 3

            Text {
                text: TimeState.hours + ":" + TimeState.minutes
                color: root.isActive ? Theme.accent : Theme.textPrimary
                font.family: "Orbitron"
                font.pixelSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: ":" + TimeState.seconds
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "·"
                color: Theme.borderSubtle
                font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: WeatherState.displayTemp
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Alt Katman: Okunabilir taktiksel tarih ve gun
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 3

            Text {
                text: TimeState.formattedDate.toUpperCase()
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "· " + TimeState.dayName.toUpperCase()
                color: root.isActive ? Theme.accent : Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                TimeState.toggleMenu()
            } else {
                TimeState.togglePanel()
            }
        }
    }
}

