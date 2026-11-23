import QtQuick
import QtQuick.Layouts
import "../../services"
import "."

Item {
    id: root

    readonly property real currentTabH: {
        if (AIState.activeTab === "chat") return 520
        if (AIState.activeTab === "usage") return 420
        if (AIState.activeTab === "tools") return 580
        return 480
    }

    Rectangle {
        id: mainCard
        anchors {
            top: parent.top
            topMargin: AIState.isOpen ? 44 : 20
            right: parent.right
            rightMargin: 14
        }
        implicitWidth: 432
        implicitHeight: root.currentTabH
        color: Theme.bgPanel
        radius: Theme.radiusPanel
        border.color: Theme.borderSubtle
        border.width: Theme.borderWidth

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

        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        Item {
            id: rail
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 1
            }
            width: 52

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

                        Text {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: tabItem.modelData.label
                            color: tabItem.active ? Theme.textPrimary : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
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

