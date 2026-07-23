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
            {
                new_next_server="$(sed -n 's/^NEXT_SERVER=//p' "$leases_file")"
                [ -n "$new_next_server" ] && printf "new_next_server='%s'\n" "$(escape "$new_next_server")"
                new_root_path="$(sed -n 's/^ROOT_PATH=//p' "$leases_file")"
                [ -n "$new_root_path" ] && printf "new_root_path='%s'\n" "$(escape "$new_root_path")"

                # systemd-networkd mixes IPv4 and IPv6 addresses under
                # the same NTP= property, but dhclient has two properties
                # for that: new_ntp_servers and new_dhcp6_ntp_servers
                ntp_ipv4=
                ntp_ipv6=
                ntp_servers=$(sed -n "s/^NTP=\(.*\)/\1/p" "$leases_file")
                for i in $ntp_servers; do
                    case "$i" in
                        *.*.*.*)
                            ntp_ipv4="$ntp_ipv4${ntp_ipv4:+ }$i"
                            ;;
                        *)
                            # hostnames are only allowed in DHCPv6
                            ntp_ipv6="$ntp_ipv6${ntp_ipv6:+ }$i"
                            ;;
                    esac
                done
                [ -n "$ntp_ipv4" ] && printf "new_ntp_servers=%s\n" "$(escape "$ntp_ipv4")"
                [ -n "$ntp_ipv6" ] && printf "new_dhcp6_ntp_servers=%s\n" "$(escape "$ntp_ipv6")"

            } > "$dhcpopts_file"
        else
            # Since systemd v261 the DHCP lease is no longer serialized to /run/, use the new networkctl command.
            lease=$(networkctl --no-pager --no-legend --full dhcp-lease "$ifname" 2> /dev/null) || lease=""
            if [ -n "$lease" ]; then
                {
                    next_server=$(printf '%s\n' "$lease" | sed -n "s/^[[:space:]]*Server Address:[[:space:]]*//p")
                    [ -n "$next_server" ] && printf "new_next_server='%s'\n" "$(escape "$next_server")"
                    # option 17 is the DHCP root-path; strip the leading "<code> <name> " columns
                    root_path=$(printf '%s\n' "$lease" | sed -n "s/^[[:space:]]*17[[:space:]].*[[:space:]]//p")
                    [ -n "$root_path" ] && printf "new_root_path='%s'\n" "$(escape "$root_path")"

                    # DHCP options containing information about NTP servers:
                    # - option 42: IPv4, no FQDN allowed. Parsing this option is
                    #   tricky, because the first value is printed after the tag
                    #   "NTP server", but the following values are indented
                    #   below in new lines. E.g.:
                    #
                    #   28 broadcast address  192.168.122.255
                    #   42 NTP server         185.103.119.60
                    #                         216.239.35.0
                    #   51 lease time         1h
                    #
                    # - option 56: IPv6, FQDN allowed. Since the dhcp-lease
                    #   command of networkctl only reads IPv4 leases, we can
                    #   omit parsing this option.
                    ntp_servers=$(printf '%s\n' "$lease" \
                        | sed -n "/^[[:space:]]*42 NTP server/{p; :a; n; /^[[:space:]]\+[0-9]/ {p; ba;};}" \
                        | sed "s/^[[:space:]]*42 NTP server//; s/^[[:space:]]*//" \
                        | tr '\n' ' ')
                    [ -n "$ntp_servers" ] && printf "new_ntp_servers='%s'\n" "$(escape "$(trim "$ntp_servers")")"

                } > "$dhcpopts_file" || :
            fi
        fi

        source_hook initqueue/online "$ifname"
        /sbin/netroot "$ifname"

        : > /tmp/networkd."$ifname".done
    fi
done
