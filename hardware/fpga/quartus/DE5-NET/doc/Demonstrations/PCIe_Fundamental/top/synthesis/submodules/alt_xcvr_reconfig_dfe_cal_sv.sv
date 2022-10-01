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



// dfe calibration
//
// This module performs offset and PI Phase calibration using 
// alt_xcvr_reconfig_dfe_cal_sweep_sv.
//
// Calibration runs on all channels at power up and it runs
// on single channel with a user write to address
// XR_DFE_OFFSET_RUN. 

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_cal_sv (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,          // stops after current channel while asserted
   
    // user interface
    input  wire        uif_go, 
    input  wire  [2:0] uif_mode, 
    output reg         uif_busy, 
    input  wire  [5:0] uif_addr, 
    input  wire  [9:0] uif_chan,
    input  wire [15:0] uif_wdata,
         
    // basic block control interface
    output reg         ctrl_go, 
    output reg   [2:0] ctrl_opcode,
    output reg         ctrl_lock,     // multicycle lock 
    input  wire        ctrl_done,     // end of transfer 
    output reg  [11:0] ctrl_addr,
    output reg   [9:0] ctrl_chan,
    input  wire        ctrl_chan_err, // channel not legal
    input  wire [15:0] ctrl_rdata,
    output reg  [15:0] ctrl_wdata,
        
    input  wire  [7:0] ctrl_testbus 
);

parameter  [6:0] NUM_OF_CHANNELS       = 66; 

// user register defaults
// PLL lock delay
parameter [15:0] DEFAULT_REG_PLL       = 15; // x (2** 14) 
// step interval duartion
parameter  [7:0] DEFAULT_REG_INTERVAL  = 63; // x (2** 5)
// testbus delay from step to testbus ready 
parameter  [7:0] DEFAULT_REG_READY     = 31; // x (2** 5)
// testbus samples required to be high
parameter  [7:0] DEFAULT_REG_SAMPLES   = 2;
// analog reset delay
parameter  [7:0] DEFAULT_REG_RESET     = 15;  // x (2** 14)   

// user modes
localparam [2:0] UIF_MODE_RD           = 3'b000;
localparam [2:0] UIF_MODE_WR           = 3'b001;
localparam [2:0] UIF_MODE_PHYS         = 3'b010;

// basic op codes
localparam [2:0] CTRL_OP_RD            = 3'b000;
localparam [2:0] CTRL_OP_WR            = 3'b001;
localparam [2:0] CTRL_OP_PHYS          = 3'b010;
localparam [2:0] CTRL_OP_TBUS          = 3'b011;

// register bits values
localparam REQUEST_DFE                 = 1'b1; // DFE enabled
localparam PHY_RX_ID                   = 1'b1; // PHY RX present

// register bits values
localparam TX_RST_OVR_ON               = 1'b1; // override user settings
localparam RX_RST_OVR_ON               = 1'b1; // override user settings
localparam TX_DIGITAL_RST_ON           = 1'b0; // tx digital reset
localparam RX_DIGITAL_RST_ON           = 1'b0; // rx digital reset
localparam RX_ANALOG_RST_ON            = 1'b0; // rx analog reset

//---------------------------------------
// state machines
//---------------------------------------
// Control state assignments
localparam [3:0] STATE_AUTO_IDLE       = 4'h0;
localparam [3:0] STATE_AUTO_PHY_REQ    = 4'h1;
localparam [3:0] STATE_AUTO_PHY_ID     = 4'h2;
localparam [3:0] STATE_AUTO_RESET_OFF  = 4'h3;
localparam [3:0] STATE_AUTO_RESET_WAIT = 4'h4;
localparam [3:0] STATE_AUTO_CAL        = 4'h5;
localparam [3:0] STATE_AUTO_RESET_OVR  = 4'h6;  
localparam [3:0] STATE_USER_IDLE       = 4'h7;
localparam [3:0] STATE_USER_CAL        = 4'h8;

