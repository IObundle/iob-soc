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


// DCD get sum
//
// Module writes the offset to REYE_MON PHY register
// and reads the new sum from the DCD accumulator.
 
// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_get_sum (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        go,
    output reg         done,
    output reg         timeout,
    
    input  wire [5:0]  offset,
    output reg  [7:0]  sum,
       
    // basic interface 
    output reg         ctrl_go,
    input  wire        ctrl_done,
    output reg  [11:0] ctrl_addr,
    output reg  [2:0]  ctrl_opcode,
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata
  );  

parameter  TIMEOUT_COUNT = 200; // clocks to wait for accumulators
parameter  WAIT_COUNT    =  50; // clocks to wait after changing offset
  
// state machine  
localparam [3:0] STATE_IDLE         = 4'h0;
localparam [3:0] STATE_RD_OFFSET    = 4'h1;
localparam [3:0] STATE_WR_OFFSET    = 4'h2;
localparam [3:0] STATE_WAIT         = 4'h3;
localparam [3:0] STATE_REQ_ON       = 4'h4;
localparam [3:0] STATE_WAIT_ACK_ON  = 4'h5;
localparam [3:0] STATE_REQ_OFF      = 4'h6;
localparam [3:0] STATE_WAIT_ACK_OFF = 4'h7;
localparam [3:0] STATE_RD_SUM       = 4'h8;
localparam [3:0] STATE_DONE         = 4'h9;
localparam [3:0] STATE_REQ_OFF_ERR  = 4'ha;

// register opcodes
localparam [2:0] CTRL_OP_RD         = 3'b000;
localparam [2:0] CTRL_OP_WR         = 3'b001;

// register addresses
import sv_xcvr_h::*;

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

reg  [3:0]                         state;
reg                                ctrl_go_ff;
wire [5:0]                         mon_data;
reg  [log2(TIMEOUT_COUNT -1) -1:0] timeout_ctr;
reg                                wait_tc;

// state machine 
always @(posedge clk)
begin 
    if (reset)
       state <=  STATE_IDLE;
    else  
       case (state)
            STATE_IDLE:         if (go)
                                    state <= STATE_RD_OFFSET;
                             
            // write ofsset (read-modify-write)
            STATE_RD_OFFSET:    if (ctrl_done)
                                    state <= STATE_WR_OFFSET;
           
            STATE_WR_OFFSET:    if (ctrl_done)
                                    state <= STATE_WAIT; 
           
            // offset delay    
            STATE_WAIT:         if (wait_tc)
                                    state <= STATE_REQ_ON;        
           
            // assert request   
            STATE_REQ_ON:       if (ctrl_done)
                                    state <= STATE_WAIT_ACK_ON;   
 
            // wait for ack on         
            STATE_WAIT_ACK_ON:  if (ctrl_done && timeout)
                                    state <= STATE_REQ_OFF_ERR;
                                else if (ctrl_done && ctrl_rdata[SV_XR_DCD_ACK_OFST])
                                    state <= STATE_REQ_OFF;
                                     
            // negate request          
            STATE_REQ_OFF:      if (ctrl_done)
                                    state <= STATE_WAIT_ACK_OFF;                
            
            // wait for ack off         
            STATE_WAIT_ACK_OFF: if (ctrl_done && timeout)
                                    state <= STATE_DONE;
                                else if (ctrl_done && !ctrl_rdata[SV_XR_DCD_ACK_OFST])
                                    state <= STATE_RD_SUM;
            // read sum 
            STATE_RD_SUM:       if (ctrl_done)
                                    state <= STATE_DONE;
                                 
            // done 
            STATE_DONE:         state <= STATE_IDLE;                    
                                 
            // negate request after timeout          
            STATE_REQ_OFF_ERR:  if (ctrl_done)
                                    state <= STATE_DONE;                    
             
            default:            state <= STATE_IDLE; 
       endcase
end

// ctrl_addr 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:         ctrl_addr <= 12'hxxx;
        STATE_RD_OFFSET:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_WR_OFFSET:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_WAIT:         ctrl_addr <= 12'hxxx;
        STATE_REQ_ON:       ctrl_addr <= SV_XR_ABS_ADDR_DCD;
        STATE_WAIT_ACK_ON:  ctrl_addr <= SV_XR_ABS_ADDR_DCD;
        STATE_REQ_OFF:      ctrl_addr <= SV_XR_ABS_ADDR_DCD; 
        STATE_WAIT_ACK_OFF: ctrl_addr <= SV_XR_ABS_ADDR_DCD; 
        STATE_RD_SUM:       ctrl_addr <= SV_XR_ABS_ADDR_DCD_RES;
        STATE_DONE:         ctrl_addr <= 12'hxxx;
        STATE_REQ_OFF_ERR:  ctrl_addr <= SV_XR_ABS_ADDR_DCD; 
        default:            ctrl_addr <= 12'hxxx;
    endcase
end 

