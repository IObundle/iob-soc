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

//************************************************************************************************************************
//
// StratixV Native PIPE Channel
//
//************************************************************************************************************************

module sv_xcvr_pipe_native #(
     parameter lanes = 1, //legal value: 1+
     parameter starting_channel_number = 0, //Automatically set to 0. So do we still need it?
     parameter protocol_version = "Gen 1", //legal value: "Gen 1", "Gen 2", "Gen 3". "Gen 3" option is available for HIP only.
     parameter pll_type = "AUTO",        //legal value: "CMU", "ATX" 
     parameter base_data_rate = "0 Mbps",   //legal values: PLL rate. Can be (data rate * 1,2,4,or 8). 
                                               // Gen1: data rate = 2500 Mbps. 
                                               // Gen2: data rate = 5000 Mbps. 
     parameter pll_refclk_freq = "100 MHz", //legal value = "100 MHz", "125 MHz"
     parameter deser_factor = 16, //legal value: 8, 16, 32. Option 32 is available for HIP only.
     parameter pipe_low_latency_syncronous_mode = 0, //legal value: 0, 1
     parameter bypass_g3pcs_scrambler_descrambler = 1, //legal value: 0, 1; default is set to 1 i.e bypass
     parameter bypass_g3pcs_dcbal = 0,                 //legal value: 0, 1
     parameter pipe_run_length_violation_checking = 160, //legal value:[160:5:5], max (6'b0) is the default value
     parameter pipe_elec_idle_infer_enable = "false", //legal value: true, false
     parameter hip_enable = "false",
     parameter hip_hard_reset = "disable",
     parameter hard_oc_enable = "false", // by default do not run hard_oc.
     parameter in_cvp_mode = "not_in_cvp_mode", //legal values: not_in_cvp_mode, in_cvp_mode
     // Exposing the Pre-emphasis and VOD static values 
     parameter pipe12_rpre_emph_a_val = 6'b001001, 
     parameter pipe12_rpre_emph_b_val = 6'b000000, 
     parameter pipe12_rpre_emph_c_val = 6'b010000, 
     parameter pipe12_rpre_emph_d_val = 6'b001011, 
     parameter pipe12_rpre_emph_e_val = 6'b000101,
     parameter pipe12_rvod_sel_a_val  = 6'b101010,
     parameter pipe12_rvod_sel_b_val  = 6'b100110,
     parameter pipe12_rvod_sel_c_val  = 6'b100110,
     parameter pipe12_rvod_sel_d_val  = 6'b100110,
     parameter pipe12_rvod_sel_e_val  = 6'b001111,
     parameter reserved_channel       = "false", 
     parameter master_ch_number       = -1
 ) (

    //input from reset controller
    input  wire               pll_powerdown,   // for tx pll from pld
    input  wire               tx_analogreset,  // for tx pma from pld
    input  wire  [lanes-1 :0] tx_digitalreset, // for tx pcs from pld
    input  wire  [lanes-1 :0] rx_analogreset,  // for rx pma from pld
    input  wire  [lanes-1 :0] rx_digitalreset, // for rx pcs from pld
	
    //input clocks from user
    input  wire               pll_ref_clk, // reference clock for PLL 
    input  wire               fixedclk,    // used in receiver detect (txdetrx) block in Tx PMA
	
    //PIPE interface ports (avalon streaming ports)
    output wire                               pipe_pclk,
    input  wire [lanes*deser_factor -1:0]     pipe_txdata,
    input  wire [(lanes*deser_factor)/8 -1:0] pipe_txdatak,

    input  wire [lanes -1:0]                  pipe_txcompliance,
    input  wire [lanes -1:0]                  pipe_txelecidle,
    input  wire [lanes -1:0]                  pipe_rxpolarity,
    output wire [lanes*deser_factor -1:0]     pipe_rxdata,
    output wire [(lanes*deser_factor)/8 -1:0] pipe_rxdatak,
    output wire [lanes -1:0]                  pipe_rxvalid,
    output wire [lanes -1:0]                  pipe_rxelecidle,
    output wire [lanes*3 -1:0]                pipe_rxstatus,
    output wire [((lanes == 8 || reserved_channel == "true")? (lanes+1):lanes)*3 -1 : 0] pld8grxstatus,

    input  wire	[lanes -1:0]	                pipe_txdetectrx_loopback,
    input  wire	[lanes -1:0]	                pipe_txswing,
    input  wire	[lanes*3 -1:0]	              pipe_txmargin,
    input  wire	[lanes-1 :0]                  pipe_txdeemph,    // used for Gen2 HIP and soft PIPE modes
    input  wire	[lanes*18-1:0]                pipe_g3_txdeemph, // Only for Gen3 Soft PIPE mode
    input  wire [lanes*3 -1:0]                pipe_rxpresethint,// Only for Gen3 Soft PIPE mode 
    input  wire	[lanes*2 -1:0]	              pipe_rate,        // each channel has its own dedicated pipe_rate signal
    input  wire	[lanes*2 -1:0]	              pipe_powerdown,
    output wire	[lanes -1:0]	                pipe_phystatus,
    input  wire	[lanes*3 -1:0]	              rx_eidleinfersel,
	
    //non-PIPE ports
    //MM ports
    input  wire [lanes -1:0]                  rx_set_locktodata,         // directly connected to rx_pma.ltd
    input  wire [lanes -1:0]                  rx_set_locktoref,          // goes through pcs and then to rx_pma.ltr
    input  wire [lanes -1:0]                  tx_invpolarity,
    output wire [(lanes*deser_factor)/8 -1:0] rx_errdetect, 
    output wire [(lanes*deser_factor)/8 -1:0] rx_disperr,
    output wire [(lanes*deser_factor)/8 -1:0] rx_patterndetect, 
    output wire [(lanes*deser_factor)/8 -1:0] rx_syncstatus, 
    output wire [lanes -1:0]                  rx_phase_comp_fifo_error,
    output wire [lanes -1:0]                  tx_phase_comp_fifo_error,
    output wire [lanes -1:0]                  rx_is_lockedtoref,        // directly from rx_pma
    output wire [lanes -1:0]                  rx_is_lockedtodata,       // from rx_pma to pcs then to port
    output wire [lanes -1:0]                  rx_signaldetect, //PLD version
    output wire	[lanes -1:0]	                rx_rlv,
    output wire [lanes*5  -1:0]	              rx_bitslipboundaryselectout,
    output wire                               pll_locked,
    input  tri0 [lanes -1:0]                  rx_seriallpbken,

    // Calibration busy signals
    output  wire [lanes-1:0]   tx_cal_busy,
    output  wire [lanes-1:0]   rx_cal_busy,

    //non-MM ports
    input  wire [lanes -1:0]   rx_serial_data,
    output wire [lanes -1:0]   tx_serial_data,
	
    //ports for designs with PCIe HIP
    input  wire	[1:0]                         rate_ctrl,  //Dedicated connection for rate from HIP to S1C1 (reserved channel 4 in x8)
    output wire                               pipe_pclkch1, 	
    output wire                               pipe_pclkcentral,
    output wire                               pllfixedclkcentral,
    output wire                               pllfixedclkch0,
    output wire                               pllfixedclkch1,
   
    // Gen3 signals
    input  wire [lanes*18 -1:0]               current_coeff,      //Proprietary Gen3 coeff interface to PCIe HIP
    input  wire [lanes*3  -1:0]               current_rxpreset,   //Proprietary Gen3 coeff interface to PCIe HIP
    input  wire [lanes    -1:0]               pipe_tx_data_valid, // PIPE 3.0 spec 
    input  wire [lanes    -1:0]               pipe_tx_blk_start,  // PIPE 3.0 spec 
    input  wire [lanes*2  -1:0]               pipe_tx_sync_hdr,   // PIPE 3.0 spec 
      
    output wire [lanes    -1:0]               pipe_rx_data_valid, // PIPE 3.0 spec 
    output wire [lanes    -1:0]               pipe_rx_blk_start,  // PIPE 3.0 spec 
    output wire [lanes*2  -1:0]               pipe_rx_sync_hdr,   // PIPE 3.0 spec 

    // HIP Hard reset controller signals (PCS PLD IF/PLL -> HIP) //TODO
    output wire [lanes:0]    frefclk,            // Data channels (Channel PLL output)
    output wire [lanes:0]    offcaldone,         // Data channels 
    //output wire [lanes:0]    masktxplllock,    // From Gen 3 PIPE through the PCS-PLD i/f block. Per ICD, HRC listens to this signal from the CMu channel. TODO for Gen3.
    //output wire [lanes:0]    txlcplllock,      //TODO for Gen3. For Gen1/2, GPLL will be converted to either CMU or LC PLL in the fitter and will connect its locked output to either rdfreqcmuplllock or txlcplllock for post-fit sim. 
    output wire [((lanes == 2) ? 4 : lanes):0]   rxfreqtxcmuplllock, // Data channels (locked to ref from Channel PLL) and CMU channel (tx pll locked from CMU). Connect to pll_locked from GPLL for pre-fit sim. 
    output wire [lanes:0]    rxpllphaselock,    // Locked to data from Data channels 
    
    // HIP Hard reset controller signals (HIP -> PCS PLD IF/PLL)
    input wire [lanes:0]     offcalen,           // To data channels  
    input wire [lanes:0]     txpcsrstn,          // active-low reset from HRC to 8g Tx PCS
    input wire [lanes:0]     rxpcsrstn,          // active-low reset from HRC to 8g Rx PCS
    input wire [lanes:0]     g3txpcsrstn,        // active-low reset from HRC to g3 Tx PCS
    input wire [lanes:0]     g3rxpcsrstn,        // active-low reset from HRC to g3 Rx PCS
    input wire [((lanes == 2) ? 4 : lanes):0]    rxpmarstb,          // active-low reset from HRC to Rx PMA (Channel PLL and CMU PLL )
    input wire [lanes:0]     txpmasyncp,         // Tx PMA reset pulse from HIP HRC through Gen 3 PIPE to Master CGB 
    //input wire [lanes:0]   txlcpllrstb,         // active-low reset from HRC to LC PLL //TODO for Gen3. For Gen1/2, GPLL will be converted to either CMU or LC PLL in the fitter and will connect its locked output to either rdfreqcmuplllock or txlcplllock for post-fit sim.  

    // Reconfig interface 
    // Gen 1/Gen 2
    // HIP     x8  - 9 channels (8 + 1 CMU/CGB) + 1 PLLs (HCLK PLL will be merged with Tx PLL)
    // HIP     x4  - 4 channels                 + 1 PLLs (HCLK PLL will be merged with Tx PLL)
    // HIP     x1  - 1 channel                  + 1 PLLs (HCLK PLL will be merged with Tx PLL)
    
    // Non-HIP x8  - 8 channels                 + 1 PLL  (1 Tx PLL)
    // Non-HIP x4  - 4 channels                 + 1 PLL  (1 Tx PLL)
    // Non-HIP x1  - 1 channel                  + 1 PLL  (1 Tx PLL)

    // Gen 3 
    // HIP     x8  (xN bonding with 1CMU/1LC) 
    //             - 9 channels (8 + 1 CMU/CGB)            + 2 PLLs (HCLK PLL should merged with Gen1/2 Tx CMU PLL)
    // HIP     x4  - 4 channels                + 2 PLLs (HCLK PLL will be merged with Tx CMU PLL)
    // HIP     x1  - 1 channel                 + 2 PLLs (HCLK PLL will be merged with Tx CMU PLL)
    
    // get_custom_reconfig_*_width (family, operating mode, lanes, plls, bonded group size)

    input   wire  [altera_xcvr_functions::get_custom_reconfig_to_width  ("Stratix V","Duplex",
                                                  (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? ((protocol_version == "Gen 3")?(lanes+3):(lanes+1)):lanes),
                                                  ((protocol_version == "Gen 3") ? (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? 4 : 2) : 1),
                                                  (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? (lanes+1):lanes),"","xN")-1:0] reconfig_to_xcvr,
    output  wire  [altera_xcvr_functions::get_custom_reconfig_from_width ("Stratix V","Duplex",
                                                  (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? ((protocol_version == "Gen 3")?(lanes+3):(lanes+1)):lanes),
                                                  ((protocol_version == "Gen 3") ? (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? 4 : 2) : 1),
                                                  (((hip_enable == "true" || reserved_channel == "true") && lanes == 8) ? (lanes+1):lanes),"","xN")-1:0] reconfig_from_xcvr
);
   
import altera_xcvr_functions::*;
    //****************************************************************************************************
    // Derive localparams for PCS and PMA
    //****************************************************************************************************
    //********************************************
    // Common local params
    //********************************************
    // protocol mode
    // --------------
    localparam PROT_MODE = (protocol_version == "Gen 1") ? "pipe_g1" : 
                           (protocol_version == "Gen 2") ? "pipe_g2" : 
                           (protocol_version == "Gen 3") ? "pipe_g3" : "<invalid>";

    // HIP mode
    // --------
    localparam HIP_MODE  = (hip_enable == "true") ? "en_hip" : "dis_hip";
   
    // PMA Bonding Mode used in Quartus
    //---------------------------------- 
    // xN Bonding with 1CMU/1LC is the officially supported version - uses 9 channels    
    localparam PMA_BONDING_MODE =  "xn";

    // Total Lanes
    // -----------
    // ======================
    // Gen 1/2 x8 (with HIP): 
    // ======================
    // Total Lanes = 9.
    //   Channels 0-3 and 5-8 are data channels.
    //   Channel 4 is a non-data channel (has the Master CGB in PMA and Master ASN block in PCS)
    //
    // ======================
    // Gen 3 x8 (with HIP):
    // ======================
    //  xN bonding (similar to Gen 2) - officially supported:
    //  Total Lanes = 9.
    //  Channels 0-3 and 5-8 are data channels.
    //  Channel 4 is a reserved channel (has the Master CGB in PMA and Master ASN block in PCS)
    //

    localparam TOTAL_LANES = (lanes == 8 && (hip_enable == "true" || reserved_channel == "true")) ?  lanes+1 : lanes;
    
    // CMU channel in HIP mode
    // -----------------------
    //1. x1 with hip   -> channel 1  (0       : data channel)
    //3. x2 with hip   -> channel 4  (0-1     : data channels)
    //3. x4 with hip   -> channel 4  (0-3     : data channels)
    //4. x8 with hip   -> channel 4  (0-3/5-8 : data channels. 4 - CMU channel + Master-only + ASN channel for bonding)
    
    localparam HIP_CMU_CHANNEL     =   (lanes == 8)? 4 :
                                       (lanes == 4)? 4 :
                                       (lanes == 2)? 4 :
                                       (lanes == 1)? 1 : -1;
 
    // Master channel in bonding mode
    // ------------------------------
    //   1. x1 with/without hip        -> channel 0
    //   2. x2 with/without hip        -> channel 1
    //   3. x4 with/without hip        -> channel 1
    //   4. x8 without hip             -> channel 0
    //   5. x8 with hip                -> channel 4 (reserved channel - master only channel)
    // PCS Bonding Master - PCS always has only one master (has the master ASN block)
    localparam BONDING_MASTER_CH = (master_ch_number != -1)? master_ch_number : 
                                   (lanes == 8)? (hip_enable == "true") ? 4 : 0 : 
                                   (lanes == 4)? 1 :
                                   (lanes == 2)? 1 :
                                   (lanes == 1)? 0 :	-1; 
    
     // PMA Bonding Master - PMA has one or more masters depending upon the bonding mode
     localparam PMA_BONDING_MASTER = (master_ch_number != -1)                                   ? int2str(master_ch_number) :
                                     ((lanes == 8) && (PMA_BONDING_MODE == "xn") )              ? (hip_enable == "true") ? "4" : "0" :
                                     (lanes == 4)                                               ? "1"      :
                                     (lanes == 2)                                               ? "1"      :
                                     (lanes == 1)                                               ? "0"      : "-1";
   
    // Indicates the lane indicated should be of type "MASTER_ONLY" (has the master CGB only. no ser/Rx PMA).
     localparam PMA_BONDING_MASTER_ONLY = ((hip_enable == "true" || reserved_channel == "true") && (lanes == 8) && (PMA_BONDING_MODE == "xn") )   //Gen3 and Gen2
                                                                                                ? "4"  : "-1";

    //********************************************
    // PMA local params
    //********************************************
    // For PCIe, PCS8G <-> PMA data width is always 10b for Gen1/2 capable and at Gen1/2 speed at Gen3 capable
    //           G3PCS <-> PMA data width is 32b for Gen3 capable
    localparam PCS8G_PMA_DW   = "ten_bit";
    // PMA Serialization Factor. If auto_negotiation=true (gen2/3 capable), PMA blocks dynamically configure the ser factor based on pcie_sw[1:0] and not based on this mode parameter.
    // For Gen 1, auto_negotiation=false and the ser factor is based on mode
    localparam PMA_MODE = 10;

    // PMA data rate - used as a parameter to the CDR model
    // For Gen2 and Gen3 capable configurations, the output date rate of the CDR model is set here as 5G. 
    // In the CDR, the static M counter value is set up for Gen2 data rate and it switches to a different M value dynamically when
    // the current speed is Gen3 (pcie_sw[1:0] = 10)
    localparam PMA_DATA_RATE = (protocol_version == "Gen 1") ? "2500000000 bps" : 
	                       ((protocol_version == "Gen 2") || (protocol_version == "Gen 3")) ? "5000000000 bps" :
                               "<invalid>"; 
   
    // PMA Auto Negotiation
    localparam PMA_AUTO_NEGOTIATION = (protocol_version == "Gen 1") ? "false" : 
	                              (protocol_version == "Gen 2") ? "true" : 
				      (protocol_version == "Gen 3") ? "true" :
				      "<invalid>"; 
    /* new parameter added to production silicon; pcie_rst either selects the rstn or pcs_rst_n as reset to PCIe
       Gen1-2 switch block in PCIe configurations
       Also, rcgb_cntl[3] needs to be set to 1 
       This will synchronize the counters when there is a speed change from Gen3 -> Gen1
       In all other cases (i.e.except PCIe) rstn will be used as reset; this comes from tx_analogreset
    */ 
