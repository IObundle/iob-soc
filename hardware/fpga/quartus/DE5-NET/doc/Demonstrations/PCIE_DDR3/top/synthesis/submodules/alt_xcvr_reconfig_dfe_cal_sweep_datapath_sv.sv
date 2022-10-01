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


// DFE  calibration sweep datapath
//
// This module generates ctrl_opcode, ctrl_lock, ctrl_addr and ctrl_data
// for DFE calibration. 
// 
// In DFE calibration, there are 4 burst register read or writes cycles. 
// There is 1 state for each block operation in the DFE
// calibration state machine. Block operations include:
//   a. save user settings
//   b. setup for OC calibration
//   c. setup for PI calibration
//   d. restore user settings.
//
// A counter selects the registers during each of the burst states. 

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv (
    input  wire        clk,
       
    input  wire [3:0]  state,       
    input  wire        reg_count_reset,
    output reg         save_reg_count_tc, 
    output reg         oc_reg_count_tc,
    output reg         pi_reg_count_tc,      
    output reg         restore_reg_count_tc,
  
  // calibration data to be written
    input  wire [23:0] oc_offset,
    input  wire [5:0]  pi_phase,
  
    output reg  [2:0]  ctrl_opcode,
    output reg         ctrl_lock, 
    output reg  [11:0] ctrl_addr,   
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    input  wire        ctrl_done 
);
// PHY register parameters
import sv_xcvr_h::*;
// DFE register burst cycle parameters           
import sv_xcvr_dfe_cal_sweep_h::*;

function integer max4;
input [(32*4)-1 :0]  temp;
integer i;
begin
    max4 = temp[31:0];
    for (i=1; i<4; i=i+1)
        if (temp[i*32 +: 32] > max4)
            max4 = temp[i*32 +: 32];
end
endfunction

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

// address counter determined by largest register burst
localparam REG_COUNT_SIZE =
    max4({LAST_COUNT_SAVE,  LAST_COUNT_OC_WR,
          LAST_COUNT_PI_WR, LAST_COUNT_RESTORE}); 
 
localparam REG_COUNT_WIDTH = log2(REG_COUNT_SIZE);

// declarations
reg  [REG_COUNT_WIDTH -1:0] reg_count;
reg  [11:0]                 save_ctrl_addr;
reg  [11:0]                 oc_ctrl_addr;
reg  [11:0]                 pi_ctrl_addr;
reg  [11:0]                 restore_ctrl_addr;
reg  [15:0]                 save_reg_8;  
reg  [15:0]                 save_reg_11;
reg  [15:0]                 save_reg_12;
reg  [15:0]                 save_reg_13;
reg  [15:0]                 save_reg_14;
reg  [15:0]                 save_reg_21;
reg  [15:0]                 save_reg_23;
reg  [15:0]                 oc_ctrl_wdata;
reg  [15:0]                 pi_ctrl_wdata; 
reg  [15:0]                 restore_ctrl_wdata; 

//--------------------------------------------- 
// reg counter
//--------------------------------------------- 
always @(posedge clk)
begin
    if (reg_count_reset)
      reg_count <= 'b0;
    else if (ctrl_done)
      reg_count <= reg_count + 1'b1;
end

always @(posedge clk)
begin
    save_reg_count_tc    <= reg_count == LAST_COUNT_SAVE;  
    oc_reg_count_tc      <= reg_count == LAST_COUNT_OC_WR;
    pi_reg_count_tc      <= reg_count == LAST_COUNT_PI_WR;      
    restore_reg_count_tc <= reg_count == LAST_COUNT_RESTORE;
end

//--------------------------------------------- 
// ctrl_lock
//--------------------------------------------- 
always @(posedge clk)
begin
    ctrl_lock <= ~( (state == STATE_IDLE) |
                   ((state == STATE_RESTORE) & (reg_count == LAST_COUNT_RESTORE)) |
                    (state == STATE_DONE) );
end

