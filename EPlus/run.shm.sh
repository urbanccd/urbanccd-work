#! /bin/sh

set -x

export SWIFT_USERHOME=/lustre/beagle/$USER/swifthome
export GLOBUS_TCP_SOURCE_RANGE=60000,61000
export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE

SWIFT_HEAP_MAX=4048M swift -config cf -sites.file sites.beagle.xml -tc.file apps sweep2.swift $*
