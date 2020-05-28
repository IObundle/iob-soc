//Useful ASCII codes
`define STX 2
`define ETX 3
`define ENQ 5
`define ACK 6

//Memory map
`define UART_ADDR_W 3

`define UART_WRITE_WAIT (`UART_ADDR_W'd0)
`define UART_DIV        (`UART_ADDR_W'd1)
`define UART_DATA       (`UART_ADDR_W'd2)
`define UART_SOFT_RESET (`UART_ADDR_W'd3)
`define UART_READ_VALID (`UART_ADDR_W'd4)
`define UART_RXEN       (`UART_ADDR_W'd5)
