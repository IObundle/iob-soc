//Memory Map
#define UART_WAIT 0
#define UART_DIV 1
#define UART_DATAOUT 2
#define UART_RESET 3

//Functions

//Reset UART
void uart_reset();

//Set the division factor div
//div should be equal to round (fclk/baudrate)
//E.g for fclk = 100 Mhz for a baudrate of 115200 we should uart_setdiv(868)
void uart_setdiv(unsigned int div);

//Get the division factor div
int uart_getdiv();

//Wait for UART be ready to operate
void uart_wait();

//Print char
void uart_putc(char c);

//Print string
void uart_puts(const char *s);

//formated print
void uart_printf(const char* fmt, int var);

