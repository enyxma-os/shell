# Enyxma Shell

> **Language / Dil:** **English** | [Türkçe](./README.tr.md)

A next-generation, event-driven, dual-theme desktop shell with local plugin support built with Quickshell and Qt 6 / QML for Enyxma OS.

---

## 🌟 Highlights

- **Dual-Theme Architecture:**
  - **Gotham 2.0:** Zero-radius, sharp tactical monochrome and amber palette.
  - **Dynamic Matugen:** Instant color extraction from the active wallpaper with live sync across Hyprland borders, GTK, Kitty, Foot, Starship, btop, Yazi, and `hyprlock`.
- **Enyxma Settings 2.0 — `SUPER + I`:**
  - **7 Categories:** Overview, Appearance, Top Bar, Display, Keyboard & Mouse, Shortcuts, System.
  - **Live Control:** Global search, one-click Undo toast, instant Hyprland window geometry via `hyprctl eval`, resolution / Hz / scale / VRR, Night Light Kelvin control, automatic `hypridle` lock / DPMS / suspend management, live `binds.lua` shortcut browser, and `~/.config/enyxma/settings.json` persistence.
- **Built-in Panels & Modules:**
  - **Unified System / Performance / Storage Panel:** CPU/GPU temperatures and utilization via Linux `hwmon` and DRM drivers (`amdgpu`, `i915`, `xe`, `nouveau`), VRAM usage, top processes, disk and NVMe health.
  - **Network Panel:** Wi-Fi scan and connect, VPN / DNS management, and instant Wi-Fi QR code sharing.
  - **PipeWire / WirePlumber Audio Mixer:** Output, microphone, and per-application audio streams.
  - **BlueZ Bluetooth Manager:** Device scanning, pairing, connecting, removal, and battery level tracking.
  - **Harmonic Bento Time, Calendar & Weather Hub:** Interactive calendar, day cycle, live weather, and hourly forecast.
  - **Optional Modules — Focus Timer & Container Monitor:** Pomodoro work/break timer and Docker / Podman container manager toggled under Settings -> System.
  - **3-Tab Side Panel:** Local AI chat, `yt-dlp` and Cobalt media downloader / converter, and active-window local screen time statistics.
  - **OmniLauncher, Media & Capture Browser, Notification Center, and Enyxma Shot:** Fuzzy-search launcher, MPRIS media controls, screenshot/recording browser, notification center, and annotation/mockup studio.
- **Strict Separation of Data and View:** UI components hold no business state; all logic lives in `pragma Singleton` services under `services/`.
- **App Isolation — `enyxma-launch`:** Applications launched via `uwsm app` and `systemd-run --user --scope` survive shell restarts and `nh os switch`.

---

## 🧩 Local Plugin Slot

Users can add custom widgets to the top bar by placing a `manifest.json` and QML component inside `~/.config/enyxma/plugins/<plugin-name>/` and toggling them under Settings -> System.

Example `manifest.json`:

```json
{
  "id": "example-plugin",
  "name": "Example Widget",
  "description": "Short plugin description",
  "slot": "bar",
  "entry": "Main.qml"
}
```

---

## 🚀 Quick Install — Nix Flake

Add as an input to your `flake.nix`:

```nix
inputs = {
  enyxma-shell.url = "git+https://codeberg.org/enyxma/shell";
};
```

### As a NixOS System Module

```nix
imports = [
  inputs.enyxma-shell.nixosModules.default
];

enyxma.shell.enable = true;
```

### As a Home Manager Module

```nix
imports = [
  inputs.enyxma-shell.homeManagerModules.default
];

enyxma.shell.enable = true;
```

---

## 📁 Directory Structure

