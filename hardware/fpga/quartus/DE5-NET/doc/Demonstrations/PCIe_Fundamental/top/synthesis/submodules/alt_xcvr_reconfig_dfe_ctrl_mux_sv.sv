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


// dfe data control ctrl mux
//
// This module multiplexes the basic block ctrl signals and UIF BUSY 
// from the DFE register block and the DFE calibration block and DFE
// tap adaptation code; it creates a CTRL_DONE pulse from CTRL_WAIT.

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_ctrl_mux_sv
   (
    input   wire         clk,
    input   wire         reset,
    
    // register block
    input   wire         ctrl_reg_go,     
    input   wire   [2:0] ctrl_reg_opcode,
    input   wire         ctrl_reg_lock, 
    input   wire  [11:0] ctrl_reg_addr, 
    input   wire  [15:0] ctrl_reg_wdata,
    
    // calibration block
    input   wire         ctrl_cal_go,     
    input   wire   [2:0] ctrl_cal_opcode,
    input   wire         ctrl_cal_lock, 
    input   wire  [11:0] ctrl_cal_addr, 
    input   wire  [15:0] ctrl_cal_wdata,

    // tap adaptation block
    input   wire         ctrl_adapt_tap_go,     
    input   wire   [2:0] ctrl_adapt_tap_opcode,
    input   wire         ctrl_adapt_tap_lock, 
    input   wire  [11:0] ctrl_adapt_tap_addr, 
    input   wire  [15:0] ctrl_adapt_tap_wdata,
	 	 
    // multiplexer control
	  input   wire         uif_reg_busy, 
    input   wire         uif_cal_busy, 
	  input   wire         uif_adapt_tap_busy, 
	 
    // ctrl block interface
    output  reg          ctrl_go,     
    output  reg    [2:0] ctrl_opcode,
    output  reg          ctrl_lock, 
    input   wire         ctrl_wait,
    output  wire         ctrl_done,   
    output  reg   [11:0] ctrl_addr, 
    output  reg   [15:0] ctrl_wdata,
	 
	 // uif busy
	 output  wire         uif_busy
);
  
// ctrl done state machine
localparam [1:0] STATE_DONE0  = 2'b00;
localparam [1:0] STATE_DONE1  = 2'b01;
localparam [1:0] STATE_DONE2  = 2'b10;

reg  [1:0]  state_done;
   
// creating CTRL_DONE from CTRL_WAITREQUEST
always @(posedge clk)
begin
    if (reset)
        state_done <= STATE_DONE0;
    else
        case (state_done)
            // wait for ctrl_go
            STATE_DONE0: if (ctrl_go)   
                             state_done <= STATE_DONE1;

            // wait for ctlr_wait to negate
            STATE_DONE1: if (!ctrl_wait) 
                             state_done <= STATE_DONE2; 
                            
             // generate ctrl_done for 1 clock period
            STATE_DONE2: state_done <= STATE_DONE0; 
       endcase
end

assign ctrl_done = (state_done == STATE_DONE2);

// multiplex signal between register and calibration blocks
always @(posedge clk)
begin   
    if (reset)
        begin
            ctrl_go          <= 1'b0;
            ctrl_lock        <= 1'b0;
            ctrl_opcode      <= 3'b000; 
            ctrl_wdata[15:0] <= 15'h0000;
            ctrl_addr        <= 12'h000;
        end
    else
        begin
		        ctrl_go  <= ctrl_reg_go | ctrl_cal_go | ctrl_adapt_tap_go;
				
			      case ({uif_adapt_tap_busy, uif_cal_busy, uif_reg_busy}) // one-hot
				        3'b001:  begin
				                     ctrl_lock        <= ctrl_reg_lock;
                             ctrl_opcode      <= ctrl_reg_opcode;  
                             ctrl_wdata[15:0] <= ctrl_reg_wdata[15:0];
                             ctrl_addr        <= ctrl_reg_addr;
                         end			
						
				        3'b010:  begin
				                     ctrl_lock        <= ctrl_cal_lock;
                             ctrl_opcode      <= ctrl_cal_opcode;  
                             ctrl_wdata[15:0] <= ctrl_cal_wdata[15:0];
                             ctrl_addr        <= ctrl_cal_addr;
								         end			
								
					      3'b100:  begin
				                     ctrl_lock        <= ctrl_adapt_tap_lock;
                             ctrl_opcode      <= ctrl_adapt_tap_opcode;  
                             ctrl_wdata[15:0] <= ctrl_adapt_tap_wdata[15:0];
                             ctrl_addr        <= ctrl_adapt_tap_addr;
							     	     end
								
					      default: begin
				                     ctrl_lock        <=  1'bx;
                             ctrl_opcode      <=  3'bxxx;  
                             ctrl_wdata[15:0] <= 16'hxxxx;
                             ctrl_addr        <= 12'hxxx;
							   	       end			
								
					  endcase
       end
end

// uif busy
// can't tolerate flip flop delay
assign uif_busy = uif_reg_busy | uif_cal_busy | uif_adapt_tap_busy;

endmodule
          
