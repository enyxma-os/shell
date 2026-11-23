import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

Item {
    id: root

    property string shortcutFilter: ""

    readonly property var filteredShortcuts: {
        var q = root.shortcutFilter.trim().toLowerCase()
        var list = SettingsState.shortcuts || []
        if (q === "") return list
        var out = []
        for (var i = 0; i < list.length; i++) {
            var item = list[i]
            if (String(item.keys).toLowerCase().indexOf(q) >= 0 ||
                String(item.action).toLowerCase().indexOf(q) >= 0) {
                out.push(item)
            }
        }
        return out
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 696)
        height: Math.min(parent.height - 80, 510)
        color: Theme.bgGlass
        radius: 0
        border.color: Theme.borderSubtle
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // Ust 2px Gotham kehribar seridi
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.accent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "ENYXMA // AYARLAR"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "×"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: Theme.fontSizeNormal }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.close() }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // Sol Navigasyon
                ColumnLayout {
                    Layout.preferredWidth: 160
                    Layout.fillHeight: true
                    spacing: 4

                    Repeater {
                        model: [
                            { key: "appearance", label: "GÖRÜNÜM" },
                            { key: "bar",        label: "ÜST ÇUBUK" },
                            { key: "shortcuts",  label: "KISAYOLLAR" },
                            { key: "system",     label: "SİSTEM" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active: SettingsState.activeTab === modelData.key
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 0
                            color: active ? Theme.surfaceActive : (navMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: active ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                text: (parent.active ? "▸ " : "  ") + modelData.label
                                color: parent.active ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                font.bold: parent.active
                            }

                            MouseArea {
                                id: navMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsState.activeTab = modelData.key
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: Theme.borderSubtle }

                // Sag Icerik
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // ── SEKME 1: GORUNUM ─────────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "appearance"
                        spacing: 8

                        Text { text: "TASARIM KİMLİĞİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: [
                                    { key: "dynamic", label: "DİNAMİK // MATUGEN" },
                                    { key: "gotham",  label: "GOTHAM // BRUTALIST" }
                                ]
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool active: (modelData.key === "gotham") ? Theme.isGotham : !Theme.isGotham
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    radius: 0
                                    color: active ? Theme.surfaceActive : Theme.surface1
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.label; color: parent.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: parent.active }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: WallpaperState.setThemePreset(modelData.key) }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 0
                            color: wpOpenMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: wpOpenMa.containsMouse ? Theme.accent : Theme.borderSubtle
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "[DUVAR KAĞIDI GALERİSİNİ AÇ]"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11 }
                            MouseArea { id: wpOpenMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.close(); WallpaperState.openPicker() } }
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                Text { text: "HAREKET VE ANİMASYONLARI AZALT"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                                Text { text: SettingsState.reduceMotion ? "[AÇIK]" : "[KAPALI]"; color: SettingsState.reduceMotion ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11 }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.reduceMotion = !SettingsState.reduceMotion; SettingsState.save() } }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                Text { text: "ÜST ÇUBUK GÖRÜNÜR"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                                Text { text: SettingsState.barVisible ? "[AÇIK]" : "[KAPALI]"; color: SettingsState.barVisible ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11 }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.barVisible = !SettingsState.barVisible; SettingsState.save() } }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 6
                                Text { text: "ÜST ÇUBUK YÜKSEKLİĞİ"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: 24; implicitHeight: 20; radius: 0; color: Theme.surface2; border.color: Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: "-"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(-1) }
                                }
                                Text { text: Theme.barHeight + " PX"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 46 }
                                Rectangle {
                                    implicitWidth: 24; implicitHeight: 20; radius: 0; color: Theme.surface2; border.color: Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(1) }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // ── SEKME 2: UST CUBUK ────────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "bar"
                        spacing: 6

                        Text { text: "ÜST ÇUBUK MODÜLLERİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: [
                                { prop: "showWorkspaces",    label: "ÇALIŞMA ALANLARI" },
                                { prop: "showClock",         label: "SAAT VE HAVA DURUMU" },
                                { prop: "showSystemStats",   label: "SİSTEM TELEMETRİ // CPU-RAM-DİSK" },
                                { prop: "showNetwork",       label: "AĞ VE WI-FI" },
                                { prop: "showVolume",        label: "SES DÜZEYİ" },
                                { prop: "showPower",         label: "GÜÇ VE KONTROL MERKEZİ" },
                                { prop: "showAi",            label: "ORACLE // AI ASİSTAN" },
                                { prop: "showNotifications", label: "BİLDİRİMLER" },
                                { prop: "showTray",          label: "SİSTEM TEPSİSİ" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool val: !!SettingsState[modelData.prop]
                                width: ListView.view.width
                                implicitHeight: 32
                                radius: 0
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                    Text { text: modelData.label; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                                    Text { text: parent.parent.val ? "[AÇIK]" : "[KAPALI]"; color: parent.parent.val ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11 }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SettingsState[modelData.prop] = !SettingsState[modelData.prop]
                                        SettingsState.save()
                                    }
                                }
                            }
                        }
                    }

                    // ── SEKME 3: KISAYOLLAR ──────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "shortcuts"
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 30
                            radius: 0
                            color: Theme.surface1
                            border.color: searchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                            border.width: 1
                            TextInput {
                                id: searchInp
                                anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                text: root.shortcutFilter
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                clip: true
                                onTextChanged: root.shortcutFilter = text
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "KISAYOL VEYA EYLEM ARA..."
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    visible: parent.text.length === 0
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 3
                            model: root.filteredShortcuts
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                implicitHeight: 28
                                radius: 0
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 8
                                    Text { text: modelData.action; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: "[" + modelData.keys + "]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
                                }
                            }
                        }
                    }

                    // ── SEKME 4: SISTEM ──────────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "system"
                        spacing: 8

                        Text { text: "KALICI AYAR DOSYASI"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            Text {
                                anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 10
                                text: SettingsState.configPath
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 32
                                radius: 0
                                color: openCfgMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                                border.color: Theme.accent
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "[AYAR DOSYASINI AÇ]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                MouseArea { id: openCfgMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.openConfigFile() }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 32
                                radius: 0
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "[VARSAYILANLARA SIFIRLA]"; color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11 }
                                MouseArea { id: resetMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetDefaults() }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
