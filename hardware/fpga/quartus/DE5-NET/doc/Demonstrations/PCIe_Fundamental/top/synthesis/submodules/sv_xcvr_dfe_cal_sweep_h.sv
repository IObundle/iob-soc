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


// SV-generation transceiver DFE definitions and functions
//
// $Header$
//
// PACKAGE DECLARATION
package sv_xcvr_dfe_cal_sweep_h;

// testbus sel in basic block
localparam [15:0] DFE_OFFSET_TESTBUS_SEL = 16'h000d;
localparam [15:0] DFE_PI_TESTBUS_SEL     = 16'h0006;
// testbus bit for pi calibration 
localparam        PI_TESTBUS_BIT         =  1; 


// basic op codes
localparam CTRL_OP_RD          = 3'b000;
localparam CTRL_OP_WR          = 3'b001;
localparam CTRL_OP_PHYS        = 3'b010;
localparam CTRL_OP_TBUS        = 3'b011;

//---------------------------------------
// PHY register bits
//---------------------------------------
// register 8 
localparam CTRL_RCRU_PDOF_TEST_2 = 2; 
localparam CTRL_RCRU_PDOF_TEST_0 = 0; 

// register 11  
localparam CTRL_RDFE_ADAPT_EN = 15;
localparam CTRL_RDFE_5T_1     = 14;
localparam CTRL_RDFE_5T_0     = 13;
localparam CTRL_RDFE_4T_2     = 12;
localparam CTRL_RDFE_4T_0     = 10;
localparam CTRL_RDFE_3T_2     = 9;
localparam CTRL_RDFE_3T_0     = 7;
localparam CTRL_RDFE_2T_2     = 6;
localparam CTRL_RDFE_2T_0     = 4;
localparam CTRL_RDFE_1T_3     = 3;
localparam CTRL_RDFE_1T_0     = 0;

// register 12 
localparam CTRL_RDFE_PDOF_OD_3 = 15;
localparam CTRL_RDFE_PDOF_OD_0 = 12;
localparam CTRL_RDFE_PDOF_EV_3 = 11;
localparam CTRL_RDFE_PDOF_EV_0 = 8;
localparam CTRL_RDFE_PDB       = 7;
localparam CTRL_RDFE_LST_2     = 6;
localparam CTRL_RDFE_LST_0     = 4;
localparam CTRL_RDFE_IBRGEN    = 3;
localparam CTRL_RDFE_CLKEN     = 0;

// register 13
localparam CTRL_RDFE_VREF_2       = 15;
localparam CTRL_RDFE_VREF_0       = 13;
localparam CTRL_RDFE_T5_INV       = 12;
localparam CTRL_RDFE_T4_INV       = 11;
localparam CTRL_RDFE_T3_INV       = 10;
localparam CTRL_RDFE_T2_INV       = 9;
localparam CTRL_RDFE_STEP_3       = 8;
localparam CTRL_RDFE_STEP_0       = 5;
localparam CTRL_RDFE_SEL_6G       = 4;
localparam CTRL_RDFE_SEL_S90D     = 3;
localparam CTRL_RDFE_SEL_S0D      = 2;
localparam CTRL_RDFE_PIEN         = 1;
localparam CTRL_RDFE_BYPASS_ADAPT = 0;

// register 14
localparam CTRL_RDFE_ADAPT_MODE_1 = 13;
localparam CTRL_RDFE_ADAPT_MODE_0 = 12;
localparam CTRL_RDFE_PCNT5_BSEL_1 = 9;
localparam CTRL_RDFE_PCNT5_BSEL_0 = 8;
localparam CTRL_RDFE_PCNT4_BSEL_1 = 7;
localparam CTRL_RDFE_PCNT4_BSEL_0 = 6;
localparam CTRL_RDFE_PCNT3_BSEL_1 = 5;
localparam CTRL_RDFE_PCNT3_BSEL_0 = 4;
localparam CTRL_RDFE_PCNT2_BSEL_1 = 3;
localparam CTRL_RDFE_PCNT2_BSEL_0 = 2;
localparam CTRL_RDFE_PCNT1_BSEL_1 = 1;
localparam CTRL_RDFE_PCNT1_BSEL_0 = 0;

