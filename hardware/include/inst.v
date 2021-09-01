   //
   // GPIO
   //

   iob_gpio gpio
     (
      .clk     (clk),
      .rst     (reset),

      // Registers interface
      .gpio    (gpio),

      // CPU interface
      .valid   (slaves_req[`valid(`GPIO)]),
      .address (slaves_req[`address(`GPIO,`GPIO_ADDR_W+2)-2]),
      .wdata   (slaves_req[`wdata(`GPIO)]),
      .wstrb   (slaves_req[`wstrb(`GPIO)]),
      .rdata   (slaves_resp[`rdata(`GPIO)]),
      .ready   (slaves_resp[`ready(`GPIO)])
      );
