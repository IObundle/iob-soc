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


// NOTES: parameter tx_pma_type can take the following four values:
// (1) SINGLE_CHANNEL --
//
// the sv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. 'datain' and 'dataout' have to be connected as 
// expected.
//
// (2) MASTER_SINGLE_CHANNEL --
//
// the sv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. In addition, the module outputs the bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). These clocks must be
// connected to another instance of sv_tx_pma_ch that serves as SLAVE_CHANNEL. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (3) SLAVE_CHANNEL --
//
// the sv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. The cgb in this case is not used to divide the high frequency clock 
// from the tx pll, but to forward the bonding clocks to the serializer. It is required that
// the bonding clock bondle is connected to the inputs (hfclkpin, lfclkpin,cpulsein, 
// pclk0in,pclk1in). These clocks must come from a sv_tx_pma_ch block that serves 
// as MASTER_SINGLE_CHANNEL or as MASTER_ONLY. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (4) MASTER_ONLY
//
// the sv_tx_pma_ch block will only instantiate a cgb -> ser. The cgb is used to divide the
// high frequency clock from the tx pll (input clk) and produce bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). The serializer block in this case is
// configured in a special clk_forward_only_mode = true. This indicates that the serializer
// does not serve its usual role of converting data on a parallel bus input into a serial output,
// but serves to only forward the parallel clock from the cgb to the output clkdivtx.
// 

