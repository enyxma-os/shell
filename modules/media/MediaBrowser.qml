import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-media-browser"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.keyboardFocus: (MediaBrowserState.isOpen && visible)
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    visible: MediaBrowserState.isOpen

    property real reveal: MediaBrowserState.isOpen ? 1.0 : 0.0
    Behavior on reveal {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    property string filterText: ""
    property int selectedIndex: 0
    property bool confirmDelete: false

    onSelectedIndexChanged: confirmDelete = false

    // Filtrelenmiş liste
    readonly property var filteredItems: {
        var all = MediaBrowserState.items || []
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

    onFilteredItemsChanged: {
        if (filteredItems.length === 0) {
            selectedIndex = 0
        } else if (selectedIndex >= filteredItems.length) {
            selectedIndex = Math.max(0, filteredItems.length - 1)
        }
    }

    function moveSelection(delta) {
        if (filteredItems.length === 0) return
        var next = selectedIndex + delta
        if (next < 0) next = 0
        if (next >= filteredItems.length) next = filteredItems.length - 1
        selectedIndex = next
    }

    readonly property var currentItem: (filteredItems.length > 0 && selectedIndex >= 0 && selectedIndex < filteredItems.length)
        ? filteredItems[selectedIndex]
        : null

    Connections {
        target: MediaBrowserState
        function onIsOpenChanged() {
            if (MediaBrowserState.isOpen) {
                root.filterText = ""
                root.selectedIndex = 0
                root.confirmDelete = false
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
            onClicked: MediaBrowserState.close()
            onWheel: function(wheel) {
                root.moveSelection(wheel.angleDelta.y < 0 ? 1 : -1)
            }
        }
    }

    // Boş durum (Kayıt/Ekran görüntüsü bulunamadığında)
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: root.filteredItems.length === 0 && root.reveal > 0
        opacity: root.reveal

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.filterText
                  ? ("Eşleşen medya bulunamadı: \"" + root.filterText + "\"")
                  : (MediaBrowserState.mode === "videos"
                     ? "Henüz ekran kaydı bulunamadı (~/Videos/Recordings)"
                     : "Henüz ekran görüntüsü bulunamadı (~/Pictures/Screenshots)")
            color: Theme.textSecondary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeLarge
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Kapatmak için Esc veya boşluğa tıklayın"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeNormal
        }
    }

    // ── Tanzaku Sahnesi (Stage) ──
    Item {
        id: stage
        anchors.fill: parent
        visible: root.filteredItems.length > 0
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
                if (root.confirmDelete) root.confirmDelete = false
                else if (root.filterText.length > 0) root.filterText = ""
                else MediaBrowserState.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Delete) {
                if (root.confirmDelete) {
                    if (root.currentItem) MediaBrowserState.deleteItem(root.currentItem.rawPath)
                    root.confirmDelete = false
                } else {
                    root.confirmDelete = true
                }
                event.accepted = true
            } else if (event.key === Qt.Key_B && (event.modifiers & Qt.ControlModifier)) {
                if (root.currentItem && !root.currentItem.isVideo) {
                    MediaBrowserState.openInMockupStudio(root.currentItem.rawPath)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier)) {
                if (root.currentItem) {
                    MediaBrowserState.copyItem(root.currentItem.rawPath, root.currentItem.isVideo)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.currentItem) {
                    MediaBrowserState.openItem(root.currentItem.rawPath)
                }
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

        // ── Üst Bilgi Satırı (Başlık & Sayaç) ──
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: carouselArea.top
            anchors.bottomMargin: 24
            width: stage.focusedW
            height: 20

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: MediaBrowserState.mode === "videos" ? "EKRAN KAYITLARI / VİDEOLAR" : "EKRAN GÖRÜNTÜLERİ"
                color: Theme.textSecondary
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.letterSpacing: 2
                font.weight: Font.Medium
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: (root.selectedIndex + 1) + " / " + root.filteredItems.length
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
                model: root.filteredItems.length

                delegate: Item {
                    id: cardItem
                    required property int index
                    readonly property var entry: root.filteredItems[index] || null
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
                        radius: 10
                        color: Theme.bgPanel
                        border.width: cardItem.focused ? 2 : 1
                        border.color: cardItem.focused
                            ? (root.confirmDelete ? Theme.danger : Theme.accent)
                            : Theme.borderSubtle

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

                            // Video rozeti (video dosyaları için)
                            Rectangle {
                                visible: cardItem.entry && cardItem.entry.isVideo
                                width: 36
                                height: 36
                                radius: 18
                                color: Qt.rgba(0.04, 0.05, 0.08, 0.75)
                                anchors.centerIn: parent

                                Text {
                                    text: "▶"
                                    color: Theme.textPrimary
                                    font.pixelSize: 14
                                    anchors.centerIn: parent
                                }
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

                    // Tıklama Alanı
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (cardItem.focused) {
                                if (cardItem.entry) MediaBrowserState.openItem(cardItem.entry.rawPath)
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
                    GradientStop { position: 0.5; color: root.confirmDelete ? Theme.danger : Theme.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Seçili Medya İsmi
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (!root.currentItem) return ""
                    var prefix = root.currentItem.isVideo ? "Videos · " : "Screenshots · "
                    return prefix + root.currentItem.fileName
                }
                color: Theme.textPrimary
                font.family: Theme.fontMono
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            // Toast Bildirimi (Panoya kopyalandığında veya silindiğinde)
            Rectangle {
                visible: MediaBrowserState.toastText.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: toastLabel.implicitWidth + 24
                implicitHeight: 28
                radius: 14
                color: Qt.rgba(0.04, 0.05, 0.08, 0.90)
                border.color: Theme.accent
                border.width: 1

                Text {
                    id: toastLabel
                    anchors.centerIn: parent
                    text: MediaBrowserState.toastText
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }

            // Canlı Filtre Metni
            Text {
                visible: root.filterText.length > 0 && !root.confirmDelete
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Filtre: " + root.filterText
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            // 2 Aşamalı Silme Onayı Uyarısı
            Text {
                visible: root.confirmDelete
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Bu " + (MediaBrowserState.mode === "videos" ? "video" : "ekran görüntüsü") + " silinsin mi?   Onaylamak için tekrar Del  ·  İptal için Esc"
                color: Theme.danger
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Normal Kısayol Rehberi
            Text {
                visible: !root.confirmDelete && MediaBrowserState.toastText.length === 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: "← →  gezin     Enter  aç     Ctrl+B  ✦ güzelleştir     Ctrl+C  kopyala     Del  sil     Esc"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
