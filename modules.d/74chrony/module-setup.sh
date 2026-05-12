#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

check() {
    require_binaries \
        chronyd \
        || return 1

    return 255
}

depends() {
    echo systemd network
    return 0
}

install() {
    # openSUSE/Fedora: chrony
    # Ubuntu: _chrony
    grep -s -E '^(_chrony|chrony):' "${dracutsysrootdir-}"/etc/passwd \
        | sed 's/\/var\/lib\/chrony/\/run\/chrony/' >> "$initdir/etc/passwd"
    grep -s -E '^(_chrony|chrony):' "${dracutsysrootdir-}"/etc/group >> "$initdir/etc/group"

    inst_hook cmdline 01 "$moddir/parse-ntp.sh"
    inst_hook initqueue/online 01 "$moddir/chrony-ntp-source.sh"

    inst_multiple -o \
        "$systemdntpunits"/50-chronyd.list \
        "$systemdsystemunitdir"/time-sync.target \
        chronyd chronyc mkdir chown

    inst_simple "$moddir/chrony.conf" /etc/chrony.conf

    for i in \
        chronyd.service \
        chrony-wait.service; do
        inst_simple "$moddir/$i" "$systemdsystemunitdir/$i"
        $SYSTEMCTL -q --root "$initdir" add-wants initrd.target "$i"
    done

    if [[ $hostonly ]]; then
        local _i _directives _keyfile _source_dirs=()

        # Install the file pointed by the "keyfile" directive, used for NTP
        # authentication. This directive is intended to be unique, chrony would
        # end up using the last one processed.
        readarray -t _directives < <(grep -r -h '^keyfile ' "${dracutsysrootdir-}"/etc/chrony*)
        if ((${#_directives[@]})); then
            printf "\n# Specify file containing keys for NTP authentication.\n%s\n" "${_directives[-1]}" >> "$initdir/etc/chrony.conf"
            _keyfile="${_directives[-1]/#keyfile /}"
        fi

        # chrony allows to configure directories with .sources files using the
        # "sourcedir" directive, used to specify NTP sources (server, pool, and
        # peer directives).
        readarray -t _directives < <(grep -r -h '^sourcedir /etc' "${dracutsysrootdir-}"/etc/chrony*)
        if ((${#_directives[@]})); then
            printf "\n# Use NTP sources configured on the host.\n" >> "$initdir/etc/chrony.conf"
            for _i in "${_directives[@]}"; do
                echo "$_i" >> "$initdir/etc/chrony.conf"
                _source_dirs+=("$(echo "$_i" | sed -e 's/sourcedir //' -e 's/$/\/*.sources/')")
            done
        fi

        # We do not want to include /etc/chrony.conf or ".conf" files specified
        # with "include" or "confdir" directives from the host, because they
        # can override "driftfile", "ntsdumpdir" or "logdir" directives,
        # intended to point to /run in the initrd.

        inst_multiple -H -o "$_keyfile" "${_source_dirs[@]}" \
            /etc/sysconfig/chronyd \
            "$systemdsystemconfdir"/time-sync.target \
            "$systemdsystemconfdir/time-sync.target.wants/*.target"
    fi
}
