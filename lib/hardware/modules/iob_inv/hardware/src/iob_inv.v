`timescale 1ns / 1ps


module iob_inv
  #(
    parameter W = 21
) (
   input [W-1:0] in_i,
   output [W-1:0]  out_o
);

   wire [W-1:0]  out_o;

   assign out_o = ~in_i;

endmodule
