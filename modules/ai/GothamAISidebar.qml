import QtQuick
import QtQuick.Layouts
import "../../services"
import "."

Item {
    id: root

    readonly property real currentTabH: {
        if (AIState.activeTab === "chat") return 540
        if (AIState.activeTab === "usage") return 440
        if (AIState.activeTab === "tools") return 580
        return 500
    }

    Rectangle {
        id: dockCard
        anchors {
            top: parent.top
            topMargin: AIState.isOpen ? Theme.barHeight : 18
            right: parent.right
        }
        implicitWidth: 448
        implicitHeight: root.currentTabH
        color: Theme.bgPanel
        radius: 0
        border.color: Theme.borderFocus
        border.width: 1

        Behavior on anchors.topMargin {
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

        // Üst 2px keskin Gotham vurgu hattı
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 2
            color: Theme.accent
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 1
            anchors.topMargin: 2
            spacing: 0

            // Taktiksel Üst Başlık ve Sekme Şeridi
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 66
                color: Theme.bgDark

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Layout.topMargin: 6
                        Layout.bottomMargin: 4
                        spacing: 8

                        Text {
                            text: "󰧑  ORACLE // TERMİNAL"
                            color: Theme.accent
                            font.family: Theme.fontDisplay
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.8
                            Layout.fillWidth: true
                        }

                        Text {
                            text: AIState.isStreaming ? "AKTİF AKIŞ" : "HAZIR"
                            color: AIState.isStreaming ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.borderSubtle
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 0

                        Repeater {
                            model: [
                                { id: "chat", icon: "󰭹", label: "SOHBET" },
                                { id: "usage", icon: "󰄪", label: "KULLANIM" },
                                { id: "tools", icon: "󰇚", label: "ARAÇLAR" }
                            ]

                            delegate: Rectangle {
                                id: tabBtn
                                required property var modelData
                                readonly property bool active: AIState.activeTab === modelData.id

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: active ? Theme.surfaceActive
                                    : (tabMa.containsMouse ? Theme.surfaceHover : "transparent")

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: tabBtn.modelData.icon
                                        color: tabBtn.active ? Theme.accent : Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: tabBtn.modelData.label
                                        color: tabBtn.active ? Theme.textPrimary : Theme.textSecondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: tabBtn.active
                                        font.letterSpacing: 1
                                    }
                                }

                                Rectangle {
                                    visible: tabBtn.active
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                    }
                                    height: 2
                                    color: Theme.accent
                                }

                                MouseArea {
                                    id: tabMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: AIState.activeTab = tabBtn.modelData.id
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.borderSubtle
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
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
}

