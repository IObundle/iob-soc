//instantiate core in system

   //
   // UART
   //

   iob_uart uart_0
     (
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts),

      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`UART0)]),
      .address(slaves_req[`address(`UART0,`UART0_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`UART0)-(`DATA_W-`UART0_WDATA_W)]),
      .wstrb(|slaves_req[`wstrb(`UART0)]),
      .rdata(slaves_resp[`rdata(`UART0)]),
      .ready(slaves_resp[`ready(`UART0)])
      );
