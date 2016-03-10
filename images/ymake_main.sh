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
    mv $file $newfilename
done

cd images
i=0
for file in $(ls .); do
    i=$((i+1))
    index="$i"
    if [ $i -lt 10 ]; then
        index="0${i}"
    fi
    newfilename="${brand_name}_${product_name}_${suffix_detail}_${index}${extension}"
    mv $file $newfilename
done

mergejpg.sh "${brand_name}_${product_name}_${suffix_detail}"

filesize=$(stat -c%s "${brand_name}_${product_name}_${suffix_detail}.jpg")
if [ $filesize -lt 1000000 ]; then
    echo "Size is fine."
elif [ $filesize -ge 1000000 ] && [ $filesize -lt 1400000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}" 50
elif [ $filesize -ge 1400000 ] && [ $filesize -lt 2400000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}" 34
elif [ $filesize -ge 2400000 ] && [ $filesize -lt 3400000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}" 25
elif [ $filesize -ge 3400000 ] && [ $filesize -lt 4400000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}" 20
elif [ $filesize -ge 4400000 ] && [ $filesize -lt 5400000 ]; then
    mycrop.sh "${brand_name}_${product_name}_${suffix_detail}" 15
else
    echo "Too large!"
    exit 1
fi
