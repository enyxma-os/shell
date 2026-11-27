import QtQuick
import QtQuick.Layouts
import "../../services"

Item {
    id: root

    Rectangle {
        id: deck
        width: 760
        implicitHeight: deckCol.implicitHeight + 24

        anchors.top: parent.top
        anchors.topMargin: TimeState.isPanelOpen ? Theme.barHeight : 18
        anchors.horizontalCenter: parent.horizontalCenter

        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1

        Behavior on anchors.topMargin {
            enabled: !Theme.reduceMotion
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
        }

        // Üst 2px keskin Gotham vurgu hattı
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 2
            color: Theme.accent
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        ColumnLayout {
            id: deckCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
                topMargin: 14
            }
            spacing: 10

            // Taktiksel Üst Başlık Şeridi
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: I18n.t("KRONOMETRE // TAKVİM & METEOROLOJİ", "CHRONO // CALENDAR & WEATHER")
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.8
                    Layout.fillWidth: true
                }

                Text {
                    text: "[ " + I18n.t("HAFTA ", "WEEK ") + TimeState.weekNumber + I18n.t(" · GÜN ", " · DAY ") + TimeState.dayOfYear + " ]"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // SOL SÜTUN: TAKVİM MATRİSİ
                Rectangle {
                    id: calendarBox
                    Layout.preferredWidth: 332
                    Layout.fillHeight: true
                    radius: 0
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1

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
                        anchors.margins: 10
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 0
                                color: prevMa.containsMouse ? Theme.surfaceHover : Theme.bgDark
                                border.color: prevMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "‹"
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
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
                                font.family: Theme.fontDisplay
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 1
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 0
                                color: nextMa.containsMouse ? Theme.surfaceHover : Theme.bgDark
                                border.color: nextMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "›"
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
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
                                width: 54
                                height: 24
                                radius: 0
                                color: todayMa.containsMouse ? Theme.accent : Theme.bgDark
                                border.color: Theme.accent
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: I18n.t("BUGÜN", "TODAY")
                                    color: todayMa.containsMouse ? Theme.accentOn : Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
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
                                model: I18n.isEn ? ["MO", "TU", "WE", "TH", "FR", "SA", "SU"] : ["PT", "SA", "ÇA", "PE", "CU", "CT", "PZ"]

                                Item {
                                    width: (332 - 20) / 7
                                    height: 18

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: (index >= 5) ? Theme.accent : Theme.textMuted
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
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
                                    width: Math.floor((332 - 20 - 12) / 7)
                                    height: 26
                                    radius: 0

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

                                    color: isToday ? Theme.accent : (isSelected ? Theme.surfaceActive : (cellMa.containsMouse ? Theme.surfaceHover : Theme.bgDark))
                                    border.color: isSelected && !isToday ? Theme.accent : Theme.borderSubtle
                                    border.width: isSelected && !isToday ? 1 : 0

                                    Rectangle {
                                        visible: parent.isSelected && !parent.isToday
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }
                                        width: 2
                                        color: Theme.accent
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: String(parent.cellDay)
                                        color: parent.isToday ? Theme.accentOn : (parent.isOtherMonth ? Theme.textMuted : Theme.textPrimary)
                                        opacity: parent.isOtherMonth ? 0.35 : 1.0
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
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
                            Layout.preferredHeight: 46
                            radius: 0
                            color: Theme.bgDark
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
                                            ? ("󰃭  " + calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.selectedDay + ", " + calendarBox.viewYear)
                                            : ("󰃭  " + calendarBox.selectedDay + " " + calendarBox.monthNames[calendarBox.viewMonth] + " " + calendarBox.viewYear)
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: true
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "UTC+3"
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: I18n.t("HAFTA ", "WEEK ") + TimeState.weekNumber
                                        color: Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: I18n.isEn ? ("DAY " + TimeState.dayOfYear + " OF YEAR") : ("YILIN " + TimeState.dayOfYear + ". GÜNÜ")
                                        color: Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }
                    }
                }

                // SAĞ SÜTUN: KRONOMETRE + METEOROLOJİ
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        radius: 0
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: 3
                            color: Theme.accent
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.leftMargin: 16
                            spacing: 14

                            Row {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: TimeState.hours + ":" + TimeState.minutes
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 36
                                    font.bold: true
                                }

                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: ":" + TimeState.seconds
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: " " + TimeState.ampm
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 12
                                    font.bold: true
                                    visible: !TimeState.use24h
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: TimeState.dayName.toUpperCase()
                                    color: Theme.accent
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    text: TimeState.formattedDate
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: (SystemState.uptime && SystemState.uptime.length > 0) ? (I18n.t("ÇALIŞMA: ", "UPTIME: ") + SystemState.uptime) : I18n.t("SİSTEM AKTİF", "SYSTEM ACTIVE")
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108
                        radius: 0
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            RowLayout {
                                Layout.preferredWidth: 162
                                spacing: 10

                                Text {
                                    text: WeatherState.conditionGlyph
                                    font.pixelSize: 30
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    Text {
                                        text: WeatherState.displayTemp
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 22
                                        font.bold: true
                                    }

                                    Text {
                                        text: WeatherState.conditionText
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "󰍎 " + WeatherState.city.toUpperCase()
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 1
                                Layout.fillHeight: true
                                color: Theme.borderSubtle
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 8
                                columnSpacing: 10

                                RowLayout {
                                    spacing: 6
                                    Text { text: "󰖝"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    ColumnLayout {
                                        spacing: 0
                                        Text { text: WeatherState.windSpeed + I18n.t(" km/s ", " km/h ") + WeatherState.windDir; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                        Text { text: I18n.t("RÜZGAR", "WIND"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 8 }
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Text { text: "󰖌"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    ColumnLayout {
                                        spacing: 0
                                        Text { text: WeatherState.humidity + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                        Text { text: I18n.t("NEM", "HUMIDITY"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 8 }
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Text { text: "󰖗"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    ColumnLayout {
                                        spacing: 0
                                        Text { text: WeatherState.rainProb + "%"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                        Text { text: I18n.t("YAĞIŞ", "PRECIP"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 8 }
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Text { text: "󰔏"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    ColumnLayout {
                                        spacing: 0
                                        Text { text: WeatherState.displayFeels; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                        Text { text: I18n.t("HİSSEDİLEN", "FEELS LIKE"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 8 }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 96
                        radius: 0
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: I18n.t("SAATLİK TAHMİN ŞERİDİ", "HOURLY FORECAST")
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: WeatherState.lastUpdated.length > 0 ? WeatherState.lastUpdated : ""
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 9
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: WeatherState.hourlyForecast.slice(0, 6)

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 58
                                        radius: 0
                                        color: hourlyMa.containsMouse ? Theme.surfaceHover : Theme.bgDark
                                        border.color: hourlyMa.containsMouse ? Theme.accent : Theme.borderSubtle
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
                                                font.pixelSize: 13
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text: WeatherState.formatTemp(modelData.temp)
                                                color: Theme.textPrimary
                                                font.family: Theme.fontMono
                                                font.pixelSize: 10
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
}