// declarations
reg  [1:0]  hold_ff /*synthesis altera_attribute =  "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 2" */;  
wire        hold_sync;
reg  [3:0]  state;
wire        phy_req;
wire        phy_id;
reg         ctrl_go_ff;
reg  [9:0]  chan_count;
reg         ctrl_chan_tc;
reg  [15:0] reg_pll;
reg  [7:0]  reg_ready;
reg  [7:0]  reg_interval;
reg  [7:0]  reg_samples;
reg  [15:0] reg_reset;
reg  [29:0] wait_timer;
reg         wait_timer_tc;
reg         sweep_go;
wire        sweep_done;
wire        sweep_wait_timer_reset;
wire        sweep_ctrl_go;
wire [2:0]  sweep_ctrl_opcode;
wire        sweep_ctrl_lock;
wire [11:0] sweep_ctrl_addr;
wire [15:0] sweep_ctrl_wdata;

import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*;           

// synchronize signals
always @(posedge clk)
begin
    hold_ff <= {hold_ff[0], hold};
end
 
assign hold_sync = hold_ff[1];

// control state machine
always @(posedge clk)
begin
      if (reset)
          state <= STATE_AUTO_IDLE;
      else
          case (state)
             // wait for enable
             STATE_AUTO_IDLE:      if (!hold_sync)
                                       state <= STATE_AUTO_PHY_REQ;
       
             // check PHY channel
             STATE_AUTO_PHY_REQ:   if ((ctrl_done && ctrl_chan_tc && ctrl_chan_err) ||
                                       (ctrl_done && ctrl_chan_tc && !phy_req))
                                       state <= STATE_USER_IDLE;
            
                                   else if ((ctrl_done && !ctrl_chan_tc && ctrl_chan_err) ||
                                            (ctrl_done && !ctrl_chan_tc && !phy_req))
                                       state <= STATE_AUTO_IDLE;
            
                                   else if (ctrl_done)
                                       state <= STATE_AUTO_PHY_ID;    
     
            // check PHY ID
            STATE_AUTO_PHY_ID:     if ((ctrl_done && ctrl_chan_tc && ctrl_chan_err) ||
                                       (ctrl_done && ctrl_chan_tc && !phy_id))
                                       state <= STATE_USER_IDLE;
            
                                   else if ((ctrl_done && !ctrl_chan_tc && ctrl_chan_err) ||
                                            (ctrl_done && !ctrl_chan_tc && !phy_id))
                                       state <= STATE_AUTO_IDLE;
            
                                   else if (ctrl_done)
                                       state <= STATE_AUTO_RESET_OFF; 
       
             // analog reset off
            STATE_AUTO_RESET_OFF:  if (ctrl_done)  
                                       state <= STATE_AUTO_RESET_WAIT;
            
            // wait                                                                                                                                                                            
            STATE_AUTO_RESET_WAIT: if (wait_timer_tc)
                                       state <= STATE_AUTO_CAL;

            // auto calibration
            STATE_AUTO_CAL:        if (sweep_done)
                                       state <= STATE_AUTO_RESET_OVR;
        
            // disable reset override
            STATE_AUTO_RESET_OVR:  if (ctrl_done && ctrl_chan_tc)
                                       state <= STATE_USER_IDLE;
            
                                   else if (ctrl_done)
                                       state <= STATE_AUTO_IDLE;
    
            // wait for user command
            STATE_USER_IDLE:       if (uif_go && (uif_mode == UIF_MODE_WR) &&
                                      (uif_addr == XR_DFE_OFFSET_RUN)) 
                                       state <= STATE_USER_CAL;
                                                                        
            // user calibration           
            STATE_USER_CAL:        if (sweep_done)
                                       state <= STATE_USER_IDLE;
           
            default:               state <= STATE_AUTO_IDLE;   
    endcase     
end

// PHY status bits 
assign phy_req = (ctrl_rdata[SV_XR_REQUEST_DFE_OFST] == REQUEST_DFE);

assign phy_id  = (ctrl_rdata[SV_XR_ID_RX_CHANNEL_OFST] == PHY_RX_ID); // RX only     
    
// busy to user
assign uif_busy = (state != STATE_USER_IDLE);

// ctrl go 
always @(posedge clk)
begin
    if (reset)
        ctrl_go_ff <= 1'b0;
    else
        case (state)
           STATE_AUTO_IDLE:       ctrl_go_ff <= ~hold_sync;
           STATE_AUTO_PHY_REQ:    ctrl_go_ff <= ctrl_done  & ~ctrl_chan_err & phy_req;
           STATE_AUTO_PHY_ID:     ctrl_go_ff <= ctrl_done  & ~ctrl_chan_err & phy_id;
           STATE_AUTO_RESET_OFF:  ctrl_go_ff <= 1'b0;
           STATE_AUTO_RESET_WAIT: ctrl_go_ff <= 1'b0;
           STATE_AUTO_CAL:        ctrl_go_ff <= sweep_ctrl_go | sweep_done;
           STATE_AUTO_RESET_OVR:  ctrl_go_ff <= 1'b0;
           STATE_USER_IDLE:       ctrl_go_ff <= 1'b0;
           STATE_USER_CAL:        ctrl_go_ff <= sweep_ctrl_go;
           default:               ctrl_go_ff <= 1'b0;
        endcase
 end 

