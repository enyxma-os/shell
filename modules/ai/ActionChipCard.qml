import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"

Rectangle {
    id: card

    property var chip: null
    property bool previewing: false

    visible: chip !== null && chip !== undefined
    radius: Theme.radiusPanel
    color: Theme.bgGlass
    border.color: previewing ? Theme.warning : Theme.borderSubtle
    border.width: previewing ? 2 : 1

    implicitHeight: (!card.chip) ? 0 : (layout.implicitHeight + 24)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6
        visible: card.chip !== null

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: card.chip ? (card.chip.title || "") : ""
                color: Theme.danger
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            Label {
                text: "güven " + Math.round((card.chip ? (card.chip.conf || 1.0) : 1.0) * 100) + "%"
                color: Theme.textMuted
                font.pixelSize: 10
            }
        }

        Label {
            Layout.fillWidth: true
            text: card.chip ? (card.chip.why || "") : ""
            color: Theme.textSecondary
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        Label {
            visible: card.chip ? ((card.chip.execCmd || "") !== "") : false
            Layout.fillWidth: true
            text: "⚑ çalıştırılacak: " + (card.chip ? card.chip.execCmd : "")
            color: Theme.accent
            font.family: "monospace"
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

                Button {
                    required property string modelData
                    required property int index
                    text: {
                        if (!card.previewing)
                            return modelData
                        const a = card.chip ? card.chip.actions[index] : null
                        return (a && (a.risk === "low" || a.risk === "medium"))
                            ? modelData + " [basılı tut]" : modelData
                    }
                    Layout.fillWidth: true

                    MouseArea {
                        id: hold
                        anchors.fill: parent
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
                        onReleased: holding = false
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

        Label {
            visible: card.previewing
            text: "İkinci onay bekleniyor — onaylamak için düğmeyi 1.5 sn basılı tutun"
            color: Theme.accent
            font.pixelSize: 10
        }
    }
}

