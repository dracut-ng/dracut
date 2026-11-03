#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

devenc=$(str_replace "$1" '/' '\2f')

[ -e /tmp/dmraid."$devenc" ] && exit 0

: > /tmp/dmraid."$devenc"

DM_RAIDS=$(getargs rd.dm.uuid)

if [ -n "$DM_RAIDS" ] || getargbool 0 rd.auto; then
    # run dmraid if udev has settled
    info "Scanning for dmraid devices $DM_RAIDS"
    SETS=$(dmraid -c -s)

    if [ "$SETS" = "no raid disks" ] || [ "$SETS" = "no raid sets" ]; then
        return
    fi

    info "Found dmraid sets:"
    echo "$SETS" | vinfo

    if [ -n "$DM_RAIDS" ]; then
        # only activate specified DM RAIDS
        for r in $DM_RAIDS; do
            for s in $SETS; do
                if [ "${s##"$r"}" != "$s" ]; then
                    info "Activating $s"
                    dmraid -ay -i -p --rm_partitions "$s" 2>&1 | vinfo
                fi
            done
        done
    else
        # scan and activate all DM RAIDS
        for s in $SETS; do
            info "Activating $s"
            dmraid -ay -i -p --rm_partitions "$s" 2>&1 | vinfo
            [ -e "/dev/mapper/$s" ] && kpartx -a "/dev/mapper/$s" 2>&1 | vinfo
            udevsettle
        done
    fi
fi
