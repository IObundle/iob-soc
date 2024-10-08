// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps


module iob_shift_reg #(
    parameter DATA_W = 21,
    parameter N = 21,
    parameter ADDR_W = $clog2(N)

) (
    `include "iob_shift_reg_clk_en_rst_s_port.vs"

    input               en_i,
    input               rst_i,
    input  [DATA_W-1:0] data_i,
    output [DATA_W-1:0] data_o,

    //memory clock
    output              ext_mem_clk_o,
    //memory write port
    output              ext_mem_w_en_o,
    output [ADDR_W-1:0] ext_mem_w_addr_o,
    output [DATA_W-1:0] ext_mem_w_data_o,
    //read port
    output              ext_mem_r_en_o,
    output [ADDR_W-1:0] ext_mem_r_addr_o,
    input  [DATA_W-1:0] ext_mem_r_data_i
);

  //address
  wire [ADDR_W-1:0] addr_w;
  reg  [ADDR_W-1:0] addr_r;

  wire              out_en;
  wire              out_en_nxt;

  wire              rst_int_w;
  wire              rst_int_r;


  assign data_o = ext_mem_r_data_i & {DATA_W{out_en}};

  assign ext_mem_clk_o = clk_i;

  assign ext_mem_w_en_o = en_i;
  assign ext_mem_w_addr_o = addr_w;
  assign ext_mem_w_data_o = data_i;

  assign ext_mem_r_en_o = en_i;
  assign ext_mem_r_addr_o = addr_r;


  //counter enable
  assign out_en_nxt = out_en | (addr_w == (N - 1));

  assign rst_int_w = rst_i | (addr_w == (N - 1));
  assign rst_int_r = rst_i | (addr_r == (N - 1));

  always @* begin
    if (addr_w == (N - 1)) begin
      addr_r = 0;
    end else begin
      addr_r = addr_w + 1'b1;
    end
  end

  //write address
  iob_counter #(
      .DATA_W (ADDR_W),
      .RST_VAL({ADDR_W{1'd0}})
  ) w_addr_cnt0 (
      `include "iob_shift_reg_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_int_w),
      .en_i  (en_i),
      .data_o(addr_w)
  );

  iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
  ) out_enable (
      `include "iob_shift_reg_clk_en_rst_s_s_portmap.vs"
      .data_i(out_en_nxt),
      .data_o(out_en)
  );


endmodule
