# MAME 0.289 headless test environment

Small MAME 0.289 builds (Linux x86-64), one per driver in `bin/`, plus scripts for scripted, headless runs,
for private testing with your own dumps. No ROM data is included.

## Supported
- **CV1000 driver** (`bin/cv1k`): all CV1000 sets (mmpork, dfkbl, deathsml, pinkswts, ibarablk, ...), plus `akatana`, `ddpsdoj`
  and `matsuri15` (Mushihime-Sama Matsuri 1.5, custom set)
- **68000 Cave driver** (`bin/cave`): dfeveron (Dangun Feveron), feversos and the other sets in MAME's `cave.cpp`
- **Toaplan Batsugun driver** (`bin/batsugun`): `batsugunsp` (Batsugun Special Version), `batsugun` and the other sets in MAME's `toaplan/batsugun.cpp`.
  `batsugunsp` needs the parent `batsugun` files too: either inside `batsugunsp.zip` or as a separate `batsugun.zip`.

The scripts pick the right binary for `GAME` automatically (or set `DRIVER=cv1k` / `DRIVER=cave` / `DRIVER=batsugun`).

## ROMs
Put your sets in `roms/` as `<set>.zip`, `<set>.7z` or folders `roms/<set>/`.
List a set's files and checksums with `bin/<driver> -listroms <set>`; check a dump with `bin/<driver> -verifyroms <set> -rompath roms`.

## Use
```sh
export GAME=<set> ROMPATH=$PWD/roms
scripts/boot_test.sh 1500           # run 1500 frames, PNG every 100 frames -> work/snap/<set>/
BT_SCHED=work/example_sched.txt BT_SNAP=50 scripts/run.sh 3000   # scripted inputs
BT_SAVE=2400:stage1 scripts/run.sh 2400                          # save a state at frame 2400
STATE=stage1 BT_DUMP=0c000000:100000 scripts/run.sh 600          # load it, dump RAM each frame -> work/dump.bin
scripts/debug_trace.sh 'wpset 0c001234,4,w,1,{logerror "pc=%08x\n",pc;go}' 2000   # -> work/error.log
```
Boot twice on a fresh `work/`: the first boot initialises EEPROM/NAND ("wait a moment").

Schedule files: one line per change, `frame tokens`, held until the next line; `-` = release all.
Tokens: `U D L R` stick, `A B C Q` buttons 1-4, `K` coin, `V` service coin, `S` 1P start, `T` 2P start, `X` service mode.

## RAM addresses
- CV1000-D: 16 MB at 0x0C000000-0x0CFFFFFF
- CV1000-B: 8 MB at 0x0C000000-0x0C7FFFFF
- 68000 Cave (dfeveron): 64 KB at 0x100000-0x10FFFF (e.g. `BT_DUMP=100000:10000`); buttons 1-3 only
- Toaplan Batsugun: 64 KB 68000 RAM at 0x100000-0x10FFFF (e.g. `BT_DUMP=100000:10000`); buttons 1-3 only

## Requirements / rebuild
If a binary won't start, install the libraries in `bin/apt_packages.txt`, or rebuild from source
(needs git, gcc, python3, libsdl2-dev, libfontconfig-dev; ~30 min on 2 cores per driver):
```sh
scripts/build_mame.sh          # all drivers
scripts/build_mame.sh cave     # just one, -> bin/cave
```
To add a driver, add a line with its name and source files to the `case` in `scripts/build_mame.sh`.

## Testing
Tested working with WSL Ubuntu-24.04
1. Copy the rom to <code>&#92;&#92;wsl$&#92;Ubuntu-24.04&#92;home&#92;<b>user</b>&#92;mame&#92;roms</code>
2. run <code>chmod +x ~/mame/bin/* ~/mame/scripts/*.sh</code> to make the program runnable again
3. run <code>cd ~/mame && GAME=<b>name of rom</b> scripts/boot_test.sh 1500</code>
4. screenshots are in `mame/work/snap/rom/`

## Credits
- [IAmTheChuckster](https://github.com/IAmTheChuckster): project owner
- [Claude](https://claude.ai) (Anthropic): build, harness and scripts
- Built on [MAME](https://github.com/mamedev/mame) 0.289 by the MAME team (GPL-2.0)
