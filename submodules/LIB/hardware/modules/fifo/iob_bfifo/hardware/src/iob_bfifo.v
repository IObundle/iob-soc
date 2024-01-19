`timescale 1ns / 1ps

module iob_bfifo #(
   parameter DATA_W = 21,
   parameter REG_W  = 21
) (
   `include "clk_en_rst_s_port.vs"

   input rst_i,

   input                     write_i,
   input  [$clog2(DATA_W):0] wwidth_i,
   input  [      DATA_W-1:0] wdata_i,
   output [ $clog2(REG_W):0] wlevel_o,

   input                     read_i,
   input  [$clog2(DATA_W):0] rwidth_i,
   output [      DATA_W-1:0] rdata_o,
   output [ $clog2(REG_W):0] rlevel_o
);

   //data register
   wire [      REG_W-1:0] data;
   reg  [      REG_W-1:0] data_nxt;

   //data read and write levels
   wire [$clog2(REG_W):0] level;
   reg  [$clog2(REG_W):0] level_nxt;
   //write data
   wire [     DATA_W-1:0] wdata;

   //assign outputs
   assign wlevel_o = {1'b1, {$clog2(REG_W) {1'b0}}} - level;
   assign rlevel_o = level;
   //read data are the high bits of the data register after getting rid of the zeros on the right
   assign rdata_o  = ((data[REG_W-1-:DATA_W] >> (DATA_W - rwidth_i)) << (DATA_W - rwidth_i));

   //control logic
   //write data are the input bits after getting rid of the zeros on the right
   assign wdata    = ((wdata_i >> (DATA_W - wwidth_i)) << (DATA_W - wwidth_i));

   always @* begin
      data_nxt  = data;
      level_nxt = level;

      if (write_i) begin  //write
         data_nxt  = data | {wdata, {REG_W - DATA_W{1'd0}}} >> level;
         level_nxt = level + wwidth_i;
      end else if (read_i) begin  //read
         data_nxt  = data << rwidth_i;
         level_nxt = level - rwidth_i;
      end
   end

   //read level register
   iob_reg_r #(
      .DATA_W ($clog2(REG_W) + 1),
      .RST_VAL({$clog2(REG_W) + 1{1'b0}})
   ) level_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(level_nxt),
      .data_o(level)
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

