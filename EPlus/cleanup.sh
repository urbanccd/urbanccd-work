#!/bin/bash

# rm -rf *.log *.rlog *.d sweep1-*-*-* *.kml *.swiftx *.out output outdir logs hw.* _concurrent .swift/tmp

echo "stopping coaster service"

PATH=/glusterfs/users/swiftlang/swift-0.94.1/bin:$PATH

stop-coaster-service
