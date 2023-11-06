`timescale 1ns / 1ps

module iob_div_pipe #(
   parameter DATA_W = 32,
   parameter OPERS_PER_STAGE = 8
) (
   input clk_i,

   input [DATA_W-1:0] dividend_i,
   input [DATA_W-1:0] divisor_i,

   output [DATA_W-1:0] quotient_o,
   output [DATA_W-1:0] remainder_o
);

   wire [(DATA_W+1)*DATA_W-1:0] dividend_int;
   wire [(DATA_W+1)*DATA_W-1:0] divisor_int;
   wire [(DATA_W+1)*DATA_W-1:0] quotient_int;

   assign dividend_int[DATA_W-1:0] = dividend_i;
   assign divisor_int[DATA_W-1:0]  = divisor_i;
   assign quotient_int[DATA_W-1:0] = {DATA_W{1'b0}};

   genvar k;
   generate
      for (k = 1; k <= DATA_W; k = k + 1) begin : div_slice_array_el
         iob_div_slice #(
            .DATA_W    (DATA_W),
            .STAGE     (k),
            .OUTPUT_REG(!(k % OPERS_PER_STAGE))
         ) uut (
            .clk_i(clk_i),

            .dividend_i(dividend_int[k*DATA_W-1-:DATA_W]),
            .divisor_i (divisor_int[k*DATA_W-1-:DATA_W]),
            .quotient_i(quotient_int[k*DATA_W-1-:DATA_W]),

            .dividend_o(dividend_int[(k+1)*DATA_W-1-:DATA_W]),
            .divisor_o (divisor_int[(k+1)*DATA_W-1-:DATA_W]),
            .quotient_o(quotient_int[(k+1)*DATA_W-1-:DATA_W])
         );
      end
   endgenerate

   assign quotient_o  = quotient_int[(DATA_W+1)*DATA_W-1-:DATA_W];
   assign remainder_o = dividend_int[(DATA_W+1)*DATA_W-1-:DATA_W];

endmodule
