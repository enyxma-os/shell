import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-cc"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: SystemState.isControlCenterOpen ? 46 : 20
        right: 12
    }

    implicitWidth: 330
    implicitHeight: mainCard.implicitHeight
    color: "transparent"

    visible: mainCard.opacity > 0.0

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    // Ekran parlaklığı durumu ve süreci
    property real brightnessLevel: 0.85

    Process {
        id: brightProc
        running: false
    }

    function setBrightness(val) {
        var clamped = Math.max(0.05, Math.min(1.0, val))
        root.brightnessLevel = clamped
        var pct = Math.round(clamped * 100)
        brightProc.command = ["bash", "-c", "brightnessctl set " + pct + "% >/dev/null 2>&1 || true"]
        brightProc.running = false
        brightProc.running = true
    }

    // Gece Işığı durumu (hyprsunset toggle)
    property bool nightLightActive: false
    Process {
        id: nightLightProc
        running: false
    }

    function toggleNightLight() {
        root.nightLightActive = !root.nightLightActive
        var cmd = root.nightLightActive
            ? "(hyprsunset -t 4500 >/dev/null 2>&1 &)"
            : "pkill -f hyprsunset >/dev/null 2>&1 || true"
        nightLightProc.command = ["bash", "-c", cmd]
        nightLightProc.running = false
        nightLightProc.running = true
    }

    // Rahatsız Etme (DND)
    property bool dndActive: false

    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderFocus
        border.width: Theme.borderWidth

        opacity: SystemState.isControlCenterOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingMedium

            // ── 1. Üst Başlık: Kullanıcı & Oturum Bilgisi ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: Theme.surfaceActive
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: ""
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true

                    Text {
                        text: "Enyxma OS"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        font.bold: true
                    }

                    Text {
                        text: TimeState.formattedDate + " • " + TimeState.formattedTime
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                EnyxmaPill {
                    implicitHeight: 26
                    implicitWidth: 26
                    onClicked: SystemState.closeControlCenter()

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // ── 2. Hızlı Kartlar (2x2 Eylem Matrisi) ──
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.spacingSmall
                columnSpacing: Theme.spacingSmall

                // Ağ (Network)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radiusWidget
                    color: SystemState.isConnected ? Theme.surfaceActive : Theme.surface1
                    border.color: SystemState.isConnected ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
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
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: SystemState.isConnected ? "󰤨" : "󰤭"
                            color: SystemState.isConnected ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Ağ"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: SystemState.isConnected ? (SystemState.wifiSSID || "Bağlı") : "Bağlı Değil"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radiusWidget
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰂯"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Bluetooth"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: "Hazır"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Gece Işığı
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radiusWidget
                    color: root.nightLightActive ? Theme.surfaceActive : Theme.surface1
                    border.color: root.nightLightActive ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleNightLight()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: "󰔎"
                            color: root.nightLightActive ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Gece Işığı"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: root.nightLightActive ? "Aktif" : "Kapalı"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                // Rahatsız Etme (DND)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radiusWidget
                    color: root.dndActive ? Theme.surfaceActive : Theme.surface1
                    border.color: root.dndActive ? Theme.borderFocus : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.dndActive = !root.dndActive
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSmall
                        spacing: Theme.spacingSmall

                        Text {
                            text: root.dndActive ? "󰂛" : "󰂚"
                            color: root.dndActive ? Theme.danger : Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Sessiz Mod"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }

                            Text {
                                text: root.dndActive ? "Susturuldu" : "Açık"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            // ── 3. Kaydırıcılar Kartı (Ses & Parlaklık) ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: sliderCol.implicitHeight + Theme.spacingMedium * 2
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                ColumnLayout {
                    id: sliderCol
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: Theme.spacingMedium
                    }
                    spacing: Theme.spacingMedium

                    // Ses Kaydırıcısı
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: AudioState.muted ? "󰝟 Ses" : "󰕾 Ses"
                                color: AudioState.muted ? Theme.danger : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: AudioState.toggleMute()
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: AudioState.muted ? "Sessiz" : Math.round(AudioState.volume * 100) + "%"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        Slider {
                            id: volumeSlider
                            Layout.fillWidth: true
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
                                radius: height / 2
                                color: Theme.surfaceActive

                                Rectangle {
                                    width: volumeSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: AudioState.muted ? Theme.danger : Theme.accent
                                    radius: height / 2
                                }
                            }

                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: width / 2
                                color: Theme.textPrimary
                            }
                        }
                    }

                    // Parlaklık Kaydırıcısı
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "󰃠 Parlaklık"
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: Math.round(brightSlider.value * 100) + "%"
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        Slider {
                            id: brightSlider
                            Layout.fillWidth: true
                            from: 0.05
                            to: 1.0
                            value: root.brightnessLevel

                            Behavior on value {
                                enabled: !brightSlider.pressed && !Theme.reduceMotion
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutQuint
                                }
                            }

                            onMoved: root.setBrightness(value)

                            background: Rectangle {
                                x: brightSlider.leftPadding
                                y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: brightSlider.availableWidth
                                height: implicitHeight
                                radius: height / 2
                                color: Theme.surfaceActive

                                Rectangle {
                                    width: brightSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.accent
                                    radius: height / 2
                                }
                            }

                            handle: Rectangle {
                                x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                                y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: width / 2
                                color: Theme.textPrimary
                            }
                        }
                    }
                }
            }

            // ── 4. Mini Medya Bandı (Yalnızca Müzik/Video Çalıyorsa Görünür) ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 46
                radius: Theme.radiusWidget
                color: Theme.surface2
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth
                visible: MediaState.hasMedia

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSmall
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
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    EnyxmaPill {
                        implicitHeight: 26
                        implicitWidth: 26
                        onClicked: MediaState.previous()
                        Text {
                            Layout.alignment: Qt.AlignCenter
                            text: "󰒮"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }
                    }

                    EnyxmaPill {
                        implicitHeight: 26
                        implicitWidth: 26
                        onClicked: MediaState.togglePlay()
                        Text {
                            Layout.alignment: Qt.AlignCenter
                            text: MediaState.isPlaying ? "󰏤" : "󰐊"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                    }

                    EnyxmaPill {
                        implicitHeight: 26
                        implicitWidth: 26
                        onClicked: MediaState.next()
                        Text {
                            Layout.alignment: Qt.AlignCenter
                            text: "󰒭"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // ── 5. Alt Bölüm: Hızlı Oturum & Güç Çubuğu ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                // Kilitle
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["loginctl", "lock-session"])
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        Text {
                            text: ""
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Kilit"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }

                // Uyku
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "suspend"])
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        Text {
                            text: "󰒲"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Uyku"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }

                // Yeniden Başlat
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Theme.radiusSmall
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "reboot"])
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        Text {
                            text: "󰜉"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Yeniden"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }

                // Kapat
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Theme.radiusSmall
                    color: Theme.surfaceActive
                    border.color: Theme.danger
                    border.width: Theme.borderWidth

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SystemState.closeControlCenter()
                            Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        Text {
                            text: "⏻"
                            color: Theme.danger
                            font.family: Theme.fontMono
                            font.pixelSize: 13
                        }
                        Text {
                            text: "Kapat"
                            color: Theme.danger
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
