// Default Enyxma Design Tokens (Tokyo Cyber Neon)
// When Matugen runs, this file will be updated with dynamic palette values.
pragma Singleton
import QtQuick

QtObject {
    id: root

    // Primary Accents
    property color primary: "#38BDF8"
    property color primaryFg: "#0B0F17"
    property color primaryContainer: "#0369A1"
    property color primaryContainerFg: "#E0F2FE"

    // Secondary & Tertiary
    property color secondary: "#818CF8"
    property color secondaryFg: "#0B0F17"
    property color tertiary: "#C084FC"
    property color tertiaryFg: "#0B0F17"

    // Surfaces & Containers
    property color background: "#0B0F17"
    property color backgroundFg: "#F2F4F8"
    property color surface: "#0B0F17"
    property color surfaceFg: "#F2F4F8"
    property color surfaceContainer: "#131822"
    property color surfaceContainerHigh: "#1E2536"
    property color surfaceVariantFg: "#94A3B8"

    // Outlines & Borders
    property color outline: "#334155"
    property color outlineVariant: "#1E293B"

    // State & Status
    property color danger: "#F43F5E"
    property color dangerFg: "#FFFFFF"
}
