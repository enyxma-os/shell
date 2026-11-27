import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * GothamSettingsPanel — Enyxma Gotham 2.0 masaustu kontrol merkezi.
 *
 * Deterministik anchors yerlesimi ile yan panel ve icerik alani
 * birbirinden kesin sinirlarla ayrilir; global ayar arama ve Geri Al seridi icerir.
 */
Item {
    id: root

    property string globalFilter: ""
    property string shortcutFilter: ""

    readonly property var navItems: {
        var _l = I18n.lang
        return [
            { key: "overview",   icon: "󰋜", label: I18n.t("GENEL BAKIŞ", "OVERVIEW"),         title: I18n.t("SİSTEM GENEL BAKIŞ", "SYSTEM OVERVIEW"),           subtitle: I18n.t("Donanım telemetrisi, aktif ekran ve hızlı ayar kısayolları", "Hardware telemetry, active display, and quick settings") },
            { key: "appearance", icon: "󰏘", label: I18n.t("GÖRÜNÜM", "APPEARANCE"),           title: I18n.t("GÖRÜNÜM VE PENCERE", "APPEARANCE & WINDOW"),       subtitle: I18n.t("Tasarım kimliği, canlı önizleme ve Hyprland pencere geometrisi", "Visual identity, live preview, and Hyprland window geometry") },
            { key: "bar",        icon: "󰕮", label: I18n.t("ÜST ÇUBUK", "TOP BAR"),             title: I18n.t("ÜST ÇUBUK MODÜLLERİ", "TOP BAR MODULES"),          subtitle: I18n.t("Panelde görünecek bileşenleri canlı olarak yönetin", "Toggle top bar components live") },
            { key: "display",    icon: "󰍹", label: I18n.t("EKRAN", "DISPLAY"),                title: I18n.t("EKRAN VE MONİTÖRLER", "DISPLAY & MONITORS"),       subtitle: I18n.t("Çözünürlük, yenileme hızı ve görüntü ölçeklendirme", "Resolution, refresh rate, and display scaling") },
            { key: "input",      icon: "󰌌", label: I18n.t("KLAVYE VE FARE", "INPUT"),         title: I18n.t("KLAVYE VE İŞARETÇİ", "KEYBOARD & POINTER"),       subtitle: I18n.t("Klavye düzeni, tuş tekrar hızı ve fare hassasiyeti", "Keyboard layout, repeat rate, and pointer sensitivity") },
            { key: "shortcuts",  icon: "󰘳", label: I18n.t("KISAYOLLAR", "SHORTCUTS"),         title: I18n.t("KLAVYE KISAYOLLARI", "KEYBOARD SHORTCUTS"),       subtitle: I18n.t("Aktif Hyprland tuş atamalarını arayın ve inceleyin", "Search and inspect active Hyprland keybindings") },
            { key: "system",     icon: "󰒓", label: I18n.t("SİSTEM", "SYSTEM"),                title: I18n.t("SİSTEM VE MODÜLLER", "SYSTEM & MODULES"),         subtitle: I18n.t("Arayüz dili, kalıcı yapılandırma ve yerleşik eklentiler", "Interface language, persistent config, and built-in modules") }
        ]
    }

    readonly property var barModules: {
        var _l = I18n.lang
        return [
            { prop: "showWorkspaces",    icon: "󰍹", label: I18n.t("ÇALIŞMA ALANLARI", "WORKSPACES"),         desc: I18n.t("Aktif ve dolu masaüstü numaraları", "Active and occupied workspace indicators") },
            { prop: "showClock",         icon: "󰥔", label: I18n.t("SAAT VE HAVA DURUMU", "CLOCK & WEATHER"),   desc: I18n.t("Tarih, saat ve canlı sıcaklık bilgisi", "Date, time, and live weather status") },
            { prop: "showSystemStats",   icon: "󰍛", label: I18n.t("SİSTEM TELEMETRİ", "SYSTEM TELEMETRY"),    desc: I18n.t("CPU, bellek ve disk kullanım özeti", "CPU, memory, and disk usage summary") },
            { prop: "showNetwork",       icon: "󰖩", label: I18n.t("AĞ VE WI-FI", "NETWORK & WI-FI"),          desc: I18n.t("Bağlantı durumu, VPN ve hız göstergesi", "Connection status, VPN, and speed indicator") },
            { prop: "showVolume",        icon: "󰕾", label: I18n.t("SES DÜZEYİ", "VOLUME"),                    desc: I18n.t("Ses karıştırıcı ve hızlı susturma", "Audio mixer and quick mute") },
            { prop: "showPower",         icon: "󰐥", label: I18n.t("GÜÇ VE KONTROL", "POWER & CONTROL"),       desc: I18n.t("Kontrol merkezi ve oturum eylemleri", "Control center and session actions") },
            { prop: "showAi",            icon: "󰧑", label: "ORACLE // AI",                                    desc: I18n.t("Yapay zeka kenar çubuğu kısayolu", "AI assistant sidebar shortcut") },
            { prop: "showNotifications", icon: "󰂚", label: I18n.t("BİLDİRİMLER", "NOTIFICATIONS"),            desc: I18n.t("Okunmamış uyarı sayacı ve geçmişi", "Unread alert counter and history") },
            { prop: "showTray",          icon: "󰀻", label: I18n.t("SİSTEM TEPSİSİ", "SYSTEM TRAY"),           desc: I18n.t("Arka plan uygulama simgeleri", "Background application icons") }
        ]
    }

    readonly property var pluginModules: {
        var _l = I18n.lang
        return [
            { prop: "enableAudioMixer",       icon: "󰓃", label: I18n.t("SES KARIŞTIRICI", "AUDIO MIXER"),           desc: I18n.t("Uygulama bazlı ses düzeyi kontrolü", "Per-application volume control") },
            { prop: "enableBluetoothPanel",   icon: "󰂯", label: I18n.t("BLUETOOTH YÖNETİCİSİ", "BLUETOOTH MANAGER"), desc: I18n.t("Cihaz eşleştirme ve pil takibi", "Device pairing and battery tracking") },
            { prop: "enableWifiQr",           icon: "󰐲", label: I18n.t("WI-FI QR PAYLAŞIMI", "WI-FI QR SHARING"),   desc: I18n.t("Aktif ağ için hızlı QR kodu üretimi", "Instant QR code generation for active Wi-Fi") },
            { prop: "enableFocusTimer",       icon: "󰔟", label: I18n.t("ODAK ZAMANLAYICI", "FOCUS TIMER"),         desc: I18n.t("Pomodoro çalışma ve mola sayacı", "Pomodoro work and break timer") },
            { prop: "enableContainerMonitor", icon: "󰡨", label: I18n.t("KONTEYNER İZLEYİCİ", "CONTAINER MONITOR"),  desc: I18n.t("Docker ve Podman servis durumu", "Docker and Podman container status") }
        ]
    }

    readonly property int activeBarModuleCount: {
        var count = 0
        for (var i = 0; i < barModules.length; i++) {
            if (SettingsState[barModules[i].prop]) count++
        }
        return count
    }

    readonly property var currentNav: {
        for (var i = 0; i < navItems.length; i++) {
            if (navItems[i].key === SettingsState.activeTab) return navItems[i]
        }
        return navItems[0]
    }

    readonly property var searchResults: {
        var q = root.globalFilter.trim().toLowerCase()
        if (q === "") return []
        var list = SettingsState.searchEntries || []
        var out = []
        for (var i = 0; i < list.length; i++) {
            var item = list[i]
            if (String(item.title).toLowerCase().indexOf(q) >= 0 ||
                String(item.keywords).toLowerCase().indexOf(q) >= 0) {
                out.push(item)
            }
        }
        return out
    }

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

    component GothamSwitch: EnyxmaSwitch {
        gotham: true
    }

    component GothamStepperRow: EnyxmaStepperRow {
        gotham: true
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 920)
        height: Math.min(parent.height - 72, 600)
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.accent
            z: 10
        }

        // ── SOL YAN PANEL ────────────────────────────────────────────────────
        Rectangle {
            id: sidebar
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 236
            color: Theme.bgDark

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                color: Theme.borderSubtle
            }

            Column {
                id: brandHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 18
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 3

                Text {
                    text: I18n.t("ENYXMA // AYARLAR", "ENYXMA // SETTINGS")
                    color: Theme.accent
                    font.family: Theme.fontDisplay
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Text {
                    text: I18n.t("MASAÜSTÜ KONTROL MERKEZİ", "DESKTOP CONTROL CENTER")
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.letterSpacing: 0.6
                }
            }

            // Global Ayar Arama Kutusu
            Rectangle {
                id: globalSearchBox
                anchors.top: brandHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 12
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 32
                radius: 0
                color: Theme.surface1
                border.color: globalSearchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 8
                    spacing: 6

                    Text {
                        text: "󰍉"
                        color: globalSearchInp.activeFocus ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                    }

                    TextInput {
                        id: globalSearchInp
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: TextInput.AlignVCenter
                        text: root.globalFilter
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        clip: true
                        onTextChanged: root.globalFilter = text

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: I18n.t("Ayar ara...", "Search settings...")
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            visible: parent.text.length === 0
                        }
                    }

                    Text {
                        visible: root.globalFilter.length > 0
                        text: "×"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 12

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: globalSearchInp.text = ""
                        }
                    }
                }
            }

            // Normal Navigasyon Listesi
            Column {
                visible: root.globalFilter.trim() === ""
                anchors.top: globalSearchBox.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 12
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 4

                Repeater {
                    model: root.navItems
                    delegate: Rectangle {
                        id: navBtn
                        required property var modelData
                        readonly property bool active: SettingsState.activeTab === modelData.key
                        width: parent.width
                        height: 36
                        radius: 0
                        color: active ? Theme.surfaceActive : (navMa.containsMouse ? Theme.surfaceHover : "transparent")
                        border.color: active ? Theme.borderFocus : "transparent"
                        border.width: 1

                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 2
                            color: Theme.accent
                            visible: navBtn.active
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 9

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: navBtn.modelData.icon
                                color: navBtn.active ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 13
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: navBtn.modelData.label
                                color: navBtn.active ? Theme.textPrimary : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: navBtn.active
                                font.letterSpacing: 0.5
                            }
                        }

                        MouseArea {
                            id: navMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SettingsState.activeTab = navBtn.modelData.key
                        }
                    }
                }
            }

            // Global Arama Sonuclari
            ListView {
                visible: root.globalFilter.trim() !== ""
                anchors.top: globalSearchBox.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: sidebarFooter.top
                anchors.topMargin: 10
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.bottomMargin: 8
                clip: true
                spacing: 4
                model: root.searchResults

                delegate: Rectangle {
                    id: srRow
                    required property var modelData
                    width: ListView.view.width
                    height: 36
                    radius: 0
                    color: srMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: srMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        text: srRow.modelData.title
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: srMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SettingsState.activeTab = srRow.modelData.tab
                            globalSearchInp.text = ""
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.searchResults.length === 0
                    text: I18n.t("Sonuç bulunamadı", "No results found")
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }
            }

            // Alt durum rozeti
            Column {
                id: sidebarFooter
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        implicitWidth: badgeText.implicitWidth + 12
                        implicitHeight: 20
                        radius: 0
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: "GOTHAM 2.0"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: I18n.t("ESC İLE KAPAT", "ESC TO CLOSE")
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                    }
                }
            }
        }

        // ── SAG ICERIK ALANI ─────────────────────────────────────────────────
        Item {
            id: contentPane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            clip: true

            Item {
                id: contentHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 62

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: closeBtn.left
                    anchors.leftMargin: 22
                    anchors.rightMargin: 12
                    spacing: 3

                    Text {
                        width: parent.width
                        text: root.currentNav.title
                        color: Theme.textPrimary
                        font.family: Theme.fontDisplay
                        font.pixelSize: 15
                        font.bold: true
                        font.letterSpacing: 0.8
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.currentNav.subtitle
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: closeBtn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: 28
                    height: 28
                    radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsState.close()
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }
            }

            Item {
                id: bodyArea
                anchors.top: contentHeader.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                clip: true

                // ── SEKME 1: GENEL BAKIS ─────────────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "overview"
                    contentHeight: overviewCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: overviewCol
                        width: parent.width
                        spacing: 12

                        Text {
                            text: I18n.t("DONANIM VE OTURUM ÖZETİ", "HARDWARE & SESSION SUMMARY")
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        GridLayout {
                            width: parent.width
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 8

                            Repeater {
                                model: {
                                    var _l = I18n.lang
                                    return [
                                        { label: I18n.t("İŞLEMCİ", "PROCESSOR"),  value: PerformanceState.cpuModel + " · " + I18n.pct(PerformanceState.cpuPercent) },
                                        { label: I18n.t("EKRAN KARTI", "GPU"), value: PerformanceState.gpuModel },
                                        { label: I18n.t("BELLEK", "MEMORY"),   value: PerformanceState.memUsedGiB.toFixed(1) + " / " + PerformanceState.memTotalGiB.toFixed(1) + " GiB · " + I18n.pct(PerformanceState.memPercent) },
                                        { label: I18n.t("DEPOLAMA", "STORAGE"), value: StorageState.rootMount + " · " + I18n.pct(StorageState.rootPercent) + " · " + StorageState.rootUsedGiB.toFixed(0) + " GiB" },
                                        { label: I18n.t("EKRAN", "DISPLAY"),    value: (SettingsState.monitors.length > 0) ? (SettingsState.monitors[0].name + " · " + SettingsState.monitors[0].width + "×" + SettingsState.monitors[0].height + " @ " + Math.round(SettingsState.monitors[0].refreshRate) + "Hz") : I18n.t("Algılanıyor", "Detecting") },
                                        { label: I18n.t("AĞ", "NETWORK"),       value: NetworkState.isConnected ? ((NetworkState.ssid || NetworkState.connectionName || I18n.t("Bağlı", "Connected")) + " · " + NetworkState.ipAddress) : I18n.t("Çevrimdışı", "Offline") }
                                    ]
                                }
                                delegate: Rectangle {
                                    id: ovCard
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 56
                                    radius: 0
                                    color: Theme.surface1
                                    border.color: Theme.borderSubtle
                                    border.width: 1

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.margins: 12
                                        spacing: 3

                                        Text {
                                            text: ovCard.modelData.label
                                            color: Theme.textMuted
                                            font.family: Theme.fontMono
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        Text {
                                            width: parent.width
                                            text: ovCard.modelData.value
                                            color: Theme.textPrimary
                                            font.family: Theme.fontMono
                                            font.pixelSize: 11
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text {
                            text: I18n.t("HIZLI ERİŞİM", "QUICK ACCESS")
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { tab: "appearance", icon: "󰏘", label: I18n.t("TEMA VE STİL", "THEME & STYLE") },
                                    { tab: "display",    icon: "󰍹", label: I18n.t("EKRAN AYARLARI", "DISPLAY SETTINGS") },
                                    { tab: "shortcuts",  icon: "󰘳", label: I18n.t("KISAYOLLAR", "SHORTCUTS") }
                                ]
                                delegate: Rectangle {
                                    id: qBtn
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 42
                                    radius: 0
                                    color: qMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                    border.color: qMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Text { text: qBtn.modelData.icon; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 14 }
                                        Text { text: qBtn.modelData.label; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                    }

                                    MouseArea {
                                        id: qMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SettingsState.activeTab = qBtn.modelData.tab
                                    }
                                }
                            }
                        }
                    }
                }

                // ── SEKME 2: GORUNUM VE PENCERE ──────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "appearance"
                    contentHeight: appearanceCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: appearanceCol
                        width: parent.width
                        spacing: 12

                        Text {
                            text: I18n.t("TASARIM KİMLİĞİ", "DESIGN IDENTITY")
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: [
                                    { key: "dynamic", title: I18n.t("DİNAMİK · MATUGEN", "DYNAMIC · MATUGEN"),  desc: I18n.t("Duvar kağıdından türetilen yumuşak renkler", "Adaptive colors extracted from your wallpaper") },
                                    { key: "gotham",  title: "GOTHAM · BRUTALIST", desc: I18n.t("Keskin köşeler, koyu yüzey ve kehribar vurgu", "Sharp corners, dark obsidian surfaces, and amber accents") }
                                ]
                                delegate: Rectangle {
                                    id: themeCard
                                    required property var modelData
                                    readonly property bool active: (modelData.key === "gotham") ? Theme.isGotham : !Theme.isGotham
                                    Layout.fillWidth: true
                                    implicitHeight: 70
                                    radius: 0
                                    color: active ? Theme.surfaceActive : (themeMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 5

                                        RowLayout {
                                            width: parent.width
                                            spacing: 6

                                            Text {
                                                text: themeCard.modelData.title
                                                color: themeCard.active ? Theme.accent : Theme.textPrimary
                                                font.family: Theme.fontMono
                                                font.pixelSize: 11
                                                font.bold: true
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                visible: themeCard.active
                                                implicitWidth: activeLbl.implicitWidth + 10
                                                implicitHeight: 18
                                                radius: 0
                                                color: Theme.accent

                                                Text { id: activeLbl; anchors.centerIn: parent; text: I18n.t("AKTİF", "ACTIVE"); color: Theme.accentOn; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
                                            }
                                        }

                                        Text {
                                            width: parent.width
                                            text: themeCard.modelData.desc
                                            color: Theme.textSecondary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: themeMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: WallpaperState.setThemePreset(themeCard.modelData.key)
                                    }
                                }
                            }
                        }

                        // Kompakt Enyxma Canli Onizleme
                        Rectangle {
                            width: parent.width
                            height: 54
                            radius: 0
                            color: Theme.bgDark
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Text {
                                    text: I18n.t("CANLI ÖNİZLEME", "LIVE PREVIEW")
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    implicitWidth: 36
                                    implicitHeight: 24
                                    radius: SettingsState.customHyprStyle ? Math.min(8, SettingsState.hyprRounding) : Theme.radiusSmall
                                    color: Theme.surface1
                                    border.color: Theme.accent
                                    border.width: SettingsState.customHyprStyle ? Math.max(1, SettingsState.hyprBorderSize) : 1
                                }

                                GothamSwitch { checked: true }

                                Rectangle {
                                    implicitWidth: 86
                                    implicitHeight: 26
                                    radius: 0
                                    color: Theme.accent

                                    Text {
                                        anchors.centerIn: parent
                                        text: I18n.t("ÖRNEK EYLEM", "SAMPLE ACTION")
                                        color: Theme.accentOn
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Duvar kagidi galerisi karti
                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 0
                            color: wpMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Text { text: "󰸉"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 18 }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text { text: I18n.t("DUVAR KAĞIDI GALERİSİ", "WALLPAPER GALLERY"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Arka plan görselini değiştirin ve renk paletini yenileyin", "Change wallpaper and refresh theme palette"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                }

                                Rectangle {
                                    implicitWidth: 68
                                    implicitHeight: 26
                                    radius: 0
                                    color: Theme.surface2
                                    border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text { anchors.centerIn: parent; text: I18n.t("AÇ →", "OPEN →"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                }
                            }

                            MouseArea {
                                id: wpMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { SettingsState.close(); WallpaperState.openPicker() }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        RowLayout {
                            width: parent.width

                            Text {
                                text: I18n.t("HYPRLAND PENCERE GEOMETRİSİ", "HYPRLAND WINDOW GEOMETRY")
                                color: Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 0.8
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                visible: SettingsState.customHyprStyle
                                implicitWidth: 118
                                implicitHeight: 22
                                radius: 0
                                color: rstHyprMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1

                                Text { anchors.centerIn: parent; text: I18n.t("TEMA VARSAYILANI", "THEME DEFAULT"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
                                MouseArea { id: rstHyprMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetHyprStyle() }
                            }
                        }

                        GothamStepperRow {
                            title: I18n.t("KÖŞE YUVARLAKLIĞI", "CORNER RADIUS")
                            subtitle: I18n.t("Pencere köşelerinin piksel cinsinden yumuşaklığı", "Window corner rounding in pixels")
                            valueText: SettingsState.hyprRounding + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprRounding", Math.max(0, SettingsState.hyprRounding - 2), I18n.t("Köşe yuvarlaklığı güncellendi", "Corner radius updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprRounding", Math.min(24, SettingsState.hyprRounding + 2), I18n.t("Köşe yuvarlaklığı güncellendi", "Corner radius updated"))
                        }

                        GothamStepperRow {
                            title: I18n.t("İÇ PENCERE BOŞLUĞU", "INNER GAPS")
                            subtitle: I18n.t("Yan yana pencereler arasındaki mesafe", "Spacing between tiled windows")
                            valueText: SettingsState.hyprGapsIn + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsIn", Math.max(0, SettingsState.hyprGapsIn - 2), I18n.t("İç boşluk güncellendi", "Inner gaps updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprGapsIn", Math.min(24, SettingsState.hyprGapsIn + 2), I18n.t("İç boşluk güncellendi", "Inner gaps updated"))
                        }

                        GothamStepperRow {
                            title: I18n.t("DIŞ KENAR BOŞLUĞU", "OUTER GAPS")
                            subtitle: I18n.t("Pencereler ile ekran kenarı arasındaki mesafe", "Spacing between windows and screen edge")
                            valueText: SettingsState.hyprGapsOut + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsOut", Math.max(0, SettingsState.hyprGapsOut - 2), I18n.t("Dış boşluk güncellendi", "Outer gaps updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprGapsOut", Math.min(32, SettingsState.hyprGapsOut + 2), I18n.t("Dış boşluk güncellendi", "Outer gaps updated"))
                        }

                        GothamStepperRow {
                            title: I18n.t("KENARLIK KALINLIĞI", "BORDER WIDTH")
                            subtitle: I18n.t("Aktif ve pasif pencere çerçeve kalınlığı", "Active and inactive window border thickness")
                            valueText: SettingsState.hyprBorderSize + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprBorderSize", Math.max(0, SettingsState.hyprBorderSize - 1), I18n.t("Kenarlık kalınlığı güncellendi", "Border width updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprBorderSize", Math.min(6, SettingsState.hyprBorderSize + 1), I18n.t("Kenarlık kalınlığı güncellendi", "Border width updated"))
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 0
                            color: blurMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("PENCERE BULANIKLIĞI", "WINDOW BLUR"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Saydam pencerelerin arkasındaki bulanıklık efektini açar", "Enable background blur behind translucent windows"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprBlur }
                            }
                            MouseArea { id: blurMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprBlur", !SettingsState.hyprBlur, I18n.t("Bulanıklık güncellendi", "Blur updated")) }
                        }

                        GothamStepperRow {
                            title: I18n.t("AKTİF PENCERE OPAKLIĞI", "ACTIVE OPACITY")
                            subtitle: I18n.t("Odaktaki pencerenin saydamlık oranı", "Opacity of the focused window")
                            valueText: Math.round(SettingsState.hyprActiveOpacity * 100) + "%"
                            onDecrement: SettingsState.setHyprSetting("hyprActiveOpacity", Math.max(0.75, Math.round((SettingsState.hyprActiveOpacity - 0.05) * 100) / 100), I18n.t("Aktif opaklık güncellendi", "Active opacity updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprActiveOpacity", Math.min(1.00, Math.round((SettingsState.hyprActiveOpacity + 0.05) * 100) / 100), I18n.t("Aktif opaklık güncellendi", "Active opacity updated"))
                        }

                        GothamStepperRow {
                            title: I18n.t("PASİF PENCERE OPAKLIĞI", "INACTIVE OPACITY")
                            subtitle: I18n.t("Arka plandaki pencerelerin saydamlık oranı", "Opacity of unfocused windows")
                            valueText: Math.round(SettingsState.hyprInactiveOpacity * 100) + "%"
                            onDecrement: SettingsState.setHyprSetting("hyprInactiveOpacity", Math.max(0.70, Math.round((SettingsState.hyprInactiveOpacity - 0.05) * 100) / 100), I18n.t("Pasif opaklık güncellendi", "Inactive opacity updated"))
                            onIncrement: SettingsState.setHyprSetting("hyprInactiveOpacity", Math.min(1.00, Math.round((SettingsState.hyprInactiveOpacity + 0.05) * 100) / 100), I18n.t("Pasif opaklık güncellendi", "Inactive opacity updated"))
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: shadowMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("PENCERE GÖLGESİ", "WINDOW SHADOW"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Pencerelerin altında derinlik gölgesi oluşturur", "Render drop shadows beneath windows"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprShadow }
                            }
                            MouseArea { id: shadowMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprShadow", !SettingsState.hyprShadow, I18n.t("Pencere gölgesi güncellendi", "Window shadow updated")) }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: animMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("HYPRLAND ANİMASYONLARI", "HYPRLAND ANIMATIONS"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Pencere açılış ve çalışma alanı geçiş efektlerini kontrol eder", "Toggle window and workspace transition animations"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprAnimations }
                            }
                            MouseArea { id: animMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprAnimations", !SettingsState.hyprAnimations, I18n.t("Hyprland animasyonları güncellendi", "Hyprland animations updated")) }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text {
                            text: I18n.t("DAVRANIŞ VE ÇUBUK GEOMETRİSİ", "BEHAVIOR & BAR GEOMETRY")
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: rmMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("HAREKET VE ANİMASYONLARI AZALT", "REDUCE MOTION"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Panel geçişleri ve açılış animasyonlarını anlık hale getirir", "Make panel transitions instant"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.reduceMotion }
                            }
                            MouseArea { id: rmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("reduceMotion", I18n.t("Hareket tercihi güncellendi", "Motion preference updated")) }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: bvMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("ÜST ÇUBUK GÖRÜNÜR", "TOP BAR VISIBLE"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Ekranın üstündeki Enyxma durum çubuğunu gösterir veya gizler", "Show or hide the Enyxma top status bar"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.barVisible }
                            }
                            MouseArea { id: bvMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("barVisible", I18n.t("Üst çubuk görünürlüğü güncellendi", "Top bar visibility updated")) }
                        }

                        GothamStepperRow {
                            title: I18n.t("ÜST ÇUBUK YÜKSEKLİĞİ", "TOP BAR HEIGHT")
                            subtitle: I18n.t("Üst panelin piksel cinsinden dikey kalınlığı", "Vertical height offset of the top bar")
                            valueText: Theme.barHeight + " px"
                            onDecrement: SettingsState.adjustBarHeight(-1)
                            onIncrement: SettingsState.adjustBarHeight(1)
                        }
                    }
                }

                // ── SEKME 3: UST CUBUK MODULLERI ─────────────────────────────
                Item {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "bar"

                    RowLayout {
                        id: barSummaryRow
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 22

                        Text { text: I18n.t("AKTİF MODÜLLER", "ACTIVE MODULES"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                        Text { text: root.activeBarModuleCount + " / " + root.barModules.length + I18n.t(" aktif", " active"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                    }

                    ListView {
                        anchors.top: barSummaryRow.bottom; anchors.topMargin: 10
                        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                        clip: true; spacing: 6; boundsBehavior: Flickable.StopAtBounds
                        model: root.barModules

                        delegate: Rectangle {
                            id: barRow
                            required property var modelData
                            readonly property bool isOn: !!SettingsState[modelData.prop]
                            width: ListView.view.width; height: 48; radius: 0
                            color: barRowMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Text { text: barRow.modelData.icon; color: barRow.isOn ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 15 }
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { width: parent.width; text: barRow.modelData.label; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                    Text { width: parent.width; text: barRow.modelData.desc; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                                GothamSwitch { checked: barRow.isOn }
                            }

                            MouseArea {
                                id: barRowMa
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsState.toggleBoolSetting(barRow.modelData.prop, barRow.modelData.label + I18n.t(" güncellendi", " updated"))
                            }
                        }
                    }
                }

                // ── SEKME 4: EKRAN VE MONITORLER ─────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "display"
                    contentHeight: displayCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: displayCol
                        width: parent.width
                        spacing: 12

                        RowLayout {
                            width: parent.width
                            Text { text: I18n.t("BAĞLI MONİTÖRLER", "CONNECTED MONITORS"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                implicitWidth: 74; implicitHeight: 24; radius: 0
                                color: refMonMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: refMonMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: I18n.t("↻ YENİLE", "↻ REFRESH"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                MouseArea { id: refMonMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.refreshMonitors() }
                            }
                        }

                        Repeater {
                            model: SettingsState.monitors
                            delegate: Rectangle {
                                id: monCard
                                required property var modelData
                                width: displayCol.width
                                height: monCol.implicitHeight + 24
                                radius: 0
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1

                                Column {
                                    id: monCol
                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                    anchors.margins: 12
                                    spacing: 10

                                    RowLayout {
                                        width: parent.width
                                        Text {
                                            text: monCard.modelData.name + " · " + monCard.modelData.model
                                            color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 12; font.bold: true
                                            Layout.fillWidth: true; elide: Text.ElideRight
                                        }
                                        Text {
                                            text: monCard.modelData.width + "×" + monCard.modelData.height + " @ " + Math.round(monCard.modelData.refreshRate) + "Hz · " + Number(monCard.modelData.scale).toFixed(2) + "x"
                                            color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true
                                        }
                                    }

                                    Text { text: I18n.t("ÇÖZÜNÜRLÜK VE YENİLEME HIZI", "RESOLUTION & REFRESH RATE"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }

                                    Flow {
                                        width: parent.width
                                        spacing: 6
                                        Repeater {
                                            model: monCard.modelData.modes
                                            delegate: Rectangle {
                                                id: modeChip
                                                required property var modelData
                                                readonly property bool isCur: (monCard.modelData.width + "x" + monCard.modelData.height + "@" + Math.round(monCard.modelData.refreshRate)) === modelData.spec
                                                implicitWidth: modeLbl.implicitWidth + 16
                                                implicitHeight: 26
                                                radius: 0
                                                color: isCur ? Theme.surfaceActive : (modeMa.containsMouse ? Theme.surfaceHover : Theme.surface2)
                                                border.color: isCur ? Theme.accent : Theme.borderSubtle
                                                border.width: 1

                                                Text { id: modeLbl; anchors.centerIn: parent; text: modeChip.modelData.label; color: modeChip.isCur ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10 }
                                                MouseArea {
                                                    id: modeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: SettingsState.applyMonitorMode(monCard.modelData.name, modeChip.modelData.spec, monCard.modelData.x, monCard.modelData.y, monCard.modelData.scale)
                                                }
                                            }
                                        }
                                    }

                                    Text { text: I18n.t("GÖRÜNTÜ ÖLÇEĞİ", "DISPLAY SCALE"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }

                                    RowLayout {
                                        width: parent.width
                                        spacing: 6
                                        Repeater {
                                            model: [ 1.0, 1.25, 1.5, 2.0 ]
                                            delegate: Rectangle {
                                                id: scaleChip
                                                required property real modelData
                                                readonly property bool isCur: Math.abs(monCard.modelData.scale - modelData) < 0.05
                                                Layout.fillWidth: true
                                                implicitHeight: 28
                                                radius: 0
                                                color: isCur ? Theme.surfaceActive : (scaleMa.containsMouse ? Theme.surfaceHover : Theme.surface2)
                                                border.color: isCur ? Theme.accent : Theme.borderSubtle
                                                border.width: 1

                                                Text { anchors.centerIn: parent; text: Number(scaleChip.modelData).toFixed(2) + "x"; color: scaleChip.isCur ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: scaleChip.isCur }
                                                MouseArea {
                                                    id: scaleMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: SettingsState.setMonitorScale(monCard.modelData.name, monCard.modelData.width, monCard.modelData.height, monCard.modelData.refreshRate, monCard.modelData.x, monCard.modelData.y, scaleChip.modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: I18n.t("ADAPTİF YENİLEME // VRR", "ADAPTIVE SYNC // VRR"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { mode: 0, label: I18n.t("KAPALI", "OFF") },
                                    { mode: 1, label: I18n.t("HER ZAMAN", "ALWAYS") },
                                    { mode: 2, label: I18n.t("TAM EKRAN", "FULLSCREEN") }
                                ]
                                delegate: Rectangle {
                                    id: vrrChip
                                    required property var modelData
                                    readonly property bool active: SettingsState.hyprVrr === modelData.mode
                                    Layout.fillWidth: true; implicitHeight: 32; radius: 0
                                    color: active ? Theme.surfaceActive : (vrrMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: vrrChip.modelData.label; color: vrrChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: vrrChip.active }
                                    MouseArea { id: vrrMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.applyVrr(vrrChip.modelData.mode) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: I18n.t("GECE IŞIĞI // HYPRSUNSET", "NIGHT LIGHT // HYPRSUNSET"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: nlMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("GECE IŞIĞI FİLTRESİ", "NIGHT LIGHT FILTER"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Mavi ışığı azaltarak göz yorgunluğunu düşürür", "Reduces blue light to ease eye strain"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.nightLightEnabled }
                            }
                            MouseArea { id: nlMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleNightLight() }
                        }

                        GothamStepperRow {
                            title: I18n.t("RENK SICAKLIĞI", "COLOR TEMPERATURE")
                            subtitle: I18n.t("Düşük Kelvin değeri daha sıcak kehribar tonu verir", "Lower Kelvin values produce warmer amber tones")
                            valueText: SettingsState.nightLightTemp + " K"
                            onDecrement: SettingsState.setNightLightTemp(SettingsState.nightLightTemp - 250)
                            onIncrement: SettingsState.setNightLightTemp(SettingsState.nightLightTemp + 250)
                        }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { temp: 3500, label: I18n.t("3500K · SICAK", "3500K · WARM") },
                                    { temp: 4500, label: I18n.t("4500K · DENGELİ", "4500K · BALANCED") },
                                    { temp: 5500, label: I18n.t("5500K · HAFİF", "5500K · MILD") }
                                ]
                                delegate: Rectangle {
                                    id: nlPreset
                                    required property var modelData
                                    readonly property bool active: SettingsState.nightLightTemp === modelData.temp
                                    Layout.fillWidth: true; implicitHeight: 30; radius: 0
                                    color: active ? Theme.surfaceActive : (nlPMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: nlPreset.modelData.label; color: nlPreset.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: nlPreset.active }
                                    MouseArea { id: nlPMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setNightLightTemp(nlPreset.modelData.temp) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: I18n.t("GÜÇ VE OTOMATİK KİLİT // HYPRIDLE", "POWER & AUTO LOCK // HYPRIDLE"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: idleEnMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("OTOMATİK KİLİT VE UYKU", "AUTO LOCK & SLEEP"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Etkinlik olmadığında ekran kilidi ve güç tasarrufu uygular", "Locks screen and manages display power when idle"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.idleEnabled }
                            }
                            MouseArea { id: idleEnMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleEnabled", !SettingsState.idleEnabled, I18n.t("Otomatik kilit durumu güncellendi", "Auto-lock state updated")) }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: I18n.t("EKRANI KİLİTLE", "LOCK SCREEN"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 3, 5, 10, 15 ]
                                delegate: Rectangle {
                                    id: lockChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleLockMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (lockMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: lockChip.modelData === 0 ? I18n.t("KAPALI", "OFF") : (lockChip.modelData + I18n.t(" DK", " MIN")); color: lockChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: lockChip.active }
                                    MouseArea { id: lockMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleLockMin", lockChip.modelData, I18n.t("Kilit süresi güncellendi", "Lock timeout updated")) }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: I18n.t("EKRANI KAPAT", "SCREEN OFF"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 5, 10, 15, 30 ]
                                delegate: Rectangle {
                                    id: dpmsChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleScreenOffMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (dpmsMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: dpmsChip.modelData === 0 ? I18n.t("KAPALI", "OFF") : (dpmsChip.modelData + I18n.t(" DK", " MIN")); color: dpmsChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: dpmsChip.active }
                                    MouseArea { id: dpmsMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleScreenOffMin", dpmsChip.modelData, I18n.t("Ekran kapatma süresi güncellendi", "Screen-off timeout updated")) }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: I18n.t("SİSTEMİ UYUT", "SUSPEND SYSTEM"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 15, 30, 60 ]
                                delegate: Rectangle {
                                    id: suspChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleSuspendMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (suspMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: suspChip.modelData === 0 ? I18n.t("KAPALI", "OFF") : (suspChip.modelData + I18n.t(" DK", " MIN")); color: suspChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: suspChip.active }
                                    MouseArea { id: suspMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleSuspendMin", suspChip.modelData, I18n.t("Uyku süresi güncellendi", "Suspend timeout updated")) }
                                }
                            }
                        }
                    }
                }

                // ── SEKME 5: KLAVYE VE FARE ──────────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "input"
                    contentHeight: inputCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: inputCol
                        width: parent.width
                        spacing: 12

                        Text { text: I18n.t("KLAVYE DÜZENİ", "KEYBOARD LAYOUT"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { code: "tr",    label: "TR · TÜRKÇE Q" },
                                    { code: "us",    label: I18n.t("US · İNGİLİZCE", "US · ENGLISH") },
                                    { code: "tr,us", label: "TR + US" },
                                    { code: "de",    label: I18n.t("DE · ALMANCA", "DE · GERMAN") }
                                ]
                                delegate: Rectangle {
                                    id: kbChip
                                    required property var modelData
                                    readonly property bool active: SettingsState.kbLayout === modelData.code
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    radius: 0
                                    color: active ? Theme.surfaceActive : (kbMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text { anchors.centerIn: parent; text: kbChip.modelData.label; color: kbChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: kbChip.active }
                                    MouseArea { id: kbMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setInputSetting("kbLayout", kbChip.modelData.code, I18n.t("Klavye düzeni değişti", "Keyboard layout changed")) }
                                }
                            }
                        }

                        GothamStepperRow {
                            title: I18n.t("TUŞ TEKRAR HIZI", "REPEAT RATE")
                            subtitle: I18n.t("Basılı tutulan tuşun saniyedeki tekrar sayısı", "Key repeats per second while held")
                            valueText: SettingsState.kbRepeatRate + " /sn"
                            onDecrement: SettingsState.setInputSetting("kbRepeatRate", Math.max(15, SettingsState.kbRepeatRate - 5), I18n.t("Tekrar hızı güncellendi", "Repeat rate updated"))
                            onIncrement: SettingsState.setInputSetting("kbRepeatRate", Math.min(80, SettingsState.kbRepeatRate + 5), I18n.t("Tekrar hızı güncellendi", "Repeat rate updated"))
                        }

                        GothamStepperRow {
                            title: I18n.t("TUŞ TEKRAR GECİKMESİ", "REPEAT DELAY")
                            subtitle: I18n.t("Tekrar başlamadan önce beklenecek süre", "Delay before key repeat starts")
                            valueText: SettingsState.kbRepeatDelay + " ms"
                            onDecrement: SettingsState.setInputSetting("kbRepeatDelay", Math.max(150, SettingsState.kbRepeatDelay - 50), I18n.t("Tekrar gecikmesi güncellendi", "Repeat delay updated"))
                            onIncrement: SettingsState.setInputSetting("kbRepeatDelay", Math.min(600, SettingsState.kbRepeatDelay + 50), I18n.t("Tekrar gecikmesi güncellendi", "Repeat delay updated"))
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: I18n.t("FARE VE DOKUNMATİK YÜZEY", "MOUSE & TOUCHPAD"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        GothamStepperRow {
                            title: I18n.t("FARE HASSASİYETİ", "POINTER SENSITIVITY")
                            subtitle: I18n.t("Hyprland işaretçi hız çarpanı", "Hyprland pointer speed multiplier")
                            valueText: SettingsState.mouseSensitivity.toFixed(1)
                            onDecrement: SettingsState.setInputSetting("mouseSensitivity", Math.max(-0.8, Math.round((SettingsState.mouseSensitivity - 0.1) * 10) / 10), I18n.t("Fare hassasiyeti güncellendi", "Pointer sensitivity updated"))
                            onIncrement: SettingsState.setInputSetting("mouseSensitivity", Math.min(0.8, Math.round((SettingsState.mouseSensitivity + 0.1) * 10) / 10), I18n.t("Fare hassasiyeti güncellendi", "Pointer sensitivity updated"))
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: nsMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("DOĞAL KAYDIRMA", "NATURAL SCROLLING"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Dokunmatik yüzeyde içerik yönünü parmak hareketiyle eşler", "Reverses scroll direction on touchpads"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.naturalScroll }
                            }
                            MouseArea { id: nsMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setInputSetting("naturalScroll", !SettingsState.naturalScroll, I18n.t("Doğal kaydırma güncellendi", "Natural scrolling updated")) }
                        }
                    }
                }

                // ── SEKME 6: KISAYOLLAR ──────────────────────────────────────
                Item {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "shortcuts"

                    Rectangle {
                        id: searchBox
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 36; radius: 0; color: Theme.surface1
                        border.color: searchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle; border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; spacing: 8
                            Text { text: "󰍉"; color: searchInp.activeFocus ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 14 }
                            TextInput {
                                id: searchInp; Layout.fillWidth: true; Layout.fillHeight: true; verticalAlignment: TextInput.AlignVCenter
                                text: root.shortcutFilter; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; clip: true
                                onTextChanged: root.shortcutFilter = text
                                Text { anchors.verticalCenter: parent.verticalCenter; text: I18n.t("Kısayol veya eylem ara...", "Search shortcuts or actions..."); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11; visible: parent.text.length === 0 }
                            }
                            Text {
                                visible: root.shortcutFilter.length > 0; text: "×"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 13
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: searchInp.text = "" }
                            }
                        }
                    }

                    ListView {
                        anchors.top: searchBox.bottom; anchors.topMargin: 10; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                        clip: true; spacing: 4; boundsBehavior: Flickable.StopAtBounds
                        model: root.filteredShortcuts

                        delegate: Rectangle {
                            id: scRow
                            required property var modelData
                            width: ListView.view.width; height: 36; radius: 0; color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                Text { text: scRow.modelData.action; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: keyText.implicitWidth + 14; implicitHeight: 22; radius: 0; color: Theme.surfaceActive; border.color: Theme.borderSubtle; border.width: 1
                                    Text { id: keyText; anchors.centerIn: parent; text: scRow.modelData.keys; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                }
                            }
                        }

                        Text { anchors.centerIn: parent; visible: root.filteredShortcuts.length === 0; text: I18n.t("Eşleşen kısayol bulunamadı", "No matching shortcuts found"); color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 12 }
                    }
                }

                // ── SEKME 7: SISTEM ──────────────────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "system"
                    contentHeight: systemCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: systemCol
                        width: parent.width
                        spacing: 12

                        Text { text: I18n.t("ARAYÜZ DİLİ // INTERFACE LANGUAGE", "INTERFACE LANGUAGE"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { code: "tr", label: "TÜRKÇE" },
                                    { code: "en", label: "ENGLISH" }
                                ]
                                delegate: Rectangle {
                                    id: langChip
                                    required property var modelData
                                    readonly property bool active: SettingsState.language === modelData.code
                                    Layout.fillWidth: true; implicitHeight: 34; radius: 0
                                    color: active ? Theme.surfaceActive : (langMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: langChip.modelData.label; color: langChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: langChip.active }
                                    MouseArea { id: langMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setLanguage(langChip.modelData.code) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: I18n.t("KALICI AYAR DOSYASI", "PERSISTENT CONFIG FILE"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 40; radius: 0; color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                                Text { text: "󰈔"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 14 }
                                Text { Layout.fillWidth: true; text: SettingsState.configPath; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideMiddle }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 10
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 36; radius: 0
                                color: openCfgMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive; border.color: Theme.accent; border.width: 1
                                Text { anchors.centerIn: parent; text: I18n.t("AYAR DOSYASINI AÇ", "OPEN CONFIG FILE"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                MouseArea { id: openCfgMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.openConfigFile() }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 36; radius: 0
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: I18n.t("VARSAYILANLARA SIFIRLA", "RESET TO DEFAULTS"); color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: resetMa.containsMouse }
                                MouseArea { id: resetMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetDefaults() }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: I18n.t("YERLEŞİK EKLENTİ MODÜLLERİ", "BUILT-IN MODULE TOGGLES"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Repeater {
                            model: root.pluginModules
                            delegate: Rectangle {
                                id: pluginRow
                                required property var modelData
                                readonly property bool isOn: !!SettingsState[modelData.prop]
                                width: systemCol.width; height: 48; radius: 0
                                color: pluginMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: pluginRow.modelData.icon; color: pluginRow.isOn ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 15 }
                                    Column {
                                        Layout.fillWidth: true; spacing: 2
                                        Text { width: parent.width; text: pluginRow.modelData.label; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                        Text { width: parent.width; text: pluginRow.modelData.desc; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    GothamSwitch { checked: pluginRow.isOn }
                                }
                                MouseArea {
                                    id: pluginMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsState.toggleBoolSetting(pluginRow.modelData.prop, pluginRow.modelData.label + I18n.t(" güncellendi", " updated"))
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: I18n.t("BİLDİRİM TERCİHLERİ", "NOTIFICATION PREFERENCES"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: dndMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: I18n.t("RAHATSIZ ETME MODU", "DO NOT DISTURB"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: I18n.t("Açılır bildirimleri susturup yalnızca geçmişe kaydeder", "Silences popup toasts and keeps history"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: NotificationState.dnd }
                            }
                            MouseArea { id: dndMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: NotificationState.dnd = !NotificationState.dnd }
                        }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [ 3, 5, 8, 12 ]
                                delegate: Rectangle {
                                    id: ntChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.notifTimeoutSec === modelData
                                    Layout.fillWidth: true; implicitHeight: 30; radius: 0
                                    color: active ? Theme.surfaceActive : (ntMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: ntChip.modelData + I18n.t(" SN", " S"); color: ntChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: ntChip.active }
                                    MouseArea { id: ntMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setNotifTimeout(ntChip.modelData) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: I18n.t("VARSAYILAN UYGULAMALAR", "DEFAULT APPLICATIONS"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Text { text: I18n.t("TERMİNAL", "TERMINAL"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 110 }
                            Repeater {
                                model: [ "kitty", "foot" ]
                                delegate: Rectangle {
                                    id: termChip
                                    required property string modelData
                                    readonly property bool active: SettingsState.defaultTerminal === modelData
                                    Layout.fillWidth: true; implicitHeight: 30; radius: 0
                                    color: active ? Theme.surfaceActive : (termMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: termChip.modelData.toUpperCase(); color: termChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: termChip.active }
                                    MouseArea { id: termMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setDefaultApp("defaultTerminal", termChip.modelData, I18n.t("Varsayılan terminal güncellendi", "Default terminal updated")) }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Text { text: I18n.t("DOSYA YÖNETİCİSİ", "FILE MANAGER"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 110 }
                            Repeater {
                                model: [ "nautilus", "yazi", "thunar" ]
                                delegate: Rectangle {
                                    id: fmChip
                                    required property string modelData
                                    readonly property bool active: SettingsState.defaultFileManager === modelData
                                    Layout.fillWidth: true; implicitHeight: 30; radius: 0
                                    color: active ? Theme.surfaceActive : (fmMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: fmChip.modelData.toUpperCase(); color: fmChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: fmChip.active }
                                    MouseArea { id: fmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setDefaultApp("defaultFileManager", fmChip.modelData, I18n.t("Varsayılan dosya yöneticisi güncellendi", "Default file manager updated")) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        RowLayout {
                            width: parent.width
                            Text { text: I18n.t("YEREL EKLENTİ YUVASI", "LOCAL PLUGIN SLOT"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                implicitWidth: 92; implicitHeight: 24; radius: 0
                                color: plOpenMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: plOpenMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: I18n.t("KLASÖRÜ AÇ", "OPEN FOLDER"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
                                MouseArea { id: plOpenMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: PluginState.openPluginsDir() }
                            }
                            Rectangle {
                                implicitWidth: 64; implicitHeight: 24; radius: 0
                                color: plRefMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: plRefMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: I18n.t("YENİLE", "REFRESH"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
                                MouseArea { id: plRefMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: PluginState.refresh() }
                            }
                        }

                        Rectangle {
                            width: parent.width; height: 42; radius: 0
                            visible: PluginState.plugins.length === 0
                            color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("Özel eklenti bulunamadı · ", "No local plugins found · ") + PluginState.pluginsDir
                                color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10; elide: Text.ElideMiddle; width: parent.width - 20; horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Repeater {
                            model: PluginState.plugins
                            delegate: Rectangle {
                                id: lpRow
                                required property var modelData
                                readonly property bool isOn: SettingsState.isPluginEnabled(modelData.id)
                                width: systemCol.width; height: 48; radius: 0
                                color: lpMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: "󰏗"; color: lpRow.isOn ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 15 }
                                    Column {
                                        Layout.fillWidth: true; spacing: 2
                                        Text { width: parent.width; text: lpRow.modelData.name; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                        Text { width: parent.width; text: lpRow.modelData.description; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    GothamSwitch { checked: lpRow.isOn }
                                }
                                MouseArea {
                                    id: lpMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsState.togglePluginEnabled(lpRow.modelData.id, lpRow.modelData.name)
                                }
                            }
                        }
                    }
                }
            }

            // ── YUZEN GERI AL / UNDO SERIDI ──────────────────────────────────
            Rectangle {
                visible: SettingsState.undoLabel !== ""
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                height: 38
                radius: 0
                color: Theme.bgDark
                border.color: Theme.accent
                border.width: 1
                z: 20

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: SettingsState.undoLabel
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 76
                        implicitHeight: 24
                        radius: 0
                        color: undoMa.containsMouse ? Theme.accent : Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: I18n.t("GERİ AL", "UNDO")
                            color: undoMa.containsMouse ? Theme.accentOn : Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            id: undoMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SettingsState.undoLast()
                        }
                    }
                }
            }
        }
    }
}
