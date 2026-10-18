# Enyxma Shell

Enyxma OS (NixOS + Hyprland + Impermanence) için Quickshell (Qt 6 / QML) tabanlı, yüksek performanslı, olay-güdümlü (event-driven) ve modüler yeni nesil masaüstü kabuğu.

---

## 🌟 Öne Çıkan Özellikler

- **Sıfır Polling, %100 Olay-Güdümlü (Event-Driven):** `Timer` ile periyodik komut çalıştırma (`hyprctl`, `wpctl` vb.) yerine doğrudan Quickshell'in yerel servisleri (`Hyprland`, `Pipewire`, `Mpris`, `Notifications`, `SystemTray`, `DesktopEntries`) ve IPC soket akışları kullanılır.
- **Kesin Veri ve Görünüm Ayrımı (Single Responsibility):** Arayüz bileşenleri (`modules/`, `widgets/`) durum tutmaz; tüm mantık ve sistem durumu `services/` altındaki `pragma Singleton` servislerinde merkezi olarak yönetilir.
- **Harmonik Bento Zaman & Takvim Hub'ı:** Barın tam merkezinde yer alan saat hapı ile sol tıklandığında interaktif takvim, gün döngüsü, canlı meteoroloji ve saatlik tahmin akışını içeren simetrik bir Bento Hub açılır; sağ tıklandığında ise 24s/12s, saniye gösterimi, °C/°F birim değişimi ve hızlı Pomodoro sayacı sunulur.
- **Özgün Tasarım Sistemi (Enyxma Design Tokens):** Sabit hex kodları (`#hex`) veya dış tema bağımlılıkları yerine `services/Theme.qml` üzerindeki anlamsal (semantic) renk token'ları, squircle köşe yarıçapları ve akıcı geçiş animasyonları kullanılır.
- **İzole ve Katmanlı Bar (Zero Overflow):** Pencere başlığı alanı `clip: true` ile sol çalışma alanları ve merkez saat arasında sınırlandırılarak uzun sayfa başlıklarının durum haplarını (pill) sağa itmesi ve üst üste binmesi kesin olarak engellenmiştir.
- **Yerel AI Asistanı:** Yan panelde doğrudan yerel büyük dil modeli (LLM) servisleriyle satır bazlı JSON (NDJSON) soket akışı üzerinden haberleşen akıllı asistan arayüzü (`AISidebar`).

---

## 📁 Dizin Mimarisi

```text
.
├── flake.nix                       # Nix Flake tanımı ve paket çıktısı
├── flake.lock                      # Bağımlılık kilit dosyası
├── Justfile                        # Geliştirici ve CI/CD görev otomasyonu
├── AGENTS.md                       # Ajan çalışma ve mimari kuralları
├── README.md                       # Proje dokümantasyonu
├── docs/
│   ├── design-tokens.md            # Renk, tipografi ve animasyon standartları
│   └── quickshell-gotchas.md       # Quickshell & QML teknik kısıtları
├── shell.qml                       # Çoklu ekran ve pencere katmanları giriş noktası
├── services/                       # Pragma Singleton servis katmanı
│   ├── qmldir                      # Modül ve singleton kayıtları
│   ├── Theme.qml                   # Renk paleti ve tasarım token'ları
│   ├── HyprlandState.qml           # Çalışma alanları ve aktif pencere durumu
│   ├── AudioState.qml              # Pipewire ses seviyesi ve susturma
│   ├── MediaState.qml              # MPRIS medya oynatıcı ve çalma durumu
│   ├── PerformanceState.qml        # CPU, RAM, loadavg ve top süreçler
│   ├── StorageState.qml            # Disk alanı ve NVMe durumu
│   ├── NetworkState.qml            # Wi-Fi ve Ethernet bağlantı durumu
│   ├── NotificationState.qml       # Masaüstü bildirim havuzu
│   ├── TimeState.qml               # Saat ve takvim biçimlendirme + IPC
│   ├── WeatherState.qml            # Canlı meteoroloji ve saatlik tahmin servisi
│   ├── LauncherState.qml           # Uygulama başlatıcı durumu
│   ├── AIState.qml                 # Yerel AI soket ve akış durumu
│   └── WallpaperState.qml          # Duvar kağıdı yönetimi
├── widgets/                        # Atomik görsel bileşenler
│   └── EnyxmaPill.qml              # Standart durum kapsülü (Sol/Sağ Tık & Active)
└── modules/                        # Masaüstü katmanları ve açılır paneller
    ├── background/BackgroundLayer.qml
    ├── bar/                        # Üst panel bileşenleri
    │   ├── Bar.qml                 # Ana bar yerleşimi
    │   ├── Workspaces.qml          # Hyprland dinamik çalışma alanları
    │   ├── ClockWidget.qml         # Merkez saat, tarih ve hava durumu hapı
    │   ├── MediaWidget.qml         # Kompakt medya durum hapı
    │   ├── PerformanceWidget.qml   # CPU & RAM birleşik durum hapı
    │   ├── StorageWidget.qml       # Disk durum hapı
    │   ├── NetworkWidget.qml       # Ağ durum hapı
    │   ├── NotificationWidget.qml  # Bildirim durum hapı
    │   ├── SystemMetrics.qml       # Metrik göstergeleri
    │   └── Tray.qml                # Sistem tepsisi (SNI)
    ├── time/                       # Zaman ve takvim modülleri
    │   ├── TimePanel.qml           # Harmonik Bento Zaman & Takvim & Hava Paneli
    │   └── TimeContextMenu.qml     # Sağ tık hızlı biçim ve ayar menüsü
    ├── media/MediaPanel.qml        # Kapak görseli, ritim dalgası ve scrubber
    ├── performance/
    │   ├── PerformancePanel.qml    # Canlı metrikler ve süreç listesi
    │   └── Sparkline.qml           # Canlı CPU/RAM grafik çizici
    ├── storage/StoragePanel.qml    # Disk kullanım paneli
    ├── network/NetworkPanel.qml    # Ağ bağlantı ve IP paneli
    ├── notifications/
    │   ├── NotificationPanel.qml   # Bildirim merkezi
    │   └── NotificationPopup.qml   # Ekran üstü anlık bildirim toast'ları
    ├── cc/ControlCenter.qml        # Hızlı ayarlar ve kontrol merkezi
    ├── launcher/OmniLauncher.qml   # Bulanık arama destekli başlatıcı
    ├── ai/AISidebar.qml            # Yerel AI sohbet yan paneli
    └── osd/OSD.qml                 # Ses ve parlaklık OSD katmanı
```

---

## 🛠️ Geliştirme ve Doğrulama

Kod bütünlüğünü ve tasarım standartlarını korumak için `Justfile` üzerinde tanımlı adımlar kullanılır:

```bash
# 1. Tüm statik kontrolleri çalıştır (Leak, Singleton ve QML Sözdizimi)
just verify

# 2. Kaçak hardcoded renk (#hex) ve /home/ sabit yol taraması
just check-leaks

# 3. Tüm servislerin qmldir içinde kayıtlı olduğunu doğrula
just check-qmldir

# 4. QML sözdizimi doğrulaması (qmllint)
just lint

# 5. Sanal makineye (VM) canlı dağıt ve shell'i yeniden başlat
just deploy
```

---

## 📜 Lisans

GPL-3.0-or-later. Enyxma OS projesinin tescilli masaüstü bileşenidir.
