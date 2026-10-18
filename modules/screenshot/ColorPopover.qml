import QtQuick
import QtQuick.Layouts
import "Singletons"

Item {
    id: pop

    property color selected: Theme.accent
    property bool eyedropArmed: false

    signal picked(color c)
    signal eyedropRequested()
    signal closeRequested()

    focus: visible
    Keys.onEscapePressed: pop.closeRequested()

    readonly property int arrow: 7
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight + arrow

    property real hue: 0
    property real sat: 1
    property real val: 1
    property bool syncing: false

    readonly property color current: Qt.hsva(pop.hue, pop.sat, pop.val, 1)

    function syncFrom(c) {
        pop.syncing = true;
        if (c.hsvHue >= 0) pop.hue = c.hsvHue;
        pop.sat = c.hsvSaturation;
        pop.val = c.hsvValue;
        pop.syncing = false;
    }

    onSelectedChanged: if (!pop.syncing) pop.syncFrom(pop.selected)
    Component.onCompleted: {
        pop.syncFrom(pop.selected);
        appear.start();
    }

    function pickSquare(px, py, w, h) {
        pop.sat = Math.max(0, Math.min(1, px / w));
        pop.val = Math.max(0, Math.min(1, 1 - py / h));
        pop.emitPick();
    }

    function pickHue(px, w) {
        pop.hue = Math.max(0, Math.min(1, px / w));
        pop.emitPick();
    }

    function emitPick() {
        pop.picked(pop.current);
    }

    opacity: 0
    scale: 0.92
    transformOrigin: Item.Top

    ParallelAnimation {
        id: appear
        NumberAnimation { target: pop; property: "opacity"; from: 0; to: 1; duration: Theme.animFast; easing.type: Easing.OutCubic }
        NumberAnimation { target: pop; property: "scale"; from: 0.92; to: 1; duration: Theme.animFast; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: card
        width: parent.width
        height: parent.height - pop.arrow
        radius: Theme.radiusPanel
        color: Theme.bgPanel
        border.color: Theme.borderSubtle
        border.width: 1
        implicitWidth: content.implicitWidth + 24
        implicitHeight: content.implicitHeight + 20

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: 12

            Item {
                id: satValSquare
                Layout.preferredWidth: 200
                Layout.preferredHeight: 130

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    clip: true
                    color: Qt.hsva(pop.hue, 1, 1, 1)

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 1) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 1) }
                        }
                    }
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    x: Math.max(0, Math.min(satValSquare.width - width, pop.sat * satValSquare.width - width / 2))
                    y: Math.max(0, Math.min(satValSquare.height - height, (1 - pop.val) * satValSquare.height - height / 2))
                    color: "transparent"
                    border.width: 2
                    border.color: pop.val < 0.5 ? Theme.textPrimary : Theme.bgDark
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onPressed: (m) => pop.pickSquare(m.x, m.y, satValSquare.width, satValSquare.height)
                    onPositionChanged: (m) => {
                        if (pressed) pop.pickSquare(m.x, m.y, satValSquare.width, satValSquare.height);
                    }
                }
            }

            Item {
                id: hueBar
                Layout.preferredWidth: 200
                Layout.preferredHeight: 14

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.00; color: Qt.hsva(0.00, 1, 1, 1) }
                        GradientStop { position: 0.17; color: Qt.hsva(0.17, 1, 1, 1) }
                        GradientStop { position: 0.33; color: Qt.hsva(0.33, 1, 1, 1) }
                        GradientStop { position: 0.50; color: Qt.hsva(0.50, 1, 1, 1) }
                        GradientStop { position: 0.67; color: Qt.hsva(0.67, 1, 1, 1) }
                        GradientStop { position: 0.83; color: Qt.hsva(0.83, 1, 1, 1) }
                        GradientStop { position: 1.00; color: Qt.hsva(1.00, 1, 1, 1) }
                    }
                }

                Rectangle {
                    width: 6
                    height: parent.height + 4
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(hueBar.width - width, pop.hue * hueBar.width - width / 2))
                    color: Theme.textPrimary
                    border.width: 1
                    border.color: Theme.bgDark
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onPressed: (m) => pop.pickHue(m.x, hueBar.width)
                    onPositionChanged: (m) => {
                        if (pressed) pop.pickHue(m.x, hueBar.width);
                    }
                }
            }

            RowLayout {
                Layout.preferredWidth: 200
                spacing: 6

                Repeater {
                    model: Theme.mockupSwatches

                    Rectangle {
                        required property var modelData
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        radius: 9
                        color: modelData
                        border.width: Qt.colorEqual(pop.selected, modelData) ? 2 : 1
                        border.color: Qt.colorEqual(pop.selected, modelData) ? Theme.accent : Theme.borderSubtle

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pop.picked(parent.color)
                        }
                    }
                }
            }
        }
    }
}
