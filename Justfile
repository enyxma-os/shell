set shell := ["bash", "-e", "-o", "pipefail", "-c"]

# Varsayılan: tüm statik doğrulamalar
default: verify

# ── Ajan Doğrulama Protokolü (AGENTS.md Bölüm 3) ───────────────────────
verify: check-shell check-leaks check-qmldir lint
    @echo "✅ Tüm statik doğrulamalar geçti."

# 1. Kabuk enjeksiyonu / RCE yüzeyi taraması (P0 kapısı)
#    `bash -c` / `sh -c` ile string birleştirme YASAK. Tek meşru istisna
#    yok: her harici çağrı argüman dizisi olmalı.
check-shell:
    @echo "🔍 Kabuk çağrısı taraması (bash -c / sh -c)..."
    @if rg -n --glob '!Justfile' --glob '!AGENTS.md' --glob '!*.md' \
        '\[\s*"(ba)?sh"\s*,\s*"-c"' . ; then \
        echo "❌ HATA: bash/sh -c kullanımı bulundu (kabuk enjeksiyonu riski)." ; \
        exit 1 ; \
    else echo "  ✔ kabuk yok" ; fi

# 2. Hardcoded renk (#hex / Qt.rgba) ve sabit kullanıcı yolu taraması
#    services/, modules/ ve widgets/ DAHİL — eski tarama services/'i atlıyordu,
#    yani kaçağın gerçekte olduğu yeri görmüyordu (R1).
#    İzin listesi: services/Theme.qml (token tanımları) ve
#    modules/screenshot/Singletons/ (araç kendi paletini taşır).
check-leaks:
    @echo "🔍 Kaçak renk / sabit yol taraması..."
    @if rg -n --glob '!services/Theme.qml' \
        --glob '!services/GeneratedColors.qml' \
        --glob '!modules/screenshot/**' \
        --glob '!**/*.md' --glob '!Justfile' \
        '"#[0-9a-fA-F]{3,8}"|/home/|/run/user/[0-9]+' \
        services modules widgets ; then \
        echo "❌ HATA: kaçak sabit renk/yol bulundu." ; exit 1 ; \
    else echo "  ✔ temiz" ; fi

# 3. services/*.qml dosyaları qmldir içinde kayıtlı mı?
check-qmldir:
    @echo "🔍 Singleton qmldir kayıtları..."
    @test -f services/qmldir || { echo "❌ services/qmldir yok"; exit 1; }
    @for f in services/*.qml; do \
        [ -e "$$f" ] || continue ; \
        name=`basename "$$f" .qml` ; \
        grep -q "singleton $$name " services/qmldir || \
            { echo "❌ HATA: $$name qmldir içinde kayıtlı değil!" ; exit 1 ; } ; \
    done
    @echo "  ✔ tümü kayıtlı"

# 4. QML sözdizimi — sabit /nix/store yolu YOK (R1: her nixpkgs
#    güncellemesinde kırılıyordu).
lint:
    @echo "🔍 qmllint..."
    @if command -v qmllint >/dev/null 2>&1; then \
        find . -name '*.qml' -not -path './.git/*' -print0 | xargs -0 qmllint ; \
    else \
        echo "  ⚠ qmllint bulunamadı — 'nix develop' içinde çalıştırın" ; \
    fi

# 5. Belirsizlik raporu
unverified:
    @rg -n "UNVERIFIED" -g '!Justfile' -g '!AGENTS.md' . || echo "Temiz."

# 6. Sahte veri taraması (R1/B9: Math.random ile uydurma istatistik)
fake-data:
    @echo "🔍 Math.random() taraması..."
    @if rg -n 'Math\.random\(' services modules ; then \
        echo "❌ HATA: sahte/rastgele veri üretimi bulundu." ; exit 1 ; \
    else echo "  ✔ temiz" ; fi

run:
    quickshell -p .

# VM senkronizasyonu
# NOT: --delete kullanılıyor ama `--exclude` listesi genişletildi; aksi halde
# matugen'ın ürettiği services/GeneratedColors.qml her deploy'da siliniyor
# ve tema varsayılana dönüyordu (R1).
deploy vm="enyxma@192.168.122.104":
    @echo "🚀 VM'e senkronize ediliyor: {{vm}}"
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='services/GeneratedColors.qml' \
        --exclude='*.qmlc' \
        ./ {{vm}}:~/.config/quickshell/
    @echo "🔄 Yeniden başlatılıyor..."
    ssh {{vm}} 'export XDG_RUNTIME_DIR=/run/user/$(id -u); \
        export WAYLAND_DISPLAY=$(basename $(ls /run/user/$(id -u)/wayland-* 2>/dev/null | grep -v lock | head -n1) 2>/dev/null || echo wayland-1); \
        export HYPRLAND_INSTANCE_SIGNATURE=$(basename $(ls -d /run/user/$(id -u)/hypr/*_* 2>/dev/null | head -n1)); \
        export QT_QPA_PLATFORM=wayland; \
        pkill -x quickshell 2>/dev/null || true; \
        sleep 0.5; \
        quickshell -d'
    @echo "✅ Enyxma Shell VM üzerinde yeniden başlatıldı."
