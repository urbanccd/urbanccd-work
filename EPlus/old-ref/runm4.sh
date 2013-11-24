#! /bin/sh

set -x

export SWIFT_USERHOME=$PWD/swifthome
export GLOBUS_TCP_SOURCE_RANGE=60000,61000
export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE

swift -config cf -sites.file sites.debug.xml -tc.file apps sweepm4.swift $*

# -orientation=0 -height=5 -width=10 -length-10 -wwr=1.8 -system=SYSTEM7

# 

: <<ENDCOMMENT

-orientation=0,20,40
-height=5
-width=10,20
-length-10,20
-wwr=1.8
-system=SYSTEM7

-epconfig=SWEEP_RECT.imf
-epweather=CHICAGO.epw

ENDCOMMENT
