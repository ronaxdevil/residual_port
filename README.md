## Notes

Thanks to [Orangepixel](https://orangepixel.net/) for Residual and its planet exploration and survival gameplay. PortMaster adaptation by **ronaxdevil**.

This port runs the original Residual 1.4.1 Windows/GOG game JAR on compatible ARM64 Linux handheld firmware using PortMaster's Java 17 and Westonpack runtimes. The single **Residual.zip** is a bring-your-own-data package. You must own the game; game code and assets are not included.

## Get residual.jar from GOG

1. Open [Residual on GOG](https://www.gog.com/en/game/residual) in your owned games library and download the **Windows offline backup installer for version 1.4.1**. Download its accompanying `.bin` parts too, if listed, and keep them beside the installer `.exe`. Use the full game installer, not a patch or GOG Galaxy installer.
2. On Windows, run that offline installer and choose an installation folder, for example `C:\GOG Games\Residual`. Galaxy is not required.
3. Open the installation folder and copy the **residual.jar** beside `residual.exe`. Keep the JAR intact; do not unpack it or rename an EXE to JAR. The Windows runtime and other installed files are not needed on the handheld.
4. Verify the file before copying it to the handheld. The supported JAR is **83,168,018 bytes**, with SHA-256:

```text
8f8caa7dc36f5ab9c7119046ccce87e3f7a2d61680dc60970fa3d2b2d619ee01
```

Windows PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'C:\GOG Games\Residual\residual.jar'
```

The inspected installation has GOG game ID `1688702977` and build ID `59032447871207888`. GOG may change download filenames or available versions; the JAR checksum, rather than a guessed installer filename, identifies this supported build. A different checksum requires compatibility verification.

On Linux, [innoextract](https://constexpr.org/innoextract/) can unpack supported GOG offline installers without running Windows. Install it through your distribution, then use the actual downloaded installer filename:

```sh
innoextract --extract --output-dir residual-extracted "setup_residual_YOUR_VERSION.exe"
find residual-extracted -type f -iname residual.jar
sha256sum "residual-extracted/app/residual.jar"
```

Use the path reported by `find` if it differs from the example. Keep any installer `.bin` parts together. If innoextract does not support the installer, use the Windows installation method. The inspected input was an installed game directory; extraction from an offline installer has not been tested for this port.

## Install Residual.zip

1. Update PortMaster on your handheld. Use compatible **64-bit ARM firmware**, such as muOS on supported Anbernic RGXX devices or a compatible R36S firmware. PortMaster provisions Java 17 and Westonpack; keep the device online for the initial runtime download.
2. Copy **Residual.zip** into your PortMaster installation's `autoinstall` folder, then open PortMaster to install it. This is the same ZIP for every supported device and resolution.
3. Copy your verified **residual.jar** into the installed **residual** data folder, alongside `display.inc` and `residual.ini`, not into `runtime`.
4. Refresh the firmware's games list if necessary and launch **Residual** from Ports.

Typical final data locations:

| Firmware | Required game file |
| --- | --- |
| muOS | `<SD card>/ports/residual/residual.jar` |
| R36S / ArkOS-style layout | `<ports directory>/residual/residual.jar` |
| Other PortMaster firmware | The installed `residual` folder inside its ports directory |

For manual installation, extract the ZIP into the firmware's ports directory so `Residual.sh` sits beside `residual/`. On muOS, put `Residual.sh` in `<SD card>/roms/PORTS/` and the `residual` folder in `<SD card>/ports/` on the same card. Preserve `residual/saves/` when updating. Linux filenames are case-sensitive: use lowercase **residual.jar**.

## Controls

| Button | Action |
| --- | --- |
| D-pad / left stick | Move and navigate |
| A | Action / confirm |
| B | Jump / up |
| X | Inventory |
| Y | Visor |
| L1 | Inventory |
| R1 | Action / confirm |
| L2 | Visor |
| R2 | Down / descend |
| Start | O / Options |
| Select | Pause / back |
| Start + Select | PortMaster exit shortcut |

Keep the game's default keyboard bindings. Use the game's save/quit option before exiting to retain planet progress.

## Display and saves

The launcher uses PortMaster's screen dimensions. Scaling handles **640x480**, **720x480**, **720x720**, **1024x768**, **1280x720** and other valid display sizes while preserving aspect ratio. The host caps updates at 60 per second. If automatic sizing is wrong, put `WIDTHxHEIGHT`, for example `720x480`, in `residual/resolution.txt`; use `auto` or remove that file to restore detection.

Saves and settings are kept in `residual/saves/`, temporary files in `residual/cache/`, and startup output in `residual/log.txt`.

## Compile

Install **Python 3.9 or newer** and a **JDK 17 or newer**, then download or clone this source and open a terminal at its root (the folder containing `src`, `tools` and `package`). The original game JAR is not needed to compile or package the port. The first full build downloads two open-source libGDX 1.13.1 JARs from Maven Central and checks their pinned SHA-256 hashes. No cross compiler, Maven or Gradle installation is needed.

Windows PowerShell:

```powershell
python tools/build.py --jdk 'C:\Program Files\Java\jdk-17'
```

Linux (replace the path with your installed JDK):

```sh
python3 tools/build.py --jdk /path/to/jdk-17
```

The build compiles the adaptation from `src/` and produces only **`dist/Residual.zip`**. Small compile-only API declarations in `compile-api/` describe the game classes used by the host. They contain no game implementation and are excluded from the host and ZIP, as are the downloaded build dependencies. At runtime the real game classes come from the player's own `residual.jar`. Java bytecode is architecture-independent; the supplied game natives and runtime target ARM64. A build on Windows can therefore produce the same handheld package as a build on Linux.

After the first full build, `python tools/build.py --jdk /path/to/jdk-17 --offline` rebuilds using the cached dependencies in `build/dependencies/`. A fresh offline build needs both checksum-matching dependency JARs placed there first. The optional `--game-jar` argument only checks a supplied game file's fingerprint; it is never used as the compiler classpath.

After changing only the launcher, mappings or documentation, reuse the compiled host:

```sh
python tools/build.py --package-only
python tools/verify_package.py
python tools/verify_portmaster.py
bash tests/verify_display.sh
bash tests/verify_launcher.sh
```

Both build modes also verify the archive. `package/` holds the public packaging inputs; `ports/residual/` is the generated PortMaster repository layout. Build intermediates, compiled JARs, saves and `dist/` are ignored by Git. Upload the source files directly to your source repository. The build neither publishes files nor creates additional ZIP variants.

Device test status and desktop evidence are recorded in [VALIDATION.md](VALIDATION.md). The Discord testing post is [testing_thread.txt](testing_thread.txt).
