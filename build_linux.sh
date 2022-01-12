#!/bin/sh -xe
ARCH=$1
case $ARCH in
    i*86) export LDFLAGS=-m32 CXXFLAGS=-m32;;
esac
command -v ninja 2>/dev/null && GEN=-GNinja
cmake -S. -Bbuild/ $GEN
cmake --build build/
