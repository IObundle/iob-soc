`timescale 1ns / 1ps
`include "bsp.vh"

module iob_clkbuf (
   input  clk_i,
   input  n_i,
   output clk_o
);

   wire clk_int = n_i ? ~clk_i : clk_i;

`ifdef XILINX
   BUFG BUFG_inst (
      .I(clk_int),
      .O(clk_o)
   );
`else
   assign clk_o = clk_int;
`endif

endmodule
