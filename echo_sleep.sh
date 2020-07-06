#!/bin/bash

echo_sleep() {
  MAX=$1
  COUNT=0
  while [ $COUNT -ne $MAX ]
  do
      echo -e "待機: $COUNT/$MAX （秒）\c"
      sleep 1
      COUNT=`expr $COUNT + 1`
      echo -e "\r\c"
  done
  echo "待機: $MAX/$MAX （秒）"   
}
