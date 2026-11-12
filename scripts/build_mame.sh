#!/bin/sh
# Usage: scripts/build_mame.sh [driver|all] [tag] [source dir]
# Builds one MAME binary per driver into bin/<driver> (default: all drivers, tag mame0289).
#   cv1k : CV1000 driver, with akatana and ddpsdoj re-enabled and the custom matsuri15 set added
#   cave : MAME's older 68000-based Cave driver (dfeveron, feversos, ...)
#   batsugun : Toaplan's Batsugun (batsugun, batsugunsp Special Version, ...)
# To add a driver: add a line to the case below with its name and its source files.
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
case "$1" in mame*) set -- all "$@";; esac   # old usage: build_mame.sh <tag>
DRIVER=${1:-all}; TAG=${2:-mame0289}; DIR=${3:-$HOME/mame-src}
DRIVERS="cv1k cave batsugun"
CV1K_V=src/mame/cave/cv1k_v.cpp; for i in 0 1 2 3 4 5 6 7 8; do CV1K_V=$CV1K_V,src/mame/cave/cv1k_v_blit$i.cpp; done
case "$DRIVER" in
  all)  for d in $DRIVERS; do sh "$0" "$d" "$TAG" "$DIR"; done; exit 0;;
  cv1k) SOURCES=src/mame/cave/cv1k.cpp,$CV1K_V;;
  cave) SOURCES=src/mame/atlus/cave.cpp,src/mame/atlus/cave_v.cpp,src/mame/atlus/sprite013.cpp;;
  batsugun) SOURCES=src/mame/toaplan/batsugun.cpp,src/mame/toaplan/gp9001.cpp,src/mame/toaplan/toaplan_coincounter.cpp;;
  *)    echo "unknown driver '$DRIVER' (known: $DRIVERS, all)" >&2; exit 1;;
esac
[ -d "$DIR" ] || git clone --depth 1 --branch "$TAG" https://github.com/mamedev/mame.git "$DIR"
cd "$DIR"
python3 - <<'PY'
p='src/mame/cave/cv1k.cpp'; s=open(p).read()
m='#if 0 // not included in MAME, see driver notes'
if m in s:
    a=s.index(m); b=s.index('#endif',a)
    s=s[:a]+'// re-enabled locally'+s[a+len(m):b]+s[b+len('#endif'):]
for g in ('akatana','ddpsdoj'):
    s=s.replace('//GAME( 2010, '+g,'GAME( 2010, '+g).replace('//GAME( 2012, '+g,'GAME( 2012, '+g)
# matsuri15: Mushihime-Sama Matsuri 1.5 (custom set), clone of mushisam on the same CV1000-B hardware
if 'ROM_START( matsuri15 )' not in s:
    import re
    roms={'mushisam_u4':('matsuri15_u4','6af99f0e','e91b3a7c329a9ce66687b48a9f2e1a8ea7282cd5'),
          'mushisam_u2':('matsuri15_u2','fbc6f3c1','9967c56121a2886261026665d9f64978f2cb4dda'),
          'u23':('u23','6dff634f','781042316fae904657326189b3b46e49a46ba675'),
          'u24':('u24','f228b801','b9dd2a7462ccad4b20b8cd7eaefcdfd881dd413f')}
    a=s.index('ROM_START( mushisam )'); b=s.index('ROM_END',a)+len('ROM_END')
    def fix(x):
        n,c,h=roms[x.group(1)]
        return '"%s"%sCRC(%s) SHA1(%s)'%(n,x.group(2),c,h)
    blk,n=re.subn(r'"([^"]+)"(, 0x[0-9a-fA-F]+, 0x[0-9a-fA-F]+, )CRC\([0-9a-f]{8}\) SHA1\([0-9a-f]{40}\)',fix,s[a:b])
    assert n==4, 'mushisam ROM block not as expected'
    blk=blk.replace('ROM_START( mushisam )','ROM_START( matsuri15 )').replace('// (2004/10/12.MASTER VER.)','// Matsuri 1.5')
    s=s[:b]+'\n\n'+blk+s[b:]
    g=s.index('GAME( 2004, mushisam,'); e=s.index('\n',g)
    line=re.sub(r'^GAME\( 2004, mushisam,\s+0,\s+','GAME( 2004, matsuri15,  mushisam, ',s[g:e])
    line=line.replace('"Mushihime-Sama (Japan, 2004/10/12.MASTER VER.)"','"Mushihime-Sama Matsuri 1.5 (custom)"')
    assert 'matsuri15' in line and 'Matsuri 1.5' in line, 'mushisam GAME line not as expected'
    s=s[:e+1]+line+'\n'+s[e+1:]
open(p,'w').write(s)
l='src/mame/mame.lst'; t=open(l).read()
if '\nakatana\n' not in t:
    t=t.replace('@source:cave/cv1k.cpp\n','@source:cave/cv1k.cpp\nakatana\nddpsdoj\n')
if '\nmatsuri15\n' not in t:
    t=t.replace('\nmushisam\n','\nmushisam\nmatsuri15\n',1)
open(l,'w').write(t)
PY
make USE_QTDEBUG=0 SUBTARGET="$DRIVER" SOURCES="$SOURCES" NO_USE_PORTAUDIO=1 NO_USE_PIPEWIRE=1 NOWERROR=1 REGENIE=1 OPTIMIZE=2 SYMBOLS=0 -j"$(nproc)"
cp "$DRIVER" "$HERE/bin/$DRIVER"
strip "$HERE/bin/$DRIVER"   # drop debug info (cv1k: ~67 MB -> ~46 MB)