```text
.
├── .gitleaks.toml                  # Secret scanning configuration
├── AGENTS.md                       # Agent workflow and architectural rules
├── Justfile                        # Developer and CI/CD task automation
├── LICENSE                         # GPL-3.0-or-later license text
├── README.md                       # Documentation (English)
├── README.tr.md                    # Documentation (Turkish)
├── VERSION                         # Version number
├── flake.lock                      # Dependency lock file
├── flake.nix                       # Nix Flake definition, package, and module outputs
├── matugen.toml                    # Matugen color extraction and template targets
├── shell.qml                       # Multi-screen and window layer entry point
├── assets/                         # Default wallpapers and visual assets
├── bin/                            # Helper scripts — enyxma-clip, enyxma-shot
├── docs/
│   ├── design-tokens.md            # Color, typography, and animation standards
│   └── quickshell-gotchas.md       # Quickshell & QML technical constraints
├── templates/                      # Application theme templates rendered by Matugen
├── services/                       # Pragma Singleton service layer
│   ├── AIState.qml                 # Local LLM socket and streaming state
│   ├── AudioState.qml              # PipeWire and WirePlumber audio mixer
│   ├── BluetoothState.qml          # BlueZ scanning, pairing, and battery service
│   ├── BrightnessState.qml         # Screen brightness control
│   ├── ContainerState.qml          # Docker and Podman container monitor
│   ├── FocusState.qml              # Pomodoro focus timer service
│   ├── GeneratedColors.qml         # Dynamic palette generated by Matugen
│   ├── HyprlandState.qml           # Workspaces and active window state
│   ├── LauncherState.qml           # Application launcher state
│   ├── MediaBrowserState.qml       # Screenshot and screen recording browser
│   ├── MediaState.qml              # MPRIS media player and playback state
│   ├── NetworkState.qml            # Wi-Fi, Ethernet, VPN, DNS, and QR sharing
│   ├── NotificationState.qml       # Desktop notification pool
│   ├── OverviewState.qml           # Mission Control overview service
│   ├── PerformanceState.qml        # CPU, RAM, DRM GPU, VRAM, temps, and top processes
│   ├── PluginState.qml             # Local plugin scanner and state management
│   ├── qmldir                      # Module and singleton registry
│   ├── ScreenState.qml             # Focused monitor tracking and layer policy
│   ├── ScreenTimeState.qml         # Active-window local screen time tracker
│   ├── SettingsState.qml           # Central settings, hyprctl eval, and live hypridle
│   ├── StorageState.qml            # Disk space and NVMe status
│   ├── SystemState.qml             # Control Center state, UPower battery, uptime, net summary
│   ├── Theme.qml                   # Color palette and design tokens
│   ├── TimeState.qml               # Time and calendar formatting
│   ├── ToolsState.qml              # yt-dlp and Cobalt media download/convert service
│   ├── WallpaperState.qml          # Wallpaper and theme management
│   └── WeatherState.qml            # Live weather and hourly forecast service
├── widgets/                        # Atomic visual components
│   └── EnyxmaPill.qml              # Standard status pill
└── modules/                        # Desktop layers and popup panels
    ├── ai/                         # 3-tab side panel — AI chat, media downloader, screen time
    ├── audio/                      # Audio mixer panels
    ├── background/                 # Desktop background layer
    ├── bar/                        # Gotham and Dynamic top bar components
    ├── bluetooth/                  # Bluetooth management panels
    ├── cc/                         # Control center
    ├── containers/                 # Container monitor panels
    ├── launcher/                   # OmniLauncher application launcher
    ├── media/                      # MPRIS media panel and capture browser
    ├── network/                    # Network and Wi-Fi QR panels
    ├── notifications/              # Notification center and popups
    ├── osd/                        # Volume and brightness OSD layer
    ├── overview/                   # Mission Control overview layer
    ├── performance/                # System, performance, and storage panels
    ├── screenshot/                 # Enyxma Shot capture and mockup tool
    ├── settings/                   # Enyxma Settings 2.0 panels
    ├── time/                       # Harmonic Bento time, calendar, and weather hub
    └── wallpaper/                  # Wallpaper picker gallery
```

---

## 🛠️ Development & Verification

All static checks defined in `Justfile` run inside `nix develop`:

```bash
# 1. Run all static checks
nix develop -c just verify

# 2. Shell injection scan
nix develop -c just check-shell

# 3. Hardcoded color and path leak scan
nix develop -c just check-leaks

# 4. Verify all services are registered in qmldir
nix develop -c just check-qmldir

# 5. QML syntax validation
nix develop -c just lint

# 6. Fake random data scan and unverified markers
nix develop -c just fake-data
nix develop -c just unverified

# 7. Run shell in local session
nix develop -c just run
```

---

## 📜 License

GPL-3.0-or-later — See [LICENSE](./LICENSE) for details. Copyright © 2026 Enyxma OS Contributors.
