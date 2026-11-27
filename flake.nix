{
  description = "Enyxma Shell - AI-native Quickshell desktop environment for Enyxma OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # Shell'in ÇALIŞMA ANINDA exec ettiği tüm ikili dosyalar.
      # Eksik her giriş, temiz bir NixOS kurulumunda "command not found"tu.
      runtimeDeps = pkgs: with pkgs; [
        bash coreutils procps findutils gnugrep gnused gawk
        wl-clipboard cliphist libnotify
        bluez
        wireplumber
        qrencode
        matugen
        imagemagick
        networkmanager networkmanagerapplet iw iproute2
        brightnessctl hyprsunset hypridle ddcutil
        hyprland
        util-linux pciutils udisks2
        curl wget yt-dlp ffmpeg
        glib
        zenity kitty foot
        xdg-utils
        nerd-fonts.jetbrains-mono
        inter
        orbitron
        bibata-cursors
        papirus-icon-theme
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        qsPkg = quickshell.packages.${system}.default;
      });
    in
    {
      packages = forAllSystems ({ system, pkgs, qsPkg }:
        let
          binPath = pkgs.lib.makeBinPath (runtimeDeps pkgs);

          # ── Çalışma zamanı ağacı ──────────────────────────────────────
          # Dinamik renkler `~/.config/enyxma/colors.json` üzerinden okunur;
          # paket ağacı ilk çalıştırmada yazılabilir dizine kopyalanır.
          bootstrap = ''
            SRC="@src@"
            ROOT="''${XDG_DATA_HOME:-$HOME/.local/share}/enyxma-shell"
            RUNTIME="$ROOT/runtime"
            # matugen sablon yollari: store degil yazilabilir calisma agaci
            export ENYXMA_SHELL_DIR="$RUNTIME"
            if [ -n "''${ENYXMA_DEFAULT_SETTINGS_JSON:-}" ] && [ ! -f "$HOME/.config/enyxma/settings.json" ]; then
              mkdir -p "$HOME/.config/enyxma"
              printf '%s\n' "$ENYXMA_DEFAULT_SETTINGS_JSON" > "$HOME/.config/enyxma/settings.json"
            fi
            if [ ! -f "$RUNTIME/.store-source" ] || [ "$(cat "$RUNTIME/.store-source" 2>/dev/null)" != "$SRC" ]; then
              mkdir -p "$RUNTIME"
              find "$ROOT" -mindepth 1 -maxdepth 1 -type d ! -name "runtime" \
                -exec rm -rf {} + 2>/dev/null || true
              cp -rf "$SRC"/. "$RUNTIME"/
              chmod -R u+w "$RUNTIME"
              chmod +x "$RUNTIME/enyxma-theme-apply"
              echo "$SRC" > "$RUNTIME/.store-source"
              date -u +%FT%TZ > "$RUNTIME/.stamp"
              WP_PATH=""
              ACTIVE_THEME="dynamic"
              STATE_FILE=$(find "''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/by-shell" -maxdepth 2 -name wallpaper.json -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n 1 | cut -d' ' -f2- || true)
              if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
                THEME_CAND=$(sed -n 's/.*"theme"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -n 1 || true)
                if [ "$THEME_CAND" = "gotham" ]; then
                  ACTIVE_THEME="gotham"
                fi
                CANDIDATE=$(sed -n 's/.*"wallpaper"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -n 1 | sed 's|^file://||' || true)
                if [ -n "$CANDIDATE" ] && [ -f "$CANDIDATE" ]; then
                  WP_PATH="$CANDIDATE"
                fi
              fi
              if [ "$ACTIVE_THEME" = "gotham" ]; then
                "$RUNTIME/enyxma-theme-apply" preset gotham >/dev/null 2>&1 || true
              else
                if [ -z "$WP_PATH" ]; then
                  WP_PATH="$RUNTIME/assets/wallpapers/enyxma-obsidian-monolith.jpg"
                fi
                if [ -f "$WP_PATH" ]; then
                  "$RUNTIME/enyxma-theme-apply" image "$WP_PATH" >/dev/null 2>&1 || true
                fi
              fi
            fi
          '';

          launcher = pkgs.writeShellScript "enyxma-shell-launcher" (''
            set -euo pipefail
          '' + bootstrap + ''
            lock="''${XDG_RUNTIME_DIR:-/tmp}/enyxma-shell.lock"
            exec flock --close -n "$lock" ${qsPkg}/bin/quickshell -p "$RUNTIME/shell.qml" "$@"
          '');

          shotLauncher = pkgs.writeShellScript "enyxma-shot-launcher" (''
            set -euo pipefail
          '' + bootstrap + ''
            # Kilit: XDG_RUNTIME_DIR, --close alt süreçlerin kilidi miras almasını önler.
            lock="''${XDG_RUNTIME_DIR:-/tmp}/enyxma-shot.lock"
            if [ "$#" -eq 0 ] && ! flock -n "$lock" true 2>/dev/null; then
              pkill -f "$RUNTIME/modules/screenshot/shell.qml" 2>/dev/null || true
              exit 0
            fi
            exec flock --close -n "$lock" ${qsPkg}/bin/quickshell \
              -p "$RUNTIME/modules/screenshot/shell.qml" "$@"
          '');

          launchWrapper = pkgs.writeShellScript "enyxma-launch" ''
            set -euo pipefail
            if [ "$#" -eq 0 ]; then
              exit 0
            fi
            if command -v uwsm >/dev/null 2>&1 && uwsm check is-active >/dev/null 2>&1; then
              exec uwsm app -- "$@"
            elif command -v systemd-run >/dev/null 2>&1; then
              exec systemd-run --user --scope --slice=app.slice --quiet -- "$@"
            else
              exec "$@"
            fi
          '';

        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "enyxma-shell";
            version = pkgs.lib.strings.trim (builtins.readFile ./VERSION);
            src = ./.;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            # Kopyalanacak kaynak dışında derleme yok.
            dontBuild = true;
            dontConfigure = true;
            dontPatchShebangs = true;

            installPhase = ''
              mkdir -p $out/share/enyxma-shell
              cp -r shell.qml services modules widgets assets templates matugen.toml \
                    $out/share/enyxma-shell/
              cp VERSION $out/share/enyxma-shell/VERSION


              cp bin/enyxma-theme-apply $out/share/enyxma-shell/enyxma-theme-apply
              chmod +x $out/share/enyxma-shell/enyxma-theme-apply

              mkdir -p $out/bin
              substitute ${launcher} $out/bin/enyxma-shell --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shell
              substitute ${shotLauncher} $out/bin/enyxma-shot --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shot
              cp bin/enyxma-theme-apply $out/bin/enyxma-theme-apply
              chmod +x $out/bin/enyxma-theme-apply
              cp bin/enyxma-clip $out/bin/enyxma-clip
              chmod +x $out/bin/enyxma-clip
              cp ${launchWrapper} $out/bin/enyxma-launch
              chmod +x $out/bin/enyxma-launch

              wrapProgram $out/bin/enyxma-shell --prefix PATH : "$out/bin:${binPath}"
              wrapProgram $out/bin/enyxma-shot --prefix PATH : "$out/bin:${binPath}"
              wrapProgram $out/bin/enyxma-theme-apply --prefix PATH : ${binPath}
              wrapProgram $out/bin/enyxma-clip --prefix PATH : ${binPath}
            '';

            meta = with pkgs.lib; {
              description = "Enyxma OS Quickshell desktop shell";
              license = licenses.gpl3Plus;
              platforms = platforms.linux;
              mainProgram = "enyxma-shell";
            };
          };
        });

      devShells = forAllSystems ({ pkgs, qsPkg, ... }: {
        default = pkgs.mkShell {
          packages = (with pkgs; [
            qsPkg
            qt6.qtdeclarative   # qmllint / qmlformat
            just
            ripgrep
            nerd-fonts.jetbrains-mono
            inter
            matugen
          ]) ++ runtimeDeps pkgs;

          shellHook = ''
            echo "🚀 Enyxma Shell Dev Environment hazır."
            echo "  just verify   → statik doğrulama (kabuk/kaçak/qmldir/qmllint)"
            echo "  just run      → bu makinede çalıştır"
            echo "  just deploy   → VM'e senkronize et"
          '';
        };
      });

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.enyxma.shell;
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          options.enyxma.shell = {
            enable = lib.mkEnableOption "Enyxma Quickshell Desktop Environment";
            package = lib.mkOption {
              type = lib.types.package;
              default = pkg;
              description = "Kullanılacak enyxma-shell paketi.";
            };
            settings = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              description = "Initial declarative seed for ~/.config/enyxma/settings.json when missing.";
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];

            systemd.user.services.enyxma-shell = {
              description = "Enyxma OS Desktop Shell";
              after = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              environment = lib.mkIf (cfg.settings != {}) {
                ENYXMA_DEFAULT_SETTINGS_JSON = builtins.toJSON cfg.settings;
              };
              serviceConfig = {
                ExecStart = "${cfg.package}/bin/enyxma-shell";
                Restart = "always";
                RestartSec = "2s";
              };
              wantedBy = [ "graphical-session.target" ];
            };
          };
        };

      homeManagerModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.enyxma.shell;
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          options.enyxma.shell = {
            enable = lib.mkEnableOption "Enyxma Quickshell Desktop";
            package = lib.mkOption {
              type = lib.types.package;
              default = pkg;
              description = "Kullanılacak enyxma-shell paketi.";
            };
            settings = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              description = "Initial declarative seed for ~/.config/enyxma/settings.json when missing.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ cfg.package ];

            systemd.user.services.enyxma-shell = {
              Unit = {
                Description = "Enyxma OS Desktop Shell";
                # Wayland socket'i hazır olmadan başlama yarışını kapatır.
                After = [ "graphical-session.target" "wayland-wm.service" ];
                Wants = [ "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
                StartLimitIntervalSec = 30;
                StartLimitBurst = 5;
              };
              Service = {
                ExecStart = "${cfg.package}/bin/enyxma-shell";
                Restart = "always";
                RestartSec = "2s";
                Environment = lib.mkIf (cfg.settings != {}) [
                  "ENYXMA_DEFAULT_SETTINGS_JSON=${builtins.toJSON cfg.settings}"
                ];
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };
    };
}
