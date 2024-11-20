#!/bin/bash

# script for integration testing invoked by GitHub Actions
# wraps configure && make
# assumes that it runs inside a CI container

set -e
if [ "$V" = "2" ]; then set -x; fi

[[ -d ${0%/*} ]] && cd "${0%/*}"/../

# remove dracut modules that are being tested
(
    cd modules.d
    for dir in *; do
        rm -rf /usr/lib/dracut/modules.d/[0-9][0-9]"${dir/#[0-9][0-9]/}"
    done
)

# disable building documentation by default
[ -z "$enable_documentation" ] && export enable_documentation=no

# shellcheck disable=SC2086
./configure $CONFIGURE_ARG

# treat warnings as error
# shellcheck disable=SC2086
CFLAGS="-Wextra -Werror" make TEST_RUN_ID="${TEST_RUN_ID:=$1}" TESTS="${TESTS:=$2}" V="${V:=1}" $MAKEFLAGS ${TARGETS:=all install check}
