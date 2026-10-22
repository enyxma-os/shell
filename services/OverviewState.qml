pragma Singleton
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

/**
 * OverviewState — Mission Control.
 *
 * P1 DÜZELTMESİ:
 *   Eski kod `hyprctl dispatch "hl.dsp.focus({...})"` çağırıyordu: bu
 *   Hyprland'in Lua dispatcher sözdizimidir ve Lua modu KAPALI olan her
 *   sistemde sessizce başarısız olur. Ayrıca veri için 3 ayrı `hyprctl`
 *   süreci (printf + $(...) ile) doğuruyordu.
 *
 *   Artık:
 *   • Veri: `Hyprland.toplevels` ve `Hyprland.workspaces` (yerel bağlayıcı,
 *     süreç yok, event-güdümlü).
 *   • Eylem: `Hyprland.dispatch(...)` — `usingLua` durumuna göre iki sözdizimi.
 *   • Kapatma: `HyprlandToplevel.wayland.close()` (native).
 *
 *   NOT: `Hyprland.focusedMonitor.screen` diye bir özellik yoktur;
 *   HyprlandMonitor yalnızca name/id/focused/x/y/w/h/scale taşır.
 */
Singleton {
    id: root

    property bool isOpen: false
    property int activeWorkspaceId: 1
    property int viewedWorkspaceId: 1
    property int selectedIndex: 0

    // Yerel modelden türetilmiş istemci listesi (süreç yok)
    readonly property var clients: {
        const out = []
        const tl = Hyprland.toplevels ? Hyprland.toplevels.values : []
        for (let i = 0; i < tl.length; i++) {
            const t = tl[i]
            if (!t) continue
            const wsId = t.workspace ? t.workspace.id : 0
            if (wsId <= 0) continue // özel/adlandırılmış çalışma alanlarını atla
            out.push({
                address: t.address || "",
                title: t.title || "",
                "class": t.wayland ? (t.wayland.appId || "") : "",
                workspace: { id: wsId },
                mapped: true,
                handle: t
            })
        }
        return out
    }

    readonly property var workspaces: {
        const out = []
        const ws = Hyprland.workspaces ? Hyprland.workspaces.values : []
        for (let i = 0; i < ws.length; i++) {
            if (ws[i] && ws[i].id > 0) out.push({ id: ws[i].id, name: ws[i].name || String(ws[i].id) })
        }
        out.sort((a, b) => a.id - b.id)
        return out
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.selectedIndex = 0
            if (Hyprland.focusedWorkspace) root.activeWorkspaceId = Hyprland.focusedWorkspace.id
            root.viewedWorkspaceId = root.activeWorkspaceId
            Hyprland.refreshToplevels()
            Hyprland.refreshWorkspaces()
        }
    }

    function toggle(): void { root.isOpen ? root.close() : root.open() }
    function open(): void {
        root.isOpen = true
        root.selectedIndex = 0
        if (Hyprland.focusedWorkspace) {
            root.activeWorkspaceId = Hyprland.focusedWorkspace.id
            root.viewedWorkspaceId = root.activeWorkspaceId
        }
        Hyprland.refreshToplevels()
        Hyprland.refreshWorkspaces()
    }
    function close(): void { root.isOpen = false }

    function next(): void {
        if (!root.isOpen) { root.open(); return }
        if (root.clients.length > 0)
            root.selectedIndex = (root.selectedIndex + 1) % root.clients.length
    }

    function prev(): void {
        if (!root.isOpen) { root.open(); return }
        if (root.clients.length > 0)
            root.selectedIndex = (root.selectedIndex - 1 + root.clients.length) % root.clients.length
    }

    function activateSelected(): void {
        if (root.clients.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.clients.length)
            root.focusClient(root.clients[root.selectedIndex].address)
        else
            root.switchWorkspace(root.viewedWorkspaceId)
    }

    function closeSelected(): void {
        if (root.clients.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.clients.length)
            root.closeClient(root.clients[root.selectedIndex].address)
    }

    // ── Eylemler: native Hyprland bağlayıcısı ────────────────────────
    function focusClient(addr): void {
        if (!addr) return
        root.close()
        // Yalnızca Hyprland'in yerel dispatcher sözdizimi. `hl.dsp.*` Lua
        // sarmalayıcısı Lua modu kapalı sistemlerde sessizce başarısız
        // olduğu için tamamen kaldırıldı (tek kod yolu = tek davranış).
        Hyprland.dispatch("focuswindow address:" + addr)
    }

    function closeClient(addr): void {
        if (!addr) return
        Hyprland.dispatch("killwindow address:" + addr)
        Hyprland.refreshToplevels()
    }

    function switchWorkspace(id): void {
        if (!(id > 0)) return
        root.close()
        Hyprland.dispatch("workspace " + id)
    }

    function createWorkspace(): void {
        var nextId = 1
        for (var i = 0; i < root.workspaces.length; i++) {
            if (root.workspaces[i].id >= nextId) nextId = root.workspaces[i].id + 1
        }
        root.switchWorkspace(nextId)
    }

    function cycleWorkspace(delta): void {
        if (root.workspaces.length === 0) return
        var curIdx = 0
        for (var i = 0; i < root.workspaces.length; i++) {
            if (root.workspaces[i].id === root.viewedWorkspaceId) { curIdx = i; break }
        }
        var nextIdx = ((curIdx + delta) % root.workspaces.length + root.workspaces.length) % root.workspaces.length
        root.viewedWorkspaceId = root.workspaces[nextIdx].id
    }

    function clientsForWorkspace(wsId) {
        return root.clients.filter(c => c.workspace && c.workspace.id === wsId)
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function next(): void { root.next() }
        function prev(): void { root.prev() }
        function activate(): void { root.activateSelected() }
    }
}
