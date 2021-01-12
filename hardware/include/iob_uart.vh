//data and address widths
`define UART_RDATA_W 32
`define UART_WDATA_W 16
`define UART_ADDR_W 3

//Useful ASCII codes
`define STX 2 //start of text 
`define ETX 3 //end of text
`define EOT 4 //end of transission
`define ENQ 5 //enquiry
`define ACK 6 //acklowledge
`define FTX 7 //transmit file
`define FRX 8 //receive file

//Memory map
`define UART_WRITE_WAIT (`UART_ADDR_W'd0)
`define UART_DIV        (`UART_ADDR_W'd1)
`define UART_DATA       (`UART_ADDR_W'd2)
`define UART_SOFT_RESET (`UART_ADDR_W'd3)
`define UART_READ_VALID (`UART_ADDR_W'd4)
`define UART_RXEN       (`UART_ADDR_W'd5)
`define UART_TXEN       (`UART_ADDR_W'd6)
