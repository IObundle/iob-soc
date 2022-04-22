//START_SWREG_TABLEaxistream_in 
`IOB_SWREG_W(AXISTREAMIN_SOFTRESET, 1, 0) //Bit duration in system clock cycles.
`IOB_SWREG_W(AXISTREAMIN_DIV, 16, 0) //Bit duration in system clock cycles.
`IOB_SWREG_W(AXISTREAMIN_TXDATA, 8, 0) //TX data
`IOB_SWREG_W(AXISTREAMIN_TXEN, 1, 0) //TX enable.
`IOB_SWREG_R(AXISTREAMIN_TXREADY, 1, 0) //TX ready to receive data
`IOB_SWREG_R(AXISTREAMIN_RXDATA, 8, 0) //RX data
`IOB_SWREG_W(AXISTREAMIN_RXEN, 1, 0) //RX enable.
`IOB_SWREG_R(AXISTREAMIN_RXREADY, 1, 0) //RX data is ready to be read.
