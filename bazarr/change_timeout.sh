#!/usr/bin/with-contenv bash
# git is already installed from the base package so we may as well borrow it
  echo '----------------------------------'
  echo '| Replacing Timeouts in Traktarr |'
  echo '----------------------------------'
  echo

git grep -lG "timeout=[0-9]" | xargs sed -i '/timeout=[0-9]*/{
h
s//timeout=300/g
H
x
s/\n/ >>> /
w /dev/stdout
x
}'

echo Done!