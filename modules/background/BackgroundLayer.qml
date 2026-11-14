pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    WlrLayershell.namespace: "enyxma-bg"
    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Arka plan temel yüzeyi (Resim yokken veya yüklenirken estetik koyu cam)
    Rectangle {
        anchors.fill: parent
        color: Theme.bgGlass
    }

    Item {
        id: bufferContainer
        anchors.fill: parent
        clip: true

        // true -> imageA aktif ve görünür, false -> imageB aktif ve görünür
        property bool activeSlotA: true
        property bool initialized: false
        property string targetSource: ""

        function activateSlot(useA: bool) {
            activeSlotA = useA
            if (initialized && !Theme.reduceMotion) {
                flashAnim.restart()
            }
            initialized = true
        }

        Image {
            id: imageA
            anchors.fill: parent
            z: bufferContainer.activeSlotA ? 2 : 1
            fillMode: Image.PreserveAspectCrop
            mipmap: true
            asynchronous: true
            opacity: (bufferContainer.activeSlotA && source.toString().length > 0) ? 1.0 : 0.0
            scale: (bufferContainer.activeSlotA && source.toString().length > 0)
                ? 1.0
                : (bufferContainer.initialized ? 1.07 : 1.04)

            Behavior on opacity {
                enabled: !Theme.reduceMotion
                NumberAnimation {
                    duration: 680
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                enabled: !Theme.reduceMotion
                NumberAnimation {
                    duration: 750
                    easing.type: Easing.OutQuint
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bufferContainer.targetSource === source.toString()) {
                    bufferContainer.activateSlot(true)
                }
            }
        }

        Image {
            id: imageB
            anchors.fill: parent
            z: !bufferContainer.activeSlotA ? 2 : 1
            fillMode: Image.PreserveAspectCrop
            mipmap: true
            asynchronous: true
            opacity: (!bufferContainer.activeSlotA && source.toString().length > 0) ? 1.0 : 0.0
            scale: (!bufferContainer.activeSlotA && source.toString().length > 0)
                ? 1.0
                : (bufferContainer.initialized ? 1.07 : 1.04)

            Behavior on opacity {
                enabled: !Theme.reduceMotion
                NumberAnimation {
                    duration: 680
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                enabled: !Theme.reduceMotion
                NumberAnimation {
                    duration: 750
                    easing.type: Easing.OutQuint
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bufferContainer.targetSource === source.toString()) {
                    bufferContainer.activateSlot(false)
                }
            }
        }

        // Geçiş anında kısa sinematik vurgu parıltısı
        Rectangle {
            id: transitionFlash
            anchors.fill: parent
            z: 5
            opacity: 0.0
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.accent }
                GradientStop { position: 0.55; color: Theme.bgDark }
                GradientStop { position: 1.0; color: "transparent" }
            }

            NumberAnimation {
                id: flashAnim
                target: transitionFlash
                property: "opacity"
                from: 0.22
                to: 0.0
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        function applyWallpaper(newPath: string) {
            if (!newPath || newPath.trim().length === 0) {
                targetSource = ""
                imageA.source = ""
                imageB.source = ""
                return
            }

            const path = newPath.trim()
            if (path === targetSource) return

            targetSource = path

            if (activeSlotA) {
                imageB.source = path
                if (imageB.status === Image.Ready) {
                    activateSlot(false)
                }
            } else {
                imageA.source = path
                if (imageA.status === Image.Ready) {
                    activateSlot(true)
                }
            }
        }

        Connections {
            target: WallpaperState
            function onCurrentWallpaperChanged() {
                bufferContainer.applyWallpaper(WallpaperState.currentWallpaper)
            }
        }

        Component.onCompleted: {
            if (WallpaperState.currentWallpaper) {
                bufferContainer.applyWallpaper(WallpaperState.currentWallpaper)
            }
        }
    }

    // Karartma (Dim) katmanı - Launcher veya AI paneli açıldığında arka planı odaklar
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: Theme.scrim
        opacity: Math.max(0.0, Math.min(1.0, WallpaperState.dimLevel))

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutQuint
            }
        }
    }
}
