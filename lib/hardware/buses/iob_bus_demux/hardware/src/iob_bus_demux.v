// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

// Split the IOb native interface, from a single master to multiple followers
module iob_bus_demux #(
   parameter ADDR_W = 32,
   parameter DATA_W = 32,
   parameter N      = 2,             // Number of followers, minimum of 2
   parameter NB     = $clog2(N)      // Number of bits needed to address all followers
) (
   `include "iob_bus_demux_clk_rst_s_port.vs"

   // Master's interface
   input                 m_valid_i,
   input  [ADDR_W-1:0]   m_addr_i,
   input  [DATA_W-1:0]   m_wdata_i,
   input  [DATA_W/8-1:0] m_wstrb_i,
   output [DATA_W-1:0]   m_rdata_o,
   output                m_rvalid_o,
   output                m_ready_o,

   // Followers' interface
   output [N*1-1:0]          f_valid_o,
   output [N*ADDR_W-1:0]     f_addr_o,
   output [N*DATA_W-1:0]     f_wdata_o,
   output [N*(DATA_W/8)-1:0] f_wstrb_o,
   input  [N*DATA_W-1:0]     f_rdata_i,
   input  [N*1-1:0]          f_rvalid_i,
   input  [N*1-1:0]          f_ready_i,

   // Follower selection
   input  [NB-1:0] f_sel_i
);

   //
   // Register the follower selection
   //

   wire [NB-1:0] f_sel_r;
   iob_reg_e #(
      .DATA_W (NB),
      .RST_VAL(0)
   ) reg_f_sel (
      `include "iob_bus_demux_clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .en_i  (m_valid_i),
      .data_i(f_sel_i),
      .data_o(f_sel_r)
   );

   //
   // Route master request to selected follower
   //

   iob_demux #(
      .DATA_W (1),
      .N      (N)
   ) demux_valid (
      .sel_i (f_sel_i),
      .data_i(m_valid_i),
      .data_o(f_valid_o)
   );

   iob_demux #(
      .DATA_W (ADDR_W),
      .N      (N)
   ) demux_addr (
      .sel_i (f_sel_i),
      .data_i(m_addr_i),
      .data_o(f_addr_o)
   );

   iob_demux #(
      .DATA_W (DATA_W),
      .N      (N)
   ) demux_wdata (
      .sel_i (f_sel_i),
      .data_i(m_wdata_i),
      .data_o(f_wdata_o)
   );

   iob_demux #(
      .DATA_W (DATA_W/8),
      .N      (N)
   ) demux_wstrb (
      .sel_i (f_sel_i),
      .data_i(m_wstrb_i),
      .data_o(f_wstrb_o)
   );

   //
   // Route selected follower response to master
   //

   iob_mux #(
      .DATA_W (DATA_W),
      .N      (N)
   ) mux_rdata (
      .sel_i (f_sel_r),
      .data_i(f_rdata_i),
      .data_o(m_rdata_o)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_rvalid (
      .sel_i (f_sel_r),
      .data_i(f_rvalid_i),
      .data_o(m_rvalid_o)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_ready (
      .sel_i (f_sel_i),
      .data_i(f_ready_i),
      .data_o(m_ready_o)
   );

endmodule
