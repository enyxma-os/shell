# QUICKSHELL CRITICAL GOTCHAS & PATTERNS

Quickshell standart bir Qt masaüstü uygulaması değildir. Yeni bir modül veya servis yazarken aşağıdaki 7 tuzağa düşme:

## 1. Pipewire Nesneleri `PwObjectTracker` Olmadan Çalışmaz
`Pipewire.defaultAudioSink.audio.volume` değerini doğrudan okursan her zaman `0` veya `null` döner. Nesnenin yaşam döngüsünü bağlamak zorundasın:

```qml
import Quickshell.Services.Pipewire

PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
}
// Artık Pipewire.defaultAudioSink?.audio.volume reaktif olarak okunabilir.
```

## 2. Gerçek Cam Efekti (Blur) QML'den Değil, Hyprland'den Gelir
QML'de `Qt.rgba(..., 0.82)` yalnızca şeffaflık verir, arka planı bulanıklaştırmaz. Blur için her `PanelWindow` bileşenine mutlaka bir `WlrLayershell.namespace` tanımla:

```qml
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.namespace: "enyxma-bar" // Hyprland layerrule: blur, enyxma-* ile eşleşir
    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: implicitHeight // Pencerelerin barın altına girmesini engeller!
    color: "transparent"
}
```

## 3. Çoklu Monitör (Multi-Monitor) Desteği Zorunludur
Bar ve OSD gibi bileşenleri doğrudan `ShellRoot` içine koyarsan sadece tek ekranda görünür. Her zaman `Variants` kullan:

```qml
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            // Bar içeriği buraya
        }
    }
}
```

## 4. Klavye Odağı (`keyboardFocus`) Olmadan AI Panelinde Yazı Yazılamaz
`AISidebar.qml` gibi içinde `TextInput` veya `TextArea` barındıran panellerde, panel açıkken klavye odağını Wayland'den talep etmelisin:

```qml
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.namespace: "enyxma-ai"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
}
```

## 5. AI Daemon İletişimi: `XMLHttpRequest` Yerine NDJSON Stream
Token akışı (streaming) için `XMLHttpRequest` kullanma. Yerel AI servisi ile `Quickshell.Io` üzerinden `Socket` veya `Process` + `SplitParser` kullanarak satır bazlı JSON (NDJSON) ile haberleş:

```qml
import Quickshell.Io

Process {
    id: aiStream
    command: ["enyxma-ai-client", "--stream"]
    stdout: SplitParser {
        onRead: data => {
            // Her satır bağımsız bir JSON paketidir, parse et ve UI'a ekle
        }
    }
}
```

## 6. Impermanence & tmpfs Dosya Yolları
Durum (state) veya önbellek kaydederken `FileView` içinde sabit `/home/...` yolları yerine yalnızca şu standart yolları kullan:
- Durum verisi (NixOS'ta `/persist` altına bağlanır): `Quickshell.statePath("ai-history.json")`
- Kalıcı uygulama verisi: `Quickshell.dataPath("prompts.json")`
- Geçici önbellek (tmpfs üzerinde kalır): `Quickshell.cachePath("thumbnails")`

## 7. Kullanıcı Etkileşiminde Animasyon Gecikmesi (Slider Tuzağı)
Ses veya parlaklık çubuğu (Slider) kullanıcı tarafından sürüklenirken (`pressed` durumundayken) değerin üzerinde `Behavior` animasyonu açıksa çubuk fareyi geriden takip eder. Sürükleme anında animasyonu devre dışı bırak:

```qml
Behavior on value {
    enabled: !slider.pressed && !Theme.reduceMotion
    NumberAnimation {
        duration: Theme.animFast
        easing.type: Easing.OutQuint
    }
}
```
## 8. OSD ve Bildirimlerde `exclusionMode: ExclusionMode.Ignore` Zorunludur
Quickshell'de `PanelWindow` varsayılan olarak `ExclusionMode.Auto` kullanır. Kenara sabitlenmiş (`anchors.bottom: true` vb.) pencereler otomatik olarak Wayland'den rezervasyon alanı talep eder ve açık pencereleri sıkıştırarak yukarı/yana iter. OSD, bildirim ve açılır pencerelerde pencerelerin sıkışmasını önlemek için mutlaka `exclusionMode: ExclusionMode.Ignore` kullanılmalıdır.
