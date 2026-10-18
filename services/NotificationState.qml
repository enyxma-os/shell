pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // Geçmiş ve aktif bildirimler listesi (en yeni en başta)
    property var notifications: []

    // Anlık popup olarak gösterilen bildirim
    property var activePopup: null
    property bool hasActivePopup: activePopup !== null

    // Popup tetikleme sinyali
    signal popupTriggered()

    // Bildirim Paneli (Pop-up kartı) açık/kapalı durumu
    property bool isPanelOpen: false

    function toggle(): void {
        root.isPanelOpen = !root.isPanelOpen
    }

    function open(): void {
        root.isPanelOpen = true
    }

    function close(): void {
        root.isPanelOpen = false
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notif => {
            root.handleNotification(notif)
        }
    }

    function handleNotification(notif) {
        if (!notif) return

        // Bildirimin bellekte tutulması için
        notif.tracked = true

        const item = {
            id: notif.id,
            rawNotification: notif,
            appName: notif.appName || "Sistem",
            appIcon: notif.appIcon || "",
            summary: notif.summary || "",
            body: notif.body || "",
            urgency: notif.urgency,
            actions: notif.actions || [],
            time: Qt.formatTime(new Date(), "hh:mm")
        }

        let list = root.notifications.slice()
        const existingIdx = list.findIndex(n => n.id === notif.id)
        if (existingIdx >= 0) {
            list[existingIdx] = item
        } else {
            list.unshift(item)
        }
        root.notifications = list

        // Anlık popup olarak tetikle
        root.activePopup = item
        root.popupTriggered()
    }

    function dismissPopup() {
        root.activePopup = null
    }

    function dismissNotification(id) {
        let list = root.notifications.slice()
        const idx = list.findIndex(n => n.id === id)
        if (idx >= 0) {
            const item = list[idx]
            if (item.rawNotification) {
                try {
                    item.rawNotification.dismiss()
                } catch(e) {}
            }
            list.splice(idx, 1)
            root.notifications = list
        }
        if (root.activePopup && root.activePopup.id === id) {
            root.activePopup = null
        }
    }

    function clearAll() {
        for (let i = 0; i < root.notifications.length; i++) {
            const item = root.notifications[i]
            if (item.rawNotification) {
                try {
                    item.rawNotification.dismiss()
                } catch(e) {}
            }
        }
        root.notifications = []
        root.activePopup = null
    }

    function invokeAction(notificationId, actionIdentifier) {
        const item = root.notifications.find(n => n.id === notificationId)
        if (item && item.rawNotification && item.rawNotification.actions) {
            for (let i = 0; i < item.rawNotification.actions.length; i++) {
                const act = item.rawNotification.actions[i]
                if (act.identifier === actionIdentifier) {
                    act.invoke()
                    break
                }
            }
        }
        root.dismissNotification(notificationId)
    }

    IpcHandler {
        target: "notifications"

        function clear(): void {
            root.clearAll()
        }

        function dismiss(): void {
            root.dismissPopup()
        }

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }
    }
}
