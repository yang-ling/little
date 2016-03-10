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

for file in $(ls *.jpg); do
    i=$((i+1))
    newfilename="${brand_name}_${product_name}_${suffix_main}_${i}${extension}"
    if [ "$file" != "$newfilename" ]; then
        mv $file $newfilename
    fi
done

cd images
i=0
for file in $(ls *.jpg); do
    i=$((i+1))
    index="$i"
    if [ $i -lt 10 ]; then
        index="0${i}"
    fi
    newfilename="${brand_name}_${product_name}_${suffix_detail}_${index}${extension}"
    if [ "$file" != "$newfilename" ]; then
        mv $file $newfilename
    fi
done

mergejpg.sh "${brand_name}_${product_name}_${suffix_detail}"

filesize=$(stat -c%s "${brand_name}_${product_name}_${suffix_detail}.jpg")
if [ $filesize -ge 1000000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}"
fi
