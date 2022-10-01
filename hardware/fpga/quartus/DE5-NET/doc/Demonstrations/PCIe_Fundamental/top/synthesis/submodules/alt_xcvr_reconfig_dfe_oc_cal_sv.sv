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


// DFE Offset Calibration
//
// This module outputs the DFE offset cancellation register 
// data for one test bus input. 
// 
// The module calculates the average offset that causes the
// test bus signal to toggle or the offset that causes 
// a single transition.
// 
// The offset count is an input. The output is the offset count 
// until the average is calculated. The average is the final output.
//
// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_oc_cal_sv (
input  wire       clk,
input  wire       reset,

input  wire       go,
input  wire       enable,
input  wire [4:0] count,
input  wire       count_tc,        // offset counter terminal count

input  wire       testbus,         // dfe testbus signal
input  wire       testbus_ready,   // dfe testbus signal stable
  
output reg  [3:0] offset,          // offset cancellation value
output wire       done             // calibration done
); 

reg  [2:0]        state;
reg  [4:0]        low_offset;
reg  [4:0]        last_offset;
wire [5:0]        temp;
wire [5:0]        temp2;
reg  [4:0]        average_offset;
reg  [4:0]        linear_offset;
reg  [3:0]        testbus_ff /*synthesis altera_attribute =  "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3" */;  
reg               last_testbus;
wire              testbus_edge;
reg  [1:0]        testbus_toggle_count;
wire              testbus_toggle; 

parameter NO_ACTIVITY_OFFSET = 4'h9; // default offset count for no toggling or edge

// state assigments
localparam [2:0] PRELOAD     = 3'h0;
localparam [2:0] LOW_NOEDGE  = 3'h1;
localparam [2:0] LOW         = 3'h2;
localparam [2:0] HIGH        = 3'h3;
localparam [2:0] AVERAGE     = 3'h4;

// control
always @(posedge clk)
begin
    if (reset)
        state <= AVERAGE;
    else
       case (state)
         // save initial testbus state
           PRELOAD:     if (enable && !testbus_toggle)
                           state <= LOW;
                       else if (enable && testbus_toggle)
                           state <= LOW_NOEDGE;
       
           // toggle detected during preload -- preload not valid
           // don't look for a single edge
           LOW_NOEDGE: if (enable && testbus_toggle && !count_tc)
                           state <= HIGH;
                       else if (enable && count_tc)
                           state <= AVERAGE;
        
           // no toggle detected during preload 
           // single edge could be possible    
           LOW:        if (enable && testbus_toggle && !count_tc)
                           state <= HIGH;
                       else if ((enable && count_tc) || (enable && testbus_edge ))
                           state <= AVERAGE;
                                
           // wait for DFE signal to stop toggling     
           HIGH:       if ((enable && !testbus_toggle) || (enable && count_tc))
                           state <= AVERAGE;
                                     
           // set final calibration value           
           AVERAGE:    if (go)
                           state <= PRELOAD;
           
           default: state <= AVERAGE;     
       endcase
end

// done
assign done = (state == AVERAGE);

// low offset count
always @(posedge clk)
begin
    if ((enable && (state == LOW_NOEDGE) && testbus_toggle) ||
        (enable && (state == LOW)        && testbus_toggle))
        low_offset <=  count; 
end

// last offset count
always @(posedge clk)
begin
    if (enable)
        last_offset <= count; 
end 

// interim values 
assign temp  = low_offset + last_offset;
assign temp2 = low_offset + count; 

// average offset
always @(posedge clk)
begin
    // normal toggle
    if (enable && (state == HIGH) && !testbus_toggle)
        average_offset <= temp[4:1];
    
    // normal toggling continues at terminal count
    else if (enable && (state == HIGH) && testbus_toggle && count_tc)
        average_offset <= temp2[4:1];
    
    // toggling starts at end
    else if ((enable && (state == LOW)        && testbus_toggle && count_tc) ||
             (enable && (state == LOW_NOEDGE) && testbus_toggle && count_tc))  
        average_offset <= count;
        
    // no activity
    else if ((enable && (state == LOW) && !testbus_edge && !testbus_toggle && count_tc) ||
             (enable && (state == LOW_NOEDGE) && !testbus_toggle && count_tc)) 
        average_offset <= NO_ACTIVITY_OFFSET;
    
    // single edge
    else if (enable && (state == LOW) && testbus_edge) 
       average_offset <= count;
 end
   
// multiplex count and average
assign linear_offset = (state == AVERAGE) ? average_offset : count;
 
// encode offset 
 always @(posedge clk)
 begin 
     case (linear_offset)
         5'h00:    offset <= 4'he;
         5'h01:    offset <= 4'hf; 
         5'h02:    offset <= 4'he; 
         5'h03:    offset <= 4'hd; 
         5'h04:    offset <= 4'hc; 
         5'h05:    offset <= 4'hb; 
         5'h06:    offset <= 4'ha;
         5'h07:    offset <= 4'h9;
         5'h08:    offset <= 4'h8;
         5'h09:    offset <= 4'h0;
         5'h0a:    offset <= 4'h1;
         5'h0b:    offset <= 4'h2;
         5'h0c:    offset <= 4'h3;
         5'h0d:    offset <= 4'h4;
         5'h0e:    offset <= 4'h5;
         5'h0f:    offset <= 4'h6;
         5'h10:    offset <= 4'h7;
         default:  offset <= 4'h0; 
     endcase;
end
			
// synchronize testbus
always @(posedge clk)
begin
    testbus_ff <= {testbus_ff[2:0], testbus};
end 

// testbus edge detection
always @(posedge clk)
begin
    if (enable) 
        last_testbus <= testbus_ff[2];
end 
 
assign testbus_edge = last_testbus ^ testbus_ff[2]; 

// testbus toggle detection
always @(posedge clk)
begin
    if (testbus_ready)
	    testbus_toggle_count <= 2'b00;
    else if (testbus_ff[3] ^ testbus_ff[2])
        testbus_toggle_count <= {testbus_toggle_count[0], 1'b1};
end

assign testbus_toggle = testbus_toggle_count[1];
 
endmodule    