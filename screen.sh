#!/bin/sh
#
# Small script to turn the screen on and off on the Raspberry Pi
#
# Based on https://www.raspberrypi.org/forums/viewtopic.php?f=64&t=7570
#

tvservice() {
    /opt/vc/bin/tvservice $@ >/dev/null
}

if [ `id -u` != 0 ]; then
	echo "Please run as root: sudo $0" 1>&2
	exit 1
fi

case "$1" in
    off)
        tvservice -o
        ;;
    on)
        tvservice -p
        VC=`sudo fgconsole`
        sudo chvt 1
        sudo chvt $VC
        ;;
    *)
        echo "Usage: $0 on|off" 1>&2
        exit 1
        ;;
esac
