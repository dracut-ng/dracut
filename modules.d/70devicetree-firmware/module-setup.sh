#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Devicetree based platforms may need board / model specific firmwares in
# the initrd. E.g. Qualcomm Snapdragon Windows-on-Arm (WoA) laptops need model
# specific firmware files in the initrd for the ADSP/Type-C controller.
# The filenames for these firmware files are specified in "firmware-name"
# devicetree properties, this module copies any such files to the initrd.

# called by dracut
check() {
    if [[ $hostonly ]]; then
        [ -d /sys/firmware/devicetree/base ] || return 1
    else
        # ATM install_generic only copies aarch64 qcom model specific firmwares
        [ "$DRACUT_ARCH" = "aarch64" ] || return 1
    fi
    return 0
}

# hostonly install (hostonly / generic use completely different approaches)
install_hostonly() {
    local _fw_names=()
    # contents of firmware-name file is 0 delimited
    while read -r -d $'\0' _fw; do
        _fw_names+=("$_fw")
    done < <(find /sys/firmware/devicetree/base -name firmware-name -exec cat {} \;)

    local _fw_files=()
    for _fw_name in "${_fw_names[@]}"; do
        # shellcheck disable=SC2154 # fw_dir is set by dracut.sh
        for _fwdir in $fw_dir; do
            # add '*' after firmware-name for .gz, etc. compression
            for _fw in "$_fwdir/$_fw_name"*; do
                [ -f "$_fw" ] || continue
                _fw=${_fw#"${dracutsysrootdir-}"}
                _fw_files+=("$_fw")
                break 2
            done
        done
    done
    ((${#_fw_files[@]} > 0)) && inst_multiple -o "${_fw_files[@]}"
}

# generic install (hostonly / generic use completely different approaches)
install_generic() {
    local _fw_files=()
    # ATM only qcom WoA laptops need this
    for _soc in qcom/sc8280xp qcom/x1e80100; do
        # shellcheck disable=SC2154 # fw_dir is set by dracut.sh
        for _fwdir in $fw_dir; do
            # add '*' after mbn, elf for .gz, etc. compression
            for _fw in "$_fwdir/$_soc"/*/*/*.mbn* "$_fwdir/$_soc"/*/*/*.elf*; do
                [ -f "$_fw" ] || continue
                _fw=${_fw#"${dracutsysrootdir-}"}
                _fw_files+=("$_fw")
            done
        done
    done
    ((${#_fw_files[@]} > 0)) && inst_multiple -o "${_fw_files[@]}"
}

# called by dracut
install() {
    if [[ $hostonly ]]; then
        install_hostonly
    else
        install_generic
    fi
}
