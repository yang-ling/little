#!/usr/bin/env bash

checkExist() {
    command -v $1 > /dev/null 2>&1 || { echo >&2 "ERROR: $1 not found!"; exit 1; }
}

checkDependenciesForPagenumber() {
    checkExist "pdflatex"
    checkExist "pdftk"
    checkExist "gs"
}

doAddPageNumbers() {
    set -e
    PAGE=$(pdfinfo $filename | grep "Pages")
    PAGE=$(echo $PAGE | cut -c 8-)

    rm -rf /tmp/pdfnumber
    mkdir /tmp/pdfnumber
    cd /tmp/pdfnumber/

    echo "Creating Page Number file for "$PAGE" pages"
    (
    printf '\\documentclass[12pt,letter]{article}\n'
    printf '\\usepackage{multido}\n'
    printf '\\usepackage[hmargin=.8cm,vmargin=1.5cm,nohead,nofoot]{geometry}\n'
    printf '\\begin{document}\n'
    printf '\\multido{}{'$PAGE'}{\\vphantom{x}\\newpage}\n'
    printf '\\end{document}'
    ) >./numbers.tex

    pdflatex -interaction=batchmode numbers.tex 1>/dev/null

    echo "Bursting PDF's"
    pdftk $filename burst output prenumb_burst_%03d.pdf
    pdftk numbers.pdf burst output number_burst_%03d.pdf

    echo "Adding Page Numbers"
    mkdir /tmp/pdfnumber/temp
    for i in $(seq -f %03g 1 $PAGE) ; do \
        pdftk prenumb_burst_$i.pdf background number_burst_$i.pdf output ./temp/numbered-$i.pdf ; done

    echo "Merging .pdf files"
    cd ./temp

    pdftk ./*.pdf cat output ./book_bloat.pdf

    echo "Optimizing PDF file"
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE \-dQUIET -dBATCH -sOutputFile=book.pdf book_bloat.pdf 2>/dev/null

    echo "Your file is /tmp/pdfnumber/temp/book.pdf"

    if [[ -n "$output" ]]; then
        cp -f /tmp/pdfnumber/temp/book.pdf $output
        echo "Your output file is $output"
    fi

    echo "Optimizing finished."
    set +e
}

usage="$(basename "$0")  input_pdf_file_name output_pdf_file_name"

[[ $# -eq 1 ]] || [[ $# -eq 2 ]]|| { echo "Invalid parameter numbers."; echo "$usage"; exit 1; }
[[ -f "$1" ]] || { echo "Input file $1 doesn't exist!"; exit 1; }
filename="$1"
output="$2"
if [[ ! ${filename: -4} == ".pdf" ]]; then
    echo "Input file is $filename, and it is not PDF. This tool only supports PDF file."
    exit 1
fi

checkDependenciesForPagenumber
doAddPageNumbers
