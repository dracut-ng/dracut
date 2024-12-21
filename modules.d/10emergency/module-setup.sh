#!/bin/bash

check() {
    require_binaries sulogin || return 1
}

depends() {
    echo base
}

# called by dracut
install() {
    inst_multiple sulogin

    inst_script "$moddir/rdsosreport.sh" "/sbin/rdsosreport"
    inst_script "$moddir/dracut-emergency.sh" /bin/dracut-emergency

    if dracut_module_included "systemd"; then
        inst_simple "$moddir/emergency.service" "${systemdsystemunitdir}"/emergency.service
        inst_simple "$moddir/dracut-emergency.service" "${systemdsystemunitdir}"/dracut-emergency.service
        inst_simple "$moddir/emergency.service" "${systemdsystemunitdir}"/rescue.service
    fi
}
