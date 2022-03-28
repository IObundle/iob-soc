//instantiate core in system

   //
   // /*<InstanceName>*/
   //

   iob_uart /*<InstanceName>*/
     (
      //RS232 interface
      .txd       (/*<InstanceName>*/_txd),
      .rxd       (/*<InstanceName>*/_rxd),
      .rts       (/*<InstanceName>*/_rts),
      .cts       (/*<InstanceName>*/_cts),
      
      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`/*<InstanceName>*/)]),
      .address(slaves_req[`address(`/*<InstanceName>*/,`iob_uart_swreg_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata(slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready(slaves_resp[`ready(`/*<InstanceName>*/)])
      );
