#! /bin/bash

set -x

export OSG_WN_TMP=/dev/shm/wilde/tmp
mkdir -p $OSG_WN_TMP

httpget()
{
  if which wget >& /dev/null; then
    wget $1
  elif which curl >& /dev/null; then
    curl $1 > $(basename $1)
  else
    echo "$0: ERROR: Can not locate wget or curl to download app."
    exit 1
  fi
} 

installApp()
{
  httpget $app
  tar zxf $apptar
}

process_EP_params()
{
  while [ $# -gt 0 ] && ! echo $1 | grep -q -- -- ; do
    pname=$1
    pval=$2
    shift 2
    # sed -i $f -e "/^$pname/s|=.*|=$pval|g"
    sed -i -e "/##set1 $pname\[\]/s/\[\].*/\[\] $pval/" $imf
  done
}

echo starting

usage="$0 --app app_tar_URL --imf configfile --epw weatherfile --out out_tar --params name value ..."


while [ $# -gt 0 ]; do
  case $1 in
    --imf) imf=$2; shift 2;;
    --epw) epw=$2; shift 2;;
    --app) app=$2; shift 2;;
    --out) out=$2; shift 2;;
    --outxml) outxml=$2; shift 2;;
    --params) shift 1; # process_EP_params $*;;
        while [ $# -gt 0 ] && ! echo $1 | grep -q -- -- ; do
          pname=$1
          pval=$2
          shift 2
          # sed -i $f -e "/^$pname/s|=.*|=$pval|g"
          sed -i -e "/##set1 $pname\[\]/s/\[\].*/\[\] $pval/" $imf
        done
        ;;
    *) echo $usage 1>&2
     exit 1;;
  esac
done

apptar=$(basename $app)
TASKDIR=$PWD
WORKDIR=$(mktemp -d $OSG_WN_TMP/RunEP.XXXXXX)
ABSOUT=$(cd $(dirname $out); pwd)/$(basename $out)
ABSXML=$(cd $(dirname $outxml); pwd)/$(basename $outxml)
cp $imf $WORKDIR
cp $epw $WORKDIR

cd $WORKDIR
#installApp

export ENERGYPLUS_DIR=/lustre/beagle/ketan/EPlus/EnergyPlus-8-0-0/bin
PATH=$ENERGYPLUS_DIR:$PATH

runenergyplus $imf $epw
RC=$?
cd Output
tar zcf $ABSOUT *
cp $WORKDIR/eplustbl.xml $ABSXML

cd $WORKDIR
rm -rf $WORKDIR
exit $RC

installSharedApp()
{
  # FIXME: Complete this logic:
  SCRATCH=$OSG_SCRATCH # FIXME
  installDir=$SCRATCH
  tempDir=$installDir.lock
  WAITTIME=5

  if [ ! -d $installDir ]; then
    if [ mkdir $tempDir ]; then
      httpget 
      extract
      mv $tempDir $installDir
    else
      for try in 1 2 3; do
        sleep $WAITTIME
      done
    fi
  fi
}

        
