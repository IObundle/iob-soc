`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_reset_sync #(
    parameter IN_RST_POL = 0, // 1: rst active HIGH, 0: rst active LOW
    parameter OUT_RST_POL = `IOB_REG_RST_POL
) (
   input  clk_i,
   input  arst_i,
   output arst_o
);

   wire [1:0] data;
   wire [1:0] sync;

   localparam RST_VAL = OUT_RST_POL ? 2'd3 : 2'd0;

   generate
      if (OUT_RST_POL == 0) begin: gen_rst_pol_0
         assign data = {sync[0], 1'b1};
      end else begin: gen_rst_pol_1
         assign data = {sync[0], 1'b0};
      end
   endgenerate

   iob_r_rstn #(
       .DATA_W  (2),
       .RST_VAL (RST_VAL),
       .RST_POL (IN_RST_POL)
       )     
   reg1 (
       .clk_i (clk_i),
       .arst_i (arst_i),
       .iob_r_data_i(data),
       .iob_r_data_o(sync)
       );
   
   assign arst_o = sync[1];
   
endmodule
