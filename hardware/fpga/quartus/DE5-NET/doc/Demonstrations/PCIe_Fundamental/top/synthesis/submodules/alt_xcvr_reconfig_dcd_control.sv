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


// DCD control
//
// Performs DCD calibration by enabling a 1010.. test pattern
// and using the eye monitor to measure the distance between
// falling and rising and edges of the data.
// 
// Accumulators capture 40 samples of 4 data bits.
// A data edge is detected when sum is nearest to 80. (50% ones).
// 
// Width measurements are repeated for all 6 values of
// rcru_dc_tune. The final rcru_dc_tune gives the width closest to 32.
//
// Eye width measurements are in alt_xcvr_reconfig_eye_width.
// Edge detection is in alt_xcvr_dcd_align_clk
// Accummulator access is in alt_xcvreconfig_get_sum.      
//
// PCS is put in bypass during DCD calibration and user settings are
// restored when the algorithm completes.

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_control (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,  // stops after current channel while asserted
    
    // Basic Block control
    output reg         ctrl_go,
    output reg         ctrl_lock,
    input  wire        ctrl_done,
    output reg  [9:0]  ctrl_chan,
    input  wire        ctrl_chan_err,
    output reg  [11:0] ctrl_addr,
    output reg  [2:0]  ctrl_opcode,
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    output reg         ctrl_sel_dcd,
    output reg         ctrl_sel_align,
    output reg         ctrl_sel_pll,
    output reg         user_busy,
    
    // PHY PLL reset
    output reg         pll_reset_go,
    input wire         pll_reset_done,
    
    // PHY counters
    output reg         eye_go,
    input  wire        eye_done,
    input  wire        eye_timeout,
    input  wire [5:0]  eye_width
      );  

parameter  [6:0] NUM_OF_CHANNELS = 66;  
 
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
 
// register bits values
localparam       REQUEST_DCD       = 1'b1;   // PHY RX present
localparam       PHY_TX_ID         = 1'b1;   // PHY TX present
localparam       PHY_RX_ID         = 1'b1;   // PHY RX present

 // Commands
localparam [2:0] OPCODE_READ  = 3'h0; 
localparam [2:0] OPCODE_WRITE = 3'h1;

localparam [2:0] DCD_CTR_INITIAL_VALUE = 3'h2;
localparam [2:0] DCD_CTR_MAX_VALUE = 3'h5;

reg         [1:0]  hold_ff;
wire               hold_sync;
reg         [5:0]  state;
wire               phy_req;
wire               phy_id;
wire               ctrl_chan_tc;
reg         [4:0]  pcs_reg_count;
wire               pcs_reg_count_tc;
wire signed [6:0]  sgn_eye_width;
reg  signed [6:0]  e;
reg         [6:0]  e_abs;
reg         [6:0]  best_e_value;
reg         [2:0]  best_dcd_ctr;
reg                best_greater_than_e;
reg         [2:0]  dcd_ctr;
wire               dcd_ctr_tc;
reg                ctrl_go_ff1; 
reg                ctrl_go_ff2; 
reg                ctrl_go_ff; 
reg         [2:0]  eye_done_ff;

 
// synchronize signals
always @(posedge clk)
begin
    hold_ff <= {hold_ff[0], hold};
end
 
assign hold_sync = hold_ff[1];