`ifdef ALTERA_RESERVED_QIS_ES
      localparam CGB_CNTR_RESET    = "normal_reset";
      localparam RESET_SCHEME      = "non_reset_bonding_scheme";  
`else 
      localparam CGB_CNTR_RESET    = (hip_hard_reset == "enable" && (protocol_version == "Gen 2" || protocol_version == "Gen 3")) ? "pcie_reset" : "normal_reset";
      localparam RESET_SCHEME      = (protocol_version == "Gen 2" || protocol_version == "Gen 3") ? "reset_bonding_scheme" : "non_reset_bonding_scheme" ;
`endif

    //********************************************
    // PCS local params
    //********************************************
    // Rx byte deserializer
    // Enable PCS8G Rx Byte SERDES for:
    //    1. HIP mode (Gen1/2/3) needs 32-bit interface
    //    2. Gen3 capable configurations => deser_factor = 32
    localparam PCS8G_RX_BYTE_DESERIALIZER = ((hip_enable == "true") || (deser_factor == 32))? "en_bds_by_4" : 
	                                          ((deser_factor == 16) ? "en_bds_by_2" : "dis_bds");

    // low latency synchronous mode
    localparam RATE_MATCH_8G = (pipe_low_latency_syncronous_mode)? "pipe_rm_0ppm" : "pipe_rm";
    localparam RATE_MATCH_G3 = (pipe_low_latency_syncronous_mode)? "enable_rm_fifo_0ppm" : "enable_rm_fifo";
    localparam ENCODER_G3    = (pipe_low_latency_syncronous_mode && hip_enable == "true") ? "bypass_encoder" : "enable_encoder"; 
    localparam DECODER_G3    = (pipe_low_latency_syncronous_mode && hip_enable == "true") ? "bypass_decoder" : "enable_decoder"; 
    localparam TX_DC_BAL_G3  = ((pipe_low_latency_syncronous_mode && hip_enable == "true") || bypass_g3pcs_dcbal == 1 ) ? "tx_g3_dcbal_dis" : "tx_g3_dcbal_en"; 
    localparam RX_DC_BAL_G3  = "g3_dcbal_en"; // DC bal is for TX only; this is a redundant attribute, RBC allows only g3_dcbal_en
    
    // Lane number is the seed for scrambler/descrambler
    // Bypass the scrambler/descrambler based on the GUI parameter for soft PIPE
    // For HIP mode, scrambler/descrambler is bypassed; bypass_g3pcs_scrambler_descrambler == 1 by default and we pass the default "lane_0"   
    localparam TX_RX_LANE_NUM_IF_NOT_BYPASSED = (reserved_channel == "true") ? "lane_0,lane_1,lane_2,lane_3,lane_0,lane_4,lane_5,lane_6,lane_7" :
                                                (lanes == 8) ? "lane_0,lane_1,lane_2,lane_3,lane_4,lane_5,lane_6,lane_7" : 
                                                (lanes == 4) ? "lane_0,lane_1,lane_2,lane_3" : 
                                                (lanes == 2) ? "lane_0,lane_1" : 
                                                "lane_0" ;

    localparam TX_RX_LANE_NUM_IF_BYPASSED     = (reserved_channel == "true") ? "lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0" :
                                                (lanes == 8 && hip_enable == "true") ? "lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0" : 
                                                (lanes == 8 && hip_enable != "true") ? "lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0,lane_0" :
                                                (lanes == 4) ? "lane_0,lane_0,lane_0,lane_0" : 
                                                (lanes == 2) ? "lane_0,lane_0" : 
                                                "lane_0" ;


    localparam TX_RX_LANE_NUM = (!bypass_g3pcs_scrambler_descrambler) ? TX_RX_LANE_NUM_IF_NOT_BYPASSED : TX_RX_LANE_NUM_IF_BYPASSED; 

    // Rx electrical idle inference 
    // This feature has both param and port associated with it
    localparam ELEC_IDLE_INFER    = (pipe_elec_idle_infer_enable == "true") ? "en_eidle_iei" : "dis_eidle_iei";
    // Per ICD, enable elec idle entry by signal detection only when inference is enabled and for Gen1. The elec idle inference logic in PCS will look at both the idle data channel and the deassertion of SD from PMA to assert rx_elecidle. In Gen 2, SD from PMA is not reliable.
    localparam ELEC_IDLE_ENTRY_SD = (pipe_elec_idle_infer_enable == "true" && protocol_version == "Gen 1")? "en_eidle_sd" : "dis_eidle_sd";

    // PCS8G Phase Comp FIFO mode
    // HIP mode or Gen3 capable -> PC FIFO in  register mode
    localparam PCS8G_PC_FIFO = (hip_enable == "true") ? "register_fifo" : "low_latency"; // RBC says register mode only for HIP.
    localparam WR_CLK_SEL = (PCS8G_PC_FIFO == "register_fifo") ? "tx_clk" : "pld_tx_clk";

    // PIPE Interface Enable
    // Gen3 PIPE is used for HIP mode and Gen3 capable configurations
    localparam PCS8G_RX_PIPE_IF_ENABLE = ((hip_enable == "true") || (protocol_version == "Gen 3")) ? "en_pipe3_rx" : "en_pipe_rx";

    //RLV param
    //RLV is always enabled for ten_bit (en_runlength_sw), default to 6'b0 which is the max value (160)
    //otherwise run_length/5. possible setting: [160:5:5]
    localparam division        = (PCS8G_PMA_DW=="ten_bit")? 5 :
                                 (PCS8G_PMA_DW=="eight_bit")? 4 : 0;
    localparam RUN_LENGTH      = (pipe_run_length_violation_checking==0)? "invalid" :
                                 ((PCS8G_PMA_DW=="ten_bit")||(PCS8G_PMA_DW=="eight_bit"))? "en_runlength_sw" : "invalid";
    localparam       RUNLENGTH_MAX   = 160;
    localparam       RUNLENGTH_DIV   = pipe_run_length_violation_checking/division;
    localparam [5:0] RUNLENGTH_VALUE = (pipe_run_length_violation_checking==RUNLENGTH_MAX)? 6'b0:RUNLENGTH_DIV[5:0];

    // Tx byte serializer
    // Enable PCS8G Tx Byte SERDES for:
    //    1. HIP mode (Gen1/2/3) needs 32-bit interface
    //    2. Gen3 capable configurations => deser_factor = 32
    localparam PCS8G_TX_BYTE_SERIALIZER = ((hip_enable == "true") || (deser_factor == 32))? "en_bs_by_4" : 
	                                    ((deser_factor == 16) ? "en_bs_by_2" : 
					       "dis_bs");

    // Tx Compliance Controlled Disparity
    
    localparam PCS8G_TX_COMPL_CONTR_DISP = ((hip_enable == "true") || (protocol_version == "Gen 3")) ? "en_txcompliance_pipe3p0" : "en_txcompliance_pipe2p0"; 
				       
    // Gen1-2 PIPE Byte Deserializer Enable
    localparam PIPE12_BYTE_DESERIALIZER_EN = ((hip_enable == "true") || (protocol_version == "Gen 3")) ? "dont_care_bds" :(deser_factor == 16)? "en_bds_by_2" : "dis_bds";

                                      
    //Setting available for PCIE
    //Setting for disparity error reported code with RXStatus
    //RIND_ERROR_REPORTING = 1 and RINVALID_CODE_ERR_ONLY = 1 to decode disparity error with code 3b111 
    localparam IND_ERROR_REPORTING    = "dis_ind_error_reporting"; //Valid values: DIS_IND_ERROR_REPORTING|EN_IND_ERROR_REPORTING
    localparam INVALID_CODE_FLAG_ONLY = "dis_invalid_code_only"; //Valid values: DIS_INVALID_CODE_ONLY|EN_INVALID_CODE_ONLY

    //********************************************
    // PCS-PLD Interface local param 
    //********************************************
    // Com PCS PLD interface reset selection from either EMSIP or PLD source depending on whether Hard Reset Controller is used by the HIP.
    // If Hard Reset Controller is used in HIP mode, then EMSIP reset inputs are selected for PCS resets. Else, PLD reset inputs are selected.
    // Hard Reset Controller should be used by the HIP in autonomous(100ms config time) mode and CvPCIe mode. 
    localparam HRDRSTCTRL_EN_CFGUSR = (hip_enable == "true" && hip_hard_reset == "enable")? "hrst_en_cfgusr" : "hrst_dis_cfgusr";
    localparam HRDRSTCTRL_EN_CFG    = (hip_enable == "true")? "hrst_en_cfg" : "hrst_dis_cfg";
    
    //********************************************
    // Other local params 
    //********************************************
    localparam WORD_SIZE       = 8;

    localparam SER_WORDS       = deser_factor/WORD_SIZE;

     // Gen 1/Gen 2. 
     // HIP     x8                - 9 channels (8 + 1 reserved) + 1 PLL (HCLK PLL will be merged with Tx PLL)
     // HIP     x4                - 4 channels               + 1 PLL (HCLK PLL will be merged with Tx PLL)
     // HIP     x1                - 1 channel                + 1 PLL (HCLK PLL will be merged with Tx PLL)
     
     // Non-HIP x8                - 8 channels               + 1 PLL  (1 Tx PLL)
     // Non-HIP x4                - 4 channels               + 1 PLL  (1 Tx PLL)
     // Non-HIP x1                - 1 channel                + 1 PLL  (1 Tx PLL)
    
    // Gen 3 
    // HIP     x8  
    // xn                                        - 9 channels  (8 + 1 CMU/CGB only)           + 2 PLLs (HCLK PLL will be merged with Tx CMU PLL)
    // HIP     x4                                - 4 channels                                 + 2 PLLs (HCLK PLL will be merged with Tx CMU PLL)
    // HIP     x1                                - 1 channel                                  + 2 PLLs (HCLK PLL will be merged with Tx CMU PLL)
     localparam NUM_TX_PLLS        = (protocol_version == "Gen 3") ? 2 :  //Gen3 x8 with xN and Gen3 x1,x4
                                                                     1 ;  //Gen2,Gen1
     localparam W_BUNDLE_TO_XCVR   = W_S5_RECONFIG_BUNDLE_TO_XCVR;
     localparam W_BUNDLE_FROM_XCVR = W_S5_RECONFIG_BUNDLE_FROM_XCVR;


//******************************************************************
// RBC checks
//******************************************************************
initial /* synthesis enable_verilog_initial_construct */
begin
    if (hip_enable == "true" && deser_factor != 32)
        $display("Error: Parameter 'deser_factor' of instance '%m' has illegal value '%d' assigned to it when hip_enable = true.  Valid parameter value is: '%d'.", deser_factor, 32);

    if (protocol_version == "Gen 3" && deser_factor != 32)
        $display("Error: Parameter 'deser_factor' of instance '%m' has illegal value '%d' assigned to it when protocol_version = Gen 3.  Valid parameter value is: '%d'.", deser_factor, 32);
    
    if (BONDING_MASTER_CH == -1)
        $display("Error: Parameter 'lanes' of instance '%m' has illegal value '%d' assigned to it.  Valid parameter values are 1,2,4,8.", lanes);

    if (RUN_LENGTH == "invalid")
        $display("Error: Parameter 'pipe_run_length_violation_checking' of instance '%m' has illegal value '%d' assigned to it.  Valid parameter value is: [160:5:5].", pipe_run_length_violation_checking);
 
end

//******************************************************************
// Wire declarations
//******************************************************************
    // PLL wires
    wire  [NUM_TX_PLLS -1 : 0]  pll_out;
    wire  [NUM_TX_PLLS -1 : 0]  w_rst_to_tx_pll;
    wire  [NUM_TX_PLLS -1 : 0]  w_pll_locked;
    wire  [NUM_TX_PLLS -1 : 0]  w_pll_fb;
    wire  [NUM_TX_PLLS -1 : 0]  w_pll_hclk;
    
    // Tx PLL comp feedback ports into PLLs (NUN_TX_PLLS wide)     
    wire  [NUM_TX_PLLS -1 : 0]  w_pll_tx_pcie_fb_clk;
    wire  [NUM_TX_PLLS -1 : 0]  w_pll_tx_pll_fb_sw;

    // Tx PLL comp feedback ports from CGB (TOTAL_LANES wide)     
    wire  [TOTAL_LANES -1 : 0]  w_tx_pcie_fb_clk;
    wire  [TOTAL_LANES -1 : 0]  w_tx_pll_fb_sw;

    wire  [TOTAL_LANES -1 : 0]	tx_clkout_to_pld;

    // EMSIP inputs/outputs to/from PLD-PCS interface
    // TOTAL_LANES wide. For x8 HIP designs, TOTAL_LANES=9 or 11 depending on the bonding mode.
    // Bits for the master-only channels 4 or 4, 10 will be interleaved whereever necessary.
    wire [TOTAL_LANES*104     -1:0]	w_emsip_tx_in;
    wire [TOTAL_LANES*13      -1:0]	w_emsip_tx_special_in;
    wire [TOTAL_LANES*3       -1:0]	w_emsip_tx_clk_in;
    
    wire [TOTAL_LANES*20      -1:0]	w_emsip_rx_in;
    wire [TOTAL_LANES*13      -1:0]	w_emsip_rx_special_in;
    wire [TOTAL_LANES*3       -1:0]	w_emsip_rx_clk_in;
    
    wire [TOTAL_LANES*38      -1:0]	w_emsip_com_in;
    wire [TOTAL_LANES*20      -1:0]	w_emsip_com_special_in;

    wire [TOTAL_LANES*12      -1:0]	w_emsip_tx_out;
    wire [TOTAL_LANES*16      -1:0]	w_emsip_tx_special_out;
    wire [TOTAL_LANES*3       -1:0]	w_emsip_tx_clk_out;
    
    wire [TOTAL_LANES*129     -1:0]	w_emsip_rx_out;
    wire [TOTAL_LANES*16      -1:0]	w_emsip_rx_special_out;
    wire [TOTAL_LANES*3       -1:0]	w_emsip_rx_clk_out;
    
    wire [TOTAL_LANES*27      -1:0]	w_emsip_com_out;
    wire [TOTAL_LANES*20     -1:0]	w_emsip_com_special_out;
    wire [TOTAL_LANES*3      -1:0]	w_emsip_com_clk_out;
    

    // Wires that are connected from PLD to PCS (non-HIP designs)
    // Not yet adjusted for HIP x8 with master-only channel. lanes wide.
    tri0 [lanes*64     -1:0]	txdatain_from_pld;
    wire [lanes*2      -1:0]	pld8gpowerdown;
    wire [lanes*3      -1:0]	pld8gtxmargin;
    wire [lanes*3      -1:0]	pldeidleinfersel;
    wire [lanes        -1:0]	pld8gtxdetectrxloopback;
    wire [lanes        -1:0]	pld8gtxelecidle;
    wire [lanes        -1:0]	pld8gtxdeemph;
    wire [lanes        -1:0]  int_pipe_g3_txdeemph; 
    wire [lanes        -1:0]	pld8gtxswing;
    wire [lanes*2      -1:0]	pldrate;
    wire [lanes        -1:0]	pldtxinvpolarity;
    wire [lanes        -1:0]	pldltr;
    wire [lanes        -1:0]	pldrxanalogreset;
    wire [lanes        -1:0]	pldtxdigitalreset;
    wire [lanes        -1:0]	pldrxdigitalreset;
   
    // Gen3 specific 
    wire [lanes*4      -1:0]	pld8gtxblkstart;
    wire [lanes*4      -1:0]	pld8gtxdatavalid;
    wire [lanes*2      -1:0]	pld8gtxsynchdr;
    wire [lanes*18     -1:0]  pldgen3currentcoeff; 
    wire [lanes*3      -1:0]  pldgen3currentrxpreset;
    
    // Outputs to PLD adjusted for HIP x8 configuration
    // In HIP Gen1/2 x8, total_lanes=9.
    // In HIP Gen3 x8,   total_lanes=9 or 11 depending on the bonding scheme used.
    // To avoid Quartus warnings, declare the wires that connect to the output of PCS to be total_lanes wide.
    wire [TOTAL_LANES*64     -1:0]      rxdata_to_pld;
    wire [TOTAL_LANES        -1:0]      pld8gphystatus;
    wire [TOTAL_LANES        -1:0]      pld8grxvalid;
    wire [TOTAL_LANES        -1:0]      pld8grxpolarity;
    wire [TOTAL_LANES        -1:0]      pld8grxelecidle;
    wire [TOTAL_LANES        -1:0]      rx_pcfifoempty_to_pld;
    wire [TOTAL_LANES        -1:0]      rx_pcfifofull_to_pld;
    wire [TOTAL_LANES        -1:0]      tx_phfifounderflow_to_pld;
    wire [TOTAL_LANES        -1:0]      tx_phfifooverflow_to_pld;
    wire [TOTAL_LANES        -1:0]      rx_rlv_to_pld;
    wire [TOTAL_LANES*5      -1:0]	    rx_bitslipboundaryselectout_to_pld;
    wire [TOTAL_LANES        -1:0]  	  w_rx_signaldetect;

    // Intermediate wires for non-HIP configuration. These bits are part of the databus to PCS.
    wire [(lanes*SER_WORDS) -1:0] w_txcompliance_per_word; 
    wire [(lanes*SER_WORDS) -1:0] w_txelecidle_per_word;

  
    // PLD inputs to PCS/PMA adjusted for HIP x8 configuration
    // with reserved channel(s)
    reg [TOTAL_LANES    -1:0]	w_rx_analogreset;
    reg [TOTAL_LANES*64 -1:0]	w_pldtxdatain;
    reg [TOTAL_LANES    -1:0]	w_tx_invpolarity;
    reg [TOTAL_LANES    -1:0]	w_tx_digitalreset;
    reg [TOTAL_LANES    -1:0]	w_rx_digitalreset;

    reg [TOTAL_LANES    -1:0]	w_rx_set_locktoref;
    reg [TOTAL_LANES    -1:0]	w_pld8gtxelecidle;
    reg [TOTAL_LANES    -1:0]	w_pld8gtxdetectrxloopback;
    reg [TOTAL_LANES    -1:0]	w_pld8gtxdeemph;
    reg [TOTAL_LANES    -1:0]	w_pld8gtxswing;
    reg [TOTAL_LANES    -1:0]	w_pld8grxpolarity;
    reg [TOTAL_LANES*2  -1:0]	w_pldrate;
    reg [TOTAL_LANES*3  -1:0]	w_pld8gtxmargin;
    reg [TOTAL_LANES*3  -1:0]	w_pldeidleinfersel;
    reg [TOTAL_LANES*2  -1:0]	w_pld8gpowerdown;
    // PLD/Pin -> PMA
    wire [TOTAL_LANES  -1:0]	w_pinrxdatain;
    wire [TOTAL_LANES  -1:0]	w_pldseriallpbken; 
    wire [TOTAL_LANES  -1:0]	w_pldrxltd;       
    // PMA -> PLD/Pin
    wire [TOTAL_LANES  -1:0]	w_tx_dataout;
    wire [TOTAL_LANES  -1:0]  w_rx_is_lockedtoref;
    wire [TOTAL_LANES  -1:0]  w_rx_is_lockedtodata;
    
    // Gen3 specific 
    wire [TOTAL_LANES*4  -1:0]  w_pld8gtxblkstart;
    wire [TOTAL_LANES*4  -1:0]  pld8grxblkstart; 
    wire [TOTAL_LANES*4  -1:0]  w_pld8gtxdatavalid; 
    wire [TOTAL_LANES*4  -1:0]  pld8grxdatavalid;
    wire [TOTAL_LANES*2  -1:0]  w_pld8gtxsynchdr; 
    wire [TOTAL_LANES*2  -1:0]  pld8grxsynchdr; 
    wire [TOTAL_LANES*18 -1:0]  w_pldgen3currentcoeff;
    wire [TOTAL_LANES*3  -1:0]  w_pldgen3currentrxpreset; 

    wire [TOTAL_LANES*4  -1:0]  w_pld8grxblkstart; 
    wire [TOTAL_LANES*4  -1:0]  w_pld8grxdatavalid;
    wire [TOTAL_LANES*2  -1:0]  w_pld8grxsynchdr; 
    // This is the clock that is driving pldrxclk and coreclk inputs of the sv_8g_pcs block. There are two scenarios:
		
    // (1) HIP design -- txclkout from the master channel (sv_8g_pcs)
    // must drive into HIP blocks and no other connection [dedicated
    // PCS-EMSIP connections
		
    // (2) non-HIP design -- txclkout from the master channel
    // (sv_8g_pcs) must drive into the core (pipe_pclk) and also must
    // loop back into pldrxclk and coreclk inputs of the sv_8g_pcs
		
    wire  core_rx_clock_into_pcs   = (hip_enable == "true") ? 1'b0 : tx_clkout_to_pld[BONDING_MASTER_CH];
    
    // This is the reserved output from PCS; we are using bit[2] of every
    // channel to hook up to pcs_rst_n of CGB
    wire [TOTAL_LANES*5 - 1: 0] out_pma_reserved_out;
    wire [TOTAL_LANES   - 1: 0] pcs_rst_n;

    //****************************************************************************************************************
    //PIPE <-> EMSIP adapter for HIP designs and PIPE <-> PLD signals to PCS for non-HIP designs 					
    //****************************************************************************************************************
    generate
    //For HIP designs
    if (hip_enable == "true")
    begin				      
      wire [TOTAL_LANES  -1:0]	  w_rx_signaldetect_hip;
      wire [TOTAL_LANES  -1:0]    w_rxfreqtxcmuplllock;
      
      // Interleave CMU channel and connect pll_locked from TX PLL for that channel. 
      // For other data channels, conenct from the emsip adapter.

      genvar num_ch;
         for (num_ch=0; num_ch < lanes+1; num_ch = num_ch + 1) begin:ch
           if (num_ch == HIP_CMU_CHANNEL || (lanes == 2 && num_ch == lanes))
             assign rxfreqtxcmuplllock[HIP_CMU_CHANNEL] = w_pll_locked; 
           else
             assign rxfreqtxcmuplllock[num_ch]          = w_rxfreqtxcmuplllock[num_ch]; 
         end
 
      
      sv_xcvr_emsip_adapter #(
        .lanes          (lanes),  
        .total_lanes    (TOTAL_LANES),  
        .deser_factor   (deser_factor), //32 for PCIe HIP
        .word_size      (WORD_SIZE),
        .hip_hard_reset (hip_hard_reset)
      ) sv_xcvr_emsip_adapter_inst (
        //PIPE inputs
        .pipe_txdata                      (pipe_txdata                ),
        .pipe_txdatak                     (pipe_txdatak               ),
        .pipe_txcompliance                (pipe_txcompliance          ),
        .pipe_txelecidle                  (pipe_txelecidle            ),
        .pipe_rxpolarity                  (pipe_rxpolarity            ),
        .pipe_txdetectrx_loopback         (pipe_txdetectrx_loopback   ),
        .pipe_txswing                     (pipe_txswing               ),
        .pipe_txmargin                    (pipe_txmargin              ),
        .pipe_txdeemph                    (pipe_txdeemph              ),
        .pipe_rate                        (pipe_rate                  ),  
        .rate_ctrl                        (rate_ctrl                  ),  
        .pipe_powerdown                   (pipe_powerdown             ),
        .rx_eidleinfersel                 (rx_eidleinfersel           ),
        .pipe_tx_data_valid               (pipe_tx_data_valid         ), //PIPE 3.0 
        .pipe_tx_blk_start                (pipe_tx_blk_start          ), //PIPE 3.0 
        .pipe_tx_sync_hdr                 (pipe_tx_sync_hdr           ), //PIPE 3.0 
        
              //PIPE outputs
        .pipe_phystatus                   (pipe_phystatus             ),
        .pipe_rxdata                      (pipe_rxdata                ),
        .pipe_rxdatak                     (pipe_rxdatak               ),
        .pipe_rxvalid                     (pipe_rxvalid               ),
        .pipe_rxelecidle                  (pipe_rxelecidle            ),
        .pipe_rxstatus                    (pipe_rxstatus              ),
        .pipe_pclk                        (pipe_pclk                  ), //PCLK from ch 0
        .pipe_pclkch1                     (pipe_pclkch1               ), //PCLK from ch 1	 
        .pipe_pclkcentral                 (pipe_pclkcentral           ), //PCLK from ch 4
        .pllfixedclkch0                   (pllfixedclkch0             ), //HCLK from ch 0
        .pllfixedclkch1                   (pllfixedclkch1             ), //HCLK from ch 0
        .pllfixedclkcentral               (pllfixedclkcentral         ), //HCLk from ch 4 (Gen1/2), 4 or 10 (Gen3). Ch4 is chosen for Gen3.
        .pipe_rx_data_valid               (pipe_rx_data_valid         ), //PIPE 3.0 
        .pipe_rx_blk_start                (pipe_rx_blk_start          ), //PIPE 3.0 
        .pipe_rx_sync_hdr                 (pipe_rx_sync_hdr           ), //PIPE 3.0 
        
        .rx_set_locktoref                 (rx_set_locktoref           ),         
        .tx_invpolarity                   (tx_invpolarity             ),
        
               //Status outputs
        .rx_errdetect                     (rx_errdetect               ), 
        .rx_disperr                       (rx_disperr                 ),
        .rx_patterndetect                 (rx_patterndetect           ), 
        .rx_syncstatus                    (rx_syncstatus              ), 
        .rx_phase_comp_fifo_error         (rx_phase_comp_fifo_error   ),
        .tx_phase_comp_fifo_error         (tx_phase_comp_fifo_error   ),
        .rx_signaldetect                  (w_rx_signaldetect_hip      ), //EMSIP version is not sent out to HIP. PLD version is sent in both in HIP and non-HIP cases. 
        .rx_rlv                           (rx_rlv                     ),
        .rx_bitslipboundaryselectout      (rx_bitslipboundaryselectout),

        // Proprietary Coeff interface for Gen3 from HIP and Gen3 PCS
        .current_coeff                    (current_coeff              ),
        .current_rxpreset                 (current_rxpreset           ),

        // Inputs from HIP Hard Reset Controller 
        .offcalen                         (offcalen                   ), // Hard OC enable. connect only to the data channels.
        .txpcsrstn                        (txpcsrstn                  ), // For 8g tx pcs from HRC. connect only to the data channels.
        .rxpcsrstn                        (rxpcsrstn                  ), // For 8g rx pcs from HRC. connect only to the data channels. 
        .g3txpcsrstn                      (g3txpcsrstn                ), // For g3 tx pcs from HRC. connect only to the data channels.
        .g3rxpcsrstn                      (g3rxpcsrstn                ), // For g3 rx pcs from HRC. connect only to the data channels. 
        .rxpmarstb                        (rxpmarstb                  ), // For rx pma from HRC. connect only to the data channels.  
        .txpmasyncp                       (txpmasyncp                 ), // For Tx Master CGB counters. 
        
        // Outputs to HIP Hard Reset       Controller 
        .frefclk                          (frefclk                    ), // Divided reference clock from CDR. connect only from the data channels.
        .offcaldone                       (offcaldone                 ), // Hard OC done. connect only from the data channels. 
        //.masktxplllock                  (masktxplllock              ), //TODO for Gen3. HRC listens to this signal from the Gen3 PCS in the CMU channel???. PHY IP does not stamp out PCS for the CMU channel.
        .rxfreqtxcmuplllock               (w_rxfreqtxcmuplllock       ), //CDR lock to ref. connect only from the data channels.
        .rxpllphaselock                   (rxpllphaselock             ), //CDR lock to data. connect from the data channels.
	
        //EMSIP buses from PCS (TOTAL_LANES wide)
        .out_pcspldif_emsip_tx_in         (w_emsip_tx_in             ),
        .out_pcspldif_emsip_tx_special_in (w_emsip_tx_special_in     ),
        .out_pcspldif_emsip_tx_clk_in     (w_emsip_tx_clk_in         ),
        .out_pcspldif_emsip_rx_in         (w_emsip_rx_in             ),
        .out_pcspldif_emsip_rx_special_in (w_emsip_rx_special_in     ),
        .out_pcspldif_emsip_rx_clk_in     (w_emsip_rx_clk_in         ),
        .out_pcspldif_emsip_com_in        (w_emsip_com_in            ),
        .out_pcspldif_emsip_com_special_in(w_emsip_com_special_in    ),
        //EMSIP buses to PCS (TOTAL_LANES wide)
        .in_pcspldif_emsip_tx_out         (w_emsip_tx_out            ),
        .in_pcspldif_emsip_tx_special_out (w_emsip_tx_special_out    ),
        .in_pcspldif_emsip_tx_clk_out     (w_emsip_tx_clk_out        ),
        .in_pcspldif_emsip_rx_out         (w_emsip_rx_out            ),
        .in_pcspldif_emsip_rx_special_out (w_emsip_rx_special_out    ),
        .in_pcspldif_emsip_rx_clk_out     (w_emsip_rx_clk_out        ),
        .in_pcspldif_emsip_com_out        (w_emsip_com_out           ),
        .in_pcspldif_emsip_com_special_out(w_emsip_com_special_out   ),
        .in_pcspldif_emsip_com_clk_out    (w_emsip_com_clk_out       )
      );
       
       // Assign unused non-emsip PLD input signals to 0
       assign pldrate                 = {lanes{2'b0}};
       assign pld8gpowerdown          = {lanes{2'b0}};
       assign pld8gtxdetectrxloopback = {lanes{1'b0}};
       assign pld8gtxmargin           = {lanes{3'b0}};
       assign pldeidleinfersel        = {lanes{3'b0}};
       assign pld8gtxdeemph           = {lanes{1'b0}};
       assign pld8gtxswing            = {lanes{1'b0}};
       assign pld8grxpolarity         = {lanes{1'b0}};
       assign pld8gtxelecidle         = {lanes{1'b0}};
       assign pldtxinvpolarity        = {lanes{1'b0}};
       assign pldltr                  = {lanes{1'b0}};
       assign txdatain_from_pld       = {lanes*64{1'b0}};
       // Gen3 specific 
       assign pld8gtxblkstart         = {lanes{4'b0000}};  
       assign pld8gtxdatavalid        = {lanes{4'b0000}}; 
       assign pld8gtxsynchdr          = {lanes{2'b00}}; 
       assign pldgen3currentcoeff     = {lanes{18'h0}}; 
       assign pldgen3currentrxpreset  = {lanes{3'h0}};  

       // If Hard Reset Controller is not enabled, assign the reset inputs from HIP to PLD reset inputs to PCS-PLD interface 
       // If Hard Reset Controller is enabled, disable PLD resets. The reset inputs from HIP will be connected to 
       // emsip_tx_special_in and emsip_rx_special_in ports to PCS-PLD interface.
       assign pldrxanalogreset        = (hip_hard_reset == "enable") ? {lanes{1'b0}} : rx_analogreset;
       assign pldtxdigitalreset       = (hip_hard_reset == "enable") ? {lanes{1'b0}} : tx_digitalreset;
       assign pldrxdigitalreset       = (hip_hard_reset == "enable") ? {lanes{1'b0}} : rx_digitalreset;

    end //HIP designs
    // Non-HIP designs
    else begin
   
       sv_xcvr_data_adapter #(
          .lanes           (lanes),
          .ser_base_factor (WORD_SIZE),             //8 for PCIe
          .ser_words       (SER_WORDS),             //1 or 2 
	        .skip_word       ((protocol_version == "Gen 3") ? 1: 2)                      //8G PCS supports up to deser factor of 16
       ) sv_xcvr_data_adapter_inst ( 
          .tx_parallel_data      (pipe_txdata),
	        .tx_datak              (pipe_txdatak),
	        .tx_forcedisp          (w_txcompliance_per_word), //Bit 9 in the 11-bit bundle is txcompliance for PIPE. 
	        .tx_dispval            (w_txelecidle_per_word),   //Bit 10 in the 11-bit bundle is txelecidle for PIPE
	        .tx_datain_from_pld    (txdatain_from_pld),
	       // The only time lanes!= TOTAL_LANES is in the case of HIP x8 type of placement for PIPE. RTL simulations are agnostic to QSFs; so number of channels will be still 8 and only in post fit simulations, we observe 9 channels after the QSF kicks in. 
         // This is to avoid any sim warnings
          `ifdef ALTERA_RESERVED_QIS 
          .rx_dataout_to_pld     ((lanes != TOTAL_LANES && reserved_channel == "true") ? {rxdata_to_pld[575:320],rxdata_to_pld[255:0]} : rxdata_to_pld), //for x8 designs with reserved, ignore the rxdata on reserved ch.  
          `else 
          .rx_dataout_to_pld     (rxdata_to_pld),
          `endif 
	        .rx_parallel_data      (pipe_rxdata),
	        .rx_datak              (pipe_rxdatak),
	        .rx_errdetect          (rx_errdetect),
	        .rx_syncstatus         (rx_syncstatus),
	        .rx_disperr            (rx_disperr),
	        .rx_patterndetect      (rx_patterndetect),
	        .rx_rmfifodatainserted (),                 //Not used for PIPE
	        .rx_rmfifodatadeleted  (),                 //Not used for PIPE
	        .rx_runningdisp        (),                 //Not used for PIPE 
	        .rx_a1a2sizeout        ()                  //Not used for PIPE 
       );

       // Also , assign tx_compliance and tx_elecidle per word for the data adapter.
       // These inputs are 1-bit per lane. Bit 9 and 10 in the 11-bit bundle of data into PCS 
       // mean tx_forcedisp and tx_dispval for other protocols. For PIPE, these bits mean 
       // tx_compliance and tx_elecidle respectively. tx_forcedisp and tx_dispval are defined per 
       // lane and per word. So, in order for the data adapter to interleave the bits correctly per lane,
       //extend tx_compliance and tx_elecidle per lane for all the words in that lane.
       genvar num_ch;
       genvar num_word;
       for (num_ch=0; num_ch < lanes; num_ch = num_ch + 1) begin:channel
         for (num_word=0; num_word < SER_WORDS; num_word=num_word+1) begin:word
           assign w_txcompliance_per_word [SER_WORDS*num_ch+num_word] = pipe_txcompliance[num_ch];		 
           assign w_txelecidle_per_word   [SER_WORDS*num_ch+num_word] = pipe_txelecidle  [num_ch];		 
         end  
       end  

       assign pldrate                 = pipe_rate;
       assign pld8gpowerdown          = pipe_powerdown;
       assign pld8gtxdetectrxloopback = pipe_txdetectrx_loopback;
       assign pld8gtxmargin           = pipe_txmargin;
       assign pldeidleinfersel        = rx_eidleinfersel;

       assign pld8gtxswing            = pipe_txswing;
       assign pld8grxpolarity         = pipe_rxpolarity;
       assign pld8gtxelecidle         = pipe_txelecidle;

       assign pldtxinvpolarity        = tx_invpolarity;
       assign pldltr                  = rx_set_locktoref;

       assign pldrxanalogreset        = rx_analogreset;
       assign pldtxdigitalreset       = tx_digitalreset;
       assign pldrxdigitalreset       = rx_digitalreset;
	   
	   // we have one bit per lane for tx_data_valid and tx_blk_start on PIPE but there are 4 bits per lane on the PCS
	   // iterate only till lanes (and not TOTAL_LANES) since we extend the signal for x8 with reserved channel later
     
     // In Gen3 mode, 
     // pld8gtxddemph[0] = pipe_g3_txdeemph[0] 
     // pld8gtxddemph[1] = pipe_g3_txdeemph[18] 
     // pld8gtxddemph[2] = pipe_g3_txdeemph[36] and so on...  
       genvar i; 
       for (i=0;i<lanes; i=i+1) begin:gen3_tx_ports   
          assign pld8gtxdatavalid[(i*4) +: 4] = {4{pipe_tx_data_valid[i]}}; // Gen3 signal 
          assign pld8gtxblkstart[(i*4) +: 4]  = {4{pipe_tx_blk_start[i]}}; // Gen3 signal
          assign int_pipe_g3_txdeemph[i]      = pipe_g3_txdeemph[18*i]; // Gen3 signal
       end    
	 
       assign pld8gtxdeemph           = (protocol_version == "Gen 3" && hip_enable == "false") ?  int_pipe_g3_txdeemph : pipe_txdeemph;
       assign pld8gtxsynchdr          = pipe_tx_sync_hdr; 
      
       assign pldgen3currentcoeff     = pipe_g3_txdeemph; 
       assign pldgen3currentrxpreset  = pipe_rxpresethint;  

       assign w_emsip_tx_in	          = {TOTAL_LANES{104'b0}};
       assign w_emsip_tx_special_in   = {TOTAL_LANES{13'b0}};
       assign w_emsip_tx_clk_in	      = {TOTAL_LANES{3'b0}};
	    
       assign w_emsip_rx_in	          = {TOTAL_LANES{20'b0}};
       assign w_emsip_rx_special_in   = {TOTAL_LANES{13'b0}};
       assign w_emsip_rx_clk_in	      = {TOTAL_LANES{3'b0}};
	    
       assign w_emsip_com_in	        = {TOTAL_LANES{38'b0}};
       assign w_emsip_com_special_in  = {TOTAL_LANES{20'b0}};

       assign frefclk                 = {lanes{1'b0}}; // not used when not using HIP
       assign offcaldone              = {lanes{1'b0}}; // not used when not using HIP
       //assign masktxplllock           = {lanes{1'b0}}; // not used when not using HIP
       //assign txlcplllock             = {lanes{1'b0}}; // not used when not using HIP
       assign rxfreqtxcmuplllock      = {lanes{1'b0}}; // not used when not using HIP
       assign rxpllphaselock          = {lanes{1'b0}}; // not used when not using HIP
       assign pipe_pclk               = tx_clkout_to_pld[BONDING_MASTER_CH]; // just use ch0 as pclk when not using HIP
       assign pipe_pclkch1            = 1'b0; // not used when not using HIP
       assign pipe_pclkcentral        = 1'b0; // not used when not using HIP
       assign pllfixedclkch0          = 1'b0; // not used when not using HIP
       assign pllfixedclkch1          = 1'b0; // not used when not using HIP
       assign pllfixedclkcentral      = 1'b0; // not used when not using HIP
   
    // Adjust the outputs depending on whether a reserved channel is present or not. 
      if (lanes == TOTAL_LANES) // no reserved ch; all cases except the special PIPE x8 that mimics HIP x8 placement 
      begin 
        assign pipe_phystatus                  = pld8gphystatus;
        assign pipe_rxstatus                   = pld8grxstatus;
        assign pipe_rxvalid                    = pld8grxvalid;
        assign pipe_rxelecidle                 = pld8grxelecidle;
        assign rx_phase_comp_fifo_error	       = rx_pcfifoempty_to_pld | rx_pcfifofull_to_pld;
        assign tx_phase_comp_fifo_error	       = tx_phfifooverflow_to_pld | tx_phfifounderflow_to_pld;
        assign rx_rlv                          = rx_rlv_to_pld;
        assign rx_bitslipboundaryselectout     = rx_bitslipboundaryselectout_to_pld;

        // per lane we have 4 bits of rx_data_valid coming from the pcs, but it is a single bit/lane on the PIPE interface
        genvar j; 
        for (j=0;j<lanes; j=j+1) begin:gen3_rx_ports 
           assign pipe_rx_data_valid[j]        = pld8grxdatavalid[j*4];  // Gen3 signal 
           assign pipe_rx_blk_start [j]        = pld8grxblkstart[j*4];  // Gen3 signal: indicates the start block for a 128/130b rx data 
        end 
        assign pipe_rx_sync_hdr                = pld8grxsynchdr;   // Gen3 signal 
      end
      
      else // to account for PIPE x8 placement similar to HIP x8  
      begin 
        assign pipe_phystatus                  = {pld8gphystatus[8:5],pld8gphystatus[3:0]};
        assign pipe_rxstatus                   = {pld8grxstatus[26:15],pld8grxstatus[11:0]} ;
        assign pipe_rxvalid                    = {pld8grxvalid[8:5],pld8grxvalid[3:0]};
        assign pipe_rxelecidle                 = {pld8grxelecidle[8:5],pld8grxelecidle[3:0]};
        assign rx_phase_comp_fifo_error	       = {(rx_pcfifoempty_to_pld[8:5] | rx_pcfifofull_to_pld[8:5]),(rx_pcfifoempty_to_pld[3:0] | rx_pcfifofull_to_pld[3:0])};
        assign tx_phase_comp_fifo_error	       = {(tx_phfifooverflow_to_pld[8:5] | tx_phfifounderflow_to_pld[8:5]), (tx_phfifooverflow_to_pld[3:0] | tx_phfifounderflow_to_pld[3:0])};
        assign rx_rlv                          = {rx_rlv_to_pld[8:5],rx_rlv_to_pld[3:0]};
        assign rx_bitslipboundaryselectout     = {rx_bitslipboundaryselectout_to_pld[44:25],rx_bitslipboundaryselectout_to_pld[19:0]};
        
        // per lane we have 4 bits of rx_data_valid coming from the pcs, but it is a single bit/lane on the PIPE interface
        genvar j; 
        for (j=0;j<TOTAL_LANES; j=j+1) begin:gen3_rx_ports 
           assign w_pld8grxdatavalid[j]        = pld8grxdatavalid[j*4];  // Gen3 signal 
           assign w_pld8grxblkstart[j]         = pld8grxblkstart[j*4];  // Gen3 signal: indicates the start block for a 128/130b rx data 
        end 
        
        assign pipe_rx_data_valid              = {w_pld8grxdatavalid[8:5],w_pld8grxdatavalid[3:0]}; // Gen3 signal
        assign pipe_rx_blk_start               = {w_pld8grxblkstart[8:5],w_pld8grxblkstart[3:0]}; // Gen3 signal
        assign pipe_rx_sync_hdr                = {pld8grxsynchdr[17:10],pld8grxsynchdr[7:0]} ;   // Gen3 signal 
      end
    end //if soft PIPE
    endgenerate
    
    // Extend the width for signals to PCS to be equal to TOTAL_LANES for x8 HIP designs 
    // For x8 HIP designs, an extra channel(s) are instantiated for control plane bonding and ASN
    // Connect the control, reset and clock signal of the reserved channels from the same source as CH0
    // Other signals for reserved channels are tied to LOW

    //For resets, connect up the resets from HIP to PLD reset inputs to PCS-PLD Interface (in_pld_*) 
    //when Hard Reset Controller is not enabled in HIP mode or during non-HIP mode.
    //When Hard Reset Controller is enabled, disable PLD reset inputs.
    generate
    //================================================================
    // For all designs except x8 HIP  
    //================================================================
    if (lanes == TOTAL_LANES)
    begin
      assign w_rx_analogreset                = pldrxanalogreset;
      assign w_tx_digitalreset               = pldtxdigitalreset;
      assign w_rx_digitalreset               = pldrxdigitalreset;
      assign w_tx_invpolarity                = pldtxinvpolarity;
      assign w_rx_set_locktoref              = pldltr;
      assign w_pld8gtxelecidle               = pld8gtxelecidle;
      assign w_pld8gtxdetectrxloopback       = pld8gtxdetectrxloopback;
      assign w_pld8gtxdeemph                 = pld8gtxdeemph;
      assign w_pld8gtxswing                  = pld8gtxswing;
      assign w_pld8grxpolarity               = pld8grxpolarity;
      assign w_pldrate                       = pldrate;
      assign w_pld8gtxmargin                 = pld8gtxmargin;
      assign w_pldeidleinfersel              = pldeidleinfersel;
      assign w_pld8gpowerdown                = pld8gpowerdown;
      assign w_pldtxdatain                   = txdatain_from_pld;
      // PLD -> PMA inputs
      assign w_pinrxdatain                   = rx_serial_data;
      assign w_pldseriallpbken               = rx_seriallpbken;
      assign w_pldrxltd                      = rx_set_locktodata;
      // PMA -> PLD outputs
      assign tx_serial_data                  = w_tx_dataout;
      assign rx_is_lockedtoref               = w_rx_is_lockedtoref;
      assign rx_is_lockedtodata              = w_rx_is_lockedtodata;
      assign rx_signaldetect                 = w_rx_signaldetect;
      // Gen 3 specific  
      assign w_pld8gtxblkstart               = pld8gtxblkstart;
      assign w_pld8gtxdatavalid              = pld8gtxdatavalid; 
      assign w_pld8gtxsynchdr                = pld8gtxsynchdr;
      assign w_pldgen3currentcoeff           = pldgen3currentcoeff;
      assign w_pldgen3currentrxpreset        = pldgen3currentrxpreset;

    end
   
    //=================================================================================
    // For Gen2 (xN) and Gen3 x8 (xN or Tx PLL Comp Fb with 4LCs) => TOTAL_LANES = 9. 
    // Interleave channel 4.
    //=================================================================================
    else 
    begin
      // Do not connect Rx PMA RSTB (analogreset) for the reserved channel
      assign w_rx_analogreset[8:5]           = pldrxanalogreset [7:4];
      assign w_rx_analogreset[4]             = 1'b0;
      assign w_rx_analogreset[3:0]           = pldrxanalogreset [3:0];

      assign w_tx_digitalreset               = {pldtxdigitalreset[7:4],pldtxdigitalreset[0],pldtxdigitalreset[3:0]};
      assign w_rx_digitalreset               = {pldrxdigitalreset[7:4],pldrxdigitalreset[0],pldrxdigitalreset[3:0]};
      assign w_tx_invpolarity                = {pldtxinvpolarity       [7:4],   1'b0,pldtxinvpolarity        [3:0]};
      assign w_rx_set_locktoref              = {pldltr                 [7:4],   1'b0,pldltr                  [3:0]};
      assign w_pld8gtxelecidle               = {pld8gtxelecidle        [7:4],   1'b0,pld8gtxelecidle         [3:0]};
      assign w_pld8gtxdetectrxloopback       = {pld8gtxdetectrxloopback[7:4],   1'b0,pld8gtxdetectrxloopback [3:0]};
      assign w_pld8gtxdeemph                 = {pld8gtxdeemph          [7:4],   1'b0,pld8gtxdeemph           [3:0]};
      assign w_pld8gtxswing                  = {pld8gtxswing           [7:4],   1'b0,pld8gtxswing            [3:0]};
      assign w_pld8grxpolarity               = {pld8grxpolarity        [7:4],   1'b0,pld8grxpolarity         [3:0]};
      assign w_pldrate                       = {pldrate          [8*2-1:4*2],pldrate[1:0],pldrate         [4*2-1:0]};
      assign w_pld8gtxmargin                 = {pld8gtxmargin    [8*3-1:4*3],   3'b0,pld8gtxmargin       [4*3-1:0]};
      assign w_pldeidleinfersel              = {pldeidleinfersel [8*3-1:4*3],   3'b0,pldeidleinfersel    [4*3-1:0]};
      assign w_pld8gpowerdown                = {pld8gpowerdown   [8*2-1:4*2],   2'b0,pld8gpowerdown      [4*2-1:0]};
      assign w_pldtxdatain                   = {txdatain_from_pld[8*64-1:4*64],64'b0,txdatain_from_pld  [4*64-1:0]};
      // Gen3  specific 
      assign w_pld8gtxblkstart               = {pld8gtxblkstart  [8*4-1:4*4],   4'b0,pld8gtxblkstart     [4*4-1:0]};
      assign w_pld8gtxdatavalid              = {pld8gtxdatavalid [8*4-1:4*4],   4'b0,pld8gtxdatavalid    [4*4-1:0]};
      assign w_pld8gtxsynchdr                = {pld8gtxsynchdr   [8*2-1:4*2],   2'b0,pld8gtxsynchdr      [4*2-1:0]};
      assign w_pldgen3currentcoeff           = {pldgen3currentcoeff[8*18-1:4*18],18'b0,pldgen3currentcoeff[4*18-1:0]};
      assign w_pldgen3currentrxpreset        = {pldgen3currentrxpreset[8*3-1:4*3],3'b0,pldgen3currentrxpreset[4*3-1:0]};
      // PLD -> PMA inputs
      assign w_pinrxdatain                   = {rx_serial_data[7:4],1'b0,rx_serial_data[3:0]};
      assign w_pldseriallpbken               = {rx_seriallpbken[7:4],1'b0,rx_seriallpbken[3:0]};
      assign w_pldrxltd                      = {rx_set_locktodata[7:4],1'b0,rx_set_locktodata[3:0]};
      // PMA -> PLD outputs: interleave channel 4
      assign tx_serial_data                  = {w_tx_dataout[8:5],w_tx_dataout[3:0]};
      assign rx_is_lockedtoref               = {w_rx_is_lockedtoref[8:5],w_rx_is_lockedtoref[3:0]};
      assign rx_is_lockedtodata              = {w_rx_is_lockedtodata[8:5],w_rx_is_lockedtodata[3:0]};
      assign rx_signaldetect                 = {w_rx_signaldetect[8:5],w_rx_signaldetect[3:0]};

    end
endgenerate
	        		
    //*****************************************************************************************************************
    //
    // sv_xcvr_plls - instantiate Tx PLL(s)
    //
    //*****************************************************************************************************************
    // Indices definition of the PLLs: 
    // Gen1/2:
    //    0 -> CMU PLL
    // Gen3 (x1,x4 and x8 with xN bonding): 2 PLLs (1 CMU, 1 LC)
    //    0 ->  Gen1/2 CMU PLL
    //    1 ->  Gen3   LC PLL
    
    //************************************************
    // Reset for the Tx PLLs
    //************************************************
    // Connect either the active-high pll_powerdown from core to PLL rst for all cases except the HIP with Hard reset controller. 
    // Connect the active-low rxpmarstb input for the CMU channel from the HIP in the hard reset controller mode. 
    // Both the above signals get connected to rx_pma_rstb port of the CMU or the channel PLL (whether it is a CMU channel or a regular Rx channel respectively)
    // Connect to index of CMU PLL (see index definition above) 
    assign w_rst_to_tx_pll[0] = (hip_enable == "true" && hip_hard_reset == "enable") ? ~rxpmarstb[HIP_CMU_CHANNEL] : pll_powerdown;
    
    // Connect to the index of LC PLL for Gen3 (see index definition below)
    generate
      if (protocol_version == "Gen 3")
        //assign w_rst_to_tx_pll[1] = (hip_hard_reset == "enable") ? ~txlcpllrstb[/*TODO*/] : pll_powerdown; //TODO for HRC
        assign w_rst_to_tx_pll[1] = pll_powerdown;
    endgenerate
    
    //*********************************************************
    // Tx PLL Comp Feedback ports for the Tx PLLs from the CGB
    //*********************************************************
    // Make the connection only for Gen3 x8 with Tx PLL Comp Fb. Tie-off to 0 for other configurations. 
    //Tie-off the ports to '0' for other configurations. 
    assign w_pll_tx_pcie_fb_clk    = {NUM_TX_PLLS{1'b0}};
    assign w_pll_tx_pll_fb_sw      = {NUM_TX_PLLS{1'b0}};
      
    //************************************************
    // Parameters for sv_xcvr_plls
    //************************************************
    // Set DATA_RATE based on protocol version
    localparam DATA_RATE = (protocol_version == "Gen 1") ? "2500 Mbps" :
                           (protocol_version == "Gen 2") ? "5000 Mbps" :
                           (protocol_version == "Gen 3") ? "8000 Mbps" : "<invalid>";

    // Default base data rate to data rate if not specified
    localparam [MAX_STRS*MAX_CHARS*8-1:0] INT_BASE_DATA_RATE = (get_value_at_index(0, base_data_rate) == "0 Mbps") ? DATA_RATE : base_data_rate;

    // Final output clock datarate string for sv_xcvr_plls
    localparam FNL_BASE_DATA_RATE = (protocol_version == "Gen 3" && hip_enable == "true") ? "5000 Mhz,8000 Mhz" : INT_BASE_DATA_RATE;
    
    // Construct the pll_type parameter for sv_xcvr_plls
    localparam FNL_PLL_TYPE = (protocol_version == "Gen 3") && ((pll_type == "CMU") || (pll_type == "AUTO")) ? "CMU,ATX" :
                              (protocol_version == "Gen 3") && (pll_type == "ATX")                           ? "ATX,ATX" :
                               pll_type;

    localparam HCLK_DRIVER = (protocol_version == "Gen 3"                               )  ? "1,0" :
                             (protocol_version == "Gen 1" || protocol_version == "Gen 2")  ? "1"   : "0" ; 

    //************************************************
    // tx_clkdiv parameter for Tx CGB
    //************************************************
    // Assign Tx_CLK_DIV to 1 for Gen3. 
    localparam pll_select = 0;   
    localparam INT_TX_CLK_DIV = (protocol_version == "Gen 1" || protocol_version == "Gen 2") ? str2hz(get_value_at_index(pll_select, INT_BASE_DATA_RATE)) / str2hz(DATA_RATE) : 1;

    localparam FNL_HCLK_DRIVER = (hip_enable == "true" || protocol_version == "Gen 3") ? HCLK_DRIVER : "0"; // Gen3 ASN block requires HCLK to operate   
    //************************************************
    // Instantiate sv_xcvr_plls for Tx PLLs
    //************************************************
    sv_xcvr_plls #(
        .plls                     (NUM_TX_PLLS                                           ), 
        .pll_type                 (FNL_PLL_TYPE                                          ), 
        .reference_clock_frequency(pll_refclk_freq                                       ),
        .output_clock_datarate    (FNL_BASE_DATA_RATE                                    ),
        .refclks                  (1                                                     ),
        .enable_avmm              (0                                                     ),  //TODO temporary
        .enable_hclk              (FNL_HCLK_DRIVER                                       )  
    ) sv_xcvr_tx_plls_inst (
        .refclk                   (pll_ref_clk                                           ),
        .rst                      (w_rst_to_tx_pll                                       ),
        .fbclk                    (w_pll_fb                                              ),
        .fboutclk                 (w_pll_fb                                              ),
        .outclk                   (pll_out                                               ), //High freq serial clock
        .hclk                     (w_pll_hclk                                            ), //HIP clock: Gen1 = 250MHz, Gen2/3=500MHz
        .locked                   (w_pll_locked                                          ),
        // TODO: Add pcie_fb_clk and pll_fb_sw
        // avalon MM native reconfiguration interfaces //TODO
        .reconfig_to_xcvr         (reconfig_to_xcvr  [(TOTAL_LANES)*W_BUNDLE_TO_XCVR+:NUM_TX_PLLS*W_BUNDLE_TO_XCVR]     ),
        .reconfig_from_xcvr       (reconfig_from_xcvr[(TOTAL_LANES)*W_BUNDLE_FROM_XCVR+:NUM_TX_PLLS*W_BUNDLE_FROM_XCVR] ),

        .pll_fb_sw(/*unused*/) 
    );
    // NOTE: In case of Gen1/2 capable configurations, plls=1 and w_pll_hclk from this PLL is connected to the PCS
    //       In case of Gen3 capable configurations, plls=2 (xN bonding) and w_pll_hclk from the Gen1/2 PLL is connected to the PCS => w_pll_hclk[0]

    //************************************************
    // Assign pll_locked output
    //************************************************
    // For Gen1/2 capable, pll_locked comes from the CMU PLL
    // For Gen3 capable, AND the locked signals from the all the PLLs to form the pll_locked output 
    generate
      if (protocol_version == "Gen 3") //Gen3 x1,x4 and x8(xN)
        assign pll_locked = w_pll_locked[0] & w_pll_locked[1];
      else
        assign pll_locked = w_pll_locked[0];
    endgenerate

    //*****************************************************************************************************************
    // Instantiate sv_xcvr_native 
    //*****************************************************************************************************************
sv_xcvr_native
#(
	//*********************************************
	// PMA parameters
	//*********************************************
	.rx_enable                     (1),                       // (1,0) Enable or disable reciever PMA
	.tx_enable                     (1),                       // (1,0) Enable or disable transmitter PMA
	.bonded_lanes                  (TOTAL_LANES),             // Number of bonded lanes 
	.pma_bonding_master            (PMA_BONDING_MASTER),      // Indicates which channel is master 
//.pma_bonding_type              ((hip_enable == "true") ? "old_xN" : "default"), // Indicates which PMA bonding method to use
  .pma_bonding_type              ("old_xN"),                // Indicates which PMA bonding method to use
	.bonding_master_only           (PMA_BONDING_MASTER_ONLY), // Indicates bonding_master_channel is MASTER_ONLY
	.pma_prot_mode                 (PROT_MODE),               // (basic,cpri,cpri_rx_tx,disabled_prot_mode,gige,
	.plls                          (NUM_TX_PLLS),             // (1+) Number of high-speed serial clocks from TX plls (tx_ser_clk)
	.pll_sel                       (0),                       // (0 - plls-1) //Which PLL clock to use. For most cases, use 0 (CMU PLL). Gen3 CMU/LC switch is handled in sv_tx_pma_ch.sv
	.pma_mode                      (PMA_MODE),                // (8,10,16,20,32,40,64,80) Serialization factor
  .pma_data_rate                 (PMA_DATA_RATE),           // Serial data rate in bits-per-second
  .cdr_reference_clock_frequency (pll_refclk_freq),
	.auto_negotiation              (PMA_AUTO_NEGOTIATION),    // ("true","false") PCIe Auto-Negotiation (Gen1,2,3)
  .cgb_sync                      ("pcs_sync_rst"),          // ("normal", "pcs_sync_rst"). Set the value for Master and slave channels
  .pll_feedback                  ("non_pll_feedback"),      //Set the value for Master channel. Slave channel value is derived ins sv_tx_pma.sv.
  .pcie_rst                      (CGB_CNTR_RESET),          // "normal_reset", "pcie_reset", PMA/PCS reset to CGB counters 
  .pcie_g3_x8                    ((protocol_version == "Gen 3") ? "pcie_g3_x8" : "non_pcie_g3_x8"),  //Set the value for Master channel. Slave channel value is derived ins sv_tx_pma_ch.sv.
	.tx_clk_div                    (INT_TX_CLK_DIV),          // CGB clock divider values. 1, 2, 4, or 8.
  .in_cvp_mode                   (in_cvp_mode),             //legal values: not_in_cvp_mode, in_cvp_mode
  .hip_hard_reset                (hip_hard_reset),          // legal values: enable, disable
  .reset_scheme                  (RESET_SCHEME),            // legal values: reset_bonding_scheme, non_reset_bonding_scheme
	
  //******************************************************
  // CvP IOCSR Control 
  // Setting a virtual parameter on CDR atom in CvP mode
  // The PCS PMA registers listen to IOCSR in CvP update
  // This is required for the cvp_update to work reliably
  
  // in_cvp_mode is set to "in_cvp_mode" only in Gen1 HRC 
  // CVP or Gen2 HRC CVP designs. 
  //******************************************************
  .cvp_en_iocsr                ((in_cvp_mode == "in_cvp_mode") ? "true" : "false"),   

	//*********************************************
	// PCS parameters
	//*********************************************
  .bonding_master_ch   (BONDING_MASTER_CH),
	.enable_10g_rx       ("false"),
	.enable_10g_tx       ("false"),
	.enable_8g_rx        ("true"), //Always enabled for Gen1/2/3 
	.enable_8g_tx        ("true"), //Always enabled for Gen1/2/3
	.enable_dyn_reconfig ("false"),  
	.enable_gen12_pipe   ("true"), //Always enabled for Gen1/2/3 for PMA coefficient transfer when the link rate is Gen 1/2. Pipe functionality is done by Gen 3 PIPE.
  //HIP needs 32-bit PIPE interface available in Gen3 PIPE. 
	.enable_gen3_pipe    (((protocol_version == "Gen 3") || (hip_enable == "true")) ? "true" : "false"),	
	.enable_gen3_rx      ((protocol_version == "Gen 3") ? "true" : "false"),	
	.enable_gen3_tx      ((protocol_version == "Gen 3") ? "true" : "false"),	

	//*********************************************
	// Parameters for stratixv_hssi_8g_rx_pcs
	//*********************************************
	.pcs8g_rx_bit_reversal			("dis_bit_reversal"), // dis_bit_reversal|en_bit_reversal //RBC = dis_bit_reversal
	.pcs8g_rx_byte_deserializer 		(PCS8G_RX_BYTE_DESERIALIZER), // dis_bds|en_bds_by_2|en_bds_by_4|en_bds_by_2_det
	
	.pcs8g_rx_cdr_ctrl          		("en_cdr_ctrl_w_cid"), // dis_cdr_ctrl|en_cdr_ctrl|en_cdr_ctrl_w_cid 
	.pcs8g_rx_cdr_ctrl_rxvalid_mask 	("en_rxvalid_mask"),   // dis_rxvalid_mask|en_rxvalid_mask
	
  // The following 3 attributes enable detection of elec idle due to one or more of the following 3 reasons:
  // Reception of EIOS, Elec Idle Inference, Deassertion of Signal Detect from PMA						       
	.pcs8g_rx_eidle_entry_eios 		("en_eidle_eios"), // dis_eidle_eios|en_eidle_eios 
	.pcs8g_rx_eidle_entry_iei 		(ELEC_IDLE_INFER), // dis_eidle_iei|en_eidle_iei
	.pcs8g_rx_eidle_entry_sd 		(ELEC_IDLE_ENTRY_SD), // dis_eidle_sd|en_eidle_sd 
	
	.pcs8g_rx_hip_mode 			(HIP_MODE),        // dis_hip|en_hip
  .pcs8g_rx_invalid_code_flag_only ("dis_invalid_code_only"), //dis_invalid_code_only|en_invalid_code_only
	.pcs8g_rx_mask_cnt 			(10'd800),         // default = 10'h3FF
	.pcs8g_rx_phase_compensation_fifo 	(PCS8G_PC_FIFO), // low_latency|normal_latency|register_fifo|pld_ctrl_low_latency|pld_ctrl_normal_latency	 

	.pcs8g_rx_pipe_if_enable 		(PCS8G_RX_PIPE_IF_ENABLE), 	// dis_pipe_rx|en_pipe_rx|en_pipe3_rx
	.pcs8g_rx_pma_done_count 		(18'd175000), 	                // Based on characterization		 
	.pcs8g_rx_pma_dw 			(PCS8G_PMA_DW), 		// eight_bit|ten_bit|sixteen_bit|twenty_bit
	
	.pcs8g_rx_prot_mode 			(PROT_MODE), 			// pipe_g1|pipe_g2|pipe_g3|
	.pcs8g_rx_rate_match 			(RATE_MATCH_8G), 			// dis_rm|xaui_rm|gige_rm|pipe_rm|pipe_rm_0ppm|sw_basic_rm|
	
	.pcs8g_rx_runlength_check 		(RUN_LENGTH), 			// dis_runlength|en_runlength_sw|en_runlength_dw
	.pcs8g_rx_runlength_val 		(RUNLENGTH_VALUE),

	.pcs8g_rx_rx_rd_clk 			((hip_enable == "true") ? "rx_clk" : "pld_rx_clk"), // pld_rx_clk|rx_clk
	.pcs8g_rx_rx_wr_clk 			((hip_enable == "true" || protocol_version == "Gen 3") ? "txfifo_rd_clk" : "rx_clk2_div_1_2_4"), // rx_clk2_div_1_2_4|txfifo_rd_clk

  .pcs8g_rx_wa_boundary_lock_ctrl 	("sync_sm"), 	   // bit_slip|sync_sm|deterministic_latency|auto_align_pld_ctrl
	.pcs8g_rx_wa_pd 			("wa_pd_fixed_10_k28p5"), // RBC = wa_pd_fixed_10_k28p5
	.pcs8g_rx_wa_pd_data 			(40'hBC),
	.pcs8g_rx_wa_pld_controlled 		("dis_pld_ctrl"), // dis_pld_ctrl|pld_ctrl_sw|rising_edge_sensitive_dw|level_sensitive_dw. RBC=dis_pld_ctrl

	.pcs8g_rx_wa_sync_sm_ctrl 		("pipe_sync_sm"), 
	.pcs8g_rx_wait_cnt 			(8'b00111111),
	.pcs8g_rx_sup_mode			("user_mode"),

	//*********************************************
  // parameters for stratixv_hssi_8g_tx_pcs
	//*********************************************
	.pcs8g_tx_bit_reversal 			("dis_bit_reversal"), // dis_bit_reversal|en_bit_reversal
	.pcs8g_tx_byte_serializer 		(PCS8G_TX_BYTE_SERIALIZER), // dis_bs|en_bs_by_2|en_bs_by_4
	.pcs8g_tx_eightb_tenb_disp_ctrl 	("en_disp_ctrl"),   // dis_disp_ctrl|en_disp_ctrl|en_ib_disp_ctrl
	.pcs8g_tx_eightb_tenb_encoder 		("en_8b10b_ibm"),   // dis_8b10b|en_8b10b_ibm|en_8b10b_sgx
	.pcs8g_tx_hip_mode 			(HIP_MODE), 	    // dis_hip|en_hip
	.pcs8g_tx_pcs_bypass 			("dis_pcs_bypass"), // dis_pcs_bypass|en_pcs_bypass
	.pcs8g_tx_phase_compensation_fifo 	(PCS8G_PC_FIFO),    // low_latency|normal_latency|register_fifo|pld_ctrl_low_latency|pld_ctrl_normal_latency
	.pcs8g_tx_phfifo_write_clk_sel 		(WR_CLK_SEL),     // pld_tx_clk|tx_clk
	.pcs8g_tx_pma_dw 			(PCS8G_PMA_DW),	    // eight_bit|ten_bit|sixteen_bit|twenty_bit
	.pcs8g_tx_polarity_inversion 		("dis_polinv"),     // dis_polinv|enable_polinv
	.pcs8g_tx_prbs_gen 			("dis_prbs"), 
	.pcs8g_tx_prot_mode 			(PROT_MODE),        // pipe_g1|pipe_g2|pipe_g3|cpri|cpri_rx_tx|gige|xaui|srio_2p1|test|basic|disabled_prot_mode
	.pcs8g_tx_symbol_swap 			("dis_symbol_swap"),// dis_symbol_swap|en_symbol_swap
	.pcs8g_tx_test_mode 			("dont_care_test"), // dont_care_test|prbs|bist
	.pcs8g_tx_tx_bitslip 			("dis_tx_bitslip"), // dis_tx_bitslip|en_tx_bitslip
	.pcs8g_tx_tx_compliance_controlled_disparity (PCS8G_TX_COMPL_CONTR_DISP), // dis_txcompliance|en_txcompliance_pipe2p0|en_txcompliance_pipe3p0
	.pcs8g_tx_sup_mode			("user_mode"),

	//*********************************************
	// parameters for stratixv_hssi_pipe_gen1_2
	//*********************************************
	.pipe12_elec_idle_delay_val	 	(3'b100), 			//prasanna:2.0 value
	.pipe12_elecidle_delay			("elec_idle_delay"), 		// elec_idle_delay
	.pipe12_hip_mode 			(HIP_MODE), 			// dis_hip|en_hip
	.pipe12_ind_error_reporting	 	("dis_ind_error_reporting"), 	// dis_ind_error_reporting|en_ind_error_reporting //TODO
	.pipe12_phy_status_delay 		("phystatus_delay"), 		// phystatus_delay
	.pipe12_phystatus_delay_val 		(3'b0),
	.pipe12_pipe_byte_de_serializer_en	(PIPE12_BYTE_DESERIALIZER_EN), // dis_bds|en_bds_by_2|dont_care_bds
	.pipe12_prot_mode 			(PROT_MODE), // pipe_g1|pipe_g2|pipe_g3|cpri|cpri_rx_tx|gige|xaui|srio_2p1|test|basic|disabled_prot_mode
	.pipe12_rpre_emph_a_val 		(pipe12_rpre_emph_a_val),
	.pipe12_rpre_emph_b_val 		(pipe12_rpre_emph_b_val), 
	.pipe12_rpre_emph_c_val 		(pipe12_rpre_emph_c_val),
	.pipe12_rpre_emph_d_val 		(pipe12_rpre_emph_d_val),
	.pipe12_rpre_emph_e_val 		(pipe12_rpre_emph_e_val),
	.pipe12_rpre_emph_settings 		(6'b0),
	.pipe12_rvod_sel_a_val 			(pipe12_rvod_sel_a_val),
	.pipe12_rvod_sel_b_val 			(pipe12_rvod_sel_b_val),
	.pipe12_rvod_sel_c_val 			(pipe12_rvod_sel_c_val),
	.pipe12_rvod_sel_d_val 			(pipe12_rvod_sel_d_val),
	.pipe12_rvod_sel_e_val 			(pipe12_rvod_sel_e_val),
	.pipe12_rvod_sel_settings 		(6'b0),
	.pipe12_rx_pipe_enable 			(((hip_enable == "true") || (protocol_version == "Gen 3")) ? "en_pipe3_rx" : "en_pipe_rx"), // dis_pipe_rx|en_pipe_rx|en_pipe3_rx 
	.pipe12_rxdetect_bypass			("dis_rxdetect_bypass"), // dis_rxdetect_bypass|en_rxdetect_bypass //TODO
	.pipe12_tx_pipe_enable 			(((hip_enable == "true") || (protocol_version == "Gen 3")) ? "en_pipe3_tx" : "en_pipe_tx"), // dis_pipe_tx|en_pipe_tx|en_pipe3_tx
	.pipe12_txswing 			(((hip_enable == "true") || (protocol_version == "Gen 3")) ? "dis_txswing" : "en_txswing"), // dis_txswing|en_txswing 

	//*********************************************
	// parameters for stratixv_hssi_pipe_gen3
	//*********************************************
	.pipe3_sup_mode 			("user_mode"), // user_mode|engr_mode
	.pipe3_asn_clk_enable 			((PROT_MODE == "pipe_g3") ? "true"   : "false"),   // false|true. 
	.pipe3_asn_enable 			((PROT_MODE == "pipe_g3") ? "en_asn" : "dis_asn"), // dis_asn|en_asn 
	.pipe3_bypass_pma_sw_done 		("false"), // false|true //RBC = false. Do not bypass PMA SW DONE
  .pipe3_bypass_rx_detection_enable ("false"), // false|true
  .pipe3_bypass_rx_preset                 ("rx_preset_bypass"),  // rx_preset_bypass
  .pipe3_bypass_rx_preset_data            (3'b0),//TODO
  .pipe3_bypass_rx_preset_enable          ("false"),             // false|true
	.pipe3_bypass_send_syncp_fbkp 		((PROT_MODE == "pipe_g3") ? "false"  : "true"), // false|true. RBC = true for pipe_g1 and g2, false for pipe_g3 (do not bypass sending syncp when going to/from Gen3). 
  .pipe3_bypass_tx_coefficent             ("tx_coeff_bypass"),   // tx_coeff_bypass
  .pipe3_bypass_tx_coefficent_data        (18'b0), //TODO
  .pipe3_bypass_tx_coefficent_enable      ("false"),          // false|true
	.pipe3_cdr_control 			("en_cdr_ctrl"), // dis_cdr_ctrl|en_cdr_ctrl
	.pipe3_cid_enable 			("en_cid_mode"), // dis_cid_mode|en_cid_mode
	.pipe3_data_mask_count 			("data_mask_count"), // data_mask_count
	.pipe3_data_mask_count_val 		(10'b1100100000),
	.pipe3_elecidle_delay_g3 		("elecidle_delay_g3"), // elecidle_delay_g3
	.pipe3_elecidle_delay_g3_data 		(3'b111),
	.pipe3_free_run_clk_enable 		("true"), // false|true
	.pipe3_ind_error_reporting 		("dis_ind_error_reporting"), // dis_ind_error_reporting|en_ind_error_reporting
	.pipe3_inf_ei_enable	 		((pipe_elec_idle_infer_enable == "true" && protocol_version == "Gen 3") ? "en_inf_ei" : "dis_inf_ei"), // dis_inf_ei|en_inf_ei
	.pipe3_mode				(PROT_MODE), // pipe_g1|pipe_g2|pipe_g3|par_lpbk|disable_pcs
	.pipe3_parity_chk_ts1 			("en_ts1_parity_chk"), // en_ts1_parity_chk|dis_ts1_parity_chk
	.pipe3_pc_en_counter 			("pc_en_count"), // pc_en_count
	.pipe3_pc_en_counter_data 		(7'b1000000),
	.pipe3_pc_rst_counter 			("pc_rst_count"), // pc_rst_count
	.pipe3_pc_rst_counter_data		(5'b01000),
	.pipe3_ph_fifo_reg_mode		 	((protocol_version == "Gen 3" && hip_enable == "false") ? "phfifo_reg_mode_dis" : "phfifo_reg_mode_en"), // phfifo_reg_mode_dis|phfifo_reg_mode_en 
	.pipe3_phfifo_flush_wait 		("phfifo_flush_wait"), // phfifo_flush_wait
	.pipe3_phfifo_flush_wait_data	 	(6'b100000),
	.pipe3_phy_status_delay_g12 		("phy_status_delay_g12"), // phy_status_delay_g12
	.pipe3_phy_status_delay_g12_data	(3'b101),
	.pipe3_phy_status_delay_g3		("phy_status_delay_g3"), // phy_status_delay_g3
	.pipe3_phy_status_delay_g3_data 	(3'b101),
	.pipe3_phystatus_rst_toggle_g12	 	("en_phystatus_rst_toggle"), // dis_phystatus_rst_toggle|en_phystatus_rst_toggle.
	.pipe3_phystatus_rst_toggle_g3 		((PROT_MODE == "pipe_g3") ? "en_phystatus_rst_toggle_g3" : "dis_phystatus_rst_toggle_g3"), // dis_phystatus_rst_toggle_g3|en_phystatus_rst_toggle_g3.
	.pipe3_pipe_clk_sel 			("func_clk"), // disable_clk|dig_clk1_8g|func_clk
	.pipe3_pma_done_counter 		("pma_done_count"), // pma_done_count
	.pipe3_pma_done_counter_data 		(18'd175000),
	.pipe3_rate_match_pad_insertion		("dis_rm_fifo_pad_ins"), // dis_rm_fifo_pad_ins|en_rm_fifo_pad_ins. 
	.pipe3_rxvalid_mask			("rxvalid_mask_en"), // rxvalid_mask_dis|rxvalid_mask_en
	.pipe3_sigdet_wait_counter		("sigdet_wait_counter"), // sigdet_wait_counter
	.pipe3_sigdet_wait_counter_data		(8'b00111111),
	.pipe3_spd_chnge_g2_sel			((PROT_MODE == "pipe_g1" || PROT_MODE == "pipe_g2") ? "true"   : 
						 (PROT_MODE == "pipe_g3") ? "false" : "<invalid>"), // false|true 
	.pipe3_test_mode_timers			("dis_test_mode_timers"), // dis_test_mode_timers|en_test_mode_timers
	.pipe3_wait_clk_on_off_timer 		("wait_clk_on_off_timer"), // wait_clk_on_off_timer
	.pipe3_wait_clk_on_off_timer_data 	(4'b0100),
	.pipe3_wait_pipe_synchronizing		("wait_pipe_sync"), // wait_pipe_sync
	.pipe3_wait_pipe_synchronizing_data	(5'b10111),
	.pipe3_wait_send_syncp_fbkp		("wait_send_syncp_fbkp"), // wait_send_syncp_fbkp
	.pipe3_wait_send_syncp_fbkp_data	(11'b00011111010),	
	
   //*********************************************
   // parameters for stratixv_hssi_gen3_rx_pcs
   //*********************************************
  .pcs_g3_rx_block_sync                   ("enable_block_sync"), // bypass_block_sync|enable_block_sync
  .pcs_g3_rx_block_sync_sm                ("enable_blk_sync_sm"),// disable_blk_sync_sm|enable_blk_sync_sm
  .pcs_g3_rx_decoder                      (DECODER_G3),    // bypass_decoder|enable_decoder
   // Use the scrambler/descrambler in the HIP in HIP mode. 
  .pcs_g3_rx_descrambler                  ((hip_enable == "true" || bypass_g3pcs_scrambler_descrambler == 1) ? "bypass_descrambler" : "enable_descrambler"),// bypass_descrambler|enable_descrambler
  .pcs_g3_rx_descrambler_lfsr_check       ("lfsr_chk_dis"),      // lfsr_chk_dis|lfsr_chk_en 
  .pcs_g3_rx_lpbk_force                   ("lpbk_frce_en"),     // lpbk_frce_dis|lpbk_frce_en
  .pcs_g3_rx_mode                         ("gen3_func"),         // gen3_func|par_lpbk|disable_pcs
  .pcs_g3_rx_parallel_lpbk                ("par_lpbk_dis"),      // par_lpbk_dis|par_lpbk_en 
  .pcs_g3_rx_rate_match_fifo              (RATE_MATCH_G3),    // bypass_rm_fifo|enable_rm_fifo
  .pcs_g3_rx_rate_match_fifo_latency      ("regular_latency"),// regular_latency|low_latency
  .pcs_g3_rx_reverse_lpbk                 ("rev_lpbk_en"),       // rev_lpbk_dis|rev_lpbk_en
  .pcs_g3_rx_rx_b4gb_par_lpbk             ("b4gb_par_lpbk_dis"), // b4gb_par_lpbk_dis|b4gb_par_lpbk_en
  .pcs_g3_rx_rx_clk_sel                   ("rcvd_clk"),          // disable_clk|dig_clk1_8g|rcvd_clk
  .pcs_g3_rx_rx_force_balign              ("en_force_balign"),   // en_force_balign|dis_force_balign
  .pcs_g3_rx_rx_g3_dcbal                  (RX_DC_BAL_G3),       // g3_dcbal_dis|g3_dcbal_en
  .pcs_g3_rx_rx_ins_del_one_skip          ( "ins_del_one_skip_en"),// ins_del_one_skip_dis|ins_del_one_skip_en
  // lane numbers are initial seeds for the scramblers. 
  // For HIP mode, we engage the scrambler/descrambler in the hard IP and do
  // not engage the ones in the PCS. 
  // For Soft PIPE mode, we statically pass the lane number depending on
  // whether it is x1,x2,x4 or x8. Dynamic reconfiguration is not supported. 
  .pcs_g3_rx_rx_lane_num                  (TX_RX_LANE_NUM),      // lane_0|lane_1|lane_2|lane_3|lane_4|lane_5|lane_6|lane_7|not_used 
  .pcs_g3_rx_rx_num_fixed_pat             ("num_fixed_pat"),     // num_fixed_pat
  .pcs_g3_rx_rx_num_fixed_pat_data        (4'b100),
  .pcs_g3_rx_rx_pol_compl                 ("rx_pol_compl_dis"),  // rx_pol_compl_dis|rx_pol_compl_en
  .pcs_g3_rx_rx_test_out_sel              ("rx_test_out0"),      // rx_test_out0|rx_test_out1
  .pcs_g3_rx_sup_mode                     ("user_mode"),         // user_mode|engr_mode
  .pcs_g3_rx_tx_clk_sel                   ("tx_pma_clk"),        // disable_clk|dig_clk2_8g|tx_pma_clk
  
  //*********************************************
  // parameters for stratixv_hssi_gen3_tx_pcs
  //*********************************************
  .pcs_g3_tx_encoder                      (ENCODER_G3),    // bypass_encoder|enable_encoder
  .pcs_g3_tx_mode                         ("gen3_func"),         // gen3_func|prbs|par_lpbk|disable_pcs
  .pcs_g3_tx_prbs_generator               ("prbs_gen_dis"),      // prbs_gen_dis|prbs_gen_en
  .pcs_g3_tx_reverse_lpbk                 ("rev_lpbk_en"),       // rev_lpbk_dis|rev_lpbk_en
   // Use the scrambler/descrambler in the HIP in HIP mode. 
  .pcs_g3_tx_scrambler                    ((hip_enable == "true" || bypass_g3pcs_scrambler_descrambler == 1) ? "bypass_scrambler" : "enable_scrambler"),  // bypass_scrambler|enable_scrambler
  .pcs_g3_tx_sup_mode                     ("user_mode"),         // user_mode|engr_mode
  .pcs_g3_tx_tx_bitslip                   ("tx_bitslip_val"),    // tx_bitslip_val
  .pcs_g3_tx_tx_bitslip_data              (5'b0),
  .pcs_g3_tx_tx_clk_sel                   ("tx_pma_clk"),        // disable_clk|dig_clk1_8g|tx_pma_clk
  .pcs_g3_tx_tx_g3_dcbal                  (TX_DC_BAL_G3),    // tx_g3_dcbal_dis|tx_g3_dcbal_en
  .pcs_g3_tx_tx_gbox_byp                  ("enable_gbox"),       // bypass_gbox|enable_gbox
  // lane numbers are initial seeds for the scramblers. 
  // For HIP mode, we engage the scrambler/descrambler in the hard IP and do
  // not engage the ones in the PCS. 
  // For Soft PIPE mode, we statically pass the lane number depending on
  // whether it is x1,x2,x4 or x8. Dynamic reconfiguration is not supported.
  .pcs_g3_tx_tx_lane_num                  (TX_RX_LANE_NUM),      // lane_0|lane_1|lane_2|lane_3|lane_4|lane_5|lane_6|lane_7|not_used 
  .pcs_g3_tx_tx_pol_compl                 ("tx_pol_compl_dis"),  // tx_pol_compl_dis|tx_pol_compl_en

	//*******************************************************
	// parameters for stratixv_hssi_common_pcs_pma_interface
	//*******************************************************
	.com_pcs_pma_if_auto_speed_ena 		(((protocol_version == "Gen 2") || (protocol_version == "Gen 3")) ? "en_auto_speed_ena": "dis_auto_speed_ena"), // dis_auto_speed_ena|en_auto_speed_ena. 
//	.com_pcs_pma_if_force_freqdet		("<auto_single>"), // force_freqdet_dis|force1_freqdet_en|force0_freqdet_en. RBC=force_freqdet_dis 
	.com_pcs_pma_if_func_mode 		((hip_enable == "true") ? ((protocol_version == "Gen 3") ? "eightg_and_g3" : "eightg_only_emsip")
                                                                        : (protocol_version == "Gen 3") ? "eightg_and_g3" : "eightg_only_pld"), 
						// disable|pma_direct|hrdrstctrl_cmu|eightg_only_pld|eightg_and_g3|eightg_only_emsip|
	.com_pcs_pma_if_pipe_if_g3pcs 		((hip_enable == "true" || protocol_version == "Gen 3") ? "pipe_if_g3pcs":"pipe_if_8gpcs"), // pipe_if_g3pcs|pipe_if_8gpcs   
	.com_pcs_pma_if_ppm_deassert_early	((protocol_version == "Gen 3") ? "deassert_early_en": "deassert_early_dis"), // deassert_early_dis|deassert_early_en
	.com_pcs_pma_if_ppm_gen1_2_cnt		("cnt_32k"), // cnt_32k|cnt_64k
	.com_pcs_pma_if_ppm_post_eidle_delay 	("cnt_200_cycles"),// cnt_200_cycles|cnt_400_cycles //TODO
	.com_pcs_pma_if_ppmsel 			("ppmsel_300"),    // ppmsel_default|ppmsel_1000|ppmsel_500|ppmsel_300|ppmsel_250|
								   // ppmsel_200|ppmsel_125|ppmsel_100|ppmsel_62p5|ppm_other
								   //TODO - PCIe requires +-300PPM. Verify. 
	.com_pcs_pma_if_prot_mode 		(PROT_MODE), 	   // disabled_prot_mode|pipe_g1|pipe_g2|pipe_g3|other_protocols
	.com_pcs_pma_if_selectpcs 		((protocol_version == "Gen 3") ? "pcie_gen3" : "eight_g_pcs"), // eight_g_pcs|pcie_gen3. 
	.com_pcs_pma_if_sup_mode 		("user_mode"), 	   

	//*******************************************************
	// parameters for stratixv_hssi_common_pld_pcs_interface
	//*******************************************************
	.com_pld_pcs_if_emsip_enable 			((hip_enable == "true") ? "emsip_enable" : "emsip_disable"), // emsip_enable|emsip_disable
	.com_pld_pcs_if_data_source             	((hip_enable == "true") ? "emsip" : "pld"), // emsip|pld
	.com_pld_pcs_if_hrdrstctrl_en_cfg 		(HRDRSTCTRL_EN_CFG), // hrst_dis_cfg|hrst_en_cfg
	.com_pld_pcs_if_hrdrstctrl_en_cfgusr 		(HRDRSTCTRL_EN_CFGUSR), // hrst_dis_cfgusr|hrst_en_cfgusr
	.com_pld_pcs_if_pld_side_reserved_source0 	((hip_enable == "true") ? "emsip_res0" : "pld_res0"), // pld_res0|emsip_res0
	.com_pld_pcs_if_pld_side_reserved_source1 	((hip_enable == "true") ? "emsip_res1" : "pld_res1"), // pld_res1|emsip_res1
	.com_pld_pcs_if_pld_side_reserved_source10 	((hip_enable == "true") ? "emsip_res10" : "pld_res10"), // pld_res10|emsip_res10
	.com_pld_pcs_if_pld_side_reserved_source11	((hip_enable == "true") ? "emsip_res11" : "pld_res11"), // pld_res11|emsip_res11
	.com_pld_pcs_if_pld_side_reserved_source2 	((hip_enable == "true") ? "emsip_res2" : "pld_res2"), // pld_res2|emsip_res2
	.com_pld_pcs_if_pld_side_reserved_source3 	((hip_enable == "true") ? "emsip_res3" : "pld_res3"), // pld_res3|emsip_res3
	.com_pld_pcs_if_pld_side_reserved_source4 	((hip_enable == "true") ? "emsip_res4" : "pld_res4"), // pld_res4|emsip_res4
	.com_pld_pcs_if_pld_side_reserved_source5 	((hip_enable == "true") ? "emsip_res5" : "pld_res5"), // pld_res5|emsip_res5
	.com_pld_pcs_if_pld_side_reserved_source6 	((hip_enable == "true") ? "emsip_res6" : "pld_res6"), // pld_res6|emsip_res6
	.com_pld_pcs_if_pld_side_reserved_source7 	((hip_enable == "true") ? "emsip_res7" : "pld_res7"), // pld_res7|emsip_res7
	.com_pld_pcs_if_pld_side_reserved_source8	((hip_enable == "true") ? "emsip_res8" : "pld_res8"), // pld_res8|emsip_res8
	.com_pld_pcs_if_pld_side_reserved_source9 	((hip_enable == "true") ? "emsip_res9" : "pld_res9"), // pld_res9|emsip_res9//	
	.com_pld_pcs_if_testbus_sel			("eight_g_pcs"), // eight_g_pcs|g3_pcs|ten_g_pcs|pma_if. 
	.com_pld_pcs_if_usrmode_sel4rst 		("usermode"), // usermode|last_frz

	//*******************************************************
	// parameters for stratixv_hssi_rx_pcs_pma_interface
	//*******************************************************
	.rx_pcs_pma_if_prot_mode 	("other_protocols"), // cpri_8g|other_protocols
	.rx_pcs_pma_if_selectpcs 	((protocol_version == "Gen 3") ? "pcie_gen3" : "eight_g_pcs"), // eight_g_pcs|ten_g_pcs|pcie_gen3|default
	//*******************************************************
	// parameters for stratixv_hssi_rx_pld_pcs_interface
	//*******************************************************
	.rx_pld_pcs_if_data_source 	((hip_enable == "true") ? "emsip" : "pld"), // emsip|pld
	.rx_pld_pcs_if_selectpcs 	("eight_g_pcs"), // eight_g_pcs|ten_g_pcs|default
	//*******************************************************
	// parameters for stratixv_hssi_tx_pcs_pma_interface
	//*******************************************************
	.tx_pcs_pma_if_selectpcs	((protocol_version == "Gen 3") ? "pcie_gen3" : "eight_g_pcs"), // eight_g_pcs|ten_g_pcs|pcie_gen3|default
	//*******************************************************
	// parameters for stratixv_hssi_tx_pld_pcs_interface
	//*******************************************************
	.tx_pld_pcs_if_data_source 	((hip_enable == "true") ? "emsip" : "pld"), // emsip|pld
  //*******************************************************
	// parameters for service requests for calibration IPs
	//*******************************************************
  .request_adce_cont               (0), //Always disable ADCE continous mode (CVP or non-CVP modes)
  .request_adce_single             (0), //Always disable ADCE single
  .request_dcd                     (0), // Disable DCD always for ES. Re-evaluate for Prod Si whether it is needed for designs with Soft Reset controller.
  .request_dfe                     (0), //Always disable DFE (CVP or non-CVP modes)
  .request_vrc                     (0), //Always disable VRC (CVP or non-CVP modes)
  .request_offset                  ((in_cvp_mode == "in_cvp_mode" || hip_hard_reset == "enable") ? 0 : 1),  //disable soft OC when CVP mode or hard reset controller is used
  // ************************************************************************
  // parameters for hard offset cancellation 
  // ************************************************************************
  // NOTES - 
  // Hard offset cancellation is intended to be engaged only for Gen2 HRC designs (optional). It is enabled based on hard_oc_enable passed from HIP wrapper. 
  // Gen1 does not require offset cancellation to run 
  // Gen3 requires offset cancellation to run; but since we do not support cvp for gen3, we are not enabling the hardened block instead we use the soft IP
  // ************************************************************************
  .cal_eye_pdb          ("EYE_MONITOR_OFF"),
  .cal_dfe_pdb          ("DFE_MONITOR_OFF"),
  .cal_offset_mode      ((hard_oc_enable == "true") ? "MODE_ACCUMULATION_MIDSWEEP" : "MODE_INDEPENDENT"),
  .cal_set_timer        ("TIMER_FAST"),
  .cal_limit_sa_cap     ("FULL_CAP"),
  .cal_oneshot          ((hard_oc_enable == "true") ? "ONESHOT_ON" : "ONESHOT_OFF"),
  .rx_dprio_sel         ((hard_oc_enable == "true") ? "RX_CALIBRATION_SEL" : "RX_DPRIO_SEL"),
  .bbpd_dprio_sel       ("BBPD_DPRIO_SEL"),
  .eye_dprio_sel        ("EYE_DPRIO_SEL"),
  .dfe_dprio_sel        ("DFE_DPRIO_SEL"),
  .offset_cal_pd_top    ("OFFSET_ENABLE"),
  .offset_att_en        ("ENABLE_12G_CAL"),
  .cal_status_sel       ("STATUS_REG1"), 
  .cal_limit_bbpd_sa_cal("ENABLE_4PHASE")
)
inst_sv_xcvr_native
(
	// *************************** PMA ports ********************************
	.seriallpbken		(w_pldseriallpbken),  		  // 1 = enable serial loopback
	.rx_crurstn		(~w_rx_analogreset),     	  // CDR analog reset (active low) 
	.rx_datain		(w_pinrxdatain),    		  // RX serial data input
	.rx_cdr_ref_clk		({TOTAL_LANES{pll_ref_clk}}), // Reference clock for CDR  
	.rx_ltd			(w_pldrxltd),     	          // Force lock-to-data stream
								  // MM port for now
	.rx_is_lockedtodata	(w_rx_is_lockedtodata),	          // Indicates lock to incoming data rate
								  // Output from PMA to PLD
	.rx_is_lockedtoref	(w_rx_is_lockedtoref), 		  // Indicates lock to reference clock
								  // Output from PMA to PLD
	.tx_rxdetclk		(fixedclk),     		  // Clock for detection of downstream receiver (125MHz ?)
	.tx_dataout		(w_tx_dataout),    		  // TX serial data output
	.tx_rstn		({TOTAL_LANES{~tx_analogreset}}), //1-bit     	  	 
	.pcs_rst_n              (pcs_rst_n),      // only for PCIe 
  .tx_ser_clk		      ({TOTAL_LANES{pll_out}}),     	  // High-speed serial clock from PLL //sv_xcvr_plls output
  .tx_cal_busy    (tx_cal_busy),
  .rx_cal_busy    (rx_cal_busy),
	.tx_pcie_fb_clk		(w_tx_pcie_fb_clk),               // PLL feedback clock for PCIe Gen3 x8
	.tx_pll_fb_sw		(w_tx_pll_fb_sw),                 // PLL feedback clock select

	// *************************** PCS ports ********************************
	.in_agg_align_status			(/*unused*/),
	.in_agg_align_status_sync_0		(/*unused*/),
	.in_agg_align_status_sync_0_top_or_bot	(/*unused*/),
	.in_agg_align_status_top_or_bot		(/*unused*/),
	.in_agg_cg_comp_rd_d_all		(/*unused*/),
	.in_agg_cg_comp_rd_d_all_top_or_bot	(/*unused*/),
	.in_agg_cg_comp_wr_all			(/*unused*/),
	.in_agg_cg_comp_wr_all_top_or_bot	(/*unused*/),
	.in_agg_del_cond_met_0			(/*unused*/),
	.in_agg_del_cond_met_0_top_or_bot	(/*unused*/),
	.in_agg_en_dskw_qd			(/*unused*/),
	.in_agg_en_dskw_qd_top_or_bot		(/*unused*/),
	.in_agg_en_dskw_rd_ptrs			(/*unused*/),
	.in_agg_en_dskw_rd_ptrs_top_or_bot	(/*unused*/),
	.in_agg_fifo_ovr_0			(/*unused*/),
	.in_agg_fifo_ovr_0_top_or_bot		(/*unused*/),
	.in_agg_fifo_rd_in_comp_0		(/*unused*/),
	.in_agg_fifo_rd_in_comp_0_top_or_bot	(/*unused*/),
	.in_agg_fifo_rst_rd_qd			(/*unused*/),
	.in_agg_fifo_rst_rd_qd_top_or_bot	(/*unused*/),
	.in_agg_insert_incomplete_0		(/*unused*/),
	.in_agg_insert_incomplete_0_top_or_bot	(/*unused*/),
	.in_agg_latency_comp_0			(/*unused*/),
	.in_agg_latency_comp_0_top_or_bot	(/*unused*/),
	.in_agg_rcvd_clk_agg			(/*unused*/),
	.in_agg_rcvd_clk_agg_top_or_bot		(/*unused*/),
	.in_agg_rx_control_rs			(/*unused*/),
	.in_agg_rx_control_rs_top_or_bot	(/*unused*/),
	.in_agg_rx_data_rs			(/*unused*/),
	.in_agg_rx_data_rs_top_or_bot		(/*unused*/),
	.in_agg_test_so_to_pld_in		(/*unused*/),
	.in_agg_testbus				(/*unused*/),
	.in_agg_tx_ctl_ts			(/*unused*/),
	.in_agg_tx_ctl_ts_top_or_bot		(/*unused*/),
	.in_agg_tx_data_ts			(/*unused*/),
	.in_agg_tx_data_ts_top_or_bot		(/*unused*/),

  //EMSIP bundle from PCIe HIp to the PCS-PLD Interface 
	.in_emsip_com_in			(w_emsip_com_in), 	  
	.in_emsip_com_special_in		(w_emsip_com_special_in), 
	.in_emsip_rx_clk_in			(w_emsip_rx_clk_in), 	 
	.in_emsip_rx_in				(w_emsip_rx_in), 	  
	.in_emsip_rx_special_in			(w_emsip_rx_special_in),  
	.in_emsip_tx_clk_in			(w_emsip_tx_clk_in), 	  
	.in_emsip_tx_in				(w_emsip_tx_in), 	  
	.in_emsip_tx_special_in			(w_emsip_tx_special_in),  

	.in_pld_10g_refclk_dig			(/*unused*/),
	.in_pld_10g_rx_align_clr		(/*unused*/),
	.in_pld_10g_rx_align_en			(/*unused*/),
	.in_pld_10g_rx_bitslip			(/*unused*/),
	.in_pld_10g_rx_clr_ber_count		(/*unused*/),
	.in_pld_10g_rx_clr_errblk_cnt		(/*unused*/),
	.in_pld_10g_rx_disp_clr			(/*unused*/),
	.in_pld_10g_rx_pld_clk			(/*unused*/),
	.in_pld_10g_rx_prbs_err_clr		(/*unused*/),
	.in_pld_10g_rx_rd_en			(/*unused*/),
	.in_pld_10g_rx_rst_n			(/*unused*/),
	.in_pld_10g_tx_bitslip			(/*unused*/),
	.in_pld_10g_tx_burst_en			(/*unused*/),
	.in_pld_10g_tx_control			(/*unused*/),
	.in_pld_10g_tx_data_valid		(/*unused*/),
	.in_pld_10g_tx_diag_status		(/*unused*/),
	.in_pld_10g_tx_pld_clk			(/*unused*/),
	.in_pld_10g_tx_rst_n			(/*unused*/),
	.in_pld_10g_tx_wordslip			(/*unused*/),

	.in_pld_8g_a1a2_size			({TOTAL_LANES{1'b0}}), 			 //Unused 				 
	.in_pld_8g_bitloc_rev_en		({TOTAL_LANES{1'b0}}), 			 //Unused 				 
	.in_pld_8g_bitslip			({TOTAL_LANES{1'b0}}), 			 //Unused 				 
	.in_pld_8g_byte_rev_en			({TOTAL_LANES{1'b0}}), 			 //Unused 				 
	.in_pld_8g_bytordpld			({TOTAL_LANES{1'b0}}), 			 //Unused 				 
	.in_pld_8g_cmpfifourst_n		({TOTAL_LANES{1'b1}}), 			 //Unused 
	.in_pld_8g_encdt			({TOTAL_LANES{1'b0}}),			 //Unused			  
	.in_pld_8g_phfifourst_rx_n		({TOTAL_LANES{1'b1}}), 			 //Unused 
	.in_pld_8g_phfifourst_tx_n		({TOTAL_LANES{1'b1}}), 			 //Unused 
	.in_pld_8g_pld_rx_clk			({TOTAL_LANES{core_rx_clock_into_pcs}}), //loopback tx_clkout_to_pld 
	.in_pld_8g_pld_tx_clk			({TOTAL_LANES{core_rx_clock_into_pcs}}), //loopback tx_clkout_to_pld 
	.in_pld_8g_polinv_rx			({TOTAL_LANES{1'b0}}),			 //PIPE listens to pipe_rxpolarity (see rxpolarity port to PCS)
	.in_pld_8g_polinv_tx			(w_tx_invpolarity), 			 //from input port and adjusted for HIP x8 reserved channel
	.in_pld_8g_powerdown			(w_pld8gpowerdown),			 //from pipe_powerdown and adjusted for HIP x8 reserved channel
	.in_pld_8g_prbs_cid_en			(/*unused*/),
	.in_pld_8g_rddisable_tx			({TOTAL_LANES{1'b0}}), 			 //Unused 
	.in_pld_8g_rdenable_rmf			({TOTAL_LANES{1'b0}}), 			 //Unused
	.in_pld_8g_rdenable_rx			(/*unused*/),
	.in_pld_8g_refclk_dig			(/*unused*/),				 
	.in_pld_8g_refclk_dig2			(/*unused*/),
	.in_pld_8g_rev_loopbk			({TOTAL_LANES{1'b0}}),			 //PIPE if decodes txdetectrxloopback and powerdown to
											 //determine rev loopbk to PCS. This input is not used for PIPE.
	.in_pld_8g_rxpolarity			(w_pld8grxpolarity), 			 //From pipe_rxpolarity and adjusted for HIP x8 reserved channel
	.in_pld_8g_rxurstpcs_n			(~w_rx_digitalreset),	//Rx digital reset from Reset Cntrlr adjusted for HIP x8 reserved channel
									//Invert every bit of this bus
									
	.in_pld_8g_tx_blk_start			(w_pld8gtxblkstart),	 	 //Gen3 signal
	.in_pld_8g_tx_boundary_sel		(/*unused*/),				 //bitslipboundaryselect is not used
	.in_pld_8g_tx_data_valid		(w_pld8gtxdatavalid), 	 //Gen3 signal 
	.in_pld_8g_tx_sync_hdr			(w_pld8gtxsynchdr), 		 //Gen3 signal 
	.in_pld_8g_txdeemph			(w_pld8gtxdeemph),
	.in_pld_8g_txdetectrxloopback		(w_pld8gtxdetectrxloopback),
	.in_pld_8g_txelecidle			(w_pld8gtxelecidle),
	.in_pld_8g_txmargin			(w_pld8gtxmargin),
	.in_pld_8g_txswing			(w_pld8gtxswing),
	.in_pld_8g_txurstpcs_n			(~w_tx_digitalreset),   //Tx digital reset from Reset Cntrlr adjusted for HIP x8 dunny channel
									//Invert every bit of this bus
	.in_pld_8g_wrdisable_rx			({TOTAL_LANES{1'b0}}),
	.in_pld_8g_wrenable_rmf			({TOTAL_LANES{1'b0}}),
	.in_pld_8g_wrenable_tx			({TOTAL_LANES{1'b0}}), 			//Tied-off to 0 in 2.0.	
	.in_pld_agg_refclk_dig			(/*unused*/),
	.in_pld_eidleinfersel			(w_pldeidleinfersel), 			//From rx_eidleinfersel and adjusted for HIP x8 reserved channel
	
	.in_pld_gen3_current_coeff		(w_pldgen3currentcoeff),			//Soft Gen3
	.in_pld_gen3_current_rxpreset	(w_pldgen3currentrxpreset),		//Soft Gen3
	.in_pld_gen3_rx_rstn			(~w_rx_digitalreset),			//Rx Rst for Gen3 PCS. 
	.in_pld_gen3_tx_rstn			(~w_tx_digitalreset),			//Tx Rst for Gen3 PCS. 
	
	.in_pld_ltr				(w_rx_set_locktoref),			//From MM port to PCS and then to PMA ltr
	.in_pld_partial_reconfig_in		({TOTAL_LANES{1'b1}}),
	.in_pld_pcs_pma_if_refclk_dig		(/*unused*/),
	.in_pld_rate				(w_pldrate),				//From pipe_rate and adjusted for HIP x8 reserved channel
	.in_pld_reserved_in			(/*unused*/),
	.in_pld_rx_clk_slip_in			({TOTAL_LANES{1'b0}}),
	.in_pld_rxpma_rstb_in			(~w_rx_analogreset),    //Rx analog reset from Reset Cntrlr adjusted for HIP x8 reserved channel
									//Invert every bit of this bus
	.in_pld_scan_mode_n			({TOTAL_LANES{1'b1}}),  //Disable scan mode
	.in_pld_scan_shift_n			({TOTAL_LANES{1'b1}}),
	.in_pld_sync_sm_en			({TOTAL_LANES{1'b1}}),  // This signal enables the sync state machine in the Word aligner. Should always be enabled for PIPE. 
	.in_pld_tx_data				(w_pldtxdatain),   //From pipe_txdata,txdatak, txcompliance, txelecidle and adjusted 
									//for HIP x8 reserved channel
	.in_pma_clkdiv33_lc_in			({TOTAL_LANES{1'b0}}),	
	.in_pma_eye_monitor_in			(/*unused*/),		//new port
	.in_pma_hclk				({TOTAL_LANES{w_pll_hclk[0]}}), //connect HCLK from the Gen1/2 PLL
	.in_pma_reserved_in			(/*unused*/),
	.in_pma_rx_freq_tx_cmu_pll_lock_in	(w_rx_is_lockedtoref),	
	.in_pma_tx_lc_pll_lock_in		({TOTAL_LANES{1'b0}}),	//TODO. connect PLL locked from LC?
	.out_agg_align_det_sync			(/*unused*/), 
	.out_agg_align_status_sync		(/*unused*/),
	.out_agg_cg_comp_rd_d_out		(/*unused*/),
	.out_agg_cg_comp_wr_out			(/*unused*/),
	.out_agg_dec_ctl			(/*unused*/),
	.out_agg_dec_data			(/*unused*/),
	.out_agg_dec_data_valid			(/*unused*/),
	.out_agg_del_cond_met_out		(/*unused*/),
	.out_agg_fifo_ovr_out			(/*unused*/),
	.out_agg_fifo_rd_out_comp		(/*unused*/),
	.out_agg_insert_incomplete_out		(/*unused*/),
	.out_agg_latency_comp_out		(/*unused*/),
	.out_agg_rd_align			(/*unused*/),
	.out_agg_rd_enable_sync			(/*unused*/),
	.out_agg_refclk_dig			(/*unused*/),
	.out_agg_running_disp			(/*unused*/),
	.out_agg_rxpcs_rst			(/*unused*/),
	.out_agg_scan_mode_n			(/*unused*/),
	.out_agg_scan_shift_n			(/*unused*/),
	.out_agg_sync_status			(/*unused*/),
	.out_agg_tx_ctl_tc			(/*unused*/),
	.out_agg_tx_data_tc			(/*unused*/),
	.out_agg_txpcs_rst			(/*unused*/),

        //EMSIP bundle from the PCS-PLD Interface to the PCIe HIP
	.out_emsip_com_clk_out			(w_emsip_com_clk_out),
	.out_emsip_com_out			(w_emsip_com_out),
	.out_emsip_com_special_out		(w_emsip_com_special_out),
	.out_emsip_rx_clk_out			(w_emsip_rx_clk_out),		
	.out_emsip_rx_out			(w_emsip_rx_out),
	.out_emsip_rx_special_out		(w_emsip_rx_special_out),
	.out_emsip_tx_clk_out			(w_emsip_tx_clk_out),	
	.out_emsip_tx_out			(w_emsip_tx_out),	
	.out_emsip_tx_special_out		(w_emsip_tx_special_out),
	
	.out_pld_10g_rx_align_val		(/*unused*/),
	.out_pld_10g_rx_blk_lock		(/*unused*/),
	.out_pld_10g_rx_clk_out			(/*unused*/),
	.out_pld_10g_rx_control			(/*unused*/),
	.out_pld_10g_rx_crc32_err		(/*unused*/),
	.out_pld_10g_rx_data_valid		(/*unused*/),
	.out_pld_10g_rx_diag_err		(/*unused*/),
	.out_pld_10g_rx_diag_status		(/*unused*/),
	.out_pld_10g_rx_empty			(/*unused*/),
	.out_pld_10g_rx_fifo_del		(/*unused*/),
	.out_pld_10g_rx_fifo_insert		(/*unused*/),
	.out_pld_10g_rx_frame_lock		(/*unused*/),
	.out_pld_10g_rx_hi_ber			(/*unused*/),
	.out_pld_10g_rx_mfrm_err		(/*unused*/),
	.out_pld_10g_rx_oflw_err		(/*unused*/),
	.out_pld_10g_rx_pempty			(/*unused*/),
	.out_pld_10g_rx_pfull			(/*unused*/),
	.out_pld_10g_rx_prbs_err		(/*unused*/),
	.out_pld_10g_rx_pyld_ins		(/*unused*/),
	.out_pld_10g_rx_rdneg_sts		(/*unused*/),
	.out_pld_10g_rx_rdpos_sts		(/*unused*/),
	.out_pld_10g_rx_rx_frame		(/*unused*/),
	.out_pld_10g_rx_scrm_err		(/*unused*/),
	.out_pld_10g_rx_sh_err			(/*unused*/),
	.out_pld_10g_rx_skip_err		(/*unused*/),
	.out_pld_10g_rx_skip_ins		(/*unused*/),
	.out_pld_10g_rx_sync_err		(/*unused*/),
	.out_pld_10g_tx_burst_en_exe		(/*unused*/),
	.out_pld_10g_tx_clk_out			(/*unused*/),
	.out_pld_10g_tx_empty			(/*unused*/),
	.out_pld_10g_tx_fifo_del		(/*unused*/),
	.out_pld_10g_tx_fifo_insert		(/*unused*/),
	.out_pld_10g_tx_frame			(/*unused*/),
	.out_pld_10g_tx_full			(/*unused*/),
	.out_pld_10g_tx_pempty			(/*unused*/),
	.out_pld_10g_tx_pfull			(/*unused*/),
	.out_pld_10g_tx_wordslip_exe		(/*unused*/),
	
	.out_pld_8g_a1a2_k1k2_flag		(/*unused*/),
	.out_pld_8g_align_status		(/*unused*/),
	.out_pld_8g_bistdone			(/*unused*/),
	.out_pld_8g_bisterr			(/*unused*/),
	.out_pld_8g_byteord_flag		(/*unused*/),
	.out_pld_8g_empty_rmf			(/*unused*/),
	.out_pld_8g_empty_rx			(rx_pcfifoempty_to_pld),
	.out_pld_8g_empty_tx			(tx_phfifounderflow_to_pld),
	.out_pld_8g_full_rmf			(/*unused*/),
	.out_pld_8g_full_rx			(rx_pcfifofull_to_pld),
	.out_pld_8g_full_tx			(tx_phfifooverflow_to_pld),
	.out_pld_8g_phystatus			(pld8gphystatus),		//Goes to pipe_phystatus output for non-HIP designs 
	.out_pld_8g_rlv_lt			(rx_rlv_to_pld),	
	.out_pld_8g_rx_blk_start		(pld8grxblkstart),		// Gen3 signal
	.out_pld_8g_rx_clk_out			(/*unused*/),			//Unconnected 
	.out_pld_8g_rx_data_valid		(pld8grxdatavalid),		// Gen3 signal.
	.out_pld_8g_rx_sync_hdr			(pld8grxsynchdr),			// Gen3 signal
	.out_pld_8g_rxelecidle			(pld8grxelecidle),		//Goes to pipe_rxelecidle output for non-HIP designs
	.out_pld_8g_rxstatus			(pld8grxstatus),		//Goes to pipe_rxstatus output for non-HIP designs
	.out_pld_8g_rxvalid			(pld8grxvalid),			//Goes to pipe_rxvalid output for non-HIP designs
	.out_pld_8g_signal_detect_out		(w_rx_signaldetect),	//Output MM port.
  .out_pld_8g_tx_clk_out			(tx_clkout_to_pld),		//loopback to pld_tx_clk and pld_rx_clk 
	.out_pld_8g_wa_boundary			(rx_bitslipboundaryselectout_to_pld),	//Output MM port.
	
	.out_pld_clkdiv33_lc			(/*unused*/),
	.out_pld_clkdiv33_txorrx		(/*unused*/),
	.out_pld_clklow				(/*unused*/),			
  .out_pld_fref				(/*unused*/),			
	.out_pld_gen3_mask_tx_pll		(/*unused*/),			//TODO for Soft Gen3 
	.out_pld_gen3_rx_eq_ctrl		(/*unused*/),			//TODO for Soft Gen3 
	.out_pld_gen3_rxdeemph			(/*unused*/),			//TODO for Soft Gen3 
	.out_pld_reserved_out			(/*unused*/),
	.out_pld_rx_data			(rxdata_to_pld),	//Goes to pipe_rxdata, pipe_rxdatak, rx_* output ports for non-HIP designs
	.out_pld_test_data			(/*unused*/),
	.out_pld_test_si_to_agg_out		(/*unused*/),
	.out_pma_current_rxpreset		(/*unused*/),			//TODO
	.out_pma_eye_monitor_out		(/*unused*/),			
	.out_pma_lc_cmu_rstb			(/*unused*/),			//TODO
	.out_pma_nfrzdrv			(/*unused*/),			
	.out_pma_partial_reconfig		(/*unused*/),		
	.out_pma_reserved_out			(out_pma_reserved_out),
	.out_pma_rx_clk_out			(/*unused*/),		
	.out_pma_tx_clk_out			(/*unused*/),			
        // sv_xcvr_avmm ports
  .reconfig_to_xcvr                       (reconfig_to_xcvr    [TOTAL_LANES*W_BUNDLE_TO_XCVR-1   :0]), 
  .reconfig_from_xcvr                     (reconfig_from_xcvr  [TOTAL_LANES*W_BUNDLE_FROM_XCVR-1 :0]),
   
	.rxqpipulldn(/*unused*/),			
	.rx_clkdivrx(/*unused*/),			
	.rx_sd(/*unused*/),			
	.txqpipulldn(/*unused*/),			
	.txqpipullup(/*unused*/),			
	.tx_clkdivtx(/*unused*/),			
	.in_pld_tx_pma_data(/*unused*/),			
	.out_pld_rx_pma_data(/*unused*/),			
	.out_pma_tx_pma_syncp_fbkp(/*unused*/)
);

// Production silicon fix: iTrack 82340
// pcsreset is brought on pma_reserved_out, this is connected to pcs_rst_n of
// CGB
genvar num_ch;
generate 
  for(num_ch = 0; num_ch < TOTAL_LANES; num_ch++) begin:pcsrst_to_cgb
      assign pcs_rst_n[num_ch] = out_pma_reserved_out[5*num_ch+2];
  end
endgenerate

endmodule
