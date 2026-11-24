# Enyxma Shell

Enyxma OS için Quickshell ve Qt 6 / QML tabanlı, olay-güdümlü, çift temalı ve yerel eklenti destekli yeni nesil masaüstü kabuğu.

---

## 🌟 Öne Çıkan Özellikler

- **Çift Tema Mimarisi:**
  - **Gotham 2.0:** Sıfır yuvarlak köşeli, keskin taktiksel monokrom ve amber paleti.
  - **Dinamik Matugen:** Seçilen duvar kağıdından anlık renk çıkarımı ile canlı Hyprland kenarlık, GTK, Kitty, Foot, Starship, btop, Yazi ve `hyprlock` senkronizasyonu.
- **Enyxma Ayarlar 2.0 — `SUPER + I`:**
  - **7 Kategori:** Genel Bakış, Görünüm, Üst Çubuk, Ekran, Klavye ve Fare, Kısayollar, Sistem.
  - **Canlı Kontrol:** Genel arama, tek tıkla Geri Al bildirimi, `hyprctl eval` ile anlık pencere geometrisi, çözünürlük / Hz / ölçek / VRR, Gece Işığı Kelvin kontrolü, otomatik `hypridle` kilit / DPMS / uyku yönetimi, canlı `binds.lua` kısayol listesi ve `~/.config/enyxma/settings.json` kalıcılığı.
- **Yerleşik Paneller ve Modüller:**
  - **Birleşik Sistem / Performans / Depolama Paneli:** AMD, Intel ve NVIDIA CPU/GPU sıcaklıkları, VRAM kullanımı, top süreçler, disk ve NVMe durumu.
  - **Ağ Paneli:** Wi-Fi tarama ve bağlantı, VPN / DNS durumu ve anlık QR kod paylaşımı.
  - **PipeWire / WirePlumber Ses Mikseri:** Çıkış, mikrofon ve uygulama bazlı ses akışları.
  - **BlueZ Bluetooth Yöneticisi:** Cihaz tarama, eşleştirme, bağlanma, kaldırma ve pil düzeyi.
  - **Harmonik Bento Zaman, Takvim ve Hava Durumu Hub'ı:** İnteraktif takvim, gün döngüsü, canlı meteoroloji ve saatlik tahmin akışı.
  - **Odak Sayacı:** Pomodoro iş ve mola zamanlayıcısı.
  - **Konteyner İzleyici:** Docker ve Podman otomatik tespiti, başlatma, durdurma ve yeniden başlatma.
  - **OmniLauncher, Medya Paneli, Bildirim Merkezi, Enyxma Shot ve Yerel AI Yan Paneli:** Bulanık aramalı başlatıcı, MPRIS medya kontrolü, bildirim havuzu, ekran görüntüsü stüdyosu ve yerel LLM sohbet akışı.
- **Kesin Veri ve Görünüm Ayrımı:** Arayüz bileşenleri durum tutmaz; tüm mantık ve sistem durumu `services/` altındaki `pragma Singleton` servislerinde merkezi olarak yönetilir.
- **Uygulama İzolasyonu — `enyxma-launch`:** `uwsm app` ve `systemd-run --user --scope` ile başlatılan uygulamalar kabuk yeniden başlasa veya `nh os switch` çalışsa bile kapanmadan yaşamaya devam eder.

---

## 🧩 Yerel Eklenti Yuvası

Kullanıcılar `~/.config/enyxma/plugins/<eklenti-adi>/` dizinine bir `manifest.json` ve QML bileşeni ekleyerek üst çubuğa özel widget'lar yerleştirebilir. Ayarlar -> Sistem altından tek tıkla açılıp kapatılabilir.

Örnek `manifest.json`:

```json
{
  "id": "ornek-eklenti",
  "name": "Örnek Widget",
  "version": "1.0.0",
  "barWidget": "Widget.qml",
  "position": "right"
}
```

---

## 🚀 Hızlı Kurulum — Nix Flake

Ana sisteminizin `flake.nix` dosyasına girdi olarak ekleyin:

```nix
inputs = {
  enyxma-shell.url = "git+https://codeberg.org/enyxma/shell";
};
```

### NixOS Sistem Modülü Olarak Kullanım

```nix
imports = [
  inputs.enyxma-shell.nixosModules.default
];

enyxma.shell.enable = true;
```

### Home Manager Kullanıcı Modülü Olarak Kullanım

```nix
imports = [
  inputs.enyxma-shell.homeManagerModules.default
];

enyxma.shell.enable = true;
```

