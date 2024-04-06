`timescale 1ns / 1ps


module iob_demux #(
   parameter DATA_W = 21,
   parameter N      = 21
) (
   input  [($clog2(N)+($clog2(N)==0))-1:0] sel_i,
   input  [                    DATA_W-1:0] data_i,
   output [                (N*DATA_W)-1:0] data_o
);

   // //Select the data to output
   genvar i;
   generate
      for (i = 0; i < N; i = i + 1) begin : gen_demux
         assign data_o[i*DATA_W+:DATA_W] = (sel_i==i)? data_i : {DATA_W{1'b0}};
      end
   endgenerate

endmodule
