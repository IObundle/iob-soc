// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */


module iob_soc_caravel #(
   parameter BITS = 16
) (
`ifdef USE_POWER_PINS
   inout vccd1,  // User area 1 1.8V supply
   inout vssd1,  // User area 1 digital ground
`endif

   // Wishbone Slave ports (WB MI A)
   input         wb_clk_i,
   input         wb_rst_i,
   input         wbs_stb_i,
   input         wbs_cyc_i,
   input         wbs_we_i,
   input  [ 3:0] wbs_sel_i,
   input  [31:0] wbs_dat_i,
   input  [31:0] wbs_adr_i,
   output        wbs_ack_o,
   output [31:0] wbs_dat_o,




   // Logic Analyzer Signals
   input  [127:0] la_data_in,
   output [127:0] la_data_out,
   input  [127:0] la_oenb,
   // IOs
   input  [BITS-1:0] io_in,
   output [BITS-1:0] io_out,
   output [BITS-1:0] io_oeb,
   // IRQ
   output [2:0] irq
);
   wire            clk;
   wire            rst;

   // wire [BITS-1:0] rdata; 
   wire [BITS-1:0] wdata;
   wire [BITS-1:0] count;
   wire            valid;
   wire [     3:0] wstrb;
   wire [BITS-1:0] la_write;

   // WB MI A
   assign valid       = wbs_cyc_i && wbs_stb_i;
   assign wstrb       = wbs_sel_i & {4{wbs_we_i}};
   //assign wbs_dat_o = {{(32-BITS){1'b0}}, rdata};
   assign wdata       = wbs_dat_i[BITS-1:0];
   assign wbs_dat_o   = 0;
   assign wbs_ack_o   = 0;

   // IO
   assign io_out      = count;
   assign io_oeb      = {(BITS) {rst}};

   // IRQ
   assign irq         = 3'b000;  // Unused

   // LA
   assign la_data_out = {{(128 - BITS) {1'b0}}, count};
   // Assuming LA probes [63:32] are for controlling the count register  
   assign la_write    = ~la_oenb[63:64-BITS] & ~{BITS{valid}};
   // Assuming LA probes [65:64] are for controlling the count clk & reset  
   assign clk         = wb_clk_i;
   assign rst         = wb_rst_i;



//on works
iob_wishbone2iob #(
   parameter ADDR_W = 32,
   parameter DATA_W = 32
) (
   .wb_addr_i(wbs_adr_i),
   .wb_select_i(wbs_sel_i),
   .wb_we_i(wbs_we_i),
   .wb_cyc_i(wbs_cyc_i),
   .wb_stb_i(wb_stb_i),
   .wb_data_i(wb_data_i),
   .wb_ack_o(wb_ack_o),
   .wb_data_o(wb_data_o),
   //iob port interface
   .iob_valid_o(),
   .iob_address_o(),
   .iob_wdata_o(),
   .iob_wstrb_o(),
   .iob_rvalid_i(),
   .iob_rdata_i(),
   iob_ready_i()
);






endmodule



`default_nettype wire
