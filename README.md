# CV1000 headless MAME test environment (MAME 0.289)

A CV1000-only MAME 0.289 build (`bin/cv1k`, Linux x86-64) with **Akai Katana (`akatana`)** and
**DoDonPachi SaiDaiOuJou (`ddpsdoj`)** re-enabled, plus scripts for scripted, headless runs.
Both sets were removed from upstream MAME in Dec 2021 at the rights holder's request; this build
re-enables the existing driver entries for private testing with your own dumps. No ROM data is included.
All other CV1000 sets (mmpork, dfkbl, deathsml, pinkswts, ibarablk, ...) work too.

## ROMs
Put your sets in `roms/` as `akatana.zip` / `ddpsdoj.zip` (or folders `roms/akatana/`). Files and CRC32s:

| set | u4 | u2 | u23 | u24 |
|---|---|---|---|---|
| akatana | 613fd380 | 89a2e1a5 | 34a67e24 | 10760fed |
| ddpsdoj | e2a4411c | 668e4cd6 | ac94801c | f593045b |

Check with `bin/cv1k -verifyroms akatana -rompath roms`.

## Use
```sh
export GAME=akatana ROMPATH=$PWD/roms
scripts/boot_test.sh 1500           # run 1500 frames, PNG every 100 frames -> work/snap/akatana/
BT_SCHED=work/example_sched.txt BT_SNAP=50 scripts/run.sh 3000   # scripted inputs
BT_SAVE=2400:stage1 scripts/run.sh 2400                          # save a state at frame 2400
STATE=stage1 BT_DUMP=0c000000:100000 scripts/run.sh 600          # load it, dump RAM each frame -> work/dump.bin
scripts/debug_trace.sh 'wpset 0c001234,4,w,1,{logerror "pc=%08x\n",pc;go}' 2000   # -> work/error.log
```
Boot twice on a fresh `work/`: the first boot initialises EEPROM/NAND ("wait a moment").

Schedule files: one line per change, `frame tokens`, held until the next line; `-` = release all.
Tokens: `U D L R` stick, `A B C Q` buttons 1-4, `K` coin, `V` service coin, `S` 1P start, `T` 2P start, `X` service mode.

Both games are CV1000-D (4 MB u4, 16 MB RAM at 0x0C000000-0x0CFFFFFF). Akai Katana is ROT0, SaiDaiOuJou ROT270.

## Requirements / rebuild
If `bin/cv1k` won't start, install the libraries in `bin/apt_packages.txt`, or rebuild from source with
`scripts/build_mame.sh mame0289` (needs git, gcc, python3, libsdl2-dev, libfontconfig-dev; ~30 min on 2 cores).