//--------------------------------------------- 
// ctrl opcode
//--------------------------------------------- 
always @(posedge clk)
begin
    case (state)
        STATE_SAVE:     ctrl_opcode <= CTRL_OP_RD;
    
        STATE_OC_SETUP: if (reg_count == COUNT_OC_TB_SEL)
                            ctrl_opcode <= CTRL_OP_TBUS;
                        else 
                            ctrl_opcode <= CTRL_OP_WR;
           
        STATE_OC_WR_12: ctrl_opcode <= CTRL_OP_WR;
        STATE_OC_WR_15: ctrl_opcode <= CTRL_OP_WR;
      
        STATE_PI_SETUP: if (reg_count == COUNT_PI_TB_SEL)
                            ctrl_opcode <= CTRL_OP_TBUS;
                        else 
                            ctrl_opcode <= CTRL_OP_WR;
    
        STATE_PI_WR_13: ctrl_opcode <= CTRL_OP_WR;
  
        STATE_RESTORE:  ctrl_opcode <= CTRL_OP_WR;

        default:        ctrl_opcode <= 3'bxxx;
    endcase
end

//--------------------------------------------- 
// ctrl address 
//--------------------------------------------- 
// ctrl addr for save user settings
always @(*)
begin
    case (reg_count)
        COUNT_SAVE_8:  save_ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        COUNT_SAVE_11: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        COUNT_SAVE_12: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        COUNT_SAVE_13: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        COUNT_SAVE_14: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE14;
        COUNT_SAVE_21: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE21;
        COUNT_SAVE_23: save_ctrl_addr <= RECONFIG_PMA_CH0_DFE23;
        default:       save_ctrl_addr <= 12'hxxx;
    endcase
end
       
// ctrl addr for OC registers
always @(*)
begin
    case (reg_count)
        COUNT_OC_WR_8:   oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        COUNT_OC_WR_11:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        COUNT_OC_WR_12:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        COUNT_OC_WR_13:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        COUNT_OC_WR_14:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE14;
        COUNT_OC_WR_21:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE21;
        COUNT_OC_WR_23:  oc_ctrl_addr <= RECONFIG_PMA_CH0_DFE23;
        COUNT_OC_WR_LTRLTD: oc_ctrl_addr <= SV_XR_ABS_ADDR_LTRLTD;
        COUNT_OC_TB_SEL: oc_ctrl_addr <= 12'h000;
        default:         oc_ctrl_addr <= 12'hxxx;
    endcase
end
       
// ctrl addr for PI registers
always @(*)
begin
    case (reg_count)
       COUNT_PI_WR_11:     pi_ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
       COUNT_PI_WR_13:     pi_ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
       COUNT_PI_TB_SEL:    pi_ctrl_addr <= 12'h000;
       default:            pi_ctrl_addr <= 12'hxxx;
    endcase
end
      
// ctrl addr for restore registers
always @(*)
begin
    case (reg_count)
       COUNT_RESTORE_8:       restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
       COUNT_RESTORE_11:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
       COUNT_RESTORE_12:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
       COUNT_RESTORE_13:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
       COUNT_RESTORE_14:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE14;
       COUNT_RESTORE_21:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE21;
       COUNT_RESTORE_23:      restore_ctrl_addr <= RECONFIG_PMA_CH0_DFE23;
       COUNT_RESTORE_LTRLTD:  restore_ctrl_addr <= SV_XR_ABS_ADDR_LTRLTD;
       default:               restore_ctrl_addr <= 12'hxxx;
    endcase
end

// ctrl addr multiplexed by control state machine
always @(posedge clk)
begin
    case (state)
        STATE_SAVE:     ctrl_addr <= save_ctrl_addr; 
        STATE_OC_SETUP: ctrl_addr <= oc_ctrl_addr;
        STATE_OC_WR_12: ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_OC_WR_15: ctrl_addr <= RECONFIG_PMA_CH0_DFE15;
        STATE_PI_SETUP: ctrl_addr <= pi_ctrl_addr; 
        STATE_PI_WR_13: ctrl_addr <= RECONFIG_PMA_CH0_DFE13;	
        STATE_RESTORE:  ctrl_addr <= restore_ctrl_addr; 
        default:        ctrl_addr <= 12'hxxx;
    endcase
end

//--------------------------------------------- 
// save user register settings
//--------------------------------------------- 
always @(posedge clk)
begin
    if ((state == STATE_SAVE) && ctrl_done)
        case (reg_count)
            COUNT_SAVE_8:  save_reg_8  <= ctrl_rdata;  
            COUNT_SAVE_11: save_reg_11 <= ctrl_rdata;
            COUNT_SAVE_12: save_reg_12 <= ctrl_rdata;
            COUNT_SAVE_13: save_reg_13 <= ctrl_rdata;
            COUNT_SAVE_14: save_reg_14 <= ctrl_rdata;
            COUNT_SAVE_21: save_reg_21 <= ctrl_rdata;
            COUNT_SAVE_23: save_reg_23 <= ctrl_rdata;
            default: ;
        endcase
