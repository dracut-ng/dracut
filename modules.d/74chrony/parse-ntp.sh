#!/bin/sh

command -v getargs > /dev/null || . /lib/dracut-lib.sh

# format: rd.ntp={server|pool|peer}:<hostname-or-ip>[:<option>[,<option>...]]
parse_ntp_source() {
    local v="${1}":
    local i
    local src addr opts

    set --
    while [ -n "$v" ]; do
        if [ "${v#\[*:*:*\]:}" != "$v" ]; then
            # handle IPv6 address
            i="${v%%\]:*}"
            i="${i##\[}"
            set -- "$@" "$i"
            v=${v#\["$i"\]:}
        else
            set -- "$@" "${v%%:*}"
            v=${v#*:}
        fi
    done

    if [ $# -lt 2 ]; then
        warn "Failed to parse NTP time source"
        return 1
    fi

    case "$1" in
        server | pool | peer)
            src=$1
            ;;
        *)
            warn "Invalid time source '$1'. Valid options: server, pool, peer"
            return 1
            ;;
    esac

    [ -n "$2" ] && addr=$2
    [ -n "$3" ] && opts="$(str_replace "$3" "," " ")"

    echo "${src} ${addr}${opts:+ $opts}"
    return 0
}

mkdir -p -m 0750 /run/chrony
chown chrony: /run/chrony
mkdir /run/chrony/dracut.sources.d

for _i in $(getargs rd.ntp); do
    _src=$(parse_ntp_source "$_i")
    if [ -n "$_src" ]; then
        echo "$_src" >> /run/chrony/dracut.sources.d/dracut.sources
    fi
done

if [ "$(ls -A /run/chrony/dracut.sources.d)" ] && ! getargbool 0 rd.neednet; then
    echo "rd.neednet=1" > /etc/cmdline.d/01-chrony.conf
    if ! getarg "ip="; then
        echo "ip=dhcp" >> /etc/cmdline.d/01-chrony.conf
    fi
fi

unset _i _src
