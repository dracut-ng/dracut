#!/usr/bin/env bash
set -eu

# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# shellcheck disable=SC2034
TEST_DESCRIPTION="dracut getarg command"

test_check() {
    if ! [[ -x "$PKGLIBDIR/dracut-util" ]]; then
        echo "Test needs dracut-util... Skipping"
        return 1
    fi
}

test_setup() {
    ln -sfn "$PKGLIBDIR"/dracut-util "$TESTDIR"/dracut-getarg
    ln -sfn "$PKGLIBDIR"/dracut-util "$TESTDIR"/dracut-getargs
    ln -sfn "$PKGLIBDIR"/modules.d/[0-9][0-9]base/dracut-lib.sh "$TESTDIR"/dracut-lib.sh
    ln -sfn "$PKGLIBDIR"/modules.d/[0-9][0-9]base/dracut-dev-lib.sh "$TESTDIR"/dracut-dev-lib.sh
    return 0
}

test_run() {
    set -x
    (
        cd "$TESTDIR" || exit 1
        # Intentional trailing quotation mark to test error handling
        export CMDLINE='key1=0 key2=val key2=val2 key3="  val  3  " "  key 4  ="val4 "key  5=val  5" "key 6=""val  6" key7="foo"bar" baz="end "  key8  =  val 8  "
"key 9"="val 9" "'

        ret=0

        unset TEST
        declare -A TEST
        TEST=(
            ["key1"]="0"
            ["key2"]="val2"
            ["key3"]="  val  3  "
            ["  key 4  "]="val4"
            ["key  5"]="val  5"
            ["key 6"]='"val  6'
            ["key7"]='foo"bar" baz="end'
            ["  key8  "]="  val 8  "
            ['key 9"']="val 9"
        )
        for key in "${!TEST[@]}"; do
            if ! val=$(./dracut-getarg "${key}="); then
                echo "'$key' == '${TEST[$key]}', but not found" >&2
                ret=$((ret + 1))
            else
                if [[ $val != "${TEST[$key]}" ]]; then
                    echo "'$key' != '${TEST[$key]}' but '$val'" >&2
                    ret=$((ret + 1))
                fi
            fi
        done

        declare -a INVALIDKEYS

        INVALIDKEYS=("key" "4" "5" "6" "key8" "9" '"' "baz")
        for key in "${INVALIDKEYS[@]}"; do
            if val=$(./dracut-getarg "$key"); then
                echo "key '$key' should not be found"
                ret=$((ret + 1))
            fi
            # must have no output
            [[ $val ]] && ret=$((ret + 1))
        done

        RESULT=("val" "val2")
        readarray -t args < <(./dracut-getargs "key2=")
        ((${#RESULT[@]} == ${#args[@]})) || ret=$((ret + 1))
        for ((i = 0; i < ${#RESULT[@]}; i++)); do
            [[ ${args[$i]} == "${RESULT[$i]}" ]] || ret=$((ret + 1))
        done

        val=$(./dracut-getarg "key1") || ret=$((ret + 1))
        [[ $val == "0" ]] || ret=$((ret + 1))

        val=$(./dracut-getarg "key2=val") && ret=$((ret + 1))
        # must have no output
        [[ $val ]] && ret=$((ret + 1))
        val=$(./dracut-getarg "key2=val2") || ret=$((ret + 1))
        # must have no output
        [[ $val ]] && ret=$((ret + 1))

        export PATH=".:$PATH"
        # shellcheck disable=SC2034  # NEWROOT defined for dracut-lib.sh, set by base/init.sh
        NEWROOT=$(mktemp -d -p "$TESTDIR" newroot.XXXXXXXXXX)
        # shellcheck disable=SC2034  # PREFIX defined for dracut-lib.sh to avoid creating /run/initramfs
        PREFIX=/nonexistent

        . dracut-dev-lib.sh
        . dracut-lib.sh

        # shellcheck disable=SC2317,SC2329  # overwrites debug_off from dracut-lib.sh
        debug_off() {
            :
        }

        # shellcheck disable=SC2317,SC2329  # overwrites debug_on from dracut-lib.sh
        debug_on() {
            :
        }

        # shellcheck disable=SC2317,SC2329  # called later by getarg in dracut-lib.sh
        getcmdline() {
            echo "rd.break=cmdline rd.lvm rd.auto=0 rd.auto rd.retry=10"
        }
        RDRETRY=$(getarg rd.retry)
        [[ $RDRETRY == "10" ]] || ret=$((ret + 1))
        getarg rd.break=cmdline || ret=$((ret + 1))
        getargbool 1 rd.lvm || ret=$((ret + 1))
        getargbool 0 rd.auto || ret=$((ret + 1))

        # shellcheck disable=SC2317,SC2329  # called later by getarg in dracut-lib.sh
        getcmdline() {
            echo "rd.break=cmdlined rd.lvm=0 rd.auto rd.auto=1 rd.auto=0"
        }
        getarg rd.break=cmdline && ret=$((ret + 1))
        getargbool 1 rd.lvm && ret=$((ret + 1))
        getargbool 0 rd.auto && ret=$((ret + 1))

        # shellcheck disable=SC2317,SC2329  # called later by getarg in dracut-lib.sh
        getcmdline() {
            echo "ip=a ip=b ip=dhcp6"
        }
        getargs "ip=dhcp6" &> /dev/null || ret=$((ret + 1))
        readarray -t args < <(getargs "ip=")
        RESULT=("a" "b" "dhcp6")
        ((${#RESULT[@]} || ${#args[@]})) || ret=$((ret + 1))
        for ((i = 0; i < ${#RESULT[@]}; i++)); do
            [[ ${args[$i]} == "${RESULT[$i]}" ]] || ret=$((ret + 1))
        done

        # shellcheck disable=SC2317,SC2329  # called later by getarg in dracut-lib.sh
        getcmdline() {
            echo "bridge bridge=val"
        }
        readarray -t args < <(getargs bridge=)
        RESULT=("bridge" "val")
        ((${#RESULT[@]} == ${#args[@]})) || ret=$((ret + 1))
        for ((i = 0; i < ${#RESULT[@]}; i++)); do
            [[ ${args[$i]} == "${RESULT[$i]}" ]] || ret=$((ret + 1))
        done

        # shellcheck disable=SC2317,SC2329  # called later by getarg in dracut-lib.sh
        getcmdline() {
            echo "rd.break rd.md.uuid=bf96e457:230c9ad4:1f3e59d6:745cf942 rd.md.uuid=bf96e457:230c9ad4:1f3e59d6:745cf943 rd.shell"
        }
        readarray -t args < <(getargs rd.md.uuid -d rd_MD_UUID=)
        RESULT=("bf96e457:230c9ad4:1f3e59d6:745cf942" "bf96e457:230c9ad4:1f3e59d6:745cf943")
        ((${#RESULT[@]} == ${#args[@]})) || ret=$((ret + 1))
        for ((i = 0; i < ${#RESULT[@]}; i++)); do
            [[ ${args[$i]} == "${RESULT[$i]}" ]] || ret=$((ret + 1))
        done

        return $ret
    )
}

test_cleanup() {
    rm -fr -- "$TESTDIR"/*.rpm
    return 0
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
