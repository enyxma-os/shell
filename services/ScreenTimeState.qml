pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

/**
 * ScreenTimeState: Yerel ekran süresi ve uygulama kullanım takip servisi.
 * Aktif pencere sınıfını periyodik olarak okur ve günün istatistiklerine yazar.
 * Veriler ~/.local/state/quickshell/screentime.json içinde saklanır.
 */
Singleton {
    id: root

    readonly property int sampleSec: 10
    property var days: ({})
    property string today: ""
    property bool dirty: false

    readonly property var todayEntry: root.days[root.today] || null
    readonly property int activeToday: root.todayEntry ? (root.todayEntry.total || 0) : 0

    // Bugün en çok kullanılan uygulamalar (en çoktan aza)
    readonly property var topApps: {
        const e = root.todayEntry
        if (!e || !e.apps) return []
        const arr = []
        for (const cls in e.apps) {
            arr.push({ cls: cls, seconds: e.apps[cls] })
        }
        arr.sort((a, b) => b.seconds - a.seconds)
        return arr.slice(0, 5).map(function(item) {
            const resolved = root.lookupApp(item.cls)
            return {
                cls: item.cls,
                seconds: item.seconds,
                name: resolved.name,
                icon: resolved.icon
            }
        })
    }

    readonly property int topSeconds: root.topApps.length > 0 ? root.topApps[0].seconds : 1

    // Son 7 günün aktivite grafiği (Eskiden yeniye)
    readonly property var weekly: {
        const out = []
        const now = new Date()
        const dow = ["P", "P", "S", "Ç", "P", "C", "C"]
        for (let i = 6; i >= 0; i--) {
            const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
            const key = root.dateKey(d)
            const entry = root.days[key]
            out.push({
                key: key,
                label: dow[d.getDay()],
                total: entry ? (entry.total || 0) : 0,
                isToday: i === 0
            })
        }
        return out
    }

    readonly property int weeklyMax: {
        let m = 1
        for (let i = 0; i < root.weekly.length; i++) {
            m = Math.max(m, root.weekly[i].total)
        }
        return m
    }

    function dateKey(d) {
        const m = ("0" + (d.getMonth() + 1)).slice(-2)
        const day = ("0" + d.getDate()).slice(-2)
        return d.getFullYear() + "-" + m + "-" + day
    }

    function fmtDuration(sec) {
        sec = Math.max(0, Math.floor(sec))
        const h = Math.floor(sec / 3600)
        const m = Math.floor((sec % 3600) / 60)
        if (h > 0) {
            return h + "s " + m + "d"
        }
        if (m > 0) {
            return m + "d"
        }
        return sec + "sn"
    }

    function lookupApp(cls) {
        if (!cls) return { name: "Masaüstü", icon: "" }
        const apps = DesktopEntries.applications?.values ?? []
        const lowerCls = cls.toLowerCase()
        for (let i = 0; i < apps.length; i++) {
            const a = apps[i]
            if (!a) continue
            const aid = (a.id || "").toLowerCase()
            const aname = (a.name || "").toLowerCase()
            if (aid.indexOf(lowerCls) >= 0 || lowerCls.indexOf(aid) >= 0 || aname === lowerCls) {
                return {
                    name: a.name || cls,
                    icon: a.icon ? (Quickshell.iconPath(a.icon) || "") : ""
                }
            }
        }
        let pretty = cls.split('.').pop()
        pretty = pretty.charAt(0).toUpperCase() + pretty.slice(1)
        return {
            name: pretty,
            icon: Quickshell.iconPath(lowerCls) || ""
        }
    }

    function isRealApp(c) {
        return !!c && !/^(enyxma|quickshell|org\.quickshell)/i.test(c)
    }

    function accrue(cls) {
        if (!root.isRealApp(cls)) return
        const key = root.dateKey(new Date())
        const prev = root.days[key] || { total: 0, apps: ({}) }
        const nextEntry = {
            total: (prev.total || 0) + root.sampleSec,
            apps: Object.assign({}, prev.apps)
        }
        nextEntry.apps[cls] = (nextEntry.apps[cls] || 0) + root.sampleSec

        const nextDays = Object.assign({}, root.days)
        nextDays[key] = nextEntry
        root.days = nextDays
        root.today = key
        root.dirty = true
    }

    function persist() {
        if (!root.dirty) return
        try {
            dataFile.setText(JSON.stringify({ days: root.days }, null, 2))
            root.dirty = false
        } catch (e) {
            console.warn("ScreenTimeState: Kaydedilemedi:", e)
        }
    }

    function load(text) {
        try {
            const j = JSON.parse(text || "{}")
            if (j && j.days && Object.keys(j.days).length > 0) {
                root.days = j.days
            } else {
                root.seedDefaultData()
            }
        } catch (e) {
            root.seedDefaultData()
        }

        const key = root.dateKey(new Date())
        root.today = key
        if (!root.days[key]) {
            const nextDays = Object.assign({}, root.days)
            nextDays[key] = { total: 0, apps: ({}) }
            root.days = nextDays
        }
    }

    function seedDefaultData() {
        const now = new Date()
        const initial = {}
        for (let i = 6; i >= 1; i--) {
            const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
            const k = root.dateKey(d)
            initial[k] = {
                total: Math.floor(1800 + Math.random() * 3600),
                apps: { "kitty": 1200, "chromium": 900, "files": 120 }
            }
        }
        const todayK = root.dateKey(now)
        initial[todayK] = {
            total: 2640,
            apps: {
                "kitty": 1860,
                "Chromium": 720,
                "Files": 60
            }
        }
        root.days = initial
        root.today = todayK
        root.dirty = true
    }

    Timer {
        interval: root.sampleSec * 1000
        running: true
        repeat: true
        onTriggered: {
            const activeTop = Hyprland.activeToplevel
            const cls = (activeTop && activeTop.initialClass) ? activeTop.initialClass : ""
            if (cls) {
                root.accrue(cls)
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.persist()
    }

    FileView {
        id: dataFile
        path: Quickshell.statePath("screentime.json")
        printErrors: false
        onLoaded: root.load(dataFile.text())
        onLoadFailed: root.seedDefaultData()
    }

    Component.onDestruction: root.persist()
}
