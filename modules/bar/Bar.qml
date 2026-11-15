import QtQuick
import "../../services"

/**
 * Bar — Enyxma Shell Ust Paneli Yonlendiricisi.
 *
 * Secilen temaya gore uygun Bar varyantini yukler:
 *  - Gotham: Yekpare endustriyel kiris ve teknik konsol
 *  - Dynamic: Klasik yuvarlatilmis yuzen cam bar
 */
Loader {
    id: root

    sourceComponent: Theme.isGotham ? gothamBarComponent : dynamicBarComponent

    Component {
        id: gothamBarComponent
        GothamBar {}
    }

    Component {
        id: dynamicBarComponent
        DynamicBar {}
    }
}
