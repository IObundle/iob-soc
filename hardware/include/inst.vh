//instantiate core in system

   //
   // /*<InstanceName>*/
   //

   iob_axistream_in /*<InstanceName>*/
     (
      //AXI4 Stream interface
      .tdata       (/*<InstanceName>*/_tdata),
      .tvalid       (/*<InstanceName>*/_tvalid),
      .tready       (/*<InstanceName>*/_tready),
      .tlast       (/*<InstanceName>*/_tlast),
      
      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`/*<InstanceName>*/)]),
      .address(slaves_req[`address(`/*<InstanceName>*/,`iob_axistream_in_swreg_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata(slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready(slaves_resp[`ready(`/*<InstanceName>*/)])
      );
