#!/bin/sh
# live .iso images are specified as
# iso-scan/filename=[<devspec>:]<filepath>

isospec=$(getargs iso-scan/devspec iso-scan/filename)

[ "$isospec" ] && /sbin/initqueue --settled --unique /sbin/iso-scan "$isospec"
