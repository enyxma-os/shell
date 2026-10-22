pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick

/**
 * ScreenTimeState — yerel ekran süresi takibi.
 *
 * P1 DÜZELTMESİ (R1/B9):
 *   `seedDefaultData()` TAMAMEN SİLİNDİ. Eski kod, veri dosyası yokken
 *   `Math.random()` ile uydurma 7 günlük kullanım geçmişi üretip diske
 *   yazıyordu → panel sahte istatistik gösteriyordu ve sonradan gerçek
 *   veriyle ayırt edilemiyordu. Boş geçmiş artık dürüstçe boş.
 *
 * Ayrıca:
 *   • Yalnızca gerçek uygulama sınıfı olan aktif pencere sayılır.
 *   • Bildirim (DND) ve boşta kalma bu sürümde AYRI ele alınmıyor:
 *     boşta algılama için idle-notify bağlayıcısı kullanılmadı (doğrulanmadı);
 *     bu yüzden "aktif pencere açıkken geçen süre" olarak belgeleniyor.
 */
Singleton {
    id: root

    readonly property int sampleSec: 10
    property var days: ({})
    property string today: ""
    property bool dirty: false

    readonly property var todayEntry: root.days[root.today] || null
    readonly property int activeToday: root.todayEntry ? (root.todayEntry.total || 0) : 0

    readonly property var topApps: {
        const e = root.todayEntry
        if (!e || !e.apps) return []
        const arr = []
        for (const cls in e.apps) arr.push({ cls: cls, seconds: e.apps[cls] })
        arr.sort((a, b) => b.seconds - a.seconds)
        return arr.slice(0, 5).map(function(item) {
            const resolved = root.lookupApp(item.cls)
            return { cls: item.cls, seconds: item.seconds, name: resolved.name, icon: resolved.icon }
        })
    }

    readonly property int topSeconds: root.topApps.length > 0 ? root.topApps[0].seconds : 1

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
        for (let i = 0; i < root.weekly.length; i++) m = Math.max(m, root.weekly[i].total)
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
        if (h > 0) return h + "s " + m + "d"
        if (m > 0) return m + "d"
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
        return { name: pretty, icon: Quickshell.iconPath(lowerCls) || "" }
    }

    // Quickshell'in kendi yüzeyleri (bar panelleri) kullanıcı uygulaması değildir.
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
        root.days = ({})
        try {
            const j = JSON.parse(text || "{}")
            if (j && j.days && typeof j.days === "object") root.days = j.days
        } catch (e) {
            console.warn("ScreenTimeState: Veri okunamadı, boş geçmişle başlanıyor:", e)
        }

        const key = root.dateKey(new Date())
        root.today = key
        if (!root.days[key]) {
            const nextDays = Object.assign({}, root.days)
            nextDays[key] = { total: 0, apps: ({}) }
            root.days = nextDays
        }
    }

    Timer {
        interval: root.sampleSec * 1000
        running: true
        repeat: true
        onTriggered: {
            const activeTop = Hyprland.activeToplevel
            const cls = (activeTop && activeTop.wayland && activeTop.wayland.appId)
                ? activeTop.wayland.appId
                : ""
            // Pencere yoksa (boş masaüstü) süre yazılmaz.
            if (cls) root.accrue(cls)
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
        // onLoadFailed: boş geçmiş — sahte veri ÜRETİLMEZ.
        onLoadFailed: root.load("{}")
    }

    Component.onDestruction: root.persist()
}
