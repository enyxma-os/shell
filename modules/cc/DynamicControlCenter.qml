import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

/**
 * DynamicControlCenter — Dinamik Tema Yuzen Cam Kontrol Merkezi.
 */
Item {
    id: root

    property bool nightLightActive: false
    signal toggleNightLightRequested()

    readonly property bool dndActive: NotificationState.dnd

    Rectangle {
        id: mainCard
        anchors {
            top: parent.top
            right: parent.right
            topMargin: Theme.barHeight + Theme.barMarginTop + 6
            rightMargin: 12
        }
        width: 340
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        // Kart uzerindeki bos tiklamalarin dis kapatmaya gecmesini onle
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

            // 1. Baslik, calisma suresi ve guc ozeti
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                Text {
                    text: "SİSTEM"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 2
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: (SystemState.uptime.length > 0 ? ("󰅐 " + SystemState.uptime + " · ") : "")
                        + (SystemState.isBatteryPresent ? ("%" + SystemState.batteryPercent) : "AC")
                        + (SystemState.isCharging ? " ⚡" : "")
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 0.5
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // 2. Hizli Eylem Karolari — 2x2 Izgara
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.spacingSmall
                columnSpacing: Theme.spacingSmall

                // Ag
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusWidget
                    color: SystemState.isConnected
                        ? (netMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive)
                        : (netMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

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
                        anchors.leftMargin: Theme.spacingSmall
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
                                text: SystemState.isConnected ? (SystemState.wifiSSID || "Bağlı") : "Bağlı Değil"
                                color: SystemState.isConnected ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusWidget
                    color: BluetoothState.enabled
                        ? (btMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive)
                        : (btMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        id: btMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothState.togglePower()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall
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

                // Gece Isigi
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusWidget
                    color: root.nightLightActive
                        ? (nightMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive)
                        : (nightMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        id: nightMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleNightLightRequested()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall
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
                                text: root.nightLightActive ? "4500K" : "Kapalı"
                                color: root.nightLightActive ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                            }
                        }
                    }
                }

                // Sessiz Mod
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusWidget
                    color: root.dndActive
                        ? (dndMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive)
                        : (dndMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        id: dndMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationState.toggleDnd()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingSmall
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
                                text: NotificationState.dnd ? "Sessiz" : "Açık"
                                color: root.dndActive ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // 2b. Thornhill Bilissel Cekirdek
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: Theme.radiusWidget
                color: thMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                border.color: ThornhillState.running ? Theme.accent : Theme.borderSubtle
                border.width: Theme.borderWidth

                MouseArea {
                    id: thMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ThornhillState.toggle()
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingSmall
                    anchors.rightMargin: Theme.spacingSmall
                    spacing: Theme.spacingSmall

                    Text {
                        text: "👁"
                        color: ThornhillState.color
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                        opacity: ThornhillState.running ? 1.0 : 0.55
                    }

                    Text {
                        text: "THORNHILL"
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: ThornhillState.busy ? "…" : ThornhillState.label
                        color: ThornhillState.color
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeXS
                    }
                }
            }

            // 2c. Tema Profili Secici
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Repeater {
                    model: [
                        { id: "dynamic", label: "✦ DİNAMİK" },
                        { id: "gotham",  label: "🦇 GOTHAM" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool isSelected: WallpaperState.currentTheme === modelData.id

                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: Theme.radiusButton
                        color: isSelected
                            ? Theme.accent
                            : (ccPresetMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: isSelected ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: isSelected ? Theme.accentOn : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: ccPresetMa
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

            // 3. Ses Kontrolu
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: AudioState.muted ? "󰝟 SES" : "󰕾 SES"
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

                    Text {
                        text: AudioState.muted ? "SESSİZ" : Math.round(AudioState.volume * 100) + "%"
                        color: AudioState.muted ? Theme.danger : Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
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
                        implicitHeight: 6
                        width: volumeSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: Theme.surfaceActive

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: AudioState.muted ? Theme.danger : Theme.accent
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
                        color: Theme.textPrimary
                    }
                }
            }

            // 4. Parlaklik Kontrolu
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

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

                    Text {
                        text: Math.round(BrightnessState.level * 100) + "%"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
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
                        implicitHeight: 6
                        width: brightSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: Theme.surfaceActive

                        Rectangle {
                            width: brightSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.accent
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                        y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
                        color: Theme.textPrimary
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
                        border.color: Theme.borderSubtle
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
                        border.color: Theme.borderSubtle
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
                        border.color: Theme.borderSubtle
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

            // 6. Guc ve Oturum Seridi — Simge + Anlasilir Etiket
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                // Kilitle
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Theme.radiusButton
                    color: lockMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
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
                            text: "Kilitle"
                            color: lockMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
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
                    implicitHeight: 44
                    radius: Theme.radiusButton
                    color: suspMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
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
                            text: "Uyku"
                            color: suspMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
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

                // Yeniden
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Theme.radiusButton
                    color: rebootMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
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
                            text: "Yeniden"
                            color: rebootMa.containsMouse ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
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

                // Kapat
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Theme.radiusButton
                    color: powerMa.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.18) : Theme.surface1
                    border.color: powerMa.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.35) : Theme.borderSubtle
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
                            text: "Kapat"
                            color: powerMa.containsMouse ? Theme.danger : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
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
