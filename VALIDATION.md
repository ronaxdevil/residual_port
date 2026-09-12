# Validation - Residual 0.1.0

## Input and build

All 150 supplied files were inventoried and fingerprinted. All 3,613 game JAR entries and 9 webcache ZIP entries passed CRC inspection. A final hash comparison confirmed the supplied files were unchanged. Windows executables and installers were not run.

Host compiled with JDK 26 --release 8 against the supplied original classes. Tests ran with Windows Java 17.0.20.1, a 256 MB Java heap and SerialGC. Host tests do not run the Linux ARM64 native libraries or PortMaster's Weston/gl4es stack.

## Runtime checks

Real keyboard events advanced splash/menu, character selection, planet generation, the saved-intro crash sequence, a tutorial dialog and active planet gameplay. Each resolution completed at least 240 gameplay frames. The five completed sizes were 640x480, 720x480, 720x720, 1024x768 and 1280x720. Final framebuffer PNG dimensions matched the requested output. The square and widescreen gameplay screenshots were visually reviewed alongside 640x480.

Class-load logs confirmed the optional SteamAPI, EpicGames and Jamepad ControllerManager classes were not loaded in this path. Settings were written into separate per-test saves directories. The first test's 3,600-frame limit ended during the long first-run intro; subsequent tests used the game's normally saved seen-intro preference. This was a test time limit, not a reported crash in the game.

The test harness supports a frame-cap elapsed-time assertion and optional original SaveGame/LoadGame readback with -Dresidual.testSave=true. The local run passed: slot 1 was saved and read back, and 1,107 render frames took 21.82 seconds (below the 60 updates/s ceiling). Evidence is in build/save-test.log. It does not patch player abilities, unlock content or replace the original game logic.

## Launcher and packages

The current build produces one BYO-data Residual.zip. The verifier checks the explicit
public file list, ZIP CRCs, executable permissions, LF scripts, metadata, controller
bindings and absence of the original JAR. Generated repository files are compared
byte-for-byte against the public source inputs. Bash display checks cover the five
requested sizes, extra valid sizes, precedence, invalid values and automatic fallback.

The full host build and both archive/tree validators passed on 2026-09-11.
The cached upstream PortMaster build_release.py --do-check also passed the
updated Residual tree: 1 new port, 0 broken ports, exit 0. The isolated check
log is build/packaging-check/check.log; this does not certify device operation.
Bash syntax and display checks passed. The simulated launcher test passed missing
data, runtime mounting, display arguments, game failure, reused mounts, JAR
verification failure and cleanup. These simulations substitute runtime helpers
and do not exercise a device GPU, audio or physical controller.

The controller mapping now uses gptokeyb2's INI format with the existing key bindings.
The shortened launcher retains Java/Weston runtime provisioning, data validation,
display selection and save locations. An exit trap cleans up mounted runtimes and
calls pm_finish. This launcher and mapping still require physical device testing.

## Not yet validated

No RG34XX SP, R36S or other physical handheld was connected. ARM64 native loading, Weston/gl4es rendering, controller mapping, audio quality, suspend/resume, memory use on a 1 GB device and long-session stability require device testing. A saved slot readback is not proof of full game completion or long-term save compatibility. 32-bit firmware and store/cloud integration are not supported by this package.

## Reproduce

First run tools/build.py. Then use a local Java 17 executable and JDK:

```sh
python tools/verify_resolutions.py --java /path/to/java17/bin/java --jdk /path/to/jdk --game-jar /path/to/Residual/residual.jar
```

An optional --seed-saves path copies an existing test profile to each new test folder; it can reuse a naturally recorded seen-intro setting. Outputs remain in build/resolutions and are excluded from distributed archives. GameplaySmoke.java is test-only and is never included in residual-host.jar.

## GOG data preparation

The inspected input is an installed GOG Windows 1.4.1 directory, game ID
1688702977, build ID 59032447871207888. No offline installer was supplied;
the README's installer and innoextract steps have not been exercised against
that installer. The build and launcher enforce the inspected JAR's SHA-256.

## Build without game data

On 2026-09-12 the host was compiled using only the handwritten compile-api
declarations and checksum-pinned public libGDX 1.13.1 dependencies. No original
game JAR is read by this build unless the optional fingerprint check is requested.
All four distributed host class files matched a reference build compiled against
the original game classes byte-for-byte. The package verifier confirms that no
compile-only declarations, library dependencies or original game data are shipped.
Game-dependent gameplay tests still require the owned game JAR.
