`timescale 1ns / 1ps

module iob_fp_special #(
                    parameter DATA_W = 32,
                    parameter EXP_W = 8
                    )
   (
    input [DATA_W-1:0] data_i,

    output             nan_o,
    output             infinite_o,
    output             zero_o,
    output             sub_normal_o
    );

   localparam MAN_W = DATA_W-EXP_W;

   wire                sign = data_i[DATA_W-1];
   wire [EXP_W-1:0]    exponent = data_i[DATA_W-2 -: EXP_W];
   wire [MAN_W-2:0]    mantissa = data_i[MAN_W-2:0];

   wire                exp_all_ones = &exponent;
   wire                exp_zero = ~|exponent;
   wire                man_zero = ~|mantissa;

   assign nan_o        = exp_all_ones & ~man_zero;
   assign infinite_o   = exp_all_ones & man_zero;
   assign zero_o       = exp_zero & man_zero;
   assign sub_normal_o = exp_zero & ~man_zero;

endmodule
