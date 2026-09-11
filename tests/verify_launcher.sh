#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
fixture=$(mktemp -d)
export TEST_ROOT="$fixture"
mkdir -p "$fixture/home/.local/share/PortMaster/libs" "$fixture/ports/residual" "$fixture/probes"
cp package/residual/display.inc package/residual/residual.ini "$fixture/ports/residual/"
sed "s|/tmp/residual-weston|$fixture/weston|g; s|/tmp/residual-java|$fixture/java|g" package/Residual.sh > "$fixture/ports/Residual.sh"
cat > "$fixture/home/.local/share/PortMaster/control.txt" <<'CONTROL'
get_controls() { :; }
pm_message() { echo "$*"; }
pm_finish() { echo finish >> "$TEST_ROOT/events"; }
pm_platform_helper() { echo platform >> "$TEST_ROOT/events"; }
getconf() { echo 64; }
sleep() { :; }
mount() {
  mkdir -p "$2/bin"
  if [[ "$1" == *weston* ]]; then
    cp "$TEST_ROOT/probes/westonwrap.sh" "$2/westonwrap.sh"
  else
    cp "$TEST_ROOT/probes/java" "$2/bin/java"
  fi
  echo mount >> "$TEST_ROOT/events"
}
umount() { echo unmount >> "$TEST_ROOT/events"; }
ESUDO=
GPTOKEYB2="env TEST_MAPPER=1 $TEST_ROOT/probes/mapper"
directory="$TEST_ROOT"
DEVICE_ARCH=aarch64
PM_CAN_MOUNT=Y
CFW_NAME=test
DISPLAY_WIDTH=720
DISPLAY_HEIGHT=480
sdl_controllerconfig=test-controller
CONTROL
cat > "$fixture/probes/java" <<'JAVA'
#!/bin/bash
[[ "${TEST_BAD_JAR:-0}" == 0 ]]
JAVA
cat > "$fixture/probes/mapper" <<'MAPPER'
#!/bin/bash
[[ "$TEST_MAPPER" == 1 && "$1" == java && "$2" == -c && "$3" == */residual.ini ]] || exit 2
echo mapper >> "$TEST_ROOT/events"
MAPPER
cat > "$fixture/probes/westonwrap.sh" <<'WESTON'
#!/bin/bash
if [[ "$1" == cleanup ]]; then
  echo cleanup >> "$TEST_ROOT/events"
else
  [[ "$1 $2 $3 $4" == 'headless noop kiosk crusty_glx_gl4es' ]] || exit 3
  [[ "$WESTON_HEADLESS_WIDTH" == 720 && "$WESTON_HEADLESS_HEIGHT" == 480 ]] || exit 4
  [[ "$*" == *'-Dresidual.width=720'* && "$*" == *'-Dresidual.height=480'* ]] || exit 5
  echo game >> "$TEST_ROOT/events"
  exit "${TEST_GAME_STATUS:-0}"
fi
WESTON
chmod +x "$fixture/probes/"*
touch "$fixture/home/.local/share/PortMaster/libs/weston_pkg_0.2.squashfs"
touch "$fixture/home/.local/share/PortMaster/libs/zulu17.54.21-ca-jre17.0.13-linux.squashfs"
run_launcher() {
  HOME="$fixture/home" XDG_DATA_HOME="$fixture/home/.local/share" bash "$fixture/ports/Residual.sh"
}
if run_launcher; then echo 'Accepted missing game data'; exit 1; fi
grep -q finish "$fixture/events"
! grep -q mount "$fixture/events"
: > "$fixture/events"
touch "$fixture/ports/residual/residual.jar"
run_launcher
[[ "$(grep -c '^mount$' "$fixture/events")" == 2 ]]
[[ "$(grep -c '^unmount$' "$fixture/events")" == 2 ]]
grep -q '^game$' "$fixture/events"
grep -q '^cleanup$' "$fixture/events"
grep -q '^platform$' "$fixture/events"
grep -q '^finish$' "$fixture/events"
: > "$fixture/events"
if TEST_GAME_STATUS=9 run_launcher; then echo 'Ignored game failure'; exit 1; fi
grep -q '^cleanup$' "$fixture/events"
grep -q '^finish$' "$fixture/events"
! grep -q '^unmount$' "$fixture/events"
: > "$fixture/events"
if TEST_BAD_JAR=1 run_launcher; then echo 'Ignored JAR verification failure'; exit 1; fi
grep -q '^finish$' "$fixture/events"
! grep -q '^game$' "$fixture/events"
printf 'LAUNCHER_MOCK_OK: missing data, runtime mounts, display arguments, game failure, reused mounts, validation failure and cleanup\n'
printf 'Temporary test fixture: %s\n' "$fixture"
