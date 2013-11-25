# export ENERGYPLUS_DIR=$bin/../EnergyPlus-8-0-0/bin

if [ -d /lustre/beagle ]; then     # UChicago Cray "Beagle"

  export ENERGYPLUS_DIR=/lustre/beagle/wilde/EnergyPlus-8-0-0/bin
  export NODE_DIR=/lustre/beagle/ketan/node-v0.10.20-linux-x64/bin

elif [ -d /glusterfs/users ]; then # Open Science Data Cloud

  export ENERGYPLUS_DIR=/root/EPlus/EnergyPlus-8-0-0/bin
  export NODE_DIR=/root/node-v0.10.20-linux-x64/bin

else

  echo setenv.sh: ERROR: Unknown system. Exiting.
  exit 1

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
