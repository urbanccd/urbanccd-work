#! /bin/sh

SCRIPT=$(cd $(dirname $0); /bin/pwd)

octave --no-window-system --path $SCRIPT $SCRIPT/run_building_sweep.m $*
