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


`timescale 1ps/1ps

module sv_pma #(
  //PARAM_LIST_START
    parameter rx_enable         = 1,                // (1,0) Enable or disable reciever PMA
    parameter tx_enable         = 1,                // (1,0) Enable or disable transmitter PMA
    // Bonding parameters
    parameter bonded_lanes      = 1,                // Number of bonded lanes
    parameter bonding_master_ch = 0,                // PCS bonding master channel. Used to connect pciesw to CGB.
    parameter pma_bonding_master= "0",              // (List i.e. "0,3,..."), (PIPE only) Indicates which channels is master
    parameter bonding_master_only = "-1",           // (List i.e. "0,3,..."), (PIPE only) Indicates bonding_master_ch is MASTER_ONLY 
    parameter pma_reserved_ch   = "-1",             // (List i.e. "0,2,...") (PIPE only) Indicates which channels are reserved (unused). 
    parameter pma_bonding_type	= "default",        // PMA bonding type

    parameter plls              = 1,                // (1+) Number of high-speed serial clocks from TX plls (tx_ser_clk)
    parameter pll_sel           = 0,                // (0 - plls-1) // Which PLL clock to use
    parameter pma_prot_mode     = "basic",          // (basic,cpri,cpri_rx_tx,disabled_prot_mode,gige, pipe_g1,pipe_g2,pipe_g3,srio_2p1,test,xaui)
    parameter pma_mode          = 8,                // (8,10,16,20,32,40,64,80) Serialization factor
    parameter pma_data_rate     = "1250000000 bps", // Serial data rate in bits-per-second
    parameter cdr_reference_clock_frequency = "100 Mhz",
    parameter cdr_refclk_cnt    = 1,                // # of CDR reference clocks
    parameter cdr_refclk_sel    = 0,                // Initial CDR reference clock selection
    parameter cdr_reconfig      = 0,                // 1-Enable CDR reconfiguration, 0-Disable CDR reconfiguration
    parameter deser_enable_bit_slip   = "false",
    parameter auto_negotiation  = "<auto_single>",  // ("true","false") PCIe Auto-Negotiation (Gen1,2,3)
    parameter tx_clk_div        = 1,                // (1,2,4,8)
    parameter sd_on             = 16,               // (0,1,2...16) Signal Detect Threshold. 0->DATA_PULSE_4, 1->DATA_PULSE_6,....,16->FORCE_SD_ON
    parameter cgb_sync          = "normal",           //("normal","pcs_sync_rst","sync_rst")
    parameter pcie_g3_x8        = "non_pcie_g3_x8",   //("non_pcie_g3_x8","pcie_g3_x8")
    parameter pll_feedback      = "non_pll_feedback", //("non_pll_feedback","pll_feedback")
    parameter reset_scheme      = "non_reset_bonding_scheme",  //("non_reset_bonding_scheme","reset_bonding_scheme")
    parameter pcie_rst          = "normal_reset",     // legal values: normal_reset, pcie_reset
    parameter in_cvp_mode       = "not_in_cvp_mode",  //legal values: not_in_cvp_mode, in_cvp_mode
    parameter enable_pma_direct_rx = "false",         // (true,false) Enable, disable the PMA Direct path
    parameter enable_pma_direct_tx = "false",          // (true,false) Enable, disable the PMA Direct path
    parameter hip_hard_reset    = "disable",          // legal values: enable, disable
    // parameters for hard offset cancellation 
    parameter cal_eye_pdb       = "EYE_MONITOR_OFF",   // eye monitor power down 
    parameter cal_dfe_pdb       = "DFE_MONITOR_OFF",   // dfe monitor power down
    parameter cal_offset_mode   = "MODE_INDEPENDENT",  // calibration mode
    parameter cal_set_timer     = "TIMER_FAST",
    parameter cal_limit_sa_cap  = "FULL_CAP",
    parameter cal_oneshot       = "ONESHOT_OFF", 
    parameter rx_dprio_sel      = "RX_DPRIO_SEL",      // source is either the DPRIO or the hard IP 
    parameter bbpd_dprio_sel    = "BBPD_DPRIO_SEL",
    parameter eye_dprio_sel     = "EYE_DPRIO_SEL",
    parameter dfe_dprio_sel     = "DFE_DPRIO_SEL",
    parameter offset_cal_pd_top = "OFFSET_ENABLE",     // enables or powers down the calibration controller
    parameter offset_att_en     = "ENABLE_12G_CAL",    // enables the 12G PMA or ATT calibration controller 
    parameter cal_status_sel    = "STATUS_REG1",       // configurable status register
    parameter cal_limit_bbpd_sa_cal = "ENABLE_4PHASE",  // reserved

    // CvP IOCSR control - cvp_update
    parameter cvp_en_iocsr      = "false" // valid values = "true", "false"

    //PARAM_LIST_END
) (
  //PORT_LIST_START
  // TX/RX ports
  input wire 				       calclk, // Calibration clock (to aux block)
  input wire [bonded_lanes - 1: 0] 	       seriallpbken, // 1 = enable serial loopback
  input wire [bonded_lanes*2-1: 0] 	       pciesw, // PCIe generation select
  input tri0 [bonded_lanes - 1: 0] 	       txpmasyncp, // Reset pulse from HIP hard reset controller through Gen3 PCS to reset counters in the CGB

  // RX ports
  input wire [bonded_lanes - 1 : 0] 	       rx_rstn, // Active low digital reset for (deserializer, CDR, RX buf)
  input wire [bonded_lanes - 1 : 0] 	       rx_crurstn, // CDR analog reset (active low)
  input wire [bonded_lanes - 1 : 0] 	       rx_datain, // RX serial data input
  input wire [bonded_lanes - 1 : 0] 	       rx_bslip, // PMA bitslip. Slips one clock cycle (2 UI of data)
  input wire [bonded_lanes*cdr_refclk_cnt-1:0] rx_cdr_ref_clk, // Reference clock for CDR
  input wire [bonded_lanes - 1 : 0] 	       rx_ltr, // Force lock-to_reference clock
  input wire [bonded_lanes - 1 : 0] 	       rx_ltd, // Force lock-to-data stream
  input wire [bonded_lanes - 1 : 0] 	       rx_freqlock, // frequency lock detector input (external PPM detector)
  input wire [bonded_lanes - 1 : 0] 	       rx_earlyeios, // Early electricle idle ordered sequence
  input wire [bonded_lanes - 1 : 0] 	       rx_adaptcapture,
  input wire [bonded_lanes - 1 : 0] 	       rx_adcestandby,
  input wire [bonded_lanes - 1 : 0] 	       rx_hardoccalen,
  input wire [bonded_lanes*5-1 : 0] 	       rx_eyemonitor,
  input wire [bonded_lanes - 1 : 0] 	       rxqpipulldn, // QPI input port
  output wire [bonded_lanes - 1 : 0] 	       rx_clkdivrx, // RX parallel clock output
  output wire [bonded_lanes*80-1: 0] 	       rx_dataout, // RX parallel data output
  output wire [bonded_lanes - 1 : 0] 	       rx_clk33pcs,
  output wire [bonded_lanes - 1 : 0] 	       rx_sd, // RX signal detect
  output wire [bonded_lanes - 1 : 0] 	       rx_clklow, // RX low frequency recovered clock
  output wire [bonded_lanes - 1 : 0] 	       rx_fref, // RX PFD reference clock (rx_cdr_refclk after divider)
  output wire [bonded_lanes - 1 : 0] 	       rx_is_lockedtodata, // Indicates lock to incoming data rate
  output wire [bonded_lanes - 1 : 0] 	       rx_is_lockedtoref, // Indicates lock to reference clock
  output wire [bonded_lanes - 1 : 0] 	       rx_adaptdone,
  output wire [bonded_lanes - 1 : 0] 	       rx_hardoccaldone,
  output wire [bonded_lanes - 1 : 0] 	       out_pcs_signal_ok,
  output wire [bonded_lanes - 1 : 0] 	       out_pcs_rx_pll_phase_lock_out,
  
  // TX ports
  //input port for buf
  input wire [bonded_lanes*80-1: 0] 	       tx_datain, // TX parallel data input
  input wire [bonded_lanes - 1 : 0] 	       tx_txelecidl, // TX force electricle idle
  input wire 				       tx_rxdetclk, // Clock for detection of downstream receiver (125MHz ?)
  input wire [bonded_lanes - 1 : 0] 	       tx_txdetrx, // 1 = enable downstream receiver detection
  input wire [bonded_lanes * 18 - 1 : 0]       icoeff, // coefficient port connection
  input wire [bonded_lanes - 1 : 0] 	       txqpipulldn, // QPI input port
  input wire [bonded_lanes - 1 : 0]            txqpipullup, // QPI input port

  //output port for buf
  output wire [bonded_lanes - 1 : 0] 	       tx_dataout, // TX serial data output
  output wire [bonded_lanes - 1 : 0] 	       tx_rxdetectvalid, // Indicates corresponding tx_rxfound signal contains valid data
  output wire [bonded_lanes - 1 : 0] 	       tx_rxfound, // Indicates downnstream receiver is detected (qualify with tx_rxdetectvalid)
  //input ports for ser
  input wire [bonded_lanes - 1 : 0] 	       tx_rstn, // TX CGB,SER reset
  input wire [bonded_lanes - 1 : 0]          pcs_rst_n, // reset to TX CGB from PCS 
  //output ports for ser
  output wire [bonded_lanes - 1 : 0] 	       tx_clkdivtx, // TX parallel clock output
  //input ports for cgb
  input wire [bonded_lanes*plls-1:0] 	       tx_ser_clk, // High-speed serial clock(s) from PLL
  //output ports for cgb
  output wire [(bonded_lanes*2)-1:0] 	       tx_pcieswdone, // Inidicates PMA has accepted value on pciesw input.
  output wire [bonded_lanes - 1 : 0] 	       tx_pcie_fb_clk, // PLL feedback clock for PCIe Gen3 x8
  output wire [bonded_lanes - 1 : 0] 	       tx_pll_fb_sw, // PLL feedback clock select

  // AVMM ports
  input wire [bonded_lanes-1:0 ] 	       pma_avmmrstn, // one for each lane
  input wire [bonded_lanes-1:0 ] 	       pma_avmmclk, // one for each lane
  input wire [bonded_lanes-1:0 ] 	       pma_avmmwrite, // one for each lane
  input wire [bonded_lanes-1:0 ] 	       pma_avmmread, // one for each lane
  input wire [(bonded_lanes*2)-1:0 ] 	       pma_avmmbyteen, // two for each lane
  input wire [(bonded_lanes*11)-1:0 ] 	       pma_avmmaddress, // 11 for each lane
  input wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmwritedata, // 16 for each lane

  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_tx_cgb, // TX AVMM CGB readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_tx_ser, // TX AVMM SER readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_tx_buf, // TX AVMM BUF readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_rx_ser, // RX AVMM SER readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_rx_buf, // RX AVMM BUF readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_rx_cdr, // RX AVMM CDR readdata (16 for each lane)
  output wire [(bonded_lanes*16)-1:0 ] 	       pma_avmmreaddata_rx_mux, // RX AVMM CDR MUX readdata (16 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_tx_cgb, // TX AVMM CGB blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_tx_ser, // TX AVMM SER blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_tx_buf, // TX AVMM BUF blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_rx_ser, // RX AVMM SER blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_rx_buf, // RX AVMM BUF blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_rx_cdr, // RX AVMM SER blockselect (1 for each lane)
  output wire [bonded_lanes-1:0 ] 	       pma_blockselect_rx_mux    // RX AVMM BUF blockselect (1 for each lane)
  //PORT_LIST_END
  );

import altera_xcvr_functions::*;  // Useful functions (primarily for rule-checking)

localparam  rbc_all_prot_mode = "(basic,cpri,cpri_rx_tx,disabled_prot_mode,gige,pipe_g1,pipe_g2,pipe_g3,srio_2p1,test,xaui)";
localparam  rbc_any_prot_mode = "basic";
localparam  fnl_prot_mode     = (pma_prot_mode == "<auto_any>" || pma_prot_mode == "<auto_single>") ? rbc_any_prot_mode : pma_prot_mode;

localparam  pipe_mode = (fnl_prot_mode == "pipe_g1" || fnl_prot_mode == "pipe_g2" || fnl_prot_mode == "pipe_g3") ? 1 : 0;
localparam  rbc_all_auto_negotiation  = (pipe_mode == 1) ? "(true,false)" : "false";
localparam  rbc_any_auto_negotiation  = "false";
localparam  fnl_auto_negotiation      = (auto_negotiation == "<auto_any>" || auto_negotiation == "<auto_single>") ? rbc_any_auto_negotiation : auto_negotiation;
        
// Internal parameters
localparam  INT_DATA_RATE             = str2hz(pma_data_rate);  // TODO - may fail due to 32-bit param
localparam  INT_CDR_OUT_CLOCK_FREQ    = INT_DATA_RATE / 2;
localparam  INT_CDR_OUT_CLOCK_FREQ_STR= hz2str(INT_CDR_OUT_CLOCK_FREQ);
// Set the Tx Buf Coeff Mux control
localparam  FIR_COEFF_CTRL_SEL = (pipe_mode == 1) ? "dynamic_ctl" : "ram_ctl";
 
// Parameter legality checking
initial begin
  if (!is_in_legal_set(pma_prot_mode, rbc_all_prot_mode)) begin
    $display("Critical Warning: pma_prot_mode value, '%s', not in legal set: '%s'", pma_prot_mode, rbc_all_prot_mode);
  end
  
  if (!is_in_legal_set(auto_negotiation, rbc_all_auto_negotiation)) begin
    $display("Critical Warning: auto_negotiation value, '%s', not in legal set: '%s'", auto_negotiation, rbc_all_auto_negotiation);
  end
end


// Internal signals
wire  [bonded_lanes - 1: 0] loopback_data;
wire  [bonded_lanes*2-1: 0] int_pciesw;     // PCIe generation select
wire  [bonded_lanes*2-1: 0] int_pcieswdone; // Inidicates PMA has accepted value on pciesw input.
wire                        int_calclk;

wire  [bonded_lanes - 1: 0] reverse_loopback_data_p;
wire  [bonded_lanes - 1: 0] reverse_loopback_data_n;
wire  [bonded_lanes - 1: 0] seriallpbken_n;

wire  [bonded_lanes - 1: 0] int_tx_rxdetclk;
wire  [bonded_lanes*11-1:0] int_refiqclk;
wire  [bonded_lanes*11-1:0] w_refiqclk;
wire  [bonded_lanes - 1: 0] refclk_to_rxdet;  

assign  int_pciesw    = (fnl_auto_negotiation == "true") ? pciesw : {bonded_lanes{2'b00}};
assign  tx_pcieswdone = (fnl_auto_negotiation == "true" || tx_enable == 0) ? int_pcieswdone : {bonded_lanes*2{1'b0}};

assign  out_pcs_signal_ok             = rx_is_lockedtodata;
assign  out_pcs_rx_pll_phase_lock_out = rx_is_lockedtodata;
// We only drive seriallpbken in duplex mode.
assign  seriallpbken_n = ((rx_enable == 1) && (tx_enable == 1)) ? ~seriallpbken : {bonded_lanes{1'b1}};

// Use CDR refclk for AUX clock in CVP mode. Use calclk from core otherwise.
// Constuct internal refiqclk wire that is bonded_lanes * 11 wide from the bonded_lanes wide refclk input for PCIe CVP
// Connect the refclk for each channel to refiqclk[0] and set the mux selector for this input
genvar i;
generate 
 for(i = 0; i < bonded_lanes; i = i + 1) 
 begin:aux_refiqclks
   assign w_refiqclk [i * 11+: 11] = { {(10){1'b0}} , rx_cdr_ref_clk[i]};
 end
endgenerate

// Use tx_rxdetclk from core/refclk for PIPE. Use calibration block clock input otherwise
// When hard reset controller is used, connect the output of cdr_refclk_select_mux to the rxdetclk of tx_buf otherwise connect tx_rxdetclk from core
genvar j; 
generate 
  for(j = 0; j < bonded_lanes; j = j + 1) 
  begin:rxdet_fixedclk
   assign  int_tx_rxdetclk[j] = (pipe_mode == 1) ? (hip_hard_reset == "enable") ? refclk_to_rxdet[j] : tx_rxdetclk : calclk;
  end
endgenerate

// Route the refclk to refiqclk of Aux block pnly in CVP mode. Tie it off in other modes.
assign int_refiqclk = (in_cvp_mode == "in_cvp_mode") ? w_refiqclk : { {bonded_lanes*11} {1'b0} };
// Set the AUX block mux selector to select refiqclk[0] in CVP mode. Select calclk input otherwise
localparam CAL_CLK_SEL = (in_cvp_mode == "in_cvp_mode") ? "pm_aux_iqclk_cal_clk_sel_iqclk0" : "pm_aux_iqclk_cal_clk_sel_cal_clk";
// Tie-off the calclk connection from the core in CVP mode 
assign int_calclk = (in_cvp_mode == "in_cvp_mode") ? 1'b0 : calclk;


//*********************************************************************
//************************ Receiver PMA *******************************
generate if(rx_enable == 1) begin:rx_pma
sv_rx_pma #(
      .bonded_lanes                 (bonded_lanes                 ),
      .bonding_master_ch_num        (pma_bonding_master           ),
      .bonding_master_only          (bonding_master_only          ),
      .reserved_ch                  (pma_reserved_ch              ),
      .pipe_mode                    (pipe_mode                    ),
      .mode                         (pma_mode                     ),
      .serial_loopback              ("lpbkp_dis"                  ),
      .sdclk_enable                 ("true"                       ),  // TODO Hard-code for now
      .deser_enable_bit_slip        (deser_enable_bit_slip        ),
      .auto_negotiation             (fnl_auto_negotiation         ),
      .cdr_reference_clock_frequency(cdr_reference_clock_frequency),
      .cdr_refclk_cnt               (cdr_refclk_cnt               ),
      .cdr_refclk_sel               (cdr_refclk_sel               ),
      .cdr_reconfig                 (cdr_reconfig                 ),
      .cdr_output_clock_frequency   (INT_CDR_OUT_CLOCK_FREQ_STR   ),
      .rxpll_pd_bw_ctrl             (300                          ),  // TODO Hard-code for now
      .sd_on                        (sd_on                        ),
      .cal_clk_sel                  (CAL_CLK_SEL                  ),
      .pma_direct                   (enable_pma_direct_rx         ),
      .cal_eye_pdb                  (cal_eye_pdb                  ),
      .cal_dfe_pdb                  (cal_dfe_pdb                  ),
      .cal_offset_mode              (cal_offset_mode              ),
      .cal_set_timer                (cal_set_timer                ),
      .cal_limit_sa_cap             (cal_limit_sa_cap             ),
      .cal_oneshot                  (cal_oneshot                  ),
      .rx_dprio_sel                 (rx_dprio_sel                 ),
      .bbpd_dprio_sel               (bbpd_dprio_sel               ),
      .eye_dprio_sel                (eye_dprio_sel                ),
      .dfe_dprio_sel                (dfe_dprio_sel                ),
      .offset_cal_pd_top            (offset_cal_pd_top            ),
      .offset_att_en                (offset_att_en                ),
      .cal_status_sel               (cal_status_sel               ),
      .cal_limit_bbpd_sa_cal        (cal_limit_bbpd_sa_cal        ),
      .cvp_en_iocsr                 (cvp_en_iocsr                 )
) sv_rx_pma_inst ( 
  .rstn               (rx_rstn                ),
  .crurstn            (rx_crurstn             ),
  
  .calclk             ({bonded_lanes{int_calclk}} ),
  .refiqclk           (int_refiqclk           ),
  .datain             (rx_datain              ),
  .seriallpbkin       (loopback_data          ),
  .seriallpbken       (seriallpbken_n         ),
  .bslip              (rx_bslip               ),
  .adaptcapture       (rx_adaptcapture        ),
  .adcestandby        (rx_adcestandby         ),
  .hardoccalen        (rx_hardoccalen         ),
  .eyemonitor         (rx_eyemonitor          ),
  .rxqpipulldn        (rxqpipulldn            ),  // QPI input port
  .adaptdone          (rx_adaptdone           ),
  .hardoccaldone      (rx_hardoccaldone       ),
  
  .cdr_ref_clk        (rx_cdr_ref_clk         ),
  
  .pciesw             (int_pciesw             ),
  
  .ltr                (rx_ltr                 ),
  .ltd                (rx_ltd                 ),
  .freqlock           (rx_freqlock            ),
  
  .earlyeios          (rx_earlyeios           ),
  
  .clkdivrx           (rx_clkdivrx            ),
  .dout               (rx_dataout             ),
  .clk33pcs           (rx_clk33pcs            ),
  .sd                 (rx_sd                  ),
  
  .clklow             (rx_clklow              ),
  .fref               (rx_fref                ),
  
  .rx_is_lockedtodata (rx_is_lockedtodata     ),
  .rx_is_lockedtoref  (rx_is_lockedtoref      ),

  .avmmrstn           (pma_avmmrstn           ),
  .avmmclk            (pma_avmmclk            ),
  .avmmwrite          (pma_avmmwrite          ),
  .avmmread           (pma_avmmread           ),
  .avmmbyteen         (pma_avmmbyteen         ),
  .avmmaddress        (pma_avmmaddress        ),
  .avmmwritedata      (pma_avmmwritedata      ),
  .avmmreaddata_ser   (pma_avmmreaddata_rx_ser), // SER readdata
  .avmmreaddata_buf   (pma_avmmreaddata_rx_buf), // BUF readdata
  .avmmreaddata_cdr   (pma_avmmreaddata_rx_cdr), // CDR readdata
  .avmmreaddata_mux   (pma_avmmreaddata_rx_mux), // CDR MUX readdata
  .blockselect_ser    (pma_blockselect_rx_ser ), // SER blockselect
  .blockselect_buf    (pma_blockselect_rx_buf ), // BUF blockselect
  .blockselect_cdr    (pma_blockselect_rx_cdr ), // CDR blockselect
  .blockselect_mux    (pma_blockselect_rx_mux ), // CDR MUX blockselect
  
  .rdlpbkp            (reverse_loopback_data_p),
  .rdlpbkn            (reverse_loopback_data_n),
  .refclk_to_cdr      (refclk_to_rxdet        )  // output of cdr_refclk_select_muxes

);
end else begin:no_rx_pma
  // Default unused outputs
  assign  rx_clkdivrx                   = {bonded_lanes{1'b0}};
  assign  rx_dataout                    = {bonded_lanes*80{1'b0}};
  assign  rx_sd                         = {bonded_lanes{1'b0}};
  assign  rx_clklow                     = {bonded_lanes{1'b0}};
  assign  rx_fref                       = {bonded_lanes{1'b0}};
  assign  rx_is_lockedtodata            = {bonded_lanes{1'b0}};
  assign  rx_is_lockedtoref             = {bonded_lanes{1'b0}};
  assign  rx_adaptdone                  = {bonded_lanes{1'b0}};
  assign  rx_hardoccaldone              = {bonded_lanes{1'b0}};
  assign  pma_avmmreaddata_rx_ser       = {bonded_lanes*16{1'b0}};
  assign  pma_avmmreaddata_rx_buf       = {bonded_lanes*16{1'b0}};
  assign  pma_avmmreaddata_rx_cdr       = {bonded_lanes*16{1'b0}};
  assign  pma_avmmreaddata_rx_mux       = {bonded_lanes*16{1'b0}};
  assign  pma_blockselect_rx_ser        = {bonded_lanes{1'b0}};
  assign  pma_blockselect_rx_buf        = {bonded_lanes{1'b0}};
  assign  pma_blockselect_rx_cdr        = {bonded_lanes{1'b0}};
  assign  pma_blockselect_rx_mux        = {bonded_lanes{1'b0}};
  assign  rx_clk33pcs                   = {bonded_lanes{1'b0}};
  assign  reverse_loopback_data_p       = {bonded_lanes{1'b0}};
  assign  reverse_loopback_data_n       = {bonded_lanes{1'b0}};
end
endgenerate
//********************** End Receiver PMA *****************************
//*********************************************************************


//*********************************************************************
//********************** Transmitter PMA ******************************
generate if(tx_enable == 1) begin:tx_pma
sv_tx_pma #(
      .bonded_lanes           (bonded_lanes           ),
      .bonding_master_ch_num  (pma_bonding_master     ),
      .bonding_master_only    (bonding_master_only    ),
      .data_rate              (pma_data_rate          ), // TODO
      .pipe_mode              (pipe_mode              ),
      .mode                   (pma_mode               ),
      .plls                   (plls                   ),
      .pll_sel                (pll_sel                ),
      .ser_loopback           ("false"                ),
      .auto_negotiation       (fnl_auto_negotiation   ),
      .ht_delay_sel           ("false"                ),
      .rx_det_pdb             ("false"                ),
      .tx_clk_div             (tx_clk_div             ),
      .cgb_sync               (cgb_sync               ),
      .pcie_g3_x8             (pcie_g3_x8             ),
      .pll_feedback           (pll_feedback           ),
      .reset_scheme           (reset_scheme           ),
      .pcie_rst               (pcie_rst               ),
      .pma_bonding_type	      (pma_bonding_type	      ),
      .cal_clk_sel            (CAL_CLK_SEL            ),
      .fir_coeff_ctrl_sel     (FIR_COEFF_CTRL_SEL     ),
      .pma_direct             (enable_pma_direct_tx   )
  ) sv_tx_pma_inst( 
  //input port for aux
  .calclk             ({bonded_lanes{int_calclk}} ),
  .refiqclk           (int_refiqclk           ),
  //input port for buf
  .datain             (tx_datain              ),
  .txelecidl          (tx_txelecidl           ),
  .rxdetclk           (int_tx_rxdetclk        ),
  .txdetrx            (tx_txdetrx             ),
  .icoeff             (icoeff                 ),
  .txqpipulldn        (txqpipulldn            ),  // QPI input port
  .txqpipullup        (txqpipullup            ),  // QPI input port 
   
  //output port for buf
  .dataout            (tx_dataout             ),
  .rxdetectvalid      (tx_rxdetectvalid       ),
  .rxfound            (tx_rxfound             ),
  
  //input ports for ser
  .rstn               (tx_rstn                ),
  .pcs_rst_n          (pcs_rst_n              ),
  .seriallpbken       (seriallpbken_n         ),
  
  //output ports for ser
  .clkdivtx           (tx_clkdivtx            ),  
  .seriallpbkout      (loopback_data          ),

  //input ports for cgb
  .clk                (tx_ser_clk             ),
  .pciesw             (int_pciesw[bonding_master_ch*2 +: 2]),
  .txpmasyncp         (txpmasyncp             ),
  .pcie_fb_clk        (tx_pcie_fb_clk         ),
  .pll_fb_sw          (tx_pll_fb_sw           ),  

  //output ports for cgb
  .pcieswdone         (int_pcieswdone         ),

  .avmmrstn           (pma_avmmrstn           ),
  .avmmclk            (pma_avmmclk            ),
  .avmmwrite          (pma_avmmwrite          ),
  .avmmread           (pma_avmmread           ),
  .avmmbyteen         (pma_avmmbyteen         ),
  .avmmaddress        (pma_avmmaddress        ),
  .avmmwritedata      (pma_avmmwritedata      ),
  .avmmreaddata_cgb   (pma_avmmreaddata_tx_cgb),  // CGB readdata
  .avmmreaddata_ser   (pma_avmmreaddata_tx_ser),  // SER readdata
  .avmmreaddata_buf   (pma_avmmreaddata_tx_buf),  // BUF readdata
  .blockselect_cgb    (pma_blockselect_tx_cgb ),  // CGB blockselect
  .blockselect_ser    (pma_blockselect_tx_ser ),  // SER blockselect
  .blockselect_buf    (pma_blockselect_tx_buf ),   // BUF blockselect

  .vrlpbkp            (reverse_loopback_data_p),
  .vrlpbkn            (reverse_loopback_data_n)
);
end else begin:no_tx_pma
  // Default the outputs
  assign  tx_dataout              = {bonded_lanes{1'b0}};
  assign  tx_rxdetectvalid        = {bonded_lanes{1'b0}};
  assign  tx_rxfound              = {bonded_lanes{1'b0}};
  assign  tx_clkdivtx             = {bonded_lanes{1'b0}};
  assign  int_pcieswdone          = {bonded_lanes*2{1'b0}};
  assign  pma_avmmreaddata_tx_cgb = {bonded_lanes*16{1'b0}};
  assign  pma_avmmreaddata_tx_ser = {bonded_lanes*16{1'b0}};
  assign  pma_avmmreaddata_tx_buf = {bonded_lanes*16{1'b0}};
  assign  pma_blockselect_tx_cgb  = {bonded_lanes{1'b0}};
  assign  pma_blockselect_tx_ser  = {bonded_lanes{1'b0}};
  assign  pma_blockselect_tx_buf  = {bonded_lanes{1'b0}};
  assign  tx_pcie_fb_clk          = {bonded_lanes{1'b0}};
  assign  tx_pll_fb_sw            = {bonded_lanes{1'b0}};
  assign  loopback_data           = {bonded_lanes{1'b0}};
end
endgenerate
//******************** End Transmitter PMA ****************************
//*********************************************************************

endmodule
