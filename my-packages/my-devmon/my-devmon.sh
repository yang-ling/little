#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
/usr/bin/devmon -s --info-on-mount --exec-on-drive "notify-send -t 3000 \"Device %f %d %l has been automounted\"" --exec-on-disc "notify-send -t 3000 \"Disk %f %d %l has been automounted\"" --exec-on-video "notify-send -t 3000 \"DVD %f %d %l has been automounted\"" --exec-on-audio "notify-send -t 3000 \"CD %f %d %l has been automounted\"" --exec-on-unmount "notify-send -t 3000 \"Device %f %d %l has been UNmounted\"" --exec-on-unmount "/usr/local/bin/clean-umounted" --exec-on-remove "notify-send -t 3000 \"Device %f %d %l has been REMOVED\"" --exec-on-remove "/usr/local/bin/clean-umounted"
