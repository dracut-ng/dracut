#!/bin/sh

# Parse the mutable-root masterkey configuration as data. Assignments are
# explicit so values from the real root are never evaluated as shell code.
read_masterkey_config() {
    _file=$1
    [ -f "${_file}" ] || return 0

    while IFS="=" read -r _key _value; do
        case "${_key}" in "" | \#*) continue ;; esac

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
            MASTERKEY) MASTERKEY="${_value}" ;;
            MASTERKEYTYPE) MASTERKEYTYPE="${_value}" ;;
            MULTIKERNELMODE) MULTIKERNELMODE="${_value}" ;;
            PCRLOCKNUM)
                if isdigit "${_value}"; then
                    PCRLOCKNUM="${_value}"
                else
                    PCRLOCKNUM=11
                fi
                ;;
        esac
    done < "${_file}"

    unset _file _key _value
    return 0
}
