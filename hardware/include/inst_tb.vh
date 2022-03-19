//add core test module in testbench

   iob_uart /*<InstanceName>*/_tb
     (
      .clk       (clk),
      .rst       (reset),
      
      .valid     (uart_valid),
      .address   (uart_addr),
      .wdata     (uart_wdata),
      .wstrb     (uart_wstrb),
      .rdata     (uart_rdata),
      .ready     (uart_ready),
      
      .txd       (/*<InstanceName>*/_rxd),
      .rxd       (/*<InstanceName>*/_txd),
      .rts       (/*<InstanceName>*/_cts),
      .cts       (/*<InstanceName>*/_rts)
      );

