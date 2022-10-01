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


// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// DFE Tap Adaptation
//
// This module performs tap adaption on a user selected channel.
//
// Tap values appear on the test bus. There are 5 taps; 
//
// For each tap a histogram is created in RAM until a count of 200
// is reached. Two histograms are made in parallel because there are
// 2 taps per test bus select.

// Taps values having count of 200 are written to the
// tap registers. Manaul mode and power are enabled at the end.

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_adapt_tap_sv (
    input  wire        clk,
    input  wire        reset,
    
    // user interface
    input  wire        uif_go, 
    input  wire  [2:0] uif_mode, 
    output reg         uif_busy, 
    input  wire  [5:0] uif_addr, 
    input  wire [15:0] uif_wdata,
         
    // basic block control interface
    output reg         ctrl_go, 
    output reg   [2:0] ctrl_opcode,
    output reg         ctrl_lock,     // multicycle lock 
    input  wire        ctrl_done,     // end of transfer 
    output reg  [11:0] ctrl_addr,
    input  wire        ctrl_chan_err, // channel not legal
    input  wire [15:0] ctrl_rdata,
    output reg  [15:0] ctrl_wdata,
        
    input  wire  [7:0] ctrl_testbus 
);
// bit delay 6GHz * 2000 (reconfig clocks))
parameter [7:0] DEFAULT_REG_WAIT  = 55;  

// RAM count
parameter [9:0] DEFAULT_REG_COUNT  = 200;  

// test bus selects
parameter [15:0] TESTBUS_SEL_1 = 16'h09;
parameter [15:0] TESTBUS_SEL_2 = 16'h0a; 
parameter [15:0] TESTBUS_SEL_3 = 16'h0b;  

// user modes
localparam [2:0] UIF_MODE_RD   = 3'b000;
localparam [2:0] UIF_MODE_WR   = 3'b001;
localparam [2:0] UIF_MODE_PHYS = 3'b010;

// basic op codes
localparam [2:0] CTRL_OP_RD    = 3'b000;
localparam [2:0] CTRL_OP_WR    = 3'b001;
localparam [2:0] CTRL_OP_PHYS  = 3'b010;
localparam [2:0] CTRL_OP_TBUS  = 3'b011;

// dfe hardware bits
// reg 11
localparam CTRL_RDFE_T1_0  = 0;  // tap 1 bit 0
localparam CTRL_RDFE_T1_1  = 1;  // tap 1 bit 1
localparam CTRL_RDFE_T1_2  = 2;  // tap 1 bit 2
localparam CTRL_RDFE_T1_3  = 3;  // tap 1 bit 3
localparam CTRL_RDFE_T2_0  = 4;  // tap 2
localparam CTRL_RDFE_T2_1  = 5;
localparam CTRL_RDFE_T2_2  = 6;
localparam CTRL_RDFE_T3_0  = 7;
localparam CTRL_RDFE_T3_1  = 8;  // tap 3
localparam CTRL_RDFE_T3_2  = 9;
localparam CTRL_RDFE_T4_0  = 10;
localparam CTRL_RDFE_T4_1  = 11; // tap 4
localparam CTRL_RDFE_T4_2  = 12;
localparam CTRL_RDFE_T5_0  = 13; // tap 5
localparam CTRL_RDFE_T5_1  = 14;
localparam CTRL_RDFE_ADAPT = 15; // adapt en

// reg 12
localparam CTRL_RDFE_PDB   = 7;   // power down

// reg 13
localparam CTRL_RDFE_BYPASS = 0; // bypass
localparam CTRL_RDFE_T2INV  = 9; // polarity
localparam CTRL_RDFE_T3INV  = 10;
localparam CTRL_RDFE_T4INV  = 11;
localparam CTRL_RDFE_T5INV  = 12;

// reg 14
localparam CTRL_RDFE_HOLD = 13; // Adapt Hold

// register bits values
localparam CTRL_RDFE_ADAPT_ON  = 1'b1;
localparam CTRL_RDFE_PDB_ON    = 1'b1;
localparam CTRL_RDFE_BYPASS_ON = 1'b1; 
localparam CTRL_RDFE_HOLD_EN   = 1'b1; 