// allow setup time for address, opcode and write data 
always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0;
    else
        ctrl_go <= ctrl_go_ff;
end
                                      
// ctrl opcode 
always @(posedge clk)
begin
    case (state)
        STATE_AUTO_IDLE:       ctrl_opcode <= 3'hx;
        STATE_AUTO_PHY_REQ:    ctrl_opcode <= CTRL_OP_RD;
        STATE_AUTO_PHY_ID:     ctrl_opcode <= CTRL_OP_RD;
        STATE_AUTO_RESET_OFF:  ctrl_opcode <= CTRL_OP_WR;
        STATE_AUTO_RESET_WAIT: ctrl_opcode <= 3'hx;
        STATE_AUTO_CAL:        ctrl_opcode <= sweep_ctrl_opcode;
        STATE_AUTO_RESET_OVR:  ctrl_opcode <= CTRL_OP_WR;
        STATE_USER_IDLE:       ctrl_opcode <= 3'hx;
        STATE_USER_CAL:        ctrl_opcode <= sweep_ctrl_opcode;
        default:               ctrl_opcode <= 3'hx; 
    endcase
end
 
// ctrl address 
always @(posedge clk)
begin
    case (state)
        STATE_AUTO_IDLE:       ctrl_addr <= 12'hxxx;
        STATE_AUTO_PHY_REQ:    ctrl_addr <= SV_XR_ABS_ADDR_REQUEST;
        STATE_AUTO_PHY_ID:     ctrl_addr <= SV_XR_ABS_ADDR_ID;
        STATE_AUTO_RESET_OFF:  ctrl_addr <= SV_XR_ABS_ADDR_RSTCTL;
        STATE_AUTO_RESET_WAIT: ctrl_addr <= 12'hxxx;
        STATE_AUTO_CAL:        ctrl_addr <= sweep_ctrl_addr;
        STATE_AUTO_RESET_OVR:  ctrl_addr <= SV_XR_ABS_ADDR_RSTCTL;
        STATE_USER_IDLE:       ctrl_addr <= 12'hxxx;
        STATE_USER_CAL:        ctrl_addr <= sweep_ctrl_addr;
        default:               ctrl_addr <= 12'hxxx;  
    endcase
end

// ctrl wdata
always @(posedge clk)
begin
    case (state)
        STATE_AUTO_IDLE:       ctrl_wdata <= 12'hxxx;
        
        STATE_AUTO_PHY_REQ:    ctrl_wdata <= 12'hxxx;
        
        STATE_AUTO_PHY_ID:     ctrl_wdata <= 12'hxxx;
		
        STATE_AUTO_RESET_OFF:  begin // analog rx reset negated
                                    ctrl_wdata                                         <=  16'h0000;
                                    ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]           <= ~TX_RST_OVR_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST] <=  TX_DIGITAL_RST_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]           <=  RX_RST_OVR_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST] <=  RX_DIGITAL_RST_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]  <= ~RX_ANALOG_RST_ON;
                               end
							   
        STATE_AUTO_RESET_WAIT: ctrl_wdata <= 12'hxxx;
		
        STATE_AUTO_CAL:        ctrl_wdata <= sweep_ctrl_wdata;
		
        STATE_AUTO_RESET_OVR:  begin // overrides off
                                    ctrl_wdata                                         <=  16'h0000;
                                    ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]           <= ~TX_RST_OVR_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST] <=  TX_DIGITAL_RST_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]           <= ~RX_RST_OVR_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST] <=  RX_DIGITAL_RST_ON;
                                    ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]  <= ~RX_ANALOG_RST_ON;
                               end
							   
        STATE_USER_IDLE:       ctrl_wdata <= 12'hxxx;
		
        STATE_USER_CAL:        ctrl_wdata <= sweep_ctrl_wdata;
		
        default:               ctrl_wdata <= 12'hxxx;
   endcase
