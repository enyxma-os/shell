import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

Item {
    id: root

    implicitHeight: col.implicitHeight + Theme.spacingLarge * 2

    Flickable {
        anchors.fill: parent
        anchors.margins: Theme.spacingMedium
        contentWidth: width
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: parent.width
            spacing: Theme.spacingMedium

            // ── ÜST BAŞLIK: BUGÜNKÜ EKRAN SÜRESİ ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: I18n.t("EKRAN SÜRESİ", "SCREEN TIME")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Qt.formatDate(new Date(), "ddd, MMM d")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: ScreenTimeState.fmtDuration(ScreenTimeState.activeToday)
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 26
                    font.bold: true
                }

                Text {
                    text: I18n.t("bugün etkin", "active today")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            // ── HAFTALIK GRAFİK: BU HAFTA ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: I18n.t("BU HAFTA", "THIS WEEK")
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Row {
                    id: chartRow
                    Layout.fillWidth: true
                    height: 80
                    spacing: 8
                    readonly property real barWidth: (width - 6 * spacing) / 7
                    readonly property real maxH: 60

                    Repeater {
                        model: ScreenTimeState.weekly
                        delegate: Item {
                            required property var modelData
                            width: chartRow.barWidth
                            height: chartRow.height

                            Rectangle {
                                anchors.bottom: labelText.top
                                anchors.bottomMargin: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(8, parent.width * 0.72)
                                radius: 3
                                height: Math.max(3, chartRow.maxH * (modelData.total / ScreenTimeState.weeklyMax))
                                color: modelData.isToday ? Theme.textPrimary : Theme.surface2

                                Behavior on height {
                                    enabled: !Theme.reduceMotion
                                    NumberAnimation { duration: Theme.animNormal }
                                }
                            }

                            Text {
                                id: labelText
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                color: modelData.isToday ? Theme.textPrimary : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                                font.bold: modelData.isToday
                            }
                        }
                    }
                }
            }

            // ── EN ÇOK KULLANILAN UYGULAMALAR ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: I18n.t("EN ÇOK KULLANILAN", "MOST USED")
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Text {
                    visible: ScreenTimeState.topApps.length === 0
                    text: I18n.t("Henüz kullanım verisi oluşmadı. Çalıştıkça istatistikler toplanır.", "No usage data yet. Stats are collected as you work.")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Repeater {
                    model: ScreenTimeState.topApps
                    delegate: ColumnLayout {
                        id: appDelegate
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSmall

                            // Uygulama İkonu veya Rozeti
                            Item {
                                implicitWidth: 16
                                implicitHeight: 16

                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon || ""
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                    visible: modelData.icon && modelData.icon.length > 0
                                    fillMode: Image.PreserveAspectFit
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 3
                                    color: Theme.surface2
                                    visible: !modelData.icon || modelData.icon.length === 0

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.name || "A").charAt(0).toUpperCase()
                                        color: Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            // Uygulama Adı
                            Text {
                                text: modelData.name
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Kullanım Süresi
                            Text {
                                text: ScreenTimeState.fmtDuration(modelData.seconds)
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        // Yatay İlerleme Çubuğu
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 3
                            radius: 1.5
                            color: Theme.surface2

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * Math.max(0.04, modelData.seconds / ScreenTimeState.topSeconds)
                                radius: 1.5
                                color: Theme.textPrimary

                                Behavior on width {
                                    enabled: !Theme.reduceMotion
                                    NumberAnimation { duration: Theme.animNormal }
                                }
                            }
                        }

                        Item { implicitHeight: 3 }
                    }
                }
            }
        }
    }
}
