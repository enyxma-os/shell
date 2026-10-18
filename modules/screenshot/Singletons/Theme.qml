pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color bgGlass: Qt.rgba(0.07, 0.07, 0.10, 0.80)
    readonly property color bgPanel: Qt.rgba(0.07, 0.08, 0.12, 0.95)
    readonly property color bgDark: Qt.rgba(0.043, 0.059, 0.090, 1.0)
    readonly property color surface1: Qt.rgba(1, 1, 1, 0.05)
    readonly property color surface2: Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.12)
    readonly property color surfaceActive: Qt.rgba(0.22, 0.74, 0.97, 0.20)
    readonly property color scrim: Qt.rgba(0.0, 0.0, 0.0, 0.75)

    readonly property int borderWidth: 1
    readonly property color borderSubtle: Qt.rgba(1, 1, 1, 0.08)
    readonly property color borderFocus: Qt.rgba(0.22, 0.74, 0.97, 0.45)

    readonly property color textPrimary: Qt.rgba(0.949, 0.957, 0.973, 1.0)
    readonly property color textSecondary: Qt.rgba(0.580, 0.639, 0.722, 1.0)
    readonly property color textMuted: Qt.rgba(0.278, 0.333, 0.412, 1.0)
    readonly property color accent: Qt.rgba(0.220, 0.741, 0.973, 1.0)
    readonly property color danger: Qt.rgba(0.957, 0.247, 0.369, 1.0)
    readonly property color success: Qt.rgba(0.063, 0.725, 0.506, 1.0)

    readonly property int radiusPanel: 14
    readonly property int radiusWidget: 10
    readonly property int radiusButton: 8
    readonly property int radiusSmall: 6
    readonly property int animFast: 150
    readonly property int animNormal: 240

    readonly property string fontFamily: "Inter"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 16

    readonly property var mockupSwatches: [
        accent,
        Qt.rgba(1, 1, 1, 1),
        Qt.rgba(0.07, 0.07, 0.07, 1),
        Qt.rgba(0.89, 0.23, 0.23, 1),
        Qt.rgba(0.95, 0.76, 0.31, 1),
        Qt.rgba(0.36, 0.75, 0.45, 1),
        Qt.rgba(0.31, 0.56, 0.88, 1),
        Qt.rgba(0.69, 0.44, 0.88, 1)
    ]
    readonly property color redactSolid: Qt.rgba(0.07, 0.07, 0.09, 1.0)
    readonly property var mockupPalette: [
        Qt.rgba(1, 1, 1, 1),
        Qt.rgba(0.043, 0.059, 0.090, 1),
        Qt.rgba(0.220, 0.741, 0.973, 1),
        Qt.rgba(0.957, 0.247, 0.369, 1),
        Qt.rgba(0.961, 0.620, 0.043, 1),
        Qt.rgba(0.063, 0.725, 0.506, 1),
        Qt.rgba(0.388, 0.400, 0.945, 1),
        Qt.rgba(0.545, 0.361, 0.965, 1),
        Qt.rgba(0.925, 0.282, 0.600, 1),
        Qt.rgba(0.580, 0.639, 0.722, 1),
        Qt.rgba(0.118, 0.161, 0.231, 1),
        Qt.rgba(0.200, 0.255, 0.333, 1)
    ]
    readonly property var mockupPresets: [
        { "a": Qt.rgba(0.22, 0.74, 0.97, 1), "b": Qt.rgba(0.01, 0.52, 0.78, 1), "ang": 135 },
        { "a": Qt.rgba(0.06, 0.73, 0.51, 1), "b": Qt.rgba(0.02, 0.37, 0.27, 1), "ang": 135 },
        { "a": Qt.rgba(0.55, 0.36, 0.96, 1), "b": Qt.rgba(0.23, 0.51, 0.96, 1), "ang": 135 },
        { "a": Qt.rgba(0.96, 0.25, 0.37, 1), "b": Qt.rgba(0.75, 0.07, 0.24, 1), "ang": 135 },
        { "a": Qt.rgba(0.96, 0.62, 0.04, 1), "b": Qt.rgba(0.85, 0.47, 0.02, 1), "ang": 135 },
        { "a": Qt.rgba(0.12, 0.16, 0.23, 1), "b": Qt.rgba(0.06, 0.09, 0.16, 1), "ang": 135 },
        { "a": Qt.rgba(0.04, 0.06, 0.09, 1), "b": Qt.rgba(0.10, 0.13, 0.20, 1), "ang": 135 },
        { "a": Qt.rgba(0.02, 0.71, 0.83, 1), "b": Qt.rgba(0.23, 0.51, 0.96, 1), "ang": 135 },
        { "a": Qt.rgba(0.93, 0.28, 0.60, 1), "b": Qt.rgba(0.55, 0.36, 0.96, 1), "ang": 135 },
        { "a": Qt.rgba(0.20, 0.25, 0.33, 1), "b": Qt.rgba(0.12, 0.16, 0.23, 1), "ang": 135 },
        { "a": Qt.rgba(0.05, 0.58, 0.53, 1), "b": Qt.rgba(0.07, 0.37, 0.35, 1), "ang": 135 },
        { "a": Qt.rgba(0.09, 0.09, 0.11, 1), "b": Qt.rgba(0.15, 0.15, 0.16, 1), "ang": 135 }
    ]
    readonly property var mockupLooks: [
        { "name": "Enyxma Cyber", "cfg": { "bgKind": "preset", "bgPreset": 0, "padding": 88, "roundness": 20, "borderW": 1, "shadowStrength": 50, "shadowBlur": 50, "shadowDist": 20, "shadowAngle": 90 } },
        { "name": "Derin Uzay",   "cfg": { "bgKind": "preset", "bgPreset": 6, "padding": 96, "roundness": 24, "borderW": 0, "shadowStrength": 45, "shadowBlur": 60, "shadowDist": 24, "shadowAngle": 90 } },
        { "name": "Neon Menekşe", "cfg": { "bgKind": "preset", "bgPreset": 2, "padding": 88, "roundness": 20, "borderW": 0, "shadowStrength": 48, "shadowBlur": 55, "shadowDist": 22, "shadowAngle": 110 } },
        { "name": "Minimal Koyu", "cfg": { "bgKind": "solid",  "bgSolid": Qt.rgba(0.043, 0.059, 0.090, 1), "padding": 64, "roundness": 16, "borderW": 1, "shadowStrength": 30, "shadowBlur": 40, "shadowDist": 16, "shadowAngle": 90 } },
        { "name": "Sade Cam",     "cfg": { "bgKind": "solid",  "bgSolid": Qt.rgba(0.118, 0.161, 0.231, 1), "padding": 72, "roundness": 14, "borderW": 1, "shadowStrength": 25, "shadowBlur": 35, "shadowDist": 12, "shadowAngle": 90 } },
        { "name": "Ham Kırpma",   "cfg": { "bgKind": "none",   "padding": 0,  "roundness": 0,  "borderW": 0, "shadowStrength": 0 } }
    ]
}
