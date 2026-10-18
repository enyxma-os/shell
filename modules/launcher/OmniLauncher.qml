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

    WlrLayershell.namespace: "enyxma-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // Gotcha #4: Klavye odağını dinamik yönet
    WlrLayershell.keyboardFocus: LauncherState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: card.opacity > 0.0

    function launchCurrent() {
        if (LauncherState.filteredApps && LauncherState.filteredApps.length > 0) {
            const idx = Math.max(0, Math.min(appList.currentIndex, LauncherState.filteredApps.length - 1))
            LauncherState.launch(LauncherState.filteredApps[idx])
        }
    }

    Connections {
        target: LauncherState
        function onIsOpenChanged() {
            if (LauncherState.isOpen) {
                searchField.text = ""
                searchField.forceActiveFocus()
                appList.currentIndex = 0
            }
        }
    }

    // Ekran dışına tıklayınca kapatma alanı
    MouseArea {
        anchors.fill: parent
        onClicked: LauncherState.close()
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        implicitWidth: 600
        implicitHeight: mainCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: LauncherState.isOpen ? 1.0 : 0.0
        scale: LauncherState.isOpen ? 1.0 : 0.96

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Behavior on scale {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        // Tıklamaların arka plana geçmesini önle
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
            spacing: Theme.spacingMedium

            // Üst Arama Çubuğu
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
                        text: "󰍉"
                        color: searchField.activeFocus ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Bir uygulama arayın veya komut yazın..."
                        placeholderTextColor: Theme.textMuted
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        background: null
                        focus: true

                        onTextChanged: {
                            LauncherState.searchText = text
                            appList.currentIndex = 0
                        }

                        Keys.onEscapePressed: {
                            LauncherState.close()
                            event.accepted = true
                        }

                        Keys.onDownPressed: {
                            appList.incrementCurrentIndex()
                            event.accepted = true
                        }

                        Keys.onUpPressed: {
                            appList.decrementCurrentIndex()
                            event.accepted = true
                        }

                        Keys.onReturnPressed: {
                            root.launchCurrent()
                            event.accepted = true
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

            // Uygulama Listesi
            ListView {
                id: appList
                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, 340)
                clip: true
                model: LauncherState.filteredApps
                currentIndex: 0
                highlightFollowsCurrentItem: true
                visible: LauncherState.filteredApps.length > 0

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

                        // İkon Konteyneri (Sabit 32x32)
                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32

                            Image {
                                id: appIconImg
                                anchors.fill: parent
                                sourceSize.width: 32
                                sourceSize.height: 32
                                fillMode: Image.PreserveAspectFit
                                source: Quickshell.iconPath(modelData.icon) || ""
                                visible: status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: appIconImg.status !== Image.Ready
                                radius: 16
                                color: Theme.surfaceActive
                                border.color: Theme.borderSubtle
                                border.width: Theme.borderWidth

                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "󰀻"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }

                        // Uygulama Adı ve Açıklama
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name || ""
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.genericName || modelData.comment || modelData.id || ""
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }

                        // Enter İpucu
                        Text {
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

            // Eşleşen Sonuç Bulunamadı Durumu
            Item {
                Layout.fillWidth: true
                implicitHeight: 64
                visible: LauncherState.filteredApps.length === 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Text {
                        text: "󰍉"
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    Text {
                        text: "Eşleşen uygulama bulunamadı"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }
            }

            // Alt Kısayol İpuçları Çubuğu
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: LauncherState.filteredApps.length + " uygulama"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "↑↓ Gezin  •  ↵ Başlat  •  Esc Kapat"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}
