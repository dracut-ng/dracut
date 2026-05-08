#!/bin/sh

command -v source_hook > /dev/null || . /lib/dracut-lib.sh

for ifpath in /sys/class/net/*; do
    ifname="${ifpath##*/}"

    # shellcheck disable=SC2015
    [ "$ifname" != "lo" ] && [ -e "$ifpath" ] && [ ! -e /tmp/networkd."$ifname".done ] || continue

    if /usr/lib/systemd/systemd-networkd-wait-online --timeout=0.000001 --interface="$ifname" 2> /dev/null; then
        leases_file="/run/systemd/netif/leases/$(cat "$ifpath"/ifindex)"
        dhcpopts_file="/tmp/dhclient.${ifname}.dhcpopts"
        if [ -r "$leases_file" ]; then
            grep -E "^(NEXT_SERVER|ROOT_PATH)=" "$leases_file" \
                | sed -e "s/NEXT_SERVER=/new_next_server='/" \
                    -e "s/ROOT_PATH=/new_root_path='/" \
                    -e "s/$/'/" > "$dhcpopts_file" || :
        fi

        source_hook initqueue/online "$ifname"
        /sbin/netroot "$ifname"

        : > /tmp/networkd."$ifname".done
    fi
done
