#!/bin/sh
if ! [[ -d build ]]; then
  mkdir -pv build
fi
# go to build
cd build

if ! [[ -d micropython-lib ]]; then
  git clone git@github.com:micropython/micropython-lib
fi

# fetch the most recent code
cd micropython-lib
git fetch origin master
git reset --hard origin/master
# then go back
cd ..

# prepare python files
if ! [[ -d umqtt_package/umqtt ]]; then
  mkdir -pv umqtt_package/umqtt
fi

touch umqtt_package/umqtt/__init__.py
cp -v ./micropython-lib/micropython/umqtt.simple/umqtt/simple.py umqtt_package/umqtt/
cp -v ./micropython-lib/micropython/umqtt.robust/umqtt/robust.py umqtt_package/umqtt/


