#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

getarg "rd.cmdline=ask" || exit 0

sleep 0.25
echo ""
sleep 0.25
echo "    ========================================================================    "
sleep 0.25
echo '(o<                                                                          >o)'
sleep 0.25
echo '//\                        INPUT REQUIRED !!!                                /\\'
sleep 0.25
echo 'V_/_                                                                        _\_V'
sleep 0.25
echo "    ========================================================================    "
sleep 0.25
echo ""
sleep 0.25
echo ' Enter additional kernel command line, or install program, parameters.'
sleep 0.25
echo ' End with a period "." or Ctrl+d in a new line:'
sleep 0.25

# Ignore Ctrl+c (the d key is too close to c)
trap '' SIGINT

# In POSIX sh, read -p is undefined, but dash supports it
# shellcheck disable=SC3045
while read -r -p "> " ${BASH:+-e} line || [ -n "$line" ]; do
    [ "$line" = "." ] && break
    [ -n "$line" ] && printf -- "%s\n" "$line" >> /etc/cmdline.d/99-cmdline-ask.conf
done

# Restore Ctrl+c
trap 'exit 2;' SIGINT

exit 0
