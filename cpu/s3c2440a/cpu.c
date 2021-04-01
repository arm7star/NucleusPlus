/*
 * cpu.c: 进行一些初始化
 */

#include "s3c24xx.h"

void disable_watch_dog(void);
void clock_init(void);
void memsetup(void);

/*
 * 关闭WATCHDOG，否则CPU会不断重启
 */
void disable_watch_dog(void)
{
    WTCON = 0;  // 关闭WATCHDOG很简单，往这个寄存器写0即可
}

#define S3C2440_MPLL_405MHZ ((0x7f << 12) | (0x2 << 4) | (0x01)) // MDIV: 0x7f, PDIV: 0x2, SDIV: 0x01

void clock_init(void)
{
    LOCKTIME = 0x00ffffff;      // 使用默认值即可
    CLKDIVN  = 0x05;            // PDIVN: 1, HDIVN: 0, HDIVN1: 1; FCLK:HCLK:PCLK=1:4:8 (<<S3C2440A_Users_Manual.pdf>> P242 "FCLK, HCLK, and PCLK")

#if 0 // bluesky del
    /* 如果HDIVN非0，CPU的总线模式应该从“fast bus mode”变为“asynchronous bus mode” */
__asm__(
    "mrc    p15, 0, r1, c1, c0, 0\n"        /* 读出控制寄存器 */
    "orr    r1, r1, #0xc0000000\n"          /* 设置为“asynchronous bus mode” */
    "mcr    p15, 0, r1, c1, c0, 0\n"        /* 写入控制寄存器 */
    );
#endif

    MPLLCON = S3C2440_MPLL_405MHZ;          /* 现在，FCLK=405MHz, HCLK=101MHz, PCLK=50MHz */
    UPLLCON = ((0x38 << 12) + (0x2 << 4) + 0x2);
}

/*
 * 设置存储控制器以使用SDRAM
 */
void memsetup(void)
{
    volatile unsigned long *p = (volatile unsigned long *)MEM_CTL_BASE;

    /* 这个函数之所以这样赋值，而不是像前面的实验(比如mmu实验)那样将配置值
     * 写在数组中，是因为要生成”位置无关的代码”，使得这个函数可以在被复制到
     * SDRAM之前就可以在steppingstone中运行
     */
    /* 存储控制器13个寄存器的值 */
    p[0] = 0x22111120;     // BWSCON
    p[1] = 0x00002F50;     // BANKCON0
    p[2] = 0x00000700;     // BANKCON1
    p[3] = 0x00000700;     // BANKCON2
    p[4] = 0x00000700;     // BANKCON3
    p[5] = 0x00000700;     // BANKCON4
    p[6] = 0x0007FFFC;     // BANKCON5
    p[7] = 0x00018005;     // BANKCON6
    p[8] = 0x00018005;     // BANKCON7

                                            /* REFRESH,
                                             * HCLK=12MHz:  0x008C07A3,
                                             * HCLK=100MHz: 0x008C04F4
                                             */
    p[9]  = 0x008C04F4;
    p[10] = 0x00000032;     // BANKSIZE
    p[11] = 0x00000030;     // MRSRB6
    p[12] = 0x00000030;     // MRSRB7
}
