import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"
import "."

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-ai"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: AIState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }

    margins {
        top: AIState.isOpen ? 44 : 20
        right: 14
    }

    implicitWidth: 432
    implicitHeight: mainCard.implicitHeight
    color: "transparent"

    visible: mainCard.opacity > 0.0

    Behavior on margins.top {
        enabled: !Theme.reduceMotion
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }
    }

    readonly property real currentTabH: {
        if (AIState.activeTab === "chat") return 520
        if (AIState.activeTab === "usage") return 420
        if (AIState.activeTab === "tools") return 580
        return 480
    }

    Rectangle {
        id: mainCard
        anchors.fill: parent
        implicitHeight: root.currentTabH
        color: Theme.bgPanel
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

        opacity: AIState.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        Behavior on implicitHeight {
            enabled: !Theme.reduceMotion
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }

        // ── SOL ETKİNLİK ŞERİDİ (ACTIVITY RAIL) ──
        Item {
            id: rail
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 1
            }
            width: 52

            // Dikey ayırıcı çizgi
            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 12
                    bottomMargin: 12
                }
                width: 1
                color: Theme.borderSubtle
            }

            Column {
                anchors {
                    top: parent.top
                    topMargin: 14
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 6

                readonly property var tabs: [
                    { id: "chat", icon: "󰭹", label: "Sohbet" },
                    { id: "usage", icon: "󰄪", label: "Kullanım" },
                    { id: "tools", icon: "󰇚", label: "Araçlar" }
                ]

                Repeater {
                    model: parent.tabs
                    delegate: Item {
                        id: tabItem
                        required property var modelData
                        readonly property bool active: AIState.activeTab === modelData.id
                        width: 44
                        height: 50

                        // Dairesel İkon Alanı
                        Rectangle {
                            id: iconCircle
                            anchors {
                                top: parent.top
                                horizontalCenter: parent.horizontalCenter
                            }
                            width: 36
                            height: 36
                            radius: 18
                            color: tabItem.active ? Theme.accent
                                : (tabMa.containsMouse ? Theme.surfaceHover : "transparent")

                            Behavior on color {
                                enabled: !Theme.reduceMotion
                                ColorAnimation { duration: Theme.animFast }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: tabItem.modelData.icon
                                color: tabItem.active ? Theme.bgDark : Theme.textSecondary
                                font.family: Theme.fontMono
                                font.pixelSize: 15
                                font.bold: tabItem.active

                                Behavior on color {
                                    enabled: !Theme.reduceMotion
                                    ColorAnimation { duration: Theme.animFast }
                                }
                            }
                        }

                        // Sekme Başlığı
                        Text {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: tabItem.modelData.label
                            color: tabItem.active ? Theme.textPrimary : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 8.5
                            font.bold: tabItem.active
                        }

                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AIState.activeTab = tabItem.modelData.id
                        }
                    }
                }
            }
        }

        // ── SAĞ İÇERİK ALANI ──
        Item {
            id: contentArea
            anchors {
                left: rail.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: 1
            }
            clip: true

            Component { id: chatComponent; ChatTab {} }
            Component { id: usageComponent; UsageTab {} }
            Component { id: toolsComponent; ToolsTab {} }

            Loader {
                id: tabLoader
                anchors.fill: parent
                sourceComponent: AIState.activeTab === "chat" ? chatComponent
                    : (AIState.activeTab === "usage" ? usageComponent : toolsComponent)
            }
        }
    }
}
