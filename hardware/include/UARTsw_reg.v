//START_TABLE sw_reg
`SWREG_R(UART_WRITE_WAIT, 1, 0) //If 1 then one must not write a new byte to e send as the UART is still processing the last byte.
`SWREG_RW(UART_DIV, DATA_W/2, 0) //Bit duration in system clock cycles.
`SWREG_RW(UART_DATA, DATA_W/4, 0) //TX (write) or RX (read) UART data
`SWREG_W(UART_SOFT_RESET, 1, 0) //Bit duration in system clock cycles.
`SWREG_R(UART_READ_VALID, 1, 0) //If 1 then RX data is ready to be read.
`SWREG_W(UART_RXEN, 1, 0) //RX enable.
`SWREG_W(UART_TXEN, 1, 0) //TX enable.
