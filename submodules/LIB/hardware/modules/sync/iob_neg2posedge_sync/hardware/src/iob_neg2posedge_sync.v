`timescale 1ns / 1ps

module iob_neg2posedge_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {2 * DATA_W{1'b0}}
) (
   `include "clk_en_rst_s_port.vs"
   input  [DATA_W-1:0] signal_i,
   output [DATA_W-1:0] signal_o
);

   wire [DATA_W-1:0] synchronizer;

   iob_regn #(
      .DATA_W (DATA_W),
      .RST_VAL(RST_VAL)
   ) reg1 (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(signal_i),
      .data_o(synchronizer)
   );

   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(RST_VAL)
   ) reg2 (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(synchronizer),
      .data_o(signal_o)
   );

endmodule
