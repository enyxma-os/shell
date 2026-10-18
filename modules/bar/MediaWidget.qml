import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

EnyxmaPill {
    id: root

    // Sadece müzik çalarken veya aktif medya varken görünür
    visible: MediaState.hasMedia
    opacity: MediaState.hasMedia ? 1.0 : 0.0

    Behavior on opacity {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    implicitHeight: 24
    implicitWidth: 44

    onClicked: MediaState.toggle()

    // Hover desteği (istemsiz hızlı mouse geçişlerini engellemek için 150ms debounce)
    Timer {
        id: hoverOpenTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (mouseArea.containsMouse) {
                MediaState.setHovered(true)
            }
        }
    }

    mouseArea.hoverEnabled: true
    mouseArea.onEntered: hoverOpenTimer.restart()
    mouseArea.onExited: {
        hoverOpenTimer.stop()
        MediaState.setHovered(false)
    }

    RowLayout {
        spacing: Theme.spacingXS
        Layout.alignment: Qt.AlignVCenter

        // Mini Kapak veya Müzik İkonu
        Item {
            implicitWidth: 16
            implicitHeight: 16

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Theme.surface2
                clip: true

                Image {
                    anchors.fill: parent
                    source: MediaState.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible: MediaState.artUrl === ""
                    text: "󰝚"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        // Canlı Mini Ritim Dalgaları
        Item {
            implicitWidth: waveRow.implicitWidth
            implicitHeight: 14
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: waveRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                property real phase: 0.0

                Timer {
                    interval: 120
                    repeat: true
                    running: MediaState.isPlaying
                    onTriggered: waveRow.phase = (waveRow.phase + 1) % 6
                }

                Repeater {
                    model: 3
                    delegate: Rectangle {
                        required property int index
                        width: 2
                        radius: 1
                        color: Theme.accent
                        height: {
                            if (!MediaState.isPlaying) return 3
                            var p = (waveRow.phase + index * 2) % 6
                            return [3, 8, 12, 6, 10, 5][p]
                        }

                        Behavior on height {
                            enabled: !Theme.reduceMotion
                            NumberAnimation {
                                duration: 110
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }
    }
}
