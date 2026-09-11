# Residual for PortMaster — experimental 0.1.0

Native Java/libGDX adaptation of the supplied Windows/GOG Residual 1.4.1 build. Original game code and assets remain in the owner's unchanged JAR. This is an unofficial port, not a game reimplementation.

## Requirements

A purchased copy of the supported game, ARM64 Linux firmware, working PortMaster, Java 17 and Westonpack runtimes, and compatible graphics drivers. Targets include RG34XX SP/muOS, R36S on 64-bit firmware, and ARM64 Anbernic XX devices. A matching processor alone does not establish firmware compatibility. 32-bit firmware is not supported by this package.

The bundled ARM64 GLFW needs GLIBC 2.27; OpenAL also needs compatible libstdc++ (GLIBCXX_3.4.22). PortMaster's graphics/runtime environment must satisfy those dependencies. Physical handheld testing remains required.

## Install

Choose one package:

- **residual-byo-data.zip**: extract into your firmware's ports directory. Copy your own `residual.jar` into `residual/residual.jar`.
- **residual-private-portmaster.zip**: already contains this owner's game JAR. Extract into the ports directory. Keep this archive private.

For muOS, the additional **residual-private-muos.zip** places the launcher in `roms/PORTS` and the game directory in `ports`; extract to the SD-card root. Keep this archive private too. Alternatively move `Residual.sh` to `/roms/PORTS` and `residual` to `/ports` manually.

Open Residual from Ports. The launcher requests missing Java 17 and Westonpack runtimes through PortMaster. A connection is needed to install missing runtimes. Ordinary local gameplay uses the offline social adapter; Steam/Epic features and cloud saves are unavailable.

## Prepare data on the handheld

No PC conversion or asset extraction is needed. Copy the original `residual.jar` directly from your Windows installation using a file manager, SD card or network transfer. The game assets and Linux native libraries are already inside it. The first launch verifies the file locally. The handheld does not run the Windows installer or manufacture game data without an owned copy.

Supported file: `residual.jar`, 83,168,018 bytes, SHA256:

`8f8caa7dc36f5ab9c7119046ccce87e3f7a2d61680dc60970fa3d2b2d619ee01`

Other builds are rejected rather than assumed compatible.

## Controls

| Handheld | Action |
|---|---|
| D-pad / left stick | Move and navigate (WASD) |
| A / R1 | Action / confirm (X) |
| B | Up / jump (W) |
| X / L1 | Inventory (Tab) |
| Y / L2 | Visor (V) |
| Start / Select | Pause / back (Escape) |
| R2 | Down (S) |

Keep default keyboard bindings in the game, or update `residual.gptk` to match any changes. PortMaster supplies controller identification. Its normal exit shortcut applies. Use the game's save/quit option before leaving to retain planet progress.

## Display and speed

The launcher uses the firmware's oriented display size. It accepts 640x480, 720x480, 720x720, 1024x768 and 1280x720, as well as other sizes from 160 to 8192 pixels per dimension. Landscape and square screens use the available area; portrait screens retain a square minimum view with borders. The game may add its own cinematic borders.

If automatic detection is wrong, create `residual/resolution.txt` containing just a size such as `720x480`. Use `auto` or remove the file to restore detection. `RESIDUAL_RESOLUTION` overrides this file. The logical height is divisible by the game's normal 160/240 camera settings, and viewport scaling preserves the aspect ratio.

A monotonic frame limiter caps game updates at 60 per second, matching Residual's desktop launcher. It does not run catch-up updates after a stall. Low performance can still slow the game on a device; higher refresh rates should not speed it up.

## Saves and troubleshooting

Settings and save slots live under `residual/saves`; cache and diagnostic output are under `residual/cache` and `residual/log.txt`. Back up the complete saves folder before updating. Exit through the in-game save/quit option: host shutdown saves settings, not an arbitrary mid-game checkpoint.

If launch fails, keep `log.txt`, note the firmware/version and device, and verify the original JAR fingerprint. Missing native libraries or unsupported graphics drivers require a compatible firmware/runtime; renaming the Windows EXE will not fix them.

## Build and prepare ZIPs

Install Python 3.8+ and a JDK 17+ on the build computer. From this source directory:

```sh
python tools/inspect_input.py /path/to/Residual
python tools/build.py --game-jar /path/to/Residual/residual.jar --jdk /path/to/jdk
python tools/verify_package.py
bash tests/verify_display.sh
```

PowerShell example:

```powershell
python tools/build.py --game-jar '/path/to/Residual/residual.jar' --jdk 'C:/path/to/jdk'
```

Compilation targets Java 8 bytecode, while the deployed runtime is Java 17. No third-party downloads are needed for the host build. Output in `dist` includes the BYO-data ZIP, private PortMaster ZIP, private muOS ZIP, source ZIP and SHA256SUMS.txt. Run `python tools/build.py --package-only` after documentation or launcher changes when the host has already been built.

`residual-port-source.zip` contains the host source and packaging tools. It excludes proprietary game data, binaries, decompiled inspection output and saves. Only share the source/BYO archives; private archives contain the commercial game. Review `VALIDATION.md` for the actual test scope before describing device compatibility.

## Release notes — 0.1.0

- Initial ARM64 PortMaster host for Residual 1.4.1.
- Direct use of the original Windows JAR, including its Linux ARM64 libraries.
- Offline startup, PortMaster keyboard controls and isolated local saves.
- Resolution selection for common 4:3, 3:2, square and widescreen handheld displays.
- Independent 60 Hz frame cap and Java 17/Westonpack launcher.
- Separate public source/BYO archives and private installation packages.
- Experimental release: desktop tests do not certify any physical handheld.

The host and adapted launcher are MIT licensed; see LICENSE. The original game and bundled third-party components retain their respective licenses.
