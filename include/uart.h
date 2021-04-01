#ifndef __uart_h__
#define __uart_h__

void uart0_init(void);
void putc(unsigned char c);
unsigned char getc(void);
int isDigit(unsigned char c);
int isLetter(unsigned char c);

#endif // __uart_h__
