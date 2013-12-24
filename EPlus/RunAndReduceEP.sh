#! /bin/bash

# set -x

bin=$(cd $(dirname $0); pwd)
source $bin/setenv.sh

PATH=$ENERGYPLUS_DIR:$PATH

usage="$0 --app app_tar_URL --imf configfile --epw weatherfile --outall tarfile --outxml xmlfile --outjson jsonfile --params name value ..."

while [ $# -gt 0 ]; do
  case $1 in
    --imf) imf=$2; shift 2;;
    --epw) epw=$2; shift 2;;
    --app) app=$2; shift 2;;
    --outall) outall=$2; shift 2;;
    --outxml) outxml=$2; shift 2;;
    --outjson) outjson=$2; shift 2;;
    --params) shift 1;
        while [ $# -gt 0 ] && ! echo $1 | grep -q -- -- ; do
          pname=$1
          pval=$2
          shift 2
          sed -i -e "/##set1 $pname\[\]/s/\[\].*/\[\] $pval/" $imf
        done
        ;;
    *) echo $usage 1>&2
     exit 1;;
  esac
done

runenergyplus $imf $epw
RC=$?

if [ $RC = 0 ]; then

  echo Energy Plus application completed: RC=0

  $NODE_DIR/node $bin/parse.js eplustbl.xml $outjson
  RC=$?
  cp eplustbl.json $outjson

  if [ $RC != 0 ]; then
    echo Postprocessing script failed: RC=$RC
  else
    echo Postprocessing script completed: RC=$RC
  fi
else
  echo Energy Plus application failed: RC=$RC
fi

cp eplustbl.xml $outxml
tar zcf $outall *

exit $RC
