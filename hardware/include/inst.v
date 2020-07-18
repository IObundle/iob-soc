   //
   // UART
   //

   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset),
      
      //cpu interface
      .valid(slaves_req[`valid(`UART)]),
      .address(slaves_req[`address(`UART,`UART_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`UART)]),
      .wstrb(|slaves_req[`wstrb(`UART)]),
      .rdata(slaves_resp[`rdata(`UART)]),
      .ready(slaves_resp[`ready(`UART)]),
      
      
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts)
      );
