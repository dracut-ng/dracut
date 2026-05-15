#!/bin/bash

__nvmf_has_nbft() {
    local f found=
    for f in /sys/firmware/acpi/tables/NBFT*; do
        [ -f "$f" ] || continue
        found=1
        break
    done
    [[ $found ]]
}

# called by dracut
check() {
    local -A nvmf_trtypes

    require_binaries nvme jq || return 1
    require_kernel_modules nvme_fabrics || return 1

    # shellcheck disable=SC2317,SC2329  # called later by for_each_host_dev_and_slaves
    is_nvmf() {
        local _dev=$1
        local trtype

        [[ -L "/sys/dev/block/$_dev" ]] || return 0
        cd -P "/sys/dev/block/$_dev" || return 0
        if [ -f partition ]; then
            cd ..
        fi
        for d in device/nvme*; do
            [ -L "$d" ] || continue
            if readlink "$d" | grep -q nvme-fabrics; then
                read -r trtype < "$d"/transport
                break
            fi
        done
        if [[ $trtype == "fc" ]] || [[ $trtype == "tcp" ]] || [[ $trtype == "rdma" ]]; then
            nvmf_trtypes["nvme_${trtype}"]=1
            return 0
        else
            return 1
        fi
    }

    [[ $hostonly ]] || [[ $mount_needs ]] && {
        [ -f /etc/nvme/hostnqn ] || return 255
        [ -f /etc/nvme/hostid ] || return 255
        pushd . > /dev/null
        for_each_host_dev_and_slaves is_nvmf
        local _is_nvmf=$?
        popd > /dev/null || exit
        [[ $_is_nvmf == 0 ]] || return 255
        require_kernel_modules "${!nvmf_trtypes[@]}" || return 1
        if [ ! -f /sys/class/fc/fc_udev_device/nvme_discovery ] \
            && [ ! -f /etc/nvme/discovery.conf ] \
            && [ ! -f /etc/nvme/config.json ] && ! __nvmf_has_nbft; then
            echo "No discovery arguments present"
            return 255
        fi
    }
    return 0
}

# called by dracut
depends() {
    echo rootfs-block network initqueue
    return 0
}

# called by dracut
installkernel() {
    hostonly=$(optional_hostonly) instmods nvme_fc nvme_tcp nvme_rdma lpfc qla2xxx
    # 802.1q VLAN may be set up in Firmware later. Include the module always.
    hostonly="" instmods 8021q
    # lookup NIC kernel modules for active NBFT interfaces
    if [[ $hostonly ]]; then
        local mac_re

        # mac_re is a list of MAC addresses joined with "|", suitable as regexp
        mac_re=$(nvme nbft show -H -o json \
            | jq -r '[.[].hfi[].mac_addr] | join("|")')
        [[ $mac_re ]] || return

        # Determine the network interfaces matching the MAC addresses from the
        # NBFT, read their drivers using readlink, and install them.
        # Note: readlink returns error if /sys/class/net/*/device doesn't exist,
        # ignore xargs return code to avoid the pipeline failing
        grep -lE "$mac_re" /sys/class/net/*/address \
            | sed 's,address$,device/driver/module,' \
            | { xargs -r readlink || true; } \
            | sed s,.*/,,g \
            | sort -u \
            | instmods
    fi
}

