#!/bin/bash

sudo pacman -S lf git 

git clone https://github.com/thimc/lfimg

cd lfimg 

make install 

cd ..

rm -rf lfimg
