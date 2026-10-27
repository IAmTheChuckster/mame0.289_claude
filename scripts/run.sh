#!/bin/sh
# Usage: GAME=akatana scripts/run.sh [frames] [extra mame args...]
# Env: ROMPATH, BT_SCHED, BT_SNAP, BT_SAVE, BT_DUMP, STATE (load state name)
set -e
cd "$(dirname "$0")/.."
: "${GAME:?set GAME=akatana or GAME=ddpsdoj}"
FRAMES=${1:-3000}; [ $# -gt 0 ] && shift
export BT_FRAMES=$FRAMES
mkdir -p work/snap work/nvram work/sta work/cfg
LOAD=""; [ -n "$STATE" ] && LOAD="-state $STATE"
exec bin/cv1k "$GAME" -rompath "${ROMPATH:-$PWD/roms}" \
  -video none -sound none -nothrottle -skip_gameinfo -window \
  -snapshot_directory work/snap -nvram_directory work/nvram -state_directory work/sta \
  -cfg_directory work/cfg -seconds_to_run 0 \
  -autoboot_script lua/harness.lua $LOAD "$@"
