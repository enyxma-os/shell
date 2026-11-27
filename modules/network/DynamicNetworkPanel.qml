import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

Item {
    id: root

    property string activeTab: "networks" // networks | tools
    property string passwordSsid: ""
    property string passwordText: ""
    property bool showPassword: false
    property bool hiddenOpen: false
    property string hiddenSsid: ""
    property string hiddenPassword: ""
    property bool customDnsOpen: false
    property string customDnsText: ""

    Connections {
        target: NetworkState
        function onPasswordRequired(ssid) {
            root.activeTab = "networks"
            root.passwordSsid = ssid
            root.passwordText = ""
            root.showPassword = false
        }
        function onIsOpenChanged() {
            if (!NetworkState.isOpen) {
                root.passwordSsid = ""
                root.passwordText = ""
                root.hiddenOpen = false
            }
        }
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 42
        anchors.rightMargin: 12
        width: 364
        height: Math.min(parent.height - 64, contentCol.implicitHeight + Theme.spacingMedium * 2)

        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        // Kart ici tiklamalari yakala; disariya tiklama overlay'i kapatir
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacingMedium
            spacing: Theme.spacingSmall

            // ── Baslik ve Hizli Wi-Fi / Tara / Kapat ───────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: I18n.t("Ağ ve Wi-Fi", "Network & Wi-Fi")
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    Layout.fillWidth: true
                }

                // Wi-Fi Radyo Anahtari
                Rectangle {
                    visible: NetworkState.hasWifiDevice
                    implicitWidth: 56
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: NetworkState.wifiEnabled ? Theme.surfaceActive : Theme.surface1
                    border.color: NetworkState.wifiEnabled ? Theme.accent : Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: NetworkState.wifiEnabled ? "Wi-Fi" : I18n.t("Kapalı", "Off")
                        color: NetworkState.wifiEnabled ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkState.toggleWifi()
                    }
                }

                // Yenile / Tara
                Rectangle {
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    implicitWidth: 26
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: scanMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: NetworkState.isScanning ? "…" : "↻"
                        color: NetworkState.isScanning ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        id: scanMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkState.scanWifi(true)
                    }
                }

                // Kapat
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Theme.radiusButton
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkState.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── Aktif Baglanti Telemetrisi ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: activeCol.implicitHeight + 16
                radius: Theme.radiusButton
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: Theme.borderWidth

                ColumnLayout {
                    id: activeCol
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: {
                                if (!NetworkState.isConnected) return I18n.t("Bağlantı Yok", "No Connection")
                                if (NetworkState.connectionType === "wifi") return (NetworkState.ssid || NetworkState.connectionName || "Wi-Fi")
                                return NetworkState.connectionName || "Ethernet"
                            }
                            color: NetworkState.isConnected ? Theme.textPrimary : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeNormal
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Bant rozeti
                        Rectangle {
                            visible: NetworkState.isConnected && NetworkState.bandFromFreq(NetworkState.frequency) !== ""
                            implicitWidth: bandLbl.implicitWidth + 10
                            implicitHeight: 18
                            radius: Theme.radiusButton
                            color: Theme.surfaceActive
                            border.color: Theme.accent
                            border.width: 1

                            Text {
                                id: bandLbl
                                anchors.centerIn: parent
                                text: NetworkState.bandFromFreq(NetworkState.frequency)
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            visible: NetworkState.isConnected && NetworkState.connectionType === "wifi"
                            text: I18n.pct(NetworkState.signalStrength)
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }

                    // Sinyal Cubugu
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 5
                        radius: 3
                        color: Theme.surfaceActive

                        Rectangle {
                            height: parent.height
                            radius: 3
                            color: Theme.accent
                            width: {
                                if (!NetworkState.isConnected) return 0
                                if (NetworkState.connectionType === "wifi") return parent.width * (NetworkState.signalStrength / 100)
                                return parent.width
                            }

                            Behavior on width {
                                enabled: !Theme.reduceMotion
                                NumberAnimation {
                                    duration: Theme.animNormal
                                    easing.type: Easing.OutQuint
                                }
                            }
                        }
                    }

                    // Arayuz + Tikla Kopyala IP + Kes
                    RowLayout {
                        Layout.fillWidth: true
                        visible: NetworkState.isConnected
                        spacing: 6

                        Text {
                            text: NetworkState.interfaceName
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text: "•"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            text: NetworkState.copiedHint !== "" ? NetworkState.copiedHint : (NetworkState.ipAddress || "-")
                            color: NetworkState.copiedHint !== "" ? Theme.success : (ipMa.containsMouse ? Theme.accent : Theme.textPrimary)
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.fillWidth: true
                            elide: Text.ElideRight

                            MouseArea {
                                id: ipMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkState.copyText(NetworkState.ipAddress, "IP")
                            }
                        }

                        Rectangle {
                            visible: SettingsState.enableWifiQr && NetworkState.isConnected && NetworkState.connectionType === "wifi"
                            implicitWidth: 48
                            implicitHeight: 20
                            radius: Theme.radiusButton
                            color: NetworkState.qrOpen ? Theme.accent : (qrBtnMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive)
                            border.color: NetworkState.qrOpen || qrBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰐲 QR"
                                color: NetworkState.qrOpen ? Theme.accentOn : Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: qrBtnMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkState.openWifiQr()
                            }
                        }

                        Rectangle {
                            implicitWidth: 44
                            implicitHeight: 20
                            radius: Theme.radiusButton
                            color: discMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                            border.color: discMa.containsMouse ? Theme.danger : Theme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("Kes", "Disconnect")
                                color: discMa.containsMouse ? Theme.danger : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: discMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: !NetworkState.actionBusy
                                onClicked: NetworkState.disconnectActive()
                            }
                        }
                    }

                    // Canli Trafik Seridi
                    RowLayout {
                        Layout.fillWidth: true
                        visible: NetworkState.isConnected
                        spacing: 12

                        Text {
                            text: "↓ " + NetworkState.formatRate(NetworkState.rxRate)
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }

                        Text {
                            text: "↑ " + NetworkState.formatRate(NetworkState.txRate)
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            visible: NetworkState.linkSpeed.length > 0
                            text: NetworkState.linkSpeed
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }
                    }

                    // Wi-Fi QR Paylasim Karti
                    Rectangle {
                        visible: SettingsState.enableWifiQr && NetworkState.qrOpen && NetworkState.isConnected && NetworkState.connectionType === "wifi"
                        Layout.fillWidth: true
                        implicitHeight: qrCol.implicitHeight + 16
                        radius: Theme.radiusButton
                        color: Theme.bgDark
                        border.color: Theme.accent
                        border.width: 1

                        ColumnLayout {
                            id: qrCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Wi-Fi QR · " + NetworkState.qrSsid
                                    color: Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "✕"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: NetworkState.closeWifiQr() }
                                }
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: 164
                                implicitHeight: 164
                                radius: Theme.radiusSmall
                                color: Theme.textPrimary

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    visible: !NetworkState.qrBusy && NetworkState.qrImagePath !== ""
                                    source: NetworkState.qrImagePath
                                    cache: false
                                    smooth: false
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: NetworkState.qrBusy || NetworkState.qrError !== ""
                                    text: NetworkState.qrBusy ? I18n.t("Üretiliyor...", "Generating...") : NetworkState.qrError
                                    color: Theme.bgDark
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }

            // ── Sekme Cubugu: Aglar | DNS & Hiz ─────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { key: "networks", label: I18n.t("Ağlar", "Networks") },
                        { key: "tools", label: I18n.t("DNS & Hız", "DNS & Speed") }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: root.activeTab === modelData.key
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusButton
                        color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: active ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.active ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: parent.active
                        }

                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeTab = modelData.key
                        }
                    }
                }
            }

            // ── SEKME 1: AGLAR (Wi-Fi Listesi, Gizli Ag, VPN) ───────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.activeTab === "networks"
                spacing: Theme.spacingXS

                // Hata bildirimi
                Text {
                    Layout.fillWidth: true
                    visible: NetworkState.actionError.length > 0
                    text: NetworkState.actionError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                // Wi-Fi Kapali durumu
                Rectangle {
                    Layout.fillWidth: true
                    visible: NetworkState.hasWifiDevice && !NetworkState.wifiEnabled
                    implicitHeight: 64
                    radius: Theme.radiusButton
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        Text {
                            text: I18n.t("Wi-Fi radyosu kapalı", "Wi-Fi radio is off")
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            implicitWidth: 88
                            implicitHeight: 26
                            radius: Theme.radiusButton
                            color: Theme.surfaceActive
                            border.color: Theme.accent
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("Wi-Fi'yi Aç", "Enable Wi-Fi")
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkState.toggleWifi()
                            }
                        }
                    }
                }

                // Wi-Fi Listesi
                ListView {
                    id: wifiList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(220, Math.max(40, contentHeight))
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    clip: true
                    spacing: 4
                    model: NetworkState.wifiNetworks

                    delegate: ColumnLayout {
                        id: netItem
                        required property var modelData
                        width: wifiList.width
                        spacing: 4

                        readonly property bool askingPass: root.passwordSsid === modelData.ssid

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: Theme.radiusButton
                            color: modelData.inUse ? Theme.surfaceActive : (netMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.inUse ? Theme.accent : (netMa.containsMouse ? Theme.accent : Theme.borderSubtle)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: I18n.pct(modelData.signal)
                                    color: modelData.inUse ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 34
                                }

                                Text {
                                    text: modelData.ssid
                                    color: modelData.inUse ? Theme.accent : Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: modelData.inUse
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: NetworkState.connectingSsid === modelData.ssid
                                    text: "…"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                }

                                Text {
                                    visible: modelData.band !== ""
                                    text: modelData.band
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Text {
                                    visible: modelData.secured
                                    text: "🔒"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                }

                                // Kayitli / Unut
                                Rectangle {
                                    visible: modelData.saved && !modelData.inUse
                                    implicitWidth: forgetDynTxt.implicitWidth + 12
                                    implicitHeight: 20
                                    radius: Theme.radiusButton
                                    color: forgetMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                                    border.color: forgetMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                    border.width: 1

                                    Text {
                                        id: forgetDynTxt
                                        anchors.centerIn: parent
                                        text: I18n.t("Unut", "Forget")
                                        color: forgetMa.containsMouse ? Theme.danger : Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                    }

                                    MouseArea {
                                        id: forgetMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NetworkState.forgetNetwork(modelData.ssid)
                                    }
                                }
                            }

                            MouseArea {
                                id: netMa
                                anchors.fill: parent
                                anchors.rightMargin: (modelData.saved && !modelData.inUse) ? 44 : 0
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: !NetworkState.actionBusy
                                onClicked: {
                                    if (modelData.inUse) return
                                    if (modelData.saved || !modelData.secured) {
                                        root.passwordSsid = ""
                                        NetworkState.connectWifi(modelData.ssid, "")
                                    } else {
                                        if (root.passwordSsid === modelData.ssid) {
                                            root.passwordSsid = ""
                                        } else {
                                            root.passwordSsid = modelData.ssid
                                            root.passwordText = ""
                                            passField.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }

                        // Satir ici parola kutusu
                        RowLayout {
                            Layout.fillWidth: true
                            visible: netItem.askingPass
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 28
                                radius: Theme.radiusButton
                                color: Theme.surface1
                                border.color: passField.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                                border.width: 1

                                TextInput {
                                    id: passField
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 28
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                    text: root.passwordText
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    clip: true
                                    onTextChanged: root.passwordText = text
                                    Keys.onReturnPressed: {
                                        if (root.passwordText.length > 0) {
                                            var target = modelData.ssid
                                            var pw = root.passwordText
                                            root.passwordSsid = ""
                                            root.passwordText = ""
                                            NetworkState.connectWifi(target, pw)
                                        }
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.showPassword ? "◉" : "◎"
                                    color: Theme.textSecondary
                                    font.pixelSize: 12
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showPassword = !root.showPassword
                                    }
                                }
                            }

                            Rectangle {
                                implicitWidth: 64
                                implicitHeight: 28
                                radius: Theme.radiusButton
                                color: Theme.surfaceActive
                                border.color: Theme.accent
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: I18n.t("Bağlan", "Connect")
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.passwordText.length > 0) {
                                            var target = modelData.ssid
                                            var pw = root.passwordText
                                            root.passwordSsid = ""
                                            root.passwordText = ""
                                            NetworkState.connectWifi(target, pw)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Gizli Ag Baglantisi
                RowLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    Text {
                        text: root.hiddenOpen ? I18n.t("▾ Gizli ağa bağlan", "▾ Connect to hidden network") : I18n.t("▸ Gizli ağa bağlan", "▸ Connect to hidden network")
                        color: hiddenToggleMa.containsMouse ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        MouseArea {
                            id: hiddenToggleMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.hiddenOpen = !root.hiddenOpen
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled && root.hiddenOpen
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: hiddenSsidInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: 1
                        TextInput {
                            id: hiddenSsidInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.hiddenSsid
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            clip: true
                            onTextChanged: root.hiddenSsid = text
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: I18n.t("Gizli SSID", "Hidden SSID")
                                color: Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                visible: parent.text.length === 0
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Theme.radiusButton
                            color: Theme.surface1
                            border.color: hiddenPassInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                            border.width: 1
                            TextInput {
                                id: hiddenPassInput
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                text: root.hiddenPassword
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                clip: true
                                onTextChanged: root.hiddenPassword = text
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: I18n.t("Parola", "Password")
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    visible: parent.text.length === 0
                                }
                            }
                        }
                        Rectangle {
                            implicitWidth: 64
                            implicitHeight: 28
                            radius: Theme.radiusButton
                            color: Theme.surfaceActive
                            border.color: Theme.accent
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("Bağlan", "Connect")
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.hiddenSsid.trim().length > 0) {
                                        var s = root.hiddenSsid.trim()
                                        var p = root.hiddenPassword
                                        root.hiddenOpen = false
                                        root.hiddenSsid = ""
                                        root.hiddenPassword = ""
                                        NetworkState.connectHiddenWifi(s, p)
                                    }
                                }
                            }
                        }
                    }
                }

                // VPN / WireGuard Profilleri (varsa)
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.vpnProfiles.length > 0
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.borderSubtle
                    }

                    Text {
                        text: "VPN / WIREGUARD"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Repeater {
                        model: NetworkState.vpnProfiles
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Theme.radiusButton
                            color: modelData.active ? Theme.surfaceActive : Theme.surface1
                            border.color: modelData.active ? Theme.accent : Theme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                Text {
                                    text: modelData.name
                                    color: modelData.active ? Theme.accent : Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeSmall
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.active ? I18n.t("Açık", "On") : I18n.t("Kapalı", "Off")
                                    color: modelData.active ? Theme.success : Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: !NetworkState.actionBusy
                                onClicked: NetworkState.toggleVpn(modelData.name, modelData.active)
                            }
                        }
                    }
                }
            }

            // ── SEKME 2: DNS & HIZ TESTI ────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.activeTab === "tools"
                spacing: Theme.spacingSmall

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: I18n.t("DNS SAĞLAYICISI", "DNS PROVIDER")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: NetworkState.dnsBusy ? I18n.t("uygulanıyor...", "applying...") : ""
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        visible: NetworkState.dnsBusy
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [
                            { label: "DHCP", key: "dhcp" },
                            { label: "Cloudflare", key: "cloudflare" },
                            { label: "Google", key: "google" },
                            { label: I18n.t("Özel", "Custom"), key: "custom" }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active: NetworkState.dnsProvider === modelData.key
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Theme.radiusButton
                            color: active ? Theme.surfaceActive : (dnsBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: active ? Theme.accent : (dnsBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle)
                            border.width: Theme.borderWidth

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: parent.active ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: dnsBtnMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: !NetworkState.dnsBusy && NetworkState.isConnected
                                onClicked: {
                                    if (modelData.key === "custom") {
                                        root.customDnsOpen = !root.customDnsOpen
                                        if (root.customDnsOpen && root.customDnsText === "") {
                                            root.customDnsText = NetworkState.dnsServers.join(", ")
                                        }
                                    } else {
                                        root.customDnsOpen = false
                                        NetworkState.setDnsProvider(modelData.key, [])
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: NetworkState.isConnected && NetworkState.dnsServers.length > 0
                    text: I18n.t("Aktif: ", "Active: ") + NetworkState.dnsServers.join(", ")
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                // Ozel DNS giris alani
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.customDnsOpen
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radiusButton
                        color: Theme.surface1
                        border.color: customInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: 1

                        TextInput {
                            id: customInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.customDnsText
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            clip: true
                            onTextChanged: root.customDnsText = text
                            Keys.onReturnPressed: {
                                var srvs = root.customDnsText.split(/[ ,]+/).filter(function(s) { return s.trim().length > 0 })
                                if (srvs.length > 0) NetworkState.setDnsProvider("custom", srvs)
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: 64
                        implicitHeight: 28
                        radius: Theme.radiusButton
                        color: Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: I18n.t("Kaydet", "Save")
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !NetworkState.dnsBusy
                            onClicked: {
                                var srvs = root.customDnsText.split(/[ ,]+/).filter(function(s) { return s.trim().length > 0 })
                                if (srvs.length > 0) NetworkState.setDnsProvider("custom", srvs)
                            }
                        }
                    }
                }

                // DNS uygula butonu
                Rectangle {
                    Layout.fillWidth: true
                    visible: NetworkState.dnsPendingApply && NetworkState.isConnected
                    implicitHeight: 28
                    radius: Theme.radiusButton
                    color: Theme.surfaceActive
                    border.color: Theme.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: I18n.t("Yeniden Bağlan ve DNS'i Uygula", "Reconnect & Apply DNS")
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !NetworkState.dnsBusy
                        onClicked: NetworkState.reconnect()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: NetworkState.dnsError.length > 0
                    text: NetworkState.dnsError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.borderSubtle
                }

                // Hiz Testi
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: I18n.t("HIZ TESTİ", "SPEED TEST")
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 64
                        implicitHeight: 22
                        radius: Theme.radiusButton
                        color: speedBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: speedBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: NetworkState.speedRunning ? I18n.t("durdur", "stop") : I18n.t("başlat", "start")
                            color: NetworkState.isConnected ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: speedBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: NetworkState.isConnected || NetworkState.speedRunning
                            onClicked: {
                                if (NetworkState.speedRunning) NetworkState.cancelSpeedTest()
                                else NetworkState.startSpeedTest()
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: NetworkState.speedPhase !== "idle" && NetworkState.speedPhase !== "cancelled"

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("Sunucu", "Server"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        Text { text: NetworkState.speedEdgeText; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("Gecikme", "Latency"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        Text { text: NetworkState.speedPhase === "latency" ? I18n.t("Ölçülüyor...", "Measuring...") : (NetworkState.speedPingMs > 0 ? (NetworkState.speedPingMs.toFixed(1) + " ms") : "-"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("İndirme", "Download"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        Text { text: NetworkState.speedPhase === "download" ? I18n.t("Ölçülüyor...", "Measuring...") : (NetworkState.speedDownloadMbps > 0 ? (NetworkState.speedDownloadMbps.toFixed(1) + " Mbps") : "-"); color: NetworkState.speedDownloadMbps > 0 ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("Yükleme", "Upload"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        Text { text: NetworkState.speedPhase === "upload" ? I18n.t("Ölçülüyor...", "Measuring...") : (NetworkState.speedUploadMbps > 0 ? (NetworkState.speedUploadMbps.toFixed(1) + " Mbps") : "-"); color: NetworkState.speedUploadMbps > 0 ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedPhase === "success" && NetworkState.speedLastStamp.length > 0
                        text: I18n.t("Tamamlandı • ", "Completed • ") + NetworkState.speedLastStamp
                        color: Theme.success
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedErrorText.length > 0
                        text: NetworkState.speedErrorText
                        color: Theme.danger
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

            // ── Alt Buton: Gelismis Ag Ayarlari ──────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Theme.radiusButton
                color: netSettingsMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                border.color: netSettingsMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: Theme.borderWidth

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("Gelişmiş Ağ Ayarları", "Advanced Network Settings")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                }

                MouseArea {
                    id: netSettingsMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        NetworkState.close()
                        NetworkState.openSettings()
                    }
                }
            }
        }
    }
}