//---------------------------------------
// state machines
//---------------------------------------
// Control state assignments
localparam [3:0] STATE_IDLE          = 4'h0;
localparam [3:0] STATE_BYPASS_OFF_RD = 4'h1;
localparam [3:0] STATE_BYPASS_OFF_WR = 4'h2;
localparam [3:0] STATE_ADAPT_ON      = 4'h3;
localparam [3:0] STATE_PDB_ON_RD     = 4'h4;
localparam [3:0] STATE_PDB_ON_WR     = 4'h5;
localparam [3:0] STATE_TESTBUS_SEL   = 4'h6;
localparam [3:0] STATE_RAM_INIT      = 4'h7;
localparam [3:0] STATE_RAM_WR        = 4'h8;
localparam [3:0] STATE_WR_REG11      = 4'h9;
localparam [3:0] STATE_WR_REG13      = 4'ha;

// declarations
reg  [3:0]  state;
reg         ctrl_go_ff;
reg  [15:0] save_ctrl_reg13;
reg  [2:0]  cycle_ctr;
wire        cycle_ctr_tc;
reg  [7:0]  testbus_ff [0:3]/*synthesis altera_attribute =  "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3" */;  
reg  [2:0]  testbus_stable;
reg         testbus_ld;
reg  [7:0]  testbus_sync;
reg  [3:0]  testbus_odd_tap;
reg  [3:0]  testbus_even_tap;
wire [3:0]  testbus_tap;
reg  [7:0]  reg_wait;
reg  [7:0]  wait_ctr;
reg         wait_tc;
reg  [9:0]  reg_count;
reg  [5:0]  ram_ctrl_ff;
wire        ram_done;
reg         ram_addr_ld;
reg         ram_we;
reg  [4:0]  ram_addr;
wire        ram_addr_tc;
(* ramstyle = "MLAB, no_rw_check" *) reg  [9:0]  ram [0:31]; 
wire [9:0]  ram_dout;
reg  [9:0]  ram_din;
wire        ram_stop;
reg         odd_tap_done;
reg         even_tap_done;
reg  [3:0]  tap1;
reg  [2:0]  tap2;
reg  [2:0]  tap3;
reg  [2:0]  tap4;
reg  [1:0]  tap5;
reg         tap2_inv;
reg         tap3_inv;
reg         tap4_inv;
reg         tap5_inv;
integer     i;

import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*; 

// control state machine
always @(posedge clk)
begin
      if (reset)
          state <= STATE_IDLE;
      else
          case (state)
             // wait for Go
             STATE_IDLE:          if (uif_go && (uif_mode == UIF_MODE_WR) && (uif_addr == XR_DFE_OFFSET_TAP_ADAPT)) 
                                      state <= STATE_BYPASS_OFF_RD; 
       
             // adaptation engine on
             STATE_BYPASS_OFF_RD: if (ctrl_done && ctrl_chan_err)
                                      state <= STATE_IDLE;
                                  else if (ctrl_done)
                                      state <= STATE_BYPASS_OFF_WR;
             
             STATE_BYPASS_OFF_WR: if (ctrl_done)
                                      state <= STATE_ADAPT_ON;
            
             STATE_ADAPT_ON: if (ctrl_done)
                                      state <= STATE_PDB_ON_RD; 

             STATE_PDB_ON_RD:     if (ctrl_done)
                                      state <= STATE_PDB_ON_WR; 

             STATE_PDB_ON_WR:     if (ctrl_done)
                                      state <= STATE_TESTBUS_SEL; 
     
             // testbus sel
             STATE_TESTBUS_SEL:   if (ctrl_done)  
                                      state <= STATE_RAM_INIT;
          
             // clear histogram RAM
             STATE_RAM_INIT:      if (ram_addr_tc)  
                                      state <= STATE_RAM_WR;
                 
             // update histogram RAM
             STATE_RAM_WR:        if (ram_done && odd_tap_done && cycle_ctr_tc)
                                      state <= STATE_WR_REG11;
                                  else if (ram_done && odd_tap_done && even_tap_done)
                                      state <= STATE_TESTBUS_SEL; 
                                 
             // engine off and write tap registers         
             STATE_WR_REG11:      if (ctrl_done)
                                      state <= STATE_WR_REG13;
             
             STATE_WR_REG13:      if (ctrl_done)
                                      state <= STATE_IDLE;

    
             default:             state <= STATE_IDLE;   
    endcase     
