#include "s3c24xx.h"

void mask_irq(unsigned int irq)
{
	INTMSK |= (1 << irq);
}

void unmask_irq(unsigned int irq)
{
	INTMSK &= (~(1 << irq));
}
