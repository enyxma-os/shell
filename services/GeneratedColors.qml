// Enyxma Live Theming — VARSAYILAN M3 koyu palet.
//
// Bu dosya matugen tarafından ÜZERİNE YAZILIR (templates/GeneratedColors.qml.in).
// Repoda bulunmasının nedeni: `services/qmldir` bu singleton'ı ilan ediyor ve
// matugen hiç çalışmamışsa (temiz kurulum, paketli sistem) dosya yoksa
// `import "./services"` aşaması çöker ve TÜM kabuk açılmazdı.
// Theme.qml ayrıca `hasGen` guard'ı ile bozuk içeriğe karşı korumalıdır.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string preset: "dynamic"

    // Primary / Accent
    property color primary: "#38bdf8"
    property color primaryFg: "#00344a"
    property color secondary: "#818cf8"
    property color secondaryFg: "#0b0f17"
    property color tertiary: "#c4b5fd"
    property color tertiaryFg: "#1a1033"

    // Surface seti (M3 tonal)
    property color background: "#0b0f17"
    property color backgroundFg: "#e6e9f0"
    property color surface: "#0f1420"
    property color surfaceFg: "#e6e9f0"
    property color surfaceContainer: "#151b28"
    property color surfaceContainerHigh: "#1c2333"
    property color surfaceVariantFg: "#a7b0c0"

    // Outline
    property color outline: "#3a4356"
    property color outlineVariant: "#242c3b"

    // Durum
    property color danger: "#f43f5e"
    property color dangerFg: "#3d0011"
}
