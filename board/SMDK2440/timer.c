/*
 * timer.c
 */

#include "s3c24xx.h"

// timer4 init
void s3c2440_timer_init(void)
{
    // Timer input clock Frequency = PCLK / {prescaler value+1} / {divider value}
    TCFG0 |= (99 << 8); // 预分频器2,3,4 = 99
    TCFG1  = (3 << 16); // MUX 4 0011 = 1/16, 16分频
    TCNTB4 = 625;
    TCON  |= (1 << 21); // auto reload/Update TCNTB4/Start for Timer 4
    TCON   =  5 << 20;  // No operation
}
