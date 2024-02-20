`timescale 1ns / 1ps

module iob_piso_reg #(
   parameter DATA_W = 32
) (

   `include "clk_en_rst_s_port.vs"

   // parallel input
   input              ld_i,
   input [DATA_W-1:0] p_i,

   // serial output
   output s_o
);

   wire [DATA_W-1:0] data_reg;
   wire [DATA_W-1:0] data;
   assign data = ld_i ? p_i : data_reg << 1'b1;

   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(data),
      .data_o(data_reg)
   );

   assign s_o = data_reg[DATA_W-1];

endmodule
