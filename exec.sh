#!/bin/bash

dir=`dirname $0`
source ${dir}/echo_sleep.sh

# 引数判定
if [ $# != 1 ]; then
  echo "引数の数が間違っています"
  exit 1
fi

for i in {1..123}; do
  echo start $i
  ruby src/main.rb $(($i*5-4+$1)) $(($i*5+$1))
  # エラー処理
  if [ $? -gt 0 ]; then
    echo 
    echo Erorr $i
    echo Erorr $i >> output_error.txt
    date '+%T'
    afplay ./sounds/error.mp3
    echo_sleep 100
  else
    afplay ./sounds/success.mp3
  fi
  echo
  echo_sleep 240
  echo
done
echo Finish!!!
afplay ./sounds/done.mp3