end

//--------------------------------------------- 
// ctrl_wdata
//--------------------------------------------- 
// ctrl wdata for OC calibration
always @(posedge clk)
begin
    case (reg_count)
        COUNT_OC_WR_8:  begin  
                            oc_ctrl_wdata <= save_reg_8;
                            oc_ctrl_wdata[CTRL_RCRU_PDOF_TEST_2 : CTRL_RCRU_PDOF_TEST_0]
                                <= OFFSET_RCRU_PDOF_TEST;
                        end
        
        COUNT_OC_WR_11: begin
                            oc_ctrl_wdata <= save_reg_11;
                            oc_ctrl_wdata[CTRL_RDFE_ADAPT_EN]
                                <= OFFSET_RDFE_ADAPT_EN;

                            oc_ctrl_wdata[CTRL_RDFE_5T_1 : CTRL_RDFE_5T_0]
                                <= DEFAULT_RDFE_5T;

                            oc_ctrl_wdata[CTRL_RDFE_4T_2 : CTRL_RDFE_4T_0]
                                <= DEFAULT_RDFE_4T;

                            oc_ctrl_wdata[CTRL_RDFE_3T_2 : CTRL_RDFE_3T_0]
                                <= DEFAULT_RDFE_3T;

                            oc_ctrl_wdata[CTRL_RDFE_2T_2 : CTRL_RDFE_2T_0]
                                <= DEFAULT_RDFE_2T;

                            oc_ctrl_wdata[CTRL_RDFE_1T_3 : CTRL_RDFE_1T_0]
                                <= DEFAULT_RDFE_1T;  
                        end
                 
        COUNT_OC_WR_12: begin
                            oc_ctrl_wdata <= save_reg_12;
                            oc_ctrl_wdata[CTRL_RDFE_PDOF_OD_3 : CTRL_RDFE_PDOF_OD_0] <= 0;
                            oc_ctrl_wdata[CTRL_RDFE_PDOF_EV_3 : CTRL_RDFE_PDOF_EV_0] <= 0;
                            oc_ctrl_wdata[CTRL_RDFE_PDB] <= OFFSET_RDFE_PDB;
                            oc_ctrl_wdata[CTRL_RDFE_LST_2 : CTRL_RDFE_LST_0]
                                <= DEFAULT_RDFE_LST;

	                      oc_ctrl_wdata[CTRL_RDFE_IBRGEN] <= DEFAULT_RDFE_IBRGEN;
                            oc_ctrl_wdata[CTRL_RDFE_CLKEN] <= DEFAULT_RDFE_CKEN; 
                        end 
                                  
        COUNT_OC_WR_13: begin 
                            oc_ctrl_wdata <= save_reg_13;
                            oc_ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                <= OFFSET_RDFE_VREF;

                            oc_ctrl_wdata[CTRL_RDFE_T5_INV] <= DEFAULT_RDFE_T5INV;
                            oc_ctrl_wdata[CTRL_RDFE_T4_INV] <= DEFAULT_RDFE_T4INV;
                            oc_ctrl_wdata[CTRL_RDFE_T3_INV] <= DEFAULT_RDFE_T3INV;
                            oc_ctrl_wdata[CTRL_RDFE_T2_INV] <= DEFAULT_RDFE_T2INV;
                            oc_ctrl_wdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                 <= DEFAULT_RDFE_STEP;

                            oc_ctrl_wdata[CTRL_RDFE_SEL_6G] <= DEFAULT_RDFE_SEL_6G;
                            oc_ctrl_wdata[CTRL_RDFE_SEL_S90D] <= DEFAULT_RDFE_S90D;
                            oc_ctrl_wdata[CTRL_RDFE_SEL_S0D] <= DEFAULT_RDFE_S0D;
                            oc_ctrl_wdata[CTRL_RDFE_PIEN] <= DEFAULT_RDFE_PIEN;
                            oc_ctrl_wdata[CTRL_RDFE_BYPASS_ADAPT]
                                 <= DEFAULT_RDFE_BYPASS_ADAPT;
      
                        end
                    
        COUNT_OC_WR_14: begin
                            oc_ctrl_wdata <= save_reg_14;
                            oc_ctrl_wdata[CTRL_RDFE_ADAPT_MODE_1 : CTRL_RDFE_ADAPT_MODE_0]
                                <= DEFAULT_RDFE_ADAPT_MODE;

                            oc_ctrl_wdata[CTRL_RDFE_PCNT5_BSEL_1 : CTRL_RDFE_PCNT5_BSEL_0]
                                <= DEFAULT_RDFE_PCNT5_BSEL;

                            oc_ctrl_wdata[CTRL_RDFE_PCNT4_BSEL_1 : CTRL_RDFE_PCNT4_BSEL_0]
                                <= DEFAULT_RDFE_PCNT4_BSEL;

                            oc_ctrl_wdata[CTRL_RDFE_PCNT3_BSEL_1 : CTRL_RDFE_PCNT3_BSEL_0]
                                <= DEFAULT_RDFE_PCNT3_BSEL;

                            oc_ctrl_wdata[CTRL_RDFE_PCNT2_BSEL_1 : CTRL_RDFE_PCNT2_BSEL_0]
                                <= DEFAULT_RDFE_PCNT2_BSEL;

                            oc_ctrl_wdata[CTRL_RDFE_PCNT1_BSEL_1 : CTRL_RDFE_PCNT1_BSEL_0]
                                <= DEFAULT_RDFE_PCNT1_BSEL;
                        end     
        
        COUNT_OC_WR_21: begin
                            oc_ctrl_wdata <= save_reg_21;
                            oc_ctrl_wdata[CTRL_RRX_PDB] <= OFFSET_RRX_PDB;
                        end    
        
        COUNT_OC_WR_23: begin
                            oc_ctrl_wdata <= save_reg_23;
                            oc_ctrl_wdata[CTRL_RDFE_ALLPCNT_SEL] <= DEFAULT_RDFE_ALLPCNT_SEL;
                            oc_ctrl_wdata[CTRL_RDFE_LIMIT_EN] <= DEFAULT_RDFE_LIMIT_EN;
                            oc_ctrl_wdata[CTRL_RDFE_HOLD_EN] <= DEFAULT_RDFE_HOLD_EN;
                            oc_ctrl_wdata[CTRL_RDFE_VCM_OP_EN] <= DEFAULT_RDFE_VCM_OP_EN;
                         end    

        COUNT_OC_WR_LTRLTD: begin
                                oc_ctrl_wdata <= 16'h0000;
                                oc_ctrl_wdata[CTRL_LTDLTR_LTD] <= PI_LTD;
                                oc_ctrl_wdata[CTRL_LTDLTR_LTR] <= PI_LTR;
                                oc_ctrl_wdata[CTRL_LTDLTR_OVR] <= PI_LTRLTD_OVR;
                            end
                                
        COUNT_OC_TB_SEL: oc_ctrl_wdata <= DFE_OFFSET_TESTBUS_SEL;

        default:         oc_ctrl_wdata <= 16'hxxxx;
    endcase
