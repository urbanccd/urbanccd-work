#! /bin/sh

installSharedApp()
{
  SCRATCH=/dev/shm/$USER/tmp
  installDir=$SCRATCH/myapp

  mkdir -p $installDir

  tempDir=$installDir.lock
  WAITTIME=5

  if [ ! -d $installDir ]; then
    if [ mkdir $tempDir ]; then  # only one process could get here
      dd if=$PACKAGE of=$(basename $PACKAGE) bs=8M # get the package
      tar zxf $PACKAGE # extract
      mv $tempDir $installDir
    else
      for waittry in 1 2 3; do
        process $$ waittry $waittry
        sleep $WAITTIME
      done
    fi
  fi
}
