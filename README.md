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
  - **Birleşik Sistem / Performans / Depolama Paneli:** Linux `hwmon` ve DRM sürücüleri — `amdgpu`, `i915`, `xe`, `nouveau` — üzerinden CPU/GPU sıcaklıkları, VRAM kullanımı, top süreçler, disk ve NVMe durumu.
  - **Ağ Paneli:** Wi-Fi tarama ve bağlantı, VPN / DNS yönetimi ve anlık QR kod paylaşımı.
  - **PipeWire / WirePlumber Ses Mikseri:** Çıkış, mikrofon ve uygulama bazlı ses akışları.
  - **BlueZ Bluetooth Yöneticisi:** Cihaz tarama, eşleştirme, bağlanma, kaldırma ve pil düzeyi.
  - **Harmonik Bento Zaman, Takvim ve Hava Durumu Hub'ı:** İnteraktif takvim, gün döngüsü, canlı meteoroloji ve saatlik tahmin akışı.
  - **İsteğe Bağlı Modüller — Odak Sayacı ve Konteyner İzleyici:** `Ayarlar -> Sistem` altından açılabilen Pomodoro zamanlayıcısı ile Docker / Podman konteyner yöneticisi.
  - **3 Sekmeli Yan Panel:** Yerel AI sohbeti, `yt-dlp` ve Cobalt tabanlı medya indirici / dönüştürücü ve aktif pencere tabanlı yerel ekran süresi istatistikleri.
  - **OmniLauncher, Medya & Ekran Görüntüsü Tarayıcısı, Bildirim Merkezi ve Enyxma Shot:** Bulanık aramalı başlatıcı, MPRIS medya kontrolü, ekran görüntüsü / video tarayıcısı, bildirim havuzu ve ekran görüntüsü stüdyosu.
- **Kesin Veri ve Görünüm Ayrımı:** Arayüz bileşenleri durum tutmaz; tüm mantık ve sistem durumu `services/` altındaki `pragma Singleton` servislerinde merkezi olarak yönetilir.
- **Uygulama İzolasyonu — `enyxma-launch`:** `uwsm app` ve `systemd-run --user --scope` ile başlatılan uygulamalar kabuk yeniden başlasa veya `nh os switch` çalışsa bile kapanmadan yaşamaya devam eder.

---

## 🧩 Yerel Eklenti Yuvası

Kullanıcılar `~/.config/enyxma/plugins/<eklenti-adi>/` dizinine bir `manifest.json` ve QML bileşeni ekleyerek üst çubuğa özel widget'lar yerleştirebilir. `Ayarlar -> Sistem` altından tek tıkla açılıp kapatılabilir.

Örnek `manifest.json`:

