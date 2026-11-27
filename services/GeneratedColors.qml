// Enyxma Live Theming — Reaktif M3 / Gotham 2.0 Palet Köprüsü.
//
// Dinamik renkler `~/.config/enyxma/colors.json` üzerinden FileView ile
// canlı okunur; `services/GeneratedColors.qml` dosyası asla üzerine yazılmaz.
// Böylece Quickshell tema değişiminde QML ağacını baştan yüklemez.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string preset: "dynamic"
    readonly property bool _g: root.preset === "gotham"

    // Dinamik M3 arka plan renkleri (colors.json yüklendikçe güncellenir)
    property color _dynPrimary: "#38bdf8"
    property color _dynPrimaryFg: "#00344a"
    property color _dynPrimaryContainer: "#0c4a6e"
    property color _dynPrimaryContainerFg: "#bae6fd"
    property color _dynSecondary: "#818cf8"
    property color _dynSecondaryFg: "#0b0f17"
    property color _dynTertiary: "#c4b5fd"
    property color _dynTertiaryFg: "#1a1033"
    property color _dynBackground: "#0b0f17"
    property color _dynBackgroundFg: "#e6e9f0"
    property color _dynSurface: "#0f1420"
    property color _dynSurfaceFg: "#e6e9f0"
    property color _dynSurfaceContainer: "#151b28"
    property color _dynSurfaceContainerHigh: "#1c2333"
    property color _dynSurfaceVariantFg: "#a7b0c0"
    property color _dynOutline: "#3a4356"
    property color _dynOutlineVariant: "#242c3b"
    property color _dynDanger: "#f43f5e"
    property color _dynDangerFg: "#3d0011"

    // Dışa açık reaktif renk token'ları (Gotham <-> Dinamik anlık geçiş)
    readonly property color primary: root._g ? "#f0b429" : root._dynPrimary
    readonly property color primaryFg: root._g ? "#07080b" : root._dynPrimaryFg
    readonly property color primaryContainer: root._g ? "#241e0a" : root._dynPrimaryContainer
    readonly property color primaryContainerFg: root._g ? "#fcd34d" : root._dynPrimaryContainerFg

    readonly property color secondary: root._g ? "#64748b" : root._dynSecondary
    readonly property color secondaryFg: root._g ? "#07080b" : root._dynSecondaryFg
    readonly property color tertiary: root._g ? "#94a3b8" : root._dynTertiary
    readonly property color tertiaryFg: root._g ? "#07080b" : root._dynTertiaryFg

    readonly property color background: root._g ? "#07080b" : root._dynBackground
    readonly property color backgroundFg: root._g ? "#e2e8f0" : root._dynBackgroundFg
    readonly property color surface: root._g ? "#0b0d12" : root._dynSurface
    readonly property color surfaceFg: root._g ? "#e2e8f0" : root._dynSurfaceFg
    readonly property color surfaceContainer: root._g ? "#11141c" : root._dynSurfaceContainer
    readonly property color surfaceContainerHigh: root._g ? "#171b26" : root._dynSurfaceContainerHigh
    readonly property color surfaceVariantFg: root._g ? "#94a3b8" : root._dynSurfaceVariantFg

    readonly property color outline: root._g ? "#333c4d" : root._dynOutline
    readonly property color outlineVariant: root._g ? "#222834" : root._dynOutlineVariant

    readonly property color danger: root._g ? "#e11d48" : root._dynDanger
    readonly property color dangerFg: root._g ? "#07080b" : root._dynDangerFg

    FileView {
        id: paletteFile
        path: (Quickshell.env("HOME") || "") + "/.config/enyxma/colors.json"
        printErrors: false
        blockLoading: false
        onLoaded: root._applyJson(paletteFile.text())
    }

    function _applyJson(raw) {
        try {
            var s = String(raw || "").trim()
            if (!s) return
            var d = JSON.parse(s)
            if (!d || typeof d !== "object") return
            var re = /^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/
            if (typeof d.primary === "string" && re.test(d.primary)) root._dynPrimary = d.primary
            if (typeof d.primaryFg === "string" && re.test(d.primaryFg)) root._dynPrimaryFg = d.primaryFg
            if (typeof d.primaryContainer === "string" && re.test(d.primaryContainer)) root._dynPrimaryContainer = d.primaryContainer
            if (typeof d.primaryContainerFg === "string" && re.test(d.primaryContainerFg)) root._dynPrimaryContainerFg = d.primaryContainerFg
            if (typeof d.secondary === "string" && re.test(d.secondary)) root._dynSecondary = d.secondary
            if (typeof d.secondaryFg === "string" && re.test(d.secondaryFg)) root._dynSecondaryFg = d.secondaryFg
            if (typeof d.tertiary === "string" && re.test(d.tertiary)) root._dynTertiary = d.tertiary
            if (typeof d.tertiaryFg === "string" && re.test(d.tertiaryFg)) root._dynTertiaryFg = d.tertiaryFg
            if (typeof d.background === "string" && re.test(d.background)) root._dynBackground = d.background
            if (typeof d.backgroundFg === "string" && re.test(d.backgroundFg)) root._dynBackgroundFg = d.backgroundFg
            if (typeof d.surface === "string" && re.test(d.surface)) root._dynSurface = d.surface
            if (typeof d.surfaceFg === "string" && re.test(d.surfaceFg)) root._dynSurfaceFg = d.surfaceFg
            if (typeof d.surfaceContainer === "string" && re.test(d.surfaceContainer)) root._dynSurfaceContainer = d.surfaceContainer
            if (typeof d.surfaceContainerHigh === "string" && re.test(d.surfaceContainerHigh)) root._dynSurfaceContainerHigh = d.surfaceContainerHigh
            if (typeof d.surfaceVariantFg === "string" && re.test(d.surfaceVariantFg)) root._dynSurfaceVariantFg = d.surfaceVariantFg
            if (typeof d.outline === "string" && re.test(d.outline)) root._dynOutline = d.outline
            if (typeof d.outlineVariant === "string" && re.test(d.outlineVariant)) root._dynOutlineVariant = d.outlineVariant
            if (typeof d.danger === "string" && re.test(d.danger)) root._dynDanger = d.danger
            if (typeof d.dangerFg === "string" && re.test(d.dangerFg)) root._dynDangerFg = d.dangerFg
        } catch (e) {
            console.warn("GeneratedColors: colors.json okunamadi:", e)
        }
    }

    function setPreset(name) {
        root.preset = (name === "gotham") ? "gotham" : "dynamic"
    }

    function reload() {
        paletteFile.reload()
    }
}
