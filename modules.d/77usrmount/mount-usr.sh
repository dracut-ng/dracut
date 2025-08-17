#!/bin/sh

command -v info > /dev/null || . /lib/dracut-lib.sh
command -v fsck_single > /dev/null || . /lib/fs-lib.sh

filtersubvol() {
    local _oldifs
    _oldifs="$IFS"
    local IFS=","
    # shellcheck disable=SC2086
    set -- $1
    IFS="$_oldifs"
    while [ $# -gt 0 ]; do
        case $1 in
            'subvol='*) : ;;
            'subvolid='*) : ;;
            *) printf '%s' "${1}," ;;
        esac
        shift
    done
}

fsck_usr() {
    local _dev="$1"
    local _fs="$2"
    local _fsopts="$3"
    local _fsckoptions

    if getargbool 0 forcefsck; then
        _fsckoptions="-f $_fsckoptions"
    fi

    fsck_single "$_dev" "$_fs" "$_fsopts" "$_fsckoptions"
}

mount_usr() {
    local _dev _mp _fs _opts _ _usr_found _ _freq _passno
    # check, if we have to mount the /usr filesystem
    while read -r _dev _mp _fs _opts _freq _passno || [ -n "$_dev" ]; do
        [ "${_dev%%#*}" != "$_dev" ] && continue
        if [ "$_mp" = "/usr" ]; then
            case "$_dev" in
                LABEL=* | UUID=* | PARTUUID=* | PARTLABEL=*)
                    _dev="$(label_uuid_to_dev "$_dev")"
                    ;;
                *) ;;
            esac

            if strstr "$_opts" "subvol=" \
                && [ "${root#block:}" -ef "$_dev" ] \
                && [ -n "$rflags" ]; then
                # for btrfs subvolumes we have to mount /usr with the same rflags
                rflags=$(filtersubvol "$rflags")
                rflags=${rflags%%,}
                _opts="${_opts:+${_opts},}${rflags}"
            elif getargbool 0 ro; then
                # if "ro" is specified, we want /usr to be mounted read-only
                _opts="${_opts:+${_opts},}ro"
            elif getargbool 0 rw; then
                # if "rw" is specified, we want /usr to be mounted read-write
                _opts="${_opts:+${_opts},}rw"
            fi
            echo "$_dev ${NEWROOT}${_mp} $_fs ${_opts} $_freq $_passno"
            _usr_found="1"
            break
        fi
    done < "$NEWROOT/etc/fstab" >> /etc/fstab

    if [ "$_usr_found" != "" ]; then
        # we have to mount /usr
        _fsck_ret=0
        if ! getargbool 0 rd.skipfsck; then
            if [ "0" != "${_passno:-0}" ]; then
                fsck_usr "$_dev" "$_fs" "$_opts"
                _fsck_ret=$?
                [ $_fsck_ret -ne 255 ] && echo $_fsck_ret > /run/initramfs/usr-fsck
            fi
        fi

        info "Mounting /usr with -o $_opts"
        mount "$NEWROOT/usr" 2>&1 | vinfo

        if ! ismounted "$NEWROOT/usr"; then
            warn "Mounting /usr to $NEWROOT/usr failed"
            warn "*** Dropping you to a shell; the system will continue"
            warn "*** when you leave the shell."
            emergency_shell
        fi
    fi
}

if [ -f "$NEWROOT/etc/fstab" ]; then
    mount_usr
fi
