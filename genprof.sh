#!/bin/bash
nim c ./analyze.nim
time ./analyze > freqprof.nim 
ls -sh freqprof.nim
