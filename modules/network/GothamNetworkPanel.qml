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
        width: 368
        height: Math.min(parent.height - 64, contentCol.implicitHeight + 28)

        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // Ust 2px Gotham kehribar vurgu seridi
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.accent
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            spacing: 8

            // ── Baslik: AG // arayuz ─────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: NetworkState.interfaceName ? (I18n.t("AĞ // ", "NETWORK // ") + NetworkState.interfaceName) : I18n.t("AĞ // ÇEVRİMDIŞI", "NETWORK // OFFLINE")
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: NetworkState.hasWifiDevice
                    implicitWidth: wifiBadgeTxt.implicitWidth + 12
                    implicitHeight: 22
                    radius: 0
                    color: NetworkState.wifiEnabled ? Theme.surfaceActive : Theme.surface1
                    border.color: NetworkState.wifiEnabled ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        id: wifiBadgeTxt
                        anchors.centerIn: parent
                        text: NetworkState.wifiEnabled ? I18n.t("WI-FI AÇIK", "WI-FI ON") : I18n.t("WI-FI KAPALI", "WI-FI OFF")
                        color: NetworkState.wifiEnabled ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkState.toggleWifi()
                    }
                }

                Rectangle {
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    implicitWidth: 46
                    implicitHeight: 22
                    radius: 0
                    color: scanMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: scanMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: NetworkState.isScanning ? "..." : I18n.t("TARA", "SCAN")
                        color: NetworkState.isScanning ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: scanMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkState.scanWifi(true)
                    }
                }

                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 0
                    color: closeMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                    border.color: closeMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeNormal
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

            // ── Telemetri Blogu ──────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: teleCol.implicitHeight + 14
                radius: 0
                color: Theme.surface1
                border.color: Theme.borderSubtle
                border.width: 1

                ColumnLayout {
                    id: teleCol
                    anchors.fill: parent
                    anchors.margins: 7
                    spacing: 5

                    // Keskin sinyal cubugu
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 0
                        color: Theme.surfaceActive

                        Rectangle {
                            height: parent.height
                            radius: 0
                            color: Theme.accent
                            width: {
                                if (!NetworkState.isConnected) return 0
                                if (NetworkState.connectionType === "wifi") return parent.width * (NetworkState.signalStrength / 100)
                                return parent.width
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "SSID"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 56 }
                        Text {
                            text: NetworkState.isConnected ? (NetworkState.ssid || NetworkState.connectionName || "-") : I18n.t("BAĞLANTI YOK", "NO CONNECTION")
                            color: NetworkState.isConnected ? Theme.textPrimary : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: NetworkState.isConnected && NetworkState.bandFromFreq(NetworkState.frequency) !== ""
                            text: NetworkState.bandFromFreq(NetworkState.frequency)
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }
                        Text {
                            visible: NetworkState.isConnected && NetworkState.connectionType === "wifi"
                            text: "%" + NetworkState.signalStrength
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: NetworkState.isConnected
                        Text { text: "IP"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 56 }
                        Text {
                            text: NetworkState.copiedHint !== "" ? NetworkState.copiedHint : (NetworkState.ipAddress || "-")
                            color: NetworkState.copiedHint !== "" ? Theme.success : (ipMa.containsMouse ? Theme.accent : Theme.textPrimary)
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            Layout.fillWidth: true

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
                            implicitWidth: 46
                            implicitHeight: 18
                            radius: 0
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
                            implicitHeight: 18
                            radius: 0
                            color: discMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                            border.color: discMa.containsMouse ? Theme.danger : Theme.borderSubtle
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("KES", "DISCONNECT")
                                color: discMa.containsMouse ? Theme.danger : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 10
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

                    RowLayout {
                        Layout.fillWidth: true
                        visible: NetworkState.isConnected
                        Text { text: I18n.t("TRAFİK", "TRAFFIC"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 56 }
                        Text { text: "RX " + NetworkState.formatRate(NetworkState.rxRate); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11 }
                        Text { text: "|"; color: Theme.borderSubtle; font.family: Theme.fontMono; font.pixelSize: 11 }
                        Text { text: "TX " + NetworkState.formatRate(NetworkState.txRate); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }

                    // Wi-Fi QR Paylasim Karti
                    Rectangle {
                        visible: SettingsState.enableWifiQr && NetworkState.qrOpen && NetworkState.isConnected && NetworkState.connectionType === "wifi"
                        Layout.fillWidth: true
                        implicitHeight: qrCol.implicitHeight + 16
                        radius: 0
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
                                    text: "WI-FI QR // " + NetworkState.qrSsid
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "×"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 13
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: NetworkState.closeWifiQr() }
                                }
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: 164
                                implicitHeight: 164
                                radius: 0
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
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }
            }

            // ── Keskin Sekme Cubugu: AGLAR | DNS & HIZ ───────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        { key: "networks", label: I18n.t("AĞLAR", "NETWORKS") },
                        { key: "tools", label: I18n.t("DNS & HIZ", "DNS & SPEED") }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: root.activeTab === modelData.key
                        Layout.fillWidth: true
                        implicitHeight: 26
                        radius: 0
                        color: active ? Theme.surfaceActive : (tabMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                        border.color: active ? Theme.accent : Theme.borderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.active ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.bold: parent.active
                            font.letterSpacing: 1
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

            // ── SEKME 1: AGLAR ───────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.activeTab === "networks"
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    visible: NetworkState.actionError.length > 0
                    text: "! " + NetworkState.actionError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    visible: NetworkState.hasWifiDevice && !NetworkState.wifiEnabled
                    implicitHeight: 54
                    radius: 0
                    color: Theme.surface1
                    border.color: Theme.borderSubtle
                    border.width: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        Text { text: "WI-FI RADYOSU KAPALI"; color: Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                        Rectangle {
                            implicitWidth: 74
                            implicitHeight: 24
                            radius: 0
                            color: Theme.surfaceActive
                            border.color: Theme.accent
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "[AÇ]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 11 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: NetworkState.toggleWifi() }
                        }
                    }
                }

                ListView {
                    id: wifiList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(220, Math.max(36, contentHeight))
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    clip: true
                    spacing: 3
                    model: NetworkState.wifiNetworks

                    delegate: ColumnLayout {
                        id: netItem
                        required property var modelData
                        width: wifiList.width
                        spacing: 3
                        readonly property bool askingPass: root.passwordSsid === modelData.ssid

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 0
                            color: modelData.inUse ? Theme.surfaceActive : (netMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: modelData.inUse ? Theme.accent : (netMa.containsMouse ? Theme.accent : Theme.borderSubtle)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: "%" + modelData.signal
                                    color: modelData.inUse ? Theme.accent : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 34
                                }

                                Text {
                                    text: modelData.ssid
                                    color: modelData.inUse ? Theme.accent : Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.bold: modelData.inUse
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: NetworkState.connectingSsid === modelData.ssid
                                    text: "[...]"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Text {
                                    visible: modelData.secured
                                    text: "WPA"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                }

                                Rectangle {
                                    visible: modelData.saved && !modelData.inUse
                                    implicitWidth: 44
                                    implicitHeight: 18
                                    radius: 0
                                    color: forgetMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                                    border.color: forgetMa.containsMouse ? Theme.danger : Theme.borderSubtle
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "[UNUT]"
                                        color: forgetMa.containsMouse ? Theme.danger : Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
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
                                anchors.rightMargin: (modelData.saved && !modelData.inUse) ? 48 : 0
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

                        RowLayout {
                            Layout.fillWidth: true
                            visible: netItem.askingPass
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 26
                                radius: 0
                                color: Theme.surface1
                                border.color: passField.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                                border.width: 1

                                TextInput {
                                    id: passField
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 24
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                    text: root.passwordText
                                    color: Theme.textPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
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
                                    text: root.showPassword ? "*" : "•"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showPassword = !root.showPassword
                                    }
                                }
                            }

                            Rectangle {
                                implicitWidth: 68
                                implicitHeight: 26
                                radius: 0
                                color: Theme.surfaceActive
                                border.color: Theme.accent
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "[BAĞLAN]"
                                    color: Theme.accent
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
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

                // Gizli Ag
                Text {
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled
                    text: root.hiddenOpen ? I18n.t("▾ GİZLİ AĞA BAĞLAN", "▾ CONNECT TO HIDDEN NETWORK") : I18n.t("▸ GİZLİ AĞA BAĞLAN", "▸ CONNECT TO HIDDEN NETWORK")
                    color: hiddenMa.containsMouse ? Theme.accent : Theme.textSecondary
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    MouseArea {
                        id: hiddenMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.hiddenOpen = !root.hiddenOpen
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.hasWifiDevice && NetworkState.wifiEnabled && root.hiddenOpen
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 26
                        radius: 0
                        color: Theme.surface1
                        border.color: hiddenSsidInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: 1
                        TextInput {
                            id: hiddenSsidInput
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.hiddenSsid
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            clip: true
                            onTextChanged: root.hiddenSsid = text
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: I18n.t("GİZLİ SSID", "HIDDEN SSID")
                                color: Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                visible: parent.text.length === 0
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 26
                            radius: 0
                            color: Theme.surface1
                            border.color: hiddenPassInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                            border.width: 1
                            TextInput {
                                id: hiddenPassInput
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                text: root.hiddenPassword
                                color: Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                clip: true
                                onTextChanged: root.hiddenPassword = text
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "PAROLA"
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    visible: parent.text.length === 0
                                }
                            }
                        }
                        Rectangle {
                            implicitWidth: 68
                            implicitHeight: 26
                            radius: 0
                            color: Theme.surfaceActive
                            border.color: Theme.accent
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "[BAĞLAN]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
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

                // VPN / WireGuard
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.vpnProfiles.length > 0
                    spacing: 4
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }
                    Text { text: "VPN // WIREGUARD"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true }
                    Repeater {
                        model: NetworkState.vpnProfiles
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 26
                            radius: 0
                            color: modelData.active ? Theme.surfaceActive : Theme.surface1
                            border.color: modelData.active ? Theme.accent : Theme.borderSubtle
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                Text { text: modelData.name; color: modelData.active ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: modelData.active ? "[AÇIK]" : "[KAPALI]"; color: modelData.active ? Theme.success : Theme.textMuted; font.family: Theme.fontMono; font.pixelSize: 10 }
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

            // ── SEKME 2: DNS & HIZ ───────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.activeTab === "tools"
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: I18n.t("DNS SAĞLAYICISI", "DNS PROVIDER"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    Text { text: NetworkState.dnsBusy ? "[UYGULANIYOR]" : ""; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10; visible: NetworkState.dnsBusy }
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
                            implicitHeight: 26
                            radius: 0
                            color: active ? Theme.surfaceActive : (dnsBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: active ? Theme.accent : (dnsBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle)
                            border.width: 1

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
                    text: I18n.t("AKTİF DNS: ", "ACTIVE DNS: ") + NetworkState.dnsServers.join(", ")
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.customDnsOpen
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 26
                        radius: 0
                        color: Theme.surface1
                        border.color: customInput.activeFocus ? Theme.borderFocus : Theme.borderSubtle
                        border.width: 1
                        TextInput {
                            id: customInput
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.customDnsText
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: 11
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
                        implicitHeight: 26
                        radius: 0
                        color: Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "[KAYDET]"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
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

                Rectangle {
                    Layout.fillWidth: true
                    visible: NetworkState.dnsPendingApply && NetworkState.isConnected
                    implicitHeight: 26
                    radius: 0
                    color: Theme.surfaceActive
                    border.color: Theme.accent
                    border.width: 1
                    Text { anchors.centerIn: parent; text: I18n.t("[YENİDEN BAĞLAN VE UYGULA]", "RECONNECT & APPLY"); color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 10 }
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
                    text: "! " + NetworkState.dnsError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: I18n.t("HIZ TESTİ", "SPEED TEST"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 68
                        implicitHeight: 22
                        radius: 0
                        color: speedBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: speedBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: NetworkState.speedRunning ? "[DURDUR]" : I18n.t("[BAŞLAT]", "START")
                            color: NetworkState.isConnected ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 10
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
                        Text { text: "SUNUCU"; color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 74 }
                        Text { text: NetworkState.speedEdgeText; color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("GECİKME", "LATENCY"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 74 }
                        Text { text: NetworkState.speedPhase === "latency" ? I18n.t("ÖLÇÜLÜYOR...", "MEASURING...") : (NetworkState.speedPingMs > 0 ? (NetworkState.speedPingMs.toFixed(1) + " ms") : "-"); color: Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("İNDİRME", "DOWNLOAD"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 74 }
                        Text { text: NetworkState.speedPhase === "download" ? I18n.t("ÖLÇÜLÜYOR...", "MEASURING...") : (NetworkState.speedDownloadMbps > 0 ? (NetworkState.speedDownloadMbps.toFixed(1) + " Mbps") : "-"); color: NetworkState.speedDownloadMbps > 0 ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("YÜKLEME", "UPLOAD"); color: Theme.textSecondary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.preferredWidth: 74 }
                        Text { text: NetworkState.speedPhase === "upload" ? I18n.t("ÖLÇÜLÜYOR...", "MEASURING...") : (NetworkState.speedUploadMbps > 0 ? (NetworkState.speedUploadMbps.toFixed(1) + " Mbps") : "-"); color: NetworkState.speedUploadMbps > 0 ? Theme.accent : Theme.textPrimary; font.family: Theme.fontMono; font.pixelSize: 11; Layout.fillWidth: true }
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedPhase === "success" && NetworkState.speedLastStamp.length > 0
                        text: "TAMAMLANDI • " + NetworkState.speedLastStamp
                        color: Theme.success
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedErrorText.length > 0
                        text: "! " + NetworkState.speedErrorText
                        color: Theme.danger
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.borderSubtle }

            // ── Alt Buton: Gelismis Ag Ayarlari ──────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 0
                color: netSettingsMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                border.color: netSettingsMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: I18n.t("GELİŞMİŞ AĞ AYARLARI", "ADVANCED NETWORK SETTINGS")
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: 11
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

