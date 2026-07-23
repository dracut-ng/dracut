#!/usr/bin/env bash
set -eu

[ -z "${USE_NETWORK-}" ] && USE_NETWORK="network"

# shellcheck disable=SC2034
TEST_DESCRIPTION="NTP support with chrony, systemd and $USE_NETWORK"

# Fake time way off in the future, so SSL certificates will appear to have
# expired
FAKE_TIME="2100-01-01T00:00:00"

# Name of the SSL certificate
SSL_CERT="webserver.pem"

test_check() {
    local binary

    for binary in chronyd openssl; do
        if ! type -p "$binary" &> /dev/null; then
            echo "Test needs $binary... Skipping"
            return 1
        fi
    done

    command -v systemctl &> /dev/null
}

client_run() {
    local nook="$1"
    local test_name="$2"
    local append="$3"

    client_test_start "$test_name"

    # Comments about some qemu options:
    # - -rtc "base=...,clock=vm" allows to disconnect vm time from host time
    # - initcall_blacklist=rtc_cmos_init (x86_64) / efi_rtc_init (aarch64)
    #   instructs the kernel to avoid trying to sync the clock
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -rtc "base=$FAKE_TIME,clock=vm" \
        -device "virtio-net-pci,netdev=lan0" \
        -netdev "user,id=lan0,net=10.0.2.0/24,dhcpstart=10.0.2.15" \
        -append "root=LABEL=dracut initcall_blacklist=rtc_cmos_init initcall_blacklist=efi_rtc_init $append $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR/initramfs.testing"

    # The "nook" variable controls whether a failed test is considered good
    if [[ $nook != 1 ]]; then
        check_qemu_log
    else
        check_qemu_log || :
    fi

    client_test_end
}

test_run() {
    declare -a disk_args=()

    qemu_add_drive disk_args "$TESTDIR"/root.img root

    start_webserver "HTTPS" "$SSL_CERT"

    client_run 1 \
        "Fetch file from HTTPS with the system clock out of sync" \
        "rd.neednet=1 ip=dhcp"

    # 2606:4700:f1::1 should be Cloudflare
    # "prefer" pool.ntp.org
    client_run 0 \
        "Fetch file from HTTPS after sync time via NTP" \
        "rd.ntp=server:[2606:4700:f1::1]:iburst rd.ntp=pool:pool.ntp.org:iburst,prefer"
}

test_setup() {
    # Create plain root filesystem
    build_client_rootfs "$TESTDIR/rootfs"

    # Create an ext4 image with the rootfs
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR/root.img" dracut

    # Create a file to be downloaded from the initrd
    echo "dracut-chrony-success" > "$TESTDIR/remote-file.txt"

    # We have to trick systemd to avoid taking its build time, see man
    # systemd(1) for more details
    touch -d "$FAKE_TIME" "$TESTDIR/clock-epoch"

    # Create a certificate, we need to add it to the initrd, so we can call curl
    # with the --cacert option, otherwise it fails with the error:
    # "curl: (60) SSL certificate OpenSSL verify result: self-signed certificate (18)"
    openssl req \
        -quiet \
        -new -x509 \
        -keyout "$TESTDIR/$SSL_CERT" \
        -subj "/CN=10.0.2.2/" \
        -out "$TESTDIR/$SSL_CERT" \
        -days 365 \
        -nodes

    # We will add a drop-in for dracut-pre-pivot.service, ordering it after
    # time-sync.target, so it will wait until the system time is synchronized
    {
        echo "[Unit]"
        echo "After=time-sync.target"
    } > "$TESTDIR/dracut-wait.conf"

    # Install a pre-pivot hook to fetch "remote-file.txt" using HTTPS, if the
    # system clock is out of sync, curl will fail with the error:
    # "curl: (60) SSL certificate OpenSSL verify result: certificate has expired (10)"
    # and the script will unmount /sysroot, so the test should fail as well
    # shellcheck disable=SC2016
    {
        echo "#!/bin/sh"
        echo "command -v warn > /dev/null || . /lib/dracut-lib.sh"
        echo 'warn "$(systemctl status chronyd.service)"'
        echo "remote_file_content=\$(curl --cacert /etc/$SSL_CERT \"https://10.0.2.2:4443/remote-file.txt\")"
        echo 'if [ "$remote_file_content" = "dracut-chrony-success" ]; then'
        echo '    warn "$remote_file_content"'
        echo "else"
        echo '    warn "Failed to fetch remote-file.txt using HTTPS"'
        echo "    umount /sysroot"
        echo "fi"
    } > "$TESTDIR/fetch-remote-file.sh"
    chmod +x "$TESTDIR/fetch-remote-file.sh"

    # Synchronizing the clock via NTP usually takes ~30s, if we want to test
    # that fetching from HTTPS fails when the clock is out of sync, we would
    # have to wait the default 3-minute timeout for a systemd service, so with
    # the following drop-in we can reduce the time spent in the test
    {
        echo "[Service]"
        echo "TimeoutSec=1min"
    } > "$TESTDIR/chrony-less-timeout.conf"

    # Build non-hostonly initrd to avoid adding local chrony configuration,
    # pointing to a variety of NTP servers depending on the distribution
    test_dracut \
        --no-hostonly \
        -i "$TESTDIR/clock-epoch" "/usr/lib/clock-epoch" \
        -i "$TESTDIR/$SSL_CERT" "/etc/$SSL_CERT" \
        -i "$TESTDIR/dracut-wait.conf" "/usr/lib/systemd/system/dracut-pre-pivot.service.d/dracut-wait.conf" \
        -i "$TESTDIR/fetch-remote-file.sh" "/var/lib/dracut/hooks/pre-pivot/10-fetch-remote-file.sh" \
        -i "$TESTDIR/chrony-less-timeout.conf" "/usr/lib/systemd/system/chrony-wait.service.d/chrony-less-timeout.conf" \
        -a "chrony url-lib ${USE_NETWORK}"
}

test_cleanup() {
    stop_webserver
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
