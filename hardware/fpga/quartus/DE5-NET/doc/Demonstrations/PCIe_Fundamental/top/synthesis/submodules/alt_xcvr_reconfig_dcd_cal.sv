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


// DCD calibration
//
// DCD calibration top module.
// 
// dcd_control.sv controls calibration 
// dcd_eye_width.sv handles obtaining eye width.
// dcd_pll_reset.sv sequences pll resets

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_cal (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,
    
    output reg         ctrl_go,
    output wire        ctrl_lock,
    input  wire        ctrl_wait,
    output wire [9:0]  ctrl_chan,
    input  wire        ctrl_chan_err,
    output reg  [11:0] ctrl_addr,
    output reg  [2:0]  ctrl_opcode,
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    
    output wire        user_busy
    );  

parameter  [6:0] NUM_OF_CHANNELS = 66;  

// done state machine
localparam [1:0] STATE_DONE0  = 2'b00;
localparam [1:0] STATE_DONE1  = 2'b01;
localparam [1:0] STATE_DONE2  = 2'b10;

// declarations
wire        dcd_ctrl_go;
wire [11:0] dcd_ctrl_addr; 
wire [2:0]  dcd_ctrl_opcode; 
wire [15:0] dcd_ctrl_wdata;
wire        eye_ctrl_sel;
wire        pll_ctrl_sel;
wire        dcd_ctrl_sel;
wire        pll_go;
wire        eye_go;
wire        pll_ctrl_go;
wire [11:0] pll_ctrl_addr; 
wire [2:0]  pll_ctrl_opcode; 
wire [15:0] pll_ctrl_wdata;
wire        pll_done;
wire        eye_ctrl_go;
wire [11:0] eye_ctrl_addr; 
wire [2:0]  eye_ctrl_opcode; 
wire [15:0] eye_ctrl_wdata;
wire        eye_done;
wire        eye_timeout;
wire [5:0]  eye_width;
reg  [1:0]  state_done;
wire        eye_ctrl_done;
wire        dcd_ctrl_done; 
wire        pll_ctrl_done; 
wire        ctrl_done;
reg  [6:0]  reset_ff;
wire        reset_sync1;
wire        reset_sync2;
wire        reset_sync3;

//debug
wire [5:0]  edge1_debug;
wire [5:0]  edge2_debug;
wire        rising_debug;   
wire [5:0]  width_debug; 

// control   
alt_xcvr_reconfig_dcd_control #(
    .NUM_OF_CHANNELS  (NUM_OF_CHANNELS)
)
inst_alt_xcvr_reconfig_dcd_control (
    .clk            (clk),
    .reset          (reset_sync1),
    .hold           (hold),
    
    .ctrl_go        (dcd_ctrl_go),
    .ctrl_lock      (ctrl_lock),
    .ctrl_done      (dcd_ctrl_done),
    .ctrl_chan      (ctrl_chan),
    .ctrl_chan_err  (ctrl_chan_err),
    .ctrl_addr      (dcd_ctrl_addr),
    .ctrl_opcode    (dcd_ctrl_opcode),
    .ctrl_wdata     (dcd_ctrl_wdata),
    .ctrl_rdata     (ctrl_rdata),
    .ctrl_sel_align (eye_ctrl_sel),
    .ctrl_sel_pll   (pll_ctrl_sel),
    .ctrl_sel_dcd   (dcd_ctrl_sel), 
    .user_busy      (user_busy),
      
    .pll_reset_go   (pll_go),
    .pll_reset_done (pll_done),   
      
    .eye_go         (eye_go),
    .eye_done       (eye_done),
    .eye_timeout    (eye_timeout),
    .eye_width      (eye_width) 
    );  

// PLL reset    
alt_xcvr_reconfig_dcd_pll_reset #(
    .ALL_ON_DELAY   (101),  // duration all PLL resets on  
    .RX_DIG_DELAY   (102),  // rx digital reset asserted after other negated
    .PLL_LOCK_DELAY (103)   // delay for PLL to lock
) 
inst_alt_xcvr_reconfig_dcd_pll_reset (
    .clk         (clk),
    .reset       (reset_sync3),
    
    .go          (pll_go),  
    .done        (pll_done),
    
    // Basic Block control
    .ctrl_go     (pll_ctrl_go),
    .ctrl_done   (pll_ctrl_done),
    .ctrl_addr   (pll_ctrl_addr),
    .ctrl_opcode (pll_ctrl_opcode),
    .ctrl_wdata  (pll_ctrl_wdata)
     );    

// eye_width    
alt_xcvr_reconfig_dcd_eye_width inst_alt_xcvr_reconfig_dcd_eye_width (
    .clk           (clk),
    .reset         (reset_sync2),
    
    .go            (eye_go),
    .done          (eye_done),
    .timeout       (eye_timeout),
    
    .eye_width     (eye_width),

    .ctrl_go       (eye_ctrl_go),
    .ctrl_done     (eye_ctrl_done),
    .ctrl_addr     (eye_ctrl_addr),
    .ctrl_opcode   (eye_ctrl_opcode),
    .ctrl_wdata    (eye_ctrl_wdata),
    .ctrl_rdata    (ctrl_rdata)
    );  

// multiplex basic block signals
always @(posedge clk)
begin
     ctrl_go       <=  pll_ctrl_go  | eye_ctrl_go | dcd_ctrl_go;

     ctrl_addr     <=  (dcd_ctrl_sel) ? (dcd_ctrl_addr) : 
                      ((pll_ctrl_sel) ? pll_ctrl_addr : (eye_ctrl_addr)); 

     ctrl_opcode   <=  (dcd_ctrl_sel) ? (dcd_ctrl_opcode) : 
                      ((pll_ctrl_sel) ? pll_ctrl_opcode : (eye_ctrl_opcode)); 

     ctrl_wdata    <=  (dcd_ctrl_sel) ? (dcd_ctrl_wdata) :
                      ((pll_ctrl_sel) ? pll_ctrl_wdata : (eye_ctrl_wdata)); 
end 

assign dcd_ctrl_done = dcd_ctrl_sel & ctrl_done;
assign eye_ctrl_done = eye_ctrl_sel & ctrl_done;
assign pll_ctrl_done = pll_ctrl_sel & ctrl_done;
 
// creating CTRL_DONE from CTRL_WAIT
always @(posedge clk)
begin
    if (reset_sync1)
        state_done <= STATE_DONE0;
    else
        case (state_done)
           // wait for ctrl_go
           STATE_DONE0:    if (ctrl_go)   
                               state_done <= STATE_DONE1;
       
           // wait ctrl_to negate     
           STATE_DONE1:    if (!ctrl_wait)   
                               state_done <= STATE_DONE2;
                           
          // generate ctrl_done for 1 clock period
           STATE_DONE2:    state_done <= STATE_DONE0;       
       endcase
end

assign ctrl_done = (state_done == STATE_DONE2);

// synchronize reset
always @(posedge clk or posedge reset)
begin   
    if (reset)
       reset_ff <= 7'h00;
    else
       reset_ff <= {reset_ff[5:0], 1'b1};    
end

assign reset_sync1 = ~reset_ff[6];
assign reset_sync2 = ~reset_ff[5];
assign reset_sync3 = ~reset_ff[4];

endmodule