---

## 📁 Dizin Mimarisi

```text
.
├── flake.nix                       # Nix Flake tanımı, paket ve modül çıktıları
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
│   ├── GeneratedColors.qml         # Matugen tarafından üretilen dinamik palet
│   ├── SettingsState.qml           # Merkezi ayarlar, Hyprland/hypridle canlı yönetimi
│   ├── PluginState.qml             # Yerel eklenti tarayıcı ve durum yönetimi
│   ├── HyprlandState.qml           # Çalışma alanları ve aktif pencere durumu
│   ├── AudioState.qml              # Pipewire / WirePlumber ses mikseri
│   ├── BluetoothState.qml          # BlueZ Bluetooth tarama ve bağlantı servisi
│   ├── BrightnessState.qml         # Ekran parlaklığı yönetimi
│   ├── ContainerState.qml          # Docker / Podman konteyner izleme servisi
│   ├── FocusState.qml              # Pomodoro odak sayacı servisi
│   ├── MediaState.qml              # MPRIS medya oynatıcı ve çalma durumu
│   ├── MediaBrowserState.qml       # Medya kitaplık ve tarama servisi
│   ├── PerformanceState.qml        # CPU, RAM, GPU, VRAM, sıcaklık ve top süreçler
│   ├── StorageState.qml            # Disk alanı ve NVMe durumu
│   ├── SystemState.qml             # Birleşik sistem özeti servisi
│   ├── NetworkState.qml            # Wi-Fi, Ethernet, VPN, DNS ve QR paylaşımı
│   ├── NotificationState.qml       # Masaüstü bildirim havuzu
│   ├── OverviewState.qml           # Çalışma alanı genel bakış servisi
│   ├── ScreenState.qml             # Ekran ve monitör yardımcıları
│   ├── ScreenTimeState.qml         # Ekran süresi takibi
│   ├── TimeState.qml               # Saat ve takvim biçimlendirme
│   ├── WeatherState.qml            # Canlı meteoroloji ve saatlik tahmin servisi
│   ├── LauncherState.qml           # Uygulama başlatıcı durumu
│   ├── ToolsState.qml              # Yardımcı araç kısayolları
│   ├── AIState.qml                 # Yerel AI soket ve akış durumu
│   └── WallpaperState.qml          # Duvar kağıdı ve tema yönetimi
├── widgets/                        # Atomik görsel bileşenler
│   └── EnyxmaPill.qml              # Standart durum kapsülü
└── modules/                        # Masaüstü katmanları ve açılır paneller
    ├── ai/                         # Yerel AI sohbet yan paneli
    ├── audio/                      # Ses mikseri panelleri
    ├── background/                 # Masaüstü arka plan katmanı
    ├── bar/                        # Gotham ve Dinamik üst çubuk bileşenleri
    ├── bluetooth/                  # Bluetooth yönetim panelleri
    ├── cc/                         # Kontrol merkezi
    ├── containers/                 # Konteyner izleme panelleri
    ├── launcher/                   # OmniLauncher uygulama başlatıcı
    ├── media/                      # Medya kontrol paneli
    ├── network/                    # Ağ ve Wi-Fi QR panelleri
    ├── notifications/              # Bildirim merkezi ve toast'lar
    ├── osd/                        # Ses ve parlaklık OSD katmanı
    ├── overview/                   # Genel bakış katmanı
    ├── performance/                # Sistem, performans ve depolama panelleri
    ├── screenshot/                 # Enyxma Shot ekran görüntüsü ve mockup aracı
    ├── settings/                   # Enyxma Ayarlar 2.0 panelleri
    ├── storage/                    # Depolama yardımcıları
    ├── time/                       # Harmonik Bento zaman, takvim ve hava hub'ı
    └── wallpaper/                  # Duvar kağıdı seçici galerisi
```

---

## 🛠️ Geliştirme ve Doğrulama

Kod bütünlüğünü ve tasarım standartlarını korumak için `Justfile` üzerinde tanımlı adımlar kullanılır:

```bash
# 1. Tüm statik kontrolleri çalıştır
just verify

# 2. Kaçak hardcoded renk ve sabit yol taraması
just check-leaks

# 3. Tüm servislerin qmldir içinde kayıtlı olduğunu doğrula
just check-qmldir

# 4. QML sözdizimi doğrulaması
just lint

# 5. Kabuğu yerel oturumda çalıştır
just run
```

---

## 📜 Lisans

GPL-3.0-or-later. Enyxma OS projesinin tescilli masaüstü bileşenidir.
