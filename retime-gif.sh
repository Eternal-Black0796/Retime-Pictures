#!/bin/bash

dir="test"

# 按最后修改时间排序处理 GIF 文件
find "$dir" -type f -iname "*.gif" -printf "%T@ %p\n" | sort -n | while read -r timestamp filepath; do
    # 格式化时间为 YYYYMMDD_HHMMSS
    newname=$(date -d @"${timestamp%.*}" +"%Y%m%d_%H%M%S")

    # 防止重名
    counter=1
    finalname="${dir}/${newname}.gif"
    while [ -e "$finalname" ]; do
        finalname="${dir}/${newname}_$counter.gif"
        counter=$((counter+1))
    done

    # 重命名
    mv "$filepath" "$finalname"

    # 修改文件系统时间
    touch -m -t "$(date -d @"${timestamp%.*}" +"%Y%m%d%H%M.%S")" "$finalname"

    echo "处理完成: $finalname"
done
