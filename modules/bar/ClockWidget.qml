import QtQuick
import "../../services"
import "./variants/dynamic"
import "./variants/gotham"

/**
 * ClockWidget — Saat ve Tarih Bileseni Yonlendiricisi.
 *
 * Secilen temaya gore uygun saat ve tarih varyantini yukler:
 *  - Gotham: Iki katmanli aviyonik saat ve teknik telemetri
 *  - Dynamic: Kapsul bento gostergesi
 */
Loader {
    id: root

    sourceComponent: Theme.isGotham ? gothamClockComponent : dynamicClockComponent

    Component {
        id: gothamClockComponent
        GothamClockWidget {}
    }

    Component {
        id: dynamicClockComponent
        DynamicClockWidget {}
    }
}
