pragma Singleton
import Quickshell
import QtQuick
import "."

/**
 * Theme — tek renk/ölçü kaynağı.
 *
 * P0 DÜZELTMESİ: GeneratedColors guard'ı.
 *   Eski kod 20 yerde doğrudan `GeneratedColors.primary` okuyordu. matugen
 *   dosyayı yarım yazdığında, kullanıcı sildiğinde veya şablon hiç
 *   üretilmediğinde singleton çözümlenemiyor ve TÜM kabuk açılmıyordu.
 *   Artık `gen` bir kez çözümlenir; null ise her token kendi sabit
 *   semantik fallback'ine düşer. Tek bir tema dosyası oturumu düşüremez.
 */
Singleton {
    id: root

    // Dynamic Theming Control
    property bool dynamicColors: true

    // Tema üreteci hâlâ çalışıyorsa false → UI fallback renklerle açılır,
    // matugen bitince WallpaperState.reloadTheme() bu bayrağı true yapar.
    property bool themeReady: true

    // GeneratedColors'ın güvenli erişimi: yoksa null.
    readonly property var gen: (typeof GeneratedColors !== "undefined" && GeneratedColors) ? GeneratedColors : null
    readonly property bool hasGen: root.gen !== null && root.themeReady
    readonly property string preset: (root.hasGen && root.gen.preset) ? root.gen.preset : "dynamic"
    readonly property bool isGotham: root.preset === "gotham"

    // Motion Control
    readonly property bool reduceMotion: false
    readonly property int animFast: 150
    readonly property int animNormal: 240
    readonly property int animSlow: 350

    // ── Surfaces & Backgrounds ────────────────────────────────────────
    readonly property color bgGlass: root.hasGen
        ? Qt.rgba(root.gen.surface.r, root.gen.surface.g, root.gen.surface.b, 0.82)
        : Qt.rgba(0.07, 0.07, 0.10, 0.80)
    readonly property color bgPanel: root.hasGen
        ? Qt.rgba(root.gen.surfaceContainer.r, root.gen.surfaceContainer.g, root.gen.surfaceContainer.b, 0.95)
        : Qt.rgba(0.07, 0.08, 0.12, 0.95)
    readonly property color bgDark: root.hasGen ? root.gen.background : "#0B0F17"
    readonly property color surface1: root.hasGen
        ? Qt.rgba(root.gen.surfaceContainer.r, root.gen.surfaceContainer.g, root.gen.surfaceContainer.b, 0.50)
        : Qt.rgba(1, 1, 1, 0.05)
    readonly property color surface2: root.hasGen
        ? Qt.rgba(root.gen.surfaceContainerHigh.r, root.gen.surfaceContainerHigh.g, root.gen.surfaceContainerHigh.b, 0.70)
        : Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceHover: root.isGotham
        ? Qt.rgba(0.12, 0.14, 0.20, 0.78)
        : Qt.rgba(1, 1, 1, 0.10)
    readonly property color surfaceActive: root.isGotham
        ? Qt.rgba(0.15, 0.18, 0.25, 0.90)
        : Qt.rgba(1, 1, 1, 0.16)
    readonly property color scrim: root.isGotham
        ? Qt.rgba(0.02, 0.02, 0.03, 0.88)
        : Qt.rgba(0.0, 0.0, 0.0, 1.0)

    // ── Borders ───────────────────────────────────────────────────────
    readonly property int borderWidth: 1
    readonly property color borderSubtle: root.isGotham
        ? Qt.rgba(0.20, 0.24, 0.30, 0.65)
        : (root.hasGen
            ? Qt.rgba(root.gen.outline.r, root.gen.outline.g, root.gen.outline.b, 0.20)
            : Qt.rgba(1, 1, 1, 0.08))
    readonly property color borderFocus: root.hasGen
        ? Qt.rgba(root.gen.primary.r, root.gen.primary.g, root.gen.primary.b, 0.60)
        : Qt.rgba(0.22, 0.74, 0.97, 0.45)

    // ── Text & Accents ────────────────────────────────────────────────
    readonly property color textPrimary: root.hasGen ? root.gen.surfaceFg : "#F2F4F8"
    readonly property color textSecondary: root.hasGen ? root.gen.surfaceVariantFg : "#94A3B8"
    readonly property color textMuted: "#475569"
    readonly property color accent: root.hasGen ? root.gen.primary : "#38BDF8"
    readonly property color accentOn: root.hasGen ? root.gen.primaryFg : "#0B0F17"
    readonly property color secondary: root.hasGen ? root.gen.secondary : "#818CF8"
    readonly property color danger: root.hasGen ? root.gen.danger : "#F43F5E"
    readonly property color success: "#10B981"

    // ── Geometry & Spacing ────────────────────────────────────────────
    readonly property int radiusPanel: root.isGotham ? 0 : 14
    readonly property int radiusWidget: root.isGotham ? 2 : 10
    readonly property int radiusButton: root.isGotham ? 2 : 8
    readonly property int radiusSmall: root.isGotham ? 1 : 6
    readonly property int barMarginTop: root.isGotham ? 0 : 4
    readonly property int barMarginSide: root.isGotham ? 0 : 8
    readonly property int barHeight: root.isGotham ? 34 : 36
    readonly property int spacingXS: 4
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 12
    readonly property int spacingLarge: 18

    // ── Typography ────────────────────────────────────────────────────
    readonly property string fontFamily: "Inter"
    readonly property string fontDisplay: root.isGotham ? "Orbitron" : "Inter"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string aiLabel: root.isGotham ? "󰧑 AI" : "✦ AI"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 16

    // ── Screenshot & Mockup Tokens ────────────────────────────────────
    readonly property var mockupSwatches: [accent, "#ffffff", "#111111", "#e23b3b", "#f2c14e", "#5bbf73", "#4f8fe0", "#b06fe0"]
    readonly property color redactSolid: "#121216"
    readonly property var mockupPalette: [
        "#ffffff", "#0B0F17", "#38BDF8", "#F43F5E", "#F59E0B", "#10B981",
        "#6366F1", "#8B5CF6", "#EC4899", "#94A3B8", "#1E293B", "#334155"
    ]
    readonly property var mockupPresets: [
        { "a": "#38BDF8", "b": "#0284C7", "ang": 135 },
        { "a": "#10B981", "b": "#065F46", "ang": 135 },
        { "a": "#8B5CF6", "b": "#3B82F6", "ang": 135 },
        { "a": "#F43F5E", "b": "#BE123C", "ang": 135 },
        { "a": "#F59E0B", "b": "#D97706", "ang": 135 },
        { "a": "#1E293B", "b": "#0F172A", "ang": 135 },
        { "a": "#0B0F17", "b": "#1A2234", "ang": 135 },
        { "a": "#06B6D4", "b": "#3B82F6", "ang": 135 },
        { "a": "#EC4899", "b": "#8B5CF6", "ang": 135 },
        { "a": "#334155", "b": "#1E293B", "ang": 135 },
        { "a": "#0D9488", "b": "#115E59", "ang": 135 },
        { "a": "#18181B", "b": "#27272A", "ang": 135 }
    ]
    readonly property var mockupLooks: [
        { "name": "Enyxma Cyber", "cfg": { "bgKind": "preset", "bgPreset": 0, "padding": 88, "roundness": 20, "borderW": 1, "shadowStrength": 50, "shadowBlur": 50, "shadowDist": 20, "shadowAngle": 90 } },
        { "name": "Derin Uzay",   "cfg": { "bgKind": "preset", "bgPreset": 6, "padding": 96, "roundness": 24, "borderW": 0, "shadowStrength": 45, "shadowBlur": 60, "shadowDist": 24, "shadowAngle": 90 } },
        { "name": "Neon Menekşe", "cfg": { "bgKind": "preset", "bgPreset": 2, "padding": 88, "roundness": 20, "borderW": 0, "shadowStrength": 48, "shadowBlur": 55, "shadowDist": 22, "shadowAngle": 110 } },
        { "name": "Minimal Koyu", "cfg": { "bgKind": "solid",  "bgSolid": "#0B0F17", "padding": 64, "roundness": 16, "borderW": 1, "shadowStrength": 30, "shadowBlur": 40, "shadowDist": 16, "shadowAngle": 90 } },
        { "name": "Sade Cam",     "cfg": { "bgKind": "solid",  "bgSolid": "#1E293B", "padding": 72, "roundness": 14, "borderW": 1, "shadowStrength": 25, "shadowBlur": 35, "shadowDist": 12, "shadowAngle": 90 } },
        { "name": "Ham Kırpma",   "cfg": { "bgKind": "none",   "padding": 0,  "roundness": 0,  "borderW": 0, "shadowStrength": 0 } }
    ]
}
