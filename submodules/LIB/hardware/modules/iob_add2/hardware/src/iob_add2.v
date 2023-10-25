`timescale 1ns / 1ps

module iob_add2 #(
   parameter W = 21
) (
   input  [W-1:0] in1_i,
   input  [W-1:0] in2_i,
   output [W-1:0] sum_o,
   output         carry_o
);
   wire [W:0] sum;
   assign sum_o   = in1_i + in2_i;
   assign carry_o = sum_o[W];
endmodule
