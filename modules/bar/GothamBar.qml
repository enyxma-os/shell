import QtQuick
import QtQuick.Layouts
import "../../services"

/**
 * GothamBar — Enyxma Shell Gotham 2.0 Kapsulsuz Kokpit Ust Paneli.
 *
 * Ic kapsuller olmadan yalnizca 1px soguk grafit dikey izgaralarla bolunmus,
 * sabit genislikli teknik telemetri ve komuta hucrelerinden olusur.
 */
Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.bgDark
    radius: 0

    function pad2(n) {
        var v = Math.max(0, Math.round(n))
        return v < 10 ? ("0" + v) : String(v)
    }

    // Merkez: Iki Katmanli Taktiksel Kronometre
    GothamClockWidget {
        id: clockWidget
        visible: SettingsState.showClock
        anchors.centerIn: parent
        z: 2
    }

    // Sol Kume: Komuta, Sektorler ve Gorsel Araclar
    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            right: clockWidget.left
            rightMargin: Theme.spacingSmall
            top: parent.top
            bottom: bottomLine.top
        }
        spacing: 0

        // 1. ENYXMA Komuta Hucresi
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: enyxmaRow.implicitWidth + 20
            radius: 0
            color: LauncherState.isOpen ? Theme.surfaceActive : (enyxmaMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: LauncherState.isOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: enyxmaRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰈈"
                    color: LauncherState.isOpen ? Theme.accent : Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                }

                Text {
                    text: "ENYXMA"
                    color: LauncherState.isOpen ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    font.letterSpacing: 1
                }
            }

            MouseArea {
                id: enyxmaMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) LauncherState.openMode("actions")
                    else LauncherState.toggle()
                }
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 2. Calisma Alanlari: Gotham Mimari Hucre Izgarasi
        Item {
            visible: SettingsState.showWorkspaces
            Layout.fillHeight: true
            Layout.leftMargin: Theme.spacingSmall
            Layout.rightMargin: Theme.spacingSmall
            implicitWidth: workspaces.implicitWidth

            GothamWorkspaces {
                id: workspaces
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 3. Duvar Kagidi ve Tema Hucresi
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 34
            radius: 0
            color: WallpaperState.pickerVisible ? Theme.surfaceActive : (wpMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: WallpaperState.pickerVisible
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            Text {
                anchors.centerIn: parent
                text: "󰏘"
                color: WallpaperState.pickerVisible ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
            }

            MouseArea {
                id: wpMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) WallpaperState.cycleTheme()
                    else WallpaperState.togglePicker()
                }
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 4. Medya ve Ekran Alintisi Galerisi Hucresi
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 34
            radius: 0
            color: MediaBrowserState.isOpen ? Theme.surfaceActive : (mbMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: MediaBrowserState.isOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            Text {
                anchors.centerIn: parent
                text: "󰋩"
                color: MediaBrowserState.isOpen ? Theme.accent : Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
            }

            MouseArea {
                id: mbMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) MediaBrowserState.toggle("videos")
                    else MediaBrowserState.toggle("screenshots")
                }
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // Calan Medya Bileseni
        MediaWidget {
            id: mediaWidget
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Theme.spacingSmall
        }

        Item {
            Layout.fillWidth: true
        }
    }

    // Sag Kume: Kapsulsuz Kokpit Telemetri ve Sistem Bloklari
    RowLayout {
        id: rightLayout
        anchors {
            left: clockWidget.right
            leftMargin: Theme.spacingSmall
            right: parent.right
            top: parent.top
            bottom: bottomLine.top
        }
        spacing: 0

        Item {
            Layout.fillWidth: true
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showSystemStats
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 1. CPU + RAM + DISK Tek Birlesik Sistem Telemetri Hucresi
        Rectangle {
            visible: SettingsState.showSystemStats
            readonly property bool sysActive: PerformanceState.isOpen
            Layout.fillHeight: true
            implicitWidth: perfRow.implicitWidth + 16
            radius: 0
            color: sysActive ? Theme.surfaceActive : (perfMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: parent.sysActive
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: perfRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "CPU"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }

                Text {
                    text: root.pad2(PerformanceState.cpuPercent) + "%"
                    color: PerformanceState.cpuPercent > 80 ? Theme.danger : (PerformanceState.isOpen ? Theme.accent : Theme.textPrimary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Text {
                    text: "RAM"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }

                Text {
                    text: perfMa.containsMouse
                        ? (PerformanceState.memUsedGiB.toFixed(1) + "G")
                        : (root.pad2(PerformanceState.memPercent) + "%")
                    color: PerformanceState.memPercent > 85 ? Theme.danger : (PerformanceState.isOpen ? Theme.accent : Theme.textPrimary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Text {
                    text: I18n.t("DİSK", "DISK")
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }

                Text {
                    text: root.pad2(StorageState.rootPercent) + "%"
                    color: StorageState.rootPercent > 85 ? Theme.danger : (PerformanceState.isOpen ? Theme.accent : Theme.textPrimary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            MouseArea {
                id: perfMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PerformanceState.toggle()
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showNetwork
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 3. Ag Hucresi
        Rectangle {
            visible: SettingsState.showNetwork
            Layout.fillHeight: true
            implicitWidth: netRow.implicitWidth + 16
            radius: 0
            color: NetworkState.isOpen ? Theme.surfaceActive : (netMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: NetworkState.isOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: netRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: {
                        if (!NetworkState.isConnected) return "󰤭"
                        if (NetworkState.connectionType === "ethernet") return "󰈀"
                        if (NetworkState.signalStrength > 75) return "󰤨"
                        if (NetworkState.signalStrength > 50) return "󰤥"
                        if (NetworkState.signalStrength > 25) return "󰤢"
                        return "󰤟"
                    }
                    color: NetworkState.isOpen ? Theme.accent : (NetworkState.isConnected ? Theme.textPrimary : Theme.textMuted)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }

                Column {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 8
                        height: 3
                        radius: 0
                        color: NetworkState.rxLevel > 0.08 ? Theme.accent : Theme.surfaceActive
                    }

                    Rectangle {
                        width: 8
                        height: 3
                        radius: 0
                        color: NetworkState.txLevel > 0.08 ? Theme.accent : Theme.surfaceActive
                    }
                }
            }

            MouseArea {
                id: netMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NetworkState.toggle()
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showVolume
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 4. Ses Hucresi
        Rectangle {
            visible: SettingsState.showVolume
            Layout.fillHeight: true
            implicitWidth: volRow.implicitWidth + 16
            radius: 0
            color: (AudioState.isOpen || AudioState.muted) ? Theme.surfaceActive : (volMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: AudioState.isOpen || AudioState.muted
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: AudioState.muted ? Theme.danger : Theme.accent
            }

            RowLayout {
                id: volRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "VOL"
                    color: AudioState.muted ? Theme.danger : (AudioState.isOpen ? Theme.accent : Theme.textSecondary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }

                Text {
                    text: AudioState.muted ? "MUTE" : (root.pad2(Math.round(AudioState.volume * 100)) + "%")
                    color: AudioState.muted ? Theme.danger : (AudioState.isOpen ? Theme.accent : Theme.textPrimary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            MouseArea {
                id: volMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) AudioState.toggleMute()
                    else if (SettingsState.enableAudioMixer) AudioState.toggle()
                    else AudioState.toggleMute()
                }
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showPower
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 5. SYS // PWR Kontrol Merkezi Hucresi
        Rectangle {
            visible: SettingsState.showPower
            Layout.fillHeight: true
            implicitWidth: sysRow.implicitWidth + 16
            radius: 0
            color: SystemState.isControlCenterOpen ? Theme.surfaceActive : (sysMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: SystemState.isControlCenterOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: sysRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "SYS ·"
                    color: SystemState.isControlCenterOpen ? Theme.accent : Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                }

                Text {
                    text: (SystemState.isBatteryPresent ? ("%" + SystemState.batteryPercent) : "AC")
                        + (SystemState.isCharging ? " 󰂄" : "")
                    color: SystemState.isControlCenterOpen ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            MouseArea {
                id: sysMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: SystemState.toggleControlCenter()
            }
        }

        // Odak Zamanlayici Hucresi
        Rectangle {
            visible: SettingsState.enableFocusTimer
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        Rectangle {
            visible: SettingsState.enableFocusTimer
            Layout.fillHeight: true
            implicitWidth: focusRow.implicitWidth + 14
            radius: 0
            color: FocusState.running ? Theme.surfaceActive : (focusMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: FocusState.running
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: focusRow
                anchors.centerIn: parent
                spacing: 5
                Text { text: "󰔟"; color: FocusState.running ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall }
                Text { text: FocusState.displayText; color: FocusState.running ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
            }

            MouseArea {
                id: focusMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) FocusState.cycleMode()
                    else if (mouse.button === Qt.MiddleButton) FocusState.reset()
                    else FocusState.toggle()
                }
            }
        }

        // Konteyner Izleyici Hucresi
        Rectangle {
            visible: SettingsState.enableContainerMonitor
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        Rectangle {
            visible: SettingsState.enableContainerMonitor
            Layout.fillHeight: true
            implicitWidth: contRow.implicitWidth + 14
            radius: 0
            color: ContainerState.isOpen ? Theme.surfaceActive : (contMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: ContainerState.isOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: contRow
                anchors.centerIn: parent
                spacing: 5
                Text { text: "󰡨"; color: ContainerState.isOpen ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall }
                Text { text: String(ContainerState.runningCount); color: ContainerState.isOpen ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
            }

            MouseArea {
                id: contMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ContainerState.toggle()
            }
        }

        // Yerel Bar Eklentileri (~/.config/enyxma/plugins)
        Repeater {
            model: PluginState.activeBarPlugins
            delegate: Loader {
                required property var modelData
                source: "file://" + modelData.entryPath
                asynchronous: true
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 4
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showAi
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 6. ORACLE // AI Hucresi
        Rectangle {
            visible: SettingsState.showAi
            Layout.fillHeight: true
            implicitWidth: aiRow.implicitWidth + 16
            radius: 0
            color: AIState.isOpen ? Theme.surfaceActive : (aiMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: AIState.isOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: aiRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "󰧑"
                    color: AIState.isOpen ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    text: "ORACLE"
                    color: AIState.isOpen ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeXS
                    font.bold: true
                    font.letterSpacing: 1
                }
            }

            MouseArea {
                id: aiMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: AIState.toggle()
            }
        }

        // Dikey Izgara Ayirici
        Rectangle {
            visible: SettingsState.showNotifications
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.borderSubtle
        }

        // 7. Bildirim Hucresi
        Rectangle {
            visible: SettingsState.showNotifications
            Layout.fillHeight: true
            implicitWidth: notifRow.implicitWidth + 16
            radius: 0
            color: NotificationState.isPanelOpen ? Theme.surfaceActive : (notifMa.containsMouse ? Theme.surfaceHover : "transparent")

            Rectangle {
                visible: NotificationState.isPanelOpen
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
            }

            RowLayout {
                id: notifRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "󰂚"
                    color: NotificationState.isPanelOpen ? Theme.accent
                        : (NotificationState.notifications.length > 0 ? Theme.textPrimary : Theme.textSecondary)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                }

                Rectangle {
                    visible: NotificationState.notifications.length > 0
                    implicitWidth: notifCountTxt.implicitWidth + 6
                    implicitHeight: 16
                    radius: 0
                    color: Theme.accent

                    Text {
                        id: notifCountTxt
                        anchors.centerIn: parent
                        text: NotificationState.notifications.length > 99 ? "99" : String(NotificationState.notifications.length)
                        color: Theme.accentOn
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeXS
                        font.bold: true
                    }
                }
            }

            MouseArea {
                id: notifMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationState.toggle()
            }
        }

        // Sistem Tepsisi
        Tray {
            id: tray
            visible: SettingsState.showTray && implicitWidth > 0
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: visible ? Theme.spacingXS : 0
            Layout.rightMargin: visible ? Theme.spacingSmall : 0
        }
    }

    // Gotham 2.0 alt ayrim hatti: 1 piksel keskin grafit
    Rectangle {
        id: bottomLine
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.borderSubtle
    }
}
