#!/usr/bin/env bash

set -e

TEMP_FILE=/tmp/md5sums.txt
LOG_FILE=/tmp/md5sums.log
READY_DELETE=/tmp/duplicated
rm -rf ${TEMP_FILE}
touch ${TEMP_FILE}
rm -rf ${LOG_FILE}
touch ${LOG_FILE}
mkdir ${READY_DELETE}

echoWarning()
{
    # Yellow
    echo -e "\033[0;33m${1}\033[0m"
}

checkMd5InDir() {
    pushd "$1"
    for oneFile in *; do
        [[ "${oneFile}" == "*" ]] && { echoWarning "$1 is an empty folder."; break; }
        if [[ -d $oneFile ]]; then
            checkMd5InDir "$oneFile"
        else
            oneMd5=$(md5sum "${oneFile}" | tr -s ' ' | cut -d ' ' -f 1)
            set +e
            grepResult=$(grep "${oneMd5}" ${TEMP_FILE})
            if [[ $? -eq 0 ]]; then
                echo "Found duplicated! ${oneFile}"
                echo "Duplicated! $(pwd)/${oneFile}, MD5: ${oneMd5}, Grep Result: ${grepResult}" >> ${LOG_FILE}
                mv "$(pwd)/${oneFile}" "${READY_DELETE}"
            else
                md5sum "${oneFile}" >> ${TEMP_FILE}
            fi
            set -e
        fi
    done
    popd
}

checkMd5InDir "$1"
