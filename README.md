# Introduction
Nucleus Plus real-time operating system 1.12.4 for SMDK2440 with qemu.

# Nucleus Plus
Nucleus PLUS is a real-time, preemptive, multitasking kernel designed for time-critical embedded applications. Approximately 95% of Nucleus PLUS is written in ANSI C.
Because of this, Nucleus PLUS is extremely portable and is currently available for use with most microprocessor families.

https://en.wikipedia.org/wiki/Nucleus_RTOS

# Toolchain
## linux
gcc-arm-none-eabi-4_9-2015q3-20150921-linux
## Cygwin
Cygwin
gcc-arm-none-eabi-4_9-2015q3-20150921-win32
make.exe

# Clean

make clean; make distclean; make clobber

# Build
make all

# Run
qemu-system-arm -nographic -M smdk2440 -kernel SMDK2440.bin 2>/dev/null
```
System_Memory have been cteated!
task_0 have been created
task_1 have been created
task_2 have been created
task_3_and_4 have been created
task_5 have been created
------- task_0 start--------------
SMail
------- task_1 start--------------
DMail is 11110000
DMail is 11112222
DMail is 33334444
DMail is 55556666
------- task_2 start--------------
------- task3_and_4 start --------------
------- task_5 start --------------
NU_Obtain_Semaphore NU_SUCCESS
NU_Obtain_Semaphore NU_SUCCESS
NU_Obtain_Semaphore NU_SUCCESS
SMail
receive mailbox error!
NU_Obtain_Semaphore NU_SUCCESS
NU_Obtain_Semaphore NU_SUCCESS
DMail is 11110000
DMail is 11112222
DMail is 33334444
DMail is 55556666
NU_Obtain_Semaphore NU_SUCCESS
NU_Obtain_Semaphore NU_SUCCESS
NU_Set_Events
```
