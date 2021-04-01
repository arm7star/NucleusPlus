@echo off
title SMDK2440
qemu-system-arm.exe -nographic -M smdk2440 -kernel SMDK2440.bin  2>nul || pause
