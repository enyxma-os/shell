pragma Singleton
import Quickshell
import QtQuick
import "."

Singleton {
    id: root

    readonly property string lang: SettingsState.language === "en" ? "en" : "tr"
    readonly property bool isEn: lang === "en"

    function t(trText, enText) {
        return root.isEn ? enText : trText
    }

    function pct(val) {
        return root.isEn ? (val + "%") : ("%" + val)
    }
}

