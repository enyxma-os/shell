pragma Singleton
import QtQuick
import "."

Singleton {
    id: root

    readonly property string lang: SettingsState.language === "en" ? "en" : "tr"
    readonly property bool isEn: lang === "en"

    function t(trText, enText) {
        return root.isEn ? enText : trText
    }
}
