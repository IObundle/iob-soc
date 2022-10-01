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


//
// Creates one or more TX plls
// 
// Clock switching must use the exported reconfiguration ports
//
// $Header$
//

`timescale 1 ns / 1 ns

import altera_xcvr_functions::*;

//`define USE_DPRIO_LC_MODEL
//`define USE_ICD_LC_MODEL
module sv_xcvr_plls #(
  parameter plls                                  = 1,        // number of PLLs
  parameter pll_type                              = "AUTO",   // "AUTO","CMU","ATX","fPLL" (List i.e. "CMU,ATX,CMU,...")
  parameter pll_reconfig                          = 0,        // 0-PLL reconfig not enabled. 1-PLL reconfig enabled
  parameter pll_network_select                    = "x1",     // selected PLL clock network ("x1","xN"). (List i.e. "x1,xN,x1,...") One per PLL. Required only for "xN" non-bonded
  parameter pll_external                          = 0,        // 0-Instantiate PLLs inside this module, 1-PLLs are instantiated outside this module; pass refclk to output or 
  parameter refclks                               = 1,        // number of refclks per PLL
  parameter reference_clock_frequency             = "0 ps",   // refclk frequencies (List i.e. "100 MHz,150 MHz,156.25 MHz,...")
  parameter reference_clock_select                = "0",      // refclk_sel per pll (List i.e. "0,3,1,2,...")
  parameter output_clock_datarate                 = "0 Mbps", // outclk data rate (frequency*2)(List i.e. "5000 Mbps,2.5 Gbps,...") Not used if left at "0 Mbps"
  parameter output_clock_frequency                = "0 ps",   // outclk frequency (List i.e. "5000 MHz, 1000 MHz,..."), Only used if output_clock_datarate unused.
  parameter feedback_clk                          = "internal",// feedback clock select per pll (List i.e. "internal,external,external,...")
  // Unused parameters
  parameter sim_additional_refclk_cycles_to_lock  = 0,        // 
  parameter duty_cycle                            = 50,       // duty cycle (List i.e. "50,40,55,...")
  parameter phase_shift                           = "0 ps",   // phase shift (List i.e. "0 ps, 180 ps, ...")
  // Config options
  parameter enable_hclk                           = "0",      // "1", "0", "1,0"  
  parameter enable_avmm                           = 1,        // 1 = Include AVMM blocks
  parameter use_generic_pll                       = 0,        // 1 = Use generic PLL atoms, 0 = Use LC/CDR/FPLL atoms
  parameter att_mode                              = 0,        // 1 = Use LC PLL 14G buffer output, 0 = Use 8G
  parameter enable_mux                            = 1         // 1 = Enable refclk mux, 0 = Disable
) (
  input   wire  [((pll_external) ? plls : refclks)-1:0] refclk,     // Overloaded. if(pll_external==1) inputs clocks from external PLLs
                                                                    // if(pll_external==0) reference clock inputs to internal PLLs
  input   wire  [plls   -1:0] rst,
  input   wire  [plls   -1:0] fbclk,

  input   wire  [plls   -1:0] pll_fb_sw,  //PLL feedback switch
  
  output  wire  [plls   -1:0] outclk,
  output  wire  [plls   -1:0] locked,
  output  wire  [plls   -1:0] fboutclk,
  output  wire  [plls   -1:0] hclk,


  //
  input   wire  [plls*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1 :0] reconfig_to_xcvr,
  output  wire  [plls*W_S5_RECONFIG_BUNDLE_FROM_XCVR-1 :0] reconfig_from_xcvr
);

// Macro definition to connect or disconnect ATX PLL reset input
`ifndef ALTERA_RESERVED_QIS_ES
  `define ALTERA_RESERVED_XCVR_SV_ATX_PLL_RESET_CONNECT
