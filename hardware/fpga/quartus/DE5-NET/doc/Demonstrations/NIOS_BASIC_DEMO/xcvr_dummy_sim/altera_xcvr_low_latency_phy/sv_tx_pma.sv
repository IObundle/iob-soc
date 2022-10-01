// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// This block instantiates a single channel or a number of bonded
// channels. 

`timescale 1ps/1ps
module sv_tx_pma #(
  parameter bonded_lanes = 1,
  parameter bonding_master_ch_num = "0",
  parameter bonding_master_only = "-1",
  parameter reserved_ch = "-1",
  parameter pipe_mode = 0,   

  parameter data_rate = "0 ps",

  parameter mode = 8,
  parameter ser_loopback = "false",
  parameter auto_negotiation = "false",
  parameter plls = 1,
  parameter pll_sel = 0,
  parameter pclksel = "local_pclk",
  parameter ht_delay_sel = "false",
  parameter rx_det_pdb = "true",
  parameter tx_clk_div = 1, //(1,2,4,8)
  parameter cgb_sync          = "normal", //("normal","pcs_sync_rst","sync_rst")
  parameter pcie_g3_x8        = "non_pcie_g3_x8", //("non_pcie_g3_x8","pcie_g3_x8")
  parameter pll_feedback      = "non_pll_feedback", //("non_pll_feedback","pll_feedback")
  parameter reset_scheme      = "non_reset_bonding_scheme", //("non_reset_bonding_scheme","reset_bonding_scheme")
  parameter pcie_rst          = "normal_reset",    // valid values - normal_reset, pcie_reset 
  parameter pma_bonding_type  = "fb_compensation", // ("default","fb_compensation","old_xN")
  parameter cal_clk_sel       = "pm_aux_iqclk_cal_clk_sel_cal_clk",	//Valid values: pm_aux_iqclk_cal_clk_sel_cal_clk|pm_aux_iqclk_cal_clk_sel_iqclk0|pm_aux_iqclk_cal_clk_sel_iqclk1|pm_aux_iqclk_cal_clk_sel_iqclk2|pm_aux_iqclk_cal_clk_sel_iqclk3|pm_aux_iqclk_cal_clk_sel_iqclk4|pm_aux_iqclk_cal_clk_sel_iqclk5|pm_aux_iqclk_cal_clk_sel_iqclk6|pm_aux_iqclk_cal_clk_sel_iqclk7|pm_aux_iqclk_cal_clk_sel_iqclk8|pm_aux_iqclk_cal_clk_sel_iqclk9|pm_aux_iqclk_cal_clk_sel_iqclk10
  parameter fir_coeff_ctrl_sel = "ram_ctl",	//Valid values: dynamic_ctl|ram_ctl
  parameter pma_direct        = "false" // ("true","false") PMA_DIRECT parameter
  ) ( 
  //input port for aux
  input [bonded_lanes - 1 : 0] 	    calclk,
  input [bonded_lanes*11 - 1: 0]    refiqclk,
  //input port for buf
  input [bonded_lanes * 80 - 1 : 0] datain,
  input [bonded_lanes - 1 : 0] 	    txelecidl,
  input [bonded_lanes - 1 : 0]      rxdetclk,
  input [bonded_lanes - 1 : 0] 	    txdetrx,
  input [bonded_lanes * 18 -1 :0]   icoeff,
  input [bonded_lanes - 1 : 0] 	    txqpipulldn, // QPI input port
  input [bonded_lanes - 1 : 0]      txqpipullup, // QPI input port  
  
  //output port for buf
  output [bonded_lanes - 1 : 0]     dataout,
  output [bonded_lanes - 1 : 0]     rxdetectvalid,
  output [bonded_lanes - 1 : 0]     rxfound,
  
  //input ports for ser
  input [bonded_lanes - 1 : 0] 	    rstn,
  input [bonded_lanes - 1 : 0]      pcs_rst_n, 
  input [bonded_lanes - 1 : 0] 	    seriallpbken,
  
  //output ports for ser
  output [bonded_lanes - 1 : 0]     clkdivtx, 
  output [bonded_lanes - 1 : 0]     seriallpbkout,

  //input ports for cgb
  input [bonded_lanes*plls-1:0]     clk, // High-speed serial clocks from PLLs
  input [1 : 0] 		    pciesw, // to the master channel
  input [bonded_lanes-1:0 ] 	    txpmasyncp, // Reset pulse from HIP hard reset controller through Gen3 PCS to reset counters in the CGB

  //output ports for cgb
  output [(bonded_lanes*2)-1 : 0]   pcieswdone, // from the master channel
  output [bonded_lanes - 1 : 0]     pcie_fb_clk, // PLL feedback clock for PCIe Gen3 x8
  output [bonded_lanes - 1 : 0]     pll_fb_sw, // PLL feedback clock select
  

  input [bonded_lanes-1:0 ] 	    avmmrstn, // one for each lane
  input [bonded_lanes-1:0 ] 	    avmmclk, // one for each lane
  input [bonded_lanes-1:0 ] 	    avmmwrite, // one for each lane
  input [bonded_lanes-1:0 ] 	    avmmread, // one for each lane
  input [(bonded_lanes*2)-1:0 ]     avmmbyteen, // two for each lane
  input [(bonded_lanes*11)-1:0 ]    avmmaddress, // 11 for each lane
  input [(bonded_lanes*16)-1:0 ]    avmmwritedata, // 16 for each lane
  output [(bonded_lanes*16)-1:0 ]   avmmreaddata_cgb, // CGB readdata
  output [(bonded_lanes*16)-1:0 ]   avmmreaddata_ser, // SER readdata
  output [(bonded_lanes*16)-1:0 ]   avmmreaddata_buf, // BUF readdata
  output [bonded_lanes-1:0 ] 	    blockselect_cgb, // CGB blockselect
  output [bonded_lanes-1:0 ] 	    blockselect_ser, // SER blockselect
  output [bonded_lanes-1:0 ] 	    blockselect_buf, // BUF blockselect
  
  input [bonded_lanes-1:0 ] 	    vrlpbkp,
  input [bonded_lanes-1:0 ] 	    vrlpbkn
);

  import altera_xcvr_functions::*;

  wire  [bonded_lanes-1:0]  w_hfclkp;
  wire  [bonded_lanes-1:0]  w_lfclkp;
  wire  [bonded_lanes-1:0]  w_cpulse;
  wire  [2:0]               w_pclk    [bonded_lanes-1:0];

  localparam  integer bonding_master_0 = str2int(get_value_at_index(0,bonding_master_ch_num));

  genvar i;                                
  generate 
  for(i = 0; i < bonded_lanes; i = i + 1) begin:tx_pma_insts 
    localparam [MAX_CHARS*8-1:0]  str_i = int2str(i);
    localparam is_single_chan = (bonded_lanes == 1) ? 1 : 0;
    localparam is_master_only = ( (is_single_chan == 0) && 
                                  (is_in_legal_set(str_i,bonding_master_ch_num) == 1) &&
                                  (is_in_legal_set(str_i,bonding_master_only) == 1))
                                  ? 1 : 0;
    localparam is_master_chan = ( (is_single_chan == 0) &&
                                  (is_master_only == 0) &&
                                  (is_in_legal_set(str_i,bonding_master_ch_num) == 1))
                                  ? 1 : 0;
    localparam is_slave_chan  = ( (is_single_chan == 0) &&
                                  ((is_in_legal_set(str_i,bonding_master_ch_num) == 0) &&
                                  (is_in_legal_set(str_i,reserved_ch) == 0)))
                                  ? 1 : 0;

    // Use feedback compensation netlist for this channel under the following conditions:
    //  1 - If the pma bonding type is set to feedback compensation
    //  2 - or .. If the pma bonding type is set to "default" and this is the master channel
    localparam is_fb_comp     = ( ((is_single_chan == 0) && (pma_bonding_type == "fb_compensation") && (is_in_legal_set(str_i,reserved_ch) == 0)) ||
                                  ((is_master_chan == 1) && (pma_bonding_type == "default")) )
                                  ? 1 : 0; 
    // Determine PMA type
    localparam  [MAX_CHARS*8-1:0] tx_pma_type = (is_single_chan == 1) ? "SINGLE_CHANNEL"        :
                                                (is_fb_comp     == 1) ? "FB_COMP_CHANNEL"       :
                                                (is_master_only == 1) ? "MASTER_ONLY"           :
                                                (is_master_chan == 1) ? "MASTER_SINGLE_CHANNEL" :
                                                (is_slave_chan  == 1) ? "SLAVE_CHANNEL"         :
                                                                        "EMPTY_CHANNEL"         ;
    // Determine the bonding master for this channel
    // If only one bonding master was specified, we select it.
    // If a bonding master per channel was specified, we select the corresponding master
    localparam  [MAX_CHARS*8-1:0] master_sel_str = get_value_at_index(i,bonding_master_ch_num);
    localparam  integer master_sel  = (master_sel_str == "NA") ? bonding_master_0 : str2int(master_sel_str);

    sv_tx_pma_ch #(
      .mode             (mode             ),
      .auto_negotiation (auto_negotiation ),
      .plls             (plls             ),
      .pll_sel          (pll_sel          ),
      .ser_loopback     (ser_loopback     ),
      .ht_delay_sel     (ht_delay_sel     ),
      .tx_pma_type      (tx_pma_type      ),
      .data_rate        (data_rate        ),
      .rx_det_pdb       (rx_det_pdb       ),
      .tx_clk_div       (tx_clk_div       ),
      .cgb_sync         (cgb_sync         ),
      .pcie_g3_x8       (pcie_g3_x8       ),
      .pll_feedback     (pll_feedback     ),
      .reset_scheme     (reset_scheme     ),
      .pcie_rst         (pcie_rst         ), 
      .cal_clk_sel      (cal_clk_sel      ), 
      .fir_coeff_ctrl_sel(fir_coeff_ctrl_sel),
      .pma_direct       (pma_direct       )
    ) sv_tx_pma_ch_inst ( 
      //input port for aux
      .calclk       (calclk       [i] ),
      .refiqclk     (refiqclk     [i* 11+: 11] ),
      //input port for buf
      .datain       (datain       [i*80+:80]),
      .txelecidl    (txelecidl    [i] ),
      .rxdetclk     (rxdetclk     [i] ),
      .txdetrx      (txdetrx      [i] ),
      .icoeff       (icoeff       [i*18+:18]),
      .txqpipulldn  (txqpipulldn  [i] ), // QPI input port
      .txqpipullup  (txqpipullup  [i] ), // QPI input port  

      //output port for buf
      .dataout      (dataout      [i] ),
      .rxdetectvalid(rxdetectvalid[i] ),
      .rxfound      (rxfound      [i] ),
      
      //input ports for ser
      .rstn         (rstn         [i] ),
      .pcs_rst_n    (pcs_rst_n    [i] ),
      .seriallpbken (seriallpbken [i] ),
      
      //output ports for ser
      .clkdivtx     (clkdivtx     [i] ),
      .seriallpbkout(seriallpbkout[i] ),
      
      //input ports for cgb
      .clk          (clk          [i*plls+:plls]),
      .pciesw       (pciesw           ),
      .txpmasyncp   (txpmasyncp   [i] ),

      // bonding clock inputs from master CGB
      .cpulsein     (w_cpulse     [master_sel]  ),
      .hfclkpin     (w_hfclkp     [master_sel]  ),
      .lfclkpin     (w_lfclkp     [master_sel]  ),
      .pclkin       (w_pclk       [master_sel]  ),
      
      //output ports for cgb
      .pcieswdone   (pcieswdone   [i*2+:2]  ),
      .pcie_fb_clk  (pcie_fb_clk  [i] ),
      .pll_fb_sw    (pll_fb_sw    [i] ),

      //
      .cpulseout    (w_cpulse     [i] ),
      .hfclkpout    (w_hfclkp     [i] ),
      .lfclkpout    (w_lfclkp     [i] ),
      .pclkout      (w_pclk       [i] ),

      .vrlpbkp      (vrlpbkp      [i] ),
      .vrlpbkn      (vrlpbkn      [i] ),
      // Avalon-MM interface
      .avmmrstn         (avmmrstn     [i]           ),
      .avmmclk          (avmmclk      [i]           ),
      .avmmwrite        (avmmwrite    [i]           ),
      .avmmread         (avmmread     [i]           ),
      .avmmbyteen       (avmmbyteen   [i*2+:2]      ),
      .avmmaddress      (avmmaddress  [i*11+:11]    ),
      .avmmwritedata    (avmmwritedata[i*16+:16]    ),
      .avmmreaddata_cgb (avmmreaddata_cgb[i*16+:16] ),  // CGB readdata
      .avmmreaddata_ser (avmmreaddata_ser[i*16+:16] ),  // SER readdata
      .avmmreaddata_buf (avmmreaddata_buf[i*16+:16] ),  // BUF readdata
      .blockselect_cgb  (blockselect_cgb[i]         ),  // CGB blockselect
      .blockselect_ser  (blockselect_ser[i]         ),  // SER blockselect
      .blockselect_buf  (blockselect_buf[i]         )   // BUF blockselect
    );
  end
  endgenerate
endmodule

    
