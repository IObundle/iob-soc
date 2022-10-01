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


// DCD control data and address 
//
// This module has the data and addresses for the PHY registers. 
//
// It decodes state and PCS register count from the DCD control module.

// $Header$

`timescale 1 ns / 1 ps
module alt_xcvr_reconfig_dcd_datapath (
    input  wire        clk,
    input  wire [5:0]  state,
    input  wire [4:0]  pcs_reg_count,    
    output wire        pcs_reg_count_tc,
    input  wire        ctrl_done,
    input  wire [15:0] ctrl_rdata,
    input  wire [2:0]  dcd_ctr,
    input  wire [2:0]  best_dcd_ctr,
    
    output reg  [11:0] ctrl_addr,
    output reg  [15:0] ctrl_wdata
 );  
 
// states  
localparam [3:0] STATE_IDLE           = 4'h0;
localparam [3:0] STATE_RD_PHY_REQ     = 4'h1;
localparam [3:0] STATE_RD_PHY_ID      = 4'h2;
localparam [3:0] STATE_RD_SETUP       = 4'h3;
localparam [3:0] STATE_WR_SETUP       = 4'h4;
localparam [3:0] STATE_RESET_PLL      = 4'h5;
localparam [3:0] STATE_RD_DCD         = 4'h6;
localparam [3:0] STATE_WR_DCD         = 4'h7;
localparam [3:0] STATE_EYE_DCD        = 4'h8;
localparam [3:0] STATE_WR_BEST        = 4'h9;
localparam [3:0] STATE_RD_RESTORE     = 4'ha;
localparam [3:0] STATE_WR_RESTORE     = 4'hb;
localparam [3:0] STATE_RESET_OVR_OFF  = 4'hc;
localparam [3:0] STATE_DONE           = 4'hd;

// register addresses
import sv_xcvr_h::*;
 
// non PCS register bits values
localparam       EYE_MON_SEL       = 1'b1;   // EYE mon / CDR data
localparam       TEST_DATA_EN      = 1'b1;   // test pattern
localparam       PHY_TX_ID         = 1'b1;   // PHY TX present
localparam       PHY_RX_ID         = 1'b1;   // PHY RX present
localparam       PHY_TX_RESET      = 1'b1;   // PHY TX_reset
localparam       PHY_RX_RESET      = 1'b1;   // PHY RX reset
localparam       PHY_LPBK          = 1'b1;   // PHY loopback
localparam [2:0] REYE_ISEL_ON      = 3'b010; // ISEL on 
localparam [2:0] REYE_ISEL_OFF     = 3'b001; // ISEL off
localparam       REYE_PDB_ON       = 1'b1;   // power on
localparam       TX_RST_OVR_ON     = 1'b1;   // override user PLL reset settings
localparam       RX_RST_OVR_ON     = 1'b1;   // override user PLL reset settings
localparam       TX_DIGITAL_RST_ON = 1'b0;   // tx digital reset
localparam       RX_DIGITAL_RST_ON = 1'b0;   // rx digital reset
localparam       RX_ANALOG_RST_ON  = 1'b0;   // rx analog res

// PCS register bit values
// PCS_8G_CTRL_6 
localparam       PCS8G6_RRX_PCS_BYPASS_EN                    = 1'b1; 
// PCS_8G_CTRL_7 
localparam       PCS8G7_RUNNING_DISPARITY_DIS                = 1'b1; 
// PCS_8G_CTRL_10 
localparam       PCS8G10_SYNC_STATE_MACHINE_DIS              = 1'b1;
// PCS_8G_CTRL_12 
localparam       PCS8G12_PCIE_POLARITY_INVERSION_DIS         = 1'b0;
localparam       PCS8G12_CASCADED_8B10B_DECODER_RX_DIS       = 1'b0;
localparam       PCS8G12_8B10B_COMPLIANCE_0_EN               = 1'b1;
localparam       PCS8G12_8B10B_COMPLIANCE_1_EN               = 1'b0; 
localparam       PCS8G12_8B10B_DIS                           = 1'b0;
localparam       PCS8G12_BIT_SLIP_MODE_DIS                   = 1'b0;
localparam       PCS8G12_RUN_LENGTH_CHECK_DIS                = 1'b0; 
localparam       PCS8G12_LOOPBACK_FROM_8B_10B_DIS            = 1'b0;
localparam       PCS8G12_RX_PMA_SIGNAL_DETECT_IGN            = 1'b1;
localparam       PCS8G12_RX_BYTE_SWAP_IGN                    = 1'b0;
// PCS_8G_CTRL_13 
localparam       PCS8G13_CLOCK_COMPENSATION_DIS              = 1'b0;
// PCS_8G_CTRL_17 
localparam       PCS8G17_AUTO_SPEED_NEGOTIATION_DIS          = 1'b0;
localparam       PCS8G17_DATA_WIDTH_SCALING_EN               = 1'b0;
localparam       PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3_DIS     = 1'b0; 
// PCS_8G_CTRL_18
localparam       PCS8G18_ERROR_REPLACE_DIS                   = 1'b1;
localparam       PCS8G18_NON_DEBUG_MODE_EN                   = 1'b0;
localparam       PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING_EN    = 1'b0;
localparam       PCS8G18_BYTE_ORDERING_0_DIS                 = 1'b0;
localparam       PCS8G18_BYTE_ORDERING_1_DIS                 = 1'b0;
localparam       PCS8G18_INVALID_CODE_REPLACEMENT_DIS        = 1'b0;
localparam       PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET_EN  = 1'b0;
localparam       PCS8GPCS8G18_PHASE_COMP_FIFO_USER_RESET_IGN = 1'b0;
localparam       PCS8G18_LOW_LATENCY_FIFO_MODE_EN            = 1'b1;
localparam       PCS8G18_BYPASS_RX_FIFO_DIS                  = 1'b0;
// PCS_8G_CTRL_30 
localparam       PCS8G30_DW_SYNC_SM_DIS                      = 1'b0;
// PCS_10G_RX_CTRL_1 
localparam       PCS10GR1_BYPASS_64_66_DECODER_EN            = 1'b1;
localparam       PCS10GR1_BYPASS_RX_STATE_MACHINE_EN         = 1'b1;
localparam       PCS10GR1_BYPASS_RX_DESCRAMBLER_EN           = 1'b1;
localparam       PCS10GR1_RX_BITSLIP_DIS                     = 1'b0;
localparam       PCS10GR1_BYPASS_RX_BLOCK_SYNC_EN            = 1'b1;
localparam       PCS10GR1_PARALLEL_LOOPBACK_DIS              = 1'b0;
// PCS_10G_RX_CTRL6 
localparam       PCS10GR6_BYPASS_FRAME_SYNC_EN               = 1'b1;
localparam       PCS10GR6_BYPASS_CRC32_CHECKER_EN            = 1'b1;
localparam       PCS10GR6_BYPASS_DISPARITY_CHECKER_EN        = 1'b1;
// PCS_10G_RX_CTRL10 
localparam       PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO_EN    = 1'b1;
// PCS_10G_RX_CTRL12 
localparam       PCS10GR12_PHASE_COMP_MODE_0_SEL             = 1'b0;
localparam       PCS10GR12_PHASE_COMP_MODE_1_SEL             = 1'b0;
localparam       PCS10GR12_PHASE_COMP_MODE_2_SEL             = 1'b0;

// PCS count register assignments
localparam [4:0] PCS_RESET  = 5'h00;
localparam [4:0] PCS_8G6    = 5'h01;
localparam [4:0] PCS_8G7    = 5'h02;
localparam [4:0] PCS_8G10   = 5'h03;
localparam [4:0] PCS_8G12   = 5'h04;
localparam [4:0] PCS_8G13   = 5'h05;
localparam [4:0] PCS_8G17   = 5'h06;
localparam [4:0] PCS_8G18   = 5'h07;
localparam [4:0] PCS_8G30   = 5'h08;
localparam [4:0] PCS_10G1   = 5'h09;
localparam [4:0] PCS_10G6   = 5'h0a;
localparam [4:0] PCS_10G10  = 5'h0b;
localparam [4:0] PCS_10G12  = 5'h0c;
localparam [4:0] PMA_LOOP   = 5'h0d;
localparam [4:0] PMA_PDB    = 5'h0e;    
localparam [4:0] PMA_EYE    = 5'h0f;
localparam [4:0] PMA_TEST   = 5'h10;

// declarations
reg  [11:0]  pcs_ctrl_addr;
reg  [15:0]  dcd_rdata;

reg  [15:0]  ctrl_pcs_bypass_wdata;
reg  [15:0]  ctrl_pcs_user_wdata; 

reg          pcs8g6_rrx_pcs_bypass_user;
reg          pcs8g7_running_disparity_user;
reg          pcs8g10_sync_state_machine_user;
reg          pcs8g12_pcie_polarity_inversion_user;
reg          pcs8g12_cascaded_8b10b_decoder_rx_user;
reg          pcs8g12_8b10b_compliance_1_user;
reg          pcs8g12_8b10b_compliance_0_user;               
reg          pcs8g12_mode_8b10b_user;                       
reg          pcs8g12_bit_slip_mode_user;
reg          pcs8g12_run_length_check_user;
reg          pcs8g12_loopback_from_8b_10b_user;
reg          pcs8g12_rx_pma_signal_detect_user;
reg          pcs8g12_rx_byte_swap_user;
reg          pcs8g13_clock_compensation_user;
reg          pcs8g17_auto_speed_negotiation_user;
reg          pcs8g17_data_width_scaling_user;
reg          pcs8g17_auto_speed_negotiation_gen3_user; 
reg          pcs8g18_error_replace_user;
reg          pcs8g18_non_debug_mode_user;
reg          pcs8g18_hssi_controlled_byte_ordering_user;
reg          pcs8g18_byte_ordering_1_user;
reg          pcs8g18_byte_ordering_0_user;
reg          pcs8g18_invalid_code_replacement_user;
reg          pcs8g18_cram_phase_comp_fifo_user_reset_user;
reg          pcs8g18_phase_comp_fifo_user_reset_user;
reg          pcs8g18_low_latency_fifo_mode_user;
reg          pcs8g18_bypass_rx_fifo_user;
reg          pcs8g30_dw_sync_sm_user;
reg          pcs10gr1_bypass_64_66_decoder_user;
reg          pcs10gr1_bypass_rx_state_machine_user;
reg          pcs10gr1_bypass_rx_descrambler_user;
reg          pcs10gr1_rx_bitslip_user;
reg          pcs10gr1_bypass_rx_block_sync_user;
reg          pcs10gr1_parallel_loopback_user;
reg          pcs10gr6_bypass_frame_sync_user;
reg          pcs10gr6_bypass_crc32_checker_user;
reg          pcs10gr6_bypass_disparity_checker_user;
reg          pcs10gr10_fast_bypass_gearbox_rx_fifo_user;
reg          pcs10gr12_phase_comp_mode_2_user;
reg          pcs10gr12_phase_comp_mode_1_user;
reg          pcs10gr12_phase_comp_mode_0_user;

// terminal count for PCS counter
assign pcs_reg_count_tc = (pcs_reg_count == PMA_TEST);

//------------------------------------------------------------ 
// ctrl_addr
//------------------------------------------------------------  
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:          ctrl_addr <= 12'hxxx;
        STATE_RD_PHY_REQ:    ctrl_addr <= SV_XR_ABS_ADDR_REQUEST;
        STATE_RD_PHY_ID:     ctrl_addr <= SV_XR_ABS_ADDR_ID;
        STATE_RD_SETUP:      ctrl_addr <= pcs_ctrl_addr;
        STATE_WR_SETUP:      ctrl_addr <= pcs_ctrl_addr;
        STATE_RESET_PLL:     ctrl_addr <= 12'hxxx;
        STATE_RD_DCD:        ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_WR_DCD:        ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_EYE_DCD:       ctrl_addr <= 12'hxxx;    
        STATE_WR_BEST:       ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_RD_RESTORE:    ctrl_addr <= pcs_ctrl_addr;
        STATE_WR_RESTORE:    ctrl_addr <= pcs_ctrl_addr;
        STATE_RESET_OVR_OFF: ctrl_addr <= SV_XR_ABS_ADDR_RSTCTL;
        STATE_DONE:          ctrl_addr <= 12'hxxx;
        default:             ctrl_addr <= 12'hxxx;
    endcase
end    

// pcs_ctrl_addr 
always @(posedge clk)
begin
    case (pcs_reg_count)
        PCS_RESET: pcs_ctrl_addr <= SV_XR_ABS_ADDR_RSTCTL;
        PCS_8G6:   pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_6;
        PCS_8G7:   pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_7;
        PCS_8G10:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_10;
        PCS_8G12:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_12;
        PCS_8G13:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_13;
        PCS_8G17:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_17;
        PCS_8G18:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_18;
        PCS_8G30:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_8G_CTRL_30;
        PCS_10G1:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_10G_RX_CTRL_1;
        PCS_10G6:  pcs_ctrl_addr <= RECONFIG_PCS_CH0_10G_RX_CTRL_6;
        PCS_10G10: pcs_ctrl_addr <= RECONFIG_PCS_CH0_10G_RX_CTRL_10;
        PCS_10G12: pcs_ctrl_addr <= RECONFIG_PCS_CH0_10G_RX_CTRL_12;
        PMA_LOOP:  pcs_ctrl_addr <= SV_XR_ABS_ADDR_SLPBK;
        PMA_PDB:   pcs_ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;    
        PMA_EYE:   pcs_ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_EYE;
        PMA_TEST:  pcs_ctrl_addr <= RECONFIG_PMA_CH0_DCD_RSER_CLK_MON;
        default:   pcs_ctrl_addr <= 12'hxxx;
    endcase
end    

//------------------------------------------------------------ 
// ctrl_wdata 
//------------------------------------------------------------ 
always @(posedge clk)
begin
    case (state)
        STATE_WR_SETUP :      ctrl_wdata                     <= ctrl_pcs_bypass_wdata;
                         
        STATE_WR_DCD:         begin
                                   ctrl_wdata                <=  dcd_rdata;
                                   ctrl_wdata[RSER_DC_TUNE_2_OFST : RSER_DC_TUNE_0_OFST]
                                                             <=  dcd_ctr;
                              end
                                                          
        STATE_WR_BEST:        begin
                                   ctrl_wdata                <=  dcd_rdata;
                                   ctrl_wdata[RSER_DC_TUNE_2_OFST : RSER_DC_TUNE_0_OFST] 
                                                             <=  best_dcd_ctr;
                              end
                                  
        STATE_WR_RESTORE:     ctrl_wdata                     <= ctrl_pcs_user_wdata;
           
        STATE_RESET_OVR_OFF:  begin
                                  ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]
                                                             <= ~TX_RST_OVR_ON;
                                  ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST]
                                                             <= ~TX_DIGITAL_RST_ON;
                                  ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]
                                                             <= ~RX_RST_OVR_ON;
                                  ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST]
                                                             <= ~RX_DIGITAL_RST_ON;
                                  ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]
                                                             <= ~RX_ANALOG_RST_ON;
                               end
                                                           
        default:               ctrl_wdata                    <=  16'hxxxx;
    endcase
end

// save dcd counter register for RMW during calibration
always @(posedge clk)
begin
    if ((state == STATE_RD_DCD) && ctrl_done)
         dcd_rdata <= ctrl_rdata;
end 

// PCS/PHY register setup 
always @(posedge clk)
begin
    case (pcs_reg_count)
        PCS_RESET: begin
                        ctrl_pcs_bypass_wdata
                              <= ctrl_rdata;
  
                        ctrl_pcs_bypass_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]
                              <= TX_RST_OVR_ON;
                              
                        ctrl_pcs_bypass_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST]
                              <= TX_DIGITAL_RST_ON;
                              
                        ctrl_pcs_bypass_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]
                              <= RX_RST_OVR_ON;
                              
                        ctrl_pcs_bypass_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST]
                              <= RX_DIGITAL_RST_ON;
                              
                        ctrl_pcs_bypass_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]
                              <= RX_ANALOG_RST_ON;
                   end
                           
        PCS_8G6:   begin
                        ctrl_pcs_bypass_wdata 
                              <= ctrl_rdata;
  
                        ctrl_pcs_bypass_wdata[PCS8G6_RRX_PCS_BYPASS]
                              <= PCS8G6_RRX_PCS_BYPASS_EN;
                   end
                                
        PCS_8G7:   begin
                        ctrl_pcs_bypass_wdata
                              <= ctrl_rdata;
  
                        ctrl_pcs_bypass_wdata[PCS8G7_RUNNING_DISPARITY]
                              <= PCS8G7_RUNNING_DISPARITY_DIS;
                   end
          
        PCS_8G10:  begin
                        ctrl_pcs_bypass_wdata
                              <= ctrl_rdata;
  
                        ctrl_pcs_bypass_wdata[PCS8G10_SYNC_STATE_MACHINE]
                              <= PCS8G10_SYNC_STATE_MACHINE_DIS;
                   end

        PCS_8G12:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;
  
                       ctrl_pcs_bypass_wdata[PCS8G12_PCIE_POLARITY_INVERSION]
                             <= PCS8G12_PCIE_POLARITY_INVERSION_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_CASCADED_8B10B_DECODER_RX]
                             <= PCS8G12_CASCADED_8B10B_DECODER_RX_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_8B10B_COMPLIANCE_1]
                             <= PCS8G12_8B10B_COMPLIANCE_1_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_8B10B_COMPLIANCE_0]
                             <= PCS8G12_8B10B_COMPLIANCE_0_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_8B10B]
                             <= PCS8G12_8B10B_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_BIT_SLIP_MODE]
                             <= PCS8G12_BIT_SLIP_MODE_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_RUN_LENGTH_CHECK]
                             <= PCS8G12_RUN_LENGTH_CHECK_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_LOOPBACK_FROM_8B_10B]
                             <= PCS8G12_LOOPBACK_FROM_8B_10B_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_RX_PMA_SIGNAL_DETECT]
                             <= PCS8G12_RX_PMA_SIGNAL_DETECT_IGN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G12_RX_BYTE_SWAP]
                             <= PCS8G12_RX_BYTE_SWAP_IGN;
                   end
                               
        PCS_8G13:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;
  
                       ctrl_pcs_bypass_wdata[PCS8G13_CLOCK_COMPENSATION]
                             <= PCS8G13_CLOCK_COMPENSATION_DIS;
                   end
                             
        PCS_8G17:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS8G17_AUTO_SPEED_NEGOTIATION]
                             <= PCS8G17_AUTO_SPEED_NEGOTIATION_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G17_DATA_WIDTH_SCALING]
                             <= PCS8G17_DATA_WIDTH_SCALING_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3]
                             <= PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3_DIS;
                   end 
        
        PCS_8G18:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS8G18_ERROR_REPLACE]
                             <= PCS8G18_ERROR_REPLACE_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_NON_DEBUG_MODE]
                             <= PCS8G18_NON_DEBUG_MODE_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING]
                             <= PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_BYTE_ORDERING_0]
                             <= PCS8G18_BYTE_ORDERING_0_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_BYTE_ORDERING_1]
                             <= PCS8G18_BYTE_ORDERING_1_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_INVALID_CODE_REPLACEMENT]
                             <= PCS8G18_INVALID_CODE_REPLACEMENT_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET]
                             <= PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_PHASE_COMP_FIFO_USER_RESET]
                             <= PCS8GPCS8G18_PHASE_COMP_FIFO_USER_RESET_IGN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_LOW_LATENCY_FIFO_MODE]
                             <= PCS8G18_LOW_LATENCY_FIFO_MODE_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS8G18_BYPASS_RX_FIFO]
                             <= PCS8G18_BYPASS_RX_FIFO_DIS; 
                   end
       
        PCS_8G30:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS8G30_DW_SYNC_SM]
                             <= PCS8G30_DW_SYNC_SM_DIS;
                   end
         
        PCS_10G1:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;
 
                       ctrl_pcs_bypass_wdata[PCS10GR1_BYPASS_64_66_DECODER]
                             <= PCS10GR1_BYPASS_64_66_DECODER_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR1_BYPASS_RX_STATE_MACHINE]
                             <= PCS10GR1_BYPASS_RX_STATE_MACHINE_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR1_BYPASS_RX_DESCRAMBLER]
                             <= PCS10GR1_BYPASS_RX_DESCRAMBLER_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR1_RX_BITSLIP]
                             <= PCS10GR1_RX_BITSLIP_DIS;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR1_BYPASS_RX_BLOCK_SYNC]
                             <= PCS10GR1_BYPASS_RX_BLOCK_SYNC_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR1_PARALLEL_LOOPBACK]
                             <= PCS10GR1_PARALLEL_LOOPBACK_DIS;
                   end
              
        PCS_10G6:  begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS10GR6_BYPASS_FRAME_SYNC]
                             <= PCS10GR6_BYPASS_FRAME_SYNC_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR6_BYPASS_CRC32_CHECKER]
                             <= PCS10GR6_BYPASS_CRC32_CHECKER_EN;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR6_BYPASS_DISPARITY_CHECKER]
                             <= PCS10GR6_BYPASS_DISPARITY_CHECKER_EN; 
                   end
    
        PCS_10G10: begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO]
                             <= PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO_EN;
                   end  
        
        PCS_10G12: begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[PCS10GR12_PHASE_COMP_MODE_2]
                             <= PCS10GR12_PHASE_COMP_MODE_2_SEL;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR12_PHASE_COMP_MODE_1]
                             <= PCS10GR12_PHASE_COMP_MODE_1_SEL;
                             
                       ctrl_pcs_bypass_wdata[PCS10GR12_PHASE_COMP_MODE_0]
                             <= PCS10GR12_PHASE_COMP_MODE_0_SEL;
                   end
        
        PMA_LOOP:  begin 
                       ctrl_pcs_bypass_wdata
                             <= 16'h0000;

                       ctrl_pcs_bypass_wdata[SV_XR_SLPBK_SLPBKEN_OFST]
                            <=  PHY_LPBK;
                   end
          
        PMA_PDB:   begin
                       ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_bypass_wdata[REYE_PDB]
                             <= REYE_PDB_ON;

                       ctrl_pcs_bypass_wdata[REYE_ISEL_2:REYE_ISEL_0]
                             <= REYE_ISEL_ON; 
                   end                                            
                                   
        PMA_EYE:    begin
                        ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                        ctrl_pcs_bypass_wdata[RCRU_EYE_OFST]
                             <=  EYE_MON_SEL;
                    end        

        PMA_TEST:   begin
                        ctrl_pcs_bypass_wdata
                             <= ctrl_rdata;

                        ctrl_pcs_bypass_wdata[RSER_CLK_MON_OFST]
                             <= TEST_DATA_EN;
                    end       

        default:   ctrl_pcs_bypass_wdata <= 16'hxxxx;
    endcase
end 
        
 // save user PCS register values 
always @(posedge clk)
begin
    if ((state == STATE_RD_SETUP) && ctrl_done)
        case (pcs_reg_count)
        
            PCS_8G6:   pcs8g6_rrx_pcs_bypass_user
                             <= ctrl_rdata[PCS8G6_RRX_PCS_BYPASS];  
                                 
            PCS_8G7:   pcs8g7_running_disparity_user
                             <= ctrl_rdata[PCS8G7_RUNNING_DISPARITY];
            
            PCS_8G10:  pcs8g10_sync_state_machine_user
                             <= ctrl_rdata[PCS8G10_SYNC_STATE_MACHINE];            
                                    
            PCS_8G12:  begin
                           pcs8g12_pcie_polarity_inversion_user
                                   <= ctrl_rdata[PCS8G12_PCIE_POLARITY_INVERSION];
                                   
                           pcs8g12_cascaded_8b10b_decoder_rx_user
                                   <= ctrl_rdata[PCS8G12_CASCADED_8B10B_DECODER_RX];
                                   
                           pcs8g12_8b10b_compliance_1_user
                                   <= ctrl_rdata[PCS8G12_8B10B_COMPLIANCE_1];
                                   
                           pcs8g12_8b10b_compliance_0_user               
                                   <= ctrl_rdata[PCS8G12_8B10B_COMPLIANCE_0];
                                   
                           pcs8g12_mode_8b10b_user                       
                                   <= ctrl_rdata[PCS8G12_8B10B];
                                   
                           pcs8g12_bit_slip_mode_user
                                   <= ctrl_rdata[PCS8G12_BIT_SLIP_MODE];
                                   
                           pcs8g12_run_length_check_user
                                   <= ctrl_rdata[PCS8G12_RUN_LENGTH_CHECK];
                                   
                           pcs8g12_loopback_from_8b_10b_user
                                   <= ctrl_rdata[PCS8G12_LOOPBACK_FROM_8B_10B];
                                   
                           pcs8g12_rx_pma_signal_detect_user
                                   <= ctrl_rdata[PCS8G12_RX_PMA_SIGNAL_DETECT];
                                   
                           pcs8g12_rx_byte_swap_user
                                   <= ctrl_rdata[PCS8G12_RX_BYTE_SWAP];
                       end
                              
            PCS_8G13:  pcs8g13_clock_compensation_user
                              <= ctrl_rdata[PCS8G13_CLOCK_COMPENSATION];
             
            PCS_8G17:  begin
                           pcs8g17_auto_speed_negotiation_user
                                   <= ctrl_rdata[PCS8G17_AUTO_SPEED_NEGOTIATION];
                                   
                           pcs8g17_data_width_scaling_user
                                   <= ctrl_rdata[PCS8G17_DATA_WIDTH_SCALING];
                                   
                           pcs8g17_auto_speed_negotiation_gen3_user 
                                   <= ctrl_rdata[PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3];
                       end 
        
            PCS_8G18:  begin
                           pcs8g18_error_replace_user
                                   <= ctrl_rdata[PCS8G18_ERROR_REPLACE];
                                   
                           pcs8g18_non_debug_mode_user
                                   <= ctrl_rdata[PCS8G18_NON_DEBUG_MODE];
                                   
                           pcs8g18_hssi_controlled_byte_ordering_user
                                   <= ctrl_rdata[PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING];
                                   
                           pcs8g18_byte_ordering_1_user
                                   <= ctrl_rdata[PCS8G18_BYTE_ORDERING_1];
                                   
                           pcs8g18_byte_ordering_0_user
                                   <= ctrl_rdata[PCS8G18_BYTE_ORDERING_0];
                                   
                           pcs8g18_invalid_code_replacement_user
                                   <= ctrl_rdata[PCS8G18_INVALID_CODE_REPLACEMENT];
                                   
                           pcs8g18_cram_phase_comp_fifo_user_reset_user
                                   <= ctrl_rdata[PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET];
                                   
                           pcs8g18_phase_comp_fifo_user_reset_user
                                   <= ctrl_rdata[PCS8G18_PHASE_COMP_FIFO_USER_RESET];
                                   
                           pcs8g18_low_latency_fifo_mode_user
                                   <= ctrl_rdata[PCS8G18_LOW_LATENCY_FIFO_MODE];
                                   
                           pcs8g18_bypass_rx_fifo_user
                                   <= ctrl_rdata[PCS8G18_BYPASS_RX_FIFO];
                       end
       
             PCS_8G30: pcs8g30_dw_sync_sm_user
                               <= ctrl_rdata[PCS8G30_DW_SYNC_SM];
         
             PCS_10G1: begin 
                           pcs10gr1_bypass_64_66_decoder_user
                                  <= ctrl_rdata[PCS10GR1_BYPASS_64_66_DECODER];
                                  
                           pcs10gr1_bypass_rx_state_machine_user
                                  <= ctrl_rdata[PCS10GR1_BYPASS_RX_STATE_MACHINE];
                                  
                           pcs10gr1_bypass_rx_descrambler_user
                                  <= ctrl_rdata[PCS10GR1_BYPASS_RX_DESCRAMBLER];
                                  
                           pcs10gr1_rx_bitslip_user
                                  <= ctrl_rdata[PCS10GR1_RX_BITSLIP];
                                  
                           pcs10gr1_bypass_rx_block_sync_user
                                  <= ctrl_rdata[PCS10GR1_BYPASS_RX_BLOCK_SYNC];
                                  
                           pcs10gr1_parallel_loopback_user
                                  <= ctrl_rdata[PCS10GR1_PARALLEL_LOOPBACK];
                      end
              
            PCS_10G6: begin
                          pcs10gr6_bypass_frame_sync_user
                                  <= ctrl_rdata[PCS10GR6_BYPASS_FRAME_SYNC];
                                  
                          pcs10gr6_bypass_crc32_checker_user
                                  <= ctrl_rdata[PCS10GR6_BYPASS_CRC32_CHECKER];
                                  
                          pcs10gr6_bypass_disparity_checker_user
                                  <= ctrl_rdata[PCS10GR6_BYPASS_DISPARITY_CHECKER];
                      end
    
            PCS_10G10: pcs10gr10_fast_bypass_gearbox_rx_fifo_user
                                  <= ctrl_rdata[PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO];    
         
            PCS_10G12: begin
                           pcs10gr12_phase_comp_mode_2_user
                                  <= ctrl_rdata[PCS10GR12_PHASE_COMP_MODE_2];
                                  
                           pcs10gr12_phase_comp_mode_1_user
                                  <= ctrl_rdata[PCS10GR12_PHASE_COMP_MODE_1];
                                  
                           pcs10gr12_phase_comp_mode_0_user
                                  <= ctrl_rdata[PCS10GR12_PHASE_COMP_MODE_0];
                      end
 
       endcase
end         
 
// restore PCS register with saved user values
always @(posedge clk)
begin
    case (pcs_reg_count)
        PCS_RESET: begin 
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]
                             <= TX_RST_OVR_ON;
                             
                       ctrl_pcs_user_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST]
                             <= TX_DIGITAL_RST_ON;
                             
                       ctrl_pcs_user_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]
                             <= RX_RST_OVR_ON;
                             
                       ctrl_pcs_user_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST]
                             <= RX_DIGITAL_RST_ON;
                             
                       ctrl_pcs_user_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]
                             <= RX_ANALOG_RST_ON;
                   end
                           
        PCS_8G6:   begin 
                       ctrl_pcs_user_wdata
                               <= ctrl_rdata;
 
                       ctrl_pcs_user_wdata[PCS8G6_RRX_PCS_BYPASS]
                               <= pcs8g6_rrx_pcs_bypass_user;
                   end
                                    
        PCS_8G7:   begin 
                       ctrl_pcs_user_wdata
                               <= ctrl_rdata;
 
                       ctrl_pcs_user_wdata[PCS8G7_RUNNING_DISPARITY]
                               <= pcs8g7_running_disparity_user;
                   end                 

        PCS_8G10:  begin 
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS8G10_SYNC_STATE_MACHINE]
                             <= pcs8g10_sync_state_machine_user;
                   end               

        PCS_8G12:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS8G12_PCIE_POLARITY_INVERSION]
                             <= pcs8g12_pcie_polarity_inversion_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_CASCADED_8B10B_DECODER_RX]
                             <= pcs8g12_cascaded_8b10b_decoder_rx_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_8B10B_COMPLIANCE_1]
                             <= pcs8g12_8b10b_compliance_1_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_8B10B_COMPLIANCE_0]
                             <= pcs8g12_8b10b_compliance_0_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_8B10B]
                             <= pcs8g12_mode_8b10b_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_BIT_SLIP_MODE]
                             <= pcs8g12_bit_slip_mode_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_RUN_LENGTH_CHECK]
                             <= pcs8g12_run_length_check_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_LOOPBACK_FROM_8B_10B]
                             <= pcs8g12_loopback_from_8b_10b_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_RX_PMA_SIGNAL_DETECT]
                             <= pcs8g12_rx_pma_signal_detect_user;
                             
                       ctrl_pcs_user_wdata[PCS8G12_RX_BYTE_SWAP]
                             <= pcs8g12_rx_byte_swap_user;
                   end
                               
        PCS_8G13:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS8G13_CLOCK_COMPENSATION]
                            <= pcs8g13_clock_compensation_user;
                   end

        PCS_8G17:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;
 
                       ctrl_pcs_user_wdata[PCS8G17_AUTO_SPEED_NEGOTIATION]
                            <= pcs8g17_auto_speed_negotiation_user;
                            
                       ctrl_pcs_user_wdata[PCS8G17_DATA_WIDTH_SCALING]
                            <= pcs8g17_data_width_scaling_user;
                            
                       ctrl_pcs_user_wdata[PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3]
                            <= pcs8g17_auto_speed_negotiation_gen3_user;
                   end 
        
        PCS_8G18:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;
 
                       ctrl_pcs_user_wdata[PCS8G18_ERROR_REPLACE]
                             <= pcs8g18_error_replace_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_NON_DEBUG_MODE]
                             <= pcs8g18_non_debug_mode_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING]
                             <= pcs8g18_hssi_controlled_byte_ordering_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_BYTE_ORDERING_0]
                             <= pcs8g18_byte_ordering_0_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_BYTE_ORDERING_1]
                             <= pcs8g18_byte_ordering_1_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_INVALID_CODE_REPLACEMENT]
                             <= pcs8g18_invalid_code_replacement_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET]
                             <= pcs8g18_cram_phase_comp_fifo_user_reset_user;
                             
                       ctrl_pcs_user_wdata[PCS8G18_PHASE_COMP_FIFO_USER_RESET]
                            <= pcs8g18_phase_comp_fifo_user_reset_user;
                            
                       ctrl_pcs_user_wdata[PCS8G18_LOW_LATENCY_FIFO_MODE]
                            <= pcs8g18_low_latency_fifo_mode_user;
                            
                       ctrl_pcs_user_wdata[PCS8G18_BYPASS_RX_FIFO]
                            <= pcs8g18_bypass_rx_fifo_user; 
                   end
       
        PCS_8G30:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;
 
                       ctrl_pcs_user_wdata[PCS8G30_DW_SYNC_SM]
                             <= pcs8g30_dw_sync_sm_user;
                   end
                                   
        PCS_10G1:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS10GR1_BYPASS_64_66_DECODER]
                             <= pcs10gr1_bypass_64_66_decoder_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR1_BYPASS_RX_STATE_MACHINE]
                             <= pcs10gr1_bypass_rx_state_machine_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR1_BYPASS_RX_DESCRAMBLER]
                             <= pcs10gr1_bypass_rx_descrambler_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR1_RX_BITSLIP]
                             <= pcs10gr1_rx_bitslip_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR1_BYPASS_RX_BLOCK_SYNC]
                             <= pcs10gr1_bypass_rx_block_sync_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR1_PARALLEL_LOOPBACK]
                             <= pcs10gr1_parallel_loopback_user;
                   end
               
        PCS_10G6:  begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS10GR6_BYPASS_FRAME_SYNC]
                            <= pcs10gr6_bypass_frame_sync_user;
                            
                       ctrl_pcs_user_wdata[PCS10GR6_BYPASS_CRC32_CHECKER]
                            <= pcs10gr6_bypass_crc32_checker_user;
                            
                       ctrl_pcs_user_wdata[PCS10GR6_BYPASS_DISPARITY_CHECKER]
                            <= pcs10gr6_bypass_disparity_checker_user; 
                   end
    
        PCS_10G10: begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO]
                             <= pcs10gr10_fast_bypass_gearbox_rx_fifo_user;
                   end
        
       PCS_10G12: begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[PCS10GR12_PHASE_COMP_MODE_2]
                             <= pcs10gr12_phase_comp_mode_2_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR12_PHASE_COMP_MODE_1]
                             <= pcs10gr12_phase_comp_mode_1_user;
                             
                       ctrl_pcs_user_wdata[PCS10GR12_PHASE_COMP_MODE_0]
                             <= pcs10gr12_phase_comp_mode_0_user;
                   end
        
        PMA_LOOP:  begin 
                       ctrl_pcs_user_wdata
                             <= 16'h0000;
                       
                       ctrl_pcs_user_wdata[SV_XR_SLPBK_SLPBKEN_OFST]
                             <= ~PHY_LPBK;
                   end
          
        PMA_PDB:   begin
                       ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                       ctrl_pcs_user_wdata[REYE_PDB]
                             <= ~REYE_PDB_ON;
                             
                       ctrl_pcs_user_wdata[REYE_ISEL_2:REYE_ISEL_0]
                             <= REYE_ISEL_OFF; 
                   end                                            
                                   
        PMA_EYE:  begin
                      ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                      ctrl_pcs_user_wdata[RCRU_EYE_OFST]
                             <=  ~EYE_MON_SEL;
                  end        

        PMA_TEST: begin
                      ctrl_pcs_user_wdata
                             <= ctrl_rdata;

                      ctrl_pcs_user_wdata[RSER_CLK_MON_OFST]
                             <= ~TEST_DATA_EN;
                  end 
        
        default:  ctrl_pcs_user_wdata <= 16'hxxxx;
    endcase
end 

endmodule
