#!/usr/bin/env bash

# This script launches a already built binary and then
# converts the output qoi file to a png file, this is
# especially useful if one doesn't have a qoi ready
# image viewer (In my case I wanted to see it in my firefox
# directly which isn't possible with qoi)

shopt -s expand_aliases

set -xe

alias time="$(which time) -f '\t%E real,\t%U user,\t%S sys,\t%K amem,\t%M mmem'"

time ./zig-out/bin/Zaytracer
ffmpeg -i out.qoi out.png -hide_banner -loglevel error -y
