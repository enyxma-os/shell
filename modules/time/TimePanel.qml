import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-time-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: card.opacity > 0.0

    // ESC ile veya dışarı tıklandığında kapat (Scrim)
    MouseArea {
        anchors.fill: parent
        onClicked: TimeState.isPanelOpen = false
    }

    Rectangle {
        id: card
        width: 730
        implicitHeight: mainLayout.implicitHeight + 32

        anchors.top: parent.top
        anchors.topMargin: TimeState.isPanelOpen ? 44 : 24
        anchors.horizontalCenter: parent.horizontalCenter

        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: TimeState.isPanelOpen ? 1.0 : 0.0
        scale: TimeState.isPanelOpen ? 1.0 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }
        Behavior on anchors.topMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            // Kart içi tıklamaları scrim'e sızdırma
            preventStealing: true
        }

        // Ana 2 Sütunlu Harmonik Bento Düzeni
        RowLayout {
            id: mainLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 16
            }
            spacing: 16

            // ==========================================
            // SOL SÜTUN: İNTERAKTİF TAKVİM & GÜN ÖZETİ
            // ==========================================
            Rectangle {
                id: calendarBox
                Layout.preferredWidth: 330
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                property int viewYear: TimeState.year
                property int viewMonth: TimeState.now.getMonth()
                property int selectedDay: TimeState.dayNumber

                readonly property var monthNames: [
                    "OCAK", "ŞUBAT", "MART", "NİSAN", "MAYIS", "HAZİRAN",
                    "TEMMUZ", "AĞUSTOS", "EYLÜL", "EKİM", "KASIM", "ARALIK"
                ]

                function prevMonth() {
                    if (viewMonth === 0) {
                        viewMonth = 11;
                        viewYear--;
                    } else {
                        viewMonth--;
                    }
                }

                function nextMonth() {
                    if (viewMonth === 11) {
                        viewMonth = 0;
                        viewYear++;
                    } else {
                        viewMonth++;
                    }
                }

                function resetToToday() {
                    const today = new Date();
                    viewYear = today.getFullYear();
                    viewMonth = today.getMonth();
                    selectedDay = today.getDate();
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Takvim Navigasyon Başlığı
                    RowLayout {
                        Layout.fillWidth: true

                        // Önceki Ay Butonu
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: prevMa.containsMouse ? Theme.surfaceHover : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                color: Theme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            MouseArea {
                                id: prevMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarBox.prevMonth()
                            }
                        }

                        // Ay ve Yıl Başlığı
                        Text {
                            text: calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.viewYear
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeNormal
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Sonraki Ay Butonu
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: nextMa.containsMouse ? Theme.surfaceHover : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                color: Theme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            MouseArea {
                                id: nextMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarBox.nextMonth()
                            }
                        }

                        // "Bugün" Hızlı Dönüş Hapı
                        Rectangle {
                            width: 48
                            height: 22
                            radius: 11
                            color: todayMa.containsMouse ? Theme.accent : Theme.surfaceHover
                            border.color: Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: "Bugün"
                                color: todayMa.containsMouse ? Theme.bgGlass : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: todayMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarBox.resetToToday()
                            }
                        }
                    }

                    // Haftanın Günleri Başlıkları (Pt - Pz)
                    Row {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]

                            Item {
                                width: (330 - 24) / 7
                                height: 20

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: (index >= 5) ? Theme.accent : Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // 42 Hücreli Takvim Matrisi (6 Hafta x 7 Gün)
                    Grid {
                        id: calendarGrid
                        columns: 7
                        rows: 6
                        spacing: 2
                        Layout.alignment: Qt.AlignHCenter

                        readonly property int firstDayOfWeek: {
                            // 0: Pzt, 6: Paz
                            const d = new Date(calendarBox.viewYear, calendarBox.viewMonth, 1).getDay();
                            return (d + 6) % 7;
                        }
                        readonly property int daysInMonth: new Date(calendarBox.viewYear, calendarBox.viewMonth + 1, 0).getDate()
                        readonly property int daysInPrevMonth: new Date(calendarBox.viewYear, calendarBox.viewMonth, 0).getDate()

                        Repeater {
                            model: 42

                            Rectangle {
                                width: Math.floor((330 - 24 - 12) / 7)
                                height: 26
                                radius: 6

                                readonly property int cellDay: {
                                    const first = calendarGrid.firstDayOfWeek;
                                    if (index < first) {
                                        return calendarGrid.daysInPrevMonth - first + index + 1;
                                    } else if (index < first + calendarGrid.daysInMonth) {
                                        return index - first + 1;
                                    } else {
                                        return index - (first + calendarGrid.daysInMonth) + 1;
                                    }
                                }

                                readonly property bool isOtherMonth: (index < calendarGrid.firstDayOfWeek || index >= calendarGrid.firstDayOfWeek + calendarGrid.daysInMonth)
                                readonly property bool isToday: (!isOtherMonth &&
                                    calendarBox.viewYear === TimeState.year &&
                                    calendarBox.viewMonth === TimeState.now.getMonth() &&
                                    cellDay === TimeState.dayNumber)
                                readonly property bool isSelected: (!isOtherMonth && cellDay === calendarBox.selectedDay)

                                color: isToday ? Theme.accent : (isSelected ? Theme.surfaceHover : (cellMa.containsMouse ? Theme.surfaceHover : "transparent"))
                                border.color: isSelected && !isToday ? Theme.accent : "transparent"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: String(parent.cellDay)
                                    color: parent.isToday ? Theme.bgGlass : (parent.isOtherMonth ? Theme.textMuted : Theme.textPrimary)
                                    opacity: parent.isOtherMonth ? 0.35 : 1.0
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: parent.isToday || parent.isSelected
                                }

                                MouseArea {
                                    id: cellMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (parent.isOtherMonth) {
                                            if (index < calendarGrid.firstDayOfWeek) {
                                                calendarBox.prevMonth();
                                            } else {
                                                calendarBox.nextMonth();
                                            }
                                        } else {
                                            calendarBox.selectedDay = parent.cellDay;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Alt Kısım: Seçilen Gün Özeti & Yıl Döngüsü
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: Theme.radiusSmall
                        color: Theme.bgGlass
                        border.color: Theme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "🗓️ " + calendarBox.selectedDay + " " + calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.viewYear
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Hafta " + TimeState.weekNumber
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "🌅 Doğuş: 07:18  •  🌇 Batış: 18:32"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "Yılın " + TimeState.dayOfYear + ". Günü"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // SAĞ SÜTUN: ZAMAN, METEOROLOJİ & TAHMİN
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                // 1. KART: CANLI DİJİTAL SAAT & GÜN
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 16

                        // Büyük Dijital Saat ve Saniye
                        Row {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: TimeState.hours + ":" + TimeState.minutes
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 38
                                font.bold: true
                            }

                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: ":" + TimeState.seconds
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: " " + TimeState.ampm
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                                font.bold: true
                                visible: !TimeState.use24h
                            }
                        }

                        // Sağ Taraf: Gün, Tarih ve Konum Bilgisi
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: TimeState.dayName
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                font.bold: true
                            }

                            Text {
                                text: TimeState.formattedDate
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            RowLayout {
                                spacing: 4

                                Text {
                                    text: "🌐 UTC+3 / İstanbul"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: Theme.textMuted
                                }

                                Text {
                                    text: (SystemState.uptime && SystemState.uptime.length > 0) ? "⏱️ " + SystemState.uptime : "Aktif"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                // 2. KART: CANLI METEOROLOJİ & ÇEVRE PARAMETRELERİ
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // Sol Taraf: Büyük İkon + Sıcaklık + Durum
                        RowLayout {
                            Layout.preferredWidth: 150
                            spacing: 10

                            Text {
                                text: WeatherState.conditionGlyph
                                font.pixelSize: 34
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: WeatherState.displayTemp
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 24
                                    font.bold: true
                                }

                                Text {
                                    text: WeatherState.conditionText
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "📍 " + WeatherState.city
                                    color: Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }

                        // Ayraç Dikey Çizgi
                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            color: Theme.borderSubtle
                        }

                        // Sağ Taraf: 2x2 Dengeli Metrik Izgarası
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 10

                            // Rüzgar
                            RowLayout {
                                spacing: 6
                                Text { text: "💨"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.windSpeed + " km/s " + WeatherState.windDir; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Rüzgar Hızı"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            // Nem
                            RowLayout {
                                spacing: 6
                                Text { text: "💧"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.humidity + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Havadaki Nem"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            // Yağış İhtimali
                            RowLayout {
                                spacing: 6
                                Text { text: "☔"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.rainProb + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Yağış İhtimali"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            // Hissedilen Sıcaklık
                            RowLayout {
                                spacing: 6
                                Text { text: "🌡️"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.displayFeels; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Hissedilen"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }
                        }
                    }
                }

                // 3. KART: SAATLİK TAHMİN AKIŞI (TREND STRIP)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        // Başlık ve Son Güncelleme
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "SAATLİK HAVA DURUMU TAHMİNİ"
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: WeatherState.lastUpdated.length > 0 ? "Güncellendi: " + WeatherState.lastUpdated : ""
                                color: Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                            }
                        }

                        // 6 Saatlik Tahmin Kartları Dizilimi
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: WeatherState.hourlyForecast.slice(0, 6)

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 64
                                    radius: 6
                                    color: hourlyMa.containsMouse ? Theme.surfaceHover : Theme.bgGlass
                                    border.color: Theme.borderSubtle
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Text {
                                            text: modelData.time
                                            color: Theme.textMuted
                                            font.family: Theme.fontMono
                                            font.pixelSize: 9
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: modelData.glyph
                                            font.pixelSize: 14
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: WeatherState.formatTemp(modelData.temp)
                                            color: Theme.textPrimary
                                            font.family: Theme.fontMono
                                            font.pixelSize: 11
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    MouseArea {
                                        id: hourlyMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
