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
        matugen
        imagemagick
        networkmanager iw iproute2
        brightnessctl hyprsunset ddcutil
        hyprland
        util-linux pciutils
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
            exec flock --close -n "$lock" ${qsPkg}/bin/quickshell \
              -p "$RUNTIME/modules/screenshot/shell.qml" "$@"
          '');

          themeApply = pkgs.writeShellScript "enyxma-theme-apply" ''
            set -euo pipefail
            export PATH="${binPath}:$PATH"
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
            mkdir -p "$HOME/.cache"
            exec 9>"$XDG_RUNTIME_DIR/enyxma-theme-apply.lock"
            flock 9
            mkdir -p "$HOME/.config/btop/themes" "$HOME/.config/yazi"
            if [ ! -f "$HOME/.config/btop/btop.conf" ]; then
              cat > "$HOME/.config/btop/btop.conf" << 'EOF'
color_theme = "enyxma"
theme_background = False
EOF
            fi
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

            apply_gotham_preset() {
              mkdir -p "$HOME/.cache" "$HOME/.config/hypr" "$HOME/.config/kitty" "$HOME/.config/foot" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/btop/themes" "$HOME/.config/yazi"

              cat > "$HOME/.cache/enyxma-GeneratedColors.qml.next" << 'EOF'
// Enyxma OS — Gotham 2.0 Brutalist Sabit Paleti
pragma Singleton
import QtQuick

QtObject {
    id: root

    property string preset: "gotham"

    // Primary Accents (Kontrollu endustriyel kehribar)
    property color primary: "#f0b429"
    property color primaryFg: "#07080b"
    property color primaryContainer: "#241e0a"
    property color primaryContainerFg: "#fcd34d"

    // Secondary & Tertiary (Soguk arduvaz ve grafit)
    property color secondary: "#64748b"
    property color secondaryFg: "#07080b"
    property color tertiary: "#94a3b8"
    property color tertiaryFg: "#07080b"

    // Surfaces & Containers (Obsidyen ve bazalt katmanlari)
    property color background: "#07080b"
    property color backgroundFg: "#e2e8f0"
    property color surface: "#0b0d12"
    property color surfaceFg: "#e2e8f0"
    property color surfaceContainer: "#11141c"
    property color surfaceContainerHigh: "#171b26"
    property color surfaceVariantFg: "#94a3b8"

    // Outlines & Borders (Soguk grafit ve arduvaz)
    property color outline: "#333c4d"
    property color outlineVariant: "#222834"

    // State & Status
    property color danger: "#e11d48"
    property color dangerFg: "#07080b"
}
EOF

              cat > "$HOME/.config/hypr/colors.lua" << 'EOF'
-- Enyxma OS Gotham 2.0 Hyprland Paleti
return {
    preset = "gotham",
    rounding = 0,
    border_size = 2,
    gaps_in = 4,
    gaps_out = 8,
    cursor_theme = "Bibata-Modern-Classic",
    cursor_size = 24,
    accent = "rgba(f0b429ee)",
    accent_secondary = "rgba(f0b429ee)",
    accent_solid = "#f0b429",
    surface = "rgba(0b0d12ee)",
    surface_container = "rgba(11141cee)",
    outline = "rgba(222834cc)",
}
EOF

              cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
# Enyxma OS — Gotham 2.0 Kitty Yapilandirmasi
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
font_size        11.5

background_opacity    0.88
window_padding_width  14

confirm_os_window_close 0
enable_audio_bell       no

cursor_shape          beam
cursor_blink_interval 0.5

background            #07080b
foreground            #e2e8f0
selection_background  #241e0a
selection_foreground  #fcd34d
url_color             #f0b429
cursor                #f0b429
cursor_text_color     #07080b

active_border_color   #f0b429
inactive_border_color #222834
active_tab_background   #f0b429
active_tab_foreground   #07080b
inactive_tab_background #11141c
inactive_tab_foreground #94a3b8

color0  #050608
color8  #333c4d
color1  #e11d48
color9  #e11d48
color2  #f0b429
color10 #f0b429
color3  #94a3b8
color11 #94a3b8
color4  #64748b
color12 #64748b
color5  #cbd5e1
color13 #94a3b8
color6  #fcd34d
color14 #f0b429
color7  #94a3b8
color15 #e2e8f0
EOF

              cat > "$HOME/.config/foot/foot.ini" << 'EOF'
# Enyxma OS — Gotham 2.0 Foot Yapilandirmasi
[main]
font=JetBrainsMono Nerd Font:size=11
pad=12x12
initial-window-size-chars=110x32

[cursor]
style=beam
blink=yes

[scrollback]
lines=10000

[colors-dark]
alpha=0.92
background=07080b
foreground=e2e8f0
cursor=07080b f0b429
selection-foreground=fcd34d
selection-background=241e0a

regular0=050608
regular1=e11d48
regular2=f0b429
regular3=94a3b8
regular4=64748b
regular5=cbd5e1
regular6=fcd34d
regular7=94a3b8

bright0=333c4d
bright1=e11d48
bright2=f0b429
bright3=94a3b8
bright4=64748b
bright5=94a3b8
bright6=f0b429
bright7=e2e8f0
EOF

              for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
                cat > "$gtk_dir/gtk.css" << 'EOF'
/* Enyxma OS — Gotham 2.0 GTK 3 ve GTK 4 Renkleri */
@define-color accent_color #f0b429;
@define-color accent_bg_color #f0b429;
@define-color accent_fg_color #07080b;
@define-color destructive_color #e11d48;
@define-color destructive_bg_color #4c0519;
@define-color destructive_fg_color #fda4af;
@define-color success_color #f0b429;
@define-color warning_color #94a3b8;
@define-color error_color #e11d48;
@define-color window_bg_color #07080b;
@define-color window_fg_color #e2e8f0;
@define-color view_bg_color #0b0d12;
@define-color view_fg_color #e2e8f0;
@define-color headerbar_bg_color #11141c;
@define-color headerbar_fg_color #e2e8f0;
@define-color headerbar_border_color #222834;
@define-color card_bg_color #11141c;
@define-color card_fg_color #e2e8f0;
@define-color dialog_bg_color #171b26;
@define-color dialog_fg_color #e2e8f0;
@define-color popover_bg_color #171b26;
@define-color popover_fg_color #e2e8f0;
@define-color sidebar_bg_color #090b0f;
@define-color sidebar_fg_color #e2e8f0;
EOF
              done

              cat > "$HOME/.config/hypr/hyprlock.conf" << 'EOF'
# Enyxma OS — Gotham 2.0 Hyprlock Yapilandirmasi
general {
    disable_loading_bar = true
    hide_cursor = true
    grace = 0
    no_fade_in = false
}

background {
    monitor =
    path = screenshot
    color = rgba(07080bff)
    blur_passes = 3
    blur_size = 7
    noise = 0.0117
    contrast = 0.8916
    brightness = 0.70
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

input-field {
    monitor =
    size = 280, 56
    outline_thickness = 2
    dots_size = 0.25
    dots_spacing = 0.2
    dots_center = true
    outer_color = rgba(f0b429cc) rgba(f0b429cc) 45deg
    inner_color = rgba(0b0d12d9)
    font_color = rgba(e2e8f0ff)
    fade_on_empty = false
    font_family = Orbitron
    placeholder_text = <i><span foreground="##94a3b8">Parola...</span></i>
    hide_input = false
    check_color = rgba(f0b429ff)
    fail_color = rgba(e11d48ff)
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
    capslock_color = rgba(f0b429ff)
    position = 0, -80
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%H:%M")"
    color = rgba(e2e8f0ff)
    font_size = 84
    font_family = Orbitron
    position = 0, 120
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:60000] echo "$(date +"%d %B %Y, %A")"
    color = rgba(f5c518ff)
    font_size = 18
    font_family = Orbitron
    position = 0, 35
    halign = center
    valign = center
}

label {
    monitor =
    text =   $USER
    color = rgba(94a3b8ff)
    font_size = 15
    font_family = JetBrainsMono Nerd Font
    position = 0, -20
    halign = center
    valign = center
}
EOF

              cat > "$HOME/.config/starship.toml" << 'EOF'
# Enyxma OS — Gotham 2.0 Starship Yapilandirmasi
add_newline = false
format = "$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character"

[directory]
style = "bold #f0b429"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = "git "
style = "bold #94a3b8"

[git_status]
style = "bold #e11d48"

[cmd_duration]
min_time = 2000
style = "bold #64748b"

[character]
success_symbol = "[❯](#f0b429 bold)"
error_symbol = "[❯](#e11d48 bold)"
EOF

              cat > "$HOME/.config/btop/themes/enyxma.theme" << 'EOF'
# Enyxma OS — Gotham 2.0 btop Temasi
theme[main_bg]=""
theme[main_fg]="#e2e8f0"
theme[title]="#e2e8f0"
theme[hi_fg]="#f0b429"
theme[selected_bg]="#241e0a"
theme[selected_fg]="#fcd34d"
theme[inactive_fg]="#333c4d"
theme[graph_text]="#94a3b8"
theme[meter_bg]="#171b26"
theme[proc_misc]="#94a3b8"
theme[cpu_box]="#222834"
theme[mem_box]="#222834"
theme[net_box]="#222834"
theme[proc_box]="#222834"
theme[div_line]="#222834"

theme[temp_start]="#f0b429"
theme[temp_mid]="#94a3b8"
theme[temp_end]="#e11d48"

theme[cpu_start]="#f0b429"
theme[cpu_mid]="#94a3b8"
theme[cpu_end]="#e11d48"

theme[free_start]="#f0b429"
theme[free_mid]="#64748b"
theme[free_end]="#94a3b8"

theme[cached_start]="#64748b"
theme[cached_mid]="#f0b429"
theme[cached_end]="#94a3b8"

theme[available_start]="#f0b429"
theme[available_mid]="#64748b"
theme[available_end]="#94a3b8"

theme[used_start]="#64748b"
theme[used_mid]="#94a3b8"
theme[used_end]="#e11d48"

theme[download_start]="#f0b429"
theme[download_mid]="#64748b"
theme[download_end]="#94a3b8"

theme[upload_start]="#94a3b8"
theme[upload_mid]="#64748b"
theme[upload_end]="#e11d48"

theme[process_start]="#f0b429"
theme[process_mid]="#94a3b8"
theme[process_end]="#e11d48"
EOF

              cat > "$HOME/.config/yazi/theme.toml" << 'EOF'
# Enyxma OS — Gotham 2.0 Yazi Temasi
[mgr]
cwd = { fg = "#f0b429", bold = true }
hovered = { fg = "#fcd34d", bg = "#241e0a", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "#f0b429", bold = true, underline = true }
find_position = { fg = "#94a3b8", bold = true }
marker_copied = { fg = "#f0b429", bg = "#f0b429" }
marker_cut = { fg = "#e11d48", bg = "#e11d48" }
marker_marked = { fg = "#94a3b8", bg = "#94a3b8" }
marker_selected = { fg = "#64748b", bg = "#64748b" }
border_style = { fg = "#222834" }

[tabs]
active = { fg = "#07080b", bg = "#f0b429", bold = true }
inactive = { fg = "#94a3b8", bg = "#11141c" }
EOF
            }

            RUNTIME_HYPR="$XDG_RUNTIME_DIR/hypr"
            if [ -d "$RUNTIME_HYPR" ]; then
              if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || [ ! -S "$RUNTIME_HYPR/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ]; then
                for d in $(ls -1t "$RUNTIME_HYPR" 2>/dev/null || true); do
                  if [ -S "$RUNTIME_HYPR/$d/.socket.sock" ]; then
                    export HYPRLAND_INSTANCE_SIGNATURE="$d"
                    break
                  fi
                done
              fi
            fi

            cd "$SHELL_DIR"
            if [ "$MODE" = "preset" ] && [ "$TARGET" = "gotham" ]; then
              apply_gotham_preset
            elif [ "$MODE" = "image" ]; then
              HEX=$(extract_vibrant_hex "$TARGET")
              matugen -c "$CFG" -t scheme-vibrant color hex "$HEX"
            else
              matugen -c "$CFG" -t scheme-vibrant color hex "$TARGET"
            fi

            CUR_THEME="Bibata-Modern-Ice"
            CUR_SIZE="24"
            ICON_THEME="Papirus-Dark"
            if [ -f "$HOME/.config/hypr/colors.lua" ]; then
              ACT_A=$(sed -n 's/^[[:space:]]*accent[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              ACT_B=$(sed -n 's/^[[:space:]]*accent_secondary[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              INACT=$(sed -n 's/^[[:space:]]*outline[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              RND=$(sed -n 's/^[[:space:]]*rounding[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              BSZ=$(sed -n 's/^[[:space:]]*border_size[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              GIN=$(sed -n 's/^[[:space:]]*gaps_in[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              GOUT=$(sed -n 's/^[[:space:]]*gaps_out[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              C_T=$(sed -n 's/^[[:space:]]*cursor_theme[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              C_S=$(sed -n 's/^[[:space:]]*cursor_size[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$HOME/.config/hypr/colors.lua" | head -n 1)
              [ -n "$C_T" ] && CUR_THEME="$C_T"
              [ -n "$C_S" ] && CUR_SIZE="$C_S"

              if command -v hyprctl >/dev/null 2>&1; then
                LUA_SYNC="hl.config({ general = { gaps_in = ''${GIN:-5}, gaps_out = ''${GOUT:-10}, border_size = ''${BSZ:-2}, col = { active_border = { colors = { \"''${ACT_A:-rgba(7aa2f7ee)}\", \"''${ACT_B:-rgba(bb9af7ee)}\" }, angle = 45 }, inactive_border = \"''${INACT:-rgba(3b4261aa)}\" } }, decoration = { rounding = ''${RND:-10} } })"
                EVAL_RES=$(hyprctl eval "$LUA_SYNC" 2>/dev/null || true)
                if [ "$EVAL_RES" != "ok" ]; then
                  [ -n "$ACT_A" ] && [ -n "$ACT_B" ] && hyprctl keyword general:col.active_border "$ACT_A $ACT_B 45deg" >/dev/null 2>&1 || true
                  [ -n "$INACT" ] && hyprctl keyword general:col.inactive_border "$INACT" >/dev/null 2>&1 || true
                  [ -n "$RND" ] && hyprctl keyword decoration:rounding "$RND" >/dev/null 2>&1 || true
                  [ -n "$BSZ" ] && hyprctl keyword general:border_size "$BSZ" >/dev/null 2>&1 || true
                  [ -n "$GIN" ] && hyprctl keyword general:gaps_in "$GIN" >/dev/null 2>&1 || true
                  [ -n "$GOUT" ] && hyprctl keyword general:gaps_out "$GOUT" >/dev/null 2>&1 || true
                fi
                hyprctl setcursor "$CUR_THEME" "$CUR_SIZE" >/dev/null 2>&1 || true
              fi
            fi

            for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
              mkdir -p "$gtk_dir"
              cat > "$gtk_dir/settings.ini" << EOF
[Settings]
gtk-application-prefer-dark-theme=1
gtk-cursor-theme-name=$CUR_THEME
gtk-cursor-theme-size=$CUR_SIZE
gtk-icon-theme-name=$ICON_THEME
EOF
            done

            mkdir -p "$HOME/.icons/default"
            cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Inherits=$CUR_THEME
EOF

            if command -v gsettings >/dev/null 2>&1; then
              gsettings set org.gnome.desktop.interface cursor-theme "$CUR_THEME" >/dev/null 2>&1 || true
              gsettings set org.gnome.desktop.interface cursor-size "$CUR_SIZE" >/dev/null 2>&1 || true
              gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" >/dev/null 2>&1 || true
              gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" >/dev/null 2>&1 || true
            fi

            pkill -USR1 -x kitty >/dev/null 2>&1 || true
            pkill -USR2 -x btop >/dev/null 2>&1 || true

            if [ -f "$HOME/.cache/enyxma-GeneratedColors.qml.next" ]; then
              mkdir -p "$SHELL_DIR/services"
              mv -f "$HOME/.cache/enyxma-GeneratedColors.qml.next" "$SHELL_DIR/services/GeneratedColors.qml"
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


              cp ${themeApply} $out/share/enyxma-shell/enyxma-theme-apply
              chmod +x $out/share/enyxma-shell/enyxma-theme-apply

              mkdir -p $out/bin
              substitute ${launcher} $out/bin/enyxma-shell --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shell
              substitute ${shotLauncher} $out/bin/enyxma-shot --replace-fail "@src@" "$out/share/enyxma-shell"
              chmod +x $out/bin/enyxma-shot
              cp ${themeApply} $out/bin/enyxma-theme-apply
              chmod +x $out/bin/enyxma-theme-apply
              cp bin/enyxma-clip $out/bin/enyxma-clip
              chmod +x $out/bin/enyxma-clip

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
