`timescale 1ns/1ps

`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_gpio.vh"
`include "GPIOsw_reg.vh"

module iob_gpio 
  # (
     parameter ADDR_W = `GPIO_ADDR_W,
     parameter DATA_W = `GPIO_DATA_W
     )
   (

   // CPU interface
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

    // additional inputs and outputs
    `INOUT(gpio, DATA_W),

`include "gen_if.v"
    );

   // BLOCK Register File & Holds the current configuration of the GPIO as well as internal parameters.
`include "GPIOsw_reg.v"
`include "GPIOsw_reg_gen.v"

   // Read GPIO
   reg [DATA_W-1:0] gpio_rd_int;
   integer i;
   always @* begin
      for (i=0; i < DATA_W; i=i+1) begin
         if (GPIO_RD_MASK[i]) begin
            gpio_rd_int[i] = gpio[i];
         end else begin
            gpio_rd_int[i] = 1'b0;
         end
      end
   end

   assign GPIO_RD = gpio_rd_int;

   // Write GPIO
   reg [DATA_W-1:0] gpio_int;
   integer j;
   always @* begin
      for (j=0; j < DATA_W; j=j+1) begin
         if (GPIO_WR_MASK[j]) begin
            gpio_int[j] = GPIO_WR[j];
         end else begin
            gpio_int[j] = 1'bz;
         end
      end
   end

   assign gpio = gpio_int;

endmodule
