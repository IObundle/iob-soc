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


// DCD Eye Width
//
// Determines eye width by subtracting offsets from 
// rising and falling clock alignments. 
//

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_eye_width (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        go,
    output reg         done,
    output wire        timeout,
    
    output reg  [5:0]  eye_width,
    
    // basic block interface    
    output wire        ctrl_go,
    input  wire        ctrl_done,
    output wire [11:0] ctrl_addr,
    output wire [2:0]  ctrl_opcode,
    output wire [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata
    );  

// control state machine
localparam [1:0] STATE_IDLE   = 2'h0;
localparam [1:0] STATE_EDGE1  = 2'h1;
localparam [1:0] STATE_EDGE2  = 2'h2;
localparam [1:0] STATE_DONE   = 2'h3;

reg         [2:0] state;
reg               align_go;
reg         [5:0] latched_align_offset;
reg         [5:0] align_initial_offset;
wire              align_done;
wire        [5:0] align_offset;
wire              align_rising_edge;
wire signed [6:0] sgn_falling_offset;
wire signed [6:0] sgn_rising_offset;
reg  signed [6:0] falling_minus_rising;
reg  signed [7:0] sgn_eye_width;

// control
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
        case (state)
            STATE_IDLE:  if (go)
                             state <= STATE_EDGE1;
            
            // clock align rising edge      
            STATE_EDGE1: if (align_done && timeout)
                             state <= STATE_DONE;  
    
                         else if (align_done && align_rising_edge)
                             state <= STATE_EDGE2;     
            
            // clock align falling edge                  
            STATE_EDGE2: if (align_done)
                             state <= STATE_DONE;
                          
            STATE_DONE:  state <= STATE_IDLE; 

            default:     state <= STATE_IDLE;
             
       endcase
end

// align go    
always @(posedge clk)
begin 
    if (reset)
        align_go <= 1'b0;
    else
        align_go <= ((state == STATE_IDLE)  & go) |
                    ((state == STATE_EDGE1) & align_done & ~timeout);
end

// latch offset from first alignment
always @(posedge clk)
begin 
    if ((state == STATE_EDGE1) && align_done)
        latched_align_offset <= align_offset;
end

// initial offset to start alignment 
always @(posedge clk)
begin 
    if ((state == STATE_IDLE) && go)
        align_initial_offset <= 6'h00;
    else if ((state == STATE_EDGE1) && align_done)
      // round off and skip a couple cycles
        align_initial_offset <= {align_offset[5:2], 2'b00} + 4'h8;
end

// align clock to data edge
alt_xcvr_reconfig_dcd_align_clk inst_alt_xcvr_reconfig_dcd_align_clk  (
    .clk            (clk),
    .reset          (reset),
    
    .go             (align_go),
    .done           (align_done),
    .timeout        (timeout),
        
    .initial_offset (align_initial_offset),
    .final_offset   (align_offset),
    .rising_edge    (align_rising_edge),
    
    // basic interface 
    .ctrl_go        (ctrl_go),
    .ctrl_done      (ctrl_done),
    .ctrl_addr      (ctrl_addr),
    .ctrl_opcode    (ctrl_opcode),
    .ctrl_wdata     (ctrl_wdata),
    .ctrl_rdata     (ctrl_rdata)
  );  

// add sign bits 
assign sgn_falling_offset = $signed({1'b0, align_offset});
assign sgn_rising_offset  = $signed({1'b0, latched_align_offset});

// falling offset - rising offset
always @(posedge clk)
begin
    falling_minus_rising <= sgn_falling_offset - sgn_rising_offset;
end

// adjust for negative difference
always @(posedge clk)
begin
    if (falling_minus_rising[6]) // sign bit
        sgn_eye_width <= $signed(8'd64) + falling_minus_rising;
    else  
        sgn_eye_width <= falling_minus_rising;
end 

assign eye_width = sgn_eye_width[5:0];

// done
always @(posedge clk)
begin
    done <= ((state == STATE_EDGE1) & align_done && timeout) |
            ((state == STATE_EDGE2) & align_done);
end

endmodule
