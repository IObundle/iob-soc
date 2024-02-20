`timescale 1ns / 1ps

module iob_fp_sqrt #(
                 parameter DATA_W = 32,
                 parameter EXP_W = 8
                )
   (
    input                   clk_i,
    input                   rst_i,

    input                   start_i,
    output                  done_o,

    input [DATA_W-1:0]      op_i,

    output                  overflow_o,
    output                  underflow_o,
    output                  exception_o,

    output reg [DATA_W-1:0] res_o
    );

   localparam MAN_W = DATA_W-EXP_W;
   localparam BIAS = 2**(EXP_W-1)-1;
   localparam EXTRA = 3;

   localparam END_COUNT = MAN_W+EXTRA-1+4; // sqrt cycle count (MAN_W+EXTRA-1) + pipeline stages
   localparam COUNT_W = $clog2(END_COUNT+1);

   reg [COUNT_W-1:0] counter;
   assign done_o = (counter == END_COUNT[COUNT_W-1:0])? 1'b1: 1'b0;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         counter <= END_COUNT[COUNT_W-1:0];
      end else if (start_i) begin
         counter <= 0;
      end else if (~done_o) begin
         counter <= counter + 1'b1;
      end
   end

   // Unpack
   wire [MAN_W-1:0]         A_Mantissa = {1'b1, op_i[MAN_W-2:0]};
   wire [EXP_W-1:0]         A_Exponent = op_i[DATA_W-2 -: EXP_W];
   wire                     A_sign = op_i[DATA_W-1];

   // pipeline stage 1
   reg                      A_sign_reg;
   reg [EXP_W-1:0]          A_Exponent_reg;
   reg [MAN_W-1:0]          A_Mantissa_reg;
   reg [EXP_W-1:0]          A_Exponent_diff_reg;
   reg                      Equal_zero_reg;
   reg                      Do_start;

   always @(posedge clk_i) begin
      if (rst_i) begin
         A_sign_reg <= 1'b0;
         A_Exponent_reg <= {EXP_W{1'b0}};
         A_Mantissa_reg <= {MAN_W{1'b0}};
         A_Exponent_diff_reg <= 0;
         Equal_zero_reg <= 1'b0;

         Do_start <= 1'b0;
      end else begin
         if(start_i) begin // This unit is not fully pipelinable, due to the use of int_sqrt, so just register at the start and reuse when needed
            A_sign_reg <= A_sign;
            A_Exponent_reg <= A_Exponent;
            A_Mantissa_reg <= A_Mantissa;
            A_Exponent_diff_reg <= A_Exponent - BIAS;
            Equal_zero_reg <= (A_Exponent == 0) && (op_i[MAN_W-2:0] == 0);
         end

         Do_start <= start_i;
      end
   end

   // Squaring
   wire [MAN_W:0]   Temp_Mantissa; // = sqrt(A_Mantissa_reg);
   iob_int_sqrt #(.DATA_W(MAN_W+2),.FRACTIONAL_W(MAN_W))
   int_sqrt (
             .clk_i   (clk_i),
             .rst_i   (rst_i),

             .start_i (Do_start),
             .done_o  (),

             .op_i    (A_Exponent_diff_reg[0] ? {2'b00,A_Mantissa_reg} : {1'b0,A_Mantissa_reg,1'b0}),
             .res_o   (Temp_Mantissa)
             );

   // pipeline stage 3
   reg [EXP_W-1:0]  Temp_Exponent_reg;
   reg [MAN_W-2:0]  Temp_Mantissa_reg;

   wire [EXP_W-1:0] Temp_Computed_Exponent = {A_Exponent_diff_reg[EXP_W-1],A_Exponent_diff_reg[EXP_W-1:1]}; // Signed division by 2
   always @(posedge clk_i) begin
      if (rst_i) begin
         Temp_Exponent_reg <= {EXP_W{1'b0}};
         Temp_Mantissa_reg <= {(MAN_W-1){1'b0}};
      end else begin

         if(A_sign_reg || Equal_zero_reg) begin
            Temp_Exponent_reg <= 0;
            Temp_Mantissa_reg <= 0;
         end else begin
            Temp_Exponent_reg <= BIAS + Temp_Computed_Exponent;
            Temp_Mantissa_reg <= A_Exponent_diff_reg[0] ? Temp_Mantissa[MAN_W-2:0] : Temp_Mantissa[MAN_W-1:1];
         end
      end
   end

   wire [MAN_W-2:0]         Mantissa = Temp_Mantissa_reg;
   wire [EXP_W-1:0]         Exponent = Temp_Exponent_reg;
   wire                     Sign = 1'b0;

   // pipeline stage 4
   always @(posedge clk_i) begin
      if (rst_i) begin
         res_o <= {DATA_W{1'b0}};
      end else begin
         res_o <= {Sign, Exponent, Mantissa};
      end
   end

   assign overflow_o = 1'b0;
   assign underflow_o = 1'b0;
   assign exception_o = A_sign_reg; // Cannot perform sqrt of negative numbers

endmodule
