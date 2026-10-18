pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Motion Control
    readonly property bool reduceMotion: false
    readonly property int animFast: 150
    readonly property int animNormal: 240
    readonly property int animSlow: 350

    // Surfaces
    readonly property color bgGlass: Qt.rgba(0.07, 0.07, 0.10, 0.80)
    readonly property color bgPanel: Qt.rgba(0.07, 0.08, 0.12, 0.95)
    readonly property color bgDark: "#0B0F17"
    readonly property color surface1: Qt.rgba(1, 1, 1, 0.05)
    readonly property color surface2: Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.10)
    readonly property color surfaceActive: Qt.rgba(1, 1, 1, 0.16)
    readonly property color scrim: Qt.rgba(0.0, 0.0, 0.0, 1.0)

    // Borders
    readonly property int borderWidth: 1
    readonly property color borderSubtle: Qt.rgba(1, 1, 1, 0.08)
    readonly property color borderFocus: Qt.rgba(0.22, 0.74, 0.97, 0.45)

    // Text & Accents
    readonly property color textPrimary: "#F2F4F8"
    readonly property color textSecondary: "#94A3B8"
    readonly property color textMuted: "#475569"
    readonly property color accent: "#38BDF8"
    readonly property color danger: "#F43F5E"
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
}
