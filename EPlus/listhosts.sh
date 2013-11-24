echo $(nova list | grep Lake0 | sed -e 's/^.*=//' -e 's/ .*//')
