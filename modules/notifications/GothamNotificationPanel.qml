import QtQuick
import QtQuick.Layouts
import "../../services"

Item {
    id: root

    Rectangle {
        id: dockCard
        anchors {
            top: parent.top
            topMargin: NotificationState.isPanelOpen ? Theme.barHeight : 18
            right: parent.right
        }
        implicitWidth: 360
        implicitHeight: contentCol.implicitHeight + 24
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
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
                topMargin: 14
            }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: I18n.t("OLAY GÜNLÜĞÜ", "EVENT LOG")
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.8
                }

                Text {
                    visible: NotificationState.notifications.length > 0
                    text: "[ " + NotificationState.notifications.length + " ]"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: NotificationState.notifications.length > 0
                    implicitWidth: clearTxt.implicitWidth + 14
                    implicitHeight: 22
                    radius: 0
                    color: clearMa.containsMouse ? Theme.surfaceHover : Theme.bgDark
                    border.color: clearMa.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        id: clearTxt
                        anchors.centerIn: parent
                        text: I18n.t("TEMİZLE", "CLEAR")
                        color: clearMa.containsMouse ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        id: clearMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationState.clearAll()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            ColumnLayout {
                Layout.fillWidth: true
                implicitHeight: 74
                visible: NotificationState.notifications.length === 0
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰂚"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 22
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "KAYITLI OLAY YOK"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }
            }

            Flickable {
                Layout.fillWidth: true
                implicitHeight: Math.min(380, listCol.implicitHeight)
                contentHeight: listCol.implicitHeight
                clip: true
                interactive: listCol.implicitHeight > 380
                boundsBehavior: Flickable.StopAtBounds
                visible: NotificationState.notifications.length > 0

                ColumnLayout {
                    id: listCol
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: NotificationState.notifications

                        delegate: Rectangle {
                            id: notifDelegate
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitHeight: notifCardCol.implicitHeight + 16
                            radius: 0
                            color: Theme.surface1
                            border.color: Theme.borderSubtle
                            border.width: 1

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                width: 3
                                color: Theme.accent
                            }

                            ColumnLayout {
                                id: notifCardCol
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 8
                                    leftMargin: 12
                                }
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: String(notifDelegate.modelData.appName || "").toUpperCase()
                                        color: Theme.accent
                                        font.family: Theme.fontMono
                                        font.pixelSize: 10
                                        font.bold: true
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: "[ " + notifDelegate.modelData.time + " ]"
                                        color: Theme.textMuted
                                        font.family: Theme.fontMono
                                        font.pixelSize: 9
                                    }

                                    Rectangle {
                                        implicitHeight: 18
                                        implicitWidth: 18
                                        radius: 0
                                        color: itemCloseMa.containsMouse ? Theme.surfaceHover : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            color: itemCloseMa.containsMouse ? Theme.danger : Theme.textMuted
                                            font.family: Theme.fontMono
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            id: itemCloseMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: NotificationState.dismissNotification(notifDelegate.modelData.id)
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notifDelegate.modelData.summary
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notifDelegate.modelData.body
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    visible: text.length > 0
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: notifDelegate.modelData.actions && notifDelegate.modelData.actions.length > 0

                                    Repeater {
                                        model: notifDelegate.modelData.actions || []

                                        delegate: Rectangle {
                                            id: actionDelegate
                                            required property var modelData
                                            implicitHeight: 20
                                            implicitWidth: actionTxt.implicitWidth + 12
                                            radius: 0
                                            color: actMa.containsMouse ? Theme.surfaceHover : Theme.bgDark
                                            border.color: actMa.containsMouse ? Theme.accent : Theme.borderSubtle
                                            border.width: 1

                                            Text {
                                                id: actionTxt
                                                anchors.centerIn: parent
                                                text: actionDelegate.modelData.text
                                                color: Theme.accent
                                                font.family: Theme.fontMono
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: actMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: NotificationState.invokeAction(notifDelegate.modelData.id, actionDelegate.modelData.identifier)
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
    }
}

