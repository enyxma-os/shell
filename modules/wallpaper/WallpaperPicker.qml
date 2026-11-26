import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

/**
 * WallpaperPicker — Enyxma Shell Duvar Kagidi Secici Yonlendiricisi.
 *
 * Ortak filtreleme, klavye kisayollari, karartma katmani ve durum esitlemesini
 * yonetir; temaya gore DynamicWallpaperStage veya GothamWallpaperStage yukler.
 */
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

    // Filtrelenmis liste
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
        function syncSelectionToCurrent() {
            var list = root.filteredWallpapers || []
            for (var i = 0; i < list.length; i++) {
                if (list[i].filePath === WallpaperState.currentWallpaper) {
                    root.selectedIndex = i
                    return
                }
            }
            if (list.length > 0 && root.selectedIndex >= list.length) {
                root.selectedIndex = 0
            }
        }
        function onPickerVisibleChanged() {
            if (WallpaperState.pickerVisible) {
                root.filterText = ""
                syncSelectionToCurrent()
                stageHost.forceActiveFocus()
            }
        }
        function onWallpapersChanged() {
            if (WallpaperState.pickerVisible) {
                syncSelectionToCurrent()
            }
        }
    }

    // Karartma katmani — Tema scrim tokeni
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: Theme.isGotham ? root.reveal : (root.reveal * 0.85)

        MouseArea {
            anchors.fill: parent
            onClicked: WallpaperState.closePicker()
            onWheel: function(wheel) {
                root.moveSelection(wheel.angleDelta.y < 0 ? 1 : -1)
            }
        }
    }

    // Bos durum — Arama sonucu bulunamadiginda
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: root.filteredWallpapers.length === 0 && root.reveal > 0
        opacity: root.reveal

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.filterText ? (I18n.t("Eşleşen duvar kağıdı bulunamadı: \"", "No matching wallpaper found: \"") + root.filterText + "\"") : I18n.t("Kütüphanede duvar kağıdı bulunamadı", "No wallpapers found in library")
            color: Theme.textSecondary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeLarge
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: I18n.t("Temizlemek için Esc veya Backspace, kapatmak için boşluğa tıklayın", "Press Esc or Backspace to clear, or click outside to close")
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeNormal
        }
    }

    // Ortak Klavye ve Sahne Yukleyici
    Item {
        id: stageHost
        anchors.fill: parent
        focus: WallpaperState.pickerVisible
        opacity: root.reveal

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
            } else if (event.key === Qt.Key_T && root.filterText.length === 0 && !(event.modifiers & Qt.ControlModifier)) {
                WallpaperState.cycleTheme()
                event.accepted = true
            } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
                root.filterText += event.text
                event.accepted = true
            }
        }

        Loader {
            id: stageLoader
            anchors.fill: parent
            visible: root.filteredWallpapers.length > 0
            sourceComponent: Theme.isGotham ? gothamStageComponent : dynamicStageComponent
            onLoaded: {
                if (WallpaperState.pickerVisible) {
                    stageHost.forceActiveFocus()
                }
            }
        }

        Component {
            id: dynamicStageComponent
            DynamicWallpaperStage {
                anchors.fill: parent
                wallpapers: root.filteredWallpapers
                selectedIndex: root.selectedIndex
                filterText: root.filterText
                onSelectIndexRequested: (idx) => { root.selectedIndex = idx }
                onApplyRequested: root.applySelected()
                onRefocusRequested: stageHost.forceActiveFocus()
            }
        }

        Component {
            id: gothamStageComponent
            GothamWallpaperStage {
                anchors.fill: parent
                wallpapers: root.filteredWallpapers
                selectedIndex: root.selectedIndex
                filterText: root.filterText
                onSelectIndexRequested: (idx) => { root.selectedIndex = idx }
                onMoveRequested: (delta) => root.moveSelection(delta)
                onApplyRequested: root.applySelected()
                onRefocusRequested: stageHost.forceActiveFocus()
            }
        }
    }
}