`endif


localparam  w_bundle_to_xcvr  = W_S5_RECONFIG_BUNDLE_TO_XCVR;
localparam  w_bundle_from_xcvr= W_S5_RECONFIG_BUNDLE_FROM_XCVR;

localparam  [plls*2-1:0]  pll_type_sel_bin    = pll_type_str2bin(pll_type);
localparam  [plls  -1:0]  pll_network_sel_bin = pll_network_str2bin(pll_network_select);


// Set "enabled_for_reconfig" from pll_reconfig parameter
localparam  enabled_for_reconfig  = (pll_reconfig == 0) ? "false" : "true";
// Use fast simulation models when reconfig is not enabled
localparam  sim_use_fast_model    = (enabled_for_reconfig == "false") ? "true" : "false";

genvar ig;      // Iterator for generated loops
genvar jg;
generate
  for(ig=0; ig<plls; ig = ig + 1) begin: pll
    // Determine initial reference clock frequency
    localparam  [MAX_CHARS*8-1:0] refclk_sel_sel  = get_value_at_index(ig,reference_clock_select);
    localparam  [MAX_CHARS*8-1:0] refclk_sel_fnl  = str2int(refclk_sel_sel); 
    localparam  [MAX_CHARS*8-1:0] refclk_freq_fnl = get_value_at_index(refclk_sel_fnl,reference_clock_frequency);
    // Determine initial output clock frequency
    localparam  [MAX_CHARS*8-1:0] outclk_rate_sel = get_value_at_index(ig,output_clock_datarate);
    localparam  [MAX_CHARS*8-1:0] outclk_freq_sel = get_value_at_index(ig,output_clock_frequency);
    localparam  [MAX_CHARS*8-1:0] outclk_freq_fnl = (outclk_rate_sel == "NA" || outclk_rate_sel == "0 Mbps") ? outclk_freq_sel :
                                                      hz2str(str2hz(outclk_rate_sel) / 2);
    // Determine PLL type
    localparam  [1:0] pll_type_sel  = ((pll_type_sel_bin >> (2*ig)) & 2'b11);
    localparam  [MAX_CHARS*8-1:0] pll_type_sdc  = (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_LC  ) ? "-name PLL_TYPE ATX"  : 
                                                  (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_FPLL) ? "-name PLL_TYPE fPLL" :
                                                  (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_CMU ) ? "-name PLL_TYPE CMU"  :
                                                   "";
    localparam  use_cmu_pll = ((use_generic_pll == 0) && (pll_external == 0) && (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_CMU))  ? 1 : 0;
    localparam  use_atx_pll = ((use_generic_pll == 0) && (pll_external == 0) && (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_LC ))  ? 1 : 0;
    localparam  use_fpll    = ((use_generic_pll == 0) && (pll_external == 0) && (pll_type_sel == sv_xcvr_h::SV_XR_ID_PLL_TYPE_FPLL)) ? 1 : 0;

    localparam  use_avmm    = ((enable_avmm == 1) && (pll_external == 0)) ? 1 : 0;
    // PLL type parameter for CSR
    localparam  csr_pll_type =  pll_type_sel;

    localparam  [MAX_CHARS*8-1:0] feedback_clk_val  = get_value_at_index(ig,feedback_clk);
    localparam  [MAX_CHARS*8-1:0] feedback_clk_sel  = (feedback_clk_val == "NA") ? get_value_at_index(0,feedback_clk) : feedback_clk_val;

    localparam  [0:0] is_xN = ((pll_network_sel_bin >> ig) & 1'b1);

    // Local AVMM signals (AVMM atom <-> PLL atoms)
    wire          local_avmm_rstn;
    wire          local_avmm_clk;
    wire  [15:0]  local_avmm_writedata;
    wire  [10:0]  local_avmm_address;
    wire  [ 1:0]  local_avmm_byteen;
    wire          local_avmm_write;
    wire          local_avmm_read;
    wire          cdr_mux_avmm_blockselect;
    wire  [15:0]  cdr_mux_avmm_readdata;
    wire          cdr_avmm_blockselect;
    wire  [15:0]  cdr_avmm_readdata;
    wire          atx_avmm_blockselect;
    wire  [15:0]  atx_avmm_readdata;
    wire          atx_mux_avmm_blockselect;
    wire  [15:0]  atx_mux_avmm_readdata;

    // Select feedback clock
    wire    fbclk_in;
    assign  fbclk_in = (feedback_clk_sel == "external") ? fbclk[ig] : fboutclk[ig];

    // Output clock from PLL (may got to output or through CGB for xN topologies)
    wire    pll_outclk;

    if(use_avmm == 1) begin:avmm
      // avalon MM native reconfiguration interfaces
      wire          pld_avmm_reset;     // one for each lane
      wire          pld_avmm_clk;       // one for each lane
      wire  [15:0]  pld_avmm_writedata; // Avalon DPRIO writedata
      wire  [11:0]  pld_avmm_address;   // Avalon DPRIO address
      wire          pld_avmm_write;     // Avalon DPRIO write
      wire          pld_avmm_read;      // Avalon DPRIO read
      wire  [15:0]  pld_avmm_readdata;  // Avalon DPRIO readdata

      // CSR/DPRIO selection signals
      wire          csr_avmm_n_sel;     // Select Soft CSR or DPRIO
      reg           csr_avmm_n_sel_r;   // Select Soft CSR or DPRIO (read)
      // Soft CSR Avalon signals
      wire          csr_write;          // Avalon write to Soft CSR
      wire          csr_read;           // Avalon read to Soft CSR
      wire  [15:0]  csr_readdata;       // Avalon readdata from Soft CSR
      // DPRIO Avalon signals
      wire          avmm_write;         // Avalon write to DPRIO
      wire          avmm_read;          // Avalon read to DPRIO
      wire  [15:0]  avmm_readdata;      // Avalon readdata from DPRIO
      
      wire  [11:0]  pmatestbussel;
      wire  [23:0]  pmatestbus;
      
      wire          interface_sel;
      wire          ser_shift_load;

      wire  [90-1:0]    chnl_avmm_blockselect;
      wire  [15:0]      chnl_avmm_readdata [0:(90-1)];
      wire  [90*16-1:0] chnl_avmm_readdatabus;

      for(jg = 0; jg < 90; jg = jg + 1) begin:avmm_assigns
        assign  chnl_avmm_readdatabus[jg*16+:16] = chnl_avmm_readdata[jg];
        assign  {chnl_avmm_readdata[jg],chnl_avmm_blockselect[jg]} = 
          // TX PMA connections
          (jg ==  5) ? {cdr_avmm_readdata,cdr_avmm_blockselect} :
          (jg ==  6) ? {cdr_mux_avmm_readdata,cdr_mux_avmm_blockselect} :
          (jg == 83) ? {atx_avmm_readdata,atx_avmm_blockselect} :
          (jg == 87) ? {atx_mux_avmm_readdata,atx_mux_avmm_blockselect} :
          {16'd0,1'b0};
      end
                       
      // Mux between hard and soft reconfig registers
      assign  csr_avmm_n_sel    = pld_avmm_address[11];
      assign  pld_avmm_readdata = csr_avmm_n_sel_r ? csr_readdata : avmm_readdata;
      assign  avmm_write        = pld_avmm_write & ~csr_avmm_n_sel;
      assign  avmm_read         = pld_avmm_read  & ~csr_avmm_n_sel;
      assign  csr_write         = pld_avmm_write & csr_avmm_n_sel;
      assign  csr_read          = pld_avmm_read  & csr_avmm_n_sel;

      always @(posedge pld_avmm_clk or posedge pld_avmm_reset)
        if(pld_avmm_reset)  csr_avmm_n_sel_r  <= 1'b0;
        else                csr_avmm_n_sel_r  <= csr_avmm_n_sel;

      // Extract and compose bundled signals
      sv_reconfig_bundle_to_xcvr #(
        .native_ifs         (1                  )   // number of native reconfig interfaces
      ) sv_reconfig_bundle_to_xcvr_inst(
        // bundled reconfig buses
        .reconfig_to_xcvr         (reconfig_to_xcvr  [ig*w_bundle_to_xcvr  +:w_bundle_to_xcvr   ] ),
        .reconfig_from_xcvr       (reconfig_from_xcvr[ig*w_bundle_from_xcvr+:w_bundle_from_xcvr ] ),
        // native reconfig sources
        .native_reconfig_clk      (pld_avmm_clk       ),
        .native_reconfig_reset    (pld_avmm_reset     ),
        .native_reconfig_writedata(pld_avmm_writedata ),
        .native_reconfig_address  (pld_avmm_address   ),
        .native_reconfig_write    (pld_avmm_write     ),
        .native_reconfig_read     (pld_avmm_read      ),
        // native reconfig sinks
        .native_reconfig_readdata (pld_avmm_readdata  ),  // Avalon DPRIO readdata

        // calibration connections
        .tx_cal_busy              (/*unused*/     ),
        .rx_cal_busy              (/*unused*/     ), 

        .pif_testbus              (pmatestbus     ),
        .pif_testbus_sel          (pmatestbussel  ),

        .pif_interface_sel        (interface_sel  ),
        .pif_ser_shift_load       (ser_shift_load )
      );

      // Instantiate AVMM_INTERFACE
      stratixv_hssi_avmm_interface stratixv_hssi_avmm_interface_inst (
        .avmmrstn           (1'b1                   ),
        .avmmclk            (pld_avmm_clk           ),
        .avmmwrite          (avmm_write             ),
        .avmmread           (avmm_read              ),
        .avmmbyteen         (2'b11                  ),
        .avmmaddress        (pld_avmm_address[10:0] ),
        .avmmwritedata      (pld_avmm_writedata     ),
        .avmmreaddata       (avmm_readdata          ),

        .blockselect        (chnl_avmm_blockselect  ),
        .readdatachnl       (chnl_avmm_readdatabus  ),
        .clkchnl            (local_avmm_clk         ),
        .rstnchnl           (local_avmm_rstn        ),
        .writedatachnl      (local_avmm_writedata   ),
        .regaddrchnl        (local_avmm_address     ),
        .writechnl          (local_avmm_write       ),
        .readchnl           (local_avmm_read        ),
        .byteenchnl         (local_avmm_byteen      ),
  
        // The following ports belong to pm_tst_mux blocks in the PMA
        .pmatestbus         (pmatestbus             ),
        .pmatestbussel      (pmatestbussel          ),

        //
        .scanmoden          (1'b1                   ),
        .scanshiftn         (1'b1                   ),
        .sershiftload       (ser_shift_load         ),
        .interfacesel       (interface_sel          ),

        .refclkdig          (/*unused*/ ),
        .avmmreservedin     (/*unused*/ ),

        .avmmreservedout    (/*unused*/ ),
        .dpriorstntop       (/*unused*/ ),
        .dprioclktop        (/*unused*/ ),
        .mdiodistopchnl     (/*unused*/ ),
        .dpriorstnmid       (/*unused*/ ),
        .dprioclkmid        (/*unused*/ ),
        .mdiodismidchnl     (/*unused*/ ),
        .dpriorstnbot       (/*unused*/ ),
        .dprioclkbot        (/*unused*/ ),
        .mdiodisbotchnl     (/*unused*/ ),
        .dpriotestsitopchnl (/*unused*/ ),
        .dpriotestsimidchnl (/*unused*/ ),
        .dpriotestsibotchnl (/*unused*/ )

      ); 

      // Soft reconfig CSR
      sv_xcvr_avmm_csr #(
          .pll_type   (csr_pll_type), // 0-None,1-CMU,2-LC/ATX,3-fPLL
          .rx_enable  (0  ),  // Indicates whether this interface contains an rx channel.
          .tx_enable  (0  ),  // Indicates whether this interface contains a tx channel
          .att_enable (0  ),  // Indicates whether this interface is an ATT channel
          // Service request parameters
          .request_adce_cont  (0),  // Request ADCE continuous mode at startup
          .request_adce_single(0),  // Request ADCE one-time mode at startup
          .request_dcd        (0),  // Request Duty Cycle Distortion correction at startup
          .request_dfe        (0),  // Request DFE at startup
          .request_vrc        (0)   // Request Voltage Regulator Calibration at startup
        ) sv_xcvr_avmm_csr_inst (
          // Avalon interface
          .av_clk               (pld_avmm_clk         ),
          .av_reset             (pld_avmm_reset       ),
          .av_writedata         (pld_avmm_writedata   ),
          .av_address           (pld_avmm_address[3:0]),
          .av_write             (csr_write            ),
          .av_read              (csr_read             ),
          .av_readdata          (csr_readdata         ),
          
          // Reset overrides (used only in channel)
          .tx_rst_ovr           (/*unused*/ ),  
          .tx_digital_rst_n_val (/*unused*/ ),
          .rx_rst_ovr           (/*unused*/ ),
          .rx_digital_rst_n_val (/*unused*/ ),
          .rx_analog_rst_n_val  (/*unused*/ ),

          // ADCE
          .adce_done            (/*unused*/ ),
          .adce_capture         (/*unused*/ ),
          .adce_standby         (/*unused*/ ),
          // Offset Cancellation
          .hardoccaldone        (/*unused*/ ),
          .hardoccalen          (/*unused*/ ),
          // PRBS
          .pcs_8g_prbs_done     (/*unused*/),
          .pcs_8g_prbs_err      (/*unused*/),
          .pcs_10g_prbs_done    (/*unused*/),
          .pcs_10g_prbs_err     (/*unused*/),
          .pcs_10g_prbs_err_clr (/*unused*/),
          // DCD
          .dcd_ack              (/*unused*/ ),
          .dcd_sum_a            (/*unused*/ ),
          .dcd_sum_b            (/*unused*/ ),
          .dcd_req              (/*unused*/ ),
          // SLPBK
          .seriallpbken         (/*unused*/ ),
          // Channel STATUS
          .stat_pll_locked      (locked [ig]),
          .stat_tx_digital_reset(/*unused*/ ),
          .stat_rx_digital_reset(/*unused*/ ),
          // EYEMON
          .eyemonitor           (/*unused*/ ),
          
          .rx_ltd_val           (/*unused*/ ),
          .rx_ltr_val           (/*unused*/ ),
          .rx_ltrltd_ovr        (/*unused*/ )
      );
    end else begin:no_avmm
      assign  reconfig_from_xcvr= {(plls*w_bundle_from_xcvr){1'b0}};
      assign  local_avmm_rstn       = 1'b1;
      assign  local_avmm_clk        = 1'b0;
      assign  local_avmm_writedata  = 16'd0;
      assign  local_avmm_address    = 11'd0;
      assign  local_avmm_byteen     = 2'b00;
      assign  local_avmm_write      = 1'b0;
      assign  local_avmm_read       = 1'b0;
    end // no_avmm

    // PLL
    if(pll_external == 1) begin:external_pll
      // Pass refclk (PLL output clock from external PLL when "external_pll" == 1) to output (or CGB)
      assign  pll_outclk    = refclk[ig];
      assign  locked  [ig]  = 1'b0;
      assign  fboutclk[ig]  = 1'b0;
      assign  hclk    [ig]  = 1'b0;
    end else if(use_generic_pll == 1) begin:generic_pll
      // No hclk with generic_pll 
      assign  hclk[ig]  = 1'b0;

      // Create generic TX pll. Set type using attribute
      (* altera_attribute = pll_type_sdc *)
      generic_pll #(  
          .reference_clock_frequency(refclk_freq_fnl),
          .output_clock_frequency   (outclk_freq_fnl)
      ) tx_pll (
        .fbclk              (fbclk_in       ),
        .fboutclk           (fboutclk [ig]  ),
        .refclk             (refclk   [refclk_sel_fnl]  ),
        .rst                (rst      [ig]  ),
        .outclk             (pll_outclk     ),
        .locked             (locked   [ig]  )
    
        `ifndef ALTERA_RESERVED_QIS
        ,
        // Inputs from Generic PLL Adapter
        .writerefclkdata    (/*unused*/     ),
        .writeoutclkdata    (/*unused*/     ),
        .writephaseshiftdata(/*unused*/     ),
        .writedutycycledata (/*unused*/     ),
        // Outputs to Generic PLL Adapter
        .readrefclkdata     (/*unused*/     ),
        .readoutclkdata     (/*unused*/     ),
        .readphaseshiftdata (/*unused*/     ),
        .readdutycycledata  (/*unused*/     )
        `endif // ifndef ALTERA_RESERVED_QIS
      );

      // Terminate unused avmm signals
      assign  cdr_avmm_readdata     = 16'd0;
      assign  atx_avmm_readdata     = 16'd0;
      assign  cdr_mux_avmm_readdata = 16'd0;
      assign  cdr_avmm_blockselect  = 1'b0;
      assign  atx_avmm_blockselect  = 1'b0;
      assign  atx_mux_avmm_readdata = 16'd0;
      assign  cdr_mux_avmm_blockselect  = &{1'b0,local_avmm_rstn,local_avmm_clk,local_avmm_writedata,local_avmm_address,
                                             local_avmm_write,local_avmm_read,local_avmm_byteen,cdr_avmm_readdata,
                                             cdr_avmm_blockselect,atx_avmm_readdata,atx_avmm_blockselect,
                                             atx_mux_avmm_readdata,atx_mux_avmm_blockselect,
                                             cdr_mux_avmm_readdata,cdr_mux_avmm_blockselect};  // Warning avoidance
      assign  atx_mux_avmm_blockselect  = &{1'b0,local_avmm_rstn,local_avmm_clk,local_avmm_writedata,local_avmm_address,
                                             local_avmm_write,local_avmm_read,local_avmm_byteen,cdr_avmm_readdata,
                                             cdr_avmm_blockselect,atx_avmm_readdata,atx_avmm_blockselect,
                                             atx_mux_avmm_readdata,atx_mux_avmm_blockselect,
                                             cdr_mux_avmm_readdata,cdr_mux_avmm_blockselect};  // Warning avoidance

    end else begin:pll
      // Connect feedback clock only in "external" feedback mode
      assign  fboutclk[ig]  = 1'b0;

      // CMU PLL
      if(use_cmu_pll) begin:cmu_pll
        // Determine feedback clock selection
        localparam  [MAX_CHARS*8-1:0] feedback_clk_fnl  = (feedback_clk_sel == "external") ? "extclk" : "vcoclk";
        localparam  [MAX_CHARS*8-1:0] refclk_sel_param  = refclk_sel_fnl == 10  ? "ref_iqclk10" :
                                                          refclk_sel_fnl ==  9  ? "ref_iqclk9"  :
                                                          refclk_sel_fnl ==  8  ? "ref_iqclk8"  :
                                                          refclk_sel_fnl ==  7  ? "ref_iqclk7"  :
                                                          refclk_sel_fnl ==  6  ? "ref_iqclk6"  :
                                                          refclk_sel_fnl ==  5  ? "ref_iqclk5"  :
                                                          refclk_sel_fnl ==  4  ? "ref_iqclk4"  :
                                                          refclk_sel_fnl ==  3  ? "ref_iqclk3"  :
                                                          refclk_sel_fnl ==  2  ? "ref_iqclk2"  :
                                                          refclk_sel_fnl ==  1  ? "ref_iqclk1"  :
                                                                                  "ref_iqclk0"  ;
        // resolve enable_hclk; enable the HCLK_DRIVER if the value at index is "1"
        localparam  [MAX_CHARS*8 - 1 : 0] hclk_str_cmu      = altera_xcvr_functions::get_value_at_index(ig,enable_hclk); 
        localparam  [MAX_CHARS*8 - 1 : 0] HCLK_ENABLE_CMU   = (hclk_str_cmu == "1") ? "true" : "false";

        wire    mux_refclk_out;

        assign  atx_avmm_readdata     = 16'd0;
        assign  atx_avmm_blockselect  = 1'b0;
        assign  atx_mux_avmm_readdata = 16'd0;
        assign  atx_mux_avmm_blockselect  = 1'b0;


        if(enable_mux == 1) begin:pll_mux
          wire  [10:0]  int_refclks;  // internal refclks

          assign  int_refclks = { {(11-refclks){1'b0}} , refclk};

          stratixv_hssi_pma_cdr_refclk_select_mux
          #(
            .refclk_select(refclk_sel_param),
            .reference_clock_frequency(refclk_freq_fnl)
            //parameter lpm_type = "stratixv_hssi_pma_cdr_refclk_select_mux";
            //parameter mux_type = "cdr_refclk_select_mux"; // cdr_refclk_select_mux|lc_refclk_select_mux
            //parameter channel_number =  0 ;
            //parameter avmm_group_channel_index = 0;
            //parameter use_default_base_address = "true";
            //parameter user_base_address = 0;

          ) pll_refclk_select_mux (
            // AVMM inteface
            .avmmclk      (local_avmm_clk       ),
            .avmmrstn     (local_avmm_rstn      ),
            .avmmwrite    (local_avmm_write     ),
            .avmmread     (local_avmm_read      ),
            .avmmbyteen   (local_avmm_byteen    ),
            .avmmaddress  (local_avmm_address   ),
            .avmmwritedata(local_avmm_writedata ),
            .avmmreaddata (cdr_mux_avmm_readdata    ),
            .blockselect  (cdr_mux_avmm_blockselect ),

            // Refclk inputs
            .refiqclk0    (int_refclks[0] ),
            .refiqclk1    (int_refclks[1] ),
            .refiqclk10   (int_refclks[10] ),
            .refiqclk2    (int_refclks[2] ),
            .refiqclk3    (int_refclks[3] ),
            .refiqclk4    (int_refclks[4] ),
            .refiqclk5    (int_refclks[5] ),
            .refiqclk6    (int_refclks[6] ),
            .refiqclk7    (int_refclks[7] ),
            .refiqclk8    (int_refclks[8] ),
            .refiqclk9    (int_refclks[9]),

            // Selected refclk output
            .clkout       (mux_refclk_out )

            `ifndef ALTERA_RESERVED_QIS
            ,
            // Unused
            .calclk         (1'b0),
            .ffplloutbot    (1'b0),
            .ffpllouttop    (1'b0),
            .pldclk         (1'b0),
            .rxiqclk0       (1'b0),
            .rxiqclk1       (1'b0),
            .rxiqclk10      (1'b0),
            .rxiqclk2       (1'b0),
            .rxiqclk3       (1'b0),
            .rxiqclk4       (1'b0),
            .rxiqclk5       (1'b0),
            .rxiqclk6       (1'b0),
            .rxiqclk7       (1'b0),
            .rxiqclk8       (1'b0),
            .rxiqclk9       (1'b0),

            .occalen        (1'b0),
            .refclklc       (1'b0)
            `endif // ifndef ALTERA_RESERVED_QIS
          );
        end else begin:no_mux
          assign  mux_refclk_out  = refclk   [refclk_sel_fnl];
        end

        // Create CMU pll atom
        stratixv_channel_pll
        #(
          // Parameter declarations and default value assignments
          .reference_clock_frequency(refclk_freq_fnl),
          .output_clock_frequency   (outclk_freq_fnl),
          .fb_sel(feedback_clk_fnl),
          .cgb_clk_enable("true"),
          .txpll_hclk_driver_enable(HCLK_ENABLE_CMU),
          .enabled_for_reconfig(enabled_for_reconfig),
          .sim_use_fast_model(sim_use_fast_model)
          //parameter avmm_group_channel_index = 0,
          //parameter use_default_base_address = "true",
          //parameter user_base_address = 0,
          //parameter bbpd_salatch_offset_ctrl_clk0 = "offset_0mv",
          //parameter bbpd_salatch_offset_ctrl_clk180 = "offset_0mv",
          //parameter bbpd_salatch_offset_ctrl_clk270 = "offset_0mv",
          //parameter bbpd_salatch_offset_ctrl_clk90 = "offset_0mv",
          //parameter bbpd_salatch_sel = "normal",
          //parameter bypass_cp_rgla = "false",
          //parameter cdr_atb_select = "atb_disable",
          //parameter charge_pump_current_test = "enable_ch_pump_normal",
          //parameter clklow_fref_to_ppm_div_sel = 1,
          //parameter clock_monitor = "lpbk_data",
          //parameter diag_rev_lpbk = "false",
          //parameter eye_monitor_bbpd_data_ctrl = "cdr_data",
          //parameter fast_lock_mode = "false",
          //parameter gpon_lock2ref_ctrl = "lck2ref",
          //parameter hs_levshift_power_supply_setting = 1,
          //parameter ignore_phslock = "false",
          //parameter l_counter_pd_clock_disable = "false",
          //parameter m_counter = 4,
          //parameter pcie_freq_control = "pcie_100mhz",
          //parameter pd_charge_pump_current_ctrl = 5,
          //parameter pd_l_counter = 1,
          //parameter pfd_charge_pump_current_ctrl = 20,
          //parameter pfd_l_counter = 1,
          //parameter powerdown = "false",
          //parameter ref_clk_div = 1,
          //parameter regulator_volt_inc = "0",
          //parameter replica_bias_ctrl = "true",
          //parameter reverse_serial_lpbk = "false",
          //parameter ripple_cap_ctrl = "none",
          //parameter rxpll_pd_bw_ctrl = 300,
          //parameter rxpll_pfd_bw_ctrl = 3200,
          //parameter vco_overange_ref = "off",
          //parameter vco_range_ctrl_en = "false"
        ) tx_pll (
          // AVMM interface
          .avmmaddress    (local_avmm_address   ),
          .avmmbyteen     (local_avmm_byteen    ),
          .avmmclk        (local_avmm_clk       ),
          .avmmread       (local_avmm_read      ),
          .avmmrstn       (local_avmm_rstn      ),
          .avmmwrite      (local_avmm_write     ),
          .avmmwritedata  (local_avmm_writedata ),
          .avmmreaddata   (cdr_avmm_readdata    ),
          .blockselect    (cdr_avmm_blockselect ),

          // Inputs
          .refclk         (mux_refclk_out ),
          .extclk         (fbclk_in   ),
          .ltd            (1'b1       ), // PMA interface block has a invert on LTD so need to drive 1 on LTD to see actual 0.
          .ltr            (1'b1       ),
          .rstn           (~rst[ig]   ),
          .pciel          (1'b0       ),
          .pciem          (1'b0       ),
          .pciesw         (2'b00      ), //set to 0 for the tx pll

          // Outputs
          .clkcdr         (pll_outclk ),
          .pfdmodelock    (locked[ig] ),
          .txpllhclk      (hclk[ig]   )

          // Unused inputs
          `ifndef ALTERA_RESERVED_QIS
          ,
          .crurstb        (1'b0),
          .clk270beyerm   (1'b0),
          .clk270eye      (1'b0),
          .clk90beyerm    (1'b0),
          .clk90eye       (1'b0),
          .clkindeser     (1'b0),
          .deeye          (1'b0),
          .deeyerm        (1'b0),
          .doeye          (1'b0),
          .doeyerm        (1'b0),
          .earlyeios      (1'b0),
          .extfbctrla     (1'b0),
          .extfbctrlb     (1'b0),
          .gpblck2refb    (1'b0),
          .lpbkpreen      (1'b0),
          .occalen        (1'b0),
          .ppmlock        (1'b0),
          .rxp            (1'b0),
          .sd             (1'b0),
          
          // Unused outputs
          .ck0pd          (/*unused*/),
          .ck180pd        (/*unused*/),
          .ck270pd        (/*unused*/),
          .ck90pd         (/*unused*/),
          .clk270bcdr     (/*unused*/),
          .clk270bdes     (/*unused*/),
          .clk90bcdr      (/*unused*/),
          .clk90bdes      (/*unused*/),
          .clklow         (/*unused*/),
          .decdr          (/*unused*/),
          .deven          (/*unused*/),
          .docdr          (/*unused*/),
          .dodd           (/*unused*/),
          .fref           (/*unused*/),
          .pdof           (/*unused*/),
          .rxlpbdp        (/*unused*/),
          .rxlpbp         (/*unused*/),
          .rxplllock      (/*unused*/),
          .txrlpbk        (/*unused*/),
          .vctrloverrange (/*unused*/)
          `endif // ifndef ALTERA_RESERVED_QIS
        );
      end // CMU PLL

      // LC PLL
      if(use_atx_pll) begin:atx_pll
        // Create LCELL to hard drive lpf reset
        //(* keep = 1 *)
        wire  cmurstnlpf = 1'b1;
        wire  cmurstn;

        wire  clk010g;
        wire  clk025g;

        wire    mux_refclk_out_atx;
        
        // Determine feedback clock selection
        localparam  [MAX_CHARS*8-1:0] feedback_clk_fnl = (feedback_clk_sel == "external") ? "external_fb" : "internal_fb";
        // Determine LC buffer selection
        localparam  [MAX_CHARS*8-1:0] ENABLE_BUF14G = (att_mode == 1) ? "enable_buf14g" : "disable_buf14g";
        localparam  [MAX_CHARS*8-1:0] ENABLE_BUF8G  = (att_mode == 0) ? "enable_buf8g"  : "disable_buf8g";
      
        // hclk is only used for PCIe HIP and it always comes from the user selected PLL (CMU,ATX)
        // If user selected PLL is ATX in Gen 3, enable hclk driver for this PLL.
        // PCIe Gen 3 uses separate ATX PLL along with user selected PLL; the hclk driver for this second PLL should be turned off
        localparam  [MAX_CHARS   - 1 : 0] hclk_str_atx      = altera_xcvr_functions::get_value_at_index(ig,enable_hclk); 
        localparam  [MAX_CHARS*8 - 1 : 0] HCLK_ENABLE_ATX   = (hclk_str_atx == "1") ? "driver_on" : "driver_off";

        // Assign unused AVMM connections
        assign  cdr_mux_avmm_readdata     = 16'd0;
        assign  cdr_mux_avmm_blockselect  = 1'b0;
        assign  cdr_avmm_readdata     = 16'd0;
        assign  cdr_avmm_blockselect  = 1'b0;

        assign  pll_outclk  = (att_mode == 0) ? clk010g : clk025g;

        // Disconnect reset for ES silicon unless macro is defined.
        `ifdef ALTERA_RESERVED_XCVR_SV_ATX_PLL_RESET_CONNECT
          assign  cmurstn = ~rst[ig];
        `else
          assign  cmurstn = 1'b1;
        `endif
        
        localparam  [MAX_CHARS*8-1:0] refclk_source_sel_fnl = "iqclk";
      
        // Determine RefIQ path selection for the LC Refclk mux
        localparam  [MAX_CHARS*8-1:0] refclk_sel_param  = refclk_sel_fnl == 10  ? "ref_iqclk10" :
                                                          refclk_sel_fnl ==  9  ? "ref_iqclk9"  :
                                                          refclk_sel_fnl ==  8  ? "ref_iqclk8"  :
                                                          refclk_sel_fnl ==  7  ? "ref_iqclk7"  :
                                                          refclk_sel_fnl ==  6  ? "ref_iqclk6"  :
                                                          refclk_sel_fnl ==  5  ? "ref_iqclk5"  :
                                                          refclk_sel_fnl ==  4  ? "ref_iqclk4"  :
                                                          refclk_sel_fnl ==  3  ? "ref_iqclk3"  :
                                                          refclk_sel_fnl ==  2  ? "ref_iqclk2"  :
                                                          refclk_sel_fnl ==  1  ? "ref_iqclk1"  :
                                                                                  "ref_iqclk0"  ;
        if(enabled_for_reconfig == "true" && enable_mux == 1) begin:pll_mux
          wire  [10:0]  int_refclks;  // internal refclks

          assign  int_refclks = { {(11-refclks){1'b0}} , refclk};

          stratixv_hssi_pma_lc_refclk_select_mux
          #(
            .refclk_select(refclk_sel_param),
            .reference_clock_frequency(refclk_freq_fnl)
            //parameter channel_number =  0 ;
            //parameter avmm_group_channel_index = 0;
            //parameter use_default_base_address = "true";
            //parameter user_base_address = 0;
          
          ) pll_refclk_select_mux (
            // AVMM inteface
            .avmmclk      (local_avmm_clk       ),
            .avmmrstn     (local_avmm_rstn      ),
            .avmmwrite    (local_avmm_write     ),
            .avmmread     (local_avmm_read      ),
            .avmmbyteen   (local_avmm_byteen    ),
            .avmmaddress  (local_avmm_address   ),
            .avmmwritedata(local_avmm_writedata ),
            .avmmreaddata (atx_mux_avmm_readdata    ),
            .blockselect  (atx_mux_avmm_blockselect ),

            // Refclk inputs
            .refiqclk0    (int_refclks[0] ),
            .refiqclk1    (int_refclks[1] ),
            .refiqclk10   (int_refclks[10] ),
            .refiqclk2    (int_refclks[2] ),
            .refiqclk3    (int_refclks[3] ),
            .refiqclk4    (int_refclks[4] ),
            .refiqclk5    (int_refclks[5] ),
            .refiqclk6    (int_refclks[6] ),
            .refiqclk7    (int_refclks[7] ),
            .refiqclk8    (int_refclks[8] ),
            .refiqclk9    (int_refclks[9]),

            // Selected refclk output
            .clkout       (mux_refclk_out_atx )

            `ifndef ALTERA_RESERVED_QIS
            ,
            // Unused inputs
            .ffplloutbot  (1'b0),
            .ffpllouttop  (1'b0),
            .rxiqclk0     (1'b0),
            .rxiqclk1     (1'b0),
            .rxiqclk10    (1'b0),
            .rxiqclk2     (1'b0),
            .rxiqclk3     (1'b0),
            .rxiqclk4     (1'b0),
            .rxiqclk5     (1'b0),
            .rxiqclk6     (1'b0),
            .rxiqclk7     (1'b0),
            .rxiqclk8     (1'b0),
            .rxiqclk9     (1'b0)
            `endif // ifndef ALTERA_RESERVED_QIS
          );
        end else begin:no_mux
          assign  mux_refclk_out_atx  = refclk   [refclk_sel_fnl];
        end
       
        // Create LC pll atom
        stratixv_atx_pll#(  
          .reference_clock_frequency(refclk_freq_fnl  ),
          .output_clock_frequency   (outclk_freq_fnl  ),
          .refclk_sel (refclk_source_sel_fnl          ),
          .fbclk_sel  (feedback_clk_fnl ),
//          .lcvco_sel  ("LOW_FREQ_8G"    ),  // TODO - This should not be needed
          .sel_buf8g  (ENABLE_BUF8G     ),
          .sel_buf14g (ENABLE_BUF14G    ),
          .lcpll_hclk_driver_enable(HCLK_ENABLE_ATX),
          .enabled_for_reconfig(enabled_for_reconfig),
          .sim_use_fast_model(sim_use_fast_model), 
        //.cp_current_ctrl("200"),
        //.cp_current_test("ENABLE_CH_PUMP_NORMAL"),
        //.cp_hs_levshift_power_supply_setting("1"),
        //.cp_replica_bias_ctrl("DISABLE_REPLICA_BIAS_CTRL"),
        //.cp_rgla_bypass("false"),
        //.cp_rgla_volt_inc("BOOST_0PCT"),
        //.l_counter("2"),
        .lc_cmu_pdb("true")
        //.lc_div33_pdb("false"),
        //.lcpll_atb_select("ATB_DISABLE"),
        //.lcvco_gear_sel("HIGH_GEAR"),
        //.lpf_ripple_cap_ctrl("NONE"),
        //.lpf_rxpll_pfd_bw_ctrl("2000"),
        //.m_counter("25"),
        //.ref_clk_div("1"),
        //.vreg1_lcvco_volt_inc("VOLT_1P1V"),
        //.vreg1_vccehlow("NORMAL_OPERATION"),
        //.vreg2_lcpll_volt_sel("VREG2_VOLT_1P0V"),
        //.vreg3_lcpll_volt_sel("VREG3_VOLT_1P0V"),
        //.vco_over_range_ref("VCO_OVER_RANGE_OFF"),
        //.vco_under_range_ref("VCO_UNDER_RANGE_OFF")
        //.ac_cap("DISABLE_AC_CAP"),
        ) tx_pll (
          // AVMM interface
          .avmmaddress    (local_avmm_address   ),
          .avmmbyteen     (local_avmm_byteen    ),
          .avmmclk        (local_avmm_clk       ),
          .avmmread       (local_avmm_read      ),
          .avmmrstn       (local_avmm_rstn      ),
          .avmmwrite      (local_avmm_write     ),
          .avmmwritedata  (local_avmm_writedata ),
          .avmmreaddata   (atx_avmm_readdata    ),
          .blockselect    (atx_avmm_blockselect ),

          .iqclklc        (mux_refclk_out_atx   ), // refclk (iqclk). Always connect to the IQ input. 
          .extfbclk       (fbclk_in             ),
          .pllfbswblc     (pll_fb_sw[ig]        ),
          .cmurstn        (cmurstn              ),
          .cmurstnlpf     (cmurstnlpf           ),

          .clk010g        (clk010g              ),
          .clk025g        (clk025g              ),
          .pfdmodelockcmu (locked   [ig]        ),
          .txpllhclk      (hclk     [ig]        )

          `ifndef ALTERA_RESERVED_QIS
          ,
          // Input port declarations
          .ch0rcsrlc      (32'd0          ),
          .ch1rcsrlc      (32'd0          ),
          .ch2rcsrlc      (32'd0          ),
          .pllfbswtlc     (1'b0           ), // pll feedback switch (top)
          .pldclklc       (1'b0           ), // refclk (from core)
          .refclklc       (1'b0           ), //direct Refclk path from LVPECL

          // Output port declarations
          .ch0lctestout   (/*unused*/ ),
          .ch1lctestout   (/*unused*/ ),
          .ch2lctestout   (/*unused*/ ),
          .clk18010g      (/*unused*/ ),
          .clk18025g      (/*unused*/ ),
          .clk33cmu       (/*unused*/ ),
          .clklowcmu      (/*unused*/ ),
          .iqclkatt       (/*unused*/ ),
          .pldclkatt      (/*unused*/ ),
          .refclkatt      (/*unused*/ )
          `endif // ifndef ALTERA_RESERVED_QIS
        ); 
      end // LC PLL
    end // Not Generic PLL

    // We put a CGB between
    if (is_xN == 0) begin : g_x1_outclk
      assign  outclk[ig]  = pll_outclk;
    end else begin : g_xN_cgb
      stratixv_hssi_pma_tx_cgb #(
        .mode                 (40                 ),
        .auto_negotiation     ("false"            ),
        .data_rate            (outclk_rate_sel    ),
        .pcie_rst             ("normal_reset"     ),
        .x1_clock_source_sel  ("same_ch_txpll"    ),
        .xn_clock_source_sel  ("cgb_x1_m_div"     ),
        .x1_div_m_sel         (1                  ),
      
        // Attributes for PCIe Gen3
        .cgb_sync             ("normal"           ),
        .clk_mute             ("disable_clockmute"),
        .pcie_g3_x8           ("non_pcie_g3_x8"   ),
        .pll_feedback         ("non_pll_feedback" ),
        .reset_scheme         ("non_reset_bonding_scheme")
      ) xN_cgb (
        .rstn           (1'b0         ),  // Hold xN CGB in reset (does not mute hfclk)
        .clkcdrloc      (pll_outclk   ),
        .hfclkpout      (outclk  [ig] ),
  
        // Unused signals
  `ifdef ALTERA_RESERVED_QIS_ES
        .pcs_rst_n      (             ), // float connection for ES as this is a production only signal
  `else 
        .pcs_rst_n      (1'b0         ),
  `endif
        .clkcdr1t       (1'b0         ),
        .clkcdr1b       (1'b0         ),
        .clklct         (1'b0         ),
        .clklcb         (1'b0         ),
        .clkffpll       (1'b0         ),
        .clkupseg       (1'b0         ),
        .clkdnseg       (1'b0         ),
        .pciesw         (2'b00        ),
        .hfclkpxnup     (1'b0         ),
        .lfclkpxnup     (1'b0         ),
        .cpulsexnup     (1'b0         ),
        .pclkxnup       (3'b000       ),
        // to serializer
        .cpulse         (/*unused*/   ),
        .hfclkp         (/*unused*/   ),
        .lfclkp         (/*unused*/   ),
        .pclk           (/*unused*/   ),
        
        // when used as a CGB master, these are bonding clocks
        .cpulseout      (/*unused*/   ),
        .lfclkpout      (/*unused*/   ),
        .pclkout        (/*unused*/   ),
        .pcieswdone     (/*unused*/   ),
        .pciefbclk      (/*unused*/   ),
        .pllfbsw        (/*unused*/   ),
        .txpmasyncp     (1'b0         ),
        
        .avmmrstn       (1'b1         ),
        .avmmclk        (1'b0         ),
        .avmmwrite      (1'b0         ),
        .avmmread       (1'b0         ),
        .avmmbyteen     (2'b00        ),
        .avmmaddress    (11'd0        ),
        .avmmwritedata  (16'd0        ),
        .avmmreaddata   (/*unused*/   ),
        .blockselect    (/*unused*/   )
  
        `ifndef ALTERA_RESERVED_QIS
        ,
        .hfclkn         (             ),
        .hfclknout      (             ),
        .lfclkn         (             ),
        .lfclknout      (             ),
        .rxiqclk        (             ),
        .fref           (1'b0         ),
        .rxclk          (1'b0         ),
        .clkbcdr1t      (1'b0         ),
        .clkbcdr1b      (1'b0         ),
        .clkbcdrloc     (1'b0         ),
        .clkbdnseg      (1'b0         ),
        .clkbffpll      (1'b0         ),
        .clkblcb        (1'b0         ),
        .clkblct        (1'b0         ),
        .clkbupseg      (1'b0         ),
        .cpulsex6up     (1'b0         ),
        .cpulsex6dn     (1'b0         ),
        .cpulsexndn     (1'b0         ),
        .hfclknx6up     (1'b0         ),
        .hfclknx6dn     (1'b0         ),
        .hfclknxndn     (1'b0         ),
        .hfclknxnup     (1'b0         ),
        .hfclkpx6up     (1'b0         ),
        .hfclkpx6dn     (1'b0         ),
        .hfclkpxndn     (1'b0         ),
        .lfclknx6up     (1'b0         ),
        .lfclknx6dn     (1'b0         ),
        .lfclknxndn     (1'b0         ),
        .lfclknxnup     (1'b0         ),
        .lfclkpx6up     (1'b0         ),
        .lfclkpx6dn     (1'b0         ),
        .lfclkpxndn     (1'b0         ),
        .pciesyncp      (/*TODO*/     ),
        .pclkx6up       (3'b0         ),
        .pclkx6dn       (3'b0         ),
        .pclkxndn       (3'b0         )
        `endif // ifndef ALTERA_RESERVED_QIS
      );
    end // if is_xN

  end // for each PLL
endgenerate

// Function takes in a string of comma seperated values containing PLL types.
// returns a binary where every two bits represents the PLL type. Allows
// Up to 10 PLLs
function  [plls*2-1:0]  pll_type_str2bin(
  input [MAX_CHARS*MAX_STRS*8-1:0]  pll_type_set
);
  int index;
  reg [MAX_CHARS*8-1:0] pll_type_str;
  reg [1:0] pll_type_bin;

  pll_type_str2bin = {plls{2'b00}};
  for(index = 0; index < plls; index = index + 1) begin
    pll_type_str = altera_xcvr_functions::get_value_at_index(index,pll_type_set);
    pll_type_bin = (pll_type_str == "ATX")  ? sv_xcvr_h::SV_XR_ID_PLL_TYPE_LC  [1:0]: 
                   (pll_type_str == "fPLL") ? sv_xcvr_h::SV_XR_ID_PLL_TYPE_FPLL[1:0]:
                   (pll_type_str == "CMU")  ? sv_xcvr_h::SV_XR_ID_PLL_TYPE_CMU [1:0]:
                   (pll_type_str == "AUTO") ? sv_xcvr_h::SV_XR_ID_PLL_TYPE_CMU [1:0]:
                                              sv_xcvr_h::SV_XR_ID_PLL_TYPE_NONE[1:0];
    pll_type_str2bin = pll_type_str2bin | (( {plls{2'b00}} | pll_type_bin ) << (index*2));
  end
endfunction

// pll_network_str2bin converts a string of comma seperated PLL network types to a binary field
// where each bit represents a network type.
//
// @param pll_network_sel - A string of comma seperated values containing PLL network types ("x1","xN").
//
// @return A binary where every bit represents the PLL network type.
function  [plls-1:0]  pll_network_str2bin(
  input [MAX_CHARS*MAX_STRS*8-1:0]  pll_network_sel
);
  int index;
  reg [MAX_CHARS*8-1:0] pll_network_str;  // Single channel string representation of network type ("x1","xN")
  reg pll_network_bin;  // Single channel binary represenation of network type (0=x1,1=xN)

  pll_network_str2bin = {plls{1'b0}}; // Initialize
  for(index = 0; index < plls; index = index + 1) begin
    pll_network_str = altera_xcvr_functions::get_value_at_index(index,pll_network_sel); // get current string
    pll_network_bin = (pll_network_str == "xN") ? 1'b1 : 1'b0; // Convert to binary
    pll_network_str2bin = pll_network_str2bin | (( {plls{1'b0}} | pll_network_bin ) << index);
  end
endfunction

endmodule
