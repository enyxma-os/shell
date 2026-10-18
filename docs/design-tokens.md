# ENYXMA DESIGN TOKENS & THEME SCHEMA

Görsel bileşenlerde çelişkiyi ve "çocuk işi" düz görünümleri önlemek için tüm stil, renk, geometri ve animasyon kuralları `services/Theme.qml` (Singleton) üzerinden aşağıdaki standartlarla sunulur.

## 1. Renk ve Yüzey Hiyerarşisi
- **İstisna:** `color: "transparent"` yalnızca kök `PanelWindow` veya görünmez tıklama alanı (`MouseArea`) kapsayıcılarında doğrudan yazılabilir. Bunun dışında `modules/` ve `widgets/` içinde literal renk (`#...`, `"red"`, `"black"`) kullanmak kesinlikle yasaktır.
- **Zeminler (Surfaces):**
  - `Theme.bgGlass`: `Qt.rgba(0.07, 0.07, 0.10, 0.80)` (Hyprland `blur` ile birleşen ana panel rengi)
  - `Theme.surface1`: `Qt.rgba(1, 1, 1, 0.05)` (İç kapsül, kart ve modül zemini)
  - `Theme.surfaceHover`: `Qt.rgba(1, 1, 1, 0.10)` (Üzerine gelindiğinde / hover durumu)
  - `Theme.surfaceActive`: `Qt.rgba(1, 1, 1, 0.16)` (Tıklanma veya aktif seçili olma durumu)
- **Kenarlıklar (Borders):**
  - `Theme.borderSubtle`: `Qt.rgba(1, 1, 1, 0.08)` (Tüm ana panellerde ve kapsüllerde `border.width: 1` ile kullanılır)
  - `Theme.borderFocus`: `Qt.rgba(0.22, 0.74, 0.97, 0.45)` (Klavye odağı olan input/AI kutuları için)
- **Metin ve Vurgu (Typography & Accent):**
  - `Theme.textPrimary`: `"#F2F4F8"` (Ana metin ve aktif ikonlar)
  - `Theme.textSecondary`: `"#94A3B8"` (İkincil bilgi metinleri)
  - `Theme.textMuted`: `"#475569"` (Pasif/devre dışı öğeler)
  - `Theme.accent`: `"#38BDF8"` (Enyxma ana vurgu rengi - aktif workspace, AI göstergesi vb.)
  - `Theme.danger`: `"#F43F5E"` (Kritik uyarı, sessize alma veya hata durumu)

## 2. Geometri, Boşluk ve Yuvarlaklık (Spacing & Radius)
- `Theme.radiusPanel`: `14` (Dış paneller, bildirim kartları ve AI yan çekmecesi)
- `Theme.radiusWidget`: `10` (İç kartlar, kod blokları ve açılır menü öğeleri)
- **Hap / Kapsül Kuralı (Pill Radius):** Bar içindeki kapsüllerde sabit sayı yerine bileşenin kendi `height / 2` değerini kullan.
- `Theme.borderWidth`: `1`
- `Theme.spacingXS`: `4`
- `Theme.spacingSmall`: `8`
- `Theme.spacingMedium`: `12`
- `Theme.spacingLarge`: `18`

## 3. Tipografi
- `Theme.fontFamily`: `"Inter"` (Arayüz ve AI sohbet metinleri)
- `Theme.fontMono`: `"JetBrainsMono Nerd Font"` (Saat, sistem metrikleri, kod blokları ve NerdFont ikonları)
- `Theme.fontSizeSmall`: `11`
- `Theme.fontSizeNormal`: `13`
- `Theme.fontSizeLarge`: `16`

## 4. Tekil Animasyon Standardı (`Easing.OutQuint`)
Farklı animasyon eğrilerinin yarattığı görsel tutarsızlığı önlemek için tüm boyut, opaklık ve konum geçişlerinde yalnızca **`Easing.OutQuint`** kullanılır:
- `Theme.reduceMotion`: `false` (True olduğunda tüm `Behavior` blokları devre dışı kalır)
- `Theme.animFast`: `150` (ms - Renk, opaklık ve hover geçişleri)
- `Theme.animNormal`: `240` (ms - Workspace kapsül genişlemesi ve küçük boyut değişimleri)
- `Theme.animSlow`: `350` (ms - AI Sidebar ve OSD açılış/kapanış kaymaları)

## 5. Referans `services/Theme.qml` Şablonu
Ajan `services/Theme.qml` dosyasını oluştururken aşağıdaki yapıyı birebir temel almalıdır:

```qml
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
    readonly property color surface1: Qt.rgba(1, 1, 1, 0.05)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.10)
    readonly property color surfaceActive: Qt.rgba(1, 1, 1, 0.16)

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

    // Geometry & Spacing
    readonly property int radiusPanel: 14
    readonly property int radiusWidget: 10
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
```