end

// ctrl_lock
always @(posedge clk)
begin
    ctrl_lock <= sweep_ctrl_lock | (state == STATE_AUTO_RESET_OFF) |
                                   (state == STATE_AUTO_RESET_WAIT) | 
                                   (state == STATE_AUTO_CAL);
end

// channel counter
always @(posedge clk)
begin
    if (reset)
        chan_count <= 10'h000;
    else if (((state == STATE_AUTO_PHY_REQ)   && ctrl_done &&  ctrl_chan_err) ||
             ((state == STATE_AUTO_PHY_REQ)   && ctrl_done && !phy_req) ||
             ((state == STATE_AUTO_PHY_ID)    && ctrl_done &&  ctrl_chan_err) ||
             ((state == STATE_AUTO_PHY_ID)    && ctrl_done && !phy_id) ||
             ((state == STATE_AUTO_RESET_OVR) && ctrl_done))  
                    
        chan_count <= chan_count + 1'b1;
end

// ctrl channel
always @(posedge clk)
begin
    if ((state == STATE_USER_CAL) || (state == STATE_USER_IDLE))
        ctrl_chan <= uif_chan;
    else 
        ctrl_chan <= chan_count;
end

always @(posedge clk)
begin
    ctrl_chan_tc <= (chan_count == NUM_OF_CHANNELS -1);
end

// user wait timer registers
always @(posedge clk)
begin
    if (reset)
        begin
            reg_pll      <= DEFAULT_REG_PLL; 
            reg_ready    <= DEFAULT_REG_READY;
            reg_interval <= DEFAULT_REG_INTERVAL;
            reg_samples  <= DEFAULT_REG_SAMPLES;
            reg_reset    <= DEFAULT_REG_RESET;
        end
    else if (uif_go && (uif_mode == UIF_MODE_WR))
        case (uif_addr)
            XR_DFE_OFFSET_CAL_PLL:   reg_pll                  <= uif_wdata;
            XR_DFE_OFFSET_CAL_TBUS: {reg_ready, reg_interval} <= uif_wdata;
            XR_DFE_OFFSET_CAL_SAMPL: reg_samples              <= uif_wdata[7:0];
            XR_DFE_OFFSET_CAL_RESET: reg_reset                <= uif_wdata;
        endcase
end
 
// wait timer                  
always @(posedge clk)
begin
    if (sweep_wait_timer_reset && (state != STATE_AUTO_RESET_WAIT))                    
         wait_timer  <= 30'h0000_0000;         
    else 
         wait_timer  <= wait_timer + 1'b1;
end

always @(posedge clk)
begin
    wait_timer_tc    <= (wait_timer[29:14] == reg_reset) & (wait_timer[13:0] == 14'h3fff);
end
  
// calibration sweep go
always @(posedge clk)
begin
    if (reset)
        sweep_go <= 1'b0; 
    else     
        sweep_go <= ((state == STATE_AUTO_RESET_WAIT)    & wait_timer_tc) |          
                    ((state == STATE_USER_IDLE) & uif_go & (uif_mode == UIF_MODE_WR) &
                                                           (uif_addr == XR_DFE_OFFSET_RUN));       
end
 
// calibration sweep (offset and PI phase)
alt_xcvr_reconfig_dfe_cal_sweep_sv 
inst_alt_xcvr_reconfig_dfe_cal_sweep_sv (
    .clk                 (clk),
    .reset               (reset),
   
    .go                  (sweep_go),       
    .done                (sweep_done),     
     
    .pll_lock_delay      (reg_pll),
    .interval_delay      (reg_interval), 
    .testbus_ready_delay (reg_ready),
    .testbus_samples     (reg_samples),
    .wait_timer          (wait_timer),
    .wait_timer_reset    (sweep_wait_timer_reset),  

    .ctrl_go             (sweep_ctrl_go),  
    .ctrl_opcode         (sweep_ctrl_opcode),
    .ctrl_lock           (sweep_ctrl_lock), 
    .ctrl_done           (ctrl_done), 
    .ctrl_addr           (sweep_ctrl_addr),
    .ctrl_rdata          (ctrl_rdata), 
    .ctrl_wdata          (sweep_ctrl_wdata), 
        
    .ctrl_testbus        (ctrl_testbus) 
);

endmodule
