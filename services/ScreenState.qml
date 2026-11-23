pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "."

/**
 * ScreenState: Odaklı monitör takibi ve katman yüzeyi politikası (P1).
 *
 * Neden gerekli:
 *   Eski `shell.qml` her panel için `Variants { model: Quickshell.screens }`
 *   kullanıyordu → N monitörde 15 panel × N adet wlr-layer-shell yüzeyi
 *   oluşuyor, hepsi aynı global bayrağa (AIState.isOpen vb.) bağlı olduğu için
 *   `keyboardFocus: OnDemand` talebi aynı anda birden çok yüzeyden geliyordu.
 *
 * Çözüm:
 *   - `overlayScreens` yalnızca odaklı ekranı döndürür → panel başına tek yüzey.
 *   - `Hyprland.monitorFor(screen)` resmi API'si kullanılır (v0.3).
 *     NOT: `Hyprland.focusedMonitor.screen` diye bir özellik YOKTUR;
 *     HyprlandMonitor yalnızca name/id/focused/x/y/width/height/scale taşır.
 *     Bu yüzden eşleştirme `monitorFor(screen).focused` üzerinden yapılır.
 *   - Odak başka monitöre geçtiğinde açık paneller kapatılır; böylece
 *     "görünmez ama odak tutan" yüzey kalmaz.
 */
Singleton {
    id: root

    readonly property var screens: Quickshell.screens ?? []
    readonly property int screenCount: root.screens.length

    readonly property var focusedScreen: {
        const list = root.screens
        if (list.length === 0) return null
        for (let i = 0; i < list.length; i++) {
            const mon = Hyprland.monitorFor(list[i])
            if (mon && mon.focused) return list[i]
        }
        // Tek ekran: Hyprland henüz raporlamadıysa ilk ekranı kullan.
        return list[0]
    }

    // Panel/launcher/OSD katmanları için model: 0 veya 1 ekran.
    readonly property var overlayScreens: root.focusedScreen ? [root.focusedScreen] : []

    // Bar ve arka plan tüm ekranlarda (çoklu monitörde beklenen davranış).
    readonly property var barScreens: root.screens

    readonly property string focusedScreenName: root.focusedScreen ? root.focusedScreen.name : ""

    function isFocused(screen) {
        if (!screen) return false
        const f = root.focusedScreen
        return !!f && f.name === screen.name
    }

    onFocusedScreenChanged: root.closeOverlays()

    function closeOverlays() {
        // Optional chaining: bir servis ileride kaldırılırsa çökme olmasın.
        LauncherState?.close()
        AIState?.close()
        SystemState?.closeControlCenter()
        NetworkState?.close()
        StorageState?.close()
        PerformanceState?.close()
        MediaState?.close()
        NotificationState?.close()
        OverviewState?.close()
        WallpaperState?.closePicker()
        MediaBrowserState?.close()
        SettingsState?.close()
    }
}
