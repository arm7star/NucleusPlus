#include <stdarg.h>

#define UTRSTAT0    (*(volatile unsigned long *)0x50000010)
#define UTXH0       (*(volatile unsigned char *)0x50000020)

#define TXD0READY   (1 <<2)

static void __put_char(char *p, int num) {
    while (*p && num--) {
        while (!(UTRSTAT0 & TXD0READY));
        UTXH0 = *p++;
    }
}

int printf(const char *fmt, ...)
{
    char print_buf[256];

    va_list args;
    unsigned int i;

    va_start(args, fmt);
    i = vsnprintf(print_buf, sizeof(print_buf),fmt, args);
    va_end(args);

    __put_char(print_buf, i);

    return 0;
}
