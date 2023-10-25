`timescale 1ns / 1ps

module iob_div_subshift_frac #(
   parameter DATA_W = 32
) (
   `include "clk_en_rst_s_port.vs"

   input  start_i,
   output done_o,

   input  [DATA_W-1:0] dividend_i,
   input  [DATA_W-1:0] divisor_i,
   output [DATA_W-1:0] quotient_o,
   output [DATA_W-1:0] remainder_o
);

   wire [DATA_W-1:0] divisor_reg;

   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(1'b0)
   ) divisor_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"

      .data_i(divisor_i),
      .data_o(divisor_reg)
   );

   //output quotient
   wire [DATA_W-1:0] quotient_int;
   reg               incr;  //residue   
   assign quotient_o = quotient_int + incr;

   iob_div_subshift #(
      .DATA_W(DATA_W)
   ) div_subshift0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .start_i(start_i),
      .done_o (done_o),

      .dividend_i (dividend_i),
      .divisor_i  (divisor_i),
      .quotient_o (quotient_int),
      .remainder_o(remainder_o)
   );

   //residue accum
   reg  [DATA_W:0] res_acc_nxt;
   wire [DATA_W:0] res_acc;
   reg             res_acc_en;

   iob_reg_e #(
      .DATA_W (DATA_W + 1),
      .RST_VAL(1'b0)
   ) res_acc_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .en_i  (res_acc_en),

      .data_i(res_acc_nxt),
      .data_o(res_acc)
   );

   //pc register
   reg  [1:0] pc_nxt;
   wire [1:0] pc;

   iob_reg #(
      .DATA_W (2),
      .RST_VAL(1'b0)
   ) pc_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"

      .data_i(pc_nxt),
      .data_o(pc)
   );

   always @* begin
      incr        = 1'b0;
      res_acc_nxt = res_acc + remainder_o;
      res_acc_en  = 1'b0;
      pc_nxt      = pc + 1'b1;

      case (pc)
         0: begin  //wait for div start
            if (!start_i) pc_nxt = pc;
         end

         1: begin  //wait for div done
            if (!done_o) pc_nxt = pc;
         end

         default: begin
            res_acc_en = 1'b1;
            if (res_acc_nxt >= divisor_i) begin
               incr        = 1'b1;
               res_acc_nxt = res_acc + remainder_o - divisor_i;
            end
            if (!start_i) pc_nxt = pc;
            else pc_nxt = 1'b1;
         end
      endcase  // case (pc)

   end


endmodule
