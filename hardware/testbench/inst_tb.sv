
   iob_uart uart_tb
     (
      .clk       (clk),
      .rst       (reset),
      
      .valid     (uart_valid),
      .address   (uart_addr),
      .wdata     (uart_wdata),
      .wstrb     (uart_wstrb),
      .rdata     (uart_rdata),
      .ready     (uart_ready),
      
      .txd       (txd_tb),
      .rxd       (rxd_tb),
      .rts       (rts_tb),
      .cts       (cts_tb)
      );

