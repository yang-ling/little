#!/usr/bin/bash
usage="$(basename "$0") [options]

options:
    -m|--markdown                       Set scratch type to markdown
    -t|--text                           Set scratch type to txt
    -h|--help                           show this help text"

SCRATCH_MARKDOWN_EXTENSION=".md"
SCRATCH_MAIL_EXTENSION=".eml"
SCRATCH_TEXT_EXTENSION=".txt"
scratch_extension="$SCRATCH_MAIL_EXTENSION"
options=$(getopt -o hm --long "help,mail" -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    echo "$usage"
    exit 1
}

eval set -- "$options"

while test $# -gt 0; do
  case "$1" in
      -m|--markdown)
          scratch_extension="$SCRATCH_MARKDOWN_EXTENSION"
          shift 1
          ;;
      -t|--text)
          scratch_extension="$SCRATCH_TEXT_EXTENSION"
          shift 1
          ;;
      -h|--help)
          echo "$usage"
          exit 0
          ;;
      --)
          shift 1
          ;;
      *)
          # In most cases, `getopt' will check incorrect options for us, but if
          # incorrect options appears after `--', `getopt' cannot detect that,
          # so we need this case branch to catch such error.
          # For example: print.sh -- filename.pdf -z
          # -z is an incorrect option but `getopt' cannot detect it.
          echo "Incorrect options provided: $1"
          echo "$usage"
          exit 1
          ;;
  esac
done

tmpfile=$(mktemp --suffix="$scratch_extension")
vim "$tmpfile"
