import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

/**
 * GothamSettingsPanel — Enyxma Gotham 2.0 masaustu kontrol merkezi.
 *
 * Deterministik anchors yerlesimi ile yan panel ve icerik alani
 * birbirinden kesin sinirlarla ayrilir; tasma veya ust uste binme olusmaz.
 */
Item {
    id: root

    property string shortcutFilter: ""

    readonly property var navItems: [
        { key: "appearance", icon: "󰏘", label: "GÖRÜNÜM",    title: "GÖRÜNÜM VE TEMA",     subtitle: "Tasarım kimliği, duvar kağıdı ve üst çubuk geometrisi" },
        { key: "bar",        icon: "󰕮", label: "ÜST ÇUBUK",  title: "ÜST ÇUBUK MODÜLLERİ", subtitle: "Panelde görünecek bileşenleri canlı olarak yönetin" },
        { key: "shortcuts",  icon: "󰌌", label: "KISAYOLLAR", title: "KLAVYE KISAYOLLARI",  subtitle: "Aktif Hyprland tuş atamalarını arayın ve inceleyin" },
        { key: "system",     icon: "󰒓", label: "SİSTEM",     title: "SİSTEM VE MODÜLLER",  subtitle: "Kalıcı yapılandırma dosyası ve yerleşik eklenti anahtarları" }
    ]

    readonly property var barModules: [
        { prop: "showWorkspaces",    icon: "󰍹", label: "ÇALIŞMA ALANLARI",      desc: "Aktif ve dolu masaüstü numaraları" },
        { prop: "showClock",         icon: "󰥔", label: "SAAT VE HAVA DURUMU",   desc: "Tarih, saat ve canlı sıcaklık bilgisi" },
        { prop: "showSystemStats",   icon: "󰍛", label: "SİSTEM TELEMETRİ",      desc: "CPU, bellek ve disk kullanım özeti" },
        { prop: "showNetwork",       icon: "󰖩", label: "AĞ VE WI-FI",           desc: "Bağlantı durumu, VPN ve hız göstergesi" },
        { prop: "showVolume",        icon: "󰕾", label: "SES DÜZEYİ",            desc: "Çıkış sesi ve hızlı sessize alma" },
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

    // Endustriyel Gotham anahtar bileseni
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

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 64, 860)
        height: Math.min(parent.height - 96, 560)
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1
        clip: true

        // Kart ici tiklamalarin disariya sizmasini engelle
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
            z: 10
        }

        // ── SOL YAN PANEL ────────────────────────────────────────────────────
        Rectangle {
            id: sidebar
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 228
            color: Theme.bgDark

            // Sag dikey ayirici
            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                color: Theme.borderSubtle
            }

            // Ust marka basligi
            Column {
                id: brandHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 4

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
                    font.letterSpacing: 0.8
                }
            }

            Rectangle {
                id: brandDivider
                anchors.top: brandHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 16
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: Theme.borderSubtle
            }

            // Navigasyon ogeleri
            Column {
                anchors.top: brandDivider.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 14
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 6

                Repeater {
                    model: root.navItems
                    delegate: Rectangle {
                        id: navBtn
                        required property var modelData
                        readonly property bool active: SettingsState.activeTab === modelData.key
                        width: parent.width
                        height: 40
                        radius: 0
                        color: active ? Theme.surfaceActive : (navMa.containsMouse ? Theme.surfaceHover : "transparent")
                        border.color: active ? Theme.borderFocus : "transparent"
                        border.width: 1

                        // Sol 2px aktif gostergesi
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
                            anchors.leftMargin: 14
                            anchors.rightMargin: 10
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
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                font.bold: navBtn.active
                                font.letterSpacing: 0.6
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

            // Alt durum rozeti
            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
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

            // Ust baslik seridi
            Item {
                id: contentHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 64

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

            // Ana icerik alani
            Item {
                id: bodyArea
                anchors.top: contentHeader.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                clip: true

                // ── SEKME 1: GORUNUM ─────────────────────────────────────────
                Flickable {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "appearance"
                    contentHeight: appearanceCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: appearanceCol
                        width: parent.width
                        spacing: 14

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
                                    implicitHeight: 74
                                    radius: 0
                                    color: active ? Theme.surfaceActive : (themeMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                                    border.color: active ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6

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

                                                Text {
                                                    id: activeLbl
                                                    anchors.centerIn: parent
                                                    text: "AKTİF"
                                                    color: Theme.accentOn
                                                    font.family: Theme.fontMono
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
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

                        // Duvar kagidi galerisi karti
                        Rectangle {
                            width: parent.width
                            height: 54
                            radius: 0
                            color: wpMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Text {
                                    text: "󰸉"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 18
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "DUVAR KAĞIDI GALERİSİ"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Arka plan görselini değiştirin ve renk paletini yenileyin"
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    implicitWidth: 68
                                    implicitHeight: 28
                                    radius: 0
                                    color: Theme.surface2
                                    border.color: wpMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "AÇ →"
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            MouseArea {
                                id: wpMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsState.close()
                                    WallpaperState.openPicker()
                                }
                            }
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

                        // Hareket azaltma
                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 0
                            color: rmMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "HAREKET VE ANİMASYONLARI AZALT"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Panel geçişleri ve açılış animasyonlarını anlık hale getirir"
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                GothamSwitch { checked: SettingsState.reduceMotion }
                            }

                            MouseArea {
                                id: rmMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsState.reduceMotion = !SettingsState.reduceMotion
                                    SettingsState.save()
                                }
                            }
                        }

                        // Ust cubuk gorunurlugu
                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 0
                            color: bvMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "ÜST ÇUBUK GÖRÜNÜR"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Ekranın üstündeki Enyxma durum çubuğunu gösterir veya gizler"
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                GothamSwitch { checked: SettingsState.barVisible }
                            }

                            MouseArea {
                                id: bvMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsState.barVisible = !SettingsState.barVisible
                                    SettingsState.save()
                                }
                            }
                        }

                        // Ust cubuk yuksekligi
                        Rectangle {
                            width: parent.width
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
                                        text: "ÜST ÇUBUK YÜKSEKLİĞİ"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Üst panelin piksel cinsinden dikey kalınlığı"
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
                                    color: minusMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                                    border.color: minusMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    MouseArea { id: minusMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(-1) }
                                }

                                Text {
                                    text: Theme.barHeight + " px"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: 52
                                }

                                Rectangle {
                                    implicitWidth: 28
                                    implicitHeight: 26
                                    radius: 0
                                    color: plusMa.containsMouse ? Theme.surfaceHover : Theme.surface2
                                    border.color: plusMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                    border.width: 1

                                    Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 13 }
                                    MouseArea { id: plusMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: SettingsState.adjustBarHeight(1) }
                                }
                            }
                        }
                    }
                }

                // ── SEKME 2: UST CUBUK MODULLERI ─────────────────────────────
                Item {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "bar"

                    RowLayout {
                        id: barSummaryRow
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 22

                        Text {
                            text: "AKTİF MODÜLLER"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.activeBarModuleCount + " / " + root.barModules.length + " aktif"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    ListView {
                        anchors.top: barSummaryRow.bottom
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        spacing: 6
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.barModules

                        delegate: Rectangle {
                            id: barRow
                            required property var modelData
                            readonly property bool isOn: !!SettingsState[modelData.prop]
                            width: ListView.view.width
                            height: 48
                            radius: 0
                            color: barRowMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Text {
                                    text: barRow.modelData.icon
                                    color: barRow.isOn ? Theme.accent : Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 15
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: barRow.modelData.label
                                        color: Theme.textPrimary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: barRow.modelData.desc
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                GothamSwitch { checked: barRow.isOn }
                            }

                            MouseArea {
                                id: barRowMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsState[barRow.modelData.prop] = !SettingsState[barRow.modelData.prop]
                                    SettingsState.save()
                                }
                            }
                        }
                    }
                }

                // ── SEKME 3: KISAYOLLAR ──────────────────────────────────────
                Item {
                    anchors.fill: parent
                    visible: SettingsState.activeTab === "shortcuts"

                    Rectangle {
                        id: searchBox
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 36
                        radius: 0
                        color: Theme.surface1
                        border.color: searchInp.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                text: "󰍉"
                                color: searchInp.activeFocus ? Theme.accent : Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                            }

                            TextInput {
                                id: searchInp
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: root.shortcutFilter
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                clip: true
                                onTextChanged: root.shortcutFilter = text

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Kısayol veya eylem ara..."
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    visible: parent.text.length === 0
                                }
                            }

                            Rectangle {
                                visible: root.shortcutFilter.length > 0
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: 0
                                color: clearMa.containsMouse ? Theme.surfaceHover : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: clearMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: searchInp.text = ""
                                }
                            }
                        }
                    }

                    ListView {
                        anchors.top: searchBox.bottom
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.filteredShortcuts

                        delegate: Rectangle {
                            id: scRow
                            required property var modelData
                            width: ListView.view.width
                            height: 36
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: scRow.modelData.action
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    implicitWidth: keyText.implicitWidth + 14
                                    implicitHeight: 22
                                    radius: 0
                                    color: Theme.surfaceActive
                                    border.color: Theme.borderSubtle
                                    border.width: 1

                                    Text {
                                        id: keyText
                                        anchors.centerIn: parent
                                        text: scRow.modelData.keys
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.filteredShortcuts.length === 0
                            text: "Eşleşen kısayol bulunamadı"
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                    }
                }

                // ── SEKME 4: SISTEM ──────────────────────────────────────────
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

                        Text {
                            text: "KALICI AYAR DOSYASI"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Rectangle {
                            width: parent.width
                            height: 40
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: "󰈔"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: SettingsState.configPath
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 36
                                radius: 0
                                color: openCfgMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                                border.color: Theme.accent
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "AYAR DOSYASINI AÇ"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    id: openCfgMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsState.openConfigFile()
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 36
                                radius: 0
                                color: resetMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: resetMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "VARSAYILANLARA SIFIRLA"
                                    color: resetMa.containsMouse ? Theme.danger : Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: resetMa.containsMouse
                                }

                                MouseArea {
                                    id: resetMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsState.resetDefaults()
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

                        Text {
                            text: "YERLEŞİK EKLENTİ MODÜLLERİ"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Repeater {
                            model: root.pluginModules
                            delegate: Rectangle {
                                id: pluginRow
                                required property var modelData
                                readonly property bool isOn: !!SettingsState[modelData.prop]
                                width: systemCol.width
                                height: 48
                                radius: 0
                                color: pluginMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                                border.color: Theme.borderSubtle
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Text {
                                        text: pluginRow.modelData.icon
                                        color: pluginRow.isOn ? Theme.accent : Theme.textMuted
                                        font.family: Theme.fontMono
                                        font.pixelSize: 15
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            width: parent.width
                                            text: pluginRow.modelData.label
                                            color: Theme.textPrimary
                                            font.family: Theme.fontMono
                                            font.pixelSize: 11
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: pluginRow.modelData.desc
                                            color: Theme.textSecondary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    GothamSwitch { checked: pluginRow.isOn }
                                }

                                MouseArea {
                                    id: pluginMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SettingsState[pluginRow.modelData.prop] = !SettingsState[pluginRow.modelData.prop]
                                        SettingsState.save()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
