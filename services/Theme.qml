pragma Singleton
import Quickshell
import QtQuick
import "."

Singleton {
    id: root

    // Dynamic Theming Control
    property bool dynamicColors: true

    // Motion Control
    readonly property bool reduceMotion: false
    readonly property int animFast: 150
    readonly property int animNormal: 240
    readonly property int animSlow: 350

    // Surfaces & Backgrounds
    readonly property color bgGlass: dynamicColors ? Qt.rgba(GeneratedColors.surface.r, GeneratedColors.surface.g, GeneratedColors.surface.b, 0.82) : Qt.rgba(0.07, 0.07, 0.10, 0.80)
    readonly property color bgPanel: dynamicColors ? Qt.rgba(GeneratedColors.surfaceContainer.r, GeneratedColors.surfaceContainer.g, GeneratedColors.surfaceContainer.b, 0.95) : Qt.rgba(0.07, 0.08, 0.12, 0.95)
    readonly property color bgDark: dynamicColors ? GeneratedColors.background : "#0B0F17"
    readonly property color surface1: dynamicColors ? Qt.rgba(GeneratedColors.surfaceContainer.r, GeneratedColors.surfaceContainer.g, GeneratedColors.surfaceContainer.b, 0.50) : Qt.rgba(1, 1, 1, 0.05)
    readonly property color surface2: dynamicColors ? Qt.rgba(GeneratedColors.surfaceContainerHigh.r, GeneratedColors.surfaceContainerHigh.g, GeneratedColors.surfaceContainerHigh.b, 0.70) : Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.10)
    readonly property color surfaceActive: Qt.rgba(1, 1, 1, 0.16)
    readonly property color scrim: Qt.rgba(0.0, 0.0, 0.0, 1.0)

    // Borders
    readonly property int borderWidth: 1
    readonly property color borderSubtle: dynamicColors ? Qt.rgba(GeneratedColors.outline.r, GeneratedColors.outline.g, GeneratedColors.outline.b, 0.20) : Qt.rgba(1, 1, 1, 0.08)
    readonly property color borderFocus: dynamicColors ? Qt.rgba(GeneratedColors.primary.r, GeneratedColors.primary.g, GeneratedColors.primary.b, 0.60) : Qt.rgba(0.22, 0.74, 0.97, 0.45)

    // Text & Accents
    readonly property color textPrimary: dynamicColors ? GeneratedColors.surfaceFg : "#F2F4F8"
    readonly property color textSecondary: dynamicColors ? GeneratedColors.surfaceVariantFg : "#94A3B8"
    readonly property color textMuted: "#475569"
    readonly property color accent: dynamicColors ? GeneratedColors.primary : "#38BDF8"
    readonly property color accentOn: dynamicColors ? GeneratedColors.primaryFg : "#0B0F17"
    readonly property color secondary: dynamicColors ? GeneratedColors.secondary : "#818CF8"
    readonly property color danger: dynamicColors ? GeneratedColors.danger : "#F43F5E"
    readonly property color success: "#10B981"

    // Geometry & Spacing
    readonly property int radiusPanel: 14
    readonly property int radiusWidget: 10
    readonly property int radiusButton: 8
    readonly property int radiusSmall: 6
    readonly property int spacingXS: 4
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 12
    readonly property int spacingLarge: 18

    // Typography
    readonly property string fontFamily: "Inter"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 16

    // Screenshot & Mockup Tokens
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
