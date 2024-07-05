#!/bin/bash

# shellcheck disable=SC2034
TEST_DESCRIPTION="Full systemd serialization/deserialization test with /usr mount"

test_check() {
    command -v systemctl &> /dev/null
}

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell rd.break"
#DEBUGOUT="quiet systemd.log_level=debug systemd.log_target=console loglevel=77  rd.info rd.debug"
DEBUGOUT="loglevel=0 "
client_run() {
    local test_name="$1"
    shift
    local client_opts="$*"

    echo "CLIENT TEST START: $test_name"

    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_index disk_args "$TESTDIR"/root.btrfs root
    qemu_add_drive disk_index disk_args "$TESTDIR"/usr.btrfs usr

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE systemd.unit=testsuite.target systemd.mask=systemd-firstboot systemd.mask=systemd-vconsole-setup rd.multipath=0 root=LABEL=dracut $client_opts rd.retry=3 console=ttyS0,115200n81 $DEBUGOUT" \
        -initrd "$TESTDIR"/initramfs.testing || return 1

    if ! test_marker_check; then
        echo "CLIENT TEST END: $test_name [FAILED]"
        return 1
    fi
    echo "CLIENT TEST END: $test_name [OK]"

}

test_run() {
    client_run "no option specified" || return 1
    client_run "readonly root" "ro" || return 1
    client_run "writeable root" "rw" || return 1
    return 0
}

test_setup() {
    # shellcheck disable=SC2064
    trap "$(shopt -p globstar)" RETURN
    shopt -q -s globstar

    # Create what will eventually be our root filesystem onto an overlay
    "$DRACUT" -N -l --keep --tmpdir "$TESTDIR" \
        -m "test-root systemd-ldconfig" \
        -i "${PKGLIBDIR}/modules.d/80test-root/test-init.sh" "/sbin/test-init.sh" \
        -i ./test-init.sh /sbin/test-init \
        -I "findmnt" \
        -i ./fstab /etc/fstab \
        -f "$TESTDIR"/initramfs.root "$KVERSION" || return 1

    mkdir -p "$TESTDIR"/overlay/source && cp -a "$TESTDIR"/dracut.*/initramfs/* "$TESTDIR"/overlay/source && rm -rf "$TESTDIR"/dracut.* && export initdir=$TESTDIR/overlay/source

    if type -P rpm &> /dev/null; then
        rpm -ql systemd | xargs -r "$PKGLIBDIR"/dracut-install ${initdir:+-D "$initdir"} -o -a -l
    elif type -P dpkg &> /dev/null; then
        dpkg -L systemd | xargs -r "$PKGLIBDIR"/dracut-install ${initdir:+-D "$initdir"} -o -a -l
    elif type -P pacman &> /dev/null; then
        pacman -Q -l systemd | while read -r _ a; do printf -- "%s\0" "$a"; done | xargs -0 -r "$PKGLIBDIR"/dracut-install ${initdir:+-D "$initdir"} -o -a -l
    elif type -P equery &> /dev/null; then
        equery f 'sys-apps/systemd*' | xargs -r "$PKGLIBDIR"/dracut-install ${initdir:+-D "$initdir"} -o -a -l
    else
        echo "Can't install systemd base"
        return 1
    fi

    # softlink mtab
    ln -fs /proc/self/mounts "$initdir"/etc/mtab

    # install any Execs from the service files
    grep -Eho '^Exec[^ ]*=[^ ]+' "$initdir"{,/usr}/lib/systemd/system/*.service \
        | while read -r i || [ -n "$i" ]; do
            i=${i##Exec*=}
            i=${i##-}
            "$PKGLIBDIR"/dracut-install ${initdir:+-D "$initdir"} -o -a -l "$i"
        done

    # setup the testsuite target
    mkdir -p "$initdir"/etc/systemd/system
    cat > "$initdir"/etc/systemd/system/testsuite.target << EOF
[Unit]
Description=Testsuite target
Requires=basic.target
After=basic.target
Conflicts=rescue.target
AllowIsolate=yes
EOF

    # setup the testsuite service
    cat > "$initdir"/etc/systemd/system/testsuite.service << EOF
[Unit]
Description=Testsuite service
After=basic.target

[Service]
ExecStart=/sbin/test-init
Type=oneshot
StandardInput=tty
StandardOutput=tty
EOF

    mkdir -p "$initdir"/etc/systemd/system/testsuite.target.wants
    ln -fs ../testsuite.service "$initdir"/etc/systemd/system/testsuite.target.wants/testsuite.service

    # second, install the files needed to make the root filesystem
    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    "$DRACUT" -N -l -i "$TESTDIR"/overlay / \
        -a "test-makeroot bash btrfs" \
        -I "mkfs.btrfs" \
        -i ./create-root.sh /lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot "$KVERSION" || return 1
    rm -rf -- "$TESTDIR"/overlay/*

    # Create the blank file to use as a root filesystem
    declare -a disk_args=()
    # shellcheck disable=SC2034
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/root.btrfs root 160
    qemu_add_drive disk_index disk_args "$TESTDIR"/usr.btrfs usr 160

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot rw rootfstype=btrfs quiet console=ttyS0,115200n81" \
        -initrd "$TESTDIR"/initramfs.makeroot || return 1

    if ! test_marker_check dracut-root-block-created; then
        echo "Could not create root filesystem"
        return 1
    fi

    [ -e /etc/machine-id ] && EXTRA_MACHINE="/etc/machine-id"
    [ -e /etc/machine-info ] && EXTRA_MACHINE+=" /etc/machine-info"

    test_dracut \
        -a "systemd i18n qemu" \
        -d "btrfs" \
        ${EXTRA_MACHINE:+-I "$EXTRA_MACHINE"} \
        "$TESTDIR"/initramfs.testing

    rm -rf -- "$TESTDIR"/overlay
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
