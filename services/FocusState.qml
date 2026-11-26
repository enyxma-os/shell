pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

/**
 * FocusState — Odak Zamanlayici / Pomodoro servisi.
 *
 * Yalnizca SettingsState.enableFocusTimer acikken ve zamanlayici calisirken
 * saniyelik sayac calistirir; kapaliyken sifir kaynak tuketir.
 */
Singleton {
    id: root

    property string mode: "work" // work | short | long
    property int remainingSeconds: 25 * 60
    property bool running: false
    property int completedSessions: 0

    readonly property string modeLabel: {
        var _l = I18n.lang
        if (mode === "short") return I18n.t("KISA MOLA", "SHORT BREAK")
        if (mode === "long") return I18n.t("UZUN MOLA", "LONG BREAK")
        return I18n.t("ODAK", "FOCUS")
    }

    readonly property string displayText: {
        var m = Math.floor(remainingSeconds / 60)
        var s = remainingSeconds % 60
        return (m < 10 ? "0" + m : String(m)) + ":" + (s < 10 ? "0" + s : String(s))
    }

    function durationFor(m) {
        if (m === "short") return 5 * 60
        if (m === "long") return 15 * 60
        return 25 * 60
    }

    function toggle() {
        running = !running
    }

    function reset() {
        running = false
        remainingSeconds = durationFor(mode)
    }

    function cycleMode() {
        running = false
        if (mode === "work") mode = "short"
        else if (mode === "short") mode = "long"
        else mode = "work"
        remainingSeconds = durationFor(mode)
    }

    Timer {
        interval: 1000
        running: root.running && SettingsState.enableFocusTimer
        repeat: true
        onTriggered: {
            if (root.remainingSeconds > 1) {
                root.remainingSeconds--
            } else {
                root.running = false
                if (root.mode === "work") {
                    root.completedSessions++
                    Quickshell.execDetached(["notify-send", I18n.t("Enyxma Odak", "Enyxma Focus"), I18n.t("Odak oturumu tamamlandı. Mola zamanı!", "Focus session completed. Break time!")])
                    root.mode = (root.completedSessions % 4 === 0) ? "long" : "short"
                } else {
                    Quickshell.execDetached(["notify-send", I18n.t("Enyxma Odak", "Enyxma Focus"), I18n.t("Mola bitti. Yeni odak oturumuna hazır!", "Break is over. Ready for a new focus session!")])
                    root.mode = "work"
                }
                root.remainingSeconds = root.durationFor(root.mode)
            }
        }
    }

    IpcHandler {
        target: "focus"
        function toggle(): void { root.toggle() }
        function reset(): void { root.reset() }
        function cycle(): void { root.cycleMode() }
    }
}
