// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_add2
  #(
    parameter W = 21,
    parameter N = 21 //must be at least 2
) (
   input [N*W-1:0] in_i,
   output [W-1:0]  sum_o,
   output          carry_o
);

   wire [(N-1)*W:0] sum;

   genvar i;
   generate

   endgenerate

   generate
      //first adder 
      if (N==2) begin: g_N2
         iob_add2 #(.W(W)) 
         adder(
               .in1_i(in_i[0 +: W]),
               .in2_i(in_i[W +: W]),
               .sum_o(sum_o),
               .carry_o(carry_o)
               );
      end else begin: g_N
         iob_add2 #(.W(W)) 
         adder(
               .in1_i(in_i[0 +: W]),
               .in2_i(in_i[W +: (N-1)*W]),
               .sum_o(sum[0 +: (N-1)*W]),
               .carry_o()
               );
      end

      //intermediate adders
      if (N>3) begin: g_Ngt3
         for(i=1; i<(N-1); i=i+1) begin: adder
            iob_add2 #(.W(W)) 
            adder(
                  .in1_i(in_i[i*W +: W]),
                  .in2_i(sum[(i-1)*W +: W]),
                  .sum_o(sum[i*W +: W]),
                  .carry_o()
                  );
         end
      end

      //last adder
      if (N>2) begin: g_Ngt3
      iob_add2 #(.W(W)) 
      adder(
            .in1_i(in_i[(N-1)*W +: W]),
            .in2_i(sum[(N-2)*W +: W]),
            .sum_o(sum_o),
            .carry_o(carry_o)
            );

   endgenerate

   
endmodule
