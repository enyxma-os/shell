import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-wallpaper-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.keyboardFocus: (WallpaperState.pickerVisible && visible)
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    visible: WallpaperState.pickerVisible

    property real reveal: WallpaperState.pickerVisible ? 1.0 : 0.0
    Behavior on reveal {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    property string filterText: ""
    property int selectedIndex: 0

    // Filtrelenmiş liste
    readonly property var filteredWallpapers: {
        var all = WallpaperState.wallpapers || []
        var query = String(filterText || "").trim().toLowerCase()
        if (!query) return all
        var res = []
        for (var i = 0; i < all.length; i++) {
            var item = all[i]
            var l = String(item.label || "").toLowerCase()
            var f = String(item.fileName || "").toLowerCase()
            if (l.indexOf(query) !== -1 || f.indexOf(query) !== -1) {
                res.push(item)
            }
        }
        return res
    }

    onFilteredWallpapersChanged: {
        if (filteredWallpapers.length === 0) {
            selectedIndex = 0
        } else if (selectedIndex >= filteredWallpapers.length) {
            selectedIndex = Math.max(0, filteredWallpapers.length - 1)
        }
    }

    function moveSelection(delta) {
        if (filteredWallpapers.length === 0) return
        var next = selectedIndex + delta
        if (next < 0) next = 0
        if (next >= filteredWallpapers.length) next = filteredWallpapers.length - 1
        selectedIndex = next
    }

    function applySelected() {
        if (filteredWallpapers.length === 0) return
        if (selectedIndex >= 0 && selectedIndex < filteredWallpapers.length) {
            var item = filteredWallpapers[selectedIndex]
            WallpaperState.setWallpaper(item.filePath)
            WallpaperState.closePicker()
        }
    }

    Connections {
        target: WallpaperState
        function onPickerVisibleChanged() {
            if (WallpaperState.pickerVisible) {
                root.filterText = ""
                // Mevcut seçili olan duvar kağıdına odaklan
                var all = WallpaperState.wallpapers || []
                for (var i = 0; i < all.length; i++) {
                    if (all[i].filePath === WallpaperState.currentWallpaper) {
                        root.selectedIndex = i
                        break
                    }
                }
                stage.forceActiveFocus()
            }
        }
    }

    // Karartma katmanı (Scrim)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.04, 0.05, 0.08, 0.85)
        opacity: root.reveal

        MouseArea {
            anchors.fill: parent
            onClicked: WallpaperState.closePicker()
            onWheel: function(wheel) {
                root.moveSelection(wheel.angleDelta.y < 0 ? 1 : -1)
            }
        }
    }

    // Boş durum (Arama sonucu bulunamadığında)
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: root.filteredWallpapers.length === 0 && root.reveal > 0
        opacity: root.reveal

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.filterText ? ("Eşleşen duvar kağıdı bulunamadı: \"" + root.filterText + "\"") : "Kütüphanede duvar kağıdı bulunamadı"
            color: Theme.textSecondary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeLarge
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Temizlemek için Esc veya Backspace, kapatmak için boşluğa tıklayın"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeNormal
        }
    }

    // ── Tanzaku Sahnesi (Stage) ──
    Item {
        id: stage
        anchors.fill: parent
        visible: root.filteredWallpapers.length > 0
        opacity: root.reveal
        focus: true

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

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (root.filterText.length > 0) root.filterText = ""
                else WallpaperState.closePicker()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.applySelected()
                event.accepted = true
            } else if (event.key === Qt.Key_Backspace) {
                if (root.filterText.length > 0) {
                    root.filterText = root.filterText.slice(0, -1)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab
                       || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                root.moveSelection(-1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                root.moveSelection(1)
                event.accepted = true
            } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
                root.filterText += event.text
                event.accepted = true
            }
        }

        // ── Tema Profili Seçici Şeridi ──
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
                            stage.forceActiveFocus()
                        }
                    }
                }
            }
        }

        // ── Üst Bilgi Satırı ──
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
                text: "ENYXMA OS DUVAR KAĞITLARI"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.letterSpacing: 2
                font.weight: Font.Medium
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: (root.selectedIndex + 1) + " / " + root.filteredWallpapers.length
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // ── Tanzaku Kartlar Alanı ──
        Item {
            id: carouselArea
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -20
            width: parent.width
            height: stage.focusedH

            Repeater {
                model: root.filteredWallpapers.length

                delegate: Item {
                    id: cardItem
                    required property int index
                    readonly property var entry: root.filteredWallpapers[index] || null
                    readonly property int relIdx: index - root.selectedIndex
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

                    // Dış Kart Çerçevesi
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

                        // İç kırpma alanı
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

                            // Odak dışı kart karartması
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

                    // Aktif Duvar Kağıdı Rozeti
                    Rectangle {
                        visible: cardItem.entry && cardItem.entry.filePath === WallpaperState.currentWallpaper
                        width: 72
                        height: 22
                        radius: 11
                        x: 10
                        y: 10
                        z: 10
                        color: Qt.rgba(0.04, 0.05, 0.08, 0.85)
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

                    // Tıklama Alanı
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (cardItem.focused) {
                                root.applySelected()
                            } else {
                                root.selectedIndex = cardItem.index
                            }
                        }
                    }
                }
            }
        }

        // ── Alt Bilgi Bölümü (Vurgu Çizgisi, Başlık & Kısayol Rehberi) ──
        Column {
            anchors.top: carouselArea.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            // Gradyanlı fırça darbesi vurgu çizgisi
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

            // Seçili Duvar Kağıdı İsmi
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.filteredWallpapers.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredWallpapers.length)
                      ? root.filteredWallpapers[root.selectedIndex].label
                      : ""
                color: Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: 22
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            // Canlı Filtre Metni (Yazılıyorsa göster)
            Text {
                visible: root.filterText.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Filtre: " + root.filterText
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Kısayol Rehberi
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "← →  kaydır     Enter  uygula     Esc  kapat     yazarak filtrele"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
