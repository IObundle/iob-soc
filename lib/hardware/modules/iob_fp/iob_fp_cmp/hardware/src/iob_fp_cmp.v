`timescale 1ns / 1ps

module iob_fp_cmp # (
                 parameter DATA_W = 32,
                 parameter EXP_W = 8
                 )
  (
   input              clk_i,
   input              rst_i,

   input              start_i,
   output reg         done_o,

   input [1:0]        fn_i,
   input [DATA_W-1:0] op_a_i,
   input [DATA_W-1:0] op_b_i,

   output reg         res_o
   );

   wire               equal = (op_a_i == op_b_i)? 1'b1: 1'b0;

   wire               less = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? 1'b1: 1'b0):
                                                op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? 1'b1: 1'b0):
                                                                ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? 1'b0: 1'b1);

   wire               op_a_nan = &op_a_i[DATA_W-2 -: EXP_W] & |op_a_i[DATA_W-EXP_W-2:0];
   wire               op_b_nan = &op_b_i[DATA_W-2 -: EXP_W] & |op_b_i[DATA_W-EXP_W-2:0];

   wire               res_int = (op_a_nan | op_b_nan)? 1'b0:
                                                fn_i[1]? equal:
                                                fn_i[0]? less:
                                                       less|equal;

   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         res_o <= 1'b0;
         done_o <= 1'b0;
      end else begin
         res_o <= res_int;
         done_o <= start_i;
      end
   end

endmodule