// register 21 
localparam CTRL_RRX_PDB = 0;

// register 23
localparam CTRL_RDFE_ALLPCNT_SEL = 15;
localparam CTRL_RDFE_LIMIT_EN    = 14;
localparam CTRL_RDFE_HOLD_EN     = 13;
localparam CTRL_RDFE_VCM_OP_EN   = 12;

// register LTRLTD
localparam CTRL_LTDLTR_LTD = 2;
localparam CTRL_LTDLTR_LTR = 1;
localparam CTRL_LTDLTR_OVR = 0;

//---------------------------------------
// PHY register default values
//---------------------------------------
// register 8
localparam DEFAULT_RCRU_PDOF_TEST = 3'b000;

// register 11
localparam DEFAULT_RDFE_ADAPT_EN = 1'b0;
localparam DEFAULT_RDFE_5T       = 2'b00;
localparam DEFAULT_RDFE_4T       = 3'b000;
localparam DEFAULT_RDFE_3T       = 3'b000;
localparam DEFAULT_RDFE_2T       = 3'b000;
localparam DEFAULT_RDFE_1T       = 4'b0000;

// register 12
localparam DEFAULT_RDFE_PDB    = 1'b0;
localparam DEFAULT_RDFE_LST    = 3'b000;
localparam DEFAULT_RDFE_IBRGEN = 1'b0;
localparam DEFAULT_RDFE_CKEN   = 1'b0;

// register 13
localparam DEFAULT_RDFE_VREF         = 3'b001;
localparam DEFAULT_RDFE_T5INV        = 1'b0;
localparam DEFAULT_RDFE_T4INV        = 1'b0;
localparam DEFAULT_RDFE_T3INV        = 1'b0;
localparam DEFAULT_RDFE_T2INV        = 1'b0;
localparam DEFAULT_RDFE_STEP         = 4'b1111;
localparam DEFAULT_RDFE_SEL_6G       = 1'b0;
localparam DEFAULT_RDFE_S90D         = 1'b1;
localparam DEFAULT_RDFE_S0D          = 1'b1;
localparam DEFAULT_RDFE_PIEN         = 1'b0;
localparam DEFAULT_RDFE_BYPASS_ADAPT = 1'b1;

// register 14
localparam DEFAULT_RDFE_ADAPT_MODE = 2'b00;
localparam DEFAULT_RDFE_PCNT5_BSEL = 2'b01;
localparam DEFAULT_RDFE_PCNT4_BSEL = 2'b01;
localparam DEFAULT_RDFE_PCNT3_BSEL = 2'b01;
localparam DEFAULT_RDFE_PCNT2_BSEL = 2'b01;
localparam DEFAULT_RDFE_PCNT1_BSEL = 2'b01;

// register 21
localparam DEFAULT_RRX_PDB = 1'b1;

// register 23
localparam DEFAULT_RDFE_ALLPCNT_SEL = 1'b0;
localparam DEFAULT_RDFE_LIMIT_EN    = 1'b0;
localparam DEFAULT_RDFE_HOLD_EN     = 1'b0;
localparam DEFAULT_RDFE_VCM_OP_EN   = 1'b1;

// register LTRLTD
localparam DEFAULT_OFFSET_LTD        = 1'b0;
localparam DEFAULT_OFFSET_LTR        = 1'b0;
localparam DEFAULT_OFFSET_LTRLTD_OVR = 1'b0;

//---------------------------------------
// PHY register offset cancellation non-default settings
//---------------------------------------
// register 8
localparam OFFSET_RCRU_PDOF_TEST = 3'b100;

// register 11
localparam OFFSET_RDFE_ADAPT_EN = 1'b1;

// register 12
localparam OFFSET_RDFE_PDB = 1'b1;

// register 13
localparam OFFSET_RDFE_VREF = 3'b000;

// register 21
localparam OFFSET_RRX_PDB = 1'b0;

//---------------------------------------
// PHY register PI phase non-default settings
//---------------------------------------
// register 8
localparam PI_RCRU_PDOF_TEST = 3'b100;

// register 11
localparam PI_RDFE_1T = 4'b1111;

