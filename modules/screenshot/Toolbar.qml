import QtQuick
import QtQuick.Layouts
import "Singletons"

Item {
    id: tb
    implicitWidth: glass.implicitWidth
    implicitHeight: glass.implicitHeight

    property var tools: []
    property string activeTool: "rect"
    property color activeColor: Theme.accent
    property int activeWidth: 4
    property bool activeFill: false
    property bool activeRough: false
    property bool hasFill: false
    property string openPopover: ""
    property bool canUndo: false
    property bool canRedo: false

    readonly property real colorCenterX: colorBtn.x + row.x + colorBtn.width / 2
    readonly property real widthCenterX: widthBtn.x + row.x + widthBtn.width / 2

    signal toolPicked(string tool)
    signal colorButtonClicked()
    signal widthButtonClicked()
    signal fillToggled()
    signal roughToggled()
    signal undoRequested()
    signal redoRequested()
    signal copyRequested()
    signal saveRequested()
    signal pinRequested()
    signal helpRequested()
    signal beautifyRequested()
    signal cancelRequested()
    signal dragged(real dx, real dy)

    Rectangle {
        id: glass
        anchors.fill: parent
        radius: Theme.radiusPanel
        color: Theme.bgPanel
        border.color: Theme.borderSubtle
        border.width: 1
        implicitWidth: row.implicitWidth + 16
        implicitHeight: row.implicitHeight + 12

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 3

            Item {
                id: grip
                Layout.preferredWidth: 14
                Layout.preferredHeight: 32

                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 3
                            height: 3
                            radius: 1.5
                            color: gripMa.containsMouse || gripMa.pressed ? Theme.accent : Theme.textMuted
                        }
                    }
                }

                MouseArea {
                    id: gripMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    property real lastX: 0
                    property real lastY: 0
                    onPressed: (m) => {
                        var p = mapToItem(null, m.x, m.y);
                        lastX = p.x;
                        lastY = p.y;
                    }
                    onPositionChanged: (m) => {
                        if (!pressed) return;
                        var p = mapToItem(null, m.x, m.y);
                        tb.dragged(p.x - lastX, p.y - lastY);
                        lastX = p.x;
                        lastY = p.y;
                    }
                }
            }

            Repeater {
                model: tb.tools
                IconButton {
                    required property var modelData
                    icon: modelData.icon
                    active: tb.activeTool === modelData.id
                    tooltip: modelData.label + " (" + modelData.key + ")"
                    onClicked: tb.toolPicked(modelData.id)
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 20
                color: Theme.borderSubtle
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            Rectangle {
                id: colorBtn
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Theme.radiusSmall
                color: tb.openPopover === "color" ? Theme.surfaceActive : (colorMa.containsMouse ? Theme.surfaceHover : "transparent")
                Rectangle {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    radius: 9
                    color: tb.activeColor
                    border.color: Theme.borderSubtle
                    border.width: 1
                }
                MouseArea {
                    id: colorMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tb.colorButtonClicked()
                }
            }

            Rectangle {
                id: widthBtn
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Theme.radiusSmall
                color: tb.openPopover === "width" ? Theme.surfaceActive : (widthMa.containsMouse ? Theme.surfaceHover : "transparent")
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.max(4, Math.min(18, tb.activeWidth * 1.6 + 3))
                    height: width
                    radius: width / 2
                    color: Theme.textSecondary
                }
                MouseArea {
                    id: widthMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tb.widthButtonClicked()
                }
            }

            IconButton {
                icon: "fill"
                visible: tb.hasFill
                active: tb.activeFill
                tooltip: "Dolgu (f)"
                onClicked: tb.fillToggled()
            }

            IconButton {
                icon: "sketch"
                active: tb.activeRough
                tooltip: "Serbest Dalga (k)"
                onClicked: tb.roughToggled()
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 20
                color: Theme.borderSubtle
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            IconButton {
                icon: "undo"
                dim: !tb.canUndo
                tooltip: "Geri Al (Ctrl+Z)"
                onClicked: { if (tb.canUndo) tb.undoRequested(); }
            }

            IconButton {
                icon: "redo"
                dim: !tb.canRedo
                tooltip: "Yinele (Ctrl+Y)"
                onClicked: { if (tb.canRedo) tb.redoRequested(); }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 20
                color: Theme.borderSubtle
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            IconButton {
                icon: "copy"
                tooltip: "Panoya Kopyala (Ctrl+C)"
                onClicked: tb.copyRequested()
            }

            IconButton {
                icon: "save"
                tooltip: "Görseli Kaydet (Ctrl+S)"
                onClicked: tb.saveRequested()
            }

            IconButton {
                icon: "pin"
                tooltip: "Ekrana Sabitle (Ctrl+P)"
                onClicked: tb.pinRequested()
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 20
                color: Theme.borderSubtle
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            Rectangle {
                id: beautBtn
                Layout.preferredWidth: 34
                Layout.preferredHeight: 32
                radius: Theme.radiusSmall
                color: beautMa.containsMouse ? Theme.surfaceHover : "transparent"
                border.width: 1
                border.color: beautMa.containsMouse ? Theme.borderFocus : Theme.borderSubtle

                Text {
                    anchors.centerIn: parent
                    text: "✦"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: beautMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tb.beautifyRequested()
                }

                Timer {
                    id: bTipDelay
                    interval: 400
                    onTriggered: bTip.opacity = 1
                }

                onHoveredChanged: {
                    if (beautMa.containsMouse) bTipDelay.restart();
                    else { bTipDelay.stop(); bTip.opacity = 0; }
                }

                readonly property bool hovered: beautMa.containsMouse

                Rectangle {
                    id: bTip
                    enabled: false
                    opacity: 0
                    z: 100
                    anchors.top: parent.bottom
                    anchors.topMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: bTipText.implicitWidth + 14
                    height: bTipText.implicitHeight + 8
                    radius: Theme.radiusSmall
                    color: Theme.bgPanel
                    border.color: Theme.borderFocus
                    border.width: 1

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.animFast }
                    }

                    Text {
                        id: bTipText
                        anchors.centerIn: parent
                        text: "✦ Mockup Stüdyosu (Ctrl+B)"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 20
                color: Theme.borderSubtle
                Layout.leftMargin: 2
                Layout.rightMargin: 2
            }

            IconButton {
                icon: "cancel"
                tooltip: "İptal / Kapat (Esc)"
                onClicked: tb.cancelRequested()
            }
        }
    }
}
