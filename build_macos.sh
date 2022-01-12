#!/bin/sh -xe
ARCH=$1
test "$ARCH" != "" && export CMAKE_OSX_ARCHITECTURES=$ARCH
cmake -H. -Bbuild/
cmake --build build/
