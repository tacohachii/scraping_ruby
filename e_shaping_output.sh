#!/bin/bash

list=(`ls -v1 output/`)

echo ${#list[@]}

for file in "${list[@]}"; do
  cat output/$file >> output_db.csv
done

# 見出し127個を削除する（最後一番上にのみつける）
