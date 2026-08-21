#!/usr/bin/env bash
set -eu

[ -z "${USE_NETWORK-}" ] && USE_NETWORK="network"

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on NFS with $USE_NETWORK"

test_check() {
    # curl needed for url-lib
    require_binaries_for_test curl exportfs
}

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug loglevel=7 rd.break=initqueue rd.shell"
#SERVER_DEBUG="rd.debug loglevel=7"
#SERIAL="unix:/tmp/server.sock"

run_server() {
    # Start server first
    echo "NFS TEST SETUP: Starting DHCP/NFS server"
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/server.img root 0 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -device virtio-net-pci,netdev=lan0,mac=52:54:00:12:34:56 \
        -netdev dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60600,remote.type=inet,remote.host=localhost,remote.port=60601 \
        -serial "${SERIAL:-"file:./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"}" \
        -append "panic=1 oops=panic softlockup_panic=1 root=LABEL=dracut rootfstype=ext4 rw systemd.journald.forward_to_console=1 ${SERVER_DEBUG-}" \
        -pidfile "$TESTDIR"/server.pid -daemonize \
        -initrd "$TESTDIR"/initramfs.server
    chmod 644 "$TESTDIR"/server.pid

    if ! [[ ${SERIAL-} ]]; then
        wait_for_server_startup "./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"
    else
        echo Sleeping 10 seconds to give the server a head start
        sleep 10
    fi
}