end

// ctrl_wdata for PI calibration        
always @(posedge clk)
begin
    case (reg_count)
        // registers 8, 12, 14, 21 and 23 do not change from OC setting

        COUNT_PI_WR_11:    begin
                               pi_ctrl_wdata <= save_reg_11;
                               pi_ctrl_wdata[CTRL_RDFE_ADAPT_EN] <= DEFAULT_RDFE_ADAPT_EN;
                               pi_ctrl_wdata[CTRL_RDFE_5T_1 : CTRL_RDFE_5T_0]
                                   <= DEFAULT_RDFE_5T;

                               pi_ctrl_wdata[CTRL_RDFE_4T_2 : CTRL_RDFE_4T_0]
                                   <= DEFAULT_RDFE_4T;

                               pi_ctrl_wdata[CTRL_RDFE_3T_2 : CTRL_RDFE_3T_0]
                                   <= DEFAULT_RDFE_4T;

                               pi_ctrl_wdata[CTRL_RDFE_2T_2 : CTRL_RDFE_2T_0]
                                   <= DEFAULT_RDFE_2T;

                               pi_ctrl_wdata[CTRL_RDFE_1T_3 : CTRL_RDFE_1T_0]
                                   <= PI_RDFE_1T;  
                           end
                              
        // register 12 does not change from OC settings    
                
        COUNT_PI_WR_13:     begin
                                pi_ctrl_wdata <= save_reg_13;
                                pi_ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                    <= DEFAULT_RDFE_VREF;

                                pi_ctrl_wdata[CTRL_RDFE_T5_INV] <= DEFAULT_RDFE_T5INV;
                                pi_ctrl_wdata[CTRL_RDFE_T4_INV] <= DEFAULT_RDFE_T4INV;
                                pi_ctrl_wdata[CTRL_RDFE_T3_INV] <= DEFAULT_RDFE_T3INV;
                                pi_ctrl_wdata[CTRL_RDFE_T2_INV] <= DEFAULT_RDFE_T2INV;
                                pi_ctrl_wdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                    <= DEFAULT_RDFE_STEP;

                                pi_ctrl_wdata[CTRL_RDFE_SEL_6G] <= DEFAULT_RDFE_SEL_6G;
                                pi_ctrl_wdata[CTRL_RDFE_SEL_S90D] <= DEFAULT_RDFE_S90D;
                                pi_ctrl_wdata[CTRL_RDFE_SEL_S0D] <= DEFAULT_RDFE_S0D;
                                pi_ctrl_wdata[CTRL_RDFE_PIEN] <= PI_RDFE_PIEN;
                                pi_ctrl_wdata[CTRL_RDFE_BYPASS_ADAPT]
                                    <= DEFAULT_RDFE_BYPASS_ADAPT;
   
                            end
                                      
        
        COUNT_PI_TB_SEL:    pi_ctrl_wdata <= DFE_PI_TESTBUS_SEL;

         default:           pi_ctrl_wdata <= 16'hxxxx;

     endcase
