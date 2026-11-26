import QtQuick
import QtQuick.Effects
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import "Singletons"

Item {
    id: beautify

    property string srcPath: ""
    property string bgImagePath: ""

    signal copyRequested(string path)
    signal saveRequested(string path)
    signal pickImageRequested()
    signal closeRequested()

    readonly property string exportTmp: "/tmp/enyxma-shot-beautified.png"

    focus: true
    onVisibleChanged: {
        if (visible) forceActiveFocus();
    }

    function doSaveAction() {
        if (!beautify.busy && !beautify.savedNotice) {
            beautify.savedNotice = true;
            beautify.exportStage(beautify.exportTmp, function (ok) {
                if (ok) beautify.saveRequested(beautify.exportTmp);
                else beautify.savedNotice = false;
            });
        }
    }

    function doCopyAction() {
        if (!beautify.busy && !beautify.copiedNotice) {
            beautify.copiedNotice = true;
            beautify.exportStage(beautify.exportTmp, function (ok) {
                if (ok) beautify.copyRequested(beautify.exportTmp);
                else beautify.copiedNotice = false;
            });
        }
    }

    Keys.onPressed: (e) => {
        var ctrl = (e.modifiers & Qt.ControlModifier) !== 0;
        if (ctrl) {
            if (e.key === Qt.Key_S) { doSaveAction(); e.accepted = true; return; }
            if (e.key === Qt.Key_C) { doCopyAction(); e.accepted = true; return; }
        }
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
            doSaveAction();
            e.accepted = true;
            return;
        }
        if (e.key === Qt.Key_Escape) {
            beautify.closeRequested();
            e.accepted = true;
            return;
        }
    }

    // ---- State ----
    property string bgKind: "preset"     // preset | solid | gradient | image | none
    property int bgPreset: 0
    property color bgSolid: Theme.bgDark
    property color bgGradA: Theme.accent
    property color bgGradB: Qt.rgba(0.01, 0.52, 0.78, 1.0)
    property real bgGradAngle: 135
    property real padding: 88
    property real roundness: 20
    property real borderW: 0
    property color borderColor: Theme.borderSubtle
    property real shadowStrength: 45
    property real shadowBlur: 55
    property real shadowDist: 20
    property real shadowAngle: 90
    property real adjBright: 0
    property real adjContrast: 0
    property real adjSat: 0
    property string ratioKey: "auto"
    property bool watermark: true
    property bool savedNotice: false
    property bool copiedNotice: false
    readonly property string userName: Quickshell.env("USER") || "enyxma"
    property bool composeOnly: false
    property string composeMode: ""
    property bool busy: false

    readonly property var presets: Theme.mockupPresets
    readonly property var palette: Theme.mockupPalette
    readonly property var looks: Theme.mockupLooks

    readonly property var ratioRow: {
        var _l = Theme.lang;
        return [
            { "k": "auto", "l": Theme.t("Serbest", "Auto") }, { "k": "1:1", "l": Theme.t("1:1 Kare", "1:1 Square") }, { "k": "4:3", "l": "4:3" },
            { "k": "16:9", "l": Theme.t("16:9 Geniş", "16:9 Wide") }, { "k": "9:16", "l": Theme.t("9:16 Dikey", "9:16 Vertical") }
        ];
    }
    readonly property var socialRow: [
        { "k": "x", "l": "X (Twitter)" }, { "k": "instagram", "l": "Instagram" },
        { "k": "linkedin", "l": "LinkedIn" }, { "k": "youtube", "l": "YouTube" }
    ]
    readonly property var ratioMap: ({ "auto": 0, "1:1": 1, "4:3": 1.3333, "16:9": 1.7778, "9:16": 0.5625, "x": 1.7778, "instagram": 1, "linkedin": 1.91, "youtube": 1.7778 })

    // ---- Resolved Background ----
    readonly property bool bgIsGradient: bgKind === "preset" || bgKind === "gradient"
    readonly property color bgA: (bgKind === "preset" && presets && presets.length > bgPreset) ? presets[bgPreset].a : bgGradA
    readonly property color bgB: (bgKind === "preset" && presets && presets.length > bgPreset) ? presets[bgPreset].b : bgGradB
    readonly property real bgAngle: (bgKind === "preset" && presets && presets.length > bgPreset) ? presets[bgPreset].ang : bgGradAngle

    // ---- Geometry (Full Resolution) ----
    readonly property real natW: img.sourceSize.width > 0 ? img.sourceSize.width : 800
    readonly property real natH: img.sourceSize.height > 0 ? img.sourceSize.height : 500
    readonly property real minW: natW + 2 * padding
    readonly property real minH: natH + 2 * padding
    readonly property real ratioV: ratioMap[ratioKey] !== undefined ? ratioMap[ratioKey] : 0
    readonly property real fullW: ratioV <= 0 ? minW : (ratioV >= minW / minH ? minH * ratioV : minW)
    readonly property real fullH: ratioV <= 0 ? minH : (ratioV >= minW / minH ? minH : minW / ratioV)

    function exportStage(path, cb) {
        beautify.busy = true;
        function done(ok) {
            beautify.busy = false;
            if (cb) cb(ok);
        }
        var scheduled = stage.grabToImage(function (r) {
            var ok = false;
            try {
                ok = r ? r.saveToFile(path) : false;
            } catch (e) {
                console.log("enyxma-shot: beautify grab failed: " + e);
            }
            done(ok);
        }, Qt.size(Math.round(beautify.fullW), Math.round(beautify.fullH)));
        if (!scheduled) done(false);
    }

    function applyLook(c) {
        for (var k in c)
            beautify[k] = c[k];
    }

    // ============================ Backdrop ============================
    Rectangle {
        anchors.fill: parent
        color: Theme.bgDark
    }

    // ============================ Top Bar ============================
    Rectangle {
        id: topbar
        visible: !beautify.composeOnly
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 56
        color: Theme.bgPanel
        border.color: Theme.borderSubtle
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "✦"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.Bold
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.t("Mockup Stüdyosu", "Mockup Studio")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.DemiBold
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.t("paylaşıma hazır görsel", "share-ready visual")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            TopBtn {
                label: Theme.t("Geri / İptal", "Back / Cancel")
                onTapped: beautify.closeRequested()
            }

            TopBtn {
                label: beautify.busy ? Theme.t("İşleniyor...", "Processing...") : (beautify.copiedNotice ? Theme.t("✦ Kopyalandı!", "✦ Copied!") : Theme.t("Panoya Kopyala (Ctrl+C)", "Copy to Clipboard (Ctrl+C)"))
                onTapped: beautify.doCopyAction()
            }

            TopBtn {
                label: beautify.busy ? Theme.t("İşleniyor...", "Processing...") : (beautify.savedNotice ? Theme.t("✦ Kaydedildi!", "✦ Saved!") : Theme.t("Görseli Kaydet (Ctrl+S)", "Save Image (Ctrl+S)"))
                accent: true
                onTapped: beautify.doSaveAction()
            }
        }
    }

    // ============================ Right Settings Panel ============================
    Rectangle {
        id: panel
        visible: !beautify.composeOnly
        anchors.right: parent.right
        anchors.top: topbar.bottom
        anchors.bottom: parent.bottom
        width: 360
        color: Theme.bgPanel
        border.color: Theme.borderSubtle
        border.width: 1

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 16
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            contentHeight: pcol.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: pcol
                width: flick.width - 12
                spacing: 22

                // ---------- ÖN AYARLAR ----------
                Group {
                    title: Theme.t("ÖN AYARLI TEMALAR", "PRESET THEMES")
                    Flow {
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: beautify.looks
                            Pill {
                                required property var modelData
                                label: modelData.name
                                onTapped: beautify.applyLook(modelData.cfg)
                            }
                        }
                    }
                }

                // ---------- ARKA PLAN ----------
                Group {
                    title: Theme.t("ARKA PLAN", "BACKGROUND")
                    Grid {
                        width: parent.width
                        columns: 6
                        columnSpacing: 8
                        rowSpacing: 8
                        Repeater {
                            model: beautify.presets
                            Rectangle {
                                id: cell
                                required property int index
                                required property var modelData
                                width: (parent.width - 5 * 8) / 6
                                height: 32
                                radius: Theme.radiusSmall
                                readonly property bool sel: beautify.bgKind === "preset" && beautify.bgPreset === cell.index
                                border.color: cell.sel ? Theme.accent : Theme.borderSubtle
                                border.width: cell.sel ? 2 : 1
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: cell.modelData.a }
                                    GradientStop { position: 1.0; color: cell.modelData.b }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { beautify.bgKind = "preset"; beautify.bgPreset = cell.index; }
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 8
                        BgType { label: Theme.t("Düz Renk", "Solid"); on: beautify.bgKind === "solid"; onTapped: beautify.bgKind = "solid" }
                        BgType { label: Theme.t("Gradyan", "Gradient"); on: beautify.bgKind === "gradient"; onTapped: beautify.bgKind = "gradient" }
                        BgType { label: Theme.t("Görsel", "Image"); on: beautify.bgKind === "image"; onTapped: { beautify.bgKind = "image"; beautify.pickImageRequested(); } }
                        BgType { label: Theme.t("Şeffaf", "Transparent"); on: beautify.bgKind === "none"; onTapped: beautify.bgKind = "none" }
                    }

                    ColorRow {
                        visible: beautify.bgKind === "solid"
                        width: parent.width
                        current: beautify.bgSolid
                        onPicked: (c) => beautify.bgSolid = c
                    }

                    Column {
                        visible: beautify.bgKind === "gradient"
                        width: parent.width
                        spacing: 10
                        ColorRow { width: parent.width; current: beautify.bgGradA; onPicked: (c) => beautify.bgGradA = c }
                        ColorRow { width: parent.width; current: beautify.bgGradB; onPicked: (c) => beautify.bgGradB = c }
                        Slider { width: parent.width; label: Theme.t("Açı", "Angle"); from: 0; to: 360; suffix: "°"; value: beautify.bgGradAngle; onMoved: (v) => beautify.bgGradAngle = v }
                    }
                }

                // ---------- ÇERÇEVE ----------
                Group {
                    title: Theme.t("ÇERÇEVE & KART", "FRAME & CARD")
                    Slider { width: parent.width; label: Theme.t("İç Boşluk", "Padding"); from: 0; to: 200; value: beautify.padding; onMoved: (v) => beautify.padding = v }
                    Slider { width: parent.width; label: Theme.t("Köşe Yuvarlaklığı", "Corner Radius"); from: 0; to: 64; value: beautify.roundness; onMoved: (v) => beautify.roundness = v }
                    Slider { width: parent.width; label: Theme.t("Kenarlık Kalınlığı", "Border Width"); from: 0; to: 12; value: beautify.borderW; onMoved: (v) => beautify.borderW = v }
                    ColorRow { visible: beautify.borderW > 0; width: parent.width; current: beautify.borderColor; onPicked: (c) => beautify.borderColor = c }
                }

                // ---------- GÖLGE ----------
                Group {
                    title: Theme.t("DERİNLİK & GÖLGE", "DEPTH & SHADOW")
                    Row {
                        width: parent.width
                        spacing: 16
                        Column {
                            width: parent.width - 56 - 16
                            spacing: 14
                            Slider { width: parent.width; label: Theme.t("Gölge Gücü", "Shadow Strength"); from: 0; to: 100; suffix: "%"; value: beautify.shadowStrength; onMoved: (v) => beautify.shadowStrength = v }
                            Slider { width: parent.width; label: Theme.t("Bulanıklık", "Blur"); from: 0; to: 100; value: beautify.shadowBlur; onMoved: (v) => beautify.shadowBlur = v }
                            Slider { width: parent.width; label: Theme.t("Mesafe", "Distance"); from: 0; to: 60; value: beautify.shadowDist; onMoved: (v) => beautify.shadowDist = v }
                        }
                        Dial {
                            anchors.verticalCenter: parent.verticalCenter
                            label: Theme.t("Açı", "Angle")
                            angle: beautify.shadowAngle
                            onMoved: (a) => beautify.shadowAngle = a
                        }
                    }
                }

                // ---------- RENK DENGESİ ----------
                Group {
                    title: Theme.t("RENK DENGESİ", "COLOR BALANCE")
                    Slider { width: parent.width; label: Theme.t("Parlaklık", "Brightness"); bipolar: true; from: -100; to: 100; value: beautify.adjBright; onMoved: (v) => beautify.adjBright = v }
                    Slider { width: parent.width; label: Theme.t("Kontrast", "Contrast"); bipolar: true; from: -100; to: 100; value: beautify.adjContrast; onMoved: (v) => beautify.adjContrast = v }
                    Slider { width: parent.width; label: Theme.t("Doygunluk", "Saturation"); bipolar: true; from: -100; to: 100; value: beautify.adjSat; onMoved: (v) => beautify.adjSat = v }
                }

                // ---------- EN-BOY ORANI ----------
                Group {
                    title: Theme.t("SOSYAL MEDYA & ORANLAR", "SOCIAL & ASPECT RATIOS")
                    Flow {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: beautify.ratioRow
                            Pill { label: modelData.l; on: beautify.ratioKey === modelData.k; onTapped: beautify.ratioKey = modelData.k }
                        }
                    }
                    Flow {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: beautify.socialRow
                            Pill { label: modelData.l; on: beautify.ratioKey === modelData.k; onTapped: beautify.ratioKey = modelData.k }
                        }
                    }
                }

                // ---------- FİLİGRAN ----------
                Group {
                    title: Theme.t("İMZA & FİLİGRAN", "SIGNATURE & WATERMARK")
                    ToggleRow { width: parent.width; label: Theme.t("✦ Enyxma OS Filigranı", "✦ Enyxma OS Watermark"); on: beautify.watermark; onToggled: (v) => beautify.watermark = v }
                }
            }
        }
    }

    // ============================ Canvas Area ============================
    Item {
        id: canvasArea
        anchors.left: parent.left
        anchors.right: panel.left
        anchors.top: topbar.bottom
        anchors.bottom: parent.bottom

        Item {
            id: stage
            width: beautify.fullW
            height: beautify.fullH
            anchors.centerIn: parent
            scale: Math.min((canvasArea.width - 96) / beautify.fullW, (canvasArea.height - 120) / beautify.fullH, 1)
            transformOrigin: Item.Center

            // Background
            Item {
                anchors.fill: parent
                visible: beautify.bgKind !== "none"
                clip: true

                Rectangle {
                    visible: beautify.bgIsGradient
                    anchors.centerIn: parent
                    width: Math.max(parent.width, parent.height) * 1.5
                    height: width
                    rotation: beautify.bgAngle - 90
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: beautify.bgA }
                        GradientStop { position: 1.0; color: beautify.bgB }
                    }
                }
                Rectangle {
                    visible: beautify.bgKind === "solid"
                    anchors.fill: parent
                    color: beautify.bgSolid
                }
                Image {
                    visible: beautify.bgKind === "image" && beautify.bgImagePath !== ""
                    anchors.fill: parent
                    source: beautify.bgImagePath ? ("file://" + beautify.bgImagePath) : ""
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                }
            }

            // The Framed Capture Card
            Item {
                id: card
                anchors.centerIn: parent
                width: beautify.natW
                height: beautify.natH

                // Directional Shadow
                Rectangle {
                    width: parent.width
                    height: parent.height
                    x: Math.cos(beautify.shadowAngle * Math.PI / 180) * beautify.shadowDist
                    y: Math.sin(beautify.shadowAngle * Math.PI / 180) * beautify.shadowDist
                    radius: beautify.roundness
                    color: Qt.rgba(0, 0, 0, 1)
                    visible: beautify.shadowStrength > 0
                    opacity: beautify.shadowStrength / 100
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1.0
                        blurMax: Math.round(beautify.shadowBlur * 0.6)
                        autoPaddingEnabled: true
                    }
                }

                // The Screenshot Image with Adjustments
                Image {
                    id: img
                    anchors.fill: parent
                    source: beautify.srcPath ? ("file://" + beautify.srcPath) : ""
                    cache: false
                    fillMode: Image.Stretch
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: beautify.roundness > 0
                        maskSource: maskRect
                        brightness: beautify.adjBright / 100
                        contrast: beautify.adjContrast / 100
                        saturation: beautify.adjSat / 100
                    }
                }

                Rectangle {
                    id: maskRect
                    anchors.fill: parent
                    radius: beautify.roundness
                    visible: false
                    layer.enabled: true
                }

                Rectangle {
                    anchors.fill: parent
                    visible: beautify.borderW > 0
                    color: "transparent"
                    radius: beautify.roundness
                    border.width: beautify.borderW
                    border.color: beautify.borderColor
                }
            }

            // Watermark
            Row {
                id: wmark
                visible: beautify.watermark
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Math.max(16, beautify.padding * 0.35)
                spacing: wmark.fs * 0.5
                readonly property real fs: Math.max(15, beautify.fullW * 0.018)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "✦"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: wmark.fs * 1.3
                    font.weight: Font.Bold
                    style: Text.Raised
                    styleColor: Qt.rgba(0, 0, 0, 0.5)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "<b>" + beautify.userName + "</b><font color='" + Theme.accent + "'>@enyxma</font>"
                    textFormat: Text.StyledText
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: wmark.fs
                    font.weight: Font.DemiBold
                    style: Text.Raised
                    styleColor: Qt.rgba(0, 0, 0, 0.45)
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            text: Math.round(beautify.fullW) + " × " + Math.round(beautify.fullH) + "  ·  " + Math.round(stage.scale * 100) + "%"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    // ============================ Inline Components ============================
    component Group: Column {
        id: grp
        width: parent ? parent.width : 0
        property string title: ""
        default property alias content: body.data
        spacing: 12

        Item {
            width: grp.width
            height: 14
            Text {
                id: gh
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: grp.title
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }
            Rectangle {
                anchors.left: gh.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 1
                color: Theme.borderSubtle
            }
        }
        Column { id: body; width: grp.width; spacing: 12 }
    }

    component TopBtn: Rectangle {
        id: tbn
        property string label: ""
        property bool accent: false
        signal tapped()
        implicitWidth: tl.implicitWidth + 28
        implicitHeight: 34
        radius: Theme.radiusSmall
        color: tbn.accent ? (tbnMa.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent) : (tbnMa.containsMouse ? Theme.surfaceHover : "transparent")
        border.width: tbn.accent ? 0 : 1
        border.color: Theme.borderSubtle

        Text {
            id: tl
            anchors.centerIn: parent
            text: tbn.label
            color: tbn.accent ? Theme.bgDark : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.DemiBold
        }
        MouseArea {
            id: tbnMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tbn.tapped()
        }
    }

    component BgType: Rectangle {
        id: bgt
        property string label: ""
        property bool on: false
        signal tapped()
        width: (parent.width - 3 * 8) / 4
        height: 30
        radius: Theme.radiusSmall
        color: bgt.on ? Theme.accent : (btMa.containsMouse ? Theme.surfaceHover : Theme.surface1)

        Text {
            anchors.centerIn: parent
            text: bgt.label
            color: bgt.on ? Theme.bgDark : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: bgt.on ? Font.DemiBold : Font.Medium
        }
        MouseArea {
            id: btMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: bgt.tapped()
        }
    }

    component Pill: Rectangle {
        id: pill
        property string label: ""
        property bool on: false
        signal tapped()
        implicitWidth: pl.implicitWidth + 20
        height: 28
        radius: Theme.radiusSmall
        color: pill.on ? Theme.accent : (plMa.containsMouse ? Theme.surfaceHover : Theme.surface1)
        border.width: 1
        border.color: pill.on ? Theme.accent : Theme.borderSubtle

        Text {
            id: pl
            anchors.centerIn: parent
            text: pill.label
            color: pill.on ? Theme.bgDark : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: pill.on ? Font.DemiBold : Font.Medium
        }
        MouseArea {
            id: plMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.tapped()
        }
    }

    component ColorRow: Flow {
        id: cr
        property color current: Theme.textPrimary
        signal picked(color c)
        spacing: 6
        Repeater {
            model: beautify.palette
            Rectangle {
                id: sw
                required property var modelData
                width: 20
                height: 20
                radius: 5
                color: sw.modelData
                readonly property bool sel: Qt.colorEqual(cr.current, sw.modelData)
                border.color: sw.sel ? Theme.accent : Theme.borderSubtle
                border.width: sw.sel ? 2 : 1
                scale: crMa.containsMouse ? 1.15 : 1
                Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                MouseArea {
                    id: crMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cr.picked(sw.modelData)
                }
            }
        }
    }

    component ToggleRow: Item {
        id: tr
        property string label: ""
        property bool on: false
        signal toggled(bool v)
        width: parent.width
        height: 28

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: tr.label
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.Medium
        }

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 22
            radius: 11
            color: tr.on ? Theme.accent : Theme.surface2
            border.width: 1
            border.color: tr.on ? Theme.accent : Theme.borderSubtle

            Rectangle {
                width: 16
                height: 16
                radius: 8
                y: 3
                x: tr.on ? parent.width - width - 3 : 3
                color: tr.on ? Theme.bgDark : Theme.textSecondary
                Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: tr.toggled(!tr.on)
            }
        }
    }
}
