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

    WlrLayershell.namespace: "enyxma-media-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: MediaState.isPanelOpen ? 42 : 20
        right: 12
    }

    implicitWidth: 380
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

    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgPanel
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: MediaState.isPanelOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        HoverHandler {
            onHoveredChanged: MediaState.setHovered(hovered)
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

            // ── 1. ÜST BİLGİ & ROZETLER ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                // Aktif Oynatıcı Rozeti (Chromium, Spotify, vs.)
                Rectangle {
                    implicitHeight: 22
                    implicitWidth: playerRow.implicitWidth + 14
                    radius: height / 2
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    RowLayout {
                        id: playerRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: {
                                var id = (MediaState.identity || "").toLowerCase()
                                if (id.indexOf("chrom") !== -1 || id.indexOf("brave") !== -1 || id.indexOf("fire") !== -1) return "󰈹"
                                if (id.indexOf("spot") !== -1) return "󰓇"
                                if (id.indexOf("mpv") !== -1 || id.indexOf("vlc") !== -1) return "󰕼"
                                return "󰝚"
                            }
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text: MediaState.identity.length > 0 ? MediaState.identity : "Medya"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }
                }

                // Ses Çıkış Cihazı Rozeti (Dahili Hoparlör / Kulaklık)
                Rectangle {
                    implicitHeight: 22
                    implicitWidth: sinkRow.implicitWidth + 14
                    radius: height / 2
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth
                    Layout.maximumWidth: 160

                    RowLayout {
                        id: sinkRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: AudioState.sinkName.toLowerCase().indexOf("head") !== -1 ? "󰋋" : "󰓃"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text: AudioState.sinkName
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            Layout.maximumWidth: 120
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Kapat Butonu (✕)
                Text {
                    text: "✕"
                    color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    Layout.alignment: Qt.AlignVCenter

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MediaState.close()
                    }
                }
            }

            // ── 2. HERO BÖLÜMÜ: ALBÜM KAPAĞI + PARÇA BİLGİSİ + RİTİM ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMedium

                // Albüm Kapağı (Kare Squircle + Ambiyans Glow)
                Item {
                    implicitWidth: 88
                    implicitHeight: 88

                    // Ambient Parıltı
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        radius: 14
                        color: Theme.accent
                        opacity: MediaState.isPlaying ? 0.22 : 0.08
                        scale: MediaState.isPlaying ? 1.04 : 1.0

                        Behavior on scale {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
                        }
                        Behavior on opacity {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.animNormal }
                        }
                    }

                    // Kapak Çerçevesi
                    Rectangle {
                        id: coverFrame
                        anchors.fill: parent
                        radius: 12
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: Theme.borderWidth
                        clip: true

                        Image {
                            id: coverImg
                            anchors.fill: parent
                            source: MediaState.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }

                        // Kapak yokken gösterilen şık müzik ikonu
                        Text {
                            anchors.centerIn: parent
                            visible: MediaState.artUrl === "" || coverImg.status !== Image.Ready
                            text: "󰝚"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 36
                            opacity: 0.65
                        }
                    }
                }

                // Parça Bilgileri & Mikro Dalgalar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Başlık Üstü Canlı Gösterge
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: MediaState.isPlaying ? "OYNATILIYOR" : "DURAKLATILDI"
                            color: MediaState.isPlaying ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall - 1
                            font.bold: true
                            font.letterSpacing: 1.5
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // 5 Barlık Canlı Ritim Ekolayzırı
                        Row {
                            id: liveEqBars
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            property real phase: 0.0

                            Timer {
                                interval: 100
                                repeat: true
                                running: MediaState.isPlaying && MediaState.isPanelOpen
                                onTriggered: liveEqBars.phase = (liveEqBars.phase + 1) % 8
                            }

                            Repeater {
                                model: 5
                                delegate: Rectangle {
                                    required property int index
                                    width: 3
                                    radius: 1.5
                                    color: Theme.accent
                                    height: {
                                        if (!MediaState.isPlaying) return 3
                                        var p = (liveEqBars.phase + index * 2) % 8
                                        return [4, 12, 16, 7, 14, 9, 5, 11][p]
                                    }

                                    Behavior on height {
                                        enabled: !Theme.reduceMotion
                                        NumberAnimation {
                                            duration: 90
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Parça Başlığı
                    Text {
                        text: MediaState.trackTitle.length > 0 ? MediaState.trackTitle : "Parça Çalmıyor"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal + 1
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Sanatçı / Kanal
                    Text {
                        text: MediaState.artist.length > 0 ? MediaState.artist : (MediaState.hasMedia ? "Bilinmeyen Sanatçı" : "—")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Albüm Adı
                    Text {
                        visible: MediaState.album.length > 0
                        text: MediaState.album
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // ── 3. ZAMAN ÇUBUĞU & SCRUBBER ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                // İlerleme Rayı
                Rectangle {
                    id: trackRail
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        id: trackPlayed
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        radius: parent.radius
                        color: Theme.accent
                        width: parent.width * (MediaState.curLen > 0 ? Math.min(1.0, MediaState.shownPos / MediaState.curLen) : 0.0)

                        Behavior on width {
                            enabled: !scrubberMa.pressed && !Theme.reduceMotion
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    // Tutamaç (Thumb)
                    Rectangle {
                        id: trackThumb
                        width: scrubberMa.containsMouse || scrubberMa.pressed ? 12 : 8
                        height: width
                        radius: width / 2
                        color: Theme.textPrimary
                        border.color: Theme.accent
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(trackRail.width - width, trackPlayed.width - width / 2))

                        Behavior on width {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                        }
                    }

                    MouseArea {
                        id: scrubberMa
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => MediaState.seekToFraction(mouse.x / width)
                        onPositionChanged: (mouse) => {
                            if (pressed) MediaState.seekToFraction(mouse.x / width)
                        }
                    }
                }

                // Süre Etiketleri (Geçen / Kalan Süre)
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: MediaState.formatTime(MediaState.shownPos)
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall - 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MediaState.formatTime(MediaState.curLen)
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall - 1
                    }
                }
            }

            // ── 4. OYNATMA KONTROLLERİ (TRANSPORT) ──
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                // Geri Butonu (󰒮)
                Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: 18
                    color: prevMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: prevMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: prevMa.containsMouse ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    MouseArea {
                        id: prevMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MediaState.previous()
                    }
                }

                // Ana Oynat / Duraklat Butonu (Glow Play Pill)
                Rectangle {
                    implicitWidth: 46
                    implicitHeight: 46
                    radius: 23
                    color: Theme.accent

                    // Glow Parıltısı
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: 26
                        color: Theme.accent
                        opacity: playMa.containsMouse ? 0.40 : 0.20
                        scale: playMa.containsMouse ? 1.08 : 1.0

                        Behavior on scale {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                        }
                        Behavior on opacity {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.animFast }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: MediaState.isPlaying ? "󰏤" : "󰐊"
                        color: Theme.bgDark
                        font.family: Theme.fontMono
                        font.pixelSize: 22
                        font.bold: true
                    }

                    MouseArea {
                        id: playMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MediaState.togglePlayPause()
                    }
                }

                // İleri Butonu (󰒭)
                Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: 18
                    color: nextMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: nextMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Behavior on color {
                        enabled: !Theme.reduceMotion
                        ColorAnimation { duration: Theme.animFast; easing.type: Easing.OutQuint }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: nextMa.containsMouse ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
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

            // ── 5. ALT BÖLÜM: OYNATICI SES SEVİYESİ ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    text: {
                        if (AudioState.muted) return "󰝟"
                        if (MediaState.playerVolume < 0.3) return "󰕿"
                        if (MediaState.playerVolume < 0.7) return "󰖀"
                        return "󰕾"
                    }
                    color: AudioState.muted ? Theme.danger : Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    Layout.alignment: Qt.AlignVCenter
                }

                // Ses Kaydırıcı Rayı
                Rectangle {
                    id: volRail
                    Layout.fillWidth: true
                    height: 4
                    radius: 2
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        radius: parent.radius
                        color: Theme.textSecondary
                        width: parent.width * Math.max(0.0, Math.min(1.0, MediaState.playerVolume))
                    }

                    MouseArea {
                        id: volMa
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => MediaState.setPlayerVolume(mouse.x / width)
                        onPositionChanged: (mouse) => {
                            if (pressed) MediaState.setPlayerVolume(mouse.x / width)
                        }
                    }
                }

                Text {
                    text: Math.round(MediaState.playerVolume * 100) + "%"
                    color: Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall - 1
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