end

// ctrl wdata for register restoration after calibration
always @(posedge clk)
begin
    case (reg_count)
        COUNT_RESTORE_8:      restore_ctrl_wdata <= save_reg_8;
        
        COUNT_RESTORE_11:     restore_ctrl_wdata <= save_reg_11;
                                                    
        COUNT_RESTORE_12:     begin 
                                   restore_ctrl_wdata <= save_reg_12;
                                   restore_ctrl_wdata[CTRL_RDFE_PDOF_OD_3 : CTRL_RDFE_PDOF_OD_0]
                                       <= oc_offset[0*4 +:4];
  
                                   restore_ctrl_wdata[CTRL_RDFE_PDOF_EV_3 : CTRL_RDFE_PDOF_EV_0]
                                       <= oc_offset[1*4 +:4];

                              end    
        
        COUNT_RESTORE_13:     begin
                                   restore_ctrl_wdata <= save_reg_13;
                                   restore_ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                       <= STATIC_RDFE_VREF;

                                   restore_ctrl_wdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                       <= pi_phase[3:0];

                                   restore_ctrl_wdata[CTRL_RDFE_SEL_S90D] <= pi_phase[4];
                                   restore_ctrl_wdata[CTRL_RDFE_SEL_S0D] <= pi_phase[5];
                                   restore_ctrl_wdata[CTRL_RDFE_PIEN] <= STATIC_RDFE_PIEN;
                              end    
        
        COUNT_RESTORE_14:     begin
                                   restore_ctrl_wdata <= save_reg_14;
                                   restore_ctrl_wdata[CTRL_RDFE_ADAPT_MODE_1 : CTRL_RDFE_ADAPT_MODE_0]
                                       <= STATIC_RDFE_ADAPT_MODE;

                                   restore_ctrl_wdata[CTRL_RDFE_PCNT1_BSEL_1 : CTRL_RDFE_PCNT1_BSEL_0]
                                       <= STATIC_RDFE_PCNT1_BSEL;

                                   restore_ctrl_wdata[CTRL_RDFE_PCNT2_BSEL_1 : CTRL_RDFE_PCNT2_BSEL_0]
                                       <= STATIC_RDFE_PCNT2_BSEL;

                                   restore_ctrl_wdata[CTRL_RDFE_PCNT3_BSEL_1 : CTRL_RDFE_PCNT3_BSEL_0]
                                       <= STATIC_RDFE_PCNT3_BSEL;

                                   restore_ctrl_wdata[CTRL_RDFE_PCNT4_BSEL_1 : CTRL_RDFE_PCNT4_BSEL_0]
                                       <= STATIC_RDFE_PCNT4_BSEL;

                                   restore_ctrl_wdata[CTRL_RDFE_PCNT5_BSEL_1 : CTRL_RDFE_PCNT5_BSEL_0]
                                       <= STATIC_RDFE_PCNT5_BSEL;

                              end 
                                                   
        COUNT_RESTORE_21:     restore_ctrl_wdata <= save_reg_21;
      
        COUNT_RESTORE_23:     begin
                                  restore_ctrl_wdata <= save_reg_23;
                                  restore_ctrl_wdata[CTRL_RDFE_ALLPCNT_SEL]
                                      <= STATIC_RDFE_ALLPCNT_SEL;

                                  restore_ctrl_wdata[CTRL_RDFE_VCM_OP_EN]
                                      <= STATIC_RDFE_VCM_OP_EN;
                              end    
        
       COUNT_RESTORE_LTRLTD: begin
                                 restore_ctrl_wdata[CTRL_LTDLTR_LTD] <= DEFAULT_OFFSET_LTD;
                                 restore_ctrl_wdata[CTRL_LTDLTR_LTR] <= DEFAULT_OFFSET_LTR;
                                 restore_ctrl_wdata[CTRL_LTDLTR_OVR]
                                     <= DEFAULT_OFFSET_LTRLTD_OVR;
                              end
         
        default:              restore_ctrl_wdata <= 16'hxxxx;
  endcase
