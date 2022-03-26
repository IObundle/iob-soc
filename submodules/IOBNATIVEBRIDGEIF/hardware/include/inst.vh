   //
   // /*<InstanceName>*/
   //

   iob_nativebridgeif /*<InstanceName>*/
     (
      .clk     (clk),
      .rst     (reset),

      // Register file interface
      .valid_ext   (/*<InstanceName>*/_valid),
      .address_ext (/*<InstanceName>*/_address),
      .wdata_ext   (/*<InstanceName>*/_wdata),
      .wstrb_ext   (/*<InstanceName>*/_wstrb),
      .rdata_ext   (/*<InstanceName>*/_rdata),
      .ready_ext   (/*<InstanceName>*/_ready),

      // CPU interface
      .valid       (slaves_req[`valid(`/*<InstanceName>*/)]),
      .address     (slaves_req[`address(`/*<InstanceName>*/,`iob_nativebridgeif_swreg_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb       (slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata       (slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready       (slaves_resp[`ready(`/*<InstanceName>*/)])
      );
