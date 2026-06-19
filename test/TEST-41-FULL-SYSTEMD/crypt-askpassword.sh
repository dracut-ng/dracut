#!/bin/sh
# Test password agent. Sends wrong passwords WRONG_ATTEMPTS times, then the
# correct one, to verify that systemd-cryptsetup retries indefinitely (tries=0)

HANDLED_DIR=/run/crypt-test-handled
WRONG_COUNT_FILE=/run/crypt-test-wrong-count
CORRECT_PASSWORD="verySecurePassword"
WRONG_PASSWORD="wrongPassword"
WRONG_ATTEMPTS=3

mkdir -p "${HANDLED_DIR}"

while true; do
    for ask_file in /run/systemd/ask-password/ask.*; do
        [ -e "${ask_file}" ] || continue

        ask_name="${ask_file##*/}"
        [ -e "${HANDLED_DIR}/${ask_name}" ] && continue

        socket=$(sed -n 's/^Socket=//p' "${ask_file}")
        [ -n "${socket}" ] || continue

        # Mark handled before responding to avoid double-sending
        : > "${HANDLED_DIR}/${ask_name}"

        count=0
        [ -f "${WRONG_COUNT_FILE}" ] && read -r count < "${WRONG_COUNT_FILE}"

        if [ "${count}" -lt "${WRONG_ATTEMPTS}" ]; then
            count=$((count + 1))
            printf '%s' "${count}" > "${WRONG_COUNT_FILE}"
            printf '%s' "${WRONG_PASSWORD}" | /usr/lib/systemd/systemd-reply-password 1 "${socket}"
        else
            printf '%s' "${CORRECT_PASSWORD}" | /usr/lib/systemd/systemd-reply-password 1 "${socket}"
        fi
    done
    sleep 0.1
done