// control
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
       case (state)
            STATE_IDLE:           if (!hold_sync)
                                     state <= STATE_RD_PHY_REQ;
       
             // check phy channel and request
            STATE_RD_PHY_REQ:     if ((ctrl_done && ctrl_chan_tc && ctrl_chan_err) ||
                                      (ctrl_done && ctrl_chan_tc && !phy_req))
                                     state <= STATE_DONE;
                                  else if ((ctrl_done && !ctrl_chan_tc && ctrl_chan_err) ||
                                           (ctrl_done && !ctrl_chan_tc && !phy_req))
                                     state <= STATE_IDLE;
                                  else if (ctrl_done )
                                     state <= STATE_RD_PHY_ID;    
     
            // check phy channel and channel ID
            STATE_RD_PHY_ID:      if (ctrl_done && ctrl_chan_tc && !phy_id)
                                     state <= STATE_DONE;
                                  else if (ctrl_done && !ctrl_chan_tc && !phy_id)
                                     state <= STATE_IDLE;
                                  else if (ctrl_done )
                                     state <= STATE_RD_SETUP; 
                    
            // assert PCS reset; PCS in bypass; enable loop back;
            // enable pdb and isel; enable eye monitor data; select test pattern data
            STATE_RD_SETUP:       if (ctrl_done)
                                      state <= STATE_WR_SETUP;
                                    
            STATE_WR_SETUP:       if (ctrl_done && pcs_reg_count_tc)
                                      state <= STATE_RESET_PLL;
                                    
                                  else if (ctrl_done)
                                      state <= STATE_RD_SETUP;   
                                           
            // PLL reset sequence 
            STATE_RESET_PLL:      if (pll_reset_done)
                                      state <= STATE_RD_DCD;
                                
            // get DCD register for RMW
            STATE_RD_DCD:         if (ctrl_done)
                                       state <= STATE_WR_DCD;
                                    
            // DCD eye measurement
            // increment reye_mon and re-align clocks          
            STATE_WR_DCD:         if (ctrl_done)
                                       state <= STATE_EYE_DCD;
                                    
            STATE_EYE_DCD:        if ((eye_done_ff[2] && dcd_ctr_tc && best_greater_than_e) || 
                                      (eye_done_ff[2] && (eye_width == 6'd32)) ||
                                      (eye_done_ff[2] && eye_timeout))
                                       state <= STATE_RD_RESTORE;
                               
                                  else if (eye_done_ff[2] && dcd_ctr_tc)
                                       state <= STATE_WR_BEST;
                               
                                  else if (eye_done_ff[2])
                                       state <= STATE_WR_DCD;
                                    
            // write best DCD value
            STATE_WR_BEST:        if (ctrl_done)
                                      state <= STATE_RD_RESTORE;
                                    
            // restore PCS form bypass; disable pdb and isel; release PLL control; 
            // disable test pattern; disable loop back; enable eye monitor data; 
            STATE_RD_RESTORE:     if (ctrl_done)
                                       state <= STATE_WR_RESTORE;
                                    
            STATE_WR_RESTORE:     if (ctrl_done && pcs_reg_count_tc)
                                       state <= STATE_RESET_OVR_OFF; 
                                  else if (ctrl_done)
                                       state <= STATE_RD_RESTORE;
                                    
            // release PLL overides
            STATE_RESET_OVR_OFF:  if (ctrl_done && ctrl_chan_tc)
                                       state <= STATE_DONE; 
                                  else if (ctrl_done)
                                       state <= STATE_IDLE;       
            // done            
            STATE_DONE:           state <= STATE_DONE; 
            
            default:              state <= STATE_IDLE; 
       endcase
end

// PHY_ID
assign phy_req = (ctrl_rdata[SV_XR_REQUEST_DCD_OFST]   == REQUEST_DCD);

assign phy_id  = (ctrl_rdata[SV_XR_ID_TX_CHANNEL_OFST] == PHY_TX_ID) & 
                 (ctrl_rdata[SV_XR_ID_RX_CHANNEL_OFST] == PHY_RX_ID);      
    
// channel counter
always @(posedge clk)
begin
    if (reset)
        ctrl_chan <= 10'h000;
    else if (((state == STATE_RD_PHY_REQ)    && ctrl_done &&  ctrl_chan_err) ||
             ((state == STATE_RD_PHY_REQ)    && ctrl_done && !phy_req) ||
             ((state == STATE_RD_PHY_ID)     && ctrl_done && !phy_id) ||
             ((state == STATE_RESET_OVR_OFF) && ctrl_done))  
                    
        ctrl_chan <= ctrl_chan + 1'b1;
end

assign ctrl_chan_tc = (ctrl_chan == NUM_OF_CHANNELS -1);

// PCS register count
always @(posedge clk)
begin
    if ((state == STATE_RD_PHY_ID) || (state == STATE_RESET_PLL)) 
        pcs_reg_count <= 5'h00;
    else if (((state == STATE_WR_SETUP) && ctrl_done) ||((state == STATE_WR_RESTORE) && ctrl_done))
        pcs_reg_count <= pcs_reg_count + 1'b1;
end
  
// adding sign bit to eye_width
assign sgn_eye_width = $signed({1'b0, eye_width});

// compare to perfect width
// e = 32 - (eye_width)  
always @(posedge clk)
begin
    e <= $signed({1'b0, 6'd32}) - sgn_eye_width;
end

// absolute value 
always @(posedge clk)
begin
    if (e[6])
        e_abs <= -e;
    else   
        e_abs <=  e;
end

// compare best_e to current e
always @(posedge clk)
begin
    best_greater_than_e <= (best_e_value > e_abs);
end

// save the lowest (best) e value and dcd counter value
always @(posedge clk)
begin
    if ((state == STATE_RD_DCD) && ctrl_done)
        begin
            best_e_value <= 7'h7f; 
            best_dcd_ctr <= DCD_CTR_INITIAL_VALUE; // fix for case:45356 - skip over setting '0' and '1'
        end
    else if (best_greater_than_e && eye_done_ff[2])
        begin 
            best_e_value <= e_abs;
            best_dcd_ctr <= dcd_ctr;
        end
end
 
// dcd counter 
always @(posedge clk)
begin
    if  ((state == STATE_RD_DCD) && ctrl_done)
        dcd_ctr <= DCD_CTR_INITIAL_VALUE; // fix for case:45356 - skip over setting '0' and '1'
    else if  ((state == STATE_EYE_DCD) && eye_done_ff[2])
        dcd_ctr <= dcd_ctr + 1'b1;
end
 
assign dcd_ctr_tc = (dcd_ctr == DCD_CTR_MAX_VALUE); // fix for case: 45356 - stop at setting '5' and skip over setting '6'

// ctrl_go 
always @(posedge clk)
begin
    if (reset)
        begin
            ctrl_go_ff1 <= 1'b0; 
            ctrl_go_ff2 <= 1'b0;
        end
    else 
        case (state)
            STATE_IDLE:          ctrl_go_ff1 <=  ~hold_sync;
            STATE_RD_PHY_REQ:    ctrl_go_ff1 <=  ctrl_done & ~ctrl_chan_err & phy_req;
            STATE_RD_PHY_ID:     ctrl_go_ff1 <=  ctrl_done &  phy_id;
            STATE_RD_SETUP:      ctrl_go_ff1 <=  ctrl_done;
            STATE_WR_SETUP:      ctrl_go_ff1 <=  ctrl_done & ~pcs_reg_count_tc;
            STATE_RESET_PLL:     ctrl_go_ff1 <=  pll_reset_done;
            default:             ctrl_go_ff1 <=  1'b0;
        endcase
        case (state) 
            STATE_RD_DCD:        ctrl_go_ff2 <=  ctrl_done;
            STATE_WR_DCD:        ctrl_go_ff2 <=  1'b0;
            STATE_EYE_DCD:       ctrl_go_ff2 <=  eye_done_ff[2];   
            STATE_WR_BEST:       ctrl_go_ff2 <=  ctrl_done;
            STATE_RD_RESTORE:    ctrl_go_ff2 <=  ctrl_done;
            STATE_WR_RESTORE:    ctrl_go_ff2 <=  ctrl_done;
            STATE_RESET_OVR_OFF: ctrl_go_ff2 <=  1'b0;
            default:             ctrl_go_ff2 <=  1'b0;
        endcase
end          

// delay GO to match write data 
always @(posedge clk)
begin
    if (reset)
        begin
            ctrl_go_ff <= 1'b0;
            ctrl_go    <= 1'b0;
        end    
    else
        begin
            ctrl_go    <= ctrl_go_ff; 
            ctrl_go_ff <= ctrl_go_ff1 | ctrl_go_ff2;
        end 
end
        
// ctrl_opcode 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:           ctrl_opcode <= 3'hx;
        STATE_RD_PHY_REQ:     ctrl_opcode <= OPCODE_READ;
        STATE_RD_PHY_ID:      ctrl_opcode <= OPCODE_READ;
        STATE_RD_SETUP:       ctrl_opcode <= OPCODE_READ;
        STATE_WR_SETUP:       ctrl_opcode <= OPCODE_WRITE;
        STATE_RESET_PLL:      ctrl_opcode <= 3'hx;
        STATE_RD_DCD:         ctrl_opcode <= OPCODE_READ;
        STATE_WR_DCD:         ctrl_opcode <= OPCODE_WRITE;
        STATE_EYE_DCD:        ctrl_opcode <= 3'hx;    
        STATE_WR_BEST:        ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_RESTORE:     ctrl_opcode <= OPCODE_READ;
        STATE_WR_RESTORE:     ctrl_opcode <= OPCODE_WRITE;
        STATE_RESET_OVR_OFF:  ctrl_opcode <= OPCODE_WRITE;
        STATE_DONE:           ctrl_opcode <= 3'hx;
        default:              ctrl_opcode <= 3'hx;
    endcase
end       

// ctrl_wdata and ctrl_addr
alt_xcvr_reconfig_dcd_datapath inst_alt_xcvr_reconfig_dcd_datapath (
    .clk              (clk),
       
    .state            (state),
    .pcs_reg_count    (pcs_reg_count),
    .pcs_reg_count_tc (pcs_reg_count_tc),   
        
    .dcd_ctr          (dcd_ctr),
    .best_dcd_ctr     (best_dcd_ctr),
       
    .ctrl_done        (ctrl_done),
    .ctrl_rdata       (ctrl_rdata),
    
    .ctrl_addr        (ctrl_addr),
    .ctrl_wdata       (ctrl_wdata)
);  

// ctrl_lock
always @(posedge clk)
begin
    ctrl_lock <= ~( (state == STATE_IDLE) |
                    (state == STATE_RD_PHY_REQ)  |
                    (state == STATE_RESET_OVR_OFF) |
                    (state == STATE_DONE) );
end 

// ctrl_sel 
// multiplex Basic Block I/F align PLL reset control signals
always @(posedge clk)
begin
    ctrl_sel_align <=   (state == STATE_EYE_DCD);
    
    ctrl_sel_pll   <=   (state == STATE_RESET_PLL);
                      
    ctrl_sel_dcd   <= ~((state == STATE_EYE_DCD) |
                        (state == STATE_RESET_PLL));                 
end

// pll_reset_go
always @(posedge clk)
begin
     pll_reset_go <= ((state == STATE_WR_SETUP) & ctrl_done & pcs_reg_count_tc);
end 
               
// eye_go  
always @(posedge clk)
begin
     eye_go <= ((state == STATE_WR_DCD) & ctrl_done);
               
end 

// delay eye_ack to match data pipeline delay
always @(posedge clk)
begin
     eye_done_ff <= {eye_done_ff[1:0], eye_done};
end
                
// user busy    
always @(posedge clk)
begin
    if (reset)
        user_busy <= 1'b1;
    else
        user_busy <= (state != STATE_DONE);       
end       

endmodule
