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
        wl-clipboard libnotify
        bluez
        matugen
        imagemagick
        networkmanager iw iproute2
        brightnessctl
        hyprland
        util-linux pciutils
        curl wget yt-dlp ffmpeg
        glib
        zenity kitty foot
        xdg-utils
        nerd-fonts.jetbrains-mono
        inter
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
          # matugen, services/GeneratedColors.qml'i YAZAR. /nix/store salt
          # okunurdur; oradan çalıştırmak tema zincirini sessizce kırıyordu.
          # Bu yüzden paket ağacı ilk çalıştırmada yazılabilir bir dizine
          # kopyalanır ve shell oradan çalışır.
          bootstrap = ''
            SRC="@src@"
            ROOT="''${XDG_DATA_HOME:-$HOME/.local/share}/enyxma-shell"
            RUNTIME="$ROOT/runtime"
            # matugen sablon yollari: store degil yazilabilir calisma agaci
            export ENYXMA_SHELL_DIR="$RUNTIME"
            if [ ! -f "$RUNTIME/.store-source" ] || [ "$(cat "$RUNTIME/.store-source" 2>/dev/null)" != "$SRC" ]; then
              mkdir -p "$RUNTIME"
              find "$ROOT" -mindepth 1 -maxdepth 1 -type d ! -name "runtime" \
                -exec rm -rf {} + 2>/dev/null || true
              cp -r "$SRC"/. "$RUNTIME"/
              chmod -R u+w "$RUNTIME"
              chmod +x "$RUNTIME/enyxma-theme-apply"
              echo "$SRC" > "$RUNTIME/.store-source"
              date -u +%FT%TZ > "$RUNTIME/.stamp"
              rm -f "$HOME/.config/yazi/theme.toml" 2>/dev/null || true
              WP_PATH=""
              STATE_FILE=$(find "''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/by-shell" -maxdepth 2 -name wallpaper.json -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n 1 | cut -d' ' -f2- || true)
              if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
                CANDIDATE=$(sed -n 's/.*"wallpaper"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -n 1 | sed 's|^file://||')
                if [ -n "$CANDIDATE" ] && [ -f "$CANDIDATE" ]; then
                  WP_PATH="$CANDIDATE"
                fi
              fi
              if [ -z "$WP_PATH" ]; then
                WP_PATH="$RUNTIME/assets/wallpapers/enyxma-obsidian-monolith.jpg"
              fi
              if [ -f "$WP_PATH" ]; then
                "$RUNTIME/enyxma-theme-apply" image "$WP_PATH" >/dev/null 2>&1 || true
              fi
            fi
          '';

          launcher = pkgs.writeShellScript "enyxma-shell-launcher" (''
            set -euo pipefail
          '' + bootstrap + ''
            lock="''${XDG_RUNTIME_DIR:-/tmp}/enyxma-shell.lock"
            exec flock -n "$lock" ${qsPkg}/bin/quickshell -p "$RUNTIME/shell.qml" "$@"
          '');

          shotLauncher = pkgs.writeShellScript "enyxma-shot-launcher" (''
            set -euo pipefail
          '' + bootstrap + ''
            # Kilit: XDG_RUNTIME_DIR (çok kullanıcılı /tmp symlink riski yok).
            lock="''${XDG_RUNTIME_DIR:-/tmp}/enyxma-shot.lock"
            exec flock -n "$lock" ${qsPkg}/bin/quickshell \
              -p "$RUNTIME/modules/screenshot/shell.qml" "$@"
          '');

          themeApply = pkgs.writeShellScript "enyxma-theme-apply" ''
            set -euo pipefail
            export PATH="${binPath}:$PATH"
            rm -f "$HOME/.config/yazi/theme.toml" 2>/dev/null || true
            MODE="''${1:-image}"
            TARGET="''${2:-}"
            if [ -z "$TARGET" ]; then
              exit 1
            fi

            SHELL_DIR="''${ENYXMA_SHELL_DIR:-$HOME/.local/share/enyxma-shell/runtime}"
            CFG="$SHELL_DIR/matugen.toml"

            extract_vibrant_hex() {
              ffmpeg -v error -i "$1" -vf "scale=64:64" -f rawvideo -pix_fmt rgb24 - | od -An -tu1 -w3 -v | awk '
              NF == 3 {
                r = $1 / 255.0; g = $2 / 255.0; b = $3 / 255.0;
                max = r; if (g > max) max = g; if (b > max) max = b;
                min = r; if (g < min) min = g; if (b < min) min = b;
                d = max - min;
                s = (max == 0) ? 0 : d / max;
                v = max;
                if (s > 0.25 && v > 0.32 && v < 0.98) {
                  if (max == r) h = (g - b) / d + (g < b ? 6 : 0);
                  else if (max == g) h = (b - r) / d + 2;
                  else h = (r - g) / d + 4;
                  h = h / 6.0;
                  bucket = int(h * 12) % 12;
                  w = (s * s * s) * (v * v);
                  bw[bucket] += w;
                  br[bucket] += $1 * w;
                  bg[bucket] += $2 * w;
                  bb[bucket] += $3 * w;
                }
              }
              END {
                best = -1; maxw = 0;
                for (i = 0; i < 12; i++) {
                  if (bw[i] > maxw) { maxw = bw[i]; best = i; }
                }
                if (best >= 0 && maxw > 0) {
                  printf "#%02x%02x%02x\n", int(br[best]/maxw), int(bg[best]/maxw), int(bb[best]/maxw);
                } else {
                  print "#38bdf8";
                }
              }'
            }

            cd "$SHELL_DIR"
            if [ "$MODE" = "image" ]; then
              HEX=$(extract_vibrant_hex "$TARGET")
              matugen -c "$CFG" -t scheme-vibrant color hex "$HEX"
            else
              matugen -c "$CFG" -t scheme-vibrant color hex "$TARGET"
            fi

            if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "/run/user/$(id -u)/hypr" ]; then
              export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 "/run/user/$(id -u)/hypr" 2>/dev/null | head -n 1 || true)
            fi

            if [ -f "$HOME/.config/hypr/colors.lua" ] && command -v hyprctl >/dev/null 2>&1; then
              ACT_A=$(sed -n 's/.*accent = "\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              ACT_B=$(sed -n 's/.*accent_secondary = "\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              INACT=$(sed -n 's/.*outline = "\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              if [ -n "$ACT_A" ] && [ -n "$ACT_B" ]; then
                hyprctl keyword general:col.active_border "$ACT_A $ACT_B 45deg" >/dev/null 2>&1 || true
              fi
              if [ -n "$INACT" ]; then
                hyprctl keyword general:col.inactive_border "$INACT" >/dev/null 2>&1 || true
              fi
            fi

            pkill -USR1 -x kitty >/dev/null 2>&1 || true
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


              cp ${themeApply} $out/share/enyxma-shell/enyxma-theme-apply
              chmod +x $out/share/enyxma-shell/enyxma-theme-apply

              mkdir -p $out/bin
              substitute ${launcher} $out/bin/enyxma-shell --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shell
              substitute ${shotLauncher} $out/bin/enyxma-shot --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shot
              cp ${themeApply} $out/bin/enyxma-theme-apply
              chmod +x $out/bin/enyxma-theme-apply

              wrapProgram $out/bin/enyxma-shell --prefix PATH : "$out/bin:${binPath}"
              wrapProgram $out/bin/enyxma-shot --prefix PATH : "$out/bin:${binPath}"
              wrapProgram $out/bin/enyxma-theme-apply --prefix PATH : ${binPath}
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
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];

            systemd.user.services.enyxma-shell = {
              description = "Enyxma OS Desktop Shell";
              after = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
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
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };
    };
}
