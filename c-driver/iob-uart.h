//Memory Map
#define UART_WAIT 0
#define UART_DIV 1
#define UART_DATAOUT 2
#define UART_RESET 3

//Functions

//Set the division
//div should be equal to round (fclk/baudrate)
//E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
void uart_setdiv(int div);

//Wait for UART be ready to operate
void uart_wait();

//Get the division previously configured
void uart_getdiv(int div);

//Functions to write
void uart_putc(char c);
void uart_puts(const *s);
void uart_printf(const char* fmt, int var);
