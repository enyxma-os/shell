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

        // true -> imageA aktif / görünür, false -> imageB aktif / görünür
        property bool activeSlotA: true
        property string targetSource: ""

        Image {
            id: imageA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            mipmap: true
            asynchronous: true
            opacity: (bufferContainer.activeSlotA && source.toString().length > 0) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animSlow
                    easing.type: Easing.OutQuint
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bufferContainer.targetSource === source.toString()) {
                    bufferContainer.activeSlotA = true
                }
            }
        }

        Image {
            id: imageB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            mipmap: true
            asynchronous: true
            opacity: (!bufferContainer.activeSlotA && source.toString().length > 0) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animSlow
                    easing.type: Easing.OutQuint
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bufferContainer.targetSource === source.toString()) {
                    bufferContainer.activeSlotA = false
                }
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
                    activeSlotA = false
                }
            } else {
                imageA.source = path
                if (imageA.status === Image.Ready) {
                    activeSlotA = true
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
