//instantiate core in system

   //
   // UART
   //

   iob_uart uart_1
     (
      //RS232 interface
      .txd       (),
      .rxd       (),
      .rts       (),
      .cts       (),

      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`UART1)]),
      .address(slaves_req[`address(`UART1,`UART1_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`UART1)-(`DATA_W-`UART1_WDATA_W)]),
      .wstrb(|slaves_req[`wstrb(`UART1)]),
      .rdata(slaves_resp[`rdata(`UART1)]),
      .ready(slaves_resp[`ready(`UART1)])
      );
