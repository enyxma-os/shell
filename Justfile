set shell := ["bash", "-uc"]

# Varsayılan: Tüm kontrolleri çalıştır
default: verify

# Ajan Doğrulama Protokolü (AGENTS.md Bölüm 3)
verify: check-leaks check-qmldir lint
    @echo "✅ Tüm statik doğrulamalar başarıyla geçti!"

# 1. Hardcoded renk (#hex) ve /home/ yolu taraması
check-leaks:
    @echo "🔍 Kaçak renk ve sabit yol taraması yapılıyor..."
    @if [ -d modules ] || [ -d widgets ]; then \
        ! rg -n '"#[0-9a-fA-F]{3,8}"|/home/' modules widgets 2>/dev/null; \
    fi

# 2. services/ içindeki QML dosyaları qmldir içinde kayıtlı mı?
check-qmldir:
    @echo "🔍 Singleton qmldir kayıtları kontrol ediliyor..."
    @if [ -d services ]; then \
        test -f services/qmldir || (echo "❌ HATA: services/qmldir bulunamadı!" && exit 1); \
        for f in services/*.qml; do \
            [ -e "$f" ] || continue; \
            name=$(basename "$f" .qml); \
            grep -q "singleton $name " services/qmldir || (echo "❌ HATA: $name services/qmldir içinde kayıtlı değil!" && exit 1); \
        done; \
    fi

# 3. QML Sözdizimi (Syntax) kontrolü
lint:
    @echo "🔍 QML dosyaları taranıyor (qmllint)..."
    @if command -v qmllint >/dev/null 2>&1; then \
        find . -name "*.qml" -exec qmllint {} +; \
    elif [ -x /nix/store/0z5545jrl0jj6g9h4cb76slxmnwl71aq-qtdeclarative-6.11.2/bin/qmllint ]; then \
        find . -name "*.qml" -exec /nix/store/0z5545jrl0jj6g9h4cb76slxmnwl71aq-qtdeclarative-6.11.2/bin/qmllint {} +; \
    else \
        LC_ALL=C nix-shell -p qt6.qtdeclarative --run 'find . -name "*.qml" -exec qmllint {} +'; \
    fi

# 4. Kod içindeki UNVERIFIED etiketlerini listele
unverified:
    @echo "⚠️ Doğrulanmamış (UNVERIFIED) API kullanımları:"
    @rg -n "UNVERIFIED" -g "!Justfile" -g "!AGENTS.md" . || echo "Temiz! UNVERIFIED etiket bulunamadı."

# Canlı test (NixOS VM içinde çalıştırmak için)
run:
    quickshell -p .

# VM'e yeni shell kodlarını senkronize et ve yeniden başlat
deploy vm="enyxma@192.168.122.104":
    @echo "🚀 VM'e senkronize ediliyor..."
    rsync -avz --delete --exclude='.git' ./ {{vm}}:~/.config/quickshell/
    @echo "🔄 Quickshell yeniden başlatılıyor..."
    ssh {{vm}} 'export XDG_RUNTIME_DIR=/run/user/1000; \
        export WAYLAND_DISPLAY=$(basename $(ls /run/user/1000/wayland-* 2>/dev/null | grep -v lock | head -n1) 2>/dev/null || echo wayland-1); \
        export HYPRLAND_INSTANCE_SIGNATURE=$(basename $(ls -d /run/user/1000/hypr/*_* 2>/dev/null | head -n1) 2>/dev/null || true); \
        export QT_QPA_PLATFORM=wayland; \
        pkill -9 -x .quickshell-wra 2>/dev/null || true; \
        sleep 0.5; \
        quickshell -d'
    @echo "✅ VM üzerinde Enyxma Shell başarıyla aktif edildi!"
