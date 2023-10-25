`timescale 1ns / 1ps


module iob_demux #(
   parameter DATA_W = 21,
   parameter N      = 21
) (
   input  [($clog2(N)+($clog2(N)==0))-1:0] sel_i,
   input  [                    DATA_W-1:0] data_i,
   output [                (N*DATA_W)-1:0] data_o
);

   //Select the data to output
   assign data_o = {{((N - 1) * DATA_W) {1'b0}}, data_i} << (sel_i * DATA_W);

endmodule
