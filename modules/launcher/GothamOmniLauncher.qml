import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

Item {
    id: root

    function launchCurrent() {
        const items = LauncherState.currentItems
        if (items && items.length > 0) {
            const idx = Math.max(0, Math.min(appList.currentIndex, items.length - 1))
            LauncherState.activateItem(items[idx])
        }
    }

    function syncFocus() {
        if (LauncherState.isOpen) {
            searchField.text = LauncherState.searchText
            searchField.forceActiveFocus()
            appList.currentIndex = 0
        }
    }

    Component.onCompleted: syncFocus()

    Connections {
        target: LauncherState
        function onIsOpenChanged() {
            root.syncFocus()
        }
        function onActiveModeChanged() {
            if (searchField.text !== LauncherState.searchText) {
                searchField.text = LauncherState.searchText
            }
            appList.currentIndex = 0
            if (LauncherState.isOpen) {
                searchField.forceActiveFocus()
            }
        }
    }

    Rectangle {
        id: deck
        anchors.centerIn: parent
        implicitWidth: 660
        implicitHeight: mainCol.implicitHeight + 28
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1

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
            onClicked: {}
        }

        ColumnLayout {
            id: mainCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
                topMargin: 14
            }
            spacing: 8

            // Taktiksel Başlık Şeridi
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "ENYXMA // KOMUT TERMİNALİ"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.8
                    Layout.fillWidth: true
                }

                Text {
                    text: "[ " + LauncherState.currentItems.length + " ÖĞE ]"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // Keskin Alt Çizgili 3 Sekme Şeridi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: Theme.bgDark
                border.color: Theme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: LauncherState.modes

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool isTabActive: LauncherState.activeMode === modelData.id

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: isTabActive
                                ? Theme.surfaceActive
                                : (tabArea.containsMouse ? Theme.surfaceHover : "transparent")

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: modelData.icon
                                    color: isTabActive ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: modelData.label.toUpperCase()
                                    color: isTabActive ? Theme.textPrimary : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: isTabActive
                                    font.letterSpacing: 1
                                }
                            }

                            Rectangle {
                                visible: isTabActive
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: 2
                                color: Theme.accent
                            }

                            MouseArea {
                                id: tabArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: LauncherState.setMode(modelData.id)
                            }
                        }
                    }
                }
            }

            // Terminal Tarzı Arama Çubuğu
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: 0
                color: Theme.bgDark
                border.color: searchField.activeFocus ? Theme.accent : Theme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 10
                    }
                    spacing: 8

                    Text {
                        text: ">"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                        font.bold: true
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: {
                            if (LauncherState.activeMode === "actions") return "sistem komutu ara..."
                            if (LauncherState.activeMode === "clipboard") return "pano geçmişinde ara..."
                            return "uygulama veya > komut..."
                        }
                        placeholderTextColor: Theme.textMuted
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                        background: null
                        focus: true

                        onTextChanged: {
                            if (text.startsWith(">")) {
                                const rest = text.substring(1).trimStart()
                                LauncherState.setMode("actions")
                                text = rest
                                return
                            }
                            LauncherState.searchText = text
                            appList.currentIndex = 0
                        }

                        Keys.onTabPressed: (event) => {
                            LauncherState.cycleMode(1)
                            event.accepted = true
                        }

                        Keys.onBacktabPressed: (event) => {
                            LauncherState.cycleMode(-1)
                            event.accepted = true
                        }

                        Keys.onEscapePressed: (event) => {
                            LauncherState.close()
                            event.accepted = true
                        }

                        Keys.onDownPressed: (event) => {
                            appList.incrementCurrentIndex()
                            event.accepted = true
                        }

                        Keys.onUpPressed: (event) => {
                            appList.decrementCurrentIndex()
                            event.accepted = true
                        }

                        Keys.onReturnPressed: (event) => {
                            root.launchCurrent()
                            event.accepted = true
                        }
                    }

                    Rectangle {
                        visible: LauncherState.activeMode === "clipboard" && LauncherState.clipboardItems.length > 0
                        implicitWidth: wipeTxt.implicitWidth + 12
                        implicitHeight: 22
                        radius: 0
                        color: wipeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: Theme.danger
                        border.width: 1

                        Text {
                            id: wipeTxt
                            anchors.centerIn: parent
                            text: "TEMİZLE"
                            color: Theme.danger
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            id: wipeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: LauncherState.wipeClipboard()
                        }
                    }

                    Rectangle {
                        visible: searchField.text.length > 0
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 0
                        color: clearSearchMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: clearSearchMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = ""
                                searchField.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            // Keskin Liste Görünümü
            ListView {
                id: appList
                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, 360)
                clip: true
                model: LauncherState.currentItems
                currentIndex: 0
                highlightFollowsCurrentItem: true
                visible: LauncherState.currentItems.length > 0

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: appList.width
                    implicitHeight: 46
                    radius: 0
                    color: (appList.currentIndex === index || delegateArea.containsMouse) ? Theme.surfaceHover : "transparent"
                    border.color: (appList.currentIndex === index) ? Theme.borderFocus : "transparent"
                    border.width: 1

                    Rectangle {
                        visible: appList.currentIndex === index
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 3
                        color: Theme.accent
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 10
                        }
                        spacing: 10

                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            Image {
                                id: appIconImg
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                fillMode: Image.PreserveAspectFit
                                source: (modelData.kind === "app" && modelData.iconName.length > 0)
                                    ? (Quickshell.iconPath(modelData.iconName) || "")
                                    : ""
                                visible: modelData.kind === "app" && status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: !(modelData.kind === "app" && appIconImg.status === Image.Ready)
                                radius: 0
                                color: (appList.currentIndex === index) ? Theme.surfaceActive : Theme.bgDark
                                border.color: (appList.currentIndex === index) ? Theme.accent : Theme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (modelData.kind === "app") {
                                            return (modelData.title && modelData.title.length > 0)
                                                ? modelData.title.charAt(0).toUpperCase()
                                                : "󰀻"
                                        }
                                        return modelData.iconGlyph
                                    }
                                    color: (appList.currentIndex === index) ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: modelData.title || ""
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.subtitle || ""
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }

                        Rectangle {
                            visible: modelData.badge && modelData.badge.length > 0 && modelData.kind !== "app"
                            implicitWidth: badgeText.implicitWidth + 10
                            implicitHeight: 18
                            radius: 0
                            color: (appList.currentIndex === index) ? Theme.surfaceActive : Theme.bgDark
                            border.color: (appList.currentIndex === index) ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: modelData.badge || ""
                                color: (appList.currentIndex === index) ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        Text {
                            visible: modelData.kind === "app"
                            text: "[ ↵ ]"
                            color: (appList.currentIndex === index) ? Theme.accent : "transparent"
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: delegateArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appList.currentIndex = index
                            root.launchCurrent()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 60
                visible: LauncherState.currentItems.length === 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: LauncherState.activeMode === "clipboard" ? "󰅍" : "󰍉"
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 16
                    }

                    Text {
                        text: {
                            if (LauncherState.activeMode === "actions") return "EŞLEŞEN SİSTEM KOMUTU YOK"
                            if (LauncherState.activeMode === "clipboard") {
                                return LauncherState.clipboardLoading ? "PANO YÜKLENİYOR..." : "PANO GEÇMİŞİ BOŞ"
                            }
                            return "EŞLEŞEN UYGULAMA YOK"
                        }
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "TAB SEKME  ·  ↑↓ GEZİN  ·  ↵ ÇALIŞTIR  ·  ESC KAPAT"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: LauncherState.activeMode.toUpperCase()
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }
    }
}

