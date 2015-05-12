#!/bin/sh

#git clone https://github.com/SvenMichaelKlose/tre
#git clone https://github.com/SvenMichaelKlose/bender
#git clone https://github.com/SvenMichaelKlose/pulse
cd tre; ./make.sh core; ./make.sh install; cd ..
ln -s ../tre/environment bender/
cd bender; ./make.sh; cd ..
ln -s ../bender pulse/
cd pulse; ./make.sh; cd ..