client_test() {
    local test_name="$1"
    local mac=$2
    local cmdline="$3"
    local server="$4"
    local check_opt="$5"
    local nfsinfo opts found expected

    client_test_start "$test_name"

    # Need this so kvm-qemu will boot (needs non-/dev/zero local disk)
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/marker2.img marker2 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -device virtio-net-pci,netdev=lan0,mac="$mac" \
        -netdev dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60601,remote.type=inet,remote.host=localhost,remote.port=60600 \
        -append "$TEST_KERNEL_CMDLINE $cmdline ro" \
        -initrd "$TESTDIR"/initramfs.testing

    if ! test_marker_check nfs-OK; then
        client_test_end "FAILED - MISSING MARKER"
        return 1
    fi

    # nfsinfo=( server:/path nfs{,4} options )
    read -r -a nfsinfo < <(awk '{print $2, $3, $4; exit}' "$TESTDIR"/marker.img)

    if [[ ${nfsinfo[0]%%:*} != "$server" ]]; then
        echo "CLIENT TEST INFO: got server: ${nfsinfo[0]%%:*}"
        echo "CLIENT TEST INFO: expected server: $server"
        client_test_end "FAILED - WRONG SERVER"
        return 1
    fi

    found=0
    expected=1
    if [[ ${check_opt:0:1} == '-' ]]; then
        expected=0
        check_opt=${check_opt:1}
    fi

    opts=${nfsinfo[2]},
    while [[ $opts ]]; do
        if [[ ${opts%%,*} == "$check_opt" ]]; then
            found=1
            break
        fi
        opts=${opts#*,}
    done

    if [[ $found -ne $expected ]]; then
        echo "CLIENT TEST INFO: got options: ${nfsinfo[2]%%:*}"
        if [[ $expected -eq 0 ]]; then
            echo "CLIENT TEST INFO: did not expect: $check_opt"
            client_test_end "FAILED - UNEXPECTED OPTION"
        else
            echo "CLIENT TEST INFO: missing: $check_opt"
            client_test_end "FAILED - MISSING OPTION"
        fi
        return 1
    fi

    if ! test_marker_check nfsfetch-OK marker2.img; then
        client_test_end "FAILED - NFS FETCH FAILED"
        return 1
    fi

    client_test_end
    return 0
}

test_nfsv3() {
    # MAC numbering scheme:
    # NFSv3: last octet starts at 0x00 and works up
    # NFSv4: last octet starts at 0x80 and works up

    client_test "NFSv3 root=dhcp DHCP path only" 52:54:00:12:34:00 \
        "root=dhcp" 192.168.50.1 -wsize=4096

    client_test "NFSv3 Legacy root=/dev/nfs nfsroot=IP:path" 52:54:00:12:34:01 \
        "root=/dev/nfs nfsroot=192.168.50.1:/nfs/client" 192.168.50.1 -wsize=4096

    client_test "NFSv3 Legacy root=/dev/nfs DHCP path only" 52:54:00:12:34:02 \
        "root=/dev/nfs" 192.168.50.1 -wsize=4096

    client_test "NFSv3 Legacy root=/dev/nfs DHCP IP:path" 52:54:00:12:34:03 \
        "root=/dev/nfs" 192.168.50.2 -wsize=4096

    client_test "NFSv3 root=dhcp DHCP IP:path" 52:54:00:12:34:04 \
        "root=dhcp" 192.168.50.2 -wsize=4096

    client_test "NFSv3 root=dhcp DHCP proto:IP:path" 52:54:00:12:34:05 \
        "root=dhcp" 192.168.50.3 -wsize=4096

    client_test "NFSv3 root=dhcp DHCP proto:IP:path:options" 52:54:00:12:34:06 \
        "root=dhcp" 192.168.50.3 wsize=4096

    client_test "NFSv3 root=nfs:..." 52:54:00:12:34:07 \
        "root=nfs:192.168.50.1:/nfs/client" 192.168.50.1 -wsize=4096

    client_test "NFSv3 Bridge root=nfs:..." 52:54:00:12:34:08 \
        "root=nfs:192.168.50.1:/nfs/client bridge net.ifnames=0" 192.168.50.1 -wsize=4096

    client_test "NFSv3 Legacy root=IP:path" 52:54:00:12:34:09 \
        "root=192.168.50.1:/nfs/client" 192.168.50.1 -wsize=4096

    client_test "NFSv3 root=dhcp DHCP path,options" 52:54:00:12:34:10 \
        "root=dhcp" 192.168.50.1 wsize=4096

    client_test "NFSv3 root=dhcp DHCP IP:path,options" 52:54:00:12:34:11 \
        "root=dhcp" 192.168.50.2 wsize=4096

    client_test "NFSv3 root=dhcp DHCP proto:IP:path,options" 52:54:00:12:34:12 \
        "root=dhcp" 192.168.50.3 wsize=4096

    # TODO FIXME
    #    client_test "NFSv3 Bridge Customized root=dhcp DHCP path,options" 52:54:00:12:34:13 \
    #        "root=dhcp bridge=foobr0:enp0s1" 192.168.50.1 wsize=4096

    return 0
}

test_nfsv4() {
    # There is a mandatory 90 second recovery when starting the NFSv4
    # server, so put these later in the list to avoid a pause when doing
    # switch_root

    client_test "NFSv4 root=dhcp DHCP proto:IP:path" 52:54:00:12:34:80 \
        "root=dhcp" 192.168.50.3 -wsize=4096

    client_test "NFSv4 root=dhcp DHCP proto:IP:path:options" 52:54:00:12:34:81 \
        "root=dhcp" 192.168.50.3 wsize=4096

    client_test "NFSv4 root=nfs4:..." 52:54:00:12:34:82 \
        "root=nfs4:192.168.50.1:/client" 192.168.50.1 -wsize=4096

    client_test "NFSv4 root=dhcp DHCP proto:IP:path,options" 52:54:00:12:34:83 \
        "root=dhcp" 192.168.50.3 wsize=4096

    client_test "NFSv4 Overlayfs root=nfs4:..." 52:54:00:12:34:84 \
        "root=nfs4:192.168.50.1:/client rd.overlay " 192.168.50.1 -wsize=4096

    client_test "NFSv4 Live Overlayfs root=nfs4:..." 52:54:00:12:34:85 \
        "root=nfs4:192.168.50.1:/client rd.live.image rd.overlay" 192.168.50.1 -wsize=4096

    return 0
}

test_run() {
    if [[ -s server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi

    if ! run_server; then
        echo "Failed to start server" 1>&2
        return 1
    fi

    test_nfsv3
    test_nfsv4

    if [[ -s $TESTDIR/server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi
}

make_server_rootfs() {
    call_dracut --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        -a "$USE_NETWORK url-lib nfs" \
        -I "ip grep setsid" \
        -f "$TESTDIR"/initramfs.root || return 1

    mkdir -p "$TESTDIR"/server/overlay

    # Create what will eventually be the server root filesystem onto an overlay
    call_dracut --tmpdir "$TESTDIR"/server/overlay \
        --add-confdir test-root \
        -a "bash $USE_NETWORK nfs" \
        --add-drivers "nfsd sunrpc lockd" \
        -I "exportfs pidof rpc.nfsd rpc.mountd dnsmasq tcpdump" \
        --install-optional "/etc/netconfig /etc/nsswitch.conf /etc/rpc /etc/protocols /etc/services /usr/etc/nsswitch.conf /usr/etc/rpc /usr/etc/protocols /usr/etc/services rpc.idmapd /etc/idmapd.conf" \
        -f "$TESTDIR"/initramfs.root

    mkdir -p "$TESTDIR"/server-rootfs
    mv "$TESTDIR"/server/overlay/dracut.*/initramfs/* "$TESTDIR"/server-rootfs
    rm -rf "$TESTDIR"/server/overlay/dracut.*

    export initdir=$TESTDIR/server-rootfs
    mkdir -p "$initdir"/var/lib/rpcbind "$initdir"/var/lib/nfs/{v4recovery,rpc_pipefs}
    : > "$initdir"/var/lib/nfs/rmtab
    chmod 777 "$initdir"/var/lib/{nfs/rmtab,rpcbind}
    inst_init ./server-init.sh "$initdir"
    cp ./exports "$initdir"/etc/exports
    cp ./dnsmasq.conf "$initdir"/etc/dnsmasq.conf

    # Make client root inside server root
    # shellcheck disable=SC2031
    export initdir=$TESTDIR/server-rootfs/nfs/client
    mkdir -p "$initdir"
    mv "$TESTDIR"/dracut.*/initramfs/* "$initdir"
    rm -rf "$TESTDIR"/dracut.*
    echo "TEST FETCH FILE" > "$initdir"/root/fetchfile
    inst_init ./client-init.sh "$initdir"

    build_ext4_image "$TESTDIR/server-rootfs" "$TESTDIR"/server.img dracut
}

test_setup() {
    make_server_rootfs

    # Make client's dracut image
    test_dracut \
        --no-hostonly \
        --include ./client.link /etc/systemd/network/01-client.link \
        -a "watchdog dmsquash-live ${USE_NETWORK}"

    # Make server's dracut image
    call_dracut \
        -a "bash $USE_NETWORK ${SERVER_DEBUG:+debug}" \
        --include ./server.link /etc/systemd/network/01-server.link \
        --include ./wait-if-server.sh /usr/lib/dracut/hooks/pre-mount/99-wait-if-server.sh \
        -N \
        -f "$TESTDIR"/initramfs.server
}

test_cleanup() {
    if [[ -s $TESTDIR/server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
