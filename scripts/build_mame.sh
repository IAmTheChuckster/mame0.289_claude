#!/bin/sh
# Rebuild bin/cv1k from MAME source (default tag mame0289) with akatana and ddpsdoj re-enabled
# and the custom matsuri15 set (Mushihime-Sama Matsuri 1.5, clone of mushisam) added.
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
make USE_QTDEBUG=0 SUBTARGET=cv1k SOURCES=src/mame/cave/cv1k.cpp,src/mame/cave/cv1k_v.cpp,src/mame/cave/cv1k_v_blit0.cpp,src/mame/cave/cv1k_v_blit1.cpp,src/mame/cave/cv1k_v_blit2.cpp,src/mame/cave/cv1k_v_blit3.cpp,src/mame/cave/cv1k_v_blit4.cpp,src/mame/cave/cv1k_v_blit5.cpp,src/mame/cave/cv1k_v_blit6.cpp,src/mame/cave/cv1k_v_blit7.cpp,src/mame/cave/cv1k_v_blit8.cpp NO_USE_PORTAUDIO=1 NO_USE_PIPEWIRE=1 NOWERROR=1 REGENIE=1 OPTIMIZE=2 SYMBOLS=0 -j"$(nproc)"
cp cv1k "$HERE/bin/cv1k"
strip "$HERE/bin/cv1k"   # drop debug info: ~67 MB -> ~46 MB
