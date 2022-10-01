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


// DCD reset control
//
// Sequences resets to PHY PLLs.

// Resets are located in a CSR register that is accessed
// through the Basic Block.

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_pll_reset (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        go,  
    output reg         done,
    
    // Basic Block control
    output reg         ctrl_go,
    input  wire        ctrl_done,
    output wire [11:0] ctrl_addr,
    output wire  [2:0] ctrl_opcode,
    output reg  [15:0] ctrl_wdata
  );  

parameter ALL_ON_DELAY   = 101;   // all resets asserted   
parameter RX_DIG_DELAY   = 102;   // rx digital reset extended after others negated
parameter PLL_LOCK_DELAY = 1000;  // PLL reset to PLL lock

localparam  MAX_DELAY    = max (ALL_ON_DELAY, RX_DIG_DELAY, PLL_LOCK_DELAY);
 
function integer max;
    input [31:0] a; 
    input [31:0] b;
    input [31:0] c;
    if (a > b)
        max = a;
    else  
        max = b;
    if (c > max)
        max = c;
endfunction
 
function integer log2;
    input [31:0] value;
    for (log2=0; value>0; log2=log2+1)
        value = value>>1;
endfunction

// states  
localparam [2:0] STATE_IDLE       = 3'h0;
localparam [2:0] STATE_ALL_ON     = 3'h1;
localparam [2:0] STATE_ALL_WAIT   = 3'h2;
localparam [2:0] STATE_RXDIG_ON   = 3'h3;
localparam [2:0] STATE_RXDIG_WAIT = 3'h4;
localparam [2:0] STATE_RXDIG_OFF  = 3'h5;
localparam [2:0] STATE_PLL_WAIT   = 3'h6;
localparam [2:0] STATE_DONE       = 3'h7;

// register addresses
import sv_xcvr_h::*;
 
// register bits values
localparam TX_RST_OVR_ON     = 1'b1; // override user settings
localparam RX_RST_OVR_ON     = 1'b1; // override user settings
localparam TX_DIGITAL_RST_ON = 1'b0; // tx digital reset
localparam RX_DIGITAL_RST_ON = 1'b0; // rx digital reset
localparam RX_ANALOG_RST_ON  = 1'b0; // rx analog reset

 // Commands
localparam [2:0] OPCODE_WRITE = 3'h1;

reg [2:0]                     state;
reg [(log2(MAX_DELAY)) -1 :0] delay_ctr;
reg                           all_on_timeout; 
reg                           rx_dig_timeout;  
reg                           pll_timeout;
reg                           ctrl_go_ff;

// control
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
       case (state)
            STATE_IDLE:         if (go)
                                    state <= STATE_ALL_ON;
                                    
            // assert all resets
            STATE_ALL_ON:       if (ctrl_done)
                                   state <= STATE_ALL_WAIT;
                                
            STATE_ALL_WAIT:     if  (all_on_timeout)
                                   state <= STATE_RXDIG_ON;
            
            // turn off all resets but rx digital reset
            STATE_RXDIG_ON:     if (ctrl_done)
                                   state <= STATE_RXDIG_WAIT;
                                    
            
            STATE_RXDIG_WAIT:   if (rx_dig_timeout)
                                   state <= STATE_RXDIG_OFF;           
            
            // turn off rx digital reset
            STATE_RXDIG_OFF:    if (ctrl_done)
                                   state <= STATE_PLL_WAIT;
            
            // wait PLL to lock           
            STATE_PLL_WAIT:     if (pll_timeout)
                                   state <= STATE_DONE;
          
            // done            
            STATE_DONE:         state <= STATE_IDLE; 
            
            default:            state <= STATE_IDLE; 
       endcase
end

 // delay counter                  
always @(posedge clk)
begin
    if ((state == STATE_IDLE)     || (state == STATE_ALL_ON) ||
        (state == STATE_RXDIG_ON) || (state == STATE_RXDIG_OFF))                    
         delay_ctr  <= 'h0;         
    else 
         delay_ctr <= delay_ctr + 1'b1;
end

always @(posedge clk)
begin
    all_on_timeout <= (delay_ctr == ALL_ON_DELAY); 
    rx_dig_timeout <= (delay_ctr == RX_DIG_DELAY);  
    pll_timeout    <= (delay_ctr == PLL_LOCK_DELAY); 
end
  
// ctrl_wdata 
always @(posedge clk)
begin
    case (state)
        STATE_ALL_ON:   begin // all resets asserts
                            ctrl_wdata                                         <= 16'h0000;
                            ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]           <= TX_RST_OVR_ON;
                            ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST] <= TX_DIGITAL_RST_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]           <= RX_RST_OVR_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST] <= RX_DIGITAL_RST_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]  <= RX_ANALOG_RST_ON;
                        end
                          
        STATE_RXDIG_ON: begin // only rx digital asserted
                            ctrl_wdata                                         <=  16'h0000;
                            ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]           <=  TX_RST_OVR_ON;
                            ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST] <= ~TX_DIGITAL_RST_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]           <=  RX_RST_OVR_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST] <=  RX_DIGITAL_RST_ON;
                            ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]  <= ~RX_ANALOG_RST_ON;
                         end
                          
        STATE_RXDIG_OFF: begin // all resets off
                             ctrl_wdata                                         <=  16'h0000;
                             ctrl_wdata[SV_XR_RSTCTL_TX_RST_OVR_OFST]           <=  TX_RST_OVR_ON;
                             ctrl_wdata[SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST] <= ~TX_DIGITAL_RST_ON;
                             ctrl_wdata[SV_XR_RSTCTL_RX_RST_OVR_OFST]           <=  RX_RST_OVR_ON;
                             ctrl_wdata[SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST] <= ~RX_DIGITAL_RST_ON;
                             ctrl_wdata[SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST]  <= ~RX_ANALOG_RST_ON;
                          end

        default:          ctrl_wdata                                            <=  16'hxxxx;
    endcase
end
 
 // ctrl_addr 
assign ctrl_addr = SV_XR_ABS_ADDR_RSTCTL;

// ctrl_opcode
assign ctrl_opcode = OPCODE_WRITE;

// ctrl_go 
// delay for wriet data setup
always @(posedge clk)
begin
    if (reset)
        ctrl_go_ff <= 1'b0; 
    else 
        case (state)
            STATE_IDLE:       ctrl_go_ff <= go;
            STATE_ALL_ON:     ctrl_go_ff <= 1'b0;
            STATE_ALL_WAIT:   ctrl_go_ff <= all_on_timeout;
            STATE_RXDIG_ON:   ctrl_go_ff <= 1'b0;
            STATE_RXDIG_WAIT: ctrl_go_ff <= rx_dig_timeout;
            STATE_RXDIG_OFF:  ctrl_go_ff <= 1'b0;
            STATE_PLL_WAIT:   ctrl_go_ff <= 1'b0;
            STATE_DONE:       ctrl_go_ff <= 1'b0;
            default:          ctrl_go_ff <= 1'b0;
        endcase
end          

always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0; 
    else 
        ctrl_go <= ctrl_go_ff;
end        

// done
 assign done = (state == STATE_DONE);
 
endmodule
