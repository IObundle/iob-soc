// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Sat May  4 18:48:58 2019
// Host        : baba-de-camelo running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/jroque/project_rv32_ddr/project_rv32_ddr.srcs/sources_1/ip/ddr4_0/ddr4_0_stub.v
// Design      : ddr4_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku040-fbva676-1-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ddr4_v2_2_6,Vivado 2018.3" *)
module ddr4_0(sys_rst, c0_sys_clk_p, c0_sys_clk_n, 
  c0_ddr4_act_n, c0_ddr4_adr, c0_ddr4_ba, c0_ddr4_bg, c0_ddr4_cke, c0_ddr4_odt, c0_ddr4_cs_n, 
  c0_ddr4_ck_t, c0_ddr4_ck_c, c0_ddr4_reset_n, c0_ddr4_dm_dbi_n, c0_ddr4_dq, c0_ddr4_dqs_c, 
  c0_ddr4_dqs_t, c0_init_calib_complete, c0_ddr4_ui_clk, c0_ddr4_ui_clk_sync_rst, 
  addn_ui_clkout1, dbg_clk, dbg_rd_data_cmp, dbg_expected_data, dbg_cal_seq, dbg_cal_seq_cnt, 
  dbg_cal_seq_rd_cnt, dbg_rd_valid, dbg_cmp_byte, dbg_rd_data, dbg_cplx_config, 
  dbg_cplx_status, dbg_io_address, dbg_pllGate, dbg_phy2clb_fixdly_rdy_low, 
  dbg_phy2clb_fixdly_rdy_upp, dbg_phy2clb_phy_rdy_low, dbg_phy2clb_phy_rdy_upp, 
  cal_r0_status, cal_post_status, c0_ddr4_aresetn, c0_ddr4_s_axi_awid, 
  c0_ddr4_s_axi_awaddr, c0_ddr4_s_axi_awlen, c0_ddr4_s_axi_awsize, c0_ddr4_s_axi_awburst, 
  c0_ddr4_s_axi_awlock, c0_ddr4_s_axi_awcache, c0_ddr4_s_axi_awprot, c0_ddr4_s_axi_awqos, 
  c0_ddr4_s_axi_awvalid, c0_ddr4_s_axi_awready, c0_ddr4_s_axi_wdata, c0_ddr4_s_axi_wstrb, 
  c0_ddr4_s_axi_wlast, c0_ddr4_s_axi_wvalid, c0_ddr4_s_axi_wready, c0_ddr4_s_axi_bready, 
  c0_ddr4_s_axi_bid, c0_ddr4_s_axi_bresp, c0_ddr4_s_axi_bvalid, c0_ddr4_s_axi_arid, 
  c0_ddr4_s_axi_araddr, c0_ddr4_s_axi_arlen, c0_ddr4_s_axi_arsize, c0_ddr4_s_axi_arburst, 
  c0_ddr4_s_axi_arlock, c0_ddr4_s_axi_arcache, c0_ddr4_s_axi_arprot, c0_ddr4_s_axi_arqos, 
  c0_ddr4_s_axi_arvalid, c0_ddr4_s_axi_arready, c0_ddr4_s_axi_rready, c0_ddr4_s_axi_rid, 
  c0_ddr4_s_axi_rdata, c0_ddr4_s_axi_rresp, c0_ddr4_s_axi_rlast, c0_ddr4_s_axi_rvalid, 
  dbg_bus)
