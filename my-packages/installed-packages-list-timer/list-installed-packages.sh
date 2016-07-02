#!/usr/bin/env bash

set -x

whatihave-official() {
    pacman -Qeni | awk '/^Name/ { name=$3 } /^Groups/ { if ( $3 != "base" && $3 != "base-devel" ) { print name } }'
}

whatihave-aur() {
    /usr/bin/pacman -Qemq
}

main() {
    line="${1}"
    root_folder=$(echo "${line}" | cut -d ',' -f 1)
    prefix=$(echo "${line}" | cut -d ',' -f 2)
    [[ -d "${root_folder}" ]] || { echo "${root_folder} doesn't exist!"; exit 1; }
    pushd "${root_folder}"
    whatihave-official > ${prefix}-official-$(date +'%F').txt
    whatihave-aur > ${prefix}-aur-$(date +'%F').txt
    popd
}


while IFS='' read -r line ; do
    [[ -z "${line}" ]] && continue
    [[ "$line" =~ ^#.*$ ]] && continue
    main "${line}"
done < "$1"

set +x
