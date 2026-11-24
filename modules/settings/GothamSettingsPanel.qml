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

    readonly property var navItems: [
        { key: "overview",   icon: "󰋜", label: "GENEL BAKIŞ",     title: "SİSTEM GENEL BAKIŞ",     subtitle: "Donanım telemetrisi, aktif ekran ve hızlı ayar kısayolları" },
        { key: "appearance", icon: "󰏘", label: "GÖRÜNÜM",         title: "GÖRÜNÜM VE PENCERE",     subtitle: "Tasarım kimliği, canlı önizleme ve Hyprland pencere geometrisi" },
        { key: "bar",        icon: "󰕮", label: "ÜST ÇUBUK",       title: "ÜST ÇUBUK MODÜLLERİ",    subtitle: "Panelde görünecek bileşenleri canlı olarak yönetin" },
        { key: "display",    icon: "󰍹", label: "EKRAN",           title: "EKRAN VE MONİTÖRLER",    subtitle: "Çözünürlük, yenileme hızı ve görüntü ölçeklendirme" },
        { key: "input",      icon: "󰌌", label: "KLAVYE VE FARE",  title: "KLAVYE VE İŞARETÇİ",     subtitle: "Klavye düzeni, tuş tekrar hızı ve fare hassasiyeti" },
        { key: "shortcuts",  icon: "󰘳", label: "KISAYOLLAR",      title: "KLAVYE KISAYOLLARI",     subtitle: "Aktif Hyprland tuş atamalarını arayın ve inceleyin" },
        { key: "system",     icon: "󰒓", label: "SİSTEM",          title: "SİSTEM VE MODÜLLER",     subtitle: "Kalıcı yapılandırma dosyası ve yerleşik eklenti anahtarları" }
    ]

    readonly property var barModules: [
        { prop: "showWorkspaces",    icon: "󰍹", label: "ÇALIŞMA ALANLARI",      desc: "Aktif ve dolu masaüstü numaraları" },
        { prop: "showClock",         icon: "󰥔", label: "SAAT VE HAVA DURUMU",   desc: "Tarih, saat ve canlı sıcaklık bilgisi" },
        { prop: "showSystemStats",   icon: "󰍛", label: "SİSTEM TELEMETRİ",      desc: "CPU, bellek ve disk kullanım özeti" },
        { prop: "showNetwork",       icon: "󰖩", label: "AĞ VE WI-FI",           desc: "Bağlantı durumu, VPN ve hız göstergesi" },
        { prop: "showVolume",        icon: "󰕾", label: "SES DÜZEYİ",            desc: "Ses karıştırıcı ve hızlı susturma" },
        { prop: "showPower",         icon: "󰐥", label: "GÜÇ VE KONTROL",        desc: "Kontrol merkezi ve oturum eylemleri" },
        { prop: "showAi",            icon: "󰧑", label: "ORACLE // AI ASİSTAN",  desc: "Yapay zeka kenar çubuğu kısayolu" },
        { prop: "showNotifications", icon: "󰂚", label: "BİLDİRİMLER",           desc: "Okunmamış uyarı sayacı ve geçmişi" },
        { prop: "showTray",          icon: "󰀻", label: "SİSTEM TEPSİSİ",        desc: "Arka plan uygulama simgeleri" }
    ]

    readonly property var pluginModules: [
        { prop: "enableAudioMixer",       icon: "󰓃", label: "SES KARIŞTIRICI",      desc: "Uygulama bazlı ses düzeyi kontrolü" },
        { prop: "enableBluetoothPanel",   icon: "󰂯", label: "BLUETOOTH YÖNETİCİSİ", desc: "Cihaz eşleştirme ve pil takibi" },
        { prop: "enableWifiQr",           icon: "󰐲", label: "WI-FI QR PAYLAŞIMI",   desc: "Aktif ağ için hızlı QR kodu üretimi" },
        { prop: "enableFocusTimer",       icon: "󰔟", label: "ODAK ZAMANLAYICI",     desc: "Pomodoro çalışma ve mola sayacı" },
        { prop: "enableContainerMonitor", icon: "󰡨", label: "KONTEYNER İZLEYİCİ",   desc: "Docker ve Podman servis durumu" }
    ]

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

    component GothamSwitch: Rectangle {
        property bool checked: false
        implicitWidth: 42
        implicitHeight: 20
        radius: 0
        color: checked ? Theme.accent : Theme.surface2
        border.color: checked ? Theme.accent : Theme.borderSubtle
        border.width: 1

        Behavior on color {
            enabled: !Theme.reduceMotion
            ColorAnimation { duration: Theme.animFast }
        }

        Rectangle {
            width: 14
            height: 14
            radius: 0
            anchors.verticalCenter: parent.verticalCenter
            x: parent.checked ? parent.width - width - 3 : 3
            color: parent.checked ? Theme.accentOn : Theme.textSecondary

            Behavior on x {
                enabled: !Theme.reduceMotion
                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
            }
        }
    }

    component GothamStepperRow: Rectangle {
        id: stp
        property string title: ""
        property string subtitle: ""
        property string valueText: ""
        signal decrement()
        signal increment()

        width: parent ? parent.width : 0
        height: 52
        radius: 0
        color: Theme.surface1
        border.color: Theme.borderSubtle
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10

            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    width: parent.width
                    text: stp.title
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: stp.subtitle
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                implicitWidth: 28
                implicitHeight: 26
                radius: 0
                color: decMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                border.color: decMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: 1

                Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
                MouseArea { id: decMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: stp.decrement() }
            }

            Text {
                text: stp.valueText
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: 11
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 56
            }

            Rectangle {
                implicitWidth: 28
                implicitHeight: 26
                radius: 0
                color: incMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                border.color: incMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: 1

                Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
                MouseArea { id: incMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: stp.increment() }
            }
        }
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
                    text: "ENYXMA // AYARLAR"
                    color: Theme.accent
                    font.family: Theme.fontDisplay
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Text {
                    text: "MASAÜSTÜ KONTROL MERKEZİ"
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
                            text: "Ayar ara..."
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
                    text: "Sonuç bulunamadı"
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
                        text: "ESC İLE KAPAT"
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
                            text: "DONANIM VE OTURUM ÖZETİ"
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
                                model: [
                                    { label: "İŞLEMCİ",  value: PerformanceState.cpuModel + " · %" + PerformanceState.cpuPercent },
                                    { label: "EKRAN KARTI", value: PerformanceState.gpuModel },
                                    { label: "BELLEK",   value: PerformanceState.memUsedGiB.toFixed(1) + " / " + PerformanceState.memTotalGiB.toFixed(1) + " GiB · %" + PerformanceState.memPercent },
                                    { label: "DEPOLAMA", value: StorageState.rootMount + " · %" + StorageState.rootPercent + " · " + StorageState.rootUsedGiB.toFixed(0) + " GiB" },
                                    { label: "EKRAN",    value: (SettingsState.monitors.length > 0) ? (SettingsState.monitors[0].name + " · " + SettingsState.monitors[0].width + "×" + SettingsState.monitors[0].height + " @ " + Math.round(SettingsState.monitors[0].refreshRate) + "Hz") : "Algılanıyor" },
                                    { label: "AĞ",       value: NetworkState.isConnected ? ((NetworkState.ssid || NetworkState.connectionName || "Bağlı") + " · " + NetworkState.ipAddress) : "Çevrimdışı" }
                                ]
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
                            text: "HIZLI ERİŞİM"
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
                                    { tab: "appearance", icon: "󰏘", label: "TEMA VE STİL" },
                                    { tab: "display",    icon: "󰍹", label: "EKRAN AYARLARI" },
                                    { tab: "shortcuts",  icon: "󰘳", label: "KISAYOLLAR" }
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
                            text: "TASARIM KİMLİĞİ"
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
                                    { key: "dynamic", title: "DİNAMİK · MATUGEN",  desc: "Duvar kağıdından türetilen yumuşak renkler" },
                                    { key: "gotham",  title: "GOTHAM · BRUTALIST", desc: "Keskin köşeler, koyu yüzey ve kehribar vurgu" }
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

                                                Text { id: activeLbl; anchors.centerIn: parent; text: "AKTİF"; color: Theme.accentOn; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
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
                                    text: "CANLI ÖNİZLEME"
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
                                        text: "ÖRNEK EYLEM"
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

                                    Text { text: "DUVAR KAĞIDI GALERİSİ"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Arka plan görselini değiştirin ve renk paletini yenileyin"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                }

                                Rectangle {
                                    implicitWidth: 68
                                    implicitHeight: 26
                                    radius: 0
                                    color: Theme.surface2
                                    border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text { anchors.centerIn: parent; text: "AÇ →"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
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
                                text: "HYPRLAND PENCERE GEOMETRİSİ"
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

                                Text { anchors.centerIn: parent; text: "TEMA VARSAYILANI"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }
                                MouseArea { id: rstHyprMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetHyprStyle() }
                            }
                        }

                        GothamStepperRow {
                            title: "KÖŞE YUVARLAKLIĞI"
                            subtitle: "Pencere köşelerinin piksel cinsinden yumuşaklığı"
                            valueText: SettingsState.hyprRounding + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprRounding", Math.max(0, SettingsState.hyprRounding - 2), "Köşe yuvarlaklığı güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprRounding", Math.min(24, SettingsState.hyprRounding + 2), "Köşe yuvarlaklığı güncellendi")
                        }

                        GothamStepperRow {
                            title: "İÇ PENCERE BOŞLUĞU"
                            subtitle: "Yan yana pencereler arasındaki mesafe"
                            valueText: SettingsState.hyprGapsIn + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsIn", Math.max(0, SettingsState.hyprGapsIn - 2), "İç boşluk güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprGapsIn", Math.min(24, SettingsState.hyprGapsIn + 2), "İç boşluk güncellendi")
                        }

                        GothamStepperRow {
                            title: "DIŞ KENAR BOŞLUĞU"
                            subtitle: "Pencereler ile ekran kenarı arasındaki mesafe"
                            valueText: SettingsState.hyprGapsOut + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsOut", Math.max(0, SettingsState.hyprGapsOut - 2), "Dış boşluk güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprGapsOut", Math.min(32, SettingsState.hyprGapsOut + 2), "Dış boşluk güncellendi")
                        }

                        GothamStepperRow {
                            title: "KENARLIK KALINLIĞI"
                            subtitle: "Aktif ve pasif pencere çerçeve kalınlığı"
                            valueText: SettingsState.hyprBorderSize + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprBorderSize", Math.max(0, SettingsState.hyprBorderSize - 1), "Kenarlık kalınlığı güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprBorderSize", Math.min(6, SettingsState.hyprBorderSize + 1), "Kenarlık kalınlığı güncellendi")
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
                                    Text { text: "PENCERE BULANIKLIĞI"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Saydam pencerelerin arkasındaki bulanıklık efektini açar"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprBlur }
                            }
                            MouseArea { id: blurMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprBlur", !SettingsState.hyprBlur, "Bulanıklık güncellendi") }
                        }

                        GothamStepperRow {
                            title: "AKTİF PENCERE OPAKLIĞI"
                            subtitle: "Odaktaki pencerenin saydamlık oranı"
                            valueText: Math.round(SettingsState.hyprActiveOpacity * 100) + "%"
                            onDecrement: SettingsState.setHyprSetting("hyprActiveOpacity", Math.max(0.75, Math.round((SettingsState.hyprActiveOpacity - 0.05) * 100) / 100), "Aktif opaklık güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprActiveOpacity", Math.min(1.00, Math.round((SettingsState.hyprActiveOpacity + 0.05) * 100) / 100), "Aktif opaklık güncellendi")
                        }

                        GothamStepperRow {
                            title: "PASİF PENCERE OPAKLIĞI"
                            subtitle: "Arka plandaki pencerelerin saydamlık oranı"
                            valueText: Math.round(SettingsState.hyprInactiveOpacity * 100) + "%"
                            onDecrement: SettingsState.setHyprSetting("hyprInactiveOpacity", Math.max(0.70, Math.round((SettingsState.hyprInactiveOpacity - 0.05) * 100) / 100), "Pasif opaklık güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprInactiveOpacity", Math.min(1.00, Math.round((SettingsState.hyprInactiveOpacity + 0.05) * 100) / 100), "Pasif opaklık güncellendi")
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: shadowMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "PENCERE GÖLGESİ"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Pencerelerin altında derinlik gölgesi oluşturur"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprShadow }
                            }
                            MouseArea { id: shadowMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprShadow", !SettingsState.hyprShadow, "Pencere gölgesi güncellendi") }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: animMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "HYPRLAND ANİMASYONLARI"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Pencere açılış ve çalışma alanı geçiş efektlerini kontrol eder"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.hyprAnimations }
                            }
                            MouseArea { id: animMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprAnimations", !SettingsState.hyprAnimations, "Hyprland animasyonları güncellendi") }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text {
                            text: "DAVRANIŞ VE ÇUBUK GEOMETRİSİ"
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
                                    Text { text: "HAREKET VE ANİMASYONLARI AZALT"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Panel geçişleri ve açılış animasyonlarını anlık hale getirir"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.reduceMotion }
                            }
                            MouseArea { id: rmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("reduceMotion", "Hareket tercihi güncellendi") }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: bvMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "ÜST ÇUBUK GÖRÜNÜR"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Ekranın üstündeki Enyxma durum çubuğunu gösterir veya gizler"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.barVisible }
                            }
                            MouseArea { id: bvMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("barVisible", "Üst çubuk görünürlüğü güncellendi") }
                        }

                        GothamStepperRow {
                            title: "ÜST ÇUBUK YÜKSEKLİĞİ"
                            subtitle: "Üst panelin piksel cinsinden dikey kalınlığı"
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

                        Text { text: "AKTİF MODÜLLER"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                        Text { text: root.activeBarModuleCount + " / " + root.barModules.length + " aktif"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
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
                                onClicked: SettingsState.toggleBoolSetting(barRow.modelData.prop, barRow.modelData.label + " güncellendi")
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
                            Text { text: "BAĞLI MONİTÖRLER"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                implicitWidth: 74; implicitHeight: 24; radius: 0
                                color: refMonMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: refMonMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: "↻ YENİLE"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
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

                                    Text { text: "ÇÖZÜNÜRLÜK VE YENİLEME HIZI"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }

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

                                    Text { text: "GÖRÜNTÜ ÖLÇEĞİ"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 9; font.bold: true }

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

                        Text { text: "ADAPTİF YENİLEME // VRR"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { mode: 0, label: "KAPALI" },
                                    { mode: 1, label: "HER ZAMAN" },
                                    { mode: 2, label: "TAM EKRAN" }
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

                        Text { text: "GECE IŞIĞI // HYPRSUNSET"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: nlMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "GECE IŞIĞI FİLTRESİ"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Mavi ışığı azaltarak göz yorgunluğunu düşürür"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.nightLightEnabled }
                            }
                            MouseArea { id: nlMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleNightLight() }
                        }

                        GothamStepperRow {
                            title: "RENK SICAKLIĞI"
                            subtitle: "Düşük Kelvin değeri daha sıcak kehribar tonu verir"
                            valueText: SettingsState.nightLightTemp + " K"
                            onDecrement: SettingsState.setNightLightTemp(SettingsState.nightLightTemp - 250)
                            onIncrement: SettingsState.setNightLightTemp(SettingsState.nightLightTemp + 250)
                        }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { temp: 3500, label: "3500K · SICAK" },
                                    { temp: 4500, label: "4500K · DENGELİ" },
                                    { temp: 5500, label: "5500K · HAFİF" }
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

                        Text { text: "GÜÇ VE OTOMATİK KİLİT // HYPRIDLE"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: idleEnMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "OTOMATİK KİLİT VE UYKU"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Etkinlik olmadığında ekran kilidi ve güç tasarrufu uygular"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.idleEnabled }
                            }
                            MouseArea { id: idleEnMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleEnabled", !SettingsState.idleEnabled, "Otomatik kilit durumu güncellendi") }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: "EKRANI KİLİTLE"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 3, 5, 10, 15 ]
                                delegate: Rectangle {
                                    id: lockChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleLockMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (lockMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: lockChip.modelData === 0 ? "KAPALI" : (lockChip.modelData + " DK"); color: lockChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: lockChip.active }
                                    MouseArea { id: lockMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleLockMin", lockChip.modelData, "Kilit süresi güncellendi") }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: "EKRANI KAPAT"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 5, 10, 15, 30 ]
                                delegate: Rectangle {
                                    id: dpmsChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleScreenOffMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (dpmsMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: dpmsChip.modelData === 0 ? "KAPALI" : (dpmsChip.modelData + " DK"); color: dpmsChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: dpmsChip.active }
                                    MouseArea { id: dpmsMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleScreenOffMin", dpmsChip.modelData, "Ekran kapatma süresi güncellendi") }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 6
                            Text { text: "SİSTEMİ UYUT"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 118 }
                            Repeater {
                                model: [ 0, 15, 30, 60 ]
                                delegate: Rectangle {
                                    id: suspChip
                                    required property int modelData
                                    readonly property bool active: SettingsState.idleSuspendMin === modelData
                                    Layout.fillWidth: true; implicitHeight: 28; radius: 0
                                    color: active ? Theme.surfaceActive : (suspMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: suspChip.modelData === 0 ? "KAPALI" : (suspChip.modelData + " DK"); color: suspChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: suspChip.active }
                                    MouseArea { id: suspMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setIdleSetting("idleSuspendMin", suspChip.modelData, "Uyku süresi güncellendi") }
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

                        Text { text: "KLAVYE DÜZENİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { code: "tr",    label: "TR · TÜRKÇE Q" },
                                    { code: "us",    label: "US · İNGİLİZCE" },
                                    { code: "tr,us", label: "TR + US" },
                                    { code: "de",    label: "DE · ALMANCA" }
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
                                    MouseArea { id: kbMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setInputSetting("kbLayout", kbChip.modelData.code, "Klavye düzeni değişti") }
                                }
                            }
                        }

                        GothamStepperRow {
                            title: "TUŞ TEKRAR HIZI"
                            subtitle: "Basılı tutulan tuşun saniyedeki tekrar sayısı"
                            valueText: SettingsState.kbRepeatRate + " /sn"
                            onDecrement: SettingsState.setInputSetting("kbRepeatRate", Math.max(15, SettingsState.kbRepeatRate - 5), "Tekrar hızı güncellendi")
                            onIncrement: SettingsState.setInputSetting("kbRepeatRate", Math.min(80, SettingsState.kbRepeatRate + 5), "Tekrar hızı güncellendi")
                        }

                        GothamStepperRow {
                            title: "TUŞ TEKRAR GECİKMESİ"
                            subtitle: "Tekrar başlamadan önce beklenecek süre"
                            valueText: SettingsState.kbRepeatDelay + " ms"
                            onDecrement: SettingsState.setInputSetting("kbRepeatDelay", Math.max(150, SettingsState.kbRepeatDelay - 50), "Tekrar gecikmesi güncellendi")
                            onIncrement: SettingsState.setInputSetting("kbRepeatDelay", Math.min(600, SettingsState.kbRepeatDelay + 50), "Tekrar gecikmesi güncellendi")
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: "FARE VE DOKUNMATİK YÜZEY"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        GothamStepperRow {
                            title: "FARE HASSASİYETİ"
                            subtitle: "Hyprland işaretçi hız çarpanı"
                            valueText: SettingsState.mouseSensitivity.toFixed(1)
                            onDecrement: SettingsState.setInputSetting("mouseSensitivity", Math.max(-0.8, Math.round((SettingsState.mouseSensitivity - 0.1) * 10) / 10), "Fare hassasiyeti güncellendi")
                            onIncrement: SettingsState.setInputSetting("mouseSensitivity", Math.min(0.8, Math.round((SettingsState.mouseSensitivity + 0.1) * 10) / 10), "Fare hassasiyeti güncellendi")
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: nsMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "DOĞAL KAYDIRMA"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Dokunmatik yüzeyde içerik yönünü parmak hareketiyle eşler"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                GothamSwitch { checked: SettingsState.naturalScroll }
                            }
                            MouseArea { id: nsMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setInputSetting("naturalScroll", !SettingsState.naturalScroll, "Doğal kaydırma güncellendi") }
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
                                Text { anchors.verticalCenter: parent.verticalCenter; text: "Kısayol veya eylem ara..."; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11; visible: parent.text.length === 0 }
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

                        Text { anchors.centerIn: parent; visible: root.filteredShortcuts.length === 0; text: "Eşleşen kısayol bulunamadı"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 12 }
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

                        Text { text: "KALICI AYAR DOSYASI"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

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
                                Text { anchors.centerIn: parent; text: "AYAR DOSYASINI AÇ"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                MouseArea { id: openCfgMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.openConfigFile() }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 36; radius: 0
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: "VARSAYILANLARA SIFIRLA"; color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: resetMa.containsMouse }
                                MouseArea { id: resetMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetDefaults() }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "YERLEŞİK EKLENTİ MODÜLLERİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

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
                                    onClicked: SettingsState.toggleBoolSetting(pluginRow.modelData.prop, pluginRow.modelData.label + " güncellendi")
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "BİLDİRİM TERCİHLERİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: 0
                            color: dndMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "RAHATSIZ ETME MODU"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Açılır bildirimleri susturup yalnızca geçmişe kaydeder"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
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
                                    Text { anchors.centerIn: parent; text: ntChip.modelData + " SN"; color: ntChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: ntChip.active }
                                    MouseArea { id: ntMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setNotifTimeout(ntChip.modelData) }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "VARSAYILAN UYGULAMALAR"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Text { text: "TERMİNAL"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 110 }
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
                                    MouseArea { id: termMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setDefaultApp("defaultTerminal", termChip.modelData, "Varsayılan terminal güncellendi") }
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Text { text: "DOSYA YÖNETİCİSİ"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; Layout.preferredWidth: 110 }
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
                                    MouseArea { id: fmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setDefaultApp("defaultFileManager", fmChip.modelData, "Varsayılan dosya yöneticisi güncellendi") }
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
                            text: "GERİ AL"
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
