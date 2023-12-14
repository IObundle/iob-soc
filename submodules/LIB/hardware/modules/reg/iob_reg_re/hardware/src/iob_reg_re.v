`timescale 1ns / 1ps

module iob_reg_re #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "clk_en_rst_s_port.vs"

   input rst_i,
   input en_i,

   input  [DATA_W-1:0] data_i,
   output [DATA_W-1:0] data_o
);

   wire [DATA_W-1:0] data = en_i ? data_i : data_o;

   iob_reg_r #(
      .DATA_W (DATA_W),
      .RST_VAL(RST_VAL)
   ) reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(data),
      .data_o(data_o)
   );

endmodule
