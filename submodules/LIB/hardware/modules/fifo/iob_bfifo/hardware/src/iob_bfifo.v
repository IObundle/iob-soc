`timescale 1ns / 1ps

module iob_bfifo #(
   parameter WDATA_W = 21,
   parameter RDATA_W = 21,
   parameter REG_W   = 21
) (
   `include "clk_en_rst_s_port.vs"

   input                     rst_i,

   input                     write_i,
   input [$clog2(WDATA_W):0] wwidth_i,
   input [ WDATA_W-1:0]      wdata_i,
   output [$clog2(REG_W):0]  wlevel_o,

   input                     read_i,
   input [$clog2(RDATA_W):0] rwidth_i,
   output [ RDATA_W-1:0]     rdata_o,
   output [$clog2(REG_W):0]  rlevel_o
);

   //read data word width with the right number of bits
   localparam [$clog2(REG_W):0] FULL_LEVEL = {1'b1, {$clog2(REG_W) {1'b0}}};
   localparam [$clog2(REG_W):0] EMPTY_LEVEL = {1'b0, {$clog2(REG_W) {1'b0}}};

   //data register
   wire [      REG_W-1:0] data;
   reg  [      REG_W-1:0] data_nxt;

   //data read and write levels
   wire [$clog2(REG_W):0] rlevel;
   reg  [$clog2(REG_W):0] rlevel_nxt;
   wire [$clog2(REG_W):0] wlevel;

   //write data
   wire  [      WDATA_W-1:0] wdata;

   //assign outputs
   assign wlevel_o = wlevel;
   assign rlevel_o = rlevel;
   assign rdata_o  = ((data[REG_W-1 -: RDATA_W] >> (RDATA_W - rwidth_i)) << (RDATA_W - rwidth_i));

   //control logic
   assign wlevel = (FULL_LEVEL - rlevel);
   assign wdata = ((wdata_i >> (WDATA_W - wwidth_i)) << (WDATA_W - wwidth_i));

   always @* begin
      data_nxt   = data;
      rlevel_nxt = rlevel;

      if (write_i) begin  //write
         data_nxt   = data | (wdata << ((REG_W - WDATA_W))-rlevel);
         rlevel_nxt = rlevel + wwidth_i;
       end else if (read_i) begin //read
         data_nxt = data << rwidth_i;
         rlevel_nxt = rlevel - rwidth_i;
      end
   end

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

