#!/usr/bin/env bash

echo "Start!"
for f in $(find . -name '*.java');
do
    perl -nle 'print if m{^[[:ascii:]]+$}' $f > $f.new
    rc=$?
    if [[ $rc -eq 0   ]]; then
        mv -f $f.new $f
    else
        echo "$f meets Error!"
    fi
done
echo "Finished!"
