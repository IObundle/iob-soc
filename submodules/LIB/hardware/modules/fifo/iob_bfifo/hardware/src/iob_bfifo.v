`timescale 1ns / 1ps

module iob_bfifo #(
   parameter WDATA_W = 21,
   parameter RDATA_W = 21,
   parameter REG_W   = 21
) (
   `include "clk_en_rst_s_port.vs"

   input rst_i,

   input                      write_i,
   input  [$clog2(WDATA_W):0] wlen_i,
   input  [      WDATA_W-1:0] wdata_i,
   output [  $clog2(REG_W):0] wlevel_o,

   input                      read_i,
   input  [$clog2(RDATA_W):0] rlen_i,
   output [      RDATA_W-1:0] rdata_o,
   output [  $clog2(REG_W):0] rlevel_o
);

   //read data word width with the right number of bits
   localparam [$clog2(REG_W):0] FULL_LEVEL = {1'b1, {$clog2(REG_W) {1'b0}}};

   //data register
   wire [      REG_W-1:0] data;
   reg  [      REG_W-1:0] data_nxt;
   reg  [      REG_W-1:0] data_tmp;

   //data read and write levela
   wire [$clog2(REG_W):0] wlevel;
   reg  [$clog2(REG_W):0] wlevel_nxt;
   wire [$clog2(REG_W):0] rlevel;
   reg  [$clog2(REG_W):0] rlevel_nxt;

   //data read register
   reg  [    RDATA_W-1:0] rdata;

   //assign outputs
   assign rlevel_o = rlevel;
   assign wlevel_o = wlevel;
   assign rdata_o  = rdata;

   //compute data to merge
   integer j;
   always @* begin
      data_tmp = data << REG_W;
      for (j = 0; j < WDATA_W; j = j + 1) begin
         data_tmp[(REG_W-1)-j] = wdata_i[(WDATA_W-1)-j];
      end
   end

   //control logic
   integer i;
   always @* begin

      data_nxt   = data;
      rlevel_nxt = rlevel;
      wlevel_nxt = wlevel;
      rdata      = {RDATA_W{1'b0}};

      if (write_i) begin  //write
         data_nxt   = data | (data_tmp >> rlevel);
         rlevel_nxt = rlevel + wlen_i;
         wlevel_nxt = wlevel - wlen_i;
      end else if (read_i) begin  //read (ignored if write)
         data_nxt = data << rlen_i;
         for (i = 0; i < RDATA_W; i = i + 1) begin
            if (i < rlen_i) begin
               rdata[(RDATA_W-1)-i] = data[(REG_W-1)-i];
            end else begin
               rdata[(RDATA_W-1)-i] = 1'b0;
            end
         end
         rlevel_nxt = rlevel - rlen_i;
         wlevel_nxt = wlevel + rlen_i;
      end
   end

   //write level register
   iob_reg_r #(
      .DATA_W ($clog2(REG_W) + 1),
      .RST_VAL(FULL_LEVEL)
   ) wlevel_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(wlevel_nxt),
      .data_o(wlevel)
   );

   //read level register
   iob_reg_r #(
      .DATA_W ($clog2(REG_W) + 1),
      .RST_VAL({$clog2(REG_W) + 1{1'b0}})
   ) rlevel_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(rlevel_nxt),
      .data_o(rlevel)
   );

   //data register
   iob_reg_r #(
      .DATA_W (REG_W),
      .RST_VAL({REG_W{1'b0}})
   ) data_reg_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(data_nxt),
      .data_o(data)
   );

endmodule