end

// busy to user
assign uif_busy = (state != STATE_IDLE);

// ctrl go 
always @(posedge clk)
begin
    if (reset)
        ctrl_go_ff <= 1'b0;
    else
        case (state)
            STATE_IDLE:          ctrl_go_ff <= uif_go & (uif_mode == UIF_MODE_WR) &
                                               (uif_addr == XR_DFE_OFFSET_TAP_ADAPT);
            STATE_BYPASS_OFF_RD: ctrl_go_ff <= ctrl_done & ~ctrl_chan_err;
            STATE_BYPASS_OFF_WR: ctrl_go_ff <= ctrl_done;
            STATE_ADAPT_ON:      ctrl_go_ff <= ctrl_done;
            STATE_PDB_ON_RD:     ctrl_go_ff <= ctrl_done;
            STATE_PDB_ON_WR:     ctrl_go_ff <= ctrl_done;
            STATE_TESTBUS_SEL:   ctrl_go_ff <= 1'b0;
            STATE_RAM_INIT:      ctrl_go_ff <= 1'b0;
            STATE_RAM_WR:        ctrl_go_ff <= (ram_done & odd_tap_done & cycle_ctr_tc) | (ram_done && odd_tap_done && even_tap_done);  
            STATE_WR_REG11:      ctrl_go_ff <= ctrl_done;
            STATE_WR_REG13:      ctrl_go_ff <= 1'b0;
            default:             ctrl_go_ff <= 1'b0;
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
        STATE_IDLE:          ctrl_opcode <= 3'hx;
        STATE_BYPASS_OFF_RD: ctrl_opcode <= CTRL_OP_RD;
        STATE_BYPASS_OFF_WR: ctrl_opcode <= CTRL_OP_WR;
        STATE_ADAPT_ON:      ctrl_opcode <= CTRL_OP_WR;
        STATE_PDB_ON_RD:     ctrl_opcode <= CTRL_OP_RD;
        STATE_PDB_ON_WR:     ctrl_opcode <= CTRL_OP_WR;
        STATE_TESTBUS_SEL:   ctrl_opcode <= CTRL_OP_TBUS;
        STATE_RAM_INIT:      ctrl_opcode <= 3'hx;
        STATE_RAM_WR:        ctrl_opcode <= 3'hx;
        STATE_WR_REG11:      ctrl_opcode <= CTRL_OP_WR;
        STATE_WR_REG13:      ctrl_opcode <= CTRL_OP_WR;
        default:             ctrl_opcode <= 3'hx; 
    endcase
end
 
// ctrl address 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:          ctrl_addr <= 12'hxxx;
        STATE_BYPASS_OFF_RD: ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        STATE_BYPASS_OFF_WR: ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        STATE_ADAPT_ON:      ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        STATE_PDB_ON_RD:     ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_PDB_ON_WR:     ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_TESTBUS_SEL:   ctrl_addr <= 12'h000;
        STATE_RAM_INIT:      ctrl_addr <= 12'hxxx;
        STATE_RAM_WR:        ctrl_addr <= 12'hxxx;
        STATE_WR_REG11:      ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        STATE_WR_REG13:      ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
    endcase
end

// save copy of register 13
always @(posedge clk)
begin
    if ((state == STATE_BYPASS_OFF_RD) && ctrl_done)
         save_ctrl_reg13 <= ctrl_rdata;
end 


