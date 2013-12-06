#!/bin/bash

set -x
export ENERGYPLUS_DIR=$HOME/EnergyPlus-8-0-0/bin
export NODE_DIR=$HOME/node-v0.10.20-linux-x64/bin
export NODE_PATH=$HOME/node-v0.10.20-linux-x64/node_modules

if [ -d /lustre/beagle ]; then     # UChicago Cray "Beagle"

  export ENERGYPLUS_DIR=/lustre/beagle/wilde/EPlus/EnergyPlus-8-0-0/bin
  export NODE_DIR=/lustre/beagle/ketan/node-v0.10.20-linux-x64/bin
  export NODE_PATH=/lustre/beagle/wilde/EPlus/examples/node_modules
  # Load the Swift module
  module load swift

elif [ -d /glusterfs/users ]; then # Open Science Data Cloud

  export ENERGYPLUS_DIR=/root/EPlus/EnergyPlus-8-0-0/bin
  export NODE_DIR=/root/node-v0.10.20-linux-x64/bin
  export NODE_PATH=/glusterfs/users/swiftlang/node_modules

else

  echo "WARNING: This is not Beagle or OSDC, check environment before proceeding."

fi

# Check if directories accessible

echo setenv.sh: ENERGYPLUS_DIR=$ENERGYPLUS_DIR
echo setenv.sh: NODE_DIR=$NODE_DIR

if [ ! -x $ENERGYPLUS_DIR ]; then
  echo setenv.sh: ERROR: $ENERGYPLUS_DIR not found or not accessible.
  RC=1
fi

if [ ! -x $NODE_DIR ]; then
  echo setenv.sh: ERROR: $NODE_DIR not found or not accessible.
  RC=1
fi

if [ _RC = _1 ]; then
  exit 1
fi
