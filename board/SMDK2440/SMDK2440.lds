OUTPUT_ARCH(arm)
ENTRY(_start)

SECTIONS
{
    . = 0x00000000;
    .text :
    {
        *(.head.text)
        *(.text)
    }
    . = ALIGN(32);

    .data :
    {
        *(.data)
    }

    . = ALIGN(32);
    __bss_start = .;
    .bss :
    {
        *(.bss)
    }
    . = ALIGN(32);
    __bss_end = .;

    . = ALIGN(32);
    . = . + 0x8000; /* 32kB of stack memory */
    __stack_svc_end__ = .;
}
