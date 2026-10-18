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

ShellRoot {
    id: root

    // Arka Plan / Duvar Kağıdı katmanı (Çoklu ekran - En altta olmalı)
    Variants {
        model: Quickshell.screens

        BackgroundLayer {
            property var modelData
            screen: modelData
        }
    }

    // Bar katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            property var modelData
            screen: modelData

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

    // OSD katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        OSD {
            property var modelData
            screen: modelData
        }
    }

    // AI Sidebar katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        AISidebar {
            property var modelData
            screen: modelData
        }
    }

    // Kontrol Merkezi (Control Center) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        ControlCenter {
            property var modelData
            screen: modelData
        }
    }

    // Ağ Paneli (Network Panel) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        NetworkPanel {
            property var modelData
            screen: modelData
        }
    }

    // Depolama Paneli (Storage Panel) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        StoragePanel {
            property var modelData
            screen: modelData
        }
    }

    // Bildirim Pop-up katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        NotificationPopup {
            property var modelData
            screen: modelData
        }
    }

    // Performans Paneli (Performance Panel) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        PerformancePanel {
            property var modelData
            screen: modelData
        }
    }

    // Bildirim Paneli (Notification Panel) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        NotificationPanel {
            property var modelData
            screen: modelData
        }
    }

    // Medya Paneli (Media Panel) katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        MediaPanel {
            property var modelData
            screen: modelData
        }
    }

    // Zaman & Takvim Paneli (Harmonik Bento Hub) (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        TimePanel {
            property var modelData
            screen: modelData
        }
    }

    // Zaman Sağ Tık Hızlı Ayar Menüsü (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        TimeContextMenu {
            property var modelData
            screen: modelData
        }
    }

    // Omni Launcher katmanı (Çoklu ekran)
    Variants {
        model: Quickshell.screens

        OmniLauncher {
            property var modelData
            screen: modelData
        }
    }
}
