#!/bin/bash
cd ext
git clone https://github.com/mborgerding/kissfft
cd kissfft
make 
cp libkissfft.so ../../
cp tools/kiss_fftr.c ../../
