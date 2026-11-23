pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

/**
 * NotificationState — bildirim sunucusu, geçmiş ve popup kuyruğu.
 *
 * DÜZELTMELER:
 *  1. DND artık GERÇEK: `dnd = true` iken popup üretilmez (geçmişe yazılır).
 *     Önceden ControlCenter'daki yerel bool hiçbir yere bağlı değildi.
 *  2. Popup KUYRUĞU: yeni bildirim, ekrandaki popup'ı anında ezmiyor
 *     (R1/B6: aynı saniyedeki 2. bildirim 1.'yi yutuyordu).
 *  3. Bellek tavanı: geçmiş en fazla 50 kayıt; ayrıca track bırakılıyor.
 *  4. `image` alanı saklanıyor ve popup'ta gösterilebilir hale getiriliyor
 *     (imageSupported: true ilan edilip hiç okunmuyordu — R1/B12).
 *  5. Otomatik kapanma süresi `expireTimeout` / urgency'den türetilir;
 *     `critical` bildirimler otomatik kapanmaz (R1/B11).
 *  6. Aynı bildirim kimliği güncellenirse kuyrukta kopya oluşmaz.
 */
Singleton {
    id: root

    readonly property int maxHistory: 50

    property var notifications: []
    property var activePopup: null
    readonly property bool hasActivePopup: activePopup !== null

    // Kuyruk: ekranda popup varken gelenler burada bekler.
    property var popupQueue: []

    signal popupTriggered()

    property bool isPanelOpen: false

    // Rahatsız Etme: ControlCenter bu özelliği okur/yazar.
    property bool dnd: false

    function toggle(): void { root.isPanelOpen = !root.isPanelOpen }
    function open(): void { root.isPanelOpen = true }
    function close(): void { root.isPanelOpen = false }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: false   // Text.textFormat PlainText ile eşleşir
        persistenceSupported: true
        keepOnReload: true

        onNotification: notif => root.handleNotification(notif)
    }

    function handleNotification(notif) {
        if (!notif) return

        // Geçmişte tutulacaksa tracked = true (aksi halde nesne serbest kalır).
        notif.tracked = true

        const item = {
            id: notif.id,
            rawNotification: notif,
            appName: notif.appName || "Sistem",
            appIcon: notif.appIcon || "",
            summary: notif.summary || "",
            body: notif.body || "",
            image: notif.image || "",
            urgency: notif.urgency,
            actions: notif.actions || [],
            // expiry: -1 = sunucu karar verir, 0 = asla kapatma
            expireTimeout: (typeof notif.expireTimeout === "number") ? notif.expireTimeout : -1,
            time: Qt.formatTime(new Date(), "hh:mm")
        }

        let list = root.notifications.slice()
        const existingIdx = list.findIndex(n => n.id === notif.id)
        if (existingIdx >= 0) {
            // Aynı id güncellendi: kuyruktaki eski kopyayı da tazele.
            list[existingIdx] = item
            const q = root.popupQueue.slice()
            const qi = q.findIndex(n => n.id === notif.id)
            if (qi >= 0) q[qi] = item
            root.popupQueue = q
        } else {
            list.unshift(item)
        }
        root.notifications = list.slice(0, root.maxHistory)

        // DND: popup yok, sadece geçmiş.
        if (root.dnd) return

        if (root.activePopup === null) root.showNow(item)
        else {
            const q = root.popupQueue.slice()
            if (!q.some(n => n.id === item.id)) q.push(item)
            root.popupQueue = q.slice(0, 10)
        }
    }

    function showNow(item) {
        root.activePopup = item
        root.popupTriggered()
        autoDismiss.restart()
    }

    // Süre: explicit expireTimeout > urgency > varsayılan 5 sn.
    readonly property int popupTimeoutMs: {
        const p = root.activePopup
        if (!p) return 5000
        if (p.expireTimeout === 0) return 0            // asla kapatma
        if (p.expireTimeout > 0) return p.expireTimeout
        if (p.urgency === NotificationUrgency.Critical) return 0
        return Math.max(2000, SettingsState.notifTimeoutSec * 1000)
    }

    Timer {
        id: autoDismiss
        interval: Math.max(1000, root.popupTimeoutMs)
        repeat: false
        onTriggered: if (root.popupTimeoutMs > 0) root.dismissPopup()
    }

    // Popup kartı hover ile duraklatır (kullanıcı okurken kaybolmasın).
    property bool autoDismissPaused: false

    function pauseAutoDismiss() {
        if (root.popupTimeoutMs === 0) return
        root.autoDismissPaused = true
        autoDismiss.stop()
    }

    function resumeAutoDismiss() {
        if (root.popupTimeoutMs === 0) return
        root.autoDismissPaused = false
        if (root.activePopup !== null) autoDismiss.restart()
    }

    onActivePopupChanged: {
        if (root.activePopup !== null) autoDismiss.restart()
        else root.drainQueue()
    }

    function drainQueue() {
        if (root.activePopup !== null) return
        const q = root.popupQueue.slice()
        if (q.length === 0) return
        const next = q.shift()
        root.popupQueue = q
        root.showNow(next)
    }

    function dismissPopup() {
        if (root.activePopup && root.activePopup.rawNotification) {
            try { root.activePopup.rawNotification.dismiss() } catch (e) {}
        }
        root.activePopup = null
        root.drainQueue()
    }

    function dismissNotification(id) {
        let list = root.notifications.slice()
        const idx = list.findIndex(n => n.id === id)
        if (idx >= 0) {
            const item = list[idx]
            if (item.rawNotification) {
                try { item.rawNotification.dismiss() } catch (e) {}
            }
            list.splice(idx, 1)
            root.notifications = list
        }
        root.popupQueue = root.popupQueue.filter(n => n.id !== id)
        if (root.activePopup && root.activePopup.id === id) root.activePopup = null
    }

    function clearAll() {
        for (let i = 0; i < root.notifications.length; i++) {
            const item = root.notifications[i]
            if (item.rawNotification) {
                try { item.rawNotification.dismiss() } catch (e) {}
            }
        }
        root.notifications = []
        root.popupQueue = []
        root.activePopup = null
    }

    function invokeAction(notificationId, actionIdentifier) {
        const item = root.notifications.find(n => n.id === notificationId)
        if (item && item.rawNotification && item.rawNotification.actions) {
            for (let i = 0; i < item.rawNotification.actions.length; i++) {
                const act = item.rawNotification.actions[i]
                if (act.identifier === actionIdentifier) {
                    try { act.invoke() } catch (e) {}
                    break
                }
            }
        }
        root.dismissNotification(notificationId)
    }

    function toggleDnd() {
        root.dnd = !root.dnd
        if (root.dnd) root.activePopup = null
    }

    IpcHandler {
        target: "notifications"
        function clear(): void { root.clearAll() }
        function dismiss(): void { root.dismissPopup() }
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function dnd(on: bool): void { root.dnd = on }
        function togglednd(): void { root.toggleDnd() }
    }
}
