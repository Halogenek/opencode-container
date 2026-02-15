#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${SCRIPT_DIR}"/functions.sh

main() {
    change_user_if_necessary "$@"
    check_config

    if [ "$1" = "-s" ]; then
        shift # remove '-s'
        command="$1"
        shift # remove the command
        "$command" "$@"
    else
        opencode "$@"
    fi
}

main "$@"