```json
{
  "id": "ornek-eklenti",
  "name": "Örnek Widget",
  "description": "Kısa eklenti açıklaması",
  "slot": "bar",
  "entry": "Main.qml"
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
├── .gitleaks.toml                  # Gizli anahtar tarama yapılandırması
├── AGENTS.md                       # Ajan çalışma ve mimari kuralları
├── Justfile                        # Geliştirici ve CI/CD görev otomasyonu
├── LICENSE                         # GPL-3.0-or-later lisans metni
├── README.md                       # Proje dokümantasyonu
├── VERSION                         # Sürüm numarası
├── flake.lock                      # Bağımlılık kilit dosyası
├── flake.nix                       # Nix Flake tanımı, paket ve modül çıktıları
├── matugen.toml                    # Matugen renk çıkarımı ve tema şablon hedefleri
├── shell.qml                       # Çoklu ekran ve pencere katmanları giriş noktası
├── assets/                         # Varsayılan duvar kağıtları ve görsel varlıklar
├── bin/                            # Yardımcı kabuk betikleri — enyxma-clip, enyxma-shot
├── docs/
│   ├── design-tokens.md            # Renk, tipografi ve animasyon standartları
│   └── quickshell-gotchas.md       # Quickshell & QML teknik kısıtları
├── templates/                      # Matugen tarafından işlenen uygulama tema şablonları
├── services/                       # Pragma Singleton servis katmanı
│   ├── AIState.qml                 # Yerel LLM soket ve akış durumu
│   ├── AudioState.qml              # PipeWire ve WirePlumber ses mikseri
│   ├── BluetoothState.qml          # BlueZ tarama, eşleştirme ve pil servisi
│   ├── BrightnessState.qml         # Ekran parlaklığı yönetimi
│   ├── ContainerState.qml          # Docker ve Podman konteyner izleme servisi
│   ├── FocusState.qml              # Pomodoro odak sayacı servisi
│   ├── GeneratedColors.qml         # Matugen tarafından üretilen dinamik palet
│   ├── HyprlandState.qml           # Çalışma alanları ve aktif pencere durumu
│   ├── LauncherState.qml           # Uygulama başlatıcı durumu
│   ├── MediaBrowserState.qml       # Ekran görüntüsü ve ekran kaydı tarayıcısı
│   ├── MediaState.qml              # MPRIS medya oynatıcı ve çalma durumu
│   ├── NetworkState.qml            # Wi-Fi, Ethernet, VPN, DNS ve QR paylaşımı
│   ├── NotificationState.qml       # Masaüstü bildirim havuzu
│   ├── OverviewState.qml           # Mission Control genel bakış servisi
│   ├── PerformanceState.qml        # CPU, RAM, DRM GPU, VRAM, sıcaklık ve top süreçler
│   ├── PluginState.qml             # Yerel eklenti tarayıcı ve durum yönetimi
│   ├── qmldir                      # Modül ve singleton kayıtları
│   ├── ScreenState.qml             # Odaklı monitör takibi ve çoklu ekran katman politikası
│   ├── ScreenTimeState.qml         # Aktif pencere tabanlı yerel ekran süresi takibi
│   ├── SettingsState.qml           # Merkezi ayarlar, hyprctl eval ve hypridle canlı yönetimi
│   ├── StorageState.qml            # Disk alanı ve NVMe durumu
│   ├── SystemState.qml             # Kontrol Merkezi görünürlüğü, UPower pil, uptime ve ağ özeti
│   ├── Theme.qml                   # Renk paleti ve tasarım token'ları
│   ├── TimeState.qml               # Saat ve takvim biçimlendirme
│   ├── ToolsState.qml              # yt-dlp ve Cobalt tabanlı medya indirme ve dönüştürme servisi
│   ├── WallpaperState.qml          # Duvar kağıdı ve tema yönetimi
│   └── WeatherState.qml            # Canlı meteoroloji ve saatlik tahmin servisi
├── widgets/                        # Atomik görsel bileşenler
│   └── EnyxmaPill.qml              # Standart durum kapsülü
└── modules/                        # Masaüstü katmanları ve açılır paneller
    ├── ai/                         # 3 sekmeli yan panel — AI sohbeti, medya indirici, ekran süresi
    ├── audio/                      # Ses mikseri panelleri
    ├── background/                 # Masaüstü arka plan katmanı
    ├── bar/                        # Gotham ve Dinamik üst çubuk bileşenleri
    ├── bluetooth/                  # Bluetooth yönetim panelleri
    ├── cc/                         # Kontrol merkezi
    ├── containers/                 # Konteyner izleme panelleri
    ├── launcher/                   # OmniLauncher uygulama başlatıcı
    ├── media/                      # MPRIS medya kontrol paneli ve ekran görüntüsü tarayıcısı
    ├── network/                    # Ağ ve Wi-Fi QR panelleri
    ├── notifications/              # Bildirim merkezi ve toast'lar
    ├── osd/                        # Ses ve parlaklık OSD katmanı
    ├── overview/                   # Mission Control genel bakış katmanı
    ├── performance/                # Sistem, performans ve depolama panelleri
    ├── screenshot/                 # Enyxma Shot ekran görüntüsü ve mockup aracı
    ├── settings/                   # Enyxma Ayarlar 2.0 panelleri
    ├── time/                       # Harmonik Bento zaman, takvim ve hava hub'ı
    └── wallpaper/                  # Duvar kağıdı seçici galerisi
```

---

## 🛠️ Geliştirme ve Doğrulama

Kod bütünlüğünü ve tasarım standartlarını korumak için `Justfile` üzerinde tanımlı adımlar `nix develop` ortamında çalıştırılır:

```bash
# 1. Tüm statik kontrolleri çalıştır
nix develop -c just verify

# 2. Kabuk enjeksiyonu taraması
nix develop -c just check-shell

# 3. Kaçak hardcoded renk ve sabit yol taraması
nix develop -c just check-leaks

# 4. Tüm servislerin qmldir içinde kayıtlı olduğunu doğrula
nix develop -c just check-qmldir

# 5. QML sözdizimi doğrulaması
nix develop -c just lint

# 6. Sahte rastgele veri taraması ve doğrulama notları
nix develop -c just fake-data
nix develop -c just unverified

# 7. Kabuğu yerel oturumda çalıştır
nix develop -c just run
```

---

## 📜 Lisans

GPL-3.0-or-later — Ayrıntılar için [LICENSE](./LICENSE) dosyasına bakın. Telif Hakkı © 2026 Enyxma OS Contributors.
