//START_SWREG_TABLE uart
`IOB_SWREG_W(UART_SOFTRESET, 1, 0) //Bit duration in system clock cycles.
`IOB_SWREG_W(UART_DIV, 16, 0) //Bit duration in system clock cycles.
`IOB_SWREG_W(UART_TXDATA, 8, 0) //TX data
`IOB_SWREG_W(UART_TXEN, 1, 0) //TX enable.
`IOB_SWREG_R(UART_TXREADY, 1, 0) //TX ready to receive data
`IOB_SWREG_R(UART_RXDATA, 8, 0) //RX data
`IOB_SWREG_W(UART_RXEN, 1, 0) //RX enable.
`IOB_SWREG_R(UART_RXREADY, 1, 0) //RX data is ready to be read.
