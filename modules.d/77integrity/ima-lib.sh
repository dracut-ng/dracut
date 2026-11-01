#!/bin/sh

# Parse an untrusted key=value config file, assigning only caller-selected keys.
# Values remain data: assignments are explicit and never evaluated as shell code.
read_untrusted_key_value_file() {
    _file=$1
    shift
    [ -f "${_file}" ] || return 0
    while IFS="=" read -r _key _value; do
        # skip comments/blank lines
        case "${_key}" in "" | \#*) continue ;; esac
        _key_supported=0
        for _supported_key in "$@"; do
            [ "${_key}" = "${_supported_key}" ] && _key_supported=1
        done
        [ "${_key_supported}" -eq 1 ] || continue
        # Remove one matching quote pair used by existing sysconfig examples.
        case "${_value}" in
            \"*\")
                _value=${_value#\"}
                _value=${_value%\"}
                ;;
            \'*\')
                _value=${_value#\'}
                _value=${_value%\'}
                ;;
        esac
        # The variables are used by the scripts sourcing this file.
        # shellcheck disable=SC2034
        case "${_key}" in
            IMAKEYSDIR) IMAKEYSDIR="${_value}" ;;
            IMAPOLICY) IMAPOLICY="${_value}" ;;
            EVMKEY) EVMKEY="${_value}" ;;
            EVMKEYDESC) EVMKEYDESC="${_value}" ;;
            EVMKEYTYPE) EVMKEYTYPE="${_value}" ;;
            EVMX509) EVMX509="${_value}" ;;
            EVMKEYSDIR) EVMKEYSDIR="${_value}" ;;
            EVM_ACTIVATION_BITS)
                # This value is used in shell arithmetic below.
                if isdigit "${_value}"; then
                    EVM_ACTIVATION_BITS="${_value}"
                else
                    EVM_ACTIVATION_BITS=0
                fi
                ;;
        esac
    done < "${_file}"
    unset _file _key _value _key_supported _supported_key
    return 0
}
