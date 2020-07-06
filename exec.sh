#!/bin/bash

dir=`dirname $0`
source ${dir}/echo_sleep.sh

# 引数判定
if [ $# != 1 ]; then
  echo "引数の数が間違っています"
  exit 1
fi

for i in {19..120}; do
  echo start $i
  ruby src/main.rb $(($i*5-4+$1)) $(($i*5+$1))
  # エラー処理
  if [ $? -gt 0 ]; then
    echo 
    echo Erorr $i
    date '+%T'
    break
  fi
  echo
  echo_sleep 240
  echo
done
