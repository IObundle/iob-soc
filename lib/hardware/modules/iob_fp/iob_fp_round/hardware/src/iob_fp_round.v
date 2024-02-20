`timescale 1ns / 1ps

// Round to nearest, tie even (3 bits)

module iob_fp_round #(
               parameter DATA_W = 24,
               parameter EXP_W = 8
               )
  (
   input [EXP_W-1:0]    exponent_i,
   input [DATA_W+3-1:0] mantissa_i,

   output [EXP_W-1:0]   exponent_rnd_o,
   output [DATA_W-1:0]  mantissa_rnd_o
   );

   // Round
   wire                 round = ~mantissa_i[2]? 1'b0:
                                ~|mantissa_i[1:0] & ~mantissa_i[3]? 1'b0: 1'b1;

   wire [DATA_W-1:0]    mantissa_rnd_int = round? mantissa_i[DATA_W+3-1:3] + 1'b1: mantissa_i[DATA_W+3-1:3];

   // Normalize
   wire [$clog2(DATA_W)-1:0] lzc;
   iob_fp_clz #(
         .DATA_W(DATA_W)
         )
   clz0
     (
      .data_i  (mantissa_rnd_int),
      .data_o (lzc)
      );

   assign exponent_rnd_o = exponent_i - {{(EXP_W-$clog2(DATA_W)){1'b0}},lzc};
   assign mantissa_rnd_o = mantissa_rnd_int << lzc;

endmodule
