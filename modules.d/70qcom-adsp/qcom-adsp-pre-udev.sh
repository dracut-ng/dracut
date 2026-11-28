#!/bin/sh

# Ensure ADSP module is loaded and Type-C USB busses are reset before
# filesystems are mounted

# Succeeds if firmware $1 is in the initrd, looking in the same places as
# the kernel, with or without a compression suffix
qcom_adsp_have_fw() {
    for _dir in ${_fw_path:+"$_fw_path"} "/lib/firmware/updates/$_kver" \
        /lib/firmware/updates "/lib/firmware/$_kver" /lib/firmware; do
        for _suffix in "" .zst .xz; do
            [ -e "$_dir/$1$_suffix" ] && return 0
        done
    done
    return 1
}

# Succeeds if all firmwares named in the devicetree for remoteproc $1 are
# in the initrd
qcom_adsp_have_rproc_fw() {
    _fws=
    if [ -e "$1/of_node/firmware-name" ]; then
        # contents of firmware-name file is 0 delimited
        _fws=$(tr '\0' ' ' < "$1/of_node/firmware-name")
    fi
    _fw=
    for _fw in $_fws; do
        if ! qcom_adsp_have_fw "$_fw"; then
            warn "qcom-adsp: missing firmware $_fw, not loading qcom_q6v5_pas early"
            return 1
        fi
    done
    if [ -z "$_fw" ]; then
        warn "qcom-adsp: unknown firmware for ${1##*/}, not loading qcom_q6v5_pas early"
        return 1
    fi
    return 0
}

_fw_path=
if [ -e /sys/module/firmware_class/parameters/path ]; then
    read -r _fw_path < /sys/module/firmware_class/parameters/path
fi
read -r _kver < /proc/sys/kernel/osrelease

# The driver boots all PAS remoteprocs as soon as it probes and does not
# retry loading their firmwares after switch-root, so only load it early if
# the firmwares of all of them are in the initrd. Otherwise leave it to udev
# after switch-root, where the firmwares of the rootfs are available.
_adsp=
for _rproc in /sys/bus/platform/devices/*.remoteproc; do
    [ -e "$_rproc/modalias" ] || continue
    read -r _alias < "$_rproc/modalias"
    case "$_alias" in
        *qcom,sc8280xp-adsp-pas* | *qcom,x1e80100-adsp-pas*)
            _adsp=1
            ;;
        *qcom,sc8280xp-*-pas* | *qcom,x1e80100-*-pas*) ;;
        *)
            continue
            ;;
    esac
    if ! qcom_adsp_have_rproc_fw "$_rproc"; then
        _adsp=
        break
    fi
done

if [ -n "$_adsp" ]; then
    modprobe qcom_q6v5_pas
fi

unset _adsp _alias _dir _fw _fw_path _fws _kver _rproc _suffix
unset -f qcom_adsp_have_fw qcom_adsp_have_rproc_fw