// ctrl_go 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:         ctrl_go_ff <= go;
        STATE_RD_OFFSET:    ctrl_go_ff <= ctrl_done;
        STATE_WR_OFFSET:    ctrl_go_ff <= 1'b0;
        STATE_WAIT:         ctrl_go_ff <= wait_tc;
        STATE_REQ_ON:       ctrl_go_ff <= ctrl_done;
        STATE_WAIT_ACK_ON:  ctrl_go_ff <= ctrl_done;
        STATE_REQ_OFF:      ctrl_go_ff <= ctrl_done; 
        STATE_WAIT_ACK_OFF: ctrl_go_ff <= ctrl_done & ~timeout; 
        STATE_RD_SUM:       ctrl_go_ff <= 1'b0;
        STATE_DONE:         ctrl_go_ff <= 1'b0; 
        STATE_REQ_OFF_ERR:  ctrl_go_ff <= 1'b0; 
        default:            ctrl_go_ff <= 1'b0;
    endcase
end 

// delay ctrl_go for data, opcode and address setup
always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0;
    else 
        ctrl_go <= ctrl_go_ff;
end  
        
// ctrl_opcode
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:         ctrl_opcode <= 3'bxxx;
        STATE_RD_OFFSET:    ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_OFFSET:    ctrl_opcode <= CTRL_OP_WR;
        STATE_WAIT:         ctrl_opcode <= 3'bxxx;
        STATE_REQ_ON:       ctrl_opcode <= CTRL_OP_WR;
        STATE_WAIT_ACK_ON:  ctrl_opcode <= CTRL_OP_RD;
        STATE_REQ_OFF:      ctrl_opcode <= CTRL_OP_WR;
        STATE_WAIT_ACK_OFF: ctrl_opcode <= CTRL_OP_RD;  
        STATE_RD_SUM:       ctrl_opcode <= CTRL_OP_RD;
        STATE_DONE:         ctrl_opcode <= 3'bxxx;
        STATE_REQ_OFF_ERR:  ctrl_opcode <= CTRL_OP_WR;
        default:            ctrl_opcode <= 3'bxxx;
    endcase
end 

// binary to grey conversion for reye_monitor register 
step_to_mon_sv inst_step_to_mon_sv (
     .clk      (clk),
     .step     (offset),
     .monitor  (mon_data)
);

// ctrl_wdata     
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:          ctrl_wdata                         <= 16'hxxxx;
        STATE_RD_OFFSET:     ctrl_wdata                         <= 16'hxxxx;
          
        STATE_WR_OFFSET:     begin
                                 ctrl_wdata                     <= ctrl_rdata;
                                 ctrl_wdata[REYE_MON_5_OFST : REYE_MON_0_OFST]
                                                                <= mon_data;
                             end
         
        STATE_WAIT:          ctrl_wdata                         <= 16'hxxxx;       
                                 
        STATE_REQ_ON:        begin
                                 ctrl_wdata                     <= 16'h0000;
                                 ctrl_wdata[SV_XR_DCD_REQ_OFST] <= 1'b1;
                             end

        STATE_WAIT_ACK_ON:   ctrl_wdata                         <= 16'hxxxx;

        STATE_REQ_OFF:       begin
                                 ctrl_wdata                     <= 16'h0000;
                                 ctrl_wdata[SV_XR_DCD_REQ_OFST] <= 1'b0;
                             end


        STATE_WAIT_ACK_OFF:  ctrl_wdata                         <= 16'hxxxx;  
        STATE_RD_SUM:        ctrl_wdata                         <= 16'hxxxx;
        STATE_DONE:          ctrl_wdata                         <= 16'hxxxx;

        STATE_REQ_OFF_ERR:   begin
                                 ctrl_wdata                     <= 16'h0000;
                                 ctrl_wdata[SV_XR_DCD_REQ_OFST] <= 1'b0;
                             end
 
        default:             ctrl_wdata                         <= 16'hxxxx;
    endcase
end 

// sum 
always @(posedge clk)
begin 
    if ((state == STATE_RD_SUM) && ctrl_done)
        sum <= ctrl_rdata[SV_XR_DCD_RES_A_OFST +: SV_XR_DCD_RES_A_LEN];
end

// done
always @(posedge clk)
begin
    if (reset)
       done <= 1'b0;
    else 
       done <= ((state == STATE_REQ_OFF_ERR)  & ctrl_done) |
               ((state == STATE_WAIT_ACK_OFF) & timeout) |
               ((state == STATE_RD_SUM)       & ctrl_done);
end  

// timer counter
always @(posedge clk)
begin 
    if ((state == STATE_WAIT) || (state == STATE_WAIT_ACK_ON) || (state == STATE_WAIT_ACK_OFF))
        timeout_ctr <= timeout_ctr + 1'b1;
    else  
        timeout_ctr <= 'h0;
end

// decode no response timeout
always @(posedge clk) 
begin
    if (state == STATE_IDLE && go)
       timeout <= 1'b0;
    else if (timeout_ctr == TIMEOUT_COUNT -1)
       timeout <= 1'b1;
end 

// decode offset delay timeout
always @(posedge clk) 
begin
    wait_tc <= (timeout_ctr == WAIT_COUNT -1);
end

endmodule
