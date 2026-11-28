#!/bin/bash
# Best-effort keyboard-layout line for the LUKS passphrase prompt: name the
# configured console keymap, print nothing when unsure (no default claim, no
# warning). Informational only - never reconfigures the keyboard, exits 0.

# plymouth draws its own prompt and handles the keymap itself.
if [[ -e /run/plymouth/pid ]] || plymouth --ping 2> /dev/null; then
    exit 0
fi
# getarg() is dracut's option parser from /lib/dracut-lib.sh (installed by the
# always-included base module); keys match exactly, so both spellings are
# queried - systemd-vconsole-setup applies rd.vconsole.keymap too.
command -v getarg > /dev/null || . /lib/dracut-lib.sh
# The kernel command line wins over /etc/vconsole.conf; else the last KEYMAP=
# line of the file, with one layer of surrounding quotes stripped.
keymap=$(getarg vconsole.keymap rd.vconsole.keymap)
if [[ -z $keymap && -r /etc/vconsole.conf ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
        [[ $line == KEYMAP=* ]] && keymap=${line#KEYMAP=}
    done < /etc/vconsole.conf
    keymap=${keymap#[\'\"]}
    keymap=${keymap%[\'\"]}
fi
[[ -n $keymap ]] && printf 'Keyboard layout: %s\n' "$keymap" > /dev/console
exit 0