`timescale 1ps/1ps
module sv_tx_pma_ch #(
    parameter mode              = 8,
    parameter auto_negotiation  = "false",
    parameter plls              = 1,
    parameter pll_sel           = 0,
    parameter ser_loopback      = "false",
    parameter ht_delay_sel      = "false",
    parameter tx_pma_type       = "SINGLE_CHANNEL",
    parameter data_rate         = "0 ps",
    parameter rx_det_pdb        = "true",
    parameter tx_clk_div        = 1, //(1,2,4,8)
    parameter cgb_sync          = "normal", //("normal","pcs_sync_rst","sync_rst")
    parameter pcie_g3_x8        = "non_pcie_g3_x8", //("non_pcie_g3_x8","pcie_g3_x8")
    parameter pll_feedback      = "non_pll_feedback", //("non_pll_feedback","pll_feedback")
    parameter reset_scheme      = "non_reset_bonding_scheme", //("non_reset_bonding_scheme","reset_bonding_scheme")
    parameter pcie_rst        = "normal_reset", // PCS reset to be used for CGB in PCIe HIP configurations 
	parameter cal_clk_sel       = "pm_aux_iqclk_cal_clk_sel_cal_clk",	//Valid values: pm_aux_iqclk_cal_clk_sel_cal_clk|pm_aux_iqclk_cal_clk_sel_iqclk0|pm_aux_iqclk_cal_clk_sel_iqclk1|pm_aux_iqclk_cal_clk_sel_iqclk2|pm_aux_iqclk_cal_clk_sel_iqclk3|pm_aux_iqclk_cal_clk_sel_iqclk4|pm_aux_iqclk_cal_clk_sel_iqclk5|pm_aux_iqclk_cal_clk_sel_iqclk6|pm_aux_iqclk_cal_clk_sel_iqclk7|pm_aux_iqclk_cal_clk_sel_iqclk8|pm_aux_iqclk_cal_clk_sel_iqclk9|pm_aux_iqclk_cal_clk_sel_iqclk10
  	parameter fir_coeff_ctrl_sel = "ram_ctl",	//Valid values: dynamic_ctl|ram_ctl
  	parameter pma_direct        = "false" // ("true","false") PMA_DIRECT parameter

) ( 
  //input port for aux
  input 	   calclk,
  input [10: 0]    refiqclk,

  //input port for buf
  input [79:0] 	   datain,
  input 	   txelecidl,
  input 	   rxdetclk,
  input 	   txdetrx,
  input [17:0] 	   icoeff,
  input 	   txqpipulldn, // QPI input port
  input            txqpipullup, // QPI input port

  //output port for buf
  output 	   dataout,
  output 	   rxdetectvalid,
  output 	   rxfound,
  
  //input ports for ser
  input 	   rstn,
  input      pcs_rst_n, 
  input 	   seriallpbken,
  
  //output ports for ser
  output 	   clkdivtx,
  output 	   seriallpbkout,
  
  //input ports for cgb
  input [plls-1:0] clk,
  input [1:0] 	   pciesw,
  input 	   txpmasyncp,
 
  // bonding clock inputs from master CGB
  input 	   cpulsein,
  input 	   hfclkpin,
  input 	   lfclkpin,
  input [2:0] 	   pclkin,
  
  //output ports for cgb
  output [1:0] 	   pcieswdone,
  output 	   pcie_fb_clk, // PLL feedback clock for PCIe Gen3 x8
  output 	   pll_fb_sw, // PLL feedback clock select
  
  // bonding clock outputs (driven if this CGB is acting as a master)
  output 	   hfclkpout,
  output 	   lfclkpout,
  output 	   cpulseout,
  output [2:0] 	   pclkout,
  
  input 	   avmmrstn,
  input 	   avmmclk,
  input 	   avmmwrite,
  input 	   avmmread,
  input [1:0 ] 	   avmmbyteen,
  input [10:0 ]    avmmaddress,
  input [15:0 ]    avmmwritedata,
  output [15:0 ]   avmmreaddata_cgb, // CGB readdata
  output [15:0 ]   avmmreaddata_ser, // SER readdata
  output [15:0 ]   avmmreaddata_buf, // BUF readdata
  output 	   blockselect_cgb, // CGB blockselect
  output 	   blockselect_ser, // SER blockselect
  output 	   blockselect_buf, // BUF blockselect
     
  input 	   vrlpbkp,
  input 	   vrlpbkn  
);

  localparam  MAX_PLLS = 8;
  localparam  PLL_CNT = (plls < MAX_PLLS) ? plls : MAX_PLLS;

  localparam  integer is_single_chan = (tx_pma_type == "SINGLE_CHANNEL"       ) ? 1 : 0;
  localparam  integer is_master_only = (tx_pma_type == "MASTER_ONLY"          ) ? 1 : 0;
  localparam  integer is_master_chan = (tx_pma_type == "MASTER_SINGLE_CHANNEL") ? 1 : 0;
  localparam  integer is_slave_chan  = (tx_pma_type == "SLAVE_CHANNEL"        ) ? 1 : 0;
  localparam  integer is_empty_chan  = (tx_pma_type == "EMPTY_CHANNEL"        ) ? 1 : 0;
  localparam  integer is_fb_comp     = (tx_pma_type == "FB_COMP_CHANNEL"      ) ? 1 : 0;  
  // to support bonding 

  // Select clock source for g2/g3 and g1 based on auto_negotiation
  localparam X1_CLOCK_SOURCE_SEL_AUTONEG =
                  (auto_negotiation == "true") ? "same_ch_txpll_g2_ch1_txpll_t_g3"
                : (is_fb_comp == 1) ? "same_ch_txpll"  // 5  - clk_cdr_loc
              //: (pll_sel ==11) ? "hfclk_ch1_x6_up"// 9  - hfclkp_x6_up
              //: (pll_sel ==10) ? "hfclk_xn_dn"    // 8  - hfclkp_xn_dn
              //: (pll_sel == 9) ? "hfclk_ch1_x6_dn"// 7  - hfclkp_x6_dn
              //: (pll_sel == 8) ? "hfclk_xn_up"    // 6  - hfclkp_xn_up
              //: (pll_sel == 7) ? "down_segmented" // 1  - clk_dn_seg
              //: (pll_sel == 6) ? "up_segmented"   // 0  - clk_up_seg
              //: (pll_sel == 5) ? "ffpll"          // 2  - clk_ffpll
                : (pll_sel == 4) ? "lcpll_bottom"   // 11 - clk_lc_b
                : (pll_sel == 3) ? "lcpll_top"      // 10 - clk_lc_t
                : (pll_sel == 2) ? "ch1_txpll_b"    // 4  - clk_cdr_1b
                : (pll_sel == 1) ? "ch1_txpll_t"    // 3  - clk_cdr_1t 
                : (pll_sel == 0) ? "same_ch_txpll"  // 5  - clk_cdr_loc
                : "same_ch_txpll";

  localparam X1_DIV_M_SEL = (tx_clk_div == 2) ? 2 :
                            (tx_clk_div == 4) ? 4 :
                            (tx_clk_div == 8) ? 8 :
                            1;    

  generate if(is_empty_chan == 0) begin:tx_pma_ch
    wire  [MAX_PLLS-1:0] wire_clk;

    wire  [79:0]  w_datain;
    wire          w_txelecidl;
    wire          w_rxdetclk;
    wire          w_txdetrx;

    wire        cpulse_from_cgb;
    wire        hclk_from_cgb;
    wire        lfclk_from_cgb;
    wire  [2:0] pclk_from_cgb;
    wire        dataout_from_ser;
    
    wire        wire_hfclkpin;
    wire        wire_lfclkpin;
    wire        wire_cpulsein;
    wire  [2:0] wire_pclkin;
    
    wire        wire_hfclkpout;
    wire        wire_lfclkpout;
    wire        wire_cpulseout;
    wire  [2:0] wire_pclkout;

    wire  [1:0] w_pciesw;
    
    // for bonding support 
    wire        cpulse_from_cgb_master; 
    wire        hclk_from_cgb_master  ;
    wire        lfclk_from_cgb_master ;
    wire [2:0]  pclk_from_cgb_master  ;
   
    assign  w_datain    = (is_master_only == 0) ? datain    : 80'd0;
    assign  w_txelecidl = (is_master_only == 0) ? txelecidl : 1'b0;
    assign  w_rxdetclk  = (is_master_only == 0) ? rxdetclk  : 1'b0;
    assign  w_txdetrx   = (is_master_only == 0) ? txdetrx   : 1'b0;
    
    // Determine what drives the bonding lines input to the CGB
    assign wire_hfclkpin = (is_single_chan == 1) ? 1'b0           : 
                           (is_fb_comp     == 1) ? wire_hfclkpout : 
                           (is_master_chan == 1) ? wire_hfclkpout :
                           (is_master_only == 1) ? wire_hfclkpout :
                                                   hfclkpin       ;
    
    assign wire_lfclkpin = (is_single_chan == 1) ? 1'b0           :
                           (is_fb_comp     == 1) ? wire_lfclkpout :
                           (is_master_chan == 1) ? wire_lfclkpout :
                           (is_master_only == 1) ? wire_lfclkpout :
                                                   lfclkpin       ;
    
    assign wire_cpulsein = (is_single_chan == 1) ? 1'b0           :
                           (is_fb_comp     == 1) ? wire_cpulseout :
                           (is_master_chan == 1) ? wire_cpulseout :
                           (is_master_only == 1) ? wire_cpulseout :
                                                   cpulsein       ;
    
    assign wire_pclkin   = (is_single_chan == 1) ? 3'b000         :
                           (is_fb_comp     == 1) ? wire_pclkout   :
                           (is_master_chan == 1) ? wire_pclkout   :
                           (is_master_only == 1) ? wire_pclkout   :
                                                   pclkin         ;
     
    
    // determine what drives the bonding lines output from this module
    assign hfclkpout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_hfclkpout;
    
    assign lfclkpout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_lfclkpout;
    
    assign cpulseout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_cpulseout;
    
    assign pclkout =  (is_single_chan == 1) ? 1'b0 :
                      (is_slave_chan  == 1) ? 1'b0 :
                                              wire_pclkout;
    
    
    // determine what drives the HF clock input into CGB
    assign wire_clk = (is_slave_chan == 1) ? {MAX_PLLS{1'b0}} // no clock can be connected in a slave mode
                      : {{(MAX_PLLS-PLL_CNT){1'b0}},clk};  // otherwise, connect the input clock
    
    assign  w_pciesw = (auto_negotiation == "false") ? 2'b00 : pciesw;
    
    wire        avmmrstn_master     ;    
    wire        avmmclk_master      ;    
    wire        avmmwrite_master    ;  
    wire        avmmread_master     ;  
    wire [1:0]  avmmbyteen_master   ;  
    wire [10:0] avmmaddress_master  ;  
    wire [15:0] avmmwritedata_master; 
    wire [15:0] avmmreaddata_master ;
    wire        blockselect_master  ;

    // Only connect CGB AVMM for non-bonded channels
    assign avmmrstn_master      = (is_single_chan == 1) ? avmmrstn      : 1'd1  ;
    assign avmmclk_master       = (is_single_chan == 1) ? avmmclk       : 1'd0  ; 
    assign avmmwrite_master     = (is_single_chan == 1) ? avmmwrite     : 1'd0  ;  
    assign avmmread_master      = (is_single_chan == 1) ? avmmread      : 1'd0  ;   
    assign avmmbyteen_master    = (is_single_chan == 1) ? avmmbyteen    : 2'd0  ; 
    assign avmmaddress_master   = (is_single_chan == 1) ? avmmaddress   : 11'd0 ;
    assign avmmwritedata_master = (is_single_chan == 1) ? avmmwritedata : 16'd0 ;
    
    stratixv_hssi_pma_tx_cgb #(
      .mode					(mode),
      .auto_negotiation		(auto_negotiation),
      .data_rate			(data_rate),
      .pcie_rst				(pcie_rst),
      .x1_clock_source_sel	( 
                     		((is_fb_comp == 1) || 
                      		 (is_single_chan == 1) ||
                      		 (is_master_chan == 1) ||
                      		 (is_master_only == 1)) ? X1_CLOCK_SOURCE_SEL_AUTONEG     // corresponds to .clkcdrloc input
                      		: "x1_clk_unused"),  // a special setting when the front-end mux of the CGB is not used (SLAVE CHANNEL ONLY)
      .xn_clock_source_sel	( 
                     		((is_fb_comp == 1) || 
                      		 (is_master_chan == 1) ||
                      		 (is_slave_chan == 1) ||
                      		 (is_master_only == 1))           ? "xn_up" : // corresponds to *xnup ports
                     		((is_single_chan == 1) && (ht_delay_sel == "true")) ? "cgb_ht" 
                     		: "cgb_x1_m_div"),
      .x1_div_m_sel			(X1_DIV_M_SEL),
    
      // Attributes for PCIe Gen3
      .cgb_sync				(cgb_sync),
      .clk_mute				("disable_clockmute"),
      .pcie_g3_x8			(((is_master_only == 1) || (is_master_chan == 1) || (is_single_chan == 1)) ? pcie_g3_x8 : "non_pcie_g3_x8"),
      .pll_feedback			(pll_feedback),
      .reset_scheme			(reset_scheme)
    ) tx_cgb (
      .rstn           (rstn             ),
`ifdef ALTERA_RESERVED_QIS_ES
      .pcs_rst_n      (                 ), // float connection for ES as this is a production only signal
