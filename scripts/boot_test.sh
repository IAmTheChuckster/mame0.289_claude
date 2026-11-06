#!/bin/sh
# Usage: GAME=ddpsdoj scripts/boot_test.sh [frames]   -> snapshots every 100 frames in work/snap/<game>/
cd "$(dirname "$0")/.."
BT_SNAP=${BT_SNAP:-100} scripts/run.sh "${1:-1500}"
ls work/snap/"$GAME" 2>/dev/null | tail -3
