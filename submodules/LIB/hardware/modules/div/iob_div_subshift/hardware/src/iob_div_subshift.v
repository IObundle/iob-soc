`timescale 1ns / 1ps

// IOB Divider with Subtraction and Shift
module iob_div_subshift #(
   parameter DIVIDEND_W = 32,
   parameter DIVISOR_W  = DIVIDEND_W,
   parameter QUOTIENT_W = DIVIDEND_W
) (
   `include "clk_en_rst_s_port.vs"
   input      rst_i,
   input      start_i,
   output reg done_o,

   input  [DIVIDEND_W-1:0] dividend_i,
   input  [ DIVISOR_W-1:0] divisor_i,
   output [QUOTIENT_W-1:0] quotient_o,
   output [ DIVISOR_W-1:0] remainder_o
);
   localparam DQR_W = (DIVISOR_W + DIVIDEND_W) + 1;

   //dividend/quotient/remainder register
   reg  [DQR_W-1:0] dqr_nxt;
   wire [DQR_W-1:0] dqr_reg;

   iob_reg_r #(
      .DATA_W (DQR_W),
      .RST_VAL({DQR_W{1'b0}})
   ) dqr_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(dqr_nxt),
      .data_o(dqr_reg)
   );

   //divisor register
   reg  [DIVISOR_W-1:0] divisor_nxt;
   wire [DIVISOR_W-1:0] divisor_reg;

   iob_reg_r #(
      .DATA_W (DIVISOR_W),
      .RST_VAL({DIVISOR_W{1'b0}})
   ) div_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(divisor_nxt),
      .data_o(divisor_reg)
   );

   wire [DIVISOR_W:0] subtraend;
   assign subtraend = dqr_reg[(DQR_W-2)-:(DIVISOR_W+1)];
   reg [(DIVISOR_W+1):0] tmp;

   //output quotient and remainder
   assign quotient_o  = dqr_reg[QUOTIENT_W-1:0];
   assign remainder_o = dqr_reg[(DQR_W-2)-:DIVISOR_W];

   //
   //PROGRAM
   //

   reg  [$clog2(DIVIDEND_W+1)-1:0] pcnt_nxt;  //program counter
   wire [$clog2(DIVIDEND_W+1)-1:0] pcnt;

   iob_reg_r #(
      .DATA_W ($clog2(DIVIDEND_W + 1)),
      .RST_VAL({($clog2(DIVIDEND_W + 1)) {1'b0}})
   ) pcnt_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(pcnt_nxt),
      .data_o(pcnt)
   );

   always @* begin
      tmp         = {1'b0, subtraend} - {1'b0, divisor_reg};
      pcnt_nxt    = pcnt + 1'b1;
      dqr_nxt     = dqr_reg;
      divisor_nxt = divisor_reg;
      done_o      = 1'b1;

      if (pcnt == 0) begin  //wait for start, load operands and do it
         if (!start_i) begin
            pcnt_nxt = pcnt;
         end else begin
            divisor_nxt = divisor_i;
            dqr_nxt     = {{(DIVISOR_W + 1) {1'b0}}, dividend_i};
         end
      end else if (pcnt == (DIVIDEND_W + 1)) begin
         pcnt_nxt = 0;
      end else begin  //shift and subtract
         done_o = 1'b0;
         if (~tmp[DIVISOR_W+1]) begin
            dqr_nxt = {tmp[DIVISOR_W:0], dqr_reg[DIVIDEND_W-2 : 0], 1'b1};
         end else begin
            dqr_nxt = {1'b0, dqr_reg[DQR_W-3 : 0], 1'b0};
         end
      end
   end

endmodule