end

// ctrl_wdata multiplexed by control state machine
always @(posedge clk)
begin
    case (state)
	    STATE_SAVE:     ctrl_wdata <= 16'hxxxx;
		
	    STATE_OC_SETUP: ctrl_wdata <= oc_ctrl_wdata;
		
          STATE_OC_WR_12: begin
                              ctrl_wdata  <= save_reg_12;
                              ctrl_wdata[CTRL_RDFE_PDOF_OD_3 : CTRL_RDFE_PDOF_OD_0]
                                  <= oc_offset[0*4 +:4];

                              ctrl_wdata[CTRL_RDFE_PDOF_EV_3 : CTRL_RDFE_PDOF_EV_0]
                                  <= oc_offset[1*4 +:4];

                              ctrl_wdata[CTRL_RDFE_PDB] <= OFFSET_RDFE_PDB;
                              ctrl_wdata[CTRL_RDFE_LST_2 : CTRL_RDFE_LST_0]
                                  <= DEFAULT_RDFE_LST;

                              ctrl_wdata[CTRL_RDFE_IBRGEN] <= DEFAULT_RDFE_IBRGEN;
                              ctrl_wdata[CTRL_RDFE_CLKEN] <= DEFAULT_RDFE_CKEN; 
                          end 
    
          STATE_OC_WR_15: ctrl_wdata <= {oc_offset[5*4 +:4], oc_offset[4*4 +:4],
                                         oc_offset[3*4 +:4], oc_offset[2*4 +:4]};
  
          STATE_PI_SETUP: ctrl_wdata <= pi_ctrl_wdata; 

          STATE_PI_WR_13: begin 
                               ctrl_wdata <= save_reg_13;
                               ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                   <= DEFAULT_RDFE_VREF;

                               ctrl_wdata[CTRL_RDFE_T5_INV] <= DEFAULT_RDFE_T5INV;
                               ctrl_wdata[CTRL_RDFE_T4_INV] <= DEFAULT_RDFE_T4INV;
                               ctrl_wdata[CTRL_RDFE_T3_INV] <= DEFAULT_RDFE_T3INV;
                               ctrl_wdata[CTRL_RDFE_T2_INV] <= DEFAULT_RDFE_T2INV;
                               ctrl_wdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                   <= pi_phase[3:0];

                               ctrl_wdata[CTRL_RDFE_SEL_6G] <= DEFAULT_RDFE_SEL_6G;
                               ctrl_wdata[CTRL_RDFE_SEL_S90D] <= pi_phase[4];
                               ctrl_wdata[CTRL_RDFE_SEL_S0D] <= pi_phase[5];
                               ctrl_wdata[CTRL_RDFE_PIEN] <= PI_RDFE_PIEN;
                               ctrl_wdata[CTRL_RDFE_BYPASS_ADAPT]
                                   <= DEFAULT_RDFE_BYPASS_ADAPT;      
                          end 
        
        STATE_RESTORE:    ctrl_wdata <= restore_ctrl_wdata; 

        default:          ctrl_wdata <= 16'hxxxx;

    endcase
end

endmodule
