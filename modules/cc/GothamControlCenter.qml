import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

/**
 * GothamControlCenter — Gotham 2.0 Brutalist Mimari Kenar Cekmecesi.
 *
 * Yuzeysel baloncuk yerine GothamBar altina ve ekranin sag kenarina sifir
 * oturan endustriyel sistem konsolu.
 */
Item {
    id: root

    property bool nightLightActive: false
    signal toggleNightLightRequested()

    readonly property bool dndActive: NotificationState.dnd

    Rectangle {
        id: drawerCard
        anchors {
            top: parent.top
            topMargin: Theme.barHeight
            right: parent.right
        }
        width: 360
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        radius: 0
        color: Theme.bgPanel

        // Sol ve alt kenar icin 1px soguk grafit sinir hatlari
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 1
            color: Theme.borderSubtle
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: Theme.borderSubtle
        }

        // Ust 1px kontrollu kehribar vurgu hatti
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 1
            color: Theme.accent
        }

        // Cekmece icindeki bos tiklamalarin dis kapatmaya gecmesini onle
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            // 1. Taktiksel Baslik ve Telemetri Seridi
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "KONTROL MERKEZİ"
                        color: Theme.textPrimary
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fontSizeNormal
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: (SystemState.uptime.length > 0 ? ("ÇALIŞMA: " + SystemState.uptime.toUpperCase() + " · ") : "")
                            + "GÜÇ: " + (SystemState.isBatteryPresent ? ("%" + SystemState.batteryPercent) : "AC")
                            + (SystemState.isCharging ? " 󰂄" : "")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeXS
                        font.letterSpacing: 1
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // 2. Endustriyel 2x2 Anahtar Modulleri
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.spacingSmall
                columnSpacing: Theme.spacingSmall

                // Ag Modulu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Theme.radiusButton
                    color: netMa.containsMouse ? Theme.surfaceHover : (SystemState.isConnected ? Theme.surfaceActive : Theme.surface1)
                    border.color: SystemState.isConnected ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        visible: SystemState.isConnected
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 2
                        color: Theme.accent
                    }

                    MouseArea {
                        id: netMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            NetworkState.open()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall + 2
                        anchors.rightMargin: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: SystemState.isConnected ? "󰤨" : "󰤭"
                            color: SystemState.isConnected ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "AĞ"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: SystemState.isConnected ? (SystemState.wifiSSID || "BAĞLI") : "ÇEVRİMDIŞI"
                                color: SystemState.isConnected ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Bluetooth Modulu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Theme.radiusButton
                    color: btMa.containsMouse ? Theme.surfaceHover : (BluetoothState.enabled ? Theme.surfaceActive : Theme.surface1)
                    border.color: BluetoothState.enabled ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        visible: BluetoothState.enabled
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 2
                        color: Theme.accent
                    }

                    MouseArea {
                        id: btMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothState.togglePower()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall + 2
                        anchors.rightMargin: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰂯"
                            color: BluetoothState.enabled ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "BLUETOOTH"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: BluetoothState.busy ? "…" : BluetoothState.statusText
                                color: BluetoothState.enabled ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Gece Isigi Modulu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Theme.radiusButton
                    color: nightMa.containsMouse ? Theme.surfaceHover : (root.nightLightActive ? Theme.surfaceActive : Theme.surface1)
                    border.color: root.nightLightActive ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        visible: root.nightLightActive
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 2
                        color: Theme.accent
                    }

                    MouseArea {
                        id: nightMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleNightLightRequested()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall + 2
                        anchors.rightMargin: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰔎"
                            color: root.nightLightActive ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "GECE IŞIĞI"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: root.nightLightActive ? "4500K AKTİF" : "KAPALI"
                                color: root.nightLightActive ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                            }
                        }
                    }
                }

                // Bildirim / Sessiz Modu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Theme.radiusButton
                    color: dndMa.containsMouse ? Theme.surfaceHover : (root.dndActive ? Theme.surfaceActive : Theme.surface1)
                    border.color: root.dndActive ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        visible: root.dndActive
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 2
                        color: Theme.accent
                    }

                    MouseArea {
                        id: dndMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationState.toggleDnd()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall + 2
                        anchors.rightMargin: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: NotificationState.dnd ? "󰂛" : "󰂚"
                            color: root.dndActive ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "BİLDİRİM"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: NotificationState.dnd ? "SESSİZ" : "AÇIK"
                                color: root.dndActive ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                            }
                        }
                    }
                }
            }

            // 2c. Keskin Segmentli Tema Profili Anahtari
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 34
                radius: Theme.radiusButton
                color: Theme.bgDark
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 2

                    Repeater {
                        model: [
                            { id: "dynamic", label: "DİNAMİK" },
                            { id: "gotham",  label: "GOTHAM" }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool isSelected: WallpaperState.currentTheme === modelData.id

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Theme.radiusSmall
                            color: isSelected
                                ? Theme.accent
                                : (segMa.containsMouse ? Theme.surfaceHover : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: isSelected ? Theme.accentOn : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            MouseArea {
                                id: segMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (WallpaperState.currentTheme !== modelData.id) {
                                        WallpaperState.setThemePreset(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. Endustriyel Ses Kanali
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: AudioState.muted ? "󰝟 SES KANALI" : "󰕾 SES KANALI"
                        color: AudioState.muted ? Theme.danger : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.letterSpacing: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AudioState.toggleMute()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: volValTxt.implicitWidth + 12
                        implicitHeight: 18
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: AudioState.muted ? Theme.danger : Theme.borderSubtle
                        border.width: 1

                        Text {
                            id: volValTxt
                            anchors.centerIn: parent
                            text: AudioState.muted ? "SESSİZ" : Math.round(AudioState.volume * 100) + "%"
                            color: AudioState.muted ? Theme.danger : Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    implicitHeight: 20
                    from: 0.0
                    to: 1.0
                    value: AudioState.muted ? 0.0 : AudioState.volume

                    Behavior on value {
                        enabled: !volumeSlider.pressed && !Theme.reduceMotion
                        NumberAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    onMoved: AudioState.setVolume(value)

                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: volumeSlider.availableWidth
                        height: implicitHeight
                        radius: Theme.radiusSmall
                        color: Theme.surfaceActive

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: AudioState.muted ? Theme.danger : Theme.accent
                            radius: Theme.radiusSmall
                        }
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 10
                        implicitHeight: 14
                        radius: Theme.radiusSmall
                        color: Theme.accent
                        border.color: Theme.bgDark
                        border.width: 1
                    }
                }
            }

            // 4. Endustriyel Parlaklik Kontrolu
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "󰃠 PARLAKLIK"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: brightValTxt.implicitWidth + 12
                        implicitHeight: 18
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        Text {
                            id: brightValTxt
                            anchors.centerIn: parent
                            text: Math.round(BrightnessState.level * 100) + "%"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }
                }

                Slider {
                    id: brightSlider
                    Layout.fillWidth: true
                    implicitHeight: 20
                    from: 0.05
                    to: 1.0
                    value: BrightnessState.level

                    Behavior on value {
                        enabled: !brightSlider.pressed && !Theme.reduceMotion
                        NumberAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    onMoved: BrightnessState.setBrightness(value)

                    background: Rectangle {
                        x: brightSlider.leftPadding
                        y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: brightSlider.availableWidth
                        height: implicitHeight
                        radius: Theme.radiusSmall
                        color: Theme.surfaceActive

                        Rectangle {
                            width: brightSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.accent
                            radius: Theme.radiusSmall
                        }
                    }

                    handle: Rectangle {
                        x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                        y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                        implicitWidth: 10
                        implicitHeight: 14
                        radius: Theme.radiusSmall
                        color: Theme.accent
                        border.color: Theme.bgDark
                        border.width: 1
                    }
                }
            }

            // 5. Medya Seridi
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall
                visible: MediaState.hasMedia

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Text {
                        text: "󰝚"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 14
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        Text {
                            text: MediaState.trackTitle || "Bilinmeyen Parça"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: MediaState.artist || "Bilinmeyen Sanatçı"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: 24
                        radius: Theme.radiusButton
                        color: prevMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: prevMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: prevMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaState.previous()
                        }
                    }

                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: 24
                        radius: Theme.radiusButton
                        color: playMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                        border.color: playMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: MediaState.isPlaying ? "󰏤" : "󰐊"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: playMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaState.togglePlay()
                        }
                    }

                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: 24
                        radius: Theme.radiusButton
                        color: nextMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: nextMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: nextMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaState.next()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // 6. Taktiksel Guc Komut Hucreleri
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                // Kilit
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Theme.radiusButton
                    color: lockMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: lockMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰌾"
                            color: lockMa.containsMouse ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "KİLİT"
                            color: lockMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: lockMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["hyprlock"])
                        }
                    }
                }

                // Uyku
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Theme.radiusButton
                    color: suspMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: suspMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰒲"
                            color: suspMa.containsMouse ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "UYKU"
                            color: suspMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: suspMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "suspend"])
                        }
                    }
                }

                // Yeniden Baslat
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Theme.radiusButton
                    color: rebootMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: rebootMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰑓"
                            color: rebootMa.containsMouse ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "YENİDEN"
                            color: rebootMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: rebootMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "reboot"])
                        }
                    }
                }

                // Kapat — Yalnizca uzerine gelindiginde danger vurgusu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Theme.radiusButton
                    color: powerMa.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.16) : Theme.surface1
                    border.color: powerMa.containsMouse ? Theme.danger : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⏻"
                            color: powerMa.containsMouse ? Theme.danger : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "KAPAT"
                            color: powerMa.containsMouse ? Theme.danger : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: powerMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }
                }
            }
        }
    }
}
