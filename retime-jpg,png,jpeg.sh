#!/bin/bash

dir="test"

# 检查 exiftool 是否安装
if ! command -v exiftool &>/dev/null; then
    echo "请先安装 exiftool，例如: sudo apt install libimage-exiftool-perl"
    exit 1
fi

# 按最后修改时间排序并处理
find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
  -printf "%T@ %p\n" | sort -n | while read -r timestamp filepath; do
    # 格式化时间为 YYYYMMDD_HHMMSS
    newname=$(date -d @"${timestamp%.*}" +"%Y%m%d_%H%M%S")

    # 获取文件扩展名（小写）
    ext="${filepath##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # 防止重名
    counter=1
    finalname="${dir}/${newname}.${ext_lower}"
    while [ -e "$finalname" ]; do
        finalname="${dir}/${newname}_$counter.${ext_lower}"
        counter=$((counter+1))
    done

    # 重命名
    mv "$filepath" "$finalname"

    # 修改 EXIF 拍摄时间和文件修改时间
    exiftool "-DateTimeOriginal=$(date -d @"${timestamp%.*}" +"%Y:%m:%d %H:%M:%S")" -overwrite_original "$finalname"
    touch -m -t "$(date -d @"${timestamp%.*}" +"%Y%m%d%H%M.%S")" "$finalname"

    echo "处理完成: $finalname"
done
