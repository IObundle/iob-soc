// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

// Canonical NAN
`define NAN {1'b0, {EXP_W{1'b1}}, 1'b1, {(DATA_W-EXP_W-2){1'b0}}}

// Infinite
`define INF(SIGN) {SIGN, {EXP_W{1'b1}}, {(DATA_W-EXP_W-1){1'b0}}}

module iob_fp_mul #(
                parameter DATA_W = 32,
                parameter EXP_W = 8
                )
   (
    input                   clk_i,
    input                   rst_i,

    input                   start_i,
    output reg              done_o,

    input [DATA_W-1:0]      op_a_i,
    input [DATA_W-1:0]      op_b_i,

    output                  overflow_o,
    output                  underflow_o,
    output                  exception_o,

    output reg [DATA_W-1:0] res_o
    );

   localparam MAN_W = DATA_W-EXP_W;
   localparam BIAS = 2**(EXP_W-1)-1;
   localparam EXTRA = 3;

   // Special cases
`ifdef SPECIAL_CASES
   wire                     op_a_nan, op_a_inf, op_a_zero, op_a_sub;
   iob_fp_special #(
                .DATA_W(DATA_W),
                .EXP_W(EXP_W)
                )
   special_op_a
     (
      .data_i      (op_a_i),

      .nan_o        (op_a_nan),
      .infinite_o   (op_a_inf),
      .zero_o       (op_a_zero),
      .sub_normal_o (op_a_sub)
      );

   wire                     op_b_nan, op_b_inf, op_b_zero, op_b_sub;
   iob_fp_special #(
                .DATA_W(DATA_W),
                .EXP_W(EXP_W)
                )
   special_op_b
     (
      .data_i       (op_b_i),

      .nan_o        (op_b_nan),
      .infinite_o   (op_b_inf),
      .zero_o       (op_b_zero),
      .sub_normal_o (op_b_sub)
      );

   wire                     special = op_a_nan | op_a_inf | op_b_nan | op_b_inf;
   wire [DATA_W-1:0]        res_special = (op_a_nan | op_b_nan)? `NAN:
                                          (op_a_inf & op_b_inf)? `NAN:
                                        (op_a_zero | op_b_zero)? `NAN:
                                                                 `INF(op_b_i[DATA_W-1] ^ op_b_i[DATA_W-1]);
`endif

   // Unpack
   wire [MAN_W-1:0]         A_Mantissa = {1'b1, op_a_i[MAN_W-2:0]};
   wire [EXP_W-1:0]         A_Exponent = op_a_i[DATA_W-2 -: EXP_W];
   wire                     A_sign     = op_a_i[DATA_W-1];

   wire [MAN_W-1:0]         B_Mantissa = {1'b1, op_b_i[MAN_W-2:0]};
   wire [EXP_W-1:0]         B_Exponent = op_b_i[DATA_W-2 -: EXP_W];
   wire                     B_sign     = op_b_i[DATA_W-1];

   // pipeline stage 1
   reg                      A_sign_reg;
   reg [EXP_W-1:0]          A_Exponent_reg;
   reg [MAN_W-1:0]          A_Mantissa_reg;

   reg                      B_sign_reg;
   reg [EXP_W-1:0]          B_Exponent_reg;
   reg [MAN_W-1:0]          B_Mantissa_reg;

   reg                      done_int;
   always @(posedge clk_i) begin
      if (rst_i) begin
         A_sign_reg <= 1'b0;
         A_Exponent_reg <= {EXP_W{1'b0}};
         A_Mantissa_reg <= {MAN_W{1'b0}};

         B_sign_reg <= 1'b0;
         B_Exponent_reg <= {EXP_W{1'b0}};
         B_Mantissa_reg <= {MAN_W{1'b0}};

         done_int <= 1'b0;
      end else begin
         A_sign_reg <= A_sign;
         A_Exponent_reg <= A_Exponent;
         A_Mantissa_reg <= A_Mantissa;

         B_sign_reg <= B_sign;
         B_Exponent_reg <= B_Exponent;
         B_Mantissa_reg <= B_Mantissa;

         done_int <= start_i;
      end
   end

   // Multiplication
   wire                     Temp_sign = A_sign_reg ^ B_sign_reg;
   wire [EXP_W-1:0]         Temp_Exponent = A_Exponent_reg + B_Exponent_reg - BIAS;
   wire [2*MAN_W-1:0]       Temp_Mantissa = A_Mantissa_reg * B_Mantissa_reg;

   // pipeline stage 2
   reg                      Temp_sign_reg;
   reg [EXP_W-1:0]          Temp_Exponent_reg;
   reg [MAN_W+EXTRA:0]      Temp_Mantissa_reg;

   reg                      done_int2;
   always @(posedge clk_i) begin
      if (rst_i) begin
         Temp_sign_reg <= 1'b0;
         Temp_Exponent_reg <= {EXP_W{1'b0}};
         Temp_Mantissa_reg <= {(MAN_W+EXTRA+1){1'b0}};

         done_int2 <= 1'b0;
      end else begin
         Temp_sign_reg <= Temp_sign;
         Temp_Exponent_reg <= Temp_Exponent;
         Temp_Mantissa_reg <= Temp_Mantissa[2*MAN_W-1 -: MAN_W+EXTRA+1];

         done_int2 <= done_int;
      end
   end

   // Normalize
   wire [MAN_W+EXTRA-1:0]   Mantissa_int = Temp_Mantissa_reg[MAN_W+EXTRA]? Temp_Mantissa_reg[MAN_W+EXTRA:1] : Temp_Mantissa_reg[MAN_W+EXTRA-1:0];
   wire [EXP_W-1:0]         Exponent_int = Temp_Mantissa_reg[MAN_W+EXTRA]? Temp_Exponent_reg + 1'b1 : Temp_Exponent_reg;

   // pipeline stage 3
   reg                      Temp_sign_reg2;

   reg [EXP_W-1:0]          Exponent_reg;
   reg [MAN_W+EXTRA-1:0]    Mantissa_reg;

   reg                      done_int3;
   always @(posedge clk_i) begin
      if (rst_i) begin
         Temp_sign_reg2 <= 1'b0;

         Exponent_reg <= {EXP_W{1'b0}};
         Mantissa_reg <= {(MAN_W+EXTRA){1'b0}};

         done_int3 <= 1'b0;
      end else begin
         Temp_sign_reg2 <= Temp_sign_reg;

         Exponent_reg <= Exponent_int;
         Mantissa_reg <= {Mantissa_int[MAN_W+EXTRA-1:1], Mantissa_int[0] | Temp_Mantissa_reg[0]};

         done_int3 <= done_int2;
      end
   end

   // Round
   wire [MAN_W-1:0]         Mantissa_rnd;
   wire [EXP_W-1:0]         Exponent_rnd;
   iob_fp_round #(
           .DATA_W (MAN_W),
           .EXP_W  (EXP_W)
           )
   round0
     (
      .exponent_i     (Exponent_reg),
      .mantissa_i     (Mantissa_reg),

      .exponent_rnd_o (Exponent_rnd),
      .mantissa_rnd_o (Mantissa_rnd)
      );

   // Pack
   wire [MAN_W-2:0]         Mantissa = Mantissa_rnd[MAN_W-2:0];
   wire [EXP_W-1:0]         Exponent = Exponent_rnd;
   wire                     Sign = Temp_sign_reg2;

`ifdef SPECIAL_CASES
   wire [DATA_W-1:0]        res_in  = special? res_special: {Sign, Exponent, Mantissa};
   wire                     done_in = special? start_i: done_int3;
`else
   wire [DATA_W-1:0]        res_in  = {Sign, Exponent, Mantissa};
   wire                     done_in = done_int3;
`endif

   // pipeline stage 4
   always @(posedge clk_i) begin
      if (rst_i) begin
         res_o <= {DATA_W{1'b0}};
         done_o <= 1'b0;
      end else begin
         res_o <= res_in;
         done_o <= done_in;
      end
   end

   // Not implemented yet!
   assign overflow_o = 1'b0;
   assign underflow_o = 1'b0;
   assign exception_o = 1'b0;

endmodule
