#! /bin/sh

# FIXME: NOT YET TESTED!

SCRIPT=$(cd $(dirname $0); /bin/pwd)

octave --no-window-system --path $SCRIPT $SCRIPT/save_weather.m $*