/* synthesis syn_black_box black_box_pad_pin="sys_rst,c0_sys_clk_p,c0_sys_clk_n,c0_ddr4_act_n,c0_ddr4_adr[16:0],c0_ddr4_ba[1:0],c0_ddr4_bg[0:0],c0_ddr4_cke[0:0],c0_ddr4_odt[0:0],c0_ddr4_cs_n[0:0],c0_ddr4_ck_t[0:0],c0_ddr4_ck_c[0:0],c0_ddr4_reset_n,c0_ddr4_dm_dbi_n[3:0],c0_ddr4_dq[31:0],c0_ddr4_dqs_c[3:0],c0_ddr4_dqs_t[3:0],c0_init_calib_complete,c0_ddr4_ui_clk,c0_ddr4_ui_clk_sync_rst,addn_ui_clkout1,dbg_clk,dbg_rd_data_cmp[63:0],dbg_expected_data[63:0],dbg_cal_seq[2:0],dbg_cal_seq_cnt[31:0],dbg_cal_seq_rd_cnt[7:0],dbg_rd_valid,dbg_cmp_byte[5:0],dbg_rd_data[63:0],dbg_cplx_config[15:0],dbg_cplx_status[1:0],dbg_io_address[27:0],dbg_pllGate,dbg_phy2clb_fixdly_rdy_low[19:0],dbg_phy2clb_fixdly_rdy_upp[19:0],dbg_phy2clb_phy_rdy_low[19:0],dbg_phy2clb_phy_rdy_upp[19:0],cal_r0_status[127:0],cal_post_status[8:0],c0_ddr4_aresetn,c0_ddr4_s_axi_awid[3:0],c0_ddr4_s_axi_awaddr[29:0],c0_ddr4_s_axi_awlen[7:0],c0_ddr4_s_axi_awsize[2:0],c0_ddr4_s_axi_awburst[1:0],c0_ddr4_s_axi_awlock[0:0],c0_ddr4_s_axi_awcache[3:0],c0_ddr4_s_axi_awprot[2:0],c0_ddr4_s_axi_awqos[3:0],c0_ddr4_s_axi_awvalid,c0_ddr4_s_axi_awready,c0_ddr4_s_axi_wdata[31:0],c0_ddr4_s_axi_wstrb[3:0],c0_ddr4_s_axi_wlast,c0_ddr4_s_axi_wvalid,c0_ddr4_s_axi_wready,c0_ddr4_s_axi_bready,c0_ddr4_s_axi_bid[3:0],c0_ddr4_s_axi_bresp[1:0],c0_ddr4_s_axi_bvalid,c0_ddr4_s_axi_arid[3:0],c0_ddr4_s_axi_araddr[29:0],c0_ddr4_s_axi_arlen[7:0],c0_ddr4_s_axi_arsize[2:0],c0_ddr4_s_axi_arburst[1:0],c0_ddr4_s_axi_arlock[0:0],c0_ddr4_s_axi_arcache[3:0],c0_ddr4_s_axi_arprot[2:0],c0_ddr4_s_axi_arqos[3:0],c0_ddr4_s_axi_arvalid,c0_ddr4_s_axi_arready,c0_ddr4_s_axi_rready,c0_ddr4_s_axi_rid[3:0],c0_ddr4_s_axi_rdata[31:0],c0_ddr4_s_axi_rresp[1:0],c0_ddr4_s_axi_rlast,c0_ddr4_s_axi_rvalid,dbg_bus[511:0]" */;
  input sys_rst;
  input c0_sys_clk_p;
  input c0_sys_clk_n;
  output c0_ddr4_act_n;
  output [16:0]c0_ddr4_adr;
  output [1:0]c0_ddr4_ba;
  output [0:0]c0_ddr4_bg;
  output [0:0]c0_ddr4_cke;
  output [0:0]c0_ddr4_odt;
  output [0:0]c0_ddr4_cs_n;
  output [0:0]c0_ddr4_ck_t;
  output [0:0]c0_ddr4_ck_c;
  output c0_ddr4_reset_n;
  inout [3:0]c0_ddr4_dm_dbi_n;
  inout [31:0]c0_ddr4_dq;
  inout [3:0]c0_ddr4_dqs_c;
  inout [3:0]c0_ddr4_dqs_t;
  output c0_init_calib_complete;
  output c0_ddr4_ui_clk;
  output c0_ddr4_ui_clk_sync_rst;
  output addn_ui_clkout1;
  output dbg_clk;
  output [63:0]dbg_rd_data_cmp;
  output [63:0]dbg_expected_data;
  output [2:0]dbg_cal_seq;
  output [31:0]dbg_cal_seq_cnt;
  output [7:0]dbg_cal_seq_rd_cnt;
  output dbg_rd_valid;
  output [5:0]dbg_cmp_byte;
  output [63:0]dbg_rd_data;
  output [15:0]dbg_cplx_config;
  output [1:0]dbg_cplx_status;
  output [27:0]dbg_io_address;
  output dbg_pllGate;
  output [19:0]dbg_phy2clb_fixdly_rdy_low;
  output [19:0]dbg_phy2clb_fixdly_rdy_upp;
  output [19:0]dbg_phy2clb_phy_rdy_low;
  output [19:0]dbg_phy2clb_phy_rdy_upp;
  output [127:0]cal_r0_status;
  output [8:0]cal_post_status;
  input c0_ddr4_aresetn;
  input [3:0]c0_ddr4_s_axi_awid;
  input [29:0]c0_ddr4_s_axi_awaddr;
  input [7:0]c0_ddr4_s_axi_awlen;
  input [2:0]c0_ddr4_s_axi_awsize;
  input [1:0]c0_ddr4_s_axi_awburst;
  input [0:0]c0_ddr4_s_axi_awlock;
  input [3:0]c0_ddr4_s_axi_awcache;
  input [2:0]c0_ddr4_s_axi_awprot;
  input [3:0]c0_ddr4_s_axi_awqos;
  input c0_ddr4_s_axi_awvalid;
  output c0_ddr4_s_axi_awready;
  input [31:0]c0_ddr4_s_axi_wdata;
  input [3:0]c0_ddr4_s_axi_wstrb;
  input c0_ddr4_s_axi_wlast;
  input c0_ddr4_s_axi_wvalid;
  output c0_ddr4_s_axi_wready;
  input c0_ddr4_s_axi_bready;
  output [3:0]c0_ddr4_s_axi_bid;
  output [1:0]c0_ddr4_s_axi_bresp;
  output c0_ddr4_s_axi_bvalid;
  input [3:0]c0_ddr4_s_axi_arid;
  input [29:0]c0_ddr4_s_axi_araddr;
  input [7:0]c0_ddr4_s_axi_arlen;
  input [2:0]c0_ddr4_s_axi_arsize;
  input [1:0]c0_ddr4_s_axi_arburst;
  input [0:0]c0_ddr4_s_axi_arlock;
  input [3:0]c0_ddr4_s_axi_arcache;
  input [2:0]c0_ddr4_s_axi_arprot;
  input [3:0]c0_ddr4_s_axi_arqos;
  input c0_ddr4_s_axi_arvalid;
  output c0_ddr4_s_axi_arready;
  input c0_ddr4_s_axi_rready;
  output [3:0]c0_ddr4_s_axi_rid;
  output [31:0]c0_ddr4_s_axi_rdata;
  output [1:0]c0_ddr4_s_axi_rresp;
  output c0_ddr4_s_axi_rlast;
  output c0_ddr4_s_axi_rvalid;
  output [511:0]dbg_bus;
endmodule
