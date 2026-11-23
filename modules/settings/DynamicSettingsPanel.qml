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
        width: Math.min(parent.width - 48, 680)
        height: Math.min(parent.height - 80, 500)
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingMedium
            spacing: Theme.spacingSmall

            // ── Baslik ───────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Enyxma Ayarlar"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "✕"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.close() }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

            // ── Sol Nav + Sag Icerik ─────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spacingMedium

                // Sol Navigasyon
                ColumnLayout {
                    Layout.preferredWidth: 156
                    Layout.fillHeight: true
                    spacing: 6

                    Repeater {
                        model: [
                            { key: "appearance", label: "Görünüm" },
                            { key: "bar",        label: "Üst Çubuk" },
                            { key: "shortcuts",  label: "Kısayollar" },
                            { key: "system",     label: "Sistem" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active: SettingsState.activeTab === modelData.key
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: Theme.radiusButton
                            color: active ? Theme.surfaceActive : (navMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: active ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                text: modelData.label
                                color: parent.active ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
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

                // Sag Icerik Alani
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // ── SEKME 1: GORUNUM ─────────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "appearance"
                        spacing: 10

                        Text { text: "Tasarım Kimliği"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: [
                                    { key: "dynamic", label: "Dinamik · Matugen" },
                                    { key: "gotham",  label: "Gotham · Brutalist" }
                                ]
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool active: (modelData.key === "gotham") ? Theme.isGotham : !Theme.isGotham
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    radius: Theme.radiusButton
                                    color: active ? Theme.surfaceActive : Theme.surface1
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: parent.active ? Theme.accent : Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: parent.active
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: WallpaperState.setThemePreset(modelData.key)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: Theme.radiusButton
                            color: wpOpenMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: wpOpenMa.containsMouse ? Theme.accent : Theme.borderSubtle
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "Duvar Kağıdı Galerisini Aç"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                            MouseArea {
                                id: wpOpenMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { SettingsState.close(); WallpaperState.openPicker() }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                        // Hareket Azaltma
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                Text { text: "Hareket ve Animasyonları Azalt"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: 54; implicitHeight: 22; radius: Theme.radiusButton
                                    color: SettingsState.reduceMotion ? Theme.surfaceActive : Theme.surface2
                                    border.color: SettingsState.reduceMotion ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: SettingsState.reduceMotion ? "Açık" : "Kapalı"; color: SettingsState.reduceMotion ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11 }
                                }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.reduceMotion = !SettingsState.reduceMotion; SettingsState.save() } }
                        }

                        // Ust Cubuk Gorunur
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                Text { text: "Üst Çubuk Görünür"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: 54; implicitHeight: 22; radius: Theme.radiusButton
                                    color: SettingsState.barVisible ? Theme.surfaceActive : Theme.surface2
                                    border.color: SettingsState.barVisible ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: SettingsState.barVisible ? "Açık" : "Kapalı"; color: SettingsState.barVisible ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11 }
                                }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.barVisible = !SettingsState.barVisible; SettingsState.save() } }
                        }

                        // Cubuk Yuksekligi
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 6
                                Text { text: "Üst Çubuk Yüksekliği"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: 26; implicitHeight: 22; radius: Theme.radiusButton
                                    color: Theme.surface2; border.color: Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(-1) }
                                }
                                Text { text: Theme.barHeight + " px"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 46 }
                                Rectangle {
                                    implicitWidth: 26; implicitHeight: 22; radius: Theme.radiusButton
                                    color: Theme.surface2; border.color: Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(1) }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // ── SEKME 2: UST CUBUK MODULLERI ─────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "bar"
                        spacing: 8

                        Text { text: "Üst Çubukta Gösterilecek Modüller"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 6
                            model: [
                                { prop: "showWorkspaces",    label: "Çalışma Alanları" },
                                { prop: "showClock",         label: "Saat, Tarih ve Hava Durumu" },
                                { prop: "showSystemStats",   label: "Sistem Telemetri — CPU / RAM / Disk" },
                                { prop: "showNetwork",       label: "Ağ ve Wi-Fi Göstergesi" },
                                { prop: "showVolume",        label: "Ses Düzeyi" },
                                { prop: "showPower",         label: "Güç ve Kontrol Merkezi" },
                                { prop: "showAi",            label: "Enyxma AI Asistan" },
                                { prop: "showNotifications", label: "Bildirim Merkezi" },
                                { prop: "showTray",          label: "Sistem Tepsisi" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool val: !!SettingsState[modelData.prop]
                                width: ListView.view.width
                                implicitHeight: 34
                                radius: Theme.radiusButton
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    Text { text: modelData.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                                    Rectangle {
                                        implicitWidth: 52; implicitHeight: 20; radius: Theme.radiusButton
                                        color: parent.parent.val ? Theme.surfaceActive : Theme.surface2
                                        border.color: parent.parent.val ? Theme.accent : Theme.borderSubtle; border.width: 1
                                        Text { anchors.centerIn: parent; text: parent.parent.parent.val ? "Açık" : "Kapalı"; color: parent.parent.parent.val ? Theme.accent : Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10 }
                                    }
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
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: searchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                            border.width: 1
                            TextInput {
                                id: searchInp
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                text: root.shortcutFilter
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                clip: true
                                onTextChanged: root.shortcutFilter = text
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Kısayol veya eylem ara..."
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    visible: parent.text.length === 0
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: root.filteredShortcuts
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                implicitHeight: 30
                                radius: Theme.radiusButton
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8
                                    Text { text: modelData.action; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Rectangle {
                                        implicitWidth: keyLbl.implicitWidth + 12
                                        implicitHeight: 20
                                        radius: Theme.radiusButton
                                        color: Theme.surfaceActive
                                        border.color: Theme.borderSubtle
                                        border.width: 1
                                        Text { id: keyLbl; anchors.centerIn: parent; text: modelData.keys; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
                                    }
                                }
                            }
                        }
                    }

                    // ── SEKME 4: SISTEM ──────────────────────────────────
                    ColumnLayout {
                        anchors.fill: parent
                        visible: SettingsState.activeTab === "system"
                        spacing: 10

                        Text { text: "Kalıcı Ayar Dosyası"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 10
                                text: SettingsState.configPath
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 34
                                radius: Theme.radiusButton
                                color: openCfgMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                                border.color: Theme.accent
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "Ayar Dosyasını Aç"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.bold: true }
                                MouseArea { id: openCfgMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.openConfigFile() }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 34
                                radius: Theme.radiusButton
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "Varsayılanlara Sıfırla"; color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
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
