#! /bin/sh

set -x

if uname -r | grep -qi cray; then
  export SWIFT_USERHOME=$PWD/swifthome
  export GLOBUS_TCP_SOURCE_RANGE=60000,61000
  export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE
  export SWIFT_HEAP_MAX=4G
fi


cat >apps <<END
midway sh    /bin/sh
midway RunEP $PWD/RunAndReduceEP.sh
END

cat >cf <<END
tc.file=apps
sites.file=sites.xml
use.provider.staging=true
provider.staging.pin.swiftfiles=true
wrapperlog.always.transfer=false
sitedir.keep=false
execution.retries=0
lazy.errors=false
use.wrapper.staging=false
END

cat >>sites.xml <<END
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns="http://www.ci.uchicago.edu/swift/SwiftSites">
<pool handle="midway">
<execution provider="coaster" jobmanager="local:slurm" />
<filesystem provider="local" />
<profile namespace="globus" key="queue">westmere</profile>
<!-- <profile namespace="globus" key="queue">sandyb</profile> -->
<!-- <profile namespace="globus" key="queue">amd</profile> -->
<profile namespace="globus" key="jobsPerNode">8</profile>
<profile namespace="globus" key="maxtime">2400</profile>
<profile namespace="globus" key="maxWalltime">00:20:00</profile>
<profile namespace="globus" key="highOverAllocation">100</profile>
<profile namespace="globus" key="lowOverAllocation">100</profile>
<profile namespace="globus" key="slots">1</profile>
<profile namespace="globus" key="maxNodes">2</profile>
<profile namespace="globus" key="nodeGranularity">2</profile>
<profile namespace="karajan" key="jobThrottle">.2</profile>
<profile namespace="karajan" key="initialScore">10000</profile>
<workdirectory>/tmp/swift.work</workdirectory>
</pool>
</config>
END

swift -config cf sweep7.swift $*
