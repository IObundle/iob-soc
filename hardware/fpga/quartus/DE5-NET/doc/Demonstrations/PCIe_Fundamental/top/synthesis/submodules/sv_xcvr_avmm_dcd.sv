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


// DCD sum of ones counters
//
// Module contains 2 accumulators.
// Each acumulator sums the ones received over multiple 
// consecutive clocks. 
// 
// Accumulators are asynchronous to IP; REQ/ACK handshake transfers data.
// REQ low resets this module.
//

`timescale 1ps/1ps

(* ALTERA_ATTRIBUTE =
"-name SDC_STATEMENT \"set_false_path -from [get_registers *sv_xcvr_avmm_dcd*\|acc*] \"; -name SDC_STATEMENT \"set_false_path -from [get_registers *sv_xcvr_avmm_dcd*\|ack] \"; -name SDC_STATEMENT \"set_false_path  -to [get_keepers *sv_xcvr_avmm_dcd*\|req_ff[0]]\"" *)
module sv_xcvr_avmm_dcd #(
    parameter NUM_OF_SAMPLES = 40,
	 parameter DIN_WIDTH = 4  // data in A and B
)(
    input  wire                                           clk,
    input  wire                                           req,
    output reg                                            ack,  
    input  wire [7:0]                                     deserial_data,
    output reg  [(log2(NUM_OF_SAMPLES * DIN_WIDTH))-1 :0] acc_a,
    output reg  [(log2(NUM_OF_SAMPLES * DIN_WIDTH))-1 :0] acc_b
);  

// control states
localparam [1:0] STATE_IDLE  = 2'b00;
localparam [1:0] STATE_RESET = 2'b01;
localparam [1:0] STATE_RUN   = 2'b11;
localparam [1:0] STATE_ACK   = 2'b10;

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction
   
reg [DIN_WIDTH -1 :0]              din_a_buf;
reg [DIN_WIDTH -1 :0]              din_b_buf;
reg [(log2(DIN_WIDTH))-1 :0]       sum_in_a;
reg [(log2(DIN_WIDTH))-1 :0]       sum_in_b;
reg [1:0]                          state;
reg [(log2(NUM_OF_SAMPLES-1)-1):0] counter;
wire                               counter_tc;
wire                               acc_rst;
wire                               acc_ld;
reg [2:0]                          req_ff; 
wire                               req_sync;
integer                            i;

// input buffers
always @(posedge clk)
begin
    for (i=0; i<4; i=i+1)
    begin 
        din_a_buf[i] <= deserial_data[2*i];
        din_b_buf[i] <= deserial_data[(2*i) +1];
    end
end

// sum of inputs A
always @(posedge clk)
begin
    case (din_a_buf) 
        4'h0: sum_in_a <= 3'h0;
        4'h1: sum_in_a <= 3'h1;       
        4'h2: sum_in_a <= 3'h1;
        4'h3: sum_in_a <= 3'h2;  
        4'h4: sum_in_a <= 3'h1;
        4'h5: sum_in_a <= 3'h2;       
        4'h6: sum_in_a <= 3'h2;
        4'h7: sum_in_a <= 3'h3;          
        4'h8: sum_in_a <= 3'h1;
        4'h9: sum_in_a <= 3'h2;       
        4'ha: sum_in_a <= 3'h2;
        4'hb: sum_in_a <= 3'h3;  
        4'hc: sum_in_a <= 3'h2;
        4'hd: sum_in_a <= 3'h3;       
        4'he: sum_in_a <= 3'h3;
        4'hf: sum_in_a <= 3'h4;          
   endcase
end   

// accumulator A
always @(posedge clk)
begin
    if (acc_rst)
        acc_a <= 'h0;
    else if (acc_ld)
        acc_a <= acc_a + sum_in_a;
end

// sum of inputs B
always @(posedge clk)
begin
    case (din_b_buf) 
        4'h0: sum_in_b <= 3'h0;
        4'h1: sum_in_b <= 3'h1;       
        4'h2: sum_in_b <= 3'h1;
        4'h3: sum_in_b <= 3'h2;  
        4'h4: sum_in_b <= 3'h1;
        4'h5: sum_in_b <= 3'h2;       
        4'h6: sum_in_b <= 3'h2;
        4'h7: sum_in_b <= 3'h3;          
        4'h8: sum_in_b <= 3'h1;
        4'h9: sum_in_b <= 3'h2;       
        4'ha: sum_in_b <= 3'h2;
        4'hb: sum_in_b <= 3'h3;  
        4'hc: sum_in_b <= 3'h2;
        4'hd: sum_in_b <= 3'h3;       
        4'he: sum_in_b <= 3'h3;
        4'hf: sum_in_b <= 3'h4;          
   endcase
end   

// accumulator B
always @(posedge clk)
begin
    if (acc_rst)
        acc_b <= 'h0;
    else if (acc_ld)
        acc_b <= acc_b + sum_in_b;
end

// control
always @(posedge clk)
begin 
    if (!req_sync)
        state <=  STATE_IDLE;
    else  
       case (state)
           STATE_IDLE:  state <= STATE_RESET;
        
           STATE_RESET: state <= STATE_RUN;
           
           STATE_RUN:   if (counter_tc)
                           state <= STATE_ACK;
                     
           STATE_ACK:   state <= STATE_ACK;
                           
           default:     state <= STATE_IDLE;
       endcase
end

// state machine outputs     
assign acc_rst = (state == STATE_RESET);
assign acc_ld  = (state == STATE_RUN);

always @(posedge clk)
begin 
    if (!req_sync)
        ack <= 1'b0;
    else
        ack <= (state == STATE_ACK);            
end

// number of samples
always @(posedge clk)
begin 
    if (!acc_ld)       
        counter <= 'h0;
    else
        counter <= counter + 1'b1;
end        
        
assign counter_tc = (counter == NUM_OF_SAMPLES -1); 

// synchronize request
always @(posedge clk)
begin
    req_ff <= {req_ff[1:0], req};
end

assign req_sync = req_ff[2];

endmodule
