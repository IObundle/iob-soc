`timescale 1ns / 1ps

module iob_acc_ld #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
`include "clk_en_rst_s_port.vs"
   input               rst_i,
   input               en_i,
   input               ld_i,
   input [DATA_W-1:0]  ld_val_i,
   input [DATA_W-1:0]  incr_i,
   output [DATA_W-1:0] data_o,
   output [DATA_W:0]   data_nxt_o
   );

   wire [DATA_W:0]    data_int;
   assign data_nxt_o = ld_i ? ld_val_i : data_o + incr_i;

   assign data_o = data_int[DATA_W-1:0];
   
   iob_reg_re #(
      .DATA_W(DATA_W+1),
      .RST_VAL(RST_VAL)
   ) reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .en_i (en_i),
      .data_i(data_nxt_o),
      .data_o(data_int)
   );

endmodule
