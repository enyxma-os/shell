# ENYXMA SHELL (`enyxma/shell`) - AGENT OPERATING PROTOCOL

Enyxma OS (NixOS + Hyprland + Impermanence) masaüstü kabuğu mimarisi. Kod üretmeden önce ilgili göreve göre `docs/quickshell-gotchas.md` ve `docs/design-tokens.md` dosyalarını oku.

## 1. MİMARİ İLKELER VE GEREKÇELİ SINIRLAR

1. **Veri ve Görünüm Ayrımı (Dumb Widgets):** Görsel bileşenler (`modules/`, `widgets/`) içinde veri işleme veya durum tutma. Tüm sistem ve AI durumu `services/` altındaki `pragma Singleton` dosyalarda yaşar. *Neden: UI yeniden tasarlandığında arka uç mantığı kırılmamalı.*
2. **Polling Yasak, Event-Driven Serbest:** `Timer` ile periyodik bash komutu (`hyprctl`, `wpctl` vb.) çalıştırma; CPU ve bataryayı tüketir, gecikme yaratır. 
   * **Önce Native Servisleri Kullan:** `Hyprland`, `Pipewire`, `Mpris`, `UPower`, `Notifications`, `SystemTray`, `DesktopEntries`, `Bluetooth`.
   * **Native Servis Yoksa:** Parlaklık, özel ağ işleri ve AI daemon iletişimi için `Quickshell.Io` (`Process` + `SplitParser`, `Socket` veya `FileView`) ile yalnızca olay tabanlı (event-driven/stream) dinleme yap.
3. **Literal Renk ve Yol Kısıtı:** Literal renk tanımları yalnızca `services/Theme.qml` içinde yapılabilir (`"transparent"` istisnadır). Kalıcı dosya yolları için `/home/...` gibi sabit dizinler yazma; `Quickshell.statePath()`, `Quickshell.cachePath()` ve `Quickshell.dataPath()` fonksiyonlarını kullan. *Neden: Sistem tmpfs + Impermanence üzerinde çalışır.*
4. **Dürüst Belirsizlik (Anti-Hallucination):** Quickshell API'sinde emin olmadığın hiçbir özelliği veya sinyali tahmin ederek yazma. Emin olmadığın satırı `// UNVERIFIED: <neden>` ile işaretle ve doğrulama adımında bildir.
5. **AI Güvenlik Sınırı (Prompt Injection Koruması):** `Hyprland` üzerinden okunan pencere başlıkları (`activeWindow.title`) güvenilmez kullanıcı girdisidir (untrusted input). Bu veriyi AI bağlamına gönderirken sistem komutlarıyla birleştirme; AI bir sistem aksiyonu tetikleyecekse UI üzerinde mutlaka açık kullanıcı onayı (Confirmation Gate) göster.

## 2. KLASÖR HARİTASI

* `shell.qml` -> Ana giriş (`ShellRoot` ve çoklu monitör için `Variants`)
* `services/` -> Singleton durum yöneticileri (`qmldir`, `Theme.qml`, `AudioState.qml`, `AIState.qml` vb.)
* `widgets/` -> Yeniden kullanılabilir atomik QML bileşenleri
* `modules/` -> Ekran katmanları (`bar/`, `osd/`, `ai/`)
* `docs/` -> `quickshell-gotchas.md` (Zorunlu teknik kurallar) ve `design-tokens.md` (Görsel şema)

## 3. DOĞRULAMA PROTOKOLÜ (HER GÖREV SONUNDA ÇALIŞTIR)

Kodu tamamladığında aşağıdaki kontrolleri sırayla çalıştır ve çıktısını raporla:
1. **Sözdizimi Kontrolü:** `qmllint` veya `qmlformat --verify` (Sıfır hata olmalı).
2. **Çalışma Zamanı Testi:** `quickshell -p .` çalıştır, loglarda `ERROR` veya `WARN` satırı olmadığını doğrula.
3. **Singleton Kaydı:** `services/` altına yeni dosya eklendiyse `services/qmldir` dosyasına kaydedildi mi?
4. **Kaçak Taraması:** `rg '"#[0-9a-fA-F]{3,8}"|/home/' modules widgets` (Sonuç boş dönmeli).
5. **Belirsizlik Raporu:** Kod içindeki tüm `// UNVERIFIED:` etiketlerini listele.