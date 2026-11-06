#!/bin/sh
# Usage: GAME=akatana scripts/debug_trace.sh 'wpset 0c001234,4,w,1,{logerror "pc=%08x\n",pc;go}' [frames]
# Runs the MAME debugger headless with the given command; output in work/error.log
cd "$(dirname "$0")/.."
printf '%s\ngo\n' "$1" > work/dbg.txt
scripts/run.sh "${2:-3000}" -debug -debugger none -debugscript work/dbg.txt -log -oslog > work/error.log 2>&1
grep -c . work/error.log
