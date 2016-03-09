#!/usr/bin/env bash

set -ex

convert $1.jpg -crop 100%x$2% +repage $1%d.jpg
