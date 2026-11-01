import Quickshell
import Quickshell.Wayland
import QtQuick
import "./services"
import "./modules/background"
import "./modules/bar"
import "./modules/osd"
import "./modules/ai"
import "./modules/cc"
import "./modules/notifications"
import "./modules/launcher"
import "./modules/network"
import "./modules/storage"
import "./modules/performance"
import "./modules/media"
import "./modules/time"
import "./modules/wallpaper"
import "./modules/overview"

/**
 * Enyxma Shell — kök katman.
 *
 * KATMAN POLİTİKASI (P1 refaktörü):
 *   • BackgroundLayer + Bar  → `ScreenState.barScreens`  (her monitörde 1 kez)
 *   • Tüm paneller / launcher / OSD / bildirim → `ScreenState.overlayScreens`
 *     (yalnızca odaklı monitörde 1 kez — N monitörde N katman yerine 1)
 *
 * Sonuç: 17 × N yüzey → (2 × N) + 15 yüzey.
 * 2 monitörde 34 → 19. Klavye odağı talebi artık tek yüzeyden geliyor,
 * dolayısıyla `keyboardFocus: OnDemand` yarışı yapısal olarak imkânsız.
 */
ShellRoot {
    id: root

    // ── 1. Arka plan / duvar kağıdı (tüm ekranlar, en altta) ──────────
    Variants {
        model: ScreenState.barScreens
        BackgroundLayer {
            property var modelData
            screen: modelData
        }
    }

    // ── 2. Üst bar (tüm ekranlar, exclusive zone) ─────────────────────
    Variants {
        model: ScreenState.barScreens
        PanelWindow {
            id: barWindow
            property var modelData
            screen: modelData
            visible: SystemState.isBarVisible

            WlrLayershell.namespace: "enyxma-bar"
            WlrLayershell.layer: WlrLayer.Top
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 36
            exclusiveZone: 36
            color: "transparent"

            Bar {
                anchors.fill: parent
            }
        }
    }

    // ── 3. OSD (odaklı ekran) ─────────────────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        OSD {
            property var modelData
            screen: modelData
        }
    }

    // ── 4. AI Kenar Çubuğu (odaklı ekran) ─────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        AISidebar {
            property var modelData
            screen: modelData
        }
    }

    // ── 5. Kontrol Merkezi (odaklı ekran) ─────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        ControlCenter {
            property var modelData
            screen: modelData
        }
    }

    // ── 6. Ağ Paneli (odaklı ekran) ───────────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        NetworkPanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 7. Depolama Paneli (odaklı ekran) ─────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        StoragePanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 8. Bildirim Pop-up (odaklı ekran) ─────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        NotificationPopup {
            property var modelData
            screen: modelData
        }
    }

    // ── 9. Performans Paneli (odaklı ekran) ───────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        PerformancePanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 10. Bildirim Paneli (odaklı ekran) ────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        NotificationPanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 11. Medya Paneli (odaklı ekran) ───────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        MediaPanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 12. Zaman & Takvim Paneli (odaklı ekran) ──────────────────────
    Variants {
        model: ScreenState.overlayScreens
        TimePanel {
            property var modelData
            screen: modelData
        }
    }

    // ── 13. Zaman Sağ Tık Menüsü (odaklı ekran) ───────────────────────
    Variants {
        model: ScreenState.overlayScreens
        TimeContextMenu {
            property var modelData
            screen: modelData
        }
    }

    // ── 14. Omni Launcher (odaklı ekran) ──────────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        OmniLauncher {
            property var modelData
            screen: modelData
        }
    }

    // ── 15. Duvar Kağıdı Seçici (odaklı ekran) ────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        WallpaperPicker {
            property var modelData
            screen: modelData
        }
    }

    // ── 16. Medya Tarayıcısı (odaklı ekran) ───────────────────────────
    Variants {
        model: ScreenState.overlayScreens
        MediaBrowser {
            property var modelData
            screen: modelData
        }
    }

    // ── 17. Genel Bakış / Mission Control (odaklı ekran) ──────────────
    Variants {
        model: ScreenState.overlayScreens
        Overview {
            property var modelData
            screen: modelData
        }
    }
}
