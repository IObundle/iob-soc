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


// dfe register control
//
// This module handles user access to DFE PHY hardware registers. 
//
// It receives user indirect registers from ALT_XRECONF_UIF and
// it generates write and read cycles to the ALT_XRECONF_BASIC.

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_reg_sv (
    input  wire        clk,
    input  wire        reset,
   
    // user interface
    input  wire        uif_go,       // start user cycle
    input  wire [2:0]  uif_mode,     // operation
    output reg         uif_busy,     // transfer in process
    input  wire [5:0]  uif_addr,     // address offset
    input  wire [15:0] uif_wdata,    // data in
    output reg  [15:0] uif_rdata,    // data out
    output reg         uif_addr_err, // illegal address
   
    // basic block control interface
    output reg         ctrl_go,      // start basic block cycle
    output reg  [2:0]  ctrl_opcode,  // read/write
    output reg         ctrl_lock,    // multicycle lock 
    input  wire        ctrl_done,    // transfer-over pulse
    output reg  [11:0] ctrl_addr,    // phy register address
    input  wire        ctrl_chan_err,// illegal channel
    input  wire [15:0] ctrl_rdata,   // data in
    output reg  [15:0] ctrl_wdata    // data out
);

// simmulation model modifications
  `ifdef ALTERA_RESERVED_QIS 
      `define ALTERA_RESERVED_XCVR_FULL_MYCALIP
  `endif    


// Control state assignments
localparam [1:0] STATE_IDLE = 2'b00;
localparam [1:0] STATE_RMW1 = 2'b01;
localparam [1:0] STATE_RMW2 = 2'b11;
localparam [1:0] STATE_RD   = 2'b10;

// user modes
localparam UIF_RDFE_MODE_RD   = 3'h0;
localparam UIF_RDFE_MODE_WR   = 3'h1;
localparam UIF_RDFE_MODE_PHYS = 3'h2;

// basic control commands
localparam CTRL_RDFE_OP_RD = 3'h0;
localparam CTRL_RDFE_OP_WR = 3'h1;

// user bits
// control reg
localparam UIF_RDFE_ADAPT = 0;
localparam UIF_RDFE_PDB   = 1;
// tap 1 reg
localparam UIF_RDFE_T1_0  = 0; // bit 0
localparam UIF_RDFE_T1_1  = 1; // bit 1
localparam UIF_RDFE_T1_2  = 2; // bit 2
localparam UIF_RDFE_T1_3  = 3; // bit 3
// tap 2 reg
localparam UIF_RDFE_T2_0  = 0;
localparam UIF_RDFE_T2_1  = 1;
localparam UIF_RDFE_T2_2  = 2;
localparam UIF_RDFE_T2INV = 3;
// tap 3 reg
localparam UIF_RDFE_T3_0  = 0;
localparam UIF_RDFE_T3_1  = 1;
localparam UIF_RDFE_T3_2  = 2;
localparam UIF_RDFE_T3INV = 3;
// tap 4 reg
localparam UIF_RDFE_T4_0  = 0;
localparam UIF_RDFE_T4_1  = 1;
localparam UIF_RDFE_T4_2  = 2;
localparam UIF_RDFE_T4INV = 3;
// tap 5 reg
localparam UIF_RDFE_T5_0   = 0;
localparam UIF_RDFE_T5_1   = 1;
localparam UIF_RDFE_T5INV  = 2;
// reference reg
localparam UIF_RDFE_VREF_0 = 0;
localparam UIF_RDFE_VREF_1 = 1;
localparam UIF_RDFE_VREF_2 = 2;
localparam UIF_RDFE_CKEN   = 3;
localparam UIF_RDFE_FREQ_0 = 4;
localparam UIF_RDFE_FREQ_1 = 5;
// step
localparam UIF_RDFE_PIEN   = 0;
localparam UIF_RDFE_S0D    = 1;
localparam UIF_RDFE_S90D   = 2;
localparam UIF_RDFE_STEP_0 = 3;
localparam UIF_RDFE_STEP_1 = 4;
localparam UIF_RDFE_STEP_2 = 5;
localparam UIF_RDFE_STEP_3 = 6;
//dfe one time adapt
localparam UIF_RDFE_ONETIME_ADAPT = 0;

// dfe hardware bits
// reg 11
localparam CTRL_RDFE_T1_0  = 0;  // tap 1 bit 0
localparam CTRL_RDFE_T1_1  = 1;  // tap 1 bit 1
localparam CTRL_RDFE_T1_2  = 2;  // tap 1 bit 2
localparam CTRL_RDFE_T1_3  = 3;  // tap 1 bit 3
localparam CTRL_RDFE_T2_0  = 4;  // tap 2
localparam CTRL_RDFE_T2_1  = 5;
localparam CTRL_RDFE_T2_2  = 6;
localparam CTRL_RDFE_T3_0  = 7;
localparam CTRL_RDFE_T3_1  = 8;  // tap 3
localparam CTRL_RDFE_T3_2  = 9;
localparam CTRL_RDFE_T4_0  = 10;
localparam CTRL_RDFE_T4_1  = 11; // tap 4
localparam CTRL_RDFE_T4_2  = 12;
localparam CTRL_RDFE_T5_0  = 13; // tap 5
localparam CTRL_RDFE_T5_1  = 14;
localparam CTRL_RDFE_ADAPT = 15; // adapt en
// reg 12
localparam CTRL_RDFE_CKEN   = 0; // VCO clk
localparam CTRL_RDFE_FREQ_0 = 1; // bandwidth
localparam CTRL_RDFE_FREQ_1 = 2;
localparam CTRL_RDFE_PDB    = 7; // power
// reg 13
localparam CTRL_RDFE_BYPASS = 0; // bypass
localparam CTRL_RDFE_PIEN   = 1;
localparam CTRL_RDFE_S0D    = 2; // step
localparam CTRL_RDFE_S90D   = 3;
localparam CTRL_RDFE_STEP_0 = 5; 
localparam CTRL_RDFE_STEP_1 = 6;
localparam CTRL_RDFE_STEP_2 = 7;
localparam CTRL_RDFE_STEP_3 = 8;
localparam CTRL_RDFE_T2INV  = 9;  // polarity
localparam CTRL_RDFE_T3INV  = 10;
localparam CTRL_RDFE_T4INV  = 11;
localparam CTRL_RDFE_T5INV  = 12;
localparam CTRL_RDFE_VREF_0 = 13; // reference
localparam CTRL_RDFE_VREF_1 = 14;
localparam CTRL_RDFE_VREF_2 = 15;

// register addresses
import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*;

// declarations
wire       valid_reg_addr;
wire       valid_cal_addr;
reg  [1:0] state;
reg        ctrl_go_ff1;
reg        ctrl_go_ff2;
reg  [2:0] cycle_counter;
wire       last_cycle;
wire [11:0] ctrl_addr2;
reg  [11:0] ctrl_addr1;
reg  [11:0] ctrl_addr0;
reg  [15:0] ctrl_wdata2;
reg  [15:0] ctrl_wdata1;
reg  [15:0] ctrl_wdata0;
reg         one_time_adapt;
reg	    dfe_power_on_sim;

assign valid_reg_addr = (uif_addr == XR_DFE_OFFSET_CTRL)  |
                        (uif_addr == XR_DFE_OFFSET_TAP1)  |
                        (uif_addr == XR_DFE_OFFSET_TAP2)  |
                        (uif_addr == XR_DFE_OFFSET_TAP3)  |
                        (uif_addr == XR_DFE_OFFSET_TAP4)  |
                        (uif_addr == XR_DFE_OFFSET_TAP5)  |
                        (uif_addr == XR_DFE_OFFSET_REF)   |
                        (uif_addr == XR_DFE_OFFSET_STEP)  |
                        (uif_addr == XR_DFE_OFFSET_TAP_ADAPT) | 
                        (uif_addr == XR_DFE_OFFSET_DFE12) |
                        (uif_addr == XR_DFE_OFFSET_DFE13) |
                        (uif_addr == XR_DFE_OFFSET_DFE14) |
                        (uif_addr == XR_DFE_OFFSET_DFE15);  

assign valid_cal_addr = (uif_addr == XR_DFE_OFFSET_CAL_PLL)  |
                        (uif_addr == XR_DFE_OFFSET_CAL_TBUS) |
                        (uif_addr == XR_DFE_OFFSET_CAL_SAMPL)|
                        (uif_addr == XR_DFE_OFFSET_CAL_RESET)|
                        (uif_addr == XR_DFE_OFFSET_RUN)      |
                        (uif_addr == XR_DFE_OFFSET_TAP_ADAPT) | 
                        (uif_addr == XR_DFE_OFFSET_ADAPT_WAIT)|
                        (uif_addr == XR_DFE_OFFSET_ADAPT_COUNT);
                        
//--------------------------------------
// control state machine
//--------------------------------------
always @(posedge clk)
begin
    if (reset)
        begin
         state <= STATE_IDLE;
	 one_time_adapt <= 0;
	 dfe_power_on_sim <= 0;   // Only meaningful for simulation purposes
        end 
    else if (ctrl_chan_err && ctrl_done) 
        state <= STATE_IDLE;
    else 
        case (state)
            // wait for user request
            STATE_IDLE: if (uif_go && valid_reg_addr && (uif_mode == UIF_RDFE_MODE_RD)) 
                            state <= STATE_RD;
                        else if (uif_go && valid_reg_addr && (uif_mode == UIF_RDFE_MODE_WR)) 
			    begin
                             state <= STATE_RMW1;
			     if (uif_addr == XR_DFE_OFFSET_TAP_ADAPT)
				begin
				 one_time_adapt <= 1'b1; 		//Record that one-time adapt has been triggered
				 dfe_power_on_sim <= 1'b1;		//And record that DFE will be powered on (for simulation only)
				end 
			     else if ((uif_addr == XR_DFE_OFFSET_CTRL) && (uif_wdata[UIF_RDFE_PDB] == 0))
				begin
				 one_time_adapt <= 1'b0; 		// Reset one-time adapt when manual mode DFE is powered-down
				 dfe_power_on_sim <= 1'b0;		// And record that DFE has been powered down (for simulation only)
				end 
			     else if ((uif_addr == XR_DFE_OFFSET_CTRL) && (uif_wdata[UIF_RDFE_ADAPT] == 1))
				begin
				 one_time_adapt <= 1'b0; 		// Reset one-time adapt when DFE continous is activated
				 dfe_power_on_sim <= 1'b1;		// And record that DFE has been powered on (for simulation only)
				end 
			     else if ((uif_addr == XR_DFE_OFFSET_CTRL) && (uif_wdata[UIF_RDFE_ADAPT] == 0) && (uif_wdata[UIF_RDFE_PDB] == 1))
				begin
				 one_time_adapt <= 1'b0; 		// Reset one-time adapt when manual mode DFE is activated
				 dfe_power_on_sim <= 1'b1;		// And record that DFE has been powered on (for simulation only)
				end
 			    end
                    
            // read part of RMW cycle
            STATE_RMW1: if (ctrl_done)
                           state <= STATE_RMW2;
                             
            // write part of RMW cycle
            STATE_RMW2: if (ctrl_done && last_cycle)
                           state <= STATE_IDLE;
                        else if (ctrl_done)
                           state <= STATE_RMW1;
                      
            // read cycle 
            STATE_RD:  if (ctrl_done && last_cycle) 
                          state <= STATE_IDLE;
  
            default:   state <= STATE_IDLE;
  
    endcase     
end

// outputs
always @(posedge clk)
begin
    if (reset)
        begin
            uif_busy     <= 1'b0;
            uif_addr_err <= 1'b0;
            ctrl_go_ff1  <= 1'b0;
            ctrl_go_ff2  <= 1'b0;
            ctrl_go      <= 1'b0;            
            ctrl_lock    <= 1'b0;
            ctrl_opcode  <= 1'b0;
        end
    else
        begin
            // busy to user
            if ((state == STATE_IDLE) && uif_go && (uif_mode == UIF_RDFE_MODE_PHYS))
                uif_busy <= 1'b1; 

            else if ((state == STATE_IDLE) && uif_go && (valid_reg_addr || valid_cal_addr))        //uif_busy goes active immediately on any legal rd/wr access to DFE 
                uif_busy <= 1'b1; 

            else if (((state == STATE_IDLE) && (uif_mode == UIF_RDFE_MODE_PHYS)) ||
                     ((state == STATE_IDLE) && ((uif_mode == UIF_RDFE_MODE_RD) || (uif_mode == UIF_RDFE_MODE_WR)) && (!valid_reg_addr)) ||
                     ((state == STATE_RMW2) && ctrl_done && last_cycle) ||
                     ((state == STATE_RD)   && ctrl_done && last_cycle) ||
                      (ctrl_chan_err        && ctrl_done))
                uif_busy <= 1'b0;

            // illegal address
            if (((state == STATE_IDLE) && (uif_mode == UIF_RDFE_MODE_PHYS)) ||
                ((state == STATE_IDLE) && uif_go && valid_reg_addr) ||
                ((state == STATE_IDLE) && uif_go && valid_cal_addr))
                uif_addr_err <= 1'b0;
            else if ((state == STATE_IDLE) && uif_go) 
                uif_addr_err <= 1'b1;

            // go to basic             
            ctrl_go_ff1  <= (state == STATE_IDLE) & uif_go & valid_reg_addr;
                            
            ctrl_go_ff2  <= ((state == STATE_RMW1) & ctrl_done) |
                            ((state == STATE_RMW2) & ctrl_done & ~last_cycle) |
                            ((state == STATE_RD)   & ctrl_done & ~last_cycle);
            
            // delay for address, opcode, lock, and write data setup 
            ctrl_go      <= ctrl_go_ff1 | ctrl_go_ff2;
                      
            // lock to basic     
            ctrl_lock    <= ( state == STATE_RMW1) |
                            ((state == STATE_RMW2) & ~last_cycle) |
                            ((state == STATE_RD)   & ~last_cycle) ; 
           
            // opcode to basic
            if (state == STATE_RMW2)
                ctrl_opcode <= CTRL_RDFE_OP_WR;
            else   
                ctrl_opcode <= CTRL_RDFE_OP_RD;
        end
end

//--------------------------------------
// cycle counter -- one hot
//--------------------------------------
always @(posedge clk)
begin
    if (uif_go && (uif_mode == UIF_RDFE_MODE_WR))
        case (uif_addr)
            XR_DFE_OFFSET_CTRL:  cycle_counter <= 3'b100;  // triple rmw // set bypass to opposite of adapt
            XR_DFE_OFFSET_TAP1:  cycle_counter <= 3'b001;  // single rmw
            XR_DFE_OFFSET_TAP2:  cycle_counter <= 3'b010;  // double rmw
            XR_DFE_OFFSET_TAP3:  cycle_counter <= 3'b010;  // double rmw
            XR_DFE_OFFSET_TAP4:  cycle_counter <= 3'b010;  // double rmw
            XR_DFE_OFFSET_TAP5:  cycle_counter <= 3'b010;  // double rmw
            XR_DFE_OFFSET_REF:   cycle_counter <= 3'b010;  // double rmw
            XR_DFE_OFFSET_STEP:  cycle_counter <= 3'b001;  // single rmw
            XR_DFE_OFFSET_DFE12: cycle_counter <= 3'b001;  // single write 
            XR_DFE_OFFSET_DFE13: cycle_counter <= 3'b001;  // single write
            XR_DFE_OFFSET_DFE14: cycle_counter <= 3'b001;  // single write
            XR_DFE_OFFSET_DFE15: cycle_counter <= 3'b001;  // single write
            default:             cycle_counter <= 3'bxxx;
        endcase    
    else if (uif_go && (uif_mode == UIF_RDFE_MODE_RD))
        case (uif_addr)
            XR_DFE_OFFSET_CTRL:  cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_TAP1:  cycle_counter <= 3'b001;  // single read
            XR_DFE_OFFSET_TAP2:  cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_TAP3:  cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_TAP4:  cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_TAP5:  cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_REF:   cycle_counter <= 3'b010;  // double read
            XR_DFE_OFFSET_STEP:  cycle_counter <= 3'b001;  // single read
            XR_DFE_OFFSET_TAP_ADAPT:	cycle_counter <= 3'b001;  // single read 
            XR_DFE_OFFSET_DFE12: cycle_counter <= 3'b001;  // single read 
            XR_DFE_OFFSET_DFE13: cycle_counter <= 3'b001;  // single read
            XR_DFE_OFFSET_DFE14: cycle_counter <= 3'b001;  // single read
            XR_DFE_OFFSET_DFE15: cycle_counter <= 3'b001;  // single read
            default:             cycle_counter <= 3'bxxx;
       endcase    
   else if (((state == STATE_RMW2) && ctrl_done) || ((state == STATE_RD) && ctrl_done)) 
        cycle_counter <= cycle_counter >> 1;
end

assign last_cycle = cycle_counter[0];

//--------------------------------------
// ctrl_address
//--------------------------------------
// 3rd from last RMW
assign  ctrl_addr2 = RECONFIG_PMA_CH0_DFE13; // bypass
 
// 2nd from last RMW
always @(*)
begin
    case (uif_addr)
        XR_DFE_OFFSET_CTRL:  ctrl_addr1 = RECONFIG_PMA_CH0_DFE11; // adapt en
        XR_DFE_OFFSET_TAP2:  ctrl_addr1 = RECONFIG_PMA_CH0_DFE11; // coef 2 
        XR_DFE_OFFSET_TAP3:  ctrl_addr1 = RECONFIG_PMA_CH0_DFE11; // coef 3
        XR_DFE_OFFSET_TAP4:  ctrl_addr1 = RECONFIG_PMA_CH0_DFE11; // coef 4
        XR_DFE_OFFSET_TAP5:  ctrl_addr1 = RECONFIG_PMA_CH0_DFE11; // coef 5
        XR_DFE_OFFSET_REF:   ctrl_addr1 = RECONFIG_PMA_CH0_DFE13; // ref
        default:             ctrl_addr1 = 12'hxxx;
    endcase
end

// last RMW
always @(*)
begin
    case (uif_addr) 
        XR_DFE_OFFSET_CTRL:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE12; // power
        XR_DFE_OFFSET_TAP1:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE11; // coef 1
        XR_DFE_OFFSET_TAP2:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE13; // pol 2
        XR_DFE_OFFSET_TAP3:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE13; // pol 3
        XR_DFE_OFFSET_TAP4:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE13; // pol 4
        XR_DFE_OFFSET_TAP5:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE13; // pol 5
        XR_DFE_OFFSET_REF:   ctrl_addr0 = RECONFIG_PMA_CH0_DFE12; // cken, freq
        XR_DFE_OFFSET_STEP:  ctrl_addr0 = RECONFIG_PMA_CH0_DFE13; // step
             
        XR_DFE_OFFSET_DFE12: ctrl_addr0 = RECONFIG_PMA_CH0_DFE12; // hidden
        XR_DFE_OFFSET_DFE13: ctrl_addr0 = RECONFIG_PMA_CH0_DFE13;
        XR_DFE_OFFSET_DFE14: ctrl_addr0 = RECONFIG_PMA_CH0_DFE14;
        XR_DFE_OFFSET_DFE15: ctrl_addr0 = RECONFIG_PMA_CH0_DFE15;
        default:             ctrl_addr0 = 12'hxxx;
    endcase
end

// multiplex with cycle counter
always @(posedge clk)
begin
     case (cycle_counter)
         3'b001:  ctrl_addr <= ctrl_addr0;
         3'b010:  ctrl_addr <= ctrl_addr1;
         3'b100:  ctrl_addr <= ctrl_addr2;
         default: ctrl_addr <= 12'hxxx;
     endcase
 end      

//--------------------------------------
// ctrl_wdata
//--------------------------------------
// 3rd from last cycle
always @(*)
begin
    ctrl_wdata2 = ctrl_rdata;
          
    ctrl_wdata2[CTRL_RDFE_BYPASS] = ~uif_wdata[UIF_RDFE_ADAPT];
end

// 2nd from last 
always @(*)
begin
    case (uif_addr)
        XR_DFE_OFFSET_CTRL:  begin
                                 ctrl_wdata1 = ctrl_rdata;
          
                                 ctrl_wdata1[CTRL_RDFE_ADAPT]   
                                             = uif_wdata[UIF_RDFE_ADAPT];
                             end

                                                    
        XR_DFE_OFFSET_TAP2:  begin
                                 ctrl_wdata1 = ctrl_rdata;
          
                                 ctrl_wdata1[CTRL_RDFE_T2_2 : CTRL_RDFE_T2_0]   
                                             = uif_wdata[UIF_RDFE_T2_2 : UIF_RDFE_T2_0];
                             end
                                            
        XR_DFE_OFFSET_TAP3:  begin
                                 ctrl_wdata1 = ctrl_rdata;
          
                                 ctrl_wdata1[CTRL_RDFE_T3_2 : CTRL_RDFE_T3_0]   
                                             = uif_wdata[UIF_RDFE_T3_2 : UIF_RDFE_T3_0];
                             end 
                                            
        XR_DFE_OFFSET_TAP4:  begin
                                 ctrl_wdata1 = ctrl_rdata;
          
                                 ctrl_wdata1[CTRL_RDFE_T4_2 : CTRL_RDFE_T4_0]
                                              = uif_wdata[UIF_RDFE_T4_2 : UIF_RDFE_T4_0];
                             end 
            
        XR_DFE_OFFSET_TAP5:  begin
                                 ctrl_wdata1 = ctrl_rdata;
          
                                 ctrl_wdata1[CTRL_RDFE_T5_1 : CTRL_RDFE_T5_0]   
                                             = uif_wdata[UIF_RDFE_T5_1 : UIF_RDFE_T5_0];
                             end 
         
        XR_DFE_OFFSET_REF:   begin
                                 ctrl_wdata1 = ctrl_rdata;
        
                                 ctrl_wdata1[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                             = uif_wdata[UIF_RDFE_VREF_2 : UIF_RDFE_VREF_0];
                             end
         
        default:             ctrl_wdata1 = 16'hxxxx;         
    endcase
 end

// last 
always @(*)
begin
    case (uif_addr)   // last RMW
        XR_DFE_OFFSET_CTRL:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_PDB]   
                                             = uif_wdata[UIF_RDFE_PDB];
                              end
                                                  
        XR_DFE_OFFSET_TAP1:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_T1_3 : CTRL_RDFE_T1_0]
                                             = uif_wdata[UIF_RDFE_T1_3 : UIF_RDFE_T1_0];
                             end             
                                            
        XR_DFE_OFFSET_TAP2:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_T2INV]
                                             = uif_wdata[UIF_RDFE_T2INV];
                             end             
                                            
        XR_DFE_OFFSET_TAP3:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_T3INV]
                                             = uif_wdata[UIF_RDFE_T3INV];
                             end             
                                            
        XR_DFE_OFFSET_TAP4:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_T4INV]
                                             = uif_wdata[UIF_RDFE_T4INV];
                             end             
                                            
        XR_DFE_OFFSET_TAP5:  begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_T5INV]
                                             = uif_wdata[UIF_RDFE_T5INV];
                             end  
                                            
        XR_DFE_OFFSET_REF:   begin
                                 ctrl_wdata0 = ctrl_rdata;
          
                                 ctrl_wdata0[CTRL_RDFE_CKEN]   
                                             = uif_wdata[UIF_RDFE_CKEN];
                                  
                                 ctrl_wdata0[CTRL_RDFE_FREQ_1 : CTRL_RDFE_FREQ_0]   
                                             = uif_wdata[UIF_RDFE_FREQ_1 : UIF_RDFE_FREQ_0];
                             end                    
           
        XR_DFE_OFFSET_STEP:  begin
                                 ctrl_wdata0 = ctrl_rdata;
   
                                 ctrl_wdata0[CTRL_RDFE_PIEN]
                                             = uif_wdata[UIF_RDFE_PIEN];
                                          
                                 ctrl_wdata0[CTRL_RDFE_S0D]
                                             = uif_wdata[UIF_RDFE_S0D];
                                          
                                 ctrl_wdata0[CTRL_RDFE_S90D]
                                             = uif_wdata[UIF_RDFE_S90D];  
                                          
                                 ctrl_wdata0[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                             = uif_wdata[UIF_RDFE_STEP_3 : UIF_RDFE_STEP_0];
                             end
                                 
        XR_DFE_OFFSET_DFE12: ctrl_wdata0 = uif_wdata;
        XR_DFE_OFFSET_DFE13: ctrl_wdata0 = uif_wdata;
        XR_DFE_OFFSET_DFE14: ctrl_wdata0 = uif_wdata;
        XR_DFE_OFFSET_DFE15: ctrl_wdata0 = uif_wdata;
     
        default:             ctrl_wdata0 = 16'hxxxx; 
    endcase
end

// multiplex with cycle counter
always @(posedge clk)
begin
     case (cycle_counter)
         3'b001:  ctrl_wdata <= ctrl_wdata0;
         3'b010:  ctrl_wdata <= ctrl_wdata1;
         3'b100:  ctrl_wdata <= ctrl_wdata2;
         default: ctrl_wdata <= 16'hxxxx;
     endcase
 end 
     
//--------------------------------------
// uif_rdata
//--------------------------------------




always @(posedge clk)
begin
    if ((state == STATE_IDLE) && uif_go && (uif_mode == UIF_RDFE_MODE_RD)
                                       && valid_reg_addr)
        uif_rdata <= 16'h0000;
  
    else if ((state == STATE_RD) && ctrl_done && (cycle_counter[1] == 1))
        case (uif_addr) // first of 2 RMW cycles
            XR_DFE_OFFSET_CTRL:  begin 
                                     uif_rdata <= 16'h0000; 
`ifdef ALTERA_RESERVED_XCVR_FULL_MYCALIP
                                     uif_rdata[UIF_RDFE_ADAPT] <= ctrl_rdata[CTRL_RDFE_ADAPT];
