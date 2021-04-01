#define INT_TIMER4  14

#define GPBCON      (*(volatile unsigned int* )0x56000010)
#define GPBDAT      (*(volatile unsigned int *)0x56000014)

static void SMDK2440_cpu_init(void)
{
    disable_watch_dog();
    clock_init();
}

static void SMDK2440_SDRAM_init(void)
{
    memsetup();
}

static void SMDK2440_gpio_init(void)
{
    GPBCON &= ~((0x3 << 10) | 0x3);
    GPBCON |= (0x1 << 10) | 0x01;
    GPBDAT &= ~(1 << 5);
    GPBDAT &= ~(1 << 0);
}

static void SMDK2440_uart_init(void)
{
    uart0_init();
}

void INT_Timer_Initialize(void)
{
    s3c2440_timer_init();   // initialize timer4
    unmask_irq(INT_TIMER4); // unmask timer4 interrupt
}

void SMDK2440_Initialize(void)
{
    SMDK2440_cpu_init();
    SMDK2440_SDRAM_init();

    SMDK2440_mmu_init();
    enable_mmu();

    SMDK2440_gpio_init();
    SMDK2440_uart_init();
}
