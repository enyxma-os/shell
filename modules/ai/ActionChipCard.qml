import QtQuick
import QtQuick.Layouts
import "../../services"

Rectangle {
    id: card

    property var chip: null
    property bool previewing: false

    visible: chip !== null && chip !== undefined
    radius: Theme.isGotham ? 2 : Theme.radiusPanel
    color: Theme.isGotham ? Theme.bgPanel : Theme.bgGlass
    border.color: previewing ? Theme.accent : (Theme.isGotham ? Theme.borderFocus : Theme.borderSubtle)
    border.width: previewing ? 2 : 1
    clip: true

    implicitHeight: (!card.chip) ? 0 : (layout.implicitHeight + 24)

    Rectangle {
        visible: Theme.isGotham
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 3
        color: Theme.accent
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        anchors.leftMargin: Theme.isGotham ? 15 : 12
        spacing: 6
        visible: card.chip !== null

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: card.chip ? (card.chip.title || "") : ""
                color: Theme.danger
                font.family: Theme.isGotham ? Theme.fontDisplay : Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }

            Text {
                text: "güven " + Math.round((card.chip ? (card.chip.conf || 1.0) : 1.0) * 100) + "%"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 10
            }

            Rectangle {
                width: 22
                height: 22
                radius: Theme.isGotham ? 2 : 11
                color: closeMouse.containsMouse ? Theme.surfaceHover : Theme.surface1
                border.color: Theme.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: 11
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (card.chip && card.chip.id) {
                            ThornhillState.dismissChip(card.chip.id)
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: card.chip ? (card.chip.why || "") : ""
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        Text {
            visible: card.chip ? ((card.chip.execCmd || "") !== "") : false
            Layout.fillWidth: true
            text: "⚑ çalıştırılacak: " + (card.chip ? card.chip.execCmd : "")
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: 10
            wrapMode: Text.WrapAnywhere
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 3
            color: Theme.borderSubtle
            Rectangle {
                id: ttlBar
                property real now: Date.now()
                property real remain: (card.chip && card.chip.ttlMs)
                    ? Math.max(0, Math.min(1, (card.chip.deadline - now) / card.chip.ttlMs))
                    : 0
                anchors.left: parent.left
                height: parent.height
                width: parent.width * remain
                color: Theme.accent

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: ttlBar.now = Date.now()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: (card.chip && card.chip.labels) ? card.chip.labels : []

                Rectangle {
                    id: actionBtn
                    required property string modelData
                    required property int index

                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: Theme.radiusButton
                    color: hold.pressed
                        ? Theme.accent
                        : (hold.containsMouse ? Theme.surfaceHover : Theme.surface2)
                    border.color: hold.containsMouse ? Theme.accent : Theme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: hold.pressed ? Theme.accentOn : Theme.textPrimary
                        text: {
                            if (!card.previewing)
                                return modelData
                            const a = card.chip ? card.chip.actions[index] : null
                            return (a && (a.risk === "low" || a.risk === "medium"))
                                ? modelData + " [basılı tut]" : modelData
                        }
                    }

                    MouseArea {
                        id: hold
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        property bool holding: false

                        onPressed: {
                            const a = card.chip ? card.chip.actions[index] : null
                            if (a && (a.risk === "low" || a.risk === "medium")) {
                                if (!card.previewing) {
                                    card.previewing = true
                                } else {
                                    holding = true
                                    holdTimer.start()
                                }
                            }
                        }
                        onReleased: {
                            holding = false
                            holdTimer.stop()
                        }
                        onClicked: {
                            const a = card.chip ? card.chip.actions[index] : null
                            if (a && a.risk === "none") {
                                ThornhillState.act(card.chip.id, modelData, true)
                            }
                        }

                        Timer {
                            id: holdTimer
                            interval: 1500
                            onTriggered: {
                                if (hold.holding) {
                                    card.previewing = false
                                    ThornhillState.act(card.chip.id, modelData, true)
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: card.previewing
            text: "İkinci onay bekleniyor — onaylamak için düğmeyi 1.5 sn basılı tutun"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}

