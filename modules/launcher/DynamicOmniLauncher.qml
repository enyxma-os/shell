import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "../../widgets"

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
        id: card
        anchors.centerIn: parent
        implicitWidth: 640
        implicitHeight: mainCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        scale: LauncherState.isOpen ? 1.0 : 0.96

        Behavior on scale {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
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
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                Repeater {
                    model: LauncherState.modes

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool isTabActive: LauncherState.activeMode === modelData.id

                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: Theme.radiusButton
                        color: isTabActive
                            ? Theme.accent
                            : (tabArea.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: isTabActive ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Behavior on color {
                            enabled: !Theme.reduceMotion
                            ColorAnimation { duration: Theme.animFast }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            Text {
                                text: modelData.icon
                                color: isTabActive ? Theme.accentOn : Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Text {
                                text: modelData.label
                                color: isTabActive ? Theme.accentOn : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: isTabActive
                            }
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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 46
                radius: Theme.radiusWidget
                color: Theme.surface1
                border.color: searchField.activeFocus ? Theme.accent : Theme.borderSubtle
                border.width: Theme.borderWidth

                Behavior on border.color {
                    enabled: !Theme.reduceMotion
                    ColorAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutQuint
                    }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: Theme.spacingMedium
                        rightMargin: Theme.spacingMedium
                    }
                    spacing: Theme.spacingSmall

                    Text {
                        text: {
                            if (LauncherState.activeMode === "actions") return "󰘳"
                            if (LauncherState.activeMode === "clipboard") return "󰅍"
                            return "󰍉"
                        }
                        color: searchField.activeFocus ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: {
                            if (LauncherState.activeMode === "actions") return "Sistem komutu veya araç ara..."
                            if (LauncherState.activeMode === "clipboard") return "Pano geçmişinde ara..."
                            return "Uygulama ara — veya > komutlar"
                        }
                        placeholderTextColor: Theme.textMuted
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
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

                    EnyxmaPill {
                        implicitHeight: 24
                        visible: LauncherState.activeMode === "clipboard" && LauncherState.clipboardItems.length > 0
                        onClicked: LauncherState.wipeClipboard()

                        Text {
                            text: "󰃢 Temizle"
                            color: Theme.danger
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    EnyxmaPill {
                        implicitHeight: 22
                        implicitWidth: 22
                        visible: searchField.text.length > 0
                        onClicked: {
                            searchField.text = ""
                            searchField.forceActiveFocus()
                        }

                        Text {
                            text: "✕"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

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
                    implicitHeight: 48
                    radius: Theme.radiusWidget
                    color: (appList.currentIndex === index || delegateArea.containsMouse) ? Theme.surfaceHover : "transparent"
                    border.color: (appList.currentIndex === index) ? Theme.borderSubtle : "transparent"
                    border.width: Theme.borderWidth

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingMedium
                            rightMargin: Theme.spacingMedium
                        }
                        spacing: Theme.spacingMedium

                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32

                            Image {
                                id: appIconImg
                                anchors.fill: parent
                                sourceSize.width: 32
                                sourceSize.height: 32
                                fillMode: Image.PreserveAspectFit
                                source: (modelData.kind === "app" && modelData.iconName.length > 0)
                                    ? (Quickshell.iconPath(modelData.iconName) || "")
                                    : ""
                                visible: modelData.kind === "app" && status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: !(modelData.kind === "app" && appIconImg.status === Image.Ready)
                                radius: 16
                                color: (appList.currentIndex === index) ? Theme.surfaceActive : Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: Theme.borderWidth

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
                                    font.pixelSize: 15
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
                                font.pixelSize: Theme.fontSizeNormal
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.subtitle || ""
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }

                        Rectangle {
                            visible: modelData.badge && modelData.badge.length > 0 && modelData.kind !== "app"
                            implicitWidth: badgeText.implicitWidth + 12
                            implicitHeight: 20
                            radius: Theme.radiusSmall
                            color: (appList.currentIndex === index) ? Theme.surfaceActive : Theme.surface1
                            border.color: (appList.currentIndex === index) ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: modelData.badge || ""
                                color: (appList.currentIndex === index) ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                                font.bold: true
                            }
                        }

                        Text {
                            visible: modelData.kind === "app"
                            text: "↵"
                            color: (appList.currentIndex === index) ? Theme.accent : "transparent"
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
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
                implicitHeight: 64
                visible: LauncherState.currentItems.length === 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Text {
                        text: {
                            if (LauncherState.activeMode === "clipboard") return "󰅍"
                            return "󰍉"
                        }
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    Text {
                        text: {
                            if (LauncherState.activeMode === "actions") return "Eşleşen sistem komutu bulunamadı"
                            if (LauncherState.activeMode === "clipboard") {
                                return LauncherState.clipboardLoading ? "Pano geçmişi yükleniyor..." : "Pano geçmişi boş"
                            }
                            return "Eşleşen uygulama bulunamadı"
                        }
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: {
                        const count = LauncherState.currentItems.length
                        if (LauncherState.activeMode === "actions") return count + " komut"
                        if (LauncherState.activeMode === "clipboard") return count + " pano öğesi"
                        return count + " uygulama"
                    }
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Tab Sekme  •  ↑↓ Gezin  •  ↵ Seç  •  Esc Kapat"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}

