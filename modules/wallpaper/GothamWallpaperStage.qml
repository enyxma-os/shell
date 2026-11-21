import QtQuick
import QtQuick.Layouts
import "../../services"

/**
 * GothamWallpaperStage — Gotham 2.0 Mimari Gorsel Arsiv ve Indeks Konsolu.
 *
 * Genis 16:9 ana onizleme ekrani ve altta yatay indeks film seridi ile
 * endustriyel duvar kagidi secim arayuzu sunar.
 */
Item {
    id: stage

    property var wallpapers: []
    property int selectedIndex: 0
    property string filterText: ""

    signal selectIndexRequested(int idx)
    signal moveRequested(int delta)
    signal applyRequested()
    signal refocusRequested()

    readonly property var currentEntry: (wallpapers.length > 0 && selectedIndex >= 0 && selectedIndex < wallpapers.length)
        ? wallpapers[selectedIndex]
        : null

    function pad2(n) {
        return n < 10 ? ("0" + n) : String(n)
    }

    Rectangle {
        id: consoleFrame
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 920)
        implicitHeight: consoleCol.implicitHeight + Theme.spacingMedium * 2
        radius: 0
        color: Theme.bgPanel
        border.width: 1
        border.color: Theme.borderSubtle

        // Ust 1px kehribar vurgu hatti
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 1
            color: Theme.accent
        }

        // Konsol uzerindeki tiklama ve tekerlek olaylarini yakala
        MouseArea {
            anchors.fill: parent
            onClicked: {}
            onWheel: function(wheel) {
                stage.moveRequested(wheel.angleDelta.y < 0 ? 1 : -1)
            }
        }

        ColumnLayout {
            id: consoleCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Theme.spacingMedium
            }
            spacing: Theme.spacingSmall

            // 1. Ust Komut Cubugu
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMedium

                Text {
                    text: "GOTHAM // GÖRSEL ARŞİV"
                    color: Theme.textPrimary
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    font.letterSpacing: 2
                }

                Item {
                    Layout.fillWidth: true
                }

                // Keskin segmentli tema secici
                Rectangle {
                    implicitWidth: 196
                    implicitHeight: 28
                    radius: Theme.radiusButton
                    color: Theme.bgDark
                    border.width: 1
                    border.color: Theme.borderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        Repeater {
                            model: [
                                { id: "dynamic", label: "DİNAMİK" },
                                { id: "gotham",  label: "GOTHAM" }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isSelected: WallpaperState.currentTheme === modelData.id

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: Theme.radiusSmall
                                color: isSelected
                                    ? Theme.accent
                                    : (segMa.containsMouse ? Theme.surfaceHover : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: isSelected ? Theme.accentOn : Theme.textSecondary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    id: segMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (WallpaperState.currentTheme !== modelData.id) {
                                            WallpaperState.setThemePreset(modelData.id)
                                        }
                                        stage.refocusRequested()
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Indeks Sayaci
                Rectangle {
                    implicitWidth: counterTxt.implicitWidth + 16
                    implicitHeight: 26
                    radius: Theme.radiusButton
                    color: Theme.surface1
                    border.width: 1
                    border.color: Theme.borderSubtle

                    Text {
                        id: counterTxt
                        anchors.centerIn: parent
                        text: "[ " + stage.pad2(stage.selectedIndex + 1) + " / " + stage.pad2(stage.wallpapers.length) + " ]"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }
            }

            // 2. Genis 16:9 Ana Onizleme Ekrani
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 330
                    radius: 0
                    color: Theme.bgDark
                    border.width: 1
                    border.color: Theme.borderSubtle
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: stage.currentEntry ? stage.currentEntry.filePath : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        sourceSize.width: 920
                        sourceSize.height: 520
                    }

                    // Sol ust keskin AKTIF kehribar rozeti
                    Rectangle {
                        visible: stage.currentEntry && stage.currentEntry.filePath === WallpaperState.currentWallpaper
                        x: 12
                        y: 12
                        width: activeTagTxt.implicitWidth + 16
                        height: 22
                        radius: Theme.radiusSmall
                        color: Theme.accent

                        Text {
                            id: activeTagTxt
                            anchors.centerIn: parent
                            text: "AKTİF"
                            color: Theme.accentOn
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stage.applyRequested()
                    }
                }

                // Onizleme alt bilgi seridi
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 0
                    color: Theme.surface1
                    border.width: 1
                    border.color: Theme.borderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingMedium
                        anchors.rightMargin: Theme.spacingMedium
                        spacing: Theme.spacingSmall

                        Text {
                            text: stage.currentEntry ? stage.currentEntry.label : ""
                            color: Theme.textPrimary
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fontSizeNormal
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "·"
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            visible: stage.currentEntry !== null
                        }

                        Text {
                            Layout.fillWidth: true
                            text: stage.currentEntry ? stage.currentEntry.fileName : ""
                            color: Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            visible: stage.filterText.length > 0
                            implicitWidth: filterBadgeTxt.implicitWidth + 12
                            implicitHeight: 22
                            radius: Theme.radiusSmall
                            color: Theme.surfaceActive
                            border.width: 1
                            border.color: Theme.accent

                            Text {
                                id: filterBadgeTxt
                                anchors.centerIn: parent
                                text: "FİLTRE: " + stage.filterText
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeXS
                                font.bold: true
                            }
                        }

                        Text {
                            visible: stage.filterText.length === 0
                            text: "ENTER UYGULA"
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.letterSpacing: 1
                        }
                    }
                }
            }

            // 3. Alt Yatay Indeks Film Seridi
            ListView {
                id: filmstrip
                Layout.fillWidth: true
                implicitHeight: 76
                orientation: ListView.Horizontal
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: stage.wallpapers
                currentIndex: stage.selectedIndex

                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex < count) {
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    }
                }

                delegate: Rectangle {
                    id: thumbCard
                    required property var modelData
                    required property int index
                    readonly property bool isSel: index === stage.selectedIndex
                    readonly property bool isCurr: modelData.filePath === WallpaperState.currentWallpaper

                    width: 136
                    height: 76
                    radius: Theme.radiusSmall
                    color: Theme.bgDark
                    border.width: isSel ? 2 : 1
                    border.color: isSel ? Theme.accent : (thumbMa.containsMouse ? Theme.borderFocus : Theme.borderSubtle)

                    Image {
                        anchors.fill: parent
                        anchors.margins: isSel ? 2 : 1
                        source: thumbCard.modelData.filePath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        sourceSize.width: 272
                        sourceSize.height: 152
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: isSel ? 2 : 1
                        color: Theme.bgDark
                        opacity: isSel ? 0.0 : (thumbMa.containsMouse ? 0.15 : 0.42)
                    }

                    // Sol ust indeks etiketi
                    Rectangle {
                        x: 4
                        y: 4
                        width: idxTxt.implicitWidth + 8
                        height: 16
                        radius: Theme.radiusSmall
                        color: isSel ? Theme.accent : Theme.bgDark
                        border.width: isSel ? 0 : 1
                        border.color: Theme.borderSubtle

                        Text {
                            id: idxTxt
                            anchors.centerIn: parent
                            text: stage.pad2(thumbCard.index + 1)
                            color: isSel ? Theme.accentOn : Theme.textSecondary
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSizeXS
                            font.bold: true
                        }
                    }

                    // Sag ust aktif nokta isaretcisi
                    Rectangle {
                        visible: isCurr
                        width: 6
                        height: 6
                        radius: 0
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 5
                        color: Theme.accent
                    }

                    MouseArea {
                        id: thumbMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (thumbCard.isSel) {
                                stage.applyRequested()
                            } else {
                                stage.selectIndexRequested(thumbCard.index)
                            }
                        }
                    }
                }
            }

            // 4. Alt Teknik Kontrol Satiri
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "← → SEÇ   ·   ↵ UYGULA   ·   T TEMA   ·   YAZARAK FİLTRELE   ·   ESC KAPAT"
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSmall
                font.letterSpacing: 1
            }
        }
    }
}