`else
                                     uif_rdata[UIF_RDFE_ADAPT] <= dfe_power_on_sim;
`endif

                                 end
                                           
            XR_DFE_OFFSET_TAP2:  begin 
                                     uif_rdata <= 16'h0000; 

                                     uif_rdata[UIF_RDFE_T2_2 : UIF_RDFE_T2_0]
                                               <= ctrl_rdata[CTRL_RDFE_T2_2 : CTRL_RDFE_T2_0];
                                 end
         
            XR_DFE_OFFSET_TAP3:  begin 
                                     uif_rdata <= 16'h0000;

                                     uif_rdata[UIF_RDFE_T3_2 : UIF_RDFE_T3_0]
                                               <= ctrl_rdata[CTRL_RDFE_T3_2 : CTRL_RDFE_T3_0];
                                 end   
                                          
            XR_DFE_OFFSET_TAP4:  begin 
                                     uif_rdata <= 16'h0000; 

                                     uif_rdata[UIF_RDFE_T4_2 : UIF_RDFE_T4_0]
                                               <= ctrl_rdata[CTRL_RDFE_T4_2 : CTRL_RDFE_T4_0];
                                 end
                                          
            XR_DFE_OFFSET_TAP5:  begin 
                                     uif_rdata <= 16'h0000;
          
                                     uif_rdata[UIF_RDFE_T5_1 : UIF_RDFE_T5_0]
                                               <= ctrl_rdata[CTRL_RDFE_T5_1 : CTRL_RDFE_T5_0];
                                 end
                                   
            XR_DFE_OFFSET_REF:   begin 
                                     uif_rdata <= 16'h0000;
          
                                     uif_rdata[UIF_RDFE_VREF_2 : UIF_RDFE_VREF_0]
                                               <= ctrl_rdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0];
                                 end          
            
            default:                 uif_rdata <= 16'hxxxx; 
        endcase
  
    else if ((state == STATE_RD) && ctrl_done && (cycle_counter[0] == 1))
        case (uif_addr)  // second of 2 RMW cycles or single cycle
            XR_DFE_OFFSET_CTRL:  begin  
                                     uif_rdata <= uif_rdata;

                                     uif_rdata[UIF_RDFE_PDB] 
                                               <= ctrl_rdata[CTRL_RDFE_PDB];
                                 end
                                          
            XR_DFE_OFFSET_TAP1:  begin  
                                     uif_rdata <= uif_rdata;
          
                                     uif_rdata[UIF_RDFE_T1_3 : UIF_RDFE_T1_0]
                                               <= ctrl_rdata[CTRL_RDFE_T1_3 : CTRL_RDFE_T1_0];
                                 end
                                          
            XR_DFE_OFFSET_TAP2:  begin  
                                     uif_rdata <= uif_rdata;

                                     uif_rdata[UIF_RDFE_T2INV]
                                               <= ctrl_rdata[CTRL_RDFE_T2INV];
                                 end
                                          
            XR_DFE_OFFSET_TAP3:  begin  
                                     uif_rdata <= uif_rdata;
          
                                     uif_rdata[UIF_RDFE_T3INV]
                                               <= ctrl_rdata[CTRL_RDFE_T3INV];
                                 end
         
            XR_DFE_OFFSET_TAP4:  begin
                                     uif_rdata <= uif_rdata;
          
                                     uif_rdata[UIF_RDFE_T4INV]
                                               <= ctrl_rdata[CTRL_RDFE_T4INV];
                                 end
                                          
            XR_DFE_OFFSET_TAP5:  begin
                                     uif_rdata <= uif_rdata;
   
                                     uif_rdata[UIF_RDFE_T5INV]
                                               <= ctrl_rdata[CTRL_RDFE_T5INV];
                                 end
         
            XR_DFE_OFFSET_REF:   begin
                                     uif_rdata <= uif_rdata;

                                     uif_rdata[UIF_RDFE_CKEN]   
                                               <= ctrl_rdata[CTRL_RDFE_CKEN];

                                     uif_rdata[UIF_RDFE_FREQ_1 : UIF_RDFE_FREQ_0]   
                                               <= ctrl_rdata[CTRL_RDFE_FREQ_1 : CTRL_RDFE_FREQ_0];
                                 end                    
           
            XR_DFE_OFFSET_STEP:  begin
                                     uif_rdata <= uif_rdata;
             
                                     uif_rdata[UIF_RDFE_PIEN]
                                               <= ctrl_rdata[CTRL_RDFE_PIEN];
                                          
                                     uif_rdata[UIF_RDFE_S0D]
                                               <= ctrl_rdata[CTRL_RDFE_S0D];
                                          
                                     uif_rdata[UIF_RDFE_S90D]
                                               <= ctrl_rdata[CTRL_RDFE_S90D];   
                                          
                                     uif_rdata[UIF_RDFE_STEP_3 : UIF_RDFE_STEP_0]
                                               <= ctrl_rdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0];
                                 end

            XR_DFE_OFFSET_TAP_ADAPT:  begin
                                     uif_rdata <= uif_rdata;
             
                                     uif_rdata[UIF_RDFE_ONETIME_ADAPT]
                                               <= one_time_adapt;
                                 end
           
            XR_DFE_OFFSET_DFE12: uif_rdata <= ctrl_rdata;
            XR_DFE_OFFSET_DFE13: uif_rdata <= ctrl_rdata;
            XR_DFE_OFFSET_DFE14: uif_rdata <= ctrl_rdata;
            XR_DFE_OFFSET_DFE15: uif_rdata <= ctrl_rdata;
   
            default:             uif_rdata <= 16'hxxxx; 
   endcase
end

endmodule