// ctrl wdata
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:          ctrl_wdata <= 16'hxxxx;
    
        STATE_BYPASS_OFF_RD: ctrl_wdata <= 16'hxxxx;
           
        STATE_BYPASS_OFF_WR: begin 
                                 ctrl_wdata <= save_ctrl_reg13;  
                                 ctrl_wdata[CTRL_RDFE_BYPASS] <= ~CTRL_RDFE_BYPASS_ON;
                             end
         
		  STATE_ADAPT_ON:      begin
                                 ctrl_wdata <= 16'h0000;
                                 ctrl_wdata[CTRL_RDFE_ADAPT] <= CTRL_RDFE_ADAPT_ON;
                             end
 									  
   
        STATE_PDB_ON_RD:     ctrl_wdata <= 16'hxxxx;
           
        STATE_PDB_ON_WR:     begin 
                                 ctrl_wdata <= ctrl_rdata;  
                                 ctrl_wdata[CTRL_RDFE_PDB] <= CTRL_RDFE_PDB_ON;
                             end
    
        STATE_TESTBUS_SEL:   case (cycle_ctr)
                                 3'b001:  ctrl_wdata <= TESTBUS_SEL_1;
                                 3'b010:  ctrl_wdata <= TESTBUS_SEL_2;
                                 3'b100:  ctrl_wdata <= TESTBUS_SEL_3;
                                 default: ctrl_wdata <= 16'hxxxx;
                             endcase   
    
        STATE_RAM_INIT:      ctrl_wdata <= 16'hxxxx;
        STATE_RAM_WR:        ctrl_wdata <= 16'hxxxx;

        STATE_WR_REG11:      begin
                                 ctrl_wdata [CTRL_RDFE_T1_3 : CTRL_RDFE_T1_0] <= tap1;
                                 ctrl_wdata [CTRL_RDFE_T2_2 : CTRL_RDFE_T2_0] <= tap2[2:0];
                                 ctrl_wdata [CTRL_RDFE_T3_2 : CTRL_RDFE_T3_0] <= tap3[2:0];
                                 ctrl_wdata [CTRL_RDFE_T4_2 : CTRL_RDFE_T4_0] <= tap4[2:0];
                                 ctrl_wdata [CTRL_RDFE_T5_1 : CTRL_RDFE_T5_0] <= tap5[1:0];
                                 ctrl_wdata [CTRL_RDFE_ADAPT] <= ~CTRL_RDFE_ADAPT_ON; //Turn off Adapt_ON
                             end
        
        STATE_WR_REG13:      begin
                                 ctrl_wdata <= save_ctrl_reg13;
                                 ctrl_wdata[CTRL_RDFE_BYPASS] <= CTRL_RDFE_BYPASS_ON;
                                 ctrl_wdata[CTRL_RDFE_T2INV]  <= tap2_inv;
                                 ctrl_wdata[CTRL_RDFE_T3INV]  <= tap3_inv; 
                                 ctrl_wdata[CTRL_RDFE_T4INV]  <= tap4_inv; 
                                 ctrl_wdata[CTRL_RDFE_T5INV]  <= tap5_inv;
                             end 
									  
        default:             ctrl_wdata <= 16'hxxxx;  
    endcase
end

// ctrl_lock
always @(posedge clk)
begin
    ctrl_lock <= (state != STATE_IDLE) & 
                 (state != STATE_ADAPT_ON) &
                 (state != STATE_WR_REG13);   
end 

// cycle count (one-hot) 
always @(posedge clk)
begin
    if (state == STATE_IDLE)
        cycle_ctr <= 3'b001;
    else if (ram_done && odd_tap_done && even_tap_done)
        cycle_ctr <= cycle_ctr << 1'b1;
end

assign cycle_ctr_tc = cycle_ctr[2];

// synchronize test bus
always @(posedge clk)
begin
    testbus_ff[0] <= ctrl_testbus;
    for (i=0; i<3; i=i+1) 
        testbus_ff[i+1] <= testbus_ff[i];
end

// testbus needs to be stable for 4 consecutive clocks
always @(posedge clk)
begin
    testbus_stable <= {testbus_stable[1:0], (testbus_ff[3] == testbus_ff[2])};
    testbus_ld     <= (& testbus_stable) &  (testbus_ff[3] == testbus_ff[2]);
end

always @(posedge clk)
begin 
    if (testbus_ld)        
        testbus_sync <= testbus_ff[3];
end
        
// separate odd and even taps
always @(*)
begin
    case (cycle_ctr) 
        3'b001:  testbus_odd_tap =  testbus_sync[7:4];
        3'b010:  testbus_odd_tap = {testbus_sync[1], testbus_sync[7:5]};
        3'b100:  testbus_odd_tap = {1'b0, testbus_sync[5], testbus_sync[7:6]};
        default: testbus_odd_tap = 4'bxxxx;
    endcase
  
    case (cycle_ctr) 
        3'b001:  testbus_even_tap = {testbus_sync[0], testbus_sync[3:1]};
        3'b010:  testbus_even_tap = {testbus_sync[0], testbus_sync[4:2]};
        3'b100:  testbus_even_tap = 4'b0000; // no tap 6
        default: testbus_even_tap = 4'bxxxx;
    endcase
