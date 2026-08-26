#!/bin/sh

command -v load_fstype > /dev/null || . /lib/dracut-lib.sh
command -v nfsroot_to_var > /dev/null || . /lib/nfs-lib.sh

if ! load_fstype sunrpc rpc_pipefs; then
    warn 'Kernel module "sunrpc" not in the initramfs, or support for filesystem "rpc_pipefs" missing!'
    return 0
fi

[ -n "$netroot" ] || return 0
nfsroot_to_var "$netroot"
str_starts "$nfs" "nfs" || return 0

[ ! -d /var/lib/nfs/rpc_pipefs/nfs ] \
    && mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs

# Start rpcbind
# FIXME occasionally saw 'rpcbind: fork failed: No such device' -- why?
command -v portmap > /dev/null && [ -z "$(pidof portmap)" ] && portmap
if command -v rpcbind > /dev/null && [ -z "$(pidof rpcbind)" ]; then
    mkdir -p /run/rpcbind
    chown "$(get_user _rpc rpc rpcuser nfsnobody):" /run/rpcbind
    rpcbind
fi

# Start rpc.statd as mount won't let us use locks on a NFSv4
# filesystem without talking to it. NFSv4 does locks internally,
# rpc.lockd isn't needed
command -v rpc.statd > /dev/null && [ -z "$(pidof rpc.statd)" ] && rpc.statd
command -v rpc.idmapd > /dev/null && [ -z "$(pidof rpc.idmapd)" ] && rpc.idmapd
