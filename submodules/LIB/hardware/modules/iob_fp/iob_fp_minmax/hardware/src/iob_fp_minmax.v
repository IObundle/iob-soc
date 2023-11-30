`timescale 1ns / 1ps

// Canonical NAN
`define NAN {1'b0, {EXP_W{1'b1}}, 1'b1, {(DATA_W-EXP_W-2){1'b0}}}

// Infinite
`define INF(SIGN) {SIGN, {EXP_W{1'b1}}, {(DATA_W-EXP_W-1){1'b0}}}

module iob_fp_minmax # (
                    parameter DATA_W = 32,
                    parameter EXP_W = 8
                    )
  (
   input                   clk_i,
   input                   rst_i,

   input                   start_i,
   output reg              done_o,

   input                   max_n_min_i,
   input [DATA_W-1:0]      op_a_i,
   input [DATA_W-1:0]      op_b_i,

   output reg [DATA_W-1:0] res_o
   );

   wire [DATA_W-1:0]   bigger  = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? op_b_i: op_a_i):
                                                    op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_b_i: op_a_i):
                                                                    ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_a_i: op_b_i);

   wire [DATA_W-1:0]   smaller = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? op_a_i: op_b_i):
                                                    op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_a_i: op_b_i):
                                                                    ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_b_i: op_a_i);

   wire                op_a_nan = &op_a_i[DATA_W-2 -: EXP_W] & |op_a_i[DATA_W-EXP_W-2:0];
   wire                op_b_nan = &op_b_i[DATA_W-2 -: EXP_W] & |op_b_i[DATA_W-EXP_W-2:0];

   wire [DATA_W-1:0] res_int = (op_a_nan & op_b_nan)? `NAN:
                                            op_a_nan? op_b_i:
                                            op_b_nan? op_a_i:
                                           max_n_min_i? bigger: smaller;

   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         res_o <= {DATA_W{1'b0}};
         done_o <= 1'b0;
      end else begin
         res_o <= res_int;
         done_o <= start_i;
      end
   end

endmodule
