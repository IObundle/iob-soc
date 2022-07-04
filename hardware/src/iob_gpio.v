`timescale 1ns/1ps

`include "iob_lib.vh"
`include "iob_gpio_swreg_def.vh"

module iob_gpio 
  # (
     parameter GPIO_W = 8, //PARAM Number of GPIO (can be up to DATA_W)
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_gpio_swreg_ADDR_W //MACRO CPU address section width
     )
   (

   //CPU interface
`include "iob_s_if.vh"

    // additional inputs and outputs
    `INOUT(gpio, GPIO_W),

`include "iob_gen_if.vh"
    );

//BLOCK Register File & Configuration control and status register file.
`include "iob_gpio_swreg_gen.vh"

    // SWRegs
    `IOB_WIRE(GPIO_WRITE_MASK, DATA_W)
    iob_reg #(.DATA_W(DATA_W))
    gpio_write_mask (
        .clk        (clk),
        .arst       (rst),
        .arst_val   (1'b0),
        .rst        (rst),
        .rst_val    (1'b0),
        .en         (GPIO_WRITE_MASK_en),
        .data_in    (GPIO_WRITE_MASK_wdata),
        .data_out   (GPIO_WRITE_MASK)
    );

    `IOB_WIRE(GPIO_WRITE, DATA_W)
    iob_reg #(.DATA_W(DATA_W))
    gpio_write      (
        .clk        (clk),
        .arst       (rst),
        .arst_val   (1'b0),
        .rst        (rst),
        .rst_val    (1'b0),
        .en         (GPIO_WRITE_en),
        .data_in    (GPIO_WRITE_wdata),
        .data_out   (GPIO_WRITE)
    );

   // Read GPIO
   reg [GPIO_W-1:0] gpio_rd_int;
   integer i;
   always @* begin
      for (i=0; i < GPIO_W; i=i+1) begin
         if (!GPIO_WRITE_MASK[i]) begin
            gpio_rd_int[i] = gpio[i];
         end else begin
            gpio_rd_int[i] = 1'b0;
         end
      end
   end

   assign GPIO_READ_rdata = gpio_rd_int;

   // Write GPIO
   reg [GPIO_W-1:0] gpio_int;
   integer j;
   always @* begin
      for (j=0; j < GPIO_W; j=j+1) begin
         if (GPIO_WRITE_MASK[j]) begin
            gpio_int[j] = GPIO_WRITE[j];
         end else begin
            gpio_int[j] = 1'bz;
         end
      end
   end

   assign gpio = gpio_int;

endmodule
