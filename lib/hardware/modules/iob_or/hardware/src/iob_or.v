`timescale 1ns / 1ps


module iob_or
  #(
    parameter W = 21,
    parameter N = 21
) (
   input [N*W-1:0] in_i,
   output [W-1:0]  out_o
);

   wire [N*W-1:0] or_vec;
   
   assign or_vec[0 +: W] = in_i[0 +: W];

   genvar i;
   generate
      for (i = 1; i < N; i = i + 1) begin : gen_mux
         assign or_vec[i*W +: W] = in_i[i*W +: W] | or_vec[(i-1)*W +: W];
      end
   endgenerate

   assign out_o = or_vec[(N-1)*W +: W];

endmodule
