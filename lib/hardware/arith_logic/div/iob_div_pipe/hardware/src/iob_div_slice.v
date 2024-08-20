`timescale 1ns / 1ps

module iob_div_slice #(
   parameter DATA_W     = 32,
   parameter STAGE      = 1,
   parameter OUTPUT_REG = 1
) (
   input clk_i,

   input [DATA_W-1:0] dividend_i,
   input [DATA_W-1:0] divisor_i,
   input [DATA_W-1:0] quotient_i,

   output reg [DATA_W-1:0] dividend_o,
   output reg [DATA_W-1:0] divisor_o,
   output reg [DATA_W-1:0] quotient_o
);

   wire                    sub_sign;
   wire [2*DATA_W-STAGE:0] sub_res;

   assign sub_res  = {{DATA_W{1'b0}}, dividend_i} - {{STAGE{1'b0}}, divisor_i, {(DATA_W-STAGE){1'b0}}};
   assign sub_sign = sub_res[2*DATA_W-STAGE];

   generate
      if (OUTPUT_REG) begin
         always @(posedge clk_i) begin
            dividend_o <= (sub_sign) ? dividend_i : sub_res[DATA_W-1:0];
            quotient_o <= quotient_i << 1 | {{(DATA_W - 1) {1'b0}}, ~sub_sign};
            divisor_o  <= divisor_i;
         end
      end else begin
         always @* begin
            dividend_o = (sub_sign) ? dividend_i : sub_res[DATA_W-1:0];
            quotient_o = quotient_i << 1 | {{(DATA_W - 1) {1'b0}}, ~sub_sign};
            divisor_o  = divisor_i;
         end
      end
   endgenerate

endmodule
