`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_bfifo #(
   parameter DATA_W = 21
) (
   `include "clk_en_rst_s_port.vs"

   input rst_i,

   input                     write_i,
   input  [$clog2(DATA_W):0] wwidth_i,
   input  [      DATA_W-1:0] wdata_i,
   output [ $clog2(2*DATA_W):0] wlevel_o,

   input                     read_i,
   input  [$clog2(DATA_W):0] rwidth_i,
   output [      DATA_W-1:0] rdata_o,
   output [ $clog2(2*DATA_W):0] rlevel_o
);

   //data register
   wire [     2*DATA_W-1:0]     data;
   reg [      2*DATA_W-1:0]     data_nxt;

   //read and write pointers
   wire [$clog2(2*DATA_W)-1:0]  rptr; //init to 2*DATA_W-1
   wire [$clog2(2*DATA_W)-1:0]  wptr; //init to 0
   reg [$clog2(2*DATA_W)-1:0]   rptr_nxt;
   reg [$clog2(2*DATA_W)-1:0]   wptr_nxt;
   
   //fifo level
   wire [$clog2(2*DATA_W):0]    level;
   reg [$clog2(2*DATA_W):0]     level_nxt;

   //write data
   wire [   DATA_W-1:0]       wdata_int;
   wire [   2*DATA_W-1:0]       wdata;
   wire [   2*DATA_W-1:0]       wmask;
   wire [   2*DATA_W-1:0]       rdata;
   
   //widths' complement
   wire [$clog2(DATA_W):0]      crwidth;
   wire [$clog2(DATA_W):0]      cwwidth;

   //assign outputs
   assign wlevel_o = (1'b1 << $clog2(2*DATA_W)) - level;
   assign rlevel_o = level;
   assign rdata_o  =  ( rdata[2*DATA_W-1-:DATA_W] >> crwidth ) <<  crwidth ; //zero extend

   //widths' complement
   assign  cwwidth = (1'b1 << $clog2(DATA_W))-wwidth_i;
   assign  crwidth = (1'b1 << $clog2(DATA_W))-rwidth_i;

   //intermediate wdata signal
   assign wdata_int = (wdata_i >> cwwidth) << cwwidth;//zero extend

   //write data shifted
   assign wdata = `IOB_CSHIFT_RIGHT( 2*DATA_W, {wdata_int, {DATA_W{1'b0}}}, wptr );
   //write mask shifted
   assign wmask = `IOB_CSHIFT_RIGHT( 2*DATA_W, ({2*DATA_W{1'b1}}>>wwidth_i), wptr);
   //read data shifted
   assign rdata = `IOB_CSHIFT_LEFT ( 2*DATA_W, data, rptr);
   
   always @* begin
      data_nxt  = data;
      rptr_nxt  = rptr;
      wptr_nxt  = wptr;
      level_nxt = level;
      if (read_i) begin  //read
         rptr_nxt  = rptr + rwidth_i;
         level_nxt = level - rwidth_i;
      end else if (write_i) begin  //write
         data_nxt  = (data & wmask) | wdata;
         wptr_nxt  = wptr + wwidth_i;
         level_nxt = level + wwidth_i;
      end
   end
      
   //data register
   iob_reg_r #(
      .DATA_W (2*DATA_W),
      .RST_VAL({2*DATA_W{1'b0}})
   ) data_reg_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(data_nxt),
      .data_o(data)
   );

   //read pointer
   iob_reg_r #(
      .DATA_W ($clog2(2*DATA_W)),
      .RST_VAL({$clog2(2*DATA_W){1'b0}})
   ) rptr_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(rptr_nxt),
      .data_o(rptr)
   );

   //write pointer
   iob_reg_r #(
      .DATA_W ($clog2(2*DATA_W)),
      .RST_VAL({$clog2(2*DATA_W){1'b0}})
   ) wptr_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(wptr_nxt),
      .data_o(wptr)
   );

   //fifo level
   iob_reg_r #(
      .DATA_W ($clog2(2*DATA_W)+1),
      .RST_VAL({$clog2(2*DATA_W)+1{1'b0}})
   ) level_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(level_nxt),
      .data_o(level)
   );

endmodule


