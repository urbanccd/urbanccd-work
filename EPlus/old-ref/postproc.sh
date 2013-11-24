#! /bin/bash

set -x

export OSG_WN_TMP=/dev/shm/wilde/tmp
mkdir -p $OSG_WN_TMP

installModule()
{
 /root/node-v0.10.20-linux-x64/bin/npm install xml2json
}

echo starting

usage="$0 --xml xmlfile --parser parserfile --outjson outjsonfile" 

while [ $# -gt 0 ]; do
  case $1 in
    --xml) xml=$2; shift 2;;
    --parser) parser=$2; shift 2;;
    --outjson) outjson=$2; shift 2;;
    *) echo $usage 1>&2
     exit 1;;
  esac
done

TASKDIR=$PWD
WORKDIR=$(mktemp -d $OSG_WN_TMP/RunEP.XXXXXX)
ABSPARSER=$(cd $(dirname $parser); pwd)/$(basename $parser)
ABSOUTJSON=$(cd $(dirname $outjson); pwd)/$(basename $outjson)
ABSXML=$(cd $(dirname $xml); pwd)/$(basename $xml)

export NODE_PATH=/lustre/beagle/wilde/EPlus/examples/node_modules  # FIXME

cd $WORKDIR
#installModule
cp $ABSPARSER parse.js
cp $ABSXML eplustbl.xml

/lustre/beagle/ketan/node-v0.10.20-linux-x64/bin/node parse.js

RC=$?
cp $WORKDIR/output.json $ABSOUTJSON

cd $WORKDIR
rm -rf $WORKDIR
exit $RC
        