end

assign testbus_tap = (ram_ctrl_ff[2]) ? testbus_even_tap : testbus_odd_tap;

// user 'wait count' register
always @(posedge clk)
begin
    if (reset)
        reg_wait <= DEFAULT_REG_WAIT;
    else if (uif_go && (uif_mode == UIF_MODE_WR) && ((uif_addr == XR_DFE_OFFSET_ADAPT_WAIT) || (uif_addr == XR_DFE_OFFSET_ADAPT_TIME)))
        reg_wait <= uif_wdata[7:0];
end

// wait counter
always @(posedge clk)
begin
    if ((state != STATE_RAM_WR))
        wait_ctr <= 8'h00;
    else if (wait_tc)
        wait_ctr <= 8'h00;
    else
        wait_ctr <= wait_ctr + 1'b1;
end

always @(posedge clk)
begin
    wait_tc <= (wait_ctr == reg_wait); 
end

// user 'max count' register
always @(posedge clk)
begin
    if (reset)
        reg_count <= DEFAULT_REG_COUNT;
    else if (uif_go && (uif_mode == UIF_MODE_WR) && (uif_addr == XR_DFE_OFFSET_ADAPT_COUNT))
        reg_count <= uif_wdata[9:0];
end

// RAM control
always @(posedge clk)
begin
    ram_ctrl_ff <= {ram_ctrl_ff[4:0], wait_tc};
end

assign ram_done = ram_ctrl_ff[5];

// RAM address load and RAM WE
always @(posedge clk)  
begin
    ram_addr_ld <= wait_tc | ram_ctrl_ff[1];
    
    ram_we      <= ((state == STATE_TESTBUS_SEL) & ctrl_done) |
                   ((state == STATE_RAM_INIT) & ~ram_addr_tc) |
                   (ram_ctrl_ff[1]) | (ram_ctrl_ff[3]);
end

// RAM address
// MSB is odd/even tap select 
always @(posedge clk)  
begin
    if (state == STATE_TESTBUS_SEL)
        ram_addr <= 5'h00;
    else if (state == STATE_RAM_INIT)  
        ram_addr <= ram_addr + 1'b1;
    else if (ram_addr_ld)
        ram_addr <= {ram_ctrl_ff[2], testbus_tap};  
end

assign ram_addr_tc = & ram_addr;

// RAM (MLAB)
always @(posedge clk)
begin
    if (ram_we)
        ram[ram_addr] <= ram_din;
end

assign ram_dout = ram[ram_addr];

// RAM data in
always @(posedge clk)
begin
   if ((state == STATE_TESTBUS_SEL) || (state == STATE_RAM_INIT))
       ram_din <= 10'h000;
   else 
     ram_din <= ram_dout + 1'b1;
end

// Check RAM count   
assign ram_stop = (ram_din == reg_count); 

// done status
// odd
always @(posedge clk)
begin
    if (state == STATE_RAM_INIT)
        odd_tap_done <= 1'b0;
    else if (ram_stop && ram_ctrl_ff[2]) // RAM WE odd
        odd_tap_done <= 1'b1;
end

// even
always @(posedge clk)
begin
    if (state == STATE_RAM_INIT)
        even_tap_done <= 1'b0;
    else if (ram_stop && ram_ctrl_ff[4]) // RAM WE even
        even_tap_done <= 1'b1;
end    
    
// latch tap values 
// odd
always @(posedge clk)
begin
    if (ram_stop && !odd_tap_done && (state == STATE_RAM_WR))
    case (cycle_ctr)
       3'b001:  tap1            <= ram_addr[3:0];
       3'b010: {tap3_inv, tap3} <= ram_addr[3:0];
       3'b100: {tap5_inv, tap5} <= ram_addr[2:0];
       default: ;
    endcase
end

// even  
always @(posedge clk)
begin
    if (ram_stop && !even_tap_done && (state == STATE_RAM_WR))
    case (cycle_ctr)
       3'b001: {tap2_inv, tap2} <= ram_addr[3:0];
       3'b010: {tap4_inv, tap4} <= ram_addr[3:0];
       default: ;
    endcase
end  
  
endmodule
