#! /bin/sh

set -x

if uname -r | grep -qi cray; then
  export SWIFT_USERHOME=$PWD/swifthome
  export GLOBUS_TCP_SOURCE_RANGE=60000,61000
  export GLOBUS_TCP_PORT_RANGE=$GLOBUS_TCP_SOURCE_RANGE
  export SWIFT_HEAP_MAX=4G
fi


cat >apps <<END
beagle sh    /bin/sh
beagle RunEP $PWD/RunAndReduceEP.sh
END

cat >cf <<END
tc.file=apps
sites.file=sites.xml
use.provider.staging=true
provider.staging.pin.swiftfiles=true
wrapperlog.always.transfer=false
sitedir.keep=false
execution.retries=2
lazy.errors=true
use.wrapper.staging=false
END

cat >sites.xml <<END
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns="http://www.ci.uchicago.edu/swift/SwiftSites">
<pool handle="beagle">
 <execution provider="coaster" jobmanager="local:pbs" />
 <filesystem provider="local" />
 <profile namespace="globus" key="jobsPerNode">24</profile>
 <profile namespace="globus" key="lowOverAllocation">100</profile>
 <profile namespace="globus" key="highOverAllocation">100</profile>
 <profile namespace="globus" key="providerAttributes">pbs.aprun;pbs.mpp;depth=24</profile>
 <profile namespace="globus" key="maxtime">7200</profile>
 <profile namespace="globus" key="project">CI-SES000031</profile>
 <profile namespace="globus" key="maxWalltime">00:20:00</profile>
 <profile namespace="globus" key="queue">batch</profile>
 <profile namespace="globus" key="userHomeOverride">$PWD</profile>
 <profile namespace="globus" key="slots">20</profile>
 <profile namespace="globus" key="maxnodes">10</profile>
 <profile namespace="globus" key="nodeGranularity">1</profile>
 <profile namespace="karajan" key="jobThrottle">180</profile>
 <profile namespace="karajan" key="initialScore">10000</profile>
 <!-- <profile namespace="globus" key="workerLoggingLevel">DEBUG</profile> -->
 <!--<workdirectory>$PWD/swiftwork</workdirectory>-->
 <workdirectory>/dev/shm/$USER/swiftapp</workdirectory>
</pool>
</config>
END

swift -config cf sweep7.swift $*
