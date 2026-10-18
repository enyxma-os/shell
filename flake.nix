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
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qsPkg = quickshell.packages.${system}.default;
    in
    {
      # Paketleme
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "enyxma-shell";
        version = "0.1.0";
        src = ./.;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          mkdir -p $out/share/enyxma-shell
          cp -r shell.qml services modules widgets assets $out/share/enyxma-shell/

          mkdir -p $out/bin
          cat << EOF > $out/bin/enyxma-shell
#!/usr/bin/env bash
exec ${qsPkg}/bin/quickshell -p$out/share/enyxma-shell/shell.qml "\$@"
EOF
          chmod +x $out/bin/enyxma-shell

          cat << EOF > $out/bin/enyxma-shot
#!/usr/bin/env bash
exec flock -n -o /tmp/enyxma-shot.lock ${qsPkg}/bin/quickshell -p$out/share/enyxma-shell/modules/screenshot/shell.qml "\$@"
EOF
          chmod +x $out/bin/enyxma-shot

          wrapProgram $out/bin/enyxma-shell \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wl-clipboard pkgs.libnotify pkgs.imagemagick pkgs.coreutils pkgs.procps pkgs.findutils ]}

          wrapProgram $out/bin/enyxma-shot \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wl-clipboard pkgs.libnotify pkgs.imagemagick pkgs.coreutils pkgs.procps pkgs.findutils ]}
        '';
      };

      # Geliştirme ve Ajan Doğrulama Ortamı (nix develop)
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          qsPkg
          qt6.qtdeclarative # qmllint ve qmlformat için
          just              # just verify iş akışı için
          ripgrep           # rg kaçak taraması için
          jetbrains-mono
          inter
        ];

        shellHook = ''
          echo "🚀 Enyxma Shell Dev Environment Hazır!"
          echo "Doğrulama için: 'just verify' | Çalıştırmak için: 'just run'"
        '';
      };

      # Home Manager Modülü
      homeManagerModules.default = { config, lib, ... }:
        let
          cfg = config.enyxma.shell;
        in
        {
          options.enyxma.shell.enable = lib.mkEnableOption "Enyxma Quickshell Desktop";

          config = lib.mkIf cfg.enable {
            home.packages = [
              self.packages.${system}.default
            ];

            systemd.user.services.enyxma-shell = {
              Unit = {
                Description = "Enyxma OS Desktop Shell";
                PartOf = [ "graphical-session.target" ];
              };
              Service = {
                ExecStart = "${self.packages.${system}.default}/bin/enyxma-shell";
                Restart = "always";
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };
    };
}
