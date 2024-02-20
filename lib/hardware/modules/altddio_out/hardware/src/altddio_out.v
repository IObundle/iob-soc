/*****************************************************************************

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module altddio_out #(
   parameter DATA_W = 1
) (
   input               clk_i,
   input  [DATA_W-1:0] data_l_i,
   input  [DATA_W-1:0] data_h_i,
   output [DATA_W-1:0] data_o
);

   reg [DATA_W-1:0] data_l_i_reg;
   reg [DATA_W-1:0] data_h_i_reg;

   always @(posedge clk_i) data_h_i_reg <= data_h_i;

   always @(negedge clk_i) data_l_i_reg <= data_l_i;

   assign data_o = clk_i ? data_h_i_reg : data_l_i_reg;

endmodule
