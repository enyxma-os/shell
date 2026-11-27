import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: stp

    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property bool gotham: Theme.isGotham

    signal decrement()
    signal increment()

    width: parent ? parent.width : 0
    height: 52
    radius: gotham ? 0 : Theme.radiusButton
    color: Theme.surface1
    border.color: Theme.borderSubtle
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Column {
            Layout.fillWidth: true
            spacing: 2

            Text {
                width: parent.width
                text: stp.title
                color: Theme.textPrimary
                font.family: stp.gotham ? Theme.fontMono : Theme.fontFamily
                font.pixelSize: stp.gotham ? 11 : 12
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: stp.subtitle
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Rectangle {
            implicitWidth: 28
            implicitHeight: 26
            radius: stp.gotham ? 0 : Theme.radiusSmall
            color: decMa.containsMouse ? Theme.surfaceHover : Theme.surface2
            border.color: decMa.containsMouse ? Theme.accent : Theme.borderSubtle
            border.width: 1

            Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
            MouseArea { id: decMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: stp.decrement() }
        }

        Text {
            text: stp.valueText
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 56
        }

        Rectangle {
            implicitWidth: 28
            implicitHeight: 26
            radius: stp.gotham ? 0 : Theme.radiusSmall
            color: incMa.containsMouse ? Theme.surfaceHover : Theme.surface2
            border.color: incMa.containsMouse ? Theme.accent : Theme.borderSubtle
            border.width: 1

            Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
            MouseArea { id: incMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: stp.increment() }
        }
    }
}

