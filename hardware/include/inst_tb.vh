//add core test module in testbench

   iob_axistream_in /*<InstanceName>*/_tb
     (
      .clk       (clk),
      .rst       (reset),
      
      .valid     (axistream_in_valid),
      .address   (axistream_in_addr),
      .wdata     (axistream_in_wdata),
      .wstrb     (axistream_in_wstrb),
      .rdata     (axistream_in_rdata),
      .ready     (axistream_in_ready),
      
      .txd       (/*<InstanceName>*/_rxd),
      .rxd       (/*<InstanceName>*/_txd),
      .rts       (/*<InstanceName>*/_cts),
      .cts       (/*<InstanceName>*/_rts)
      );

