import QtQuick
import "../../services"
import "./variants/dynamic"
import "./variants/gotham"

/**
 * Workspaces — Calisma Alanlari Bileseni Yonlendiricisi.
 *
 * Secilen temaya gore uygun calisma alani varyantini yukler:
 *  - Gotham: Sabit genislikli mimari sektor hucreleri
 *  - Dynamic: Klasik kapsul hap gostergesi
 */
Loader {
    id: root

    sourceComponent: Theme.isGotham ? gothamWorkspacesComponent : dynamicWorkspacesComponent

    Component {
        id: gothamWorkspacesComponent
        GothamWorkspaces {}
    }

    Component {
        id: dynamicWorkspacesComponent
        DynamicWorkspaces {}
    }
}