`else 
      .pcs_rst_n      (pcs_rst_n        ),
`endif
      .clkcdrloc      (wire_clk[0]      ),
      .clkcdr1t       (wire_clk[1]      ),
      .clkcdr1b       (wire_clk[2]      ),
      .clklct         (wire_clk[3]      ),
      .clklcb         (wire_clk[4]      ),
      .clkffpll       (wire_clk[5]      ),
      .clkupseg       (wire_clk[6]      ),
      .clkdnseg       (wire_clk[7]      ),
      .pciesw         (w_pciesw         ),
      .hfclkpxnup     (wire_hfclkpin    ),
      .lfclkpxnup     (wire_lfclkpin    ),
      .cpulsexnup     (wire_cpulsein    ),
      .pclkxnup       (wire_pclkin      ),
      // to serializer
      .cpulse         (cpulse_from_cgb_master  ),
      .hfclkp         (hclk_from_cgb_master    ),
      .lfclkp         (lfclk_from_cgb_master   ),
      .pclk           (pclk_from_cgb_master    ),
      
      // when used as a CGB master, these are bonding clocks
      .cpulseout      (wire_cpulseout   ),
      .hfclkpout      (wire_hfclkpout   ),
      .lfclkpout      (wire_lfclkpout   ),
      .pclkout        (wire_pclkout     ),
      .pcieswdone     (pcieswdone       ),
      .pciefbclk      (pcie_fb_clk      ),
      .pllfbsw        (pll_fb_sw        ),
      .txpmasyncp     (txpmasyncp       ),
      
      .avmmrstn       (avmmrstn_master     ),
      .avmmclk        (avmmclk_master      ),
      .avmmwrite      (avmmwrite_master    ),
      .avmmread       (avmmread_master     ),
      .avmmbyteen     (avmmbyteen_master   ),
      .avmmaddress    (avmmaddress_master  ),
      .avmmwritedata  (avmmwritedata_master),
      .avmmreaddata   (avmmreaddata_master ),
      .blockselect    (blockselect_master  )

      `ifndef ALTERA_RESERVED_QIS
      ,
      .hfclkn         (                 ),
      .hfclknout      (                 ),
      .lfclkn         (                 ),
      .lfclknout      (                 ),
      .rxiqclk        (                 ),
      .fref           (1'b0             ),
      .rxclk          (1'b0             ),
      .clkbcdr1t      (1'b0             ),
      .clkbcdr1b      (1'b0             ),
      .clkbcdrloc     (1'b0             ),
      .clkbdnseg      (1'b0             ),
      .clkbffpll      (1'b0             ),
      .clkblcb        (1'b0             ),
      .clkblct        (1'b0             ),
      .clkbupseg      (1'b0             ),
      .cpulsex6up     (1'b0             ),
      .cpulsex6dn     (1'b0             ),
      .cpulsexndn     (1'b0             ),
      .hfclknx6up     (1'b0             ),
      .hfclknx6dn     (1'b0             ),
      .hfclknxndn     (1'b0             ),
      .hfclknxnup     (1'b0             ),
      .hfclkpx6up     (1'b0             ),
      .hfclkpx6dn     (1'b0             ),
      .hfclkpxndn     (1'b0             ),
      .lfclknx6up     (1'b0             ),
      .lfclknx6dn     (1'b0             ),
      .lfclknxndn     (1'b0             ),
      .lfclknxnup     (1'b0             ),
      .lfclkpx6up     (1'b0             ),
      .lfclkpx6dn     (1'b0             ),
      .lfclkpxndn     (1'b0             ),
      .pciesyncp      (/*TODO*/         ),
      .pclkx6up       (3'b0             ),
      .pclkx6dn       (3'b0             ),
      .pclkxndn       (3'b0             )
      `endif // ifndef ALTERA_RESERVED_QIS
    );
    
    // Outputs to AVMM
    // If feedback compensation is not used, signals from CGB connect to/from the AVMM 
    assign avmmreaddata_cgb     = (is_single_chan == 1) ? avmmreaddata_master: 16'd0 ; 
    assign blockselect_cgb      = (is_single_chan == 1) ? blockselect_master : 1'd0  ;
    
    if(is_fb_comp == 0) begin: tx_cgb_master
      // Based on the bonding type, either the master or the slave CGB output ports will be connected to the Serializer. 
      // If the bonding type is not feedback compensation, then the master CGB output ports will be connected to the Serializer  
      assign cpulse_from_cgb = cpulse_from_cgb_master; 
      assign hclk_from_cgb   = hclk_from_cgb_master  ; 
      assign lfclk_from_cgb  = lfclk_from_cgb_master ;
      assign pclk_from_cgb   = pclk_from_cgb_master  ;  
    end else begin
      wire        cpulse_from_cgb_slave  ;
      wire        hclk_from_cgb_slave    ;
      wire        lfclk_from_cgb_slave   ;
      wire  [2:0] pclk_from_cgb_slave    ;

      // slave CGB; This is cascaded to the Master CGB when feedback compensation bonding is used.
      // The cpulseout, hfclkpout, lfclkpout, pclkout, pcieswdone, pciefbclk, pllfbsw, txpmasyncp are left unconnected  
      assign cpulse_from_cgb = cpulse_from_cgb_slave; 
      assign hclk_from_cgb   = hclk_from_cgb_slave  ; 
      assign lfclk_from_cgb  = lfclk_from_cgb_slave ;
      assign pclk_from_cgb   = pclk_from_cgb_slave  ;  

      stratixv_hssi_pma_tx_cgb #(
        .mode					(mode),
        .auto_negotiation		(auto_negotiation),
        .data_rate				(data_rate),
        .x1_clock_source_sel	("x1_clk_unused"),
        .xn_clock_source_sel	("xn_up"),
        .x1_div_m_sel			(X1_DIV_M_SEL),
        .pcie_rst				(pcie_rst),
      
        // Attributes for PCIe Gen3
        .cgb_sync				(cgb_sync),
        .clk_mute				("disable_clockmute"),
        .pcie_g3_x8				(pcie_g3_x8),
        .pll_feedback			(pll_feedback),
        .reset_scheme			(reset_scheme)
      )tx_cgb_slave (
        .rstn           (rstn             ),
`ifdef ALTERA_RESERVED_QIS_ES
        .pcs_rst_n      (                 ), // float connection for ES as this is a production only signal
`else 
        .pcs_rst_n      (pcs_rst_n        ),
`endif
        .clkcdrloc      (1'b0             ),
        .clkcdr1t       (1'b0             ),
        .clkcdr1b       (1'b0             ),
        .clklct         (1'b0             ),
        .clklcb         (1'b0             ),
        .clkffpll       (1'b0             ),
        .clkupseg       (1'b0             ),
        .clkdnseg       (1'b0             ),
        .pciesw         (w_pciesw         ),
        .hfclkpxnup     (wire_hfclkpout   ),
        .lfclkpxnup     (wire_lfclkpout   ),
        .cpulsexnup     (wire_cpulseout   ),
        .pclkxnup       (wire_pclkout     ),
        // to serializer
        .cpulse         (cpulse_from_cgb_slave  ),
        .hfclkp         (hclk_from_cgb_slave    ),
        .lfclkp         (lfclk_from_cgb_slave   ),
        .pclk           (pclk_from_cgb_slave    ),
        
        // when used as a CGB master, these are bonding clocks
        .cpulseout      (                 ),
        .hfclkpout      (                 ),
        .lfclkpout      (                 ),
        .pclkout        (                 ),
        .pcieswdone     (                 ),
        .pciefbclk      (                 ),
        .pllfbsw        (                 ),
        .txpmasyncp     (                 ),
        
        .avmmrstn       (1'b1             ),
        .avmmclk        (1'b0             ),
        .avmmwrite      (1'b0             ),
        .avmmread       (1'b0             ),
        .avmmbyteen     (2'b00            ),
        .avmmaddress    (11'd0            ),
        .avmmwritedata  (16'd0            ),
        .avmmreaddata   (/*unused*/       ),
        .blockselect    (/*unused*/       )

        `ifndef ALTERA_RESERVED_QIS
        ,
        .hfclkn         (                 ),
        .hfclknout      (                 ),
        .lfclkn         (                 ),
        .lfclknout      (                 ),
        .rxiqclk        (                 ),
        .fref           (1'b0             ),
        .rxclk          (1'b0             ),
        .clkbcdr1t      (1'b0             ),
        .clkbcdr1b      (1'b0             ),
        .clkbcdrloc     (1'b0             ),
        .clkbdnseg      (1'b0             ),
        .clkbffpll      (1'b0             ),
        .clkblcb        (1'b0             ),
        .clkblct        (1'b0             ),
        .clkbupseg      (1'b0             ),
        .cpulsex6up     (1'b0             ),
        .cpulsex6dn     (1'b0             ),
        .cpulsexndn     (1'b0             ),
        .hfclknx6up     (1'b0             ),
        .hfclknx6dn     (1'b0             ),
        .hfclknxndn     (1'b0             ),
        .hfclknxnup     (1'b0             ),
        .hfclkpx6up     (1'b0             ),
        .hfclkpx6dn     (1'b0             ),
        .hfclkpxndn     (1'b0             ),
        .lfclknx6up     (1'b0             ),
        .lfclknx6dn     (1'b0             ),
        .lfclknxndn     (1'b0             ),
        .lfclknxnup     (1'b0             ),
        .lfclkpx6up     (1'b0             ),
        .lfclkpx6dn     (1'b0             ),
        .lfclkpxndn     (1'b0             ),
        .pciesyncp      (/*TODO*/         ),
        .pclkx6up       (3'b0             ),
        .pclkx6dn       (3'b0             ),
        .pclkxndn       (3'b0             )
        `endif // ifndef ALTERA_RESERVED_QIS
      );
    end
    
    stratixv_hssi_pma_tx_ser #(
      .duty_cycle_tune       ("duty_cycle4"),  // iTrack 80215 - always use static setting of '4' for rser_dc_tune DCD compensation
      .pma_direct            (pma_direct),
      .mode                  (mode),
      .auto_negotiation      (auto_negotiation),
      .ser_loopback          (ser_loopback),
      .clk_forward_only_mode ((is_master_only == 1) ? "true" : "false")
    ) tx_pma_ser (
      .cpulse         (cpulse_from_cgb  ),
      .datain         (w_datain         ),
      .hfclk          (hclk_from_cgb    ),
      .lfclk          (lfclk_from_cgb   ),
      .pclk           (pclk_from_cgb    ),
      .pciesw         (w_pciesw         ),
      .rstn           (rstn             ),
      .clkdivtx       (clkdivtx         ),
      .dataout        (dataout_from_ser ),
      .lbvop          (seriallpbkout    ),
      .slpbk          (seriallpbken     ),
      .hfclkn         (1'b0             ),
      .lfclkn         (1'b0             ),
      .lbvon          (/*TODO*/         ),
      .preenout       (/*TODO*/         ),
      .pciesyncp      (/*TODO*/         ),
      .avmmrstn       (avmmrstn         ),
      .avmmclk        (avmmclk          ),
      .avmmwrite      (avmmwrite        ),
      .avmmread       (avmmread         ),
      .avmmbyteen     (avmmbyteen       ),
      .avmmaddress    (avmmaddress      ),
      .avmmwritedata  (avmmwritedata    ),
      .avmmreaddata   (avmmreaddata_ser ),
      .blockselect    (blockselect_ser  )
    );
    

    if (is_master_only == 0) begin:tx_pma_buf
      wire nonuserfrompmaux;
      
      stratixv_hssi_pma_aux  #(
        .cal_clk_sel  (cal_clk_sel),
        .continuous_calibration ("true"),
        .rx_imp("cal_imp_52_ohm"),
        .tx_imp("cal_imp_52_ohm")
      ) tx_pma_aux (
        .calpdb       (1'b1             ),
        .calclk       (calclk           ),
        .testcntl     (/*unused*/       ),
        .refiqclk     (refiqclk         ),
        .nonusertoio  (nonuserfrompmaux ),
        .zrxtx50      (/*unused*/       )
      ); 
                    
      stratixv_hssi_pma_tx_buf #(
        .rx_det_pdb(rx_det_pdb),
        .fir_coeff_ctrl_sel(fir_coeff_ctrl_sel)
      ) tx_pma_buf (
        .nonuserfrompmaux (nonuserfrompmaux ),
        .datain           (dataout_from_ser ),
        .rxdetclk         (w_rxdetclk       ),
        .txdetrx          (w_txdetrx        ),
        .txelecidl        (w_txelecidl      ),
        .rxdetectvalid    (rxdetectvalid    ),
        .dataout          (dataout          ),
        .rxfound          (rxfound          ),
        .txqpipulldn      (txqpipulldn      ), // QPI input port
        .txqpipullup      (txqpipullup      ), // QPI input port
        .fixedclkout      (/*TODO*/         ),
        .vrlpbkn          (vrlpbkn          ),
        .vrlpbkp          (vrlpbkp          ),
        .vrlpbkp1t        (/*TODO*/         ),
        .vrlpbkn1t        (/*TODO*/         ),
        .icoeff           (icoeff           ),
        .avmmrstn         (avmmrstn         ),
        .avmmclk          (avmmclk          ),
        .avmmwrite        (avmmwrite        ),
        .avmmread         (avmmread         ),
        .avmmbyteen       (avmmbyteen       ),
        .avmmaddress      (avmmaddress      ),
        .avmmwritedata    (avmmwritedata    ),
        .avmmreaddata     (avmmreaddata_buf ),
        .blockselect      (blockselect_buf  )
      );
    end // end of if (is_master_only == 0)
  end else begin  // if dummy_chan
    // Warning avoidance
    assign  dataout = {1'b0,calclk,datain,txelecidl,rxdetclk,txdetrx,
              rstn,seriallpbken,clk,pciesw,txpmasyncp,cpulsein,
              hfclkpin,lfclkpin,pclkin,avmmrstn,avmmclk,avmmwrite,
              avmmread,avmmbyteen,avmmaddress,avmmwritedata, 
              vrlpbkp,vrlpbkn};

    assign  rxdetectvalid = 1'b0;
    assign  rxfound       = 1'b0;
    assign  clkdivtx      = 1'b0;
    assign  seriallpbkout = 1'b0;
    assign  pcieswdone    = 2'b00;
    assign  pcie_fb_clk   = 1'b0;
    assign  pll_fb_sw     = 1'b0;
    assign  hfclkpout     = 1'b0;
    assign  lfclkpout     = 1'b0;
    assign  cpulseout     = 1'b0;
    assign  pclkout       = 3'b000;
    
    assign  avmmreaddata_cgb  = 16'd0;
    assign  avmmreaddata_ser  = 16'd0;
    assign  avmmreaddata_buf  = 16'd0;
    assign  blockselect_cgb   = 1'b0;
    assign  blockselect_ser   = 1'b0;
    assign  blockselect_buf   = 1'b0;
  end
  endgenerate

initial begin
  if( (tx_clk_div != 1) && (tx_clk_div != 2) && (tx_clk_div != 4) && (tx_clk_div != 8) ) begin
    $display("Warning: parameter 'tx_clk_div' of instance '%m' has illegal value '%0d' assigned to it. Valid parameter values are: '1,2,4,8'. Using value '%0d'", tx_clk_div, X1_DIV_M_SEL);
  end
end
        
endmodule

                
