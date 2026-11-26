pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    // Ayarlar
    property bool use24h: true
    property bool showSeconds: false
    property bool isPanelOpen: false
    property bool isMenuOpen: false

    // Pomodoro / Odak Sayacı
    property bool pomodoroActive: false
    property int pomodoroSeconds: 1500
    readonly property string pomodoroDisplay: {
        const m = Math.floor(pomodoroSeconds / 60);
        const s = pomodoroSeconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    // Canlı Tarih/Saat
    property date now: new Date()

    readonly property string hours: {
        const h = now.getHours();
        if (use24h) return h < 10 ? "0" + h : String(h);
        const h12 = h % 12 || 12;
        return h12 < 10 ? "0" + h12 : String(h12);
    }

    readonly property string minutes: {
        const m = now.getMinutes();
        return m < 10 ? "0" + m : String(m);
    }

    readonly property string seconds: {
        const s = now.getSeconds();
        return s < 10 ? "0" + s : String(s);
    }

    readonly property string ampm: use24h ? "" : (now.getHours() < 12 ? "AM" : "PM")

    // Bar için formatlanmış saat
    readonly property string formattedTime: {
        let base = hours + ":" + minutes;
        if (showSeconds) base += ":" + seconds;
        if (!use24h) base += " " + ampm;
        return base;
    }

    readonly property var _trDaysLong: ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
    readonly property var _trDaysShort: ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"]
    readonly property var _trMonthsLong: ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
    readonly property var _trMonthsShort: ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]

    readonly property var _enDaysLong: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    readonly property var _enDaysShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var _enMonthsLong: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var _enMonthsShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    // Bar ve paneller için formatlanmış tarih
    readonly property int dayNumber: now.getDate()
    readonly property string dayName: (I18n.isEn ? _enDaysLong : _trDaysLong)[now.getDay()]
    readonly property string monthName: (I18n.isEn ? _enMonthsLong : _trMonthsLong)[now.getMonth()]
    readonly property int year: now.getFullYear()
    readonly property string formattedDate: I18n.isEn
        ? (_enDaysShort[now.getDay()] + ", " + _enMonthsShort[now.getMonth()] + " " + dayNumber)
        : (dayNumber + " " + _trMonthsShort[now.getMonth()] + " " + _trDaysShort[now.getDay()])
    readonly property string fullDateString: I18n.isEn
        ? (dayName + ", " + monthName + " " + dayNumber + ", " + year)
        : (dayNumber + " " + monthName + " " + year + ", " + dayName)

    // Hafta numarası ve yılın günü
    readonly property int weekNumber: {
        const d = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
        const dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
        return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
    }

    readonly property int dayOfYear: {
        const start = new Date(now.getFullYear(), 0, 0);
        const diff = now - start;
        const oneDay = 1000 * 60 * 60 * 24;
        return Math.floor(diff / oneDay);
    }

    // Metotlar
    function togglePanel() {
        isMenuOpen = false;
        isPanelOpen = !isPanelOpen;
    }

    function toggleMenu() {
        isPanelOpen = false;
        isMenuOpen = !isMenuOpen;
    }

    function closeAll() {
        isPanelOpen = false;
        isMenuOpen = false;
    }

    function toggle24h() {
        use24h = !use24h;
    }

    function toggleSeconds() {
        showSeconds = !showSeconds;
    }

    function togglePomodoro() {
        pomodoroActive = !pomodoroActive;
        if (pomodoroSeconds <= 0) pomodoroSeconds = 1500;
    }

    function resetPomodoro() {
        pomodoroActive = false;
        pomodoroSeconds = 1500;
    }

    // IPC Arayüzü (Kısayol ve dış komutlar için)
    IpcHandler {
        target: "time"

        function toggle(): void { root.togglePanel() }
        function open(): void { root.isPanelOpen = true; root.isMenuOpen = false; }
        function close(): void { root.closeAll() }
        function toggleMenu(): void { root.toggleMenu() }
        function toggleFormat(): void { root.toggle24h() }
    }

    // Zamanlayıcı (Her saniye güncellenir)
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.now = new Date();
            if (root.pomodoroActive) {
                if (root.pomodoroSeconds > 0) {
                    root.pomodoroSeconds--;
                } else {
                    root.pomodoroActive = false;
                }
            }
        }
    }
}
