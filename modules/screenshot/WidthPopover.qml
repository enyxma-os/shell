import QtQuick
import QtQuick.Layouts
import "Singletons"

Item {
    id: pop

    property int selected: 4
    signal picked(int w)
    signal closeRequested()

    focus: visible
    Keys.onEscapePressed: pop.closeRequested()

    readonly property int arrow: 7
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight + arrow

    readonly property var presets: [
        { width: 2, dot: 5 },
        { width: 4, dot: 9 },
        { width: 8, dot: 13 },
        { width: 12, dot: 17 }
    ]

    function apply(w) {
        var c = Math.max(1, Math.min(24, Math.round(w)));
        if (c !== pop.selected) pop.picked(c);
    }

    opacity: 0
    scale: 0.92
    transformOrigin: Item.Top
    Component.onCompleted: appear.start()

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
        implicitHeight: content.implicitHeight + 16

        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: pop.presets

                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Theme.radiusSmall
                    color: pop.selected === modelData.width ? Theme.surfaceActive : (ma.containsMouse ? Theme.surfaceHover : "transparent")
                    border.width: pop.selected === modelData.width ? 1 : 0
                    border.color: Theme.accent

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.modelData.dot
                        height: width
                        radius: width / 2
                        color: pop.selected === parent.modelData.width ? Theme.accent : Theme.textSecondary
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pop.apply(parent.modelData.width)
                    }
                }
            }
        }
    }
}
