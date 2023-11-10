/*****************************************************************************

  Description: Clock Wrapper

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps
`include "bsp.vh"

module iob_clkmux (
   input  clk0_i,
   input  clk1_i,
   input  clk_sel_i,
   output clk_o
);

`ifdef XILINX
   BUFGMUX #(
      .CLK_SEL_TYPE("ASYNC")
   ) BUFGMUX_inst (
      .I0(clk0_i),
      .I1(clk1_i),
      .S (clk_sel_i),
      .O (clk_o)
   );
`elsif INTEL
   altclkctrl altclkctrl_inst (
      .inclk     ({clk0_i, clk1_i}),
      .clkselect (clk_sel_i),
      .outclk    (clk_o)
   );
`else 
   reg    clk_v;
   always @* clk_v = #1 clk_sel_i ? clk1_i : clk0_i;
   assign clk_o = clk_v;
`endif

endmodule
