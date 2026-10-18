pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string formattedTime: Qt.formatTime(new Date(), "hh:mm")
    property string formattedDate: Qt.formatDate(new Date(), "d MMM ddd")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date()
            root.formattedTime = Qt.formatTime(now, "hh:mm")
            root.formattedDate = Qt.formatDate(now, "d MMM ddd")
        }
    }
}
