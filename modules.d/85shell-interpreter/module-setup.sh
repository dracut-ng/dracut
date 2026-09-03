#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Module dependency requirements.

# due to the dependencies below, this dracut module needs to be ordered later than the bash, dash and busybox dracut modules

depends() {
    # The priority order is by module order: bash busybox dash
    for shell in bash busybox dash; do
        if dracut_module_included "$shell"; then
            echo "$shell"
            return 0
        fi
    done

    shell=$(realpath /bin/sh)
    shell=${shell##*/}

    echo "$shell"
    return 0
}
