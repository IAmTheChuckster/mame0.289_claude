#!/bin/sh
# Rebuild bin/cv1k from MAME source (default tag mame0289) with akatana and ddpsdoj re-enabled.
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
TAG=${1:-mame0289}; DIR=${2:-$HOME/mame-src}
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
open(p,'w').write(s)
l='src/mame/mame.lst'; t=open(l).read()
if '\nakatana\n' not in t:
    t=t.replace('@source:cave/cv1k.cpp\n','@source:cave/cv1k.cpp\nakatana\nddpsdoj\n')
    open(l,'w').write(t)
PY
make USE_QTDEBUG=0 SUBTARGET=cv1k SOURCES=src/mame/cave/cv1k.cpp,src/mame/cave/cv1k_v.cpp,src/mame/cave/cv1k_v_blit0.cpp,src/mame/cave/cv1k_v_blit1.cpp,src/mame/cave/cv1k_v_blit2.cpp,src/mame/cave/cv1k_v_blit3.cpp,src/mame/cave/cv1k_v_blit4.cpp,src/mame/cave/cv1k_v_blit5.cpp,src/mame/cave/cv1k_v_blit6.cpp,src/mame/cave/cv1k_v_blit7.cpp,src/mame/cave/cv1k_v_blit8.cpp NO_USE_PORTAUDIO=1 NO_USE_PIPEWIRE=1 NOWERROR=1 REGENIE=1 OPTIMIZE=2 SYMBOLS=0 -j"$(nproc)"
cp cv1k "$HERE/bin/cv1k"
