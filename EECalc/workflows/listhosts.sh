echo $(nova list | grep LakeSim | sed -e 's/^.*=//' -e 's/ .*//')
