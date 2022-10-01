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


// DFE PI Phase Calibrator
//
// The module passes the count input until a rising edge
// is detected on the testbus.
// 
// Output count is encoded in grey code.

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_pi_phase_sv (
input  wire       clk,
input  wire       reset,

input  wire       go,
input  wire       enable,
input  wire [5:0] count, 
input  wire       count_tc, 

input  wire       testbus_ready,
input  wire [7:0] testbus_samples, // samples for testbus to be consider "1"
input  wire       testbus,
  
output wire [5:0] pi_phase,
output reg        done 
); 

reg  [2:0]        state;
reg               ld_pi_phase;
reg  [2:0]        testbus_ff /*synthesis altera_attribute =  "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3" */;  
wire              testbus_sync;
reg  [7:0]        testbus_hi_count;
reg               testbus_hi;
reg               last_testbus_hi;
wire              testbus_posedge; 

// states
localparam [1:0]  STATE_IDLE    = 2'h0;
localparam [1:0]  STATE_PRELOAD = 2'h1;
localparam [1:0]  STATE_EDGE    = 2'h2;


// control
always @(posedge clk)
begin
    if (reset)
        state <= STATE_IDLE;
    else
        case (state)
            // wait for start           
            STATE_IDLE:    if (go)
                               state <= STATE_PRELOAD;
                   
            // get initial state for edge detection
            STATE_PRELOAD: if (enable) 
                               state <= STATE_EDGE;
       
            // wait for positive edge on test bus
            STATE_EDGE:    if ((enable && count_tc) || (enable && testbus_posedge))
                               state <= STATE_IDLE;

            default: state <= STATE_IDLE;     
       endcase
end

// done
always @(posedge clk)
begin
    done <= (state == STATE_IDLE) & ~go;
end

// latch output
always @(posedge clk)
begin
    ld_pi_phase = ((state == STATE_IDLE) & go) | 
                  ((state == STATE_PRELOAD) & enable) |
                  ((state == STATE_EDGE) & enable & ~count_tc & ~testbus_posedge);  
end

// binary to grey conversion of count
alt_xcvr_reconfig_dfe_step_to_mon_en_sv inst_alt_xcvr_reconfig_dfe_step_to_mon_en (
     .clk      (clk),
     .enable   (ld_pi_phase),
     .step     (count),
     .monitor  (pi_phase)
); 

// synchronize testbus bit
always @(posedge clk)
begin
    testbus_ff <= {testbus_ff[1:0], testbus};
end 

assign testbus_sync = testbus_ff[2];

// testbus high
always @(posedge clk)
begin
    if (testbus_ready)
       testbus_hi_count <= 1'b0;
    else if (testbus_sync && (testbus_hi_count != testbus_samples))
       testbus_hi_count <= testbus_hi_count  + 1'b1;
end		 

always @(posedge clk)
begin
    testbus_hi <= (testbus_hi_count == testbus_samples);
end

// testbus edge
always @(posedge clk)
begin
    if (enable)
        last_testbus_hi <= testbus_hi; 
end 

assign testbus_posedge = testbus_hi & (~ last_testbus_hi);

endmodule    