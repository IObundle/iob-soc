`timescale 1ns / 1ps

module iob_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "clk_rst_s_port.vs"
   input  [DATA_W-1:0] signal_i,
   output [DATA_W-1:0] signal_o
);

   wire [DATA_W-1:0] synchronizer;

   iob_r #(
      .DATA_W (DATA_W),
      .RST_VAL(RST_VAL)
   ) reg1 (
      .clk_i       (clk_i),
      .arst_i      (arst_i),
      .iob_r_data_i(signal_i),
      .iob_r_data_o(synchronizer)
   );

   iob_r #(
      .DATA_W (DATA_W),
      .RST_VAL(RST_VAL)
   ) reg2 (
      .clk_i       (clk_i),
      .arst_i      (arst_i),
      .iob_r_data_i(synchronizer),
      .iob_r_data_o(signal_o)
   );

endmodule
