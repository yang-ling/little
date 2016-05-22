#!/usr/bin/env bash
pandoc -N -s --toc --smart --latex-engine=xelatex -V CJKmainfont='WenQuanYi Micro Hei' -V mainfont='DejaVu Sans Mono' -V geometry:margin=1in $1  -o output.pdf
