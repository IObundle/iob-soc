`timescale 1ns / 1ps
`include "iob_utils.vh"


module iob_nco 
  #(
    parameter DATA_W = 21,
    parameter FRAC_W = 21
    ) (
`include "clk_en_rst_s_port.vs"
       input rst_i,
       input en_i,
       input [DATA_W-1:0] period_i,
       input ld_i,
       output  clk_o
       );
   
   wire [DATA_W-1:0]        period_r;
   wire [DATA_W-1:0]        diff;
   wire [DATA_W-1:FRAC_W]   cnt;
   wire [DATA_W-1:0]        acc_in, acc_out;
   wire                     clk_int;
   
   assign diff = period_r - {quant, {FRAC_W{1'b0}}};
   assign clk_int = (cnt > (quant/2));

   //
   reg [DATA_W-1:FRAC_W]    quant;
   always @* begin
      if (acc_out[FRAC_W-1:0] == {1'b1,{FRAC_W-1{1'b0}}})
        quant = acc_out[DATA_W-1:FRAC_W] + ^acc_out[DATA_W-1:FRAC_W];
      else if (acc_out[FRAC_W-1])
        quant = acc_out[DATA_W-1:FRAC_W] + 1'b1;
      else
        quant = acc_out[DATA_W-1:FRAC_W];
   end

   //fractional period value register 
   iob_reg_re 
     #(
       .DATA_W(DATA_W)
       )
   per_reg
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .en_i(en_i),
      .data_i(period_i),
      .data_o(period_r)
      );

   //output clock register 
   iob_reg_re 
     #(
       .DATA_W(1)
       )
   clk_out_reg
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .en_i(en_i),
      .data_i(clk_int),
      .data_o(clk_o)
      );
   
   //modulator accumulator
   iob_acc_ld 
     #(
       .DATA_W(DATA_W)
       )
   acc_ld
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .en_i(en_i),
      .ld_i(ld_i),
      .ld_val_i(period_i),
      .incr_i(diff),
      .data_o(acc_out)
      );
   

   //output period counter 
   iob_modcnt
     #(
       .DATA_W(DATA_W-FRAC_W)
       )
   modcnt
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(ld_i),
      .en_i(en_i),
      .mod_i(quant),
      .data_o(cnt)
      );
   
      
endmodule
