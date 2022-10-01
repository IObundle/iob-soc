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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_hip_eq_bypass_ph3
 #(
    parameter K_G3_FULL_SWING    = 6'd63,                 // Local Full Swing FS
    parameter K_G3_LOW_FREQ      = 6'd1,                  // Local Low Freq LF
    parameter K_G3_EN_HALF_SWING = 1'b0,                  // Enable Half Swing
    parameter PRST_COEFF_MAP0    = {6'd0,6'd53,6'd10},    // Preset to Coefficient Mapping
    parameter PRST_COEFF_MAP1    = {6'd0,6'd52,6'd11},
    parameter PRST_COEFF_MAP2    = {6'd0,6'd50,6'd13},
    parameter PRST_COEFF_MAP3    = {6'd0,6'd55,6'd8},
    parameter PRST_COEFF_MAP4    = {6'd0,6'd63,6'd0},
    parameter PRST_COEFF_MAP5    = {6'd6,6'd57,6'd0},
    parameter PRST_COEFF_MAP6    = {6'd8,6'd55,6'd0},
    parameter PRST_COEFF_MAP7    = {6'd6,6'd44,6'd13},
    parameter PRST_COEFF_MAP8    = {6'd8,6'd47,6'd8},
    parameter PRST_COEFF_MAP9    = {6'd11,6'd52,6'd0},
    parameter PRST_COEFF_MAP10   = {6'd30,6'd33,6'd0},
    parameter PRST_COEFF_MAPERR  = {6'd0,6'd0,6'd0},
    parameter DEFAULT_PRST       = PRST_COEFF_MAP4,       // Default PMA preset
    parameter TIMEOUT_32MS       = 23'd7999500,           // 32 ms calculated using 250 Mhz clock - 500 clocks
    parameter ACT_LANES          = 8'b1111_1111
  )
  (
   // Clocks & Resets
   input   wire                                 rst_n,              // Active low Async rst
   input   wire                                 pld_clk,            // Core CLK
   //--------------- HIP Connections
   // Inputs
   input   wire [255:0]                         test_out_hip,       // Test Bus from HIP
   input   wire [63:0]                          test_out_1_hip,     // Test Bus from HIP
   input   wire [4:0]                           ltssm_state,        // LTSSM state from HIP
   input   wire [1:0]                           current_speed,      // Current Speed from HIP

   // Outputs
   output   wire  [31:0]                        test_in_hip,        // Test In to HIP  [10-12] are only used
   output   wire  [31:0]                        test_in_1_hip,      // test In to HIP  [0-4,15-16,31-20] are only used
   output   wire  [31:0]                        reserved_in,        // Reserved Input to HIP [29-10] are only used

   // Output to PMA
   output   reg   [143:0]                       tx_coeff_pma        // Value to be programmed into PMA
   );
//********************************************************************
// Design Params
//********************************************************************
localparam [4:0] DET_QUIET   = 5'b00000 ;
localparam [4:0] REC_RXCFG   = 5'b01101 ;
localparam [4:0] REC_RXLCK   = 5'b01100 ;
localparam [4:0] REC_SPEED   = 5'b11010 ;
localparam [4:0] EQZ_PHASE_0 = 5'b11011 ;
localparam [4:0] EQZ_PHASE_1 = 5'b11100 ;
localparam [4:0] EQZ_PHASE_2 = 5'b11101 ;
localparam [4:0] EQZ_PHASE_3 = 5'b11110 ;

//********************************************************************
// Define Variables
//********************************************************************
reg   [22:0]                     cpt_ph3;
reg                              timeout_ph3;
wire  [31:0]                     test_dbg_eqin;         // Debug Mode Equalization Signals In (All Channels)
reg  [(8*32)-1:0]               test_dbg_eqout;        // Debug Mode Equalization Signals Out (All Channels)
reg  [(8*8)-1:0]                test_dbg_eqber;        // Debug Mode Equalization BER Count O/P's (All Channels)
reg  [5:0]                      test_dbg_farend_lf;
reg  [5:0]                      test_dbg_farend_fs;
wire  [7:0]                      rx_ts_tgl_sync;
reg   [7:0]                      rx_ts_tgl_sync_d0;
wire  [7:0]                      rx_ts_tgl_re;
wire  [7:0]                      rx_ts_tgl_fe;
wire  [7:0]                      rx_ts_tgl;
wire  [7:0]                      rx_ts1_i;
wire  [7:0]                      rx_reject_coeff_i;
wire  [(8*18)-1:0]               rx_coeff_i;
wire  [7:0]                      rx_use_prst_i;
wire  [(8*4)-1:0]                rx_txpreset_i;
wire  [(8*2)-1:0]                rx_ecbits_i;
reg   [7:0]                      rx_ts1;
reg   [7:0]                      rx_reject_coeff;
reg   [(8*18)-1:0]               rx_coeff;
reg   [7:0]                      rx_use_prst;
reg   [(8*4)-1:0]                rx_txpreset;
reg   [(8*2)-1:0]                rx_ecbits;
reg   [7:0]                      tx_reject_coeff_i;     // Transmitted TS1 "reject Coeff" field
reg   [(8*18)-1:0]               tx_coeff_i;            // Transmitted TS1 "Coefficient" field
reg   [7:0]                      tx_use_prst_i;         // Transmitted TS1 "Use Preset" field
reg   [(8*4)-1:0]                tx_txpreset_i;         // Transmitted TS1 "Tx Preset" field
reg   [(8*4)-1:0]                store_tx_txpreset_i;   // Transmitted TS1 "Tx Preset" field
reg   [(8*2)-1:0]                tx_ecbits_i;           // Transmitted TS1 "EC" Field
reg                              tx_lntgl;              // Per lane Strobe Signal active when lane number is changed
reg                              tx_reject_coeff;       // Transmitted TS1 "reject Coeff" field
reg   [17:0]                     tx_coeff;              // Transmitted TS1 "Coefficient" field
reg                              tx_use_prst;           // Transmitted TS1 "Use Preset" field
reg   [3:0]                      tx_txpreset;           // Transmitted TS1 "Tx Preset" field
reg   [1:0]                      tx_ecbits;             // Transmitted TS1 "EC" Field
reg   [2:0]                      tx_lane_num;           // Lane number for which the above values should be applied
reg                              tx_alltgl;             // Strobe Signal indicating all lanes are updated and ready for Transmission
reg                              dbg_hold_ltssm_eqph;
reg                              dbg_rel_ltssm_eqph;
reg                              dbg_en_berchk_eqph;
reg   [3:0]                      snd_prst_cnt;
reg   [1:0]                      enable_cnt;
reg   [3:0]                      lane_cnt;
wire  [7:0]                      rx_ber_tgl;
wire  [(5*8)-1:0]                rx_ber_total_i;
reg   [7:0]                      rx_ber_max;
reg   [(5*8)-1:0]                rx_ber_total;
reg   [21:0]                     cpt_ber;
reg                              equlz_entered;
reg   [7:0]                      legal_coeff_prst;

//********************************************************************
// Test bus assignments
//********************************************************************
   // Force to use Test Bus for Equalization Bypass
   assign test_in_1_hip[4:0] = 5'h10;
   assign test_in_1_hip[14:5]= 10'h0;
   assign test_in_1_hip[15]  = 0;
   assign test_in_1_hip[16]  = 0;
   assign test_in_1_hip[19:17] = 3'h0;

   // Test In HIP
   assign test_in_hip[9:0]        = 10'h0;
   assign test_in_hip[10]      = dbg_hold_ltssm_eqph;
   assign test_in_hip[11]      = dbg_rel_ltssm_eqph;
   assign test_in_hip[12]      = dbg_en_berchk_eqph;
   assign test_in_hip[31:13]      = 18'h0;

   // Test in HIP
   assign {reserved_in[29:10],test_in_1_hip[31:20]} = test_dbg_eqin;
   assign reserved_in[31:30] = 2'h0;
   assign reserved_in[9:0] = 10'h0;

   // Test Out HIP
   always @(negedge rst_n or posedge pld_clk) begin
      if (rst_n == 1'b0) begin
         test_dbg_eqout       <= 256'h0;
         test_dbg_eqber       <= 64'h0;
         test_dbg_farend_lf   <= 6'h0;
         test_dbg_farend_fs   <= 6'h0;
      end
      else begin
         test_dbg_eqout       <= test_out_hip;
         test_dbg_eqber       <= test_out_1_hip;
         test_dbg_farend_lf   <= test_out_hip[9:4];
         test_dbg_farend_fs   <= {test_out_hip[3:0],test_out_1_hip[63:62]};
      end
   end

//********************************************************************
//Test Out Bus for Debug of Equalization SM
// --Ch0
// test_dbg_eqber[0]       = rx_ts_tgl[0]
// test_dbg_eqber[5:1]     = rx_ber_total[4:0]
// test_dbg_eqber[7:6]     = Not Connected
// ---Ch1
// test_dbg_eqber[8]       = rx_ts_tgl[1]
// test_dbg_eqber[13:9]    = rx_ber_total[9:5]
// ...
//********************************************************************
genvar id;
generate
   for (id = 0; id < (8); id = id+1) begin : EQULZ_DBG_BER_OUT_PORT
      assign  rx_ber_tgl[id]                     = test_dbg_eqber[(id*8)];
      assign  rx_ber_total_i[(5*(id+1))-1:5*id]  = test_dbg_eqber[((id*8)+5):((id*8)+1)];
   end
endgenerate


//********************************************************************
//Test Out Bus for Debug of Equalization SM
// --Ch0
// test_dbg_eqout[0]       = rx_ts_tgl[0]             // Indicates TS1/2 Received, toggles each time a TS is received
// test_dbg_eqout[1]       = rx_ts1[0]                // Indicates if a received OS is a TS1(1) or TS2(0)
// test_dbg_eqout[2]       = rx_reject_coeff[0]       // Received TS1 "reject Coeff" field
// test_dbg_eqout[20:3]    = rx_coeff[17:0]           // Received TS1 "Coefficient" field
// test_dbg_eqout[21]      = rx_use_prst[0]           // Received TS1 "Use Preset" field
// test_dbg_eqout[25:22]   = rx_txpreset[3:0]         // Received TS1 "Rx Preset" field
// test_dbg_eqout[27:26]   = rx_ecbits[1:0]           // Received TS1 "EC" Field
// test_dbg_eqout[31:28]   = Not Connected
// ---Ch1
// test_dbg_eqout[32]      = rx_ts_tgl[1]
// test_dbg_eqout[33]      = rx_ts1[1]
// test_dbg_eqout[34]      = rx_reject_coeff[1]
// test_dbg_eqout[52:35]   = rx_coeff[35:18]
// ...
//********************************************************************

genvar ib;
generate
   for (ib = 0; ib < (8); ib = ib+1) begin : EQULZ_DBG_OUT_PORT
      assign  rx_ts_tgl[ib]                       = test_dbg_eqout[(ib*32)];
      assign  rx_ts1_i[ib]                        = test_dbg_eqout[(ib*32)+1];
      assign  rx_reject_coeff_i[ib]               = test_dbg_eqout[(ib*32)+2];
      assign  rx_coeff_i[(18*(ib+1))-1:18*ib]     = test_dbg_eqout[((ib*32)+20):((ib*32)+3)];
      assign  rx_use_prst_i[ib]                   = test_dbg_eqout[(ib*32)+21];
      assign  rx_txpreset_i[(4*(ib+1))-1:4*ib]    = test_dbg_eqout[((ib*32)+25):((ib*32)+22)];
      assign  rx_ecbits_i[(2*(ib+1))-1:2*ib]      = test_dbg_eqout[((ib*32)+27):((ib*32)+26)];
   end
endgenerate

//********************************************************************
//Test In Bus for Debug of Equalization SM when k_g3_ltssm_eq_dbg is active
//-- Ch Based on Lane Num
// tx_lntgl              =  test_dbg_eqin[0]        // Per lane Strobe Signal active when lane number is changed
// tx_ts1                =  test_dbg_eqin[1]        // Not Used
// tx_reject_coeff       =  test_dbg_eqin[2]        // Transmitted TS1 "reject Coeff" field
// tx_coeff[17:0]        =  test_dbg_eqin[20:3]     // Transmitted TS1 "Coefficient" field
// tx_use_prst           =  test_dbg_eqin[21]       // Transmitted TS1 "Use Preset" field
// tx_txpreset[3:0]      =  test_dbg_eqin[25:22]    // Transmitted TS1 "Tx Preset" field
// tx_ecbits[1:0]        =  test_dbg_eqin[27:26]    // Transmitted TS1 "EC" Field
// tx_lane_num[2:0]      =  test_dbg_eqin[30:28]    // Lane number for which the above values should be applied
// tx_alltgl             =  test_dbg_eqin[31]       // Strobe Signal indicating all lanes are updated and ready for Transmission
//
//********************************************************************
assign test_dbg_eqin[0]     = tx_lntgl;           // Per lane Strobe Signal active when lane number is changed
assign test_dbg_eqin[1]     = 1'b1;               // Not Used
assign test_dbg_eqin[2]     = tx_reject_coeff;    // Transmitted TS1 "reject Coeff" field
assign test_dbg_eqin[20:3]  = tx_coeff[17:0];     // Transmitted TS1 "Coefficient" field
assign test_dbg_eqin[21]    = tx_use_prst;        // Transmitted TS1 "Use Preset" field
assign test_dbg_eqin[25:22] = tx_txpreset[3:0];   // Transmitted TS1 "Tx Preset" field
assign test_dbg_eqin[27:26] = tx_ecbits[1:0];     // Transmitted TS1 "EC" Field
assign test_dbg_eqin[30:28] = tx_lane_num[2:0];   // Lane number for which the above values should be applied
assign test_dbg_eqin[31]    = tx_alltgl;          // Strobe Signal indicating all lanes are updated and ready for Transmission


//********************************************************************
// Synchroniser for Bit 0 of test_dbg_eqin signal (Strobe) & bit 31
//********************************************************************
altpcie_hip_bitsync2
#(
.DWIDTH      (8)
)
altpcie_hip_bitsync_strobe_in
   (
   .clk      (pld_clk),
   .rst_n    (rst_n),
   .data_in  (rx_ts_tgl),
   .data_out (rx_ts_tgl_sync)
   );

// Lane Toggle signal RE & FE
genvar ic;
generate
   for (ic = 0; ic < (8); ic = ic+1) begin : RX_TGL_RE_FE
      assign rx_ts_tgl_re[ic] =  rx_ts_tgl_sync[ic] & ~rx_ts_tgl_sync_d0[ic];
      assign rx_ts_tgl_fe[ic] = ~rx_ts_tgl_sync[ic] & rx_ts_tgl_sync_d0[ic];
   end
endgenerate

//********************************************************************
// Register Sync data
//********************************************************************
always @(negedge rst_n or posedge pld_clk) begin
   if (rst_n == 1'b0) begin
      rx_ts_tgl_sync_d0 <= 8'd0;
   end
   else begin
      rx_ts_tgl_sync_d0 <= rx_ts_tgl_sync;
   end
end

//********************************************************************
// Store TS information of  ALL Lane
//********************************************************************
always @(negedge rst_n or posedge pld_clk) begin
   if (rst_n == 1'b0) begin
      rx_ts1                         <= 1'b0;
      rx_reject_coeff                <= 1'b0;
      rx_coeff                       <= 18'd0;
      rx_use_prst                    <= 1'b0;
      rx_txpreset                    <= 4'd0;
      rx_ecbits                      <= 2'd0;
      rx_ber_total                   <= 40'd0;
      rx_ber_max                     <= 8'd0;
   end
   else begin
      // CH0
      if ((rx_ts_tgl_re[0] | rx_ts_tgl_fe[0])) begin
         rx_ts1[0]                      <= rx_ts1_i[0];
         rx_reject_coeff[0]             <= rx_reject_coeff_i[0];
         rx_coeff[(18*(0+1))-1:18*0]    <= rx_coeff_i[(18*(0+1))-1:18*0];
         rx_use_prst[0]                 <= rx_use_prst_i[0];
         rx_txpreset[(4*(0+1))-1:4*0]   <= rx_txpreset_i[(4*(0+1))-1:4*0];
         rx_ecbits[(2*(0+1))-1:2*0]     <= rx_ecbits_i[(2*(0+1))-1:2*0];
         rx_ber_total[(5*(0+1))-1:5*0]  <= rx_ber_total_i[(5*(0+1))-1:5*0];
         rx_ber_max[0]                  <= (rx_ber_total_i[(5*(0+1))-1:5*0] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH1
      if ((rx_ts_tgl_re[1] | rx_ts_tgl_fe[1])) begin
         rx_ts1[1]                      <= rx_ts1_i[1];
         rx_reject_coeff[1]             <= rx_reject_coeff_i[1];
         rx_coeff[(18*(1+1))-1:18*1]    <= rx_coeff_i[(18*(1+1))-1:18*1];
         rx_use_prst[1]                 <= rx_use_prst_i[1];
         rx_txpreset[(4*(1+1))-1:4*1]   <= rx_txpreset_i[(4*(1+1))-1:4*1];
         rx_ecbits[(2*(1+1))-1:2*1]     <= rx_ecbits_i[(2*(1+1))-1:2*1];
         rx_ber_total[(5*(1+1))-1:5*1]  <= rx_ber_total_i[(5*(1+1))-1:5*1];
         rx_ber_max[1]                  <= (rx_ber_total_i[(5*(1+1))-1:5*1] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH2
      if ((rx_ts_tgl_re[2] | rx_ts_tgl_fe[2])) begin
         rx_ts1[2]                      <= rx_ts1_i[2];
         rx_reject_coeff[2]             <= rx_reject_coeff_i[2];
         rx_coeff[(18*(2+1))-1:18*2]    <= rx_coeff_i[(18*(2+1))-1:18*2];
         rx_use_prst[2]                 <= rx_use_prst_i[2];
         rx_txpreset[(4*(2+1))-1:4*2]   <= rx_txpreset_i[(4*(2+1))-1:4*2];
         rx_ecbits[(2*(2+1))-1:2*2]     <= rx_ecbits_i[(2*(2+1))-1:2*2];
         rx_ber_total[(5*(2+1))-1:5*2]  <= rx_ber_total_i[(5*(2+1))-1:5*2];
         rx_ber_max[2]                  <= (rx_ber_total_i[(5*(2+1))-1:5*2] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH3
      if ((rx_ts_tgl_re[3] | rx_ts_tgl_fe[3])) begin
         rx_ts1[3]                      <= rx_ts1_i[3];
         rx_reject_coeff[3]             <= rx_reject_coeff_i[3];
         rx_coeff[(18*(3+1))-1:18*3]    <= rx_coeff_i[(18*(3+1))-1:18*3];
         rx_use_prst[3]                 <= rx_use_prst_i[3];
         rx_txpreset[(4*(3+1))-1:4*3]   <= rx_txpreset_i[(4*(3+1))-1:4*3];
         rx_ecbits[(2*(3+1))-1:2*3]     <= rx_ecbits_i[(2*(3+1))-1:2*3];
         rx_ber_total[(5*(3+1))-1:5*3]  <= rx_ber_total_i[(5*(3+1))-1:5*3];
         rx_ber_max[3]                  <= (rx_ber_total_i[(5*(3+1))-1:5*3] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH4
      if ((rx_ts_tgl_re[4] | rx_ts_tgl_fe[4])) begin
         rx_ts1[4]                      <= rx_ts1_i[4];
         rx_reject_coeff[4]             <= rx_reject_coeff_i[4];
         rx_coeff[(18*(4+1))-1:18*4]    <= rx_coeff_i[(18*(4+1))-1:18*4];
         rx_use_prst[4]                 <= rx_use_prst_i[4];
         rx_txpreset[(4*(4+1))-1:4*4]   <= rx_txpreset_i[(4*(4+1))-1:4*4];
         rx_ecbits[(2*(4+1))-1:2*4]     <= rx_ecbits_i[(2*(4+1))-1:2*4];
         rx_ber_total[(5*(4+1))-1:5*4]  <= rx_ber_total_i[(5*(4+1))-1:5*4];
         rx_ber_max[4]                  <= (rx_ber_total_i[(5*(4+1))-1:5*4] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH5
      if ((rx_ts_tgl_re[5] | rx_ts_tgl_fe[5])) begin
         rx_ts1[5]                      <= rx_ts1_i[5];
         rx_reject_coeff[5]             <= rx_reject_coeff_i[5];
         rx_coeff[(18*(5+1))-1:18*5]    <= rx_coeff_i[(18*(5+1))-1:18*5];
         rx_use_prst[5]                 <= rx_use_prst_i[5];
         rx_txpreset[(4*(5+1))-1:4*5]   <= rx_txpreset_i[(4*(5+1))-1:4*5];
         rx_ecbits[(2*(5+1))-1:2*5]     <= rx_ecbits_i[(2*(5+1))-1:2*5];
         rx_ber_total[(5*(5+1))-1:5*5]  <= rx_ber_total_i[(5*(5+1))-1:5*5];
         rx_ber_max[5]                  <= (rx_ber_total_i[(5*(5+1))-1:5*5] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH6
      if ((rx_ts_tgl_re[6] | rx_ts_tgl_fe[6])) begin
         rx_ts1[6]                      <= rx_ts1_i[6];
         rx_reject_coeff[6]             <= rx_reject_coeff_i[6];
         rx_coeff[(18*(6+1))-1:18*6]    <= rx_coeff_i[(18*(6+1))-1:18*6];
         rx_use_prst[6]                 <= rx_use_prst_i[6];
         rx_txpreset[(4*(6+1))-1:4*6]   <= rx_txpreset_i[(4*(6+1))-1:4*6];
         rx_ecbits[(2*(6+1))-1:2*6]     <= rx_ecbits_i[(2*(6+1))-1:2*6];
         rx_ber_total[(5*(6+1))-1:5*6]  <= rx_ber_total_i[(5*(6+1))-1:5*6];
         rx_ber_max[6]                  <= (rx_ber_total_i[(5*(6+1))-1:5*6] >= 5'h1f) ? 1'b1 : 1'b0;
      end
      // CH7
      if ((rx_ts_tgl_re[7] | rx_ts_tgl_fe[7])) begin
         rx_ts1[7]                      <= rx_ts1_i[7];
         rx_reject_coeff[7]             <= rx_reject_coeff_i[7];
         rx_coeff[(18*(7+1))-1:18*7]    <= rx_coeff_i[(18*(7+1))-1:18*7];
         rx_use_prst[7]                 <= rx_use_prst_i[7];
         rx_txpreset[(4*(7+1))-1:4*7]   <= rx_txpreset_i[(4*(7+1))-1:4*7];
         rx_ecbits[(2*(7+1))-1:2*7]     <= rx_ecbits_i[(2*(7+1))-1:2*7];
         rx_ber_total[(5*(7+1))-1:5*7]  <= rx_ber_total_i[(5*(7+1))-1:5*7];
         rx_ber_max[7]                  <= (rx_ber_total_i[(5*(7+1))-1:5*7] >= 5'h1f) ? 1'b1 : 1'b0;
      end
   end
end

//********************************************************************
// Store TS information of  ALL Lane
//********************************************************************
  // Equlization SM
   always @(negedge rst_n or posedge pld_clk) begin
      if (rst_n == 1'b0) begin
         tx_coeff_pma        <= {8{DEFAULT_PRST}};
         tx_coeff_i          <= 144'd0;
         tx_use_prst_i       <= 8'd0;
         tx_txpreset_i       <= 32'd0;
         tx_ecbits_i         <= 16'd0;
         tx_reject_coeff_i   <= 8'd0;
         dbg_hold_ltssm_eqph <= 1'b0;
         dbg_rel_ltssm_eqph  <= 1'b0;
         dbg_en_berchk_eqph  <= 1'b0;
         equlz_entered       <= 1'b0;
         legal_coeff_prst    <= 8'd0;
      end
      else begin
         dbg_en_berchk_eqph  <= 1'b0;
         case(ltssm_state)
           DET_QUIET: begin
              tx_coeff_pma        <= {8{DEFAULT_PRST}};
              equlz_entered       <= 1'b0;
              dbg_hold_ltssm_eqph <= 1'b0;
              dbg_rel_ltssm_eqph  <= 1'b0;
           end
           EQZ_PHASE_0: begin
              tx_coeff_pma        <= {8{DEFAULT_PRST}};
              dbg_hold_ltssm_eqph <= 1'b0;
              dbg_rel_ltssm_eqph  <= 1'b0;
           end
           //PRE Fill , waiting to enter Phase3
           EQZ_PHASE_2: begin
              tx_coeff_i          <= {8{PRST_COEFF_MAP0}}; // Dont care, can be anything
              tx_txpreset_i       <= {8{4'd0}};
              tx_use_prst_i       <= 8'd0;
              tx_reject_coeff_i   <= 8'd0;
              tx_ecbits_i         <= {8{2'b11}};
              dbg_hold_ltssm_eqph <= 1'b0;
              dbg_rel_ltssm_eqph  <= 1'b0;
           end
           EQZ_PHASE_3: begin
              dbg_hold_ltssm_eqph <= 1'b1;
              dbg_rel_ltssm_eqph  <= 1'b0;
              tx_ecbits_i         <= {8{2'b11}};
              if (lane_cnt == 4'd8 & rx_ecbits[1:0] == 2'b11) begin
                 if (enable_cnt == 2'd3) begin
                    tx_coeff_pma[(18*(0+1))-1:18*0] <= (~tx_reject_coeff_i[0]) ? (rx_use_prst[0] ? map_prst_coeff(rx_txpreset[(4*(0+1))-1:4*0]) : rx_coeff[(18*(0+1))-1:18*0]) : tx_coeff_pma[(18*(0+1))-1:18*0];
                    tx_coeff_pma[(18*(1+1))-1:18*1] <= (~tx_reject_coeff_i[1]) ? (rx_use_prst[1] ? map_prst_coeff(rx_txpreset[(4*(1+1))-1:4*1]) : rx_coeff[(18*(1+1))-1:18*1]) : tx_coeff_pma[(18*(1+1))-1:18*1];
                    tx_coeff_pma[(18*(2+1))-1:18*2] <= (~tx_reject_coeff_i[2]) ? (rx_use_prst[2] ? map_prst_coeff(rx_txpreset[(4*(2+1))-1:4*2]) : rx_coeff[(18*(2+1))-1:18*2]) : tx_coeff_pma[(18*(2+1))-1:18*2];
                    tx_coeff_pma[(18*(3+1))-1:18*3] <= (~tx_reject_coeff_i[3]) ? (rx_use_prst[3] ? map_prst_coeff(rx_txpreset[(4*(3+1))-1:4*3]) : rx_coeff[(18*(3+1))-1:18*3]) : tx_coeff_pma[(18*(3+1))-1:18*3];
                    tx_coeff_pma[(18*(4+1))-1:18*4] <= (~tx_reject_coeff_i[4]) ? (rx_use_prst[4] ? map_prst_coeff(rx_txpreset[(4*(4+1))-1:4*4]) : rx_coeff[(18*(4+1))-1:18*4]) : tx_coeff_pma[(18*(4+1))-1:18*4];
                    tx_coeff_pma[(18*(5+1))-1:18*5] <= (~tx_reject_coeff_i[5]) ? (rx_use_prst[5] ? map_prst_coeff(rx_txpreset[(4*(5+1))-1:4*5]) : rx_coeff[(18*(5+1))-1:18*5]) : tx_coeff_pma[(18*(5+1))-1:18*5];
                    tx_coeff_pma[(18*(6+1))-1:18*6] <= (~tx_reject_coeff_i[6]) ? (rx_use_prst[6] ? map_prst_coeff(rx_txpreset[(4*(6+1))-1:4*6]) : rx_coeff[(18*(6+1))-1:18*6]) : tx_coeff_pma[(18*(6+1))-1:18*6];
                    tx_coeff_pma[(18*(7+1))-1:18*7] <= (~tx_reject_coeff_i[7]) ? (rx_use_prst[7] ? map_prst_coeff(rx_txpreset[(4*(7+1))-1:4*7]) : rx_coeff[(18*(7+1))-1:18*7]) : tx_coeff_pma[(18*(7+1))-1:18*7];
                 end

                 //tx_coeff_i          <= rx_coeff;
                                          tx_coeff_i[(18*(0+1))-1:18*0] <= (~tx_reject_coeff_i[0]) ? (rx_use_prst[0] ? map_prst_coeff(rx_txpreset[(4*(0+1))-1:4*0]) : rx_coeff[(18*(0+1))-1:18*0]) : tx_coeff_pma[(18*(0+1))-1:18*0];
                 tx_coeff_i[(18*(1+1))-1:18*1] <= (~tx_reject_coeff_i[1]) ? (rx_use_prst[1] ? map_prst_coeff(rx_txpreset[(4*(1+1))-1:4*1]) : rx_coeff[(18*(1+1))-1:18*1]) : tx_coeff_pma[(18*(1+1))-1:18*1];
                 tx_coeff_i[(18*(2+1))-1:18*2] <= (~tx_reject_coeff_i[2]) ? (rx_use_prst[2] ? map_prst_coeff(rx_txpreset[(4*(2+1))-1:4*2]) : rx_coeff[(18*(2+1))-1:18*2]) : tx_coeff_pma[(18*(2+1))-1:18*2];
                 tx_coeff_i[(18*(3+1))-1:18*3] <= (~tx_reject_coeff_i[3]) ? (rx_use_prst[3] ? map_prst_coeff(rx_txpreset[(4*(3+1))-1:4*3]) : rx_coeff[(18*(3+1))-1:18*3]) : tx_coeff_pma[(18*(3+1))-1:18*3];
                 tx_coeff_i[(18*(4+1))-1:18*4] <= (~tx_reject_coeff_i[4]) ? (rx_use_prst[4] ? map_prst_coeff(rx_txpreset[(4*(4+1))-1:4*4]) : rx_coeff[(18*(4+1))-1:18*4]) : tx_coeff_pma[(18*(4+1))-1:18*4];
                 tx_coeff_i[(18*(5+1))-1:18*5] <= (~tx_reject_coeff_i[5]) ? (rx_use_prst[5] ? map_prst_coeff(rx_txpreset[(4*(5+1))-1:4*5]) : rx_coeff[(18*(5+1))-1:18*5]) : tx_coeff_pma[(18*(5+1))-1:18*5];
                 tx_coeff_i[(18*(6+1))-1:18*6] <= (~tx_reject_coeff_i[6]) ? (rx_use_prst[6] ? map_prst_coeff(rx_txpreset[(4*(6+1))-1:4*6]) : rx_coeff[(18*(6+1))-1:18*6]) : tx_coeff_pma[(18*(6+1))-1:18*6];
                 tx_coeff_i[(18*(7+1))-1:18*7] <= (~tx_reject_coeff_i[7]) ? (rx_use_prst[7] ? map_prst_coeff(rx_txpreset[(4*(7+1))-1:4*7]) : rx_coeff[(18*(7+1))-1:18*7]) : tx_coeff_pma[(18*(7+1))-1:18*7];
                 tx_txpreset_i       <= rx_txpreset;
                 tx_use_prst_i       <= rx_use_prst;
                 tx_reject_coeff_i[0]<= (rx_use_prst[0] ? (rx_txpreset[(4*(0+1))-1:4*0] > 4'd10) : coeff_err_chk(rx_coeff[(18*(0+1))-1:18*0]));
                 tx_reject_coeff_i[1]<= (rx_use_prst[1] ? (rx_txpreset[(4*(1+1))-1:4*1] > 4'd10) : coeff_err_chk(rx_coeff[(18*(1+1))-1:18*1]));
                 tx_reject_coeff_i[2]<= (rx_use_prst[2] ? (rx_txpreset[(4*(2+1))-1:4*2] > 4'd10) : coeff_err_chk(rx_coeff[(18*(2+1))-1:18*2]));
                 tx_reject_coeff_i[3]<= (rx_use_prst[3] ? (rx_txpreset[(4*(3+1))-1:4*3] > 4'd10) : coeff_err_chk(rx_coeff[(18*(3+1))-1:18*3]));
                 tx_reject_coeff_i[4]<= (rx_use_prst[4] ? (rx_txpreset[(4*(4+1))-1:4*4] > 4'd10) : coeff_err_chk(rx_coeff[(18*(4+1))-1:18*4]));
                 tx_reject_coeff_i[5]<= (rx_use_prst[5] ? (rx_txpreset[(4*(5+1))-1:4*5] > 4'd10) : coeff_err_chk(rx_coeff[(18*(5+1))-1:18*5]));
                 tx_reject_coeff_i[6]<= (rx_use_prst[6] ? (rx_txpreset[(4*(6+1))-1:4*6] > 4'd10) : coeff_err_chk(rx_coeff[(18*(6+1))-1:18*6]));
                 tx_reject_coeff_i[7]<= (rx_use_prst[7] ? (rx_txpreset[(4*(7+1))-1:4*7] > 4'd10) : coeff_err_chk(rx_coeff[(18*(7+1))-1:18*7]));
              end
              if (((rx_ecbits[1:0] == 2'b00) & (rx_ts1 & ACT_LANES) == ACT_LANES) | timeout_ph3) begin
                 dbg_rel_ltssm_eqph  <= 1'b1;
              end
           end
                          REC_RXLCK : begin
              dbg_hold_ltssm_eqph <= 1'b0;
              dbg_rel_ltssm_eqph  <= 1'b0;
                          end
         endcase
      end
   end

//********************************************************************
// Logic to send out TS1's
//********************************************************************
   always @(negedge rst_n or posedge pld_clk) begin
      if (rst_n == 1'b0) begin
         lane_cnt        <= 0;
         enable_cnt      <= 0;
         tx_lntgl        <= 1'b0;
         tx_reject_coeff <= 1'b0;
         tx_coeff        <= 18'd0;
         tx_use_prst     <= 1'b0;
         tx_txpreset     <= 4'd0;
         tx_ecbits       <= 2'd0;
         tx_lane_num     <= 3'd0;
         tx_alltgl       <= 1'b0;
      end
      else if (ltssm_state == EQZ_PHASE_3 | ltssm_state == EQZ_PHASE_2)  begin
         if (lane_cnt == 4'd8 & enable_cnt == 2'd3) begin
            lane_cnt    <= 4'd0;
            enable_cnt  <= 0;
         end
         else  begin
            lane_cnt    <= (enable_cnt == 2'd3) ? lane_cnt + 4'd1 : lane_cnt;
            enable_cnt  <= enable_cnt + 2'd1;
         end

         case(lane_cnt)
            4'd0:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[0];
               tx_coeff        <= tx_coeff_i[(18*(0+1))-1:18*0];
               tx_use_prst     <= tx_use_prst_i[0];
               tx_txpreset     <= tx_txpreset_i[(4*(0+1))-1:4*0];
               tx_ecbits       <= tx_ecbits_i[(2*(0+1))-1:2*0];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd1:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[1];
               tx_coeff        <= tx_coeff_i[(18*(1+1))-1:18*1];
               tx_use_prst     <= tx_use_prst_i[1];
               tx_txpreset     <= tx_txpreset_i[(4*(1+1))-1:4*1];
               tx_ecbits       <= tx_ecbits_i[(2*(1+1))-1:2*1];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd2:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[2];
               tx_coeff        <= tx_coeff_i[(18*(2+1))-1:18*2];
               tx_use_prst     <= tx_use_prst_i[2];
               tx_txpreset     <= tx_txpreset_i[(4*(2+1))-1:4*2];
               tx_ecbits       <= tx_ecbits_i[(2*(2+1))-1:2*2];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd3:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[3];
               tx_coeff        <= tx_coeff_i[(18*(3+1))-1:18*3];
               tx_use_prst     <= tx_use_prst_i[3];
               tx_txpreset     <= tx_txpreset_i[(4*(3+1))-1:4*3];
               tx_ecbits       <= tx_ecbits_i[(2*(3+1))-1:2*3];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd4:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[4];
               tx_coeff        <= tx_coeff_i[(18*(4+1))-1:18*4];
               tx_use_prst     <= tx_use_prst_i[4];
               tx_txpreset     <= tx_txpreset_i[(4*(4+1))-1:4*4];
               tx_ecbits       <= tx_ecbits_i[(2*(4+1))-1:2*4];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd5:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[5];
               tx_coeff        <= tx_coeff_i[(18*(5+1))-1:18*5];
               tx_use_prst     <= tx_use_prst_i[5];
               tx_txpreset     <= tx_txpreset_i[(4*(5+1))-1:4*5];
               tx_ecbits       <= tx_ecbits_i[(2*(5+1))-1:2*5];
               tx_lane_num     <= lane_cnt[2:0];
            end
            4'd6:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[6];
               tx_coeff        <= tx_coeff_i[(18*(6+1))-1:18*6];
               tx_use_prst     <= tx_use_prst_i[6];
               tx_txpreset     <= tx_txpreset_i[(4*(6+1))-1:4*6];
               tx_ecbits       <= tx_ecbits_i[(2*(6+1))-1:2*6];
               tx_lane_num     <= lane_cnt[2:0];
            end
            3'd7:begin
               tx_lntgl        <= (enable_cnt == 'd0) ? ~tx_lntgl : tx_lntgl;
               tx_reject_coeff <= tx_reject_coeff_i[7];
               tx_coeff        <= tx_coeff_i[(18*(7+1))-1:18*7];
               tx_use_prst     <= tx_use_prst_i[7];
               tx_txpreset     <= tx_txpreset_i[(4*(7+1))-1:4*7];
               tx_ecbits       <= tx_ecbits_i[(2*(7+1))-1:2*7];
               tx_lane_num     <= lane_cnt[2:0];
               tx_alltgl       <= (enable_cnt == 'd0) ? ~tx_alltgl : tx_alltgl;
            end
         endcase
      end
      else begin
         enable_cnt  <= 'd0;
         lane_cnt    <= 'd0;
      end
   end


//********************************************************************
// Function to convert Preset to Coeffients
//********************************************************************
function [17:0] map_prst_coeff;
   input  [3:0] txpreset_in;
   begin
      case(txpreset_in)
         4'd0   : map_prst_coeff = PRST_COEFF_MAP0;
         4'd1   : map_prst_coeff = PRST_COEFF_MAP1;
         4'd2   : map_prst_coeff = PRST_COEFF_MAP2;
         4'd3   : map_prst_coeff = PRST_COEFF_MAP3;
         4'd4   : map_prst_coeff = PRST_COEFF_MAP4;
         4'd5   : map_prst_coeff = PRST_COEFF_MAP5;
         4'd6   : map_prst_coeff = PRST_COEFF_MAP6;
         4'd7   : map_prst_coeff = PRST_COEFF_MAP7;
         4'd8   : map_prst_coeff = PRST_COEFF_MAP8;
         4'd9   : map_prst_coeff = PRST_COEFF_MAP9;
         4'd10  : map_prst_coeff = PRST_COEFF_MAP10;
         default: map_prst_coeff = PRST_COEFF_MAPERR;
      endcase
   end
endfunction

//********************************************************************
// Function check coeff is error
//********************************************************************
function  coeff_err_chk;
   input [17:0] coeff_data_in;
   reg          err_rule_a;
   reg          err_rule_b;
   reg          err_rule_ca;
   reg          err_rule_cb;
   reg          err_full_swing;
   reg          err_half_swing;
   reg          err_swing;
   reg   [5:0]  coeff_prec;
   reg   [5:0]  coeff_curs;
   reg   [5:0]  coeff_pstc;

   begin
      // Rules for Transmitter Coefficients
      coeff_pstc = coeff_data_in[17:12];
      coeff_curs = coeff_data_in[11:6];
      coeff_prec = coeff_data_in[5:0];

      err_full_swing  = (K_G3_FULL_SWING <'d24 | K_G3_FULL_SWING > 'd63) ? 1'b1 : 1'b0;
      err_half_swing  = (K_G3_FULL_SWING <'d12 | K_G3_FULL_SWING > 'd63) ? 1'b1 : 1'b0;
      err_swing       = (K_G3_EN_HALF_SWING) ? err_half_swing : err_full_swing;

      // Error Rules
      //a) |C-1| <= (FS/4);
      err_rule_a = (coeff_prec <= K_G3_FULL_SWING[5:2]) ? 1'b0 : 1'b1;

      //b) |C-1|+C0+|C+1| = FS (Do not allow peak power to change with adaptation
      err_rule_b = (({2'b00,coeff_prec} + {2'b00,coeff_curs} + {2'b00,coeff_pstc}) == {2'b00,K_G3_FULL_SWING}) ? 1'b0 : 1'b1;

      //c) C0-|C-1|-|C+1 |>= LF
      // Check if the number is positive, before subtracting
      err_rule_ca = ({2'b00,coeff_curs} >= ({2'b00,coeff_prec} + {2'b00,coeff_pstc})) ? 1'b1 : 1'b0;
      err_rule_cb = (err_rule_ca) ? ((({2'b00,coeff_curs} - ({2'b00,coeff_prec} + {2'b00,coeff_pstc})) >= {2'b00,K_G3_LOW_FREQ}) ? 1'b0 : 1'b1) : 1'b1;

      coeff_err_chk = (err_rule_a | err_rule_b | err_rule_cb | err_swing);
   end
endfunction

//********************************************************************
// phase3  32ms Timeout
//********************************************************************
  always @(negedge rst_n or posedge pld_clk) begin
      if (rst_n == 1'b0) begin
         timeout_ph3  <= 1'b0 ;
         cpt_ph3      <= 23'd0 ;
      end
      else if (ltssm_state != EQZ_PHASE_3) begin
         timeout_ph3  <= 1'b0 ;
         cpt_ph3      <= TIMEOUT_32MS;
      end
      else begin
         if (cpt_ph3 != 23'd0) begin
            cpt_ph3     <= cpt_ph3 - 23'd1 ;
            timeout_ph3 <= 1'b0 ;
         end
         else begin
            timeout_ph3 <= 1'b1 ;
         end
      end
   end

endmodule
/////////////////////////////////////////////////
// Module instantiations for PTC CV enable_pcisigtest
// Sync modules used in PTC CV

module altpcie_hip_bitsync2
  #(
    parameter DWIDTH    = 1,    // Sync Data input
    parameter RESET_VAL = 0     // Reset value
    )
    (
    input  wire              clk,     // clock
    input  wire              rst_n,   // async reset
    input  wire [DWIDTH-1:0] data_in, // data in
    output wire [DWIDTH-1:0] data_out // data out
     );

// 2-stage synchronizer
localparam SYNCSTAGE = 2;

// synchronizer
altpcie_hip_bitsync
  #(
    .DWIDTH(DWIDTH),        // Sync Data input
    .SYNCSTAGE(SYNCSTAGE),  // Sync stages
    .RESET_VAL(RESET_VAL)   // Reset value
    ) altpcie_hip_bitsync2
    (
     .clk(clk),          // clock
     .rst_n(rst_n),      // async reset
     .data_in(data_in),  // data in
     .data_out(data_out) // data out
     );

endmodule // altpcie_hip_bitsync2

module altpcie_hip_bitsync
  #(
    parameter DWIDTH = 1,    // Sync Data input
    parameter SYNCSTAGE = 2, // Sync stages
    parameter RESET_VAL = 0  // Reset value
    )
    (
    input  wire              clk,     // clock
    input  wire              rst_n,   // async reset
    input  wire [DWIDTH-1:0] data_in, // data in
    output wire [DWIDTH-1:0] data_out // data out
     );

   // Define wires/regs
   reg [(DWIDTH*SYNCSTAGE)-1:0] sync_regs;
   wire                         reset_value;

   assign reset_value = (RESET_VAL == 1) ? 1'b1 : 1'b0;  // To eliminate truncating warning

   // Sync Always block
   always @(negedge rst_n or posedge clk) begin
      if (rst_n == 1'b0) begin
         sync_regs[(DWIDTH*SYNCSTAGE)-1:DWIDTH] <= {(DWIDTH*(SYNCSTAGE-1)){reset_value}};
      end
      else begin
         sync_regs[(DWIDTH*SYNCSTAGE)-1:DWIDTH] <= sync_regs[((DWIDTH*(SYNCSTAGE-1))-1):0];
      end
   end

   // Separated out the first stage of FFs without reset
   always @(posedge clk) begin
         sync_regs[DWIDTH-1:0] <= data_in;
   end

   assign data_out = sync_regs[((DWIDTH*SYNCSTAGE)-1):(DWIDTH*(SYNCSTAGE-1))];

endmodule // altpcie_hip_bitsync

module altpcie_hip_vecsync2
   #(
      parameter DWIDTH           = 2 // Sync Data input
    )
   (
   // Inputs
   input  wire               wr_clk,        // write clock
   input  wire               rd_clk,        // read clock
   input  wire               wr_rst_n,      // async write reset
   input  wire               rd_rst_n,      // async read reset
   input  wire [DWIDTH-1:0]  data_in,       // data in
   // Outputs
   output wire  [DWIDTH-1:0] data_out       // data out
   );

// 2-stage synchronizer
localparam SYNCSTAGE = 2;

// Vecsync module
altpcie_hip_vecsync
   #(
      .DWIDTH(DWIDTH),       // Sync Data input
      .SYNCSTAGE(SYNCSTAGE)  // Sync stages
    ) altpcie_hip_vecsync2
   (
   // Inputs
   .wr_clk(wr_clk),         // write clock
   .rd_clk(rd_clk),         // read clock
   .wr_rst_n(wr_rst_n),     // async write reset
   .rd_rst_n(rd_rst_n),     // async read reset
   .data_in(data_in),       // data in
   // Outputs
   .data_out(data_out)      // data out
   );

endmodule // altpcie_hip_vecsync2

module altpcie_hip_vecsync
   #(
      parameter DWIDTH           = 2, // Sync Data input
      parameter SYNCSTAGE        = 2  // Sync stages
    )
   (
   // Inputs
   input  wire               wr_clk,        // write clock
   input  wire               rd_clk,        // read clock
   input  wire               wr_rst_n,      // async write reset
   input  wire               rd_rst_n,      // async read reset
   input  wire [DWIDTH-1:0]  data_in,       // data in
   // Outputs
   output reg  [DWIDTH-1:0]  data_out       // data out
   );

//******************************************************************************
// Define regs
//******************************************************************************
reg  [DWIDTH-1:0]  data_in_d0;
reg                req_wr_clk;
wire               req_rd_clk;
wire               ack_wr_clk;
wire               ack_rd_clk;
reg                req_rd_clk_d0;

//******************************************************************************
// WRITE CLOCK DOMAIN: Generate req & Store data when synchroniztion is not
// already in progress
//******************************************************************************
always @(negedge wr_rst_n or posedge wr_clk) begin
   if (wr_rst_n == 1'b0) begin
      data_in_d0 <= {DWIDTH{1'b0}};
      req_wr_clk <= 1'b0;
   end
   else begin
      // Store data when Write Req equals Write Ack
      if (req_wr_clk == ack_wr_clk) begin
         data_in_d0 <= data_in;
      end

      // Generate a Req when there is change in data
      if ((req_wr_clk == ack_wr_clk) & (data_in_d0 != data_in)) begin
         req_wr_clk <= ~req_wr_clk;
      end
   end
end

//******************************************************************************
// WRITE CLOCK DOMAIN:
//******************************************************************************
altpcie_hip_bitsync
#(
.DWIDTH      (1),         // Sync Data input
.SYNCSTAGE   (SYNCSTAGE)  // Sync stages
)
u_ack_wr_clk
   (
   .clk      (wr_clk),
   .rst_n    (wr_rst_n),
   .data_in  (ack_rd_clk),
   .data_out (ack_wr_clk)
   );
assign ack_rd_clk = req_rd_clk_d0;

//******************************************************************************
// READ CLOCK DOMAIN:
//******************************************************************************
altpcie_hip_bitsync
#(
.DWIDTH      (1),         // Sync Data input
.SYNCSTAGE   (SYNCSTAGE)  // Sync stages
)
u_req_rd_clk
(
   .clk      (rd_clk),
   .rst_n    (rd_rst_n),
   .data_in  (req_wr_clk),
   .data_out (req_rd_clk)
);

//******************************************************************************
// READ CLOCK DOMAIN:
//******************************************************************************
always @(negedge rd_rst_n or posedge rd_clk) begin
   if (rd_rst_n == 1'b0) begin
      data_out      <= {DWIDTH{1'b0}};
      req_rd_clk_d0 <= 1'b0;
   end
   else begin
      req_rd_clk_d0 <= req_rd_clk;
      if (req_rd_clk_d0 != req_rd_clk) begin
         data_out <= data_in_d0;
      end
   end
end


endmodule // altpcie_hip_vecsync

// End sync modules
