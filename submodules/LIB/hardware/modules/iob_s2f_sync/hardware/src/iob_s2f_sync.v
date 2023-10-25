`timescale 1ns / 1ps

module iob_s2f_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "clk_rst_s_port.vs",

   input rst_i,

   input              ld_i,
   input [DATA_W-1:0] ld_val_i,

   input  [DATA_W-1:0] data_i,
   output [DATA_W-1:0] data_o
);

   wire [DATA_W-1:0] ld_reg0 = ld_i ? ld_val_i : data_i;
   
   wire [DATA_W-1:0] data_rst0 = rst_i ? RST_VAL : ld_reg0;

   iob_sync #(
       .DATA_W  (DATA_W),
       .RST_VAL (RST_VAL),
       .CLKEDGE ("posedge")
   ) iob_sync_inst0 (
       `include "clk_rst_s_s_portmap.vs",
       .signal_i(data_rst0),
       .signal_o(data_o)
   );

endmodule
