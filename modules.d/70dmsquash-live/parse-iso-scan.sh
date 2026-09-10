#!/bin/sh
# live .iso images are specified as
# [iso-scan/devspec=<devspec>]
# iso-scan/filename=<filepath>

isospec=$(getargs iso-scan/devspec iso-scan/filename)

[ "$isospec" ] && /sbin/initqueue --settled --unique /sbin/iso-scan "$isospec"
