#! /bin/sh

set -x

export SWIFT_USERHOME=$PWD/swifthome
export GLOBUS_TCP_SOURCE_RANGE=60000,61000
export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE

swift -config cf -sites.file sites.beagle.xml -tc.file apps sweep3.swift $*
