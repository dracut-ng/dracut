#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

for root in $(getargs rootfallback=); do
    root=$(label_uuid_to_dev "$root")

    if ! [ -b "$root" ]; then
        warn "Could not find rootfallback $root"
        continue
    fi

    if /bin/mount "$root" /sysroot; then
        info "Mounted rootfallback $root"
        exit 0
    else
        warn "Failed to mount rootfallback $root"
        exit 1
    fi
done

[ -e "$job" ] && rm -f "$job"
