import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

Item {
    id: root

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

        scale: TimeState.isPanelOpen ? 1.0 : 0.96

        Behavior on anchors.topMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        RowLayout {
            id: mainLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 16
            }
            spacing: 16

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

                readonly property var monthNames: I18n.isEn ? [
                    "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
                    "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
                ] : [
                    "OCAK", "ŞUBAT", "MART", "NİSAN", "MAYIS", "HAZİRAN",
                    "TEMMUZ", "AĞUSTOS", "EYLÜL", "EKİM", "KASIM", "ARALIK"
                ]

                function prevMonth() {
                    if (viewMonth === 0) {
                        viewMonth = 11
                        viewYear--
                    } else {
                        viewMonth--
                    }
                }

                function nextMonth() {
                    if (viewMonth === 11) {
                        viewMonth = 0
                        viewYear++
                    } else {
                        viewMonth++
                    }
                }

                function resetToToday() {
                    const today = new Date()
                    viewYear = today.getFullYear()
                    viewMonth = today.getMonth()
                    selectedDay = today.getDate()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

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

                        Text {
                            text: calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.viewYear
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeNormal
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

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

                        Rectangle {
                            width: 48
                            height: 22
                            radius: 11
                            color: todayMa.containsMouse ? Theme.accent : Theme.surfaceHover
                            border.color: Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("Bugün", "Today")
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

                    Row {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: I18n.isEn ? ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"] : ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]

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

                    Grid {
                        id: calendarGrid
                        columns: 7
                        rows: 6
                        spacing: 2
                        Layout.alignment: Qt.AlignHCenter

                        readonly property int firstDayOfWeek: {
                            const d = new Date(calendarBox.viewYear, calendarBox.viewMonth, 1).getDay()
                            return (d + 6) % 7
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
                                    const first = calendarGrid.firstDayOfWeek
                                    if (index < first) {
                                        return calendarGrid.daysInPrevMonth - first + index + 1
                                    } else if (index < first + calendarGrid.daysInMonth) {
                                        return index - first + 1
                                    } else {
                                        return index - (first + calendarGrid.daysInMonth) + 1
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
                                                calendarBox.prevMonth()
                                            } else {
                                                calendarBox.nextMonth()
                                            }
                                        } else {
                                            calendarBox.selectedDay = parent.cellDay
                                        }
                                    }
                                }
                            }
                        }
                    }

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
                                    text: I18n.isEn
                                        ? ("🗓️ " + calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.selectedDay + ", " + calendarBox.viewYear)
                                        : ("🗓️ " + calendarBox.selectedDay + " " + calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.viewYear)
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: I18n.t("Hafta ", "Week ") + TimeState.weekNumber
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: I18n.t("🌅 Doğuş: 07:18  •  🌇 Batış: 18:32", "🌅 Sunrise: 07:18  •  🌇 Sunset: 18:32")
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: I18n.isEn ? ("Day " + TimeState.dayOfYear + " of Year") : ("Yılın " + TimeState.dayOfYear + ". Günü")
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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

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
                                    text: I18n.t("🌐 UTC+3 / İstanbul", "🌐 Local Time")
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
                                    text: (SystemState.uptime && SystemState.uptime.length > 0) ? "⏱️ " + SystemState.uptime : I18n.t("Aktif", "Active")
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

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            color: Theme.borderSubtle
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 10

                            RowLayout {
                                spacing: 6
                                Text { text: "💨"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.windSpeed + I18n.t(" km/s ", " km/h ") + WeatherState.windDir; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Rüzgar Hızı", "Wind Speed"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            RowLayout {
                                spacing: 6
                                Text { text: "💧"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.humidity + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Havadaki Nem", "Humidity"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            RowLayout {
                                spacing: 6
                                Text { text: "☔"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.rainProb + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Yağış İhtimali", "Precipitation"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }

                            RowLayout {
                                spacing: 6
                                Text { text: "🌡️"; font.pixelSize: 12 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: WeatherState.displayFeels; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Hissedilen", "Feels Like"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                }
                            }
                        }
                    }
                }

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

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: I18n.t("SAATLİK HAVA DURUMU TAHMİNİ", "HOURLY WEATHER FORECAST")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: WeatherState.lastUpdated.length > 0 ? I18n.t("Güncellendi: ", "Updated: ") + WeatherState.lastUpdated : ""
                                color: Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                            }
                        }

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

