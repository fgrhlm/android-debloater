#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

usage () {
    echo -e "Usage:\n ARGS:\n -d <device_key>\tandroid device key.\n -f <file_path>\t\tapp manifest file.\n\n FLAGS:\n -n\t\t\tdon't prompt before uninstalling."
    exit 0
}

check_adb_installed () {
    if ! command -v adb 2>&1 >/dev/null
    then
        echo "adb not installed, please install before continuing"
        exit 1
    fi
}

check_adb_device () {
    adb -s $DEVICE_KEY get-state 1> /dev/null
    if [ $? -eq 0 ]; then
        echo "Device: ${DEVICE_KEY}"
    fi
}

prompt_continue () {
    local confirm=

    while true; do
        read -p "${1} [y/n]: " confirm
        case $confirm in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
        esac
    done
}
parse_args () {
    if [[ "$#" -lt 2 ]]; then
        usage
    fi

    while getopts "hd:f:n" o; do
        case "${o}" in
            d)
                DEVICE_KEY=${OPTARG}
                ;;
            f)
                APP_MANIFEST=${OPTARG}
                ;;
            n)
                NO_CONFIRM=1
                ;;
            h | *)
                usage
                ;;
        esac
    done

    shift $((OPTIND-1))

    if [[ -z "${DEVICE_KEY}" || "${DEVICE_KEY}" == "" ]]; then
        echo -e "Invalid or missing device key!\n"
        usage
    fi

    if [[ -z "${APP_MANIFEST}" || ! -f "${APP_MANIFEST}" ]]; then
        echo -e "Invalid or missing app manifest!\n"
        usage
    fi
}

uninstall () {
    adb -s "${DEVICE_KEY}" shell pm uninstall --user 0 -k "$1"
}

debloat () {
    echo "Starting debloating script.."

    for app in $(cat "${APP_MANIFEST}")
    do
        if [[ "${NO_CONFIRM}" -gt 0 ]]; then
            uninstall "${app}"
        else
            prompt_continue "Uninstall ${app}?" && uninstall "${app}" || echo "skipping..";
        fi
    done
}

main () {
    local DEVICE_KEY=
    local APP_MANIFEST=
    local NO_CONFIRM=0
    
    check_adb_installed
    parse_args "$@"
   
    check_adb_device
    echo "App manifest: ${APP_MANIFEST}"
    
    if [[ "${NO_CONFIRM}" -gt 0 ]]; then
        echo "The script will not prompt before uninstalling."
    fi

    prompt_continue "Is this ok?" && debloat || echo "Exiting without touching device."; exit 0; 

    echo "Done! Bye!"
}

main "$@"
