`timescale 1ns / 1ps

module iob_div_subshift #(
   parameter DATA_W = 32
) (
   `include "clk_en_rst_s_port.vs"

   input      start_i,
   output reg done_o,

   input  [DATA_W-1:0] dividend_i,
   input  [DATA_W-1:0] divisor_i,
   output [DATA_W-1:0] quotient_o,
   output [DATA_W-1:0] remainder_o
);

   //dividend/quotient/remainder register
   reg  [2*DATA_W:0] dqr_nxt;
   wire [2*DATA_W:0] dqr_reg;

   iob_reg #(
      .DATA_W ((2 * DATA_W) + 1),
      .RST_VAL({((2*DATA_W) + 1){1'b0}})
   ) dqr_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(dqr_nxt),
      .data_o(dqr_reg)
   );

   //divisor register
   reg  [DATA_W-1:0] divisor_nxt;
   wire [DATA_W-1:0] divisor_reg;

   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'b0}})
   ) div_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"

      .data_i(divisor_nxt),
      .data_o(divisor_reg)
   );

   wire [DATA_W-1:0] subtraend = dqr_reg[(2*DATA_W)-2-:DATA_W];
   wire  [  DATA_W:0] tmp;

   //output quotient and remainder
   assign quotient_o  = dqr_reg[DATA_W-1:0];
   assign remainder_o = dqr_reg[(2*DATA_W)-1:DATA_W];

   assign tmp = {1'b0, subtraend} - {1'b0, divisor_reg};


   //
   //PROGRAM
   //

   reg [$clog2(DATA_W+1)-1:0] pcnt_nxt;  //program counter
   wire [$clog2(DATA_W+1)-1:0] pcnt;
   
   /* verilator lint_off WIDTH */   
   wire [$clog2(DATA_W+1)-1:0] last_stage = DATA_W + 1;
   /* verilator lint_on WIDTH */

   iob_reg #(
       .DATA_W($clog2(DATA_W+1)),
       .RST_VAL({($clog2(DATA_W+1)){1'b0}})
   ) pcnt_reg (
       .clk_i(clk_i),
       .cke_i(cke_i),
       .arst_i(arst_i),
       .data_i(pcnt_nxt),
       .data_o(pcnt)
   );

   always @* begin
      pcnt_nxt      = pcnt + 1'b1;
      dqr_nxt     = dqr_reg;
      divisor_nxt = divisor_reg;
      done_o      = 1'b1;

      if(pcnt == 0) begin //wait for start, load operands and do it
         if (!start_i) begin 
            pcnt_nxt = pcnt;
         end else begin
            divisor_nxt = divisor_i;
            dqr_nxt     = {1'b0,{DATA_W{1'b0}}, dividend_i};
         end         
      end else if (pcnt == last_stage) begin
         pcnt_nxt = 0;
      end else begin //shift and subtract
         done_o = 1'b0;
         if (~tmp[DATA_W]) begin
             dqr_nxt = {tmp, dqr_reg[DATA_W-2 : 0], 1'b1};
         end else begin
             dqr_nxt = {1'b0,dqr_reg[(2*DATA_W)-2 : 0], 1'b0};
         end         
      end
   end

endmodule
