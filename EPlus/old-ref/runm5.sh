#! /bin/sh

set -x

export SWIFT_USERHOME=$PWD/swifthome
export GLOBUS_TCP_SOURCE_RANGE=60000,61000
export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE

# Full param set

cat >params <<END
pnum pname        pvals
1    ORIENT       0,30,60
2    NumberFloors 5,10,15,20
3    W            10,20,30,40
4    L            10,20,30,40
5    WINTOP       1.8,2.5,3.5
6    HVACSystem   SYSTEM7,OptimizedVAV,DOASFCU,DOASECMFCU
7    ENDMONTH     1
8    ENDDAY       31
END

# Test param set

cat >params <<END
pnum pname        pvals
1    ORIENT       0,30
2    NumberFloors 5,10
3    W            10,20
4    L            10,20,30
5    WINTOP       1.8,2.5
6    HVACSystem   SYSTEM7,OptimizedVAV
7    ENDMONTH     2
8    ENDDAY       28
END

cat >params <<END  # 3*4*4*4*3*4
pnum pname        pvals
1    ORIENT       0,30,60
2    NumberFloors 5,10,15,20
3    W            10,20,30,40
4    L            10,20,30,40
5    WINTOP       1.8,2.5,3.5
6    HVACSystem   SYSTEM7,OptimizedVAV,DOASFCU,DOASECMFCU
7    ENDMONTH     2
8    ENDDAY       28
END

SWIFT_HEAP_MAX=4G swift -config cf -sites.file sites.beagle.xml -tc.file apps sweep6.swift $* # -epconfig=SWEEP_RECT.imf -epweather=CHICAGO.epw
