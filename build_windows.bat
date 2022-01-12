@echo off
set ARCH=%1
rem if %ARCH% == ia32 set GENARCH=-AWin32
cmake -S. -Bbuild %GENARCH%
cmake --build build
