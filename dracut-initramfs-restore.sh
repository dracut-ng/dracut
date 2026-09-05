#!/bin/sh

set -e

# do some sanity checks first
[ -e /run/initramfs/bin/sh ] && exit 0
[ -e /run/initramfs/.need_shutdown ] || exit 0

# SIGTERM signal is received upon forced shutdown: ignore the signal
# We want to remain alive to be able to trap unpacking errors to avoid
# switching root to an incompletely unpacked initramfs
trap 'echo "Received SIGTERM signal, ignoring!" >&2' TERM

KERNEL_VERSION="$(uname -r)"

[ "$dracutbasedir" ] || dracutbasedir=/usr/lib/dracut

find_initrd_for_kernel_version() {
    local kernel_version="$1"
    local base_path f initrd machine_id
    local arg deploy entries entry match opt

    if [ -d /efi/Default ] || [ -d /boot/Default ] || [ -d /boot/efi/Default ]; then
        machine_id="Default"
    elif [ -s /etc/machine-id ]; then
        read -r machine_id < /etc/machine-id
        [ "$machine_id" = "uninitialized" ] && machine_id="Default"
    else
        machine_id="Default"
    fi

    if [ -n "$machine_id" ]; then
        for base_path in /efi /boot /boot/efi; do
            initrd="${base_path}/${machine_id}/${kernel_version}/initrd"
            if [ -f "$initrd" ]; then
                echo "$initrd"
                return
            fi
        done
    fi

    # ostree-based distributions (Silverblue, RHEL for Edge, FCOS) keep
    # per-deployment images under /boot/ostree/<stateroot>-<bootcsum>/
    if [ -d /boot/ostree ]; then
        # Prefer the deployment the running kernel booted with, resolved
        # through its BLS loader entry: the ostree= kernel argument carries
        # the deployment path, and the matching entry's "initrd" line then
        # names the exact image.  The filename must match the kernel
        # version so spec-valid entries that load a microcode image first
        # cannot mislead the selection.
        deploy=""
        set -f
        for arg in $(tr -d '\r' < /proc/cmdline); do
            case $arg in
                ostree=*) deploy=${arg#ostree=} ;;
            esac
        done
        set +f
        if [ -n "$deploy" ]; then
            for entries in /efi/loader/entries /boot/loader*/entries /boot/efi/loader/entries; do
                for entry in "$entries"/*.conf; do
                    [ -f "$entry" ] || continue
                    match=n
                    for opt in $(sed -n 's/^options[[:space:]]\{1,\}//p' "$entry" | tr -d '\r'); do
                        if [ "$opt" = "ostree=$deploy" ]; then
                            match=y
                            break
                        fi
                    done
                    [ "$match" = y ] || continue
                    for initrd in $(sed -n 's/^initrd[[:space:]]\{1,\}//p' "$entry" | tr -d '\r'); do
                        case $initrd in
                            *initramfs-"${kernel_version}".img) ;;
                            *) continue ;;
                        esac
                        initrd=${initrd#/}
                        if [ -f "/boot/$initrd" ]; then
                            echo "/boot/$initrd"
                            return
                        fi
                    done
                done
            done
        fi
        for initrd in /boot/ostree/*/initramfs-"${kernel_version}".img; do
            if [ -f "$initrd" ]; then
                echo "$initrd"
                return
            fi
        done
    fi

    if [ -f "/lib/modules/${kernel_version}/initrd" ]; then
        echo "/lib/modules/${kernel_version}/initrd"
    elif [ -f "/boot/initramfs-${kernel_version}.img" ]; then
        echo "/boot/initramfs-${kernel_version}.img"
    else
        for f in /boot/initr*"${kernel_version}"*; do
            if [ -e "${f}" ]; then
                echo "${f}"
                return
            fi
        done
    fi
}

extract_initrd() {
    local initrd="$1"
    if command -v 3cpio > /dev/null; then
        3cpio --extract "$initrd"
    else
        "$dracutbasedir/extractinitrd" "$initrd"
    fi
}

mount -o ro /boot > /dev/null 2>&1 || :

IMG=$(find_initrd_for_kernel_version "$KERNEL_VERSION")
if [ -z "$IMG" ]; then
    if [ -f /boot/initramfs-linux.img ]; then
        IMG="/boot/initramfs-linux.img"
    elif [ -f /boot/initrd.img ]; then
        IMG="/boot/initrd.img"
    elif [ -f /initrd.img ]; then
        IMG="/initrd.img"
    else
        echo "No initramfs image found to restore!"
        exit 1
    fi
fi

cd /run/initramfs

if ! extract_initrd "$IMG"; then
    # something failed, so we clean up
    echo "Unpacking of $IMG to /run/initramfs failed" >&2
    rm -f -- /run/initramfs/shutdown
    exit 1
fi
rm -f -- .need_shutdown

if [ -f squashfs-root.img ]; then
    if ! unsquashfs -no-xattrs -f -d . squashfs-root.img > /dev/null; then
        echo "Squash module is enabled for this initramfs but failed to unpack squash-root.img" >&2
        rm -f -- /run/initramfs/shutdown
        exit 1
    fi
elif [ -f erofs-root.img ]; then
    if ! fsck.erofs --extract=. --overwrite erofs-root.img > /dev/null; then
        echo "Squash module is enabled for this initramfs but failed to unpack erofs-root.img" >&2
        rm -f -- /run/initramfs/shutdown
        exit 1
    fi
fi

if grep -qs -w selinux /sys/kernel/security/lsm \
    && [ -e /etc/selinux/config ] && [ -x /usr/sbin/setfiles ]; then
    . /etc/selinux/config
    if [ "$SELINUX" != "disabled" ] && [ -n "$SELINUXTYPE" ]; then
        /usr/sbin/setfiles -v -r /run/initramfs /etc/selinux/"${SELINUXTYPE}"/contexts/files/file_contexts /run/initramfs > /dev/null
    fi
fi

exit 0
