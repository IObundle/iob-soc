`timescale 1ns / 1ps

module iob_div_subshift_signed #(
   parameter DATA_W = 32
) (
   input clk_i,

   input      en_i,
   input      sign_i,
   output reg done_o,

   input  [DATA_W-1:0] dividend_i,
   input  [DATA_W-1:0] divisor_i,
   output [DATA_W-1:0] quotient_o,
   output [DATA_W-1:0] remainder_o
);

   localparam PC_W = $clog2(DATA_W + 5) + 1;

   reg  [2*DATA_W:0] rq;
   reg  [DATA_W-1:0] divisor_reg;
   reg               divident_sign;
   reg               divisor_sign;
   reg  [  PC_W-1:0] pc;  //program counter
   wire [DATA_W-1:0] subtraend = rq[2*DATA_W-2-:DATA_W];
   reg  [  DATA_W:0] tmp;

   //output quotient and remainder
   assign quotient_o  = rq[DATA_W-1:0];
   assign remainder_o = rq[2*DATA_W-1:DATA_W];

   //
   //PROGRAM
   //

   always @(posedge clk_i) begin
      if (en_i) begin
         pc <= pc + 1'b1;

         case (pc)
            0: begin  //load operands and result sign
               if (sign_i) begin
                  divisor_reg    <= divisor_i;
                  divisor_sign   <= divisor_i[DATA_W-1];
                  rq[DATA_W-1:0] <= dividend_i[DATA_W-1] ? -dividend_i : dividend_i;
                  divident_sign  <= dividend_i[DATA_W-1];
               end else begin
                  divisor_reg    <= divisor_i;
                  divisor_sign   <= 1'b0;
                  rq[DATA_W-1:0] <= dividend_i;
                  divident_sign  <= 1'b0;
               end
            end  // case: 0

            1: begin
               if (sign_i) divisor_reg <= divisor_reg[DATA_W-1] ? -divisor_reg : divisor_reg;
            end

            PC_W'(DATA_W + 2): begin  //apply sign to quotient
               rq[DATA_W-1:0] <= (divident_sign^divisor_sign)? -{rq[DATA_W-2], rq[DATA_W-2 : 0]}: {rq[DATA_W-2], rq[DATA_W-2 : 0]};
            end

            PC_W'(DATA_W + 3): begin  //apply sign to remainder
               done_o <= 1'b1;
               rq[2*DATA_W-1:DATA_W] <= divident_sign? -rq[2*DATA_W-1 -: DATA_W] : rq[2*DATA_W-1 -: DATA_W];
            end

            PC_W'(DATA_W + 4): pc <= pc;  //finish

            default: begin  //shift and subtract
               tmp = {1'b0, subtraend} - {1'b0, divisor_reg};
               if (~tmp[DATA_W]) rq <= {tmp, rq[DATA_W-2 : 0], 1'b1};
               else rq <= {rq[2*DATA_W-1 : 0], 1'b0};
            end
         endcase  // case (pc)

      end else begin  // if (en)
         rq     <= 0;
         done_o <= 1'b0;
         pc     <= 0;
      end
   end  // always @ *

endmodule
