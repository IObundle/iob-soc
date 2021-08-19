   //
   // GPIO
   //
   wire [`GPIO_R0_W-1:0] gpio_r0;
   wire [`GPIO_R1_W-1:0] gpio_r1;
   wire [`GPIO_R2_W-1:0] gpio_r2;
   wire [`GPIO_R3_W-1:0] gpio_r3;

   iob_gpio gpio
     (
      .clk     (clk),
      .rst     (reset),

      // Registers interface
      .r0      (gpio_r0),
      .r1      (gpio_r1),
      .r2      (gpio_r2),
      .r3      (gpio_r3),

      // CPU interface
      .valid   (slaves_req[`valid(`GPIO)]),
      .address (slaves_req[`address(`GPIO,`GPIO_ADDR_W+2)-2]),
      .wdata   (slaves_req[`wdata(`GPIO)]),
      .wstrb   (slaves_req[`wstrb(`GPIO)]),
      .rdata   (slaves_resp[`rdata(`GPIO)]),
      .ready   (slaves_resp[`ready(`GPIO)])
      );
