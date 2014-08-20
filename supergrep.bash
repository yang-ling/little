#!/usr/bin/bash

# ignore dir
# ignore file
# multiple pattern
# supergreprc

while [ "$1" != "" ]; do
    case $1 in
        -cv | --convert )       convert=1
                                ;;
        -ck | --check )         check=1
                                ;;
        -o | --out )            shift
                                outdir=$1
                                ;;
        -a | --all )            check=1
                                convert=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
