import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * DynamicSettingsPanel — Enyxma Dinamik Ayarlar 2.0 kontrol merkezi.
 *
 * Matugen uyumlu yumusak yuzeyler, global ayar arama, canli Hyprland pencere
 * geometrisi, ekran/giris kontrolleri ve tek tikla Geri Al seridi icerir.
 */
Item {
    id: root

    property string globalFilter: ""
    property string shortcutFilter: ""

    readonly property var navItems: [
        { key: "overview",   icon: "󰋜", label: "Genel Bakış",     title: "Sistem Genel Bakış",     subtitle: "Donanım telemetrisi, aktif ekran ve hızlı ayar kısayolları" },
        { key: "appearance", icon: "󰏘", label: "Görünüm",         title: "Görünüm ve Pencere",     subtitle: "Tasarım kimliği, canlı önizleme ve Hyprland pencere geometrisi" },
        { key: "bar",        icon: "󰕮", label: "Üst Çubuk",       title: "Üst Çubuk Modülleri",    subtitle: "Panelde görünecek bileşenleri canlı olarak yönetin" },
        { key: "display",    icon: "󰍹", label: "Ekran",           title: "Ekran ve Monitörler",    subtitle: "Çözünürlük, yenileme hızı ve görüntü ölçeklendirme" },
        { key: "input",      icon: "󰌌", label: "Klavye ve Fare",  title: "Klavye ve İşaretçi",     subtitle: "Klavye düzeni, tuş tekrar hızı ve fare hassasiyeti" },
        { key: "shortcuts",  icon: "󰘳", label: "Kısayollar",      title: "Klavye Kısayolları",     subtitle: "Aktif Hyprland tuş atamalarını arayın ve inceleyin" },
        { key: "system",     icon: "󰒓", label: "Sistem",          title: "Sistem ve Modüller",     subtitle: "Kalıcı yapılandırma dosyası ve yerleşik eklenti anahtarları" }
    ]

    readonly property var barModules: [
        { prop: "showWorkspaces",    icon: "󰍹", label: "Çalışma Alanları",      desc: "Aktif ve dolu masaüstü numaraları" },
        { prop: "showClock",         icon: "󰥔", label: "Saat ve Hava Durumu",   desc: "Tarih, saat ve canlı sıcaklık bilgisi" },
        { prop: "showSystemStats",   icon: "󰍛", label: "Sistem Telemetri",      desc: "CPU, bellek ve disk kullanım özeti" },
        { prop: "showNetwork",       icon: "󰖩", label: "Ağ ve Wi-Fi",           desc: "Bağlantı durumu, VPN ve hız göstergesi" },
        { prop: "showVolume",        icon: "󰕾", label: "Ses Düzeyi",            desc: "Ses karıştırıcı ve hızlı susturma" },
        { prop: "showPower",         icon: "󰐥", label: "Güç ve Kontrol",        desc: "Kontrol merkezi ve oturum eylemleri" },
        { prop: "showAi",            icon: "󰧑", label: "Enyxma AI Asistan",     desc: "Yapay zeka kenar çubuğu kısayolu" },
        { prop: "showNotifications", icon: "󰂚", label: "Bildirim Merkezi",      desc: "Okunmamış uyarı sayacı ve geçmişi" },
        { prop: "showTray",          icon: "󰀻", label: "Sistem Tepsisi",        desc: "Arka plan uygulama simgeleri" }
    ]

    readonly property var pluginModules: [
        { prop: "enableAudioMixer",       icon: "󰓃", label: "Ses Karıştırıcı",      desc: "Uygulama bazlı ses düzeyi kontrolü" },
        { prop: "enableBluetoothPanel",   icon: "󰂯", label: "Bluetooth Yöneticisi", desc: "Cihaz eşleştirme ve pil takibi" },
        { prop: "enableWifiQr",           icon: "󰐲", label: "Wi-Fi QR Paylaşımı",   desc: "Aktif ağ için hızlı QR kodu üretimi" },
        { prop: "enableFocusTimer",       icon: "󰔟", label: "Odak Zamanlayıcı",     desc: "Pomodoro çalışma ve mola sayacı" },
        { prop: "enableContainerMonitor", icon: "󰡨", label: "Konteyner İzleyici",   desc: "Docker ve Podman servis durumu" }
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

    component DynamicSwitch: Rectangle {
        property bool checked: false
        implicitWidth: 42
        implicitHeight: 22
        radius: 11
        color: checked ? Theme.accent : Theme.surface2
        border.color: checked ? Theme.accent : Theme.borderSubtle
        border.width: 1

        Behavior on color {
            enabled: !Theme.reduceMotion
            ColorAnimation { duration: Theme.animFast }
        }

        Rectangle {
            width: 16
            height: 16
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            x: parent.checked ? parent.width - width - 3 : 3
            color: parent.checked ? Theme.accentOn : Theme.textSecondary

            Behavior on x {
                enabled: !Theme.reduceMotion
                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
            }
        }
    }

    component DynamicStepperRow: Rectangle {
        id: stp
        property string title: ""
        property string subtitle: ""
        property string valueText: ""
        signal decrement()
        signal increment()

        width: parent ? parent.width : 0
        height: 52
        radius: Theme.radiusButton
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
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
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
                radius: Theme.radiusSmall
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
                radius: Theme.radiusSmall
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
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
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
                anchors.topMargin: 20
                anchors.leftMargin: 18
                anchors.rightMargin: 16
                spacing: 3

                Text {
                    text: "Enyxma Ayarlar"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "Masaüstü Kontrol Merkezi"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }

            Rectangle {
                id: globalSearchBox
                anchors.top: brandHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 12
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 34
                radius: Theme.radiusButton
                color: Theme.surface1
                border.color: globalSearchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
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
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        clip: true
                        onTextChanged: root.globalFilter = text

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Ayar ara..."
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            visible: parent.text.length === 0
                        }
                    }

                    Text {
                        visible: root.globalFilter.length > 0
                        text: "✕"
                        color: Theme.textSecondary
                        font.pixelSize: 11

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: globalSearchInp.text = ""
                        }
                    }
                }
            }

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
                        radius: Theme.radiusButton
                        color: active ? Theme.surfaceActive : (navMa.containsMouse ? Theme.surfaceHover : "transparent")
                        border.color: active ? Theme.borderFocus : "transparent"
                        border.width: 1

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: navBtn.modelData.icon
                                color: navBtn.active ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: navBtn.modelData.label
                                color: navBtn.active ? Theme.textPrimary : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: navBtn.active
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
                    radius: Theme.radiusButton
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
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
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
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }

            Column {
                id: sidebarFooter
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                spacing: 8

                Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                RowLayout {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        implicitWidth: badgeText.implicitWidth + 14
                        implicitHeight: 22
                        radius: Theme.radiusSmall
                        color: Theme.surface1
                        border.color: Theme.borderSubtle
                        border.width: 1

                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: "DİNAMİK · MATUGEN"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text { text: "Esc"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
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
                        font.pixelSize: 16
                        font.bold: true
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
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "✕"; color: closeMa.containsMouse ? Theme.accent : Theme.textSecondary; font.pixelSize: 12 }
                    MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.close() }
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

                        Text { text: "Donanım ve Oturum Özeti"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        GridLayout {
                            width: parent.width
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 8

                            Repeater {
                                model: [
                                    { label: "İşlemci",     value: PerformanceState.cpuModel + " · %" + PerformanceState.cpuPercent },
                                    { label: "Ekran Kartı", value: PerformanceState.gpuModel },
                                    { label: "Bellek",      value: PerformanceState.memUsedGiB.toFixed(1) + " / " + PerformanceState.memTotalGiB.toFixed(1) + " GiB · %" + PerformanceState.memPercent },
                                    { label: "Depolama",    value: StorageState.rootMount + " · %" + StorageState.rootPercent + " · " + StorageState.rootUsedGiB.toFixed(0) + " GiB" },
                                    { label: "Ekran",       value: (SettingsState.monitors.length > 0) ? (SettingsState.monitors[0].name + " · " + SettingsState.monitors[0].width + "×" + SettingsState.monitors[0].height + " @ " + Math.round(SettingsState.monitors[0].refreshRate) + "Hz") : "Algılanıyor" },
                                    { label: "Ağ",          value: NetworkState.isConnected ? ((NetworkState.ssid || NetworkState.connectionName || "Bağlı") + " · " + NetworkState.ipAddress) : "Çevrimdışı" }
                                ]
                                delegate: Rectangle {
                                    id: ovCard
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 56
                                    radius: Theme.radiusButton
                                    color: Theme.surface1
                                    border.color: Theme.borderSubtle
                                    border.width: 1

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.margins: 12
                                        spacing: 3

                                        Text { text: ovCard.modelData.label; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                                        Text { width: parent.width; text: ovCard.modelData.value; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text { text: "Hızlı Erişim"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        RowLayout {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { tab: "appearance", icon: "󰏘", label: "Tema ve Stil" },
                                    { tab: "display",    icon: "󰍹", label: "Ekran Ayarları" },
                                    { tab: "shortcuts",  icon: "󰘳", label: "Kısayollar" }
                                ]
                                delegate: Rectangle {
                                    id: qBtn
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 42
                                    radius: Theme.radiusButton
                                    color: qMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                    border.color: qMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Text { text: qBtn.modelData.icon; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 14 }
                                        Text { text: qBtn.modelData.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    }

                                    MouseArea {
                                        id: qMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
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

                        Text { text: "Tasarım Kimliği"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        RowLayout {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: [
                                    { key: "dynamic", title: "Dinamik · Matugen",  desc: "Duvar kağıdından türetilen yumuşak renkler" },
                                    { key: "gotham",  title: "Gotham · Brutalist", desc: "Keskin köşeler, koyu yüzey ve kehribar vurgu" }
                                ]
                                delegate: Rectangle {
                                    id: themeCard
                                    required property var modelData
                                    readonly property bool active: (modelData.key === "gotham") ? Theme.isGotham : !Theme.isGotham
                                    Layout.fillWidth: true
                                    implicitHeight: 70
                                    radius: Theme.radiusButton
                                    color: active ? Theme.surfaceActive : (themeMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent; anchors.margins: 12; spacing: 5

                                        RowLayout {
                                            width: parent.width; spacing: 6
                                            Text { text: themeCard.modelData.title; color: themeCard.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                                            Rectangle {
                                                visible: themeCard.active; implicitWidth: activeLbl.implicitWidth + 12; implicitHeight: 18; radius: Theme.radiusSmall; color: Theme.accent
                                                Text { id: activeLbl; anchors.centerIn: parent; text: "Aktif"; color: Theme.accentOn; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                                            }
                                        }

                                        Text { width: parent.width; text: themeCard.modelData.desc; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                    }

                                    MouseArea { id: themeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: WallpaperState.setThemePreset(themeCard.modelData.key) }
                                }
                            }
                        }

                        // Kompakt Enyxma Canli Onizleme
                        Rectangle {
                            width: parent.width
                            height: 54
                            radius: Theme.radiusButton
                            color: Theme.bgDark
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Text { text: "Canlı Önizleme"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: 36; implicitHeight: 24
                                    radius: SettingsState.customHyprStyle ? Math.min(8, SettingsState.hyprRounding) : Theme.radiusSmall
                                    color: Theme.surface1; border.color: Theme.accent; border.width: SettingsState.customHyprStyle ? Math.max(1, SettingsState.hyprBorderSize) : 1
                                }
                                DynamicSwitch { checked: true }
                                Rectangle {
                                    implicitWidth: 88; implicitHeight: 26; radius: Theme.radiusSmall; color: Theme.accent
                                    Text { anchors.centerIn: parent; text: "Örnek Eylem"; color: Theme.accentOn; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: Theme.radiusButton
                            color: wpMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Text { text: "󰸉"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 18 }
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "Duvar Kağıdı Galerisi"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    Text { text: "Arka plan görselini değiştirin ve renk paletini yenileyin"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                                Rectangle {
                                    implicitWidth: 68; implicitHeight: 26; radius: Theme.radiusSmall; color: Theme.surface2; border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: "Aç →"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }
                                }
                            }
                            MouseArea { id: wpMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { SettingsState.close(); WallpaperState.openPicker() } }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        RowLayout {
                            width: parent.width
                            Text { text: "Hyprland Pencere Geometrisi"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                visible: SettingsState.customHyprStyle; implicitWidth: 118; implicitHeight: 22; radius: Theme.radiusSmall
                                color: rstHyprMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: "Tema Varsayılanı"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                                MouseArea { id: rstHyprMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetHyprStyle() }
                            }
                        }

                        DynamicStepperRow {
                            title: "Köşe Yuvarlaklığı"
                            subtitle: "Pencere köşelerinin piksel cinsinden yumuşaklığı"
                            valueText: SettingsState.hyprRounding + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprRounding", Math.max(0, SettingsState.hyprRounding - 2), "Köşe yuvarlaklığı güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprRounding", Math.min(24, SettingsState.hyprRounding + 2), "Köşe yuvarlaklığı güncellendi")
                        }

                        DynamicStepperRow {
                            title: "İç Pencere Boşluğu"
                            subtitle: "Yan yana pencereler arasındaki mesafe"
                            valueText: SettingsState.hyprGapsIn + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsIn", Math.max(0, SettingsState.hyprGapsIn - 2), "İç boşluk güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprGapsIn", Math.min(24, SettingsState.hyprGapsIn + 2), "İç boşluk güncellendi")
                        }

                        DynamicStepperRow {
                            title: "Dış Kenar Boşluğu"
                            subtitle: "Pencereler ile ekran kenarı arasındaki mesafe"
                            valueText: SettingsState.hyprGapsOut + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprGapsOut", Math.max(0, SettingsState.hyprGapsOut - 2), "Dış boşluk güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprGapsOut", Math.min(32, SettingsState.hyprGapsOut + 2), "Dış boşluk güncellendi")
                        }

                        DynamicStepperRow {
                            title: "Kenarlık Kalınlığı"
                            subtitle: "Aktif ve pasif pencere çerçeve kalınlığı"
                            valueText: SettingsState.hyprBorderSize + " px"
                            onDecrement: SettingsState.setHyprSetting("hyprBorderSize", Math.max(0, SettingsState.hyprBorderSize - 1), "Kenarlık kalınlığı güncellendi")
                            onIncrement: SettingsState.setHyprSetting("hyprBorderSize", Math.min(6, SettingsState.hyprBorderSize + 1), "Kenarlık kalınlığı güncellendi")
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: Theme.radiusButton
                            color: blurMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "Pencere Bulanıklığı"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    Text { text: "Saydam pencerelerin arkasındaki bulanıklık efektini açar"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                DynamicSwitch { checked: SettingsState.hyprBlur }
                            }
                            MouseArea { id: blurMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setHyprSetting("hyprBlur", !SettingsState.hyprBlur, "Bulanıklık güncellendi") }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "Davranış ve Çubuk Geometrisi"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 52; radius: Theme.radiusButton
                            color: rmMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "Hareket ve Animasyonları Azalt"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    Text { text: "Panel geçişleri ve açılış animasyonlarını anlık hale getirir"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                DynamicSwitch { checked: SettingsState.reduceMotion }
                            }
                            MouseArea { id: rmMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("reduceMotion", "Hareket tercihi güncellendi") }
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: Theme.radiusButton
                            color: bvMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "Üst Çubuk Görünür"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    Text { text: "Ekranın üstündeki Enyxma durum çubuğunu gösterir veya gizler"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                DynamicSwitch { checked: SettingsState.barVisible }
                            }
                            MouseArea { id: bvMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.toggleBoolSetting("barVisible", "Üst çubuk görünürlüğü güncellendi") }
                        }

                        DynamicStepperRow {
                            title: "Üst Çubuk Yüksekliği"
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
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 22
                        Text { text: "Aktif Modüller"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                        Text { text: root.activeBarModuleCount + " / " + root.barModules.length + " aktif"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true }
                    }

                    ListView {
                        anchors.top: barSummaryRow.bottom; anchors.topMargin: 10; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                        clip: true; spacing: 6; boundsBehavior: Flickable.StopAtBounds
                        model: root.barModules

                        delegate: Rectangle {
                            id: barRow
                            required property var modelData
                            readonly property bool isOn: !!SettingsState[modelData.prop]
                            width: ListView.view.width; height: 48; radius: Theme.radiusButton
                            color: barRowMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Text { text: barRow.modelData.icon; color: barRow.isOn ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 15 }
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { width: parent.width; text: barRow.modelData.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                                    Text { width: parent.width; text: barRow.modelData.desc; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                                DynamicSwitch { checked: barRow.isOn }
                            }
                            MouseArea {
                                id: barRowMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
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
                            Text { text: "Bağlı Monitörler"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                            Rectangle {
                                implicitWidth: 74; implicitHeight: 24; radius: Theme.radiusSmall
                                color: refMonMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: refMonMa.containsMouse ? Theme.accent : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: "↻ Yenile"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }
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
                                radius: Theme.radiusButton
                                color: Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1

                                Column {
                                    id: monCol
                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 12; spacing: 10

                                    RowLayout {
                                        width: parent.width
                                        Text { text: monCard.modelData.name + " · " + monCard.modelData.model; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: monCard.modelData.width + "×" + monCard.modelData.height + " @ " + Math.round(monCard.modelData.refreshRate) + "Hz · " + Number(monCard.modelData.scale).toFixed(2) + "x"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                    }

                                    Text { text: "Çözünürlük ve Yenileme Hızı"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }

                                    Flow {
                                        width: parent.width; spacing: 6
                                        Repeater {
                                            model: monCard.modelData.modes
                                            delegate: Rectangle {
                                                id: modeChip
                                                required property var modelData
                                                readonly property bool isCur: (monCard.modelData.width + "x" + monCard.modelData.height + "@" + Math.round(monCard.modelData.refreshRate)) === modelData.spec
                                                implicitWidth: modeLbl.implicitWidth + 16; implicitHeight: 26; radius: Theme.radiusSmall
                                                color: isCur ? Theme.surfaceActive : (modeMa.containsMouse ? Theme.surfaceHover : Theme.surface2)
                                                border.color: isCur ? Theme.accent : Theme.borderSubtle; border.width: 1
                                                Text { id: modeLbl; anchors.centerIn: parent; text: modeChip.modelData.label; color: modeChip.isCur ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10 }
                                                MouseArea { id: modeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.applyMonitorMode(monCard.modelData.name, modeChip.modelData.spec, monCard.modelData.x, monCard.modelData.y, monCard.modelData.scale) }
                                            }
                                        }
                                    }

                                    Text { text: "Görüntü Ölçeği"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }

                                    RowLayout {
                                        width: parent.width; spacing: 6
                                        Repeater {
                                            model: [ 1.0, 1.25, 1.5, 2.0 ]
                                            delegate: Rectangle {
                                                id: scaleChip
                                                required property real modelData
                                                readonly property bool isCur: Math.abs(monCard.modelData.scale - modelData) < 0.05
                                                Layout.fillWidth: true; implicitHeight: 28; radius: Theme.radiusSmall
                                                color: isCur ? Theme.surfaceActive : (scaleMa.containsMouse ? Theme.surfaceHover : Theme.surface2)
                                                border.color: isCur ? Theme.accent : Theme.borderSubtle; border.width: 1
                                                Text { anchors.centerIn: parent; text: Number(scaleChip.modelData).toFixed(2) + "x"; color: scaleChip.isCur ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: scaleChip.isCur }
                                                MouseArea { id: scaleMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setMonitorScale(monCard.modelData.name, monCard.modelData.width, monCard.modelData.height, monCard.modelData.refreshRate, monCard.modelData.x, monCard.modelData.y, scaleChip.modelData) }
                                            }
                                        }
                                    }
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

                        Text { text: "Klavye Düzeni"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        RowLayout {
                            width: parent.width; spacing: 8
                            Repeater {
                                model: [
                                    { code: "tr",    label: "TR · Türkçe Q" },
                                    { code: "us",    label: "US · İngilizce" },
                                    { code: "tr,us", label: "TR + US" },
                                    { code: "de",    label: "DE · Almanca" }
                                ]
                                delegate: Rectangle {
                                    id: kbChip
                                    required property var modelData
                                    readonly property bool active: SettingsState.kbLayout === modelData.code
                                    Layout.fillWidth: true; implicitHeight: 34; radius: Theme.radiusButton
                                    color: active ? Theme.surfaceActive : (kbMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle; border.width: 1
                                    Text { anchors.centerIn: parent; text: kbChip.modelData.label; color: kbChip.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: kbChip.active }
                                    MouseArea { id: kbMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.setInputSetting("kbLayout", kbChip.modelData.code, "Klavye düzeni değişti") }
                                }
                            }
                        }

                        DynamicStepperRow {
                            title: "Tuş Tekrar Hızı"
                            subtitle: "Basılı tutulan tuşun saniyedeki tekrar sayısı"
                            valueText: SettingsState.kbRepeatRate + " /sn"
                            onDecrement: SettingsState.setInputSetting("kbRepeatRate", Math.max(15, SettingsState.kbRepeatRate - 5), "Tekrar hızı güncellendi")
                            onIncrement: SettingsState.setInputSetting("kbRepeatRate", Math.min(80, SettingsState.kbRepeatRate + 5), "Tekrar hızı güncellendi")
                        }

                        DynamicStepperRow {
                            title: "Tuş Tekrar Gecikmesi"
                            subtitle: "Tekrar başlamadan önce beklenecek süre"
                            valueText: SettingsState.kbRepeatDelay + " ms"
                            onDecrement: SettingsState.setInputSetting("kbRepeatDelay", Math.max(150, SettingsState.kbRepeatDelay - 50), "Tekrar gecikmesi güncellendi")
                            onIncrement: SettingsState.setInputSetting("kbRepeatDelay", Math.min(600, SettingsState.kbRepeatDelay + 50), "Tekrar gecikmesi güncellendi")
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "Fare ve Dokunmatik Yüzey"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        DynamicStepperRow {
                            title: "Fare Hassasiyeti"
                            subtitle: "Hyprland işaretçi hız çarpanı"
                            valueText: SettingsState.mouseSensitivity.toFixed(1)
                            onDecrement: SettingsState.setInputSetting("mouseSensitivity", Math.max(-0.8, Math.round((SettingsState.mouseSensitivity - 0.1) * 10) / 10), "Fare hassasiyeti güncellendi")
                            onIncrement: SettingsState.setInputSetting("mouseSensitivity", Math.min(0.8, Math.round((SettingsState.mouseSensitivity + 0.1) * 10) / 10), "Fare hassasiyeti güncellendi")
                        }

                        Rectangle {
                            width: parent.width; height: 52; radius: Theme.radiusButton
                            color: nsMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                Column {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: "Doğal Kaydırma"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                    Text { text: "Dokunmatik yüzeyde içerik yönünü parmak hareketiyle eşler"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                }
                                DynamicSwitch { checked: SettingsState.naturalScroll }
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
                        height: 36; radius: Theme.radiusButton; color: Theme.surface1
                        border.color: searchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle; border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; spacing: 8
                            Text { text: "󰍉"; color: searchInp.activeFocus ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 14 }
                            TextInput {
                                id: searchInp; Layout.fillWidth: true; Layout.fillHeight: true; verticalAlignment: TextInput.AlignVCenter
                                text: root.shortcutFilter; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; clip: true
                                onTextChanged: root.shortcutFilter = text
                                Text { anchors.verticalCenter: parent.verticalCenter; text: "Kısayol veya eylem ara..."; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 12; visible: parent.text.length === 0 }
                            }
                            Text {
                                visible: root.shortcutFilter.length > 0; text: "✕"; color: Theme.textSecondary; font.pixelSize: 11
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
                            width: ListView.view.width; height: 36; radius: Theme.radiusButton; color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                Text { text: scRow.modelData.action; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                                Rectangle {
                                    implicitWidth: keyText.implicitWidth + 14; implicitHeight: 22; radius: Theme.radiusSmall; color: Theme.surfaceActive; border.color: Theme.borderSubtle; border.width: 1
                                    Text { id: keyText; anchors.centerIn: parent; text: scRow.modelData.keys; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                                }
                            }
                        }

                        Text { anchors.centerIn: parent; visible: root.filteredShortcuts.length === 0; text: "Eşleşen kısayol bulunamadı"; color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 12 }
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

                        Text { text: "Kalıcı Ayar Dosyası"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        Rectangle {
                            width: parent.width; height: 40; radius: Theme.radiusButton; color: Theme.surface1; border.color: Theme.borderSubtle; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                                Text { text: "󰈔"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 14 }
                                Text { Layout.fillWidth: true; text: SettingsState.configPath; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideMiddle }
                            }
                        }

                        RowLayout {
                            width: parent.width; spacing: 10
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 36; radius: Theme.radiusButton
                                color: openCfgMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive; border.color: Theme.accent; border.width: 1
                                Text { anchors.centerIn: parent; text: "Ayar Dosyasını Aç"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                                MouseArea { id: openCfgMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.openConfigFile() }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 36; radius: Theme.radiusButton
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle; border.width: 1
                                Text { anchors.centerIn: parent; text: "Varsayılanlara Sıfırla"; color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: resetMa.containsMouse }
                                MouseArea { id: resetMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.resetDefaults() }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }
                        Text { text: "Yerleşik Eklenti Modülleri"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true }

                        Repeater {
                            model: root.pluginModules
                            delegate: Rectangle {
                                id: pluginRow
                                required property var modelData
                                readonly property bool isOn: !!SettingsState[modelData.prop]
                                width: systemCol.width; height: 48; radius: Theme.radiusButton
                                color: pluginMa.containsMouse ? Theme.surfaceHover : Theme.surface1; border.color: Theme.borderSubtle; border.width: 1

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: pluginRow.modelData.icon; color: pluginRow.isOn ? Theme.accent : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 15 }
                                    Column {
                                        Layout.fillWidth: true; spacing: 2
                                        Text { width: parent.width; text: pluginRow.modelData.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                                        Text { width: parent.width; text: pluginRow.modelData.desc; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    DynamicSwitch { checked: pluginRow.isOn }
                                }
                                MouseArea {
                                    id: pluginMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsState.toggleBoolSetting(pluginRow.modelData.prop, pluginRow.modelData.label + " güncellendi")
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
                height: 40
                radius: Theme.radiusButton
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
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 76
                        implicitHeight: 26
                        radius: Theme.radiusSmall
                        color: undoMa.containsMouse ? Theme.accent : Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Geri Al"
                            color: undoMa.containsMouse ? Theme.accentOn : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
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
