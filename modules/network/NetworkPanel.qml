import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../widgets"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-network"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: NetworkState.isOpen ? 42 : 20
        right: 12
    }

    implicitWidth: 320
    implicitHeight: mainCard.implicitHeight
    color: "transparent"

    visible: mainCard.opacity > 0.0
    WlrLayershell.keyboardFocus: (NetworkState.isOpen && customDnsOpen) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property bool customDnsOpen: false
    property string customDnsText: ""

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitHeight: contentCol.implicitHeight + Theme.spacingMedium * 2
        color: Theme.bgGlass
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: NetworkState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            // ── BAŞLIK BÖLÜMÜ (Ağ & Kapatma Butonu) ──
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Ağ"
                    color: Theme.textPrimary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    font.letterSpacing: 1
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitHeight: 24
                    implicitWidth: 24
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

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── BAĞLANTI DURUMU & ÇUBUK ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        if (!NetworkState.isConnected) return "Bağlantı Yok"
                        if (NetworkState.connectionType === "wifi") return "%" + NetworkState.signalStrength
                        return "Bağlı"
                    }
                    color: NetworkState.isConnected ? Theme.accent : Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
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
            }

            // ── DETAYLAR BÖLÜMÜ (Yazı, Arayüz, IP, Hız) ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                // Yazı (Bağlantı Tipi / Adı)
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Yazı"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.preferredWidth: 90
                    }
                    Text {
                        text: NetworkState.connectionType === "wifi" ? (NetworkState.connectionName || "Wi-Fi") : (NetworkState.connectionType === "ethernet" ? "Ethernet" : "-")
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Arayüz
                RowLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.interfaceName.length > 0
                    Text {
                        text: "Arayüz"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.preferredWidth: 90
                    }
                    Text {
                        text: NetworkState.interfaceName
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }
                }

                // IP Adresi
                RowLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.ipAddress.length > 0
                    Text {
                        text: "IP"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.preferredWidth: 90
                    }
                    Text {
                        text: NetworkState.ipAddress
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }
                }

                // Link Hızı (varsa)
                RowLayout {
                    Layout.fillWidth: true
                    visible: NetworkState.linkSpeed.length > 0
                    Text {
                        text: "Hız"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.preferredWidth: 90
                    }
                    Text {
                        text: NetworkState.linkSpeed
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.fillWidth: true
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── HIZ TESTİ (CLOUDFLARE SPEED TEST) ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "HIZ TESTİ"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 64
                        implicitHeight: 22
                        radius: Theme.radiusButton
                        color: speedBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1
                        border.color: speedBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: NetworkState.speedRunning ? "durdur" : "başlat"
                            color: NetworkState.isConnected ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        MouseArea {
                            id: speedBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: NetworkState.isConnected || NetworkState.speedRunning
                            onClicked: {
                                if (NetworkState.speedRunning)
                                    NetworkState.cancelSpeedTest()
                                else
                                    NetworkState.startSpeedTest()
                            }
                        }
                    }
                }

                // Hız Testi Sonuç Alanı (Test başlatıldığında görünür)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: NetworkState.speedPhase !== "idle" && NetworkState.speedPhase !== "cancelled"

                    // Sunucu / Edge
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Sunucu"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.preferredWidth: 90
                        }
                        Text {
                            text: NetworkState.speedEdgeText
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Gecikme (Ping)
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Gecikme"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.preferredWidth: 90
                        }
                        Text {
                            text: NetworkState.speedPhase === "latency" ? "Ölçülüyor..." : (NetworkState.speedPingMs > 0 ? (NetworkState.speedPingMs.toFixed(1) + " ms") : "-")
                            color: Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "✓"
                            color: Theme.success
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            visible: NetworkState.speedPingMs > 0 && NetworkState.speedPhase !== "latency"
                        }
                    }

                    // İndirme (Download)
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "İndirme"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.preferredWidth: 90
                        }
                        Text {
                            text: NetworkState.speedPhase === "download" ? "Ölçülüyor..." : (NetworkState.speedDownloadMbps > 0 ? (NetworkState.speedDownloadMbps.toFixed(1) + " Mbps") : "-")
                            color: NetworkState.speedDownloadMbps > 0 ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "✓"
                            color: Theme.success
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            visible: NetworkState.speedDownloadMbps > 0 && NetworkState.speedPhase !== "latency" && NetworkState.speedPhase !== "download"
                        }
                    }

                    // Yükleme (Upload)
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Yükleme"
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.preferredWidth: 90
                        }
                        Text {
                            text: NetworkState.speedPhase === "upload" ? "Ölçülüyor..." : (NetworkState.speedUploadMbps > 0 ? (NetworkState.speedUploadMbps.toFixed(1) + " Mbps") : "-")
                            color: NetworkState.speedUploadMbps > 0 ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "✓"
                            color: Theme.success
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            visible: NetworkState.speedPhase === "success" && NetworkState.speedUploadMbps > 0
                        }
                    }

                    // Tamamlandı Bildirimi
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedPhase === "success" && NetworkState.speedLastStamp.length > 0
                        text: "Tamamlandı • " + NetworkState.speedLastStamp
                        color: Theme.success
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.letterSpacing: 1
                    }

                    // Hata Bildirimi (varsa)
                    Text {
                        Layout.fillWidth: true
                        visible: NetworkState.speedErrorText.length > 0
                        text: NetworkState.speedErrorText
                        color: Theme.danger
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── DNS SAĞLAYICISI ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "DNS SAĞLAYICISI"
                        color: Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: NetworkState.dnsBusy ? "uygulanıyor..." : ""
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        visible: NetworkState.dnsBusy
                    }
                }

                // 4 DNS Butonu: [DHCP] [Cloudflare] [Google] [Özel]
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [
                            { label: "DHCP", key: "dhcp" },
                            { label: "Cloudflare", key: "cloudflare" },
                            { label: "Google", key: "google" },
                            { label: "Özel", key: "custom" }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Theme.radiusButton
                            readonly property bool active: NetworkState.dnsProvider === modelData.key
                            color: active ? Theme.surfaceActive : (dnsBtnMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
                            border.color: active ? Theme.accent : (dnsBtnMa.containsMouse ? Theme.accent : Theme.borderSubtle)
                            border.width: Theme.borderWidth

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: parent.active ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
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

                // Özel DNS Giriş Alanı (Açılır çekmece)
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
                        border.width: Theme.borderWidth

                        TextInput {
                            id: customInput
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingSmall
                            anchors.rightMargin: Theme.spacingSmall
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
                        color: applyMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                        border.color: Theme.accent
                        border.width: Theme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: "Uygula"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        MouseArea {
                            id: applyMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !NetworkState.dnsBusy
                            onClicked: {
                                var srvs = root.customDnsText.split(/[ ,]+/).filter(function(s) { return s.trim().length > 0 })
                                if (srvs.length > 0) NetworkState.setDnsProvider("custom", srvs)
                            }
                        }
                    }
                }

                // DNS Hata Bildirimi (varsa)
                Text {
                    Layout.fillWidth: true
                    visible: NetworkState.dnsError.length > 0
                    text: NetworkState.dnsError
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            // Çizgi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            // ── ALT BUTON: AĞ AYARLARI ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: Theme.radiusButton
                color: netSettingsMa.containsMouse ? Theme.surfaceHover : Theme.surfaceActive
                border.color: netSettingsMa.containsMouse ? Theme.accent : Theme.borderSubtle
                border.width: Theme.borderWidth

                Behavior on color {
                    enabled: !Theme.reduceMotion
                    ColorAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutQuint
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Ağ ayarları"
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
