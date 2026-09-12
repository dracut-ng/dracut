#!/bin/sh
# live .iso images are specified as
# iso-scan/filename=[<devspec>:]<filepath>

isopath=$(getarg iso-scan/filename)

[ "$isopath" ] && /sbin/initqueue --settled --unique /sbin/iso-scan "$isopath"