# called by dracut
cmdline() {
    local _hostnqn
    local _hostid
    local -a _nbft_subsystems

    # Generate "rd.nvmf.discover=" cmdline parameters for NVMeoF devices found
    # on the host (in hostonly mode).
    # Depending on the value of $nvmf_nbft_mode, skip devices discovered
    # from the NBFT.
    # shellcheck disable=SC2317,SC2329  # called later by for_each_host_dev_and_slaves
    gen_nvmf_cmdline() {
        local _dev=$1
        local trtype

        [[ -L "/sys/dev/block/$_dev" ]] || return 0
        cd -P "/sys/dev/block/$_dev" || return 0
        if [ -f partition ]; then
            cd ..
        fi
        for d in device/nvme*; do
            [ -L "$d" ] || continue
            if readlink "$d" | grep -q nvme-fabrics; then
                read -r trtype < "$d"/transport
                break
            fi
        done

        [[ $trtype ]] || return 0
        [[ $trtype == tcp && $nvmf_nbft_mode == nbft ]] \
            && __nvmf_has_nbft && return 0

        nvme list-subsys "${PWD##*/}" -o json | jq -j '
if type == "array" then .[] else . end |
.Subsystems[]? |
.Paths[]? |
select (.Transport == "'"$trtype"'") |
(if .AddressDetails then
  {
     traddr: .AddressDetails.traddr,
     host_traddr: .AddressDetails.host_traddr,
     trsvcid: .AddressDetails.trsvcid
  }
else
  (.Address | split(",") | map(split("=") | {(.[0]): .[1]}) | add) as $fields |
  {
     traddr: $fields.traddr,
     host_traddr: $fields.host_traddr,
     trsvcid: $fields.trsvcid
  }
end) as $vals |
if $vals.traddr == null and $vals.trsvcid == null and $vals.host_traddr == null
then ""
# In "match" mode, do not generate discover lines for subsystems specified in the NBFT
elif ("'"$nvmf_nbft_mode"'" == "match") and
     (($vals.traddr + "," + $vals.trsvcid) | in ('"$_nbft_subsystems"'))
then ""
# "//" is the "alternative" operator in jq. It avoids null values.
# \(expr) is jq syntax for interpolation of an expression into a string.
else " rd.nvmf.discover=\(.Transport),\($vals.traddr // ""),\($vals.host_traddr // ""),\($vals.trsvcid // "")"
end'
    }

    if [ -f /etc/nvme/hostnqn ]; then
        read -r _hostnqn < /etc/nvme/hostnqn
        echo -n " rd.nvmf.hostnqn=${_hostnqn}"
    fi
    if [ -f /etc/nvme/hostid ]; then
        read -r _hostid < /etc/nvme/hostid
        echo -n " rd.nvmf.hostid=${_hostid}"
    fi

    if dracut_module_included network-manager; then
        # NetworkManager 1.54 and newer reads the NBFT natively.
        # If this version is detected, set rd.nvmf.nm=1 in order to simplify
        # the NBFT handling in the initrd
        mapfile -t -d . version < <(NetworkManager --version)
        [[ ${#version[@]} == 3 &&
            $((10000 * version[0] + 100 * version[1] + version[2])) -ge 15400 ]] \
            && echo -n " rd.nvmf.nm=1 "
    fi

    [[ $hostonly ]] || [[ $mount_needs ]] && {
        # Create a string representing the NVMe subsystems reported by the NBFT
        # in the form of a JSON object.
        # E.g. '{ "192.168.1.100:4420": 0, ... }'
        # It's used in the jq code in gen_nvmf_cmdline() above to check whether
        # or not a given subsystem was specified in the NBFT.
        # An object (rather than an array) must be used because jq's in()
        # builtin looks for keys only, not values.
        # The '+ [{}]' avoids a "null" result for systems without NBFT.
        # The "add" at the end combines an array of objects into one object.
        _nbft_subsystems=$(nvme nbft show -s -o json \
            | jq '[.[].subsystem[] |
                                   select(.transport == "tcp") |
                                   {(.traddr + "," + .trsvcid): 0}] + [{}] |
                                   add')
        pushd . > /dev/null
        for_each_host_dev_and_slaves gen_nvmf_cmdline
        popd > /dev/null || exit
    }
}

# called by dracut
install() {
    if [[ $hostonly_cmdline == "yes" ]]; then
        local _nvmf_args
        _nvmf_args=$(cmdline)
        [[ "$_nvmf_args" ]] && printf "%s" "$_nvmf_args" >> "${initdir}/etc/cmdline.d/20-nvmf-args.conf"
    fi
    inst_simple -H "/etc/nvme/hostnqn"
    inst_simple -H "/etc/nvme/hostid"

    inst_multiple ip sed

    inst_script "${moddir}/nvmf-autoconnect.sh" /sbin/nvmf-autoconnect.sh
    inst_script "${moddir}/nbftroot.sh" /sbin/nbftroot

    inst_multiple nvme jq
    inst_hook cmdline 92 "$moddir/parse-nvmf-boot-connections.sh"
    inst_simple -H "/etc/nvme/discovery.conf"
    inst_simple -H "/etc/nvme/config.json"
    inst_rules /usr/lib/udev/rules.d/71-nvmf-iopolicy-netapp.rules
    inst_rules "$moddir/95-nvmf-initqueue.rules"
}