// register 12
localparam PI_RDFE_PDB    = 1'b1;

// register 13
localparam PI_RDFE_PIEN = 1'b1;

// register LTRLTD
localparam PI_LTD        = 1'b0;
localparam PI_LTR        = 1'b1;
localparam PI_LTRLTD_OVR = 1'b1;

// register 21
localparam PI_RRX_PDB = 1'b0;

//---------------------------------------
// PHY register Static settings
//---------------------------------------
// register 13
localparam STATIC_RDFE_VREF = 3'b110;
localparam STATIC_RDFE_PIEN = 1'b1;

// register 14
localparam STATIC_RDFE_ADAPT_MODE = 2'b00;
localparam STATIC_RDFE_PCNT1_BSEL = 2'b11;
localparam STATIC_RDFE_PCNT2_BSEL = 2'b11;
localparam STATIC_RDFE_PCNT3_BSEL = 2'b11;
localparam STATIC_RDFE_PCNT4_BSEL = 2'b11;
localparam STATIC_RDFE_PCNT5_BSEL = 2'b11;

// register 23
localparam STATIC_RDFE_ALLPCNT_SEL = 1'b1;
localparam STATIC_RDFE_VCM_OP_EN   = 1'b1;

//---------------------------------------
// state machine
//---------------------------------------
localparam [3:0] STATE_IDLE        = 4'h0;
localparam [3:0] STATE_SAVE        = 4'h1;
localparam [3:0] STATE_OC_SETUP    = 4'h2;
localparam [3:0] STATE_OC_PLL_WAIT = 4'h3;
localparam [3:0] STATE_OC_WR_12    = 4'h4;
localparam [3:0] STATE_OC_WR_15    = 4'h5;
localparam [3:0] STATE_OC_WAIT     = 4'h6;
localparam [3:0] STATE_PI_SETUP    = 4'h7;
localparam [3:0] STATE_PI_WR_13    = 4'h8;
localparam [3:0] STATE_PI_WAIT     = 4'h9;
localparam [3:0] STATE_RESTORE     = 4'ha;
localparam [3:0] STATE_DONE        = 4'hb;

//---------------------------------------
// Register/Counter Assignments 
//---------------------------------------
// Save registers
localparam       COUNT_SAVE_8    = 0; 
localparam       COUNT_SAVE_11   = 1; 
localparam       COUNT_SAVE_12   = 2; 
localparam       COUNT_SAVE_13   = 3; 
localparam       COUNT_SAVE_14   = 4; 
localparam       COUNT_SAVE_21   = 5; 
localparam       COUNT_SAVE_23   = 6;
localparam       LAST_COUNT_SAVE = COUNT_SAVE_23;
// OC registers 
localparam       COUNT_OC_WR_8    = 0; 
localparam       COUNT_OC_WR_11   = 1; 
localparam       COUNT_OC_WR_12   = 2; 
localparam       COUNT_OC_WR_13   = 3; 
localparam       COUNT_OC_WR_14   = 4; 
localparam       COUNT_OC_WR_21   = 5; 
localparam       COUNT_OC_WR_23   = 6; 
localparam       COUNT_OC_WR_LTRLTD = 7; 
localparam       COUNT_OC_TB_SEL  = 8; 
localparam       LAST_COUNT_OC_WR = COUNT_OC_TB_SEL;
// PI registers 
localparam       COUNT_PI_WR_11     = 0; 
localparam       COUNT_PI_WR_13     = 1; 
localparam       COUNT_PI_TB_SEL    = 2;
localparam       LAST_COUNT_PI_WR   = COUNT_PI_TB_SEL;
// Restore registers 
localparam       COUNT_RESTORE_8      = 0; 
localparam       COUNT_RESTORE_11     = 1; 
localparam       COUNT_RESTORE_12     = 2; 
localparam       COUNT_RESTORE_13     = 3; 
localparam       COUNT_RESTORE_14     = 4; 
localparam       COUNT_RESTORE_21     = 5; 
localparam       COUNT_RESTORE_23     = 6; 
localparam       COUNT_RESTORE_LTRLTD = 7; 
localparam       LAST_COUNT_RESTORE   = COUNT_RESTORE_LTRLTD;

endpackage
