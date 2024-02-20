/*****************************************************************************

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module altddio_in #(
   parameter DATA_W = 21
) (
   input                   clk_i,
   input      [DATA_W-1:0] data_i,
   output reg [DATA_W-1:0] data_l_o,
   output reg [DATA_W-1:0] data_h_o
);

   always @(posedge clk_i) data_h_o <= data_i;

   always @(negedge clk_i) data_l_o <= data_i;

endmodule
