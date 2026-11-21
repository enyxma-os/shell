import QtQuick
import "../../services"

/**
 * DynamicWallpaperStage — Tanzaku Akici Serit Karusel Duvar Kagidi Secicisi.
 */
Item {
    id: stage

    property var wallpapers: []
    property int selectedIndex: 0
    property string filterText: ""

    signal selectIndexRequested(int idx)
    signal applyRequested()
    signal refocusRequested()

    readonly property int focusedW: 460
    readonly property int focusedH: 259
    readonly property int peekW: 104
    readonly property int stripW: 24
    readonly property int gap: 8
    readonly property int maxVisible: 5

    function stripWidthFor(d) {
        if (d <= 0) return focusedW
        if (d === 1) return peekW
        return stripW
    }

    function xForRel(r) {
        var cx = stage.width / 2
        var fLeft = cx - focusedW / 2
        var fRight = cx + focusedW / 2
        if (r === 0) return fLeft
        if (r < 0) {
            var x = fLeft
            for (var k = -1; k >= r; k--) {
                x -= (gap + stripWidthFor(-k))
            }
            return x
        }
        var xr = fRight + gap
        for (var j = 1; j < r; j++) {
            xr += (stripWidthFor(j) + gap)
        }
        return xr
    }

    // Tema Profili Secici Seridi
    Row {
        id: themePresetRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: headerRow.top
        anchors.bottomMargin: 16
        spacing: 10

        Repeater {
            model: [
                { id: "dynamic", label: "✦ DİNAMİK" },
                { id: "gotham",  label: "🦇 GOTHAM" }
            ]

            delegate: Rectangle {
                required property var modelData
                readonly property bool isSelected: WallpaperState.currentTheme === modelData.id

                height: 28
                width: presetTxt.implicitWidth + 24
                radius: Theme.radiusButton
                color: isSelected
                    ? Theme.accent
                    : (presetMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                border.width: Theme.borderWidth
                border.color: isSelected ? Theme.accent : Theme.borderSubtle

                Text {
                    id: presetTxt
                    anchors.centerIn: parent
                    text: modelData.label
                    color: isSelected ? Theme.accentOn : Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: presetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (WallpaperState.currentTheme !== modelData.id) {
                            WallpaperState.setThemePreset(modelData.id)
                        }
                        stage.refocusRequested()
                    }
                }
            }
        }
    }

    // Ust Bilgi Satiri
    Item {
        id: headerRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: carouselArea.top
        anchors.bottomMargin: 24
        width: stage.focusedW
        height: 20

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "✦ ENYXMA DİNAMİK DUVAR KAĞITLARI"
            color: Theme.textSecondary
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fontSizeSmall
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: (stage.selectedIndex + 1) + " / " + stage.wallpapers.length
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    // Tanzaku Kartlar Alani
    Item {
        id: carouselArea
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        width: parent.width
        height: stage.focusedH

        Repeater {
            model: stage.wallpapers.length

            delegate: Item {
                id: cardItem
                required property int index
                readonly property var entry: stage.wallpapers[index] || null
                readonly property int relIdx: index - stage.selectedIndex
                readonly property bool focused: relIdx === 0
                readonly property bool near: Math.abs(relIdx) <= stage.maxVisible

                width: stage.stripWidthFor(Math.abs(relIdx))
                height: stage.focusedH
                y: 0
                x: stage.xForRel(relIdx)
                z: focused ? 100 : (50 - Math.abs(relIdx))
                visible: near
                opacity: near ? 1.0 : 0.0

                Behavior on x {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                // Dis Kart Cercevesi
                Rectangle {
                    id: cardFrame
                    anchors.fill: parent
                    radius: Theme.radiusWidget
                    color: Theme.bgPanel
                    border.width: cardItem.focused ? 2 : 1
                    border.color: cardItem.focused ? Theme.accent : Theme.borderSubtle

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 180
                        }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: cardItem.focused ? 2 : 1
                        clip: true

                        Image {
                            id: imgThumb
                            anchors.fill: parent
                            source: cardItem.entry ? cardItem.entry.filePath : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            sourceSize.width: stage.focusedW
                            sourceSize.height: stage.focusedH
                        }

                        // Odak disi kart karartmasi
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.bgDark
                            opacity: cardItem.focused ? 0.0 : (Math.abs(cardItem.relIdx) === 1 ? 0.25 : 0.55)
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }
                            }
                        }
                    }
                }

                // Aktif Duvar Kagidi Rozeti — Yalnizca tema tokenlari
                Rectangle {
                    visible: cardItem.entry && cardItem.entry.filePath === WallpaperState.currentWallpaper
                    width: 72
                    height: 22
                    radius: 11
                    x: 10
                    y: 10
                    z: 10
                    color: Theme.bgDark
                    border.color: Theme.accent
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: Theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "AKTİF"
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (cardItem.focused) {
                            stage.applyRequested()
                        } else {
                            stage.selectIndexRequested(cardItem.index)
                        }
                    }
                }
            }
        }
    }

    // Alt Bilgi Bolumu
    Column {
        anchors.top: carouselArea.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220
            height: 3
            radius: 1.5
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.accent }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (stage.wallpapers.length > 0 && stage.selectedIndex >= 0 && stage.selectedIndex < stage.wallpapers.length)
                ? stage.wallpapers[stage.selectedIndex].label
                : ""
            color: Theme.textPrimary
            font.family: Theme.fontMono
            font.pixelSize: 22
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: stage.filterText.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Filtre: " + stage.filterText
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "← →  kaydır     Enter  uygula     T  tema değiştir     Esc  kapat     yazarak filtrele"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
