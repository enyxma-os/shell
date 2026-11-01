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
        coreutils procps findutils gnugrep gnused gawk
        wl-clipboard libnotify
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
            VER="$(cat "$SRC/VERSION")"
            ROOT="''${XDG_DATA_HOME:-$HOME/.local/share}/enyxma-shell"
            RUNTIME="$ROOT/$VER"
            if [ ! -f "$RUNTIME/.stamp" ]; then
              mkdir -p "$RUNTIME"
              find "$ROOT" -mindepth 1 -maxdepth 1 -type d ! -name "$VER" \
                -exec rm -rf {} + 2>/dev/null || true
              cp -r "$SRC"/. "$RUNTIME"/
              chmod -R u+w "$RUNTIME"
              date -u +%FT%TZ > "$RUNTIME/.stamp"
            fi
            # matugen şablon yolları: store değil, yazılabilir çalışma ağacı.
            export ENYXMA_SHELL_DIR="$RUNTIME"
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
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "enyxma-shell";
            version = "0.2.0";
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


              mkdir -p $out/bin
              substitute ${launcher} $out/bin/enyxma-shell --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shell
              substitute ${shotLauncher} $out/bin/enyxma-shot --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shot

              wrapProgram $out/bin/enyxma-shell --prefix PATH : ${binPath}
              wrapProgram $out/bin/enyxma-shot --prefix PATH : ${binPath}
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
