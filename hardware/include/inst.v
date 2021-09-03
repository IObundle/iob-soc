   //
   // REGFILEIF
   //

   iob_regfileif regfileif
     (
      .clk     (clk),
      .rst     (reset),

      // Register file interface
      .valid_ext   (regfileif_valid),
      .address_ext (regfileif_address),
      .wdata_ext   (regfileif_wdata),
      .wstrb_ext   (regfileif_wstrb),
      .rdata_ext   (regfileif_rdata),
      .ready_ext   (regfileif_ready),

      // CPU interface
      .valid       (slaves_req[`valid(`REGFILEIF)]),
      .address     (slaves_req[`address(`REGFILEIF,`REGFILEIF_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`REGFILEIF)]),
      .wstrb       (slaves_req[`wstrb(`REGFILEIF)]),
      .rdata       (slaves_resp[`rdata(`REGFILEIF)]),
      .ready       (slaves_resp[`ready(`REGFILEIF)])
      );
