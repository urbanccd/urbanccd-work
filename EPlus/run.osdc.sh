#! /bin/sh

# set -x

export SWIFT_HEAP_MAX=4G

cat >apps <<END
persistent-coasters sh    /bin/sh
persistent-coasters RunEP $PWD/RunAndReduceEP.sh null null GLOBUS::maxwalltime="00:20:00"
END

cat >cf <<END
tc.file=apps
sites.file=sites.xml
use.provider.staging=true
provider.staging.pin.swiftfiles=false
wrapperlog.always.transfer=false
sitedir.keep=false
execution.retries=0
lazy.errors=false
use.wrapper.staging=false
END

PATH=/glusterfs/users/swiftlang/swift-0.94.1/bin:$PATH

swift -config cf sweep7.swift $*
