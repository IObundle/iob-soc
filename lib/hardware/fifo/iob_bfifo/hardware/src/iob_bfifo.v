// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_bfifo #(
    parameter DATA_W = 21
) (
    `include "iob_bfifo_clk_en_rst_s_port.vs"

    input rst_i,

    input                       write_i,
    input  [  $clog2(DATA_W):0] wwidth_i,
    input  [        DATA_W-1:0] wdata_i,
    output [$clog2(2*DATA_W):0] wlevel_o,

    input                       read_i,
    input  [  $clog2(DATA_W):0] rwidth_i,
    output [        DATA_W-1:0] rdata_o,
    output [$clog2(2*DATA_W):0] rlevel_o
);

  `include "iob_functions.vs"

  localparam BUFFER_SIZE = 2 * DATA_W;
  //data register
  wire [      (2*DATA_W)-1:0] data;
  reg  [      (2*DATA_W)-1:0] data_nxt;

  //read and write pointers
  wire [$clog2(2*DATA_W)-1:0] rptr;  //init to 2*DATA_W-1
  wire [$clog2(2*DATA_W)-1:0] wptr;  //init to 0
  reg  [$clog2(2*DATA_W)-1:0] rptr_nxt;
  reg  [$clog2(2*DATA_W)-1:0] wptr_nxt;

  //fifo level
  wire [  $clog2(2*DATA_W):0] level;
  reg  [  $clog2(2*DATA_W):0] level_nxt;

  //write data
  reg  [          DATA_W-1:0] wdata_int;
  reg  [      (2*DATA_W)-1:0] wdata;
  wire [      (2*DATA_W)-1:0] wmask;
  wire [      (2*DATA_W)-1:0] rdata;

  //assign outputs
  assign wlevel_o = (1'b1 << $clog2(BUFFER_SIZE)) - level;
  assign rlevel_o = level;

  //widths' complement
  wire [$clog2(DATA_W)-1:0] crwidth;
  wire [$clog2(DATA_W)-1:0] cwwidth;
  assign crwidth = (~rwidth_i[$clog2(DATA_W)-1:0]) + {{$clog2(DATA_W) - 1{1'd0}}, 1'd1};
  assign cwwidth = (~wwidth_i[$clog2(DATA_W)-1:0]) + {{$clog2(DATA_W) - 1{1'd0}}, 1'd1};

  //zero trailing bits
  assign rdata_o = (rdata[(2*DATA_W)-1-:DATA_W] >> crwidth) << crwidth;

  //write mask shifted
  assign wmask   = iob_cshift_right(BUFFER_SIZE, ({BUFFER_SIZE{1'b1}} >> wwidth_i), wptr);
  //read data shifted
  assign rdata   = iob_cshift_left(BUFFER_SIZE, data, rptr);

  always @* begin
    //write data shifted
    wdata_int = (wdata_i >> cwwidth) << cwwidth;
    wdata     = iob_cshift_right(BUFFER_SIZE, {wdata_int, {DATA_W{1'b0}}}, wptr);
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
      .DATA_W (BUFFER_SIZE),
      .RST_VAL({BUFFER_SIZE{1'b0}})
  ) data_reg_inst (
      `include "iob_bfifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(data_nxt),
      .data_o(data)
  );

  //read pointer
  iob_reg_r #(
      .DATA_W ($clog2(BUFFER_SIZE)),
      .RST_VAL({$clog2(BUFFER_SIZE) {1'b0}})
  ) rptr_reg (
      `include "iob_bfifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(rptr_nxt),
      .data_o(rptr)
  );

  //write pointer
  iob_reg_r #(
      .DATA_W ($clog2(BUFFER_SIZE)),
      .RST_VAL({$clog2(BUFFER_SIZE) {1'b0}})
  ) wptr_reg (
      `include "iob_bfifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(wptr_nxt),
      .data_o(wptr)
  );

  //fifo level
  iob_reg_r #(
      .DATA_W ($clog2(BUFFER_SIZE) + 1),
      .RST_VAL({$clog2(BUFFER_SIZE) + 1{1'b0}})
  ) level_reg (
      `include "iob_bfifo_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(level_nxt),
      .data_o(level)
  );

endmodule


