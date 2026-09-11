#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/${directory#/}/ports/residual"
scriptdir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$scriptdir/residual" ]; then
  GAMEDIR="$scriptdir/residual"
elif [ -d "$scriptdir/../../ports/residual" ]; then
  GAMEDIR="$(cd "$scriptdir/../../ports/residual" && pwd)"
fi
cd "$GAMEDIR" || { pm_message "Residual: install the complete port package."; pm_finish; exit 1; }
mkdir -p saves cache
exec > >(tee "$GAMEDIR/log.txt") 2>&1

weston_dir=/tmp/residual-weston
export JAVA_HOME=/tmp/residual-java
mounted=()
weston_started=0
cleanup() {
  local status=$?
  trap - EXIT
  [ "$weston_started" = 1 ] && $ESUDO "$weston_dir/westonwrap.sh" cleanup
  if [ "$PM_CAN_MOUNT" != N ]; then
    for target in "${mounted[@]}"; do $ESUDO umount "$target"; done
  fi
  pm_finish
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
fail() { pm_message "Residual: $* See residual/log.txt."; sleep 5; exit 1; }
[ "$DEVICE_ARCH" = aarch64 ] || fail "64-bit ARM firmware is required."
[ "$(getconf LONG_BIT)" = 64 ] || fail "64-bit userland is required."
[ -f residual.jar ] || fail "Copy your GOG 1.4.1 residual.jar into $GAMEDIR."
[ -n "$GPTOKEYB2" ] || fail "Update PortMaster for controller support."

mount_runtime() {
  local runtime="$1" target="$2" probe="$3"
  [ -x "$target/$probe" ] && return 0
  if [ ! -f "$controlfolder/libs/$runtime.squashfs" ]; then
    $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "$runtime.squashfs" || fail "Cannot download $runtime."
  fi
  $ESUDO mkdir -p "$target"
  $ESUDO mount "$controlfolder/libs/$runtime.squashfs" "$target" || fail "Cannot mount $runtime."
  mounted+=("$target")
  [ -x "$target/$probe" ] || fail "Reinstall the $runtime runtime."
}
mount_runtime weston_pkg_0.2 "$weston_dir" westonwrap.sh
mount_runtime zulu17.54.21-ca-jre17.0.13-linux "$JAVA_HOME" bin/java
"$JAVA_HOME/bin/java" -Xmx64m -cp runtime/residual-host.jar org.portmaster.residual.VerifyGame residual.jar || fail "Unsupported or damaged game JAR. Check the README checksum."

source "$GAMEDIR/display.inc"
residual_display_setup || fail "Use auto or WIDTHxHEIGHT in resolution.txt."
printf 'Firmware: %s; display: %s\n' "$CFW_NAME" "$residual_display_description"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOTKEY=back
$GPTOKEYB2 java -c "$GAMEDIR/residual.ini" &
pm_platform_helper "$JAVA_HOME/bin/java"
weston_started=1
$ESUDO env "${display_env[@]}" "$weston_dir/westonwrap.sh" headless noop kiosk crusty_glx_gl4es \
  "PATH=$JAVA_HOME/bin:$PATH" "JAVA_HOME=$JAVA_HOME" "HOME=$GAMEDIR/saves" \
  "XDG_DATA_HOME=$GAMEDIR/saves" "XDG_CONFIG_HOME=$GAMEDIR/saves/config" \
  "XDG_CACHE_HOME=$GAMEDIR/cache" "WAYLAND_DISPLAY=" \
  "$JAVA_HOME/bin/java" -Xms32m -Xmx256m -XX:+UseSerialGC \
  "-Duser.home=$GAMEDIR/saves" "-Djava.io.tmpdir=$GAMEDIR/cache" \
  "-Dresidual.jar=$GAMEDIR/residual.jar" "-Dresidual.saves=$GAMEDIR/saves" \
  -Dresidual.fullscreen=true "${display_java[@]}" \
  -cp "$GAMEDIR/runtime/residual-host.jar:$GAMEDIR/residual.jar" org.portmaster.residual.Main
status=$?
[ "$status" = 0 ] || fail "The game exited with status $status."
