#!/usr/bin/env bash
set -ex

currentPath=$(pwd)
product_name=${currentPath##*/}
temp=${currentPath%/*}
brand_name=${temp##*/}
suffix_main="主图"
suffix_detail="详情"
extension=".jpg"
i=0
while test $# -gt 0; do
    i=$((i+1))
    newfilename="${brand_name}_${product_name}_${suffix_main}_${i}${extension}"
    mv $1 $newfilename
    shift 1
done

cd images
i=0
for file in $(ls .); do
    i=$((i+1))
    index="$i"
    if [ i lt 9 ]; then
        index="0${i}"
    fi
    newfilename="${brand_name}_${product_name}_${suffix_detail}_${index}${extension}"
    mv $file $newfilename
done

mergejpg.sh "${brand_name}_${product_name}_${suffix_detail}"
