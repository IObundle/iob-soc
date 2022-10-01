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


// dfe calibration sweep
//
// This module performs offset and PI Phase calibration.
//
// Offset calibration involves writing to DFE offset cancellation
// registers to determine the average value that causes the testbus
// input to oscillate. Six testbus lines are monitored in parallel.
//
// PI Phase calibration involves writing to RDFE_STEP register
// to determine the value that causes a positve edge of the
// testbus.

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_cal_sweep_sv (
    input  wire        clk,
    input  wire        reset,
  
    input  wire        go,
    output reg         done,
   
    // PLL lock delay
    input  wire [15:0] pll_lock_delay,      // x (2** 14) 
    // eye_mon step interval duartion
    input  wire [7:0]  interval_delay,      // x (2** 5)
    // eye_mon change to testbus ready
    input  wire [7:0]  testbus_ready_delay, // x (2** 5) 
    // testbus samples for high
    input  wire [7:0]  testbus_samples,  

    // timer 
    input  wire [29:0] wait_timer,
    output reg         wait_timer_reset,

    // basic block control interface
    output reg         ctrl_go,       // start basic block cycle
    input  wire        ctrl_done,     // transfer done
    output reg  [2:0]  ctrl_opcode,   // cycle type
    output reg         ctrl_lock,     // multicycle lock 
    output wire [11:0] ctrl_addr,     // address
    input  wire [15:0] ctrl_rdata,    // data in
    output wire [15:0] ctrl_wdata,    // data out

    input  wire [7:0]  ctrl_testbus   // testbus
);

// declarations
//---------------------------------------
reg  [3:0]  state;
reg         reg_count_reset;
reg         cal_count_reset;
reg         oc_go;
reg         pi_phase_go;
wire        save_reg_count_tc;
wire        oc_reg_count_tc;
wire        pi_reg_count_tc;
wire        restore_reg_count_tc;
reg         wait_timer_tc;
reg         testbus_ready;
reg         wait_pll_tc; 
reg  [6:0]  cal_count;
wire        oc_count_tc;
wire        pi_phase_count_tc;
wire [23:0] oc_offset;
wire [5:0]  local_oc_done; 
wire        oc_done;
wire [5:0]  pi_phase;    
wire        pi_phase_done;    

// PHY register parameters
import sv_xcvr_h::*;    
// DFE datapath parameters
import sv_xcvr_dfe_cal_sweep_h::*; 

// control state machine
always @(posedge clk)
begin
    if (reset)
        state <= STATE_IDLE;
    else
        case (state)
            // wait for user write to control register 
            STATE_IDLE:        if (go)
                                   state <= STATE_SAVE;
                                    
            // save user register settings
            // abort if illegal channel
            STATE_SAVE:        if (ctrl_done && save_reg_count_tc)
                                   state <= STATE_OC_SETUP;
            
            // set registers to default and offset cancellation values
            STATE_OC_SETUP:    if (ctrl_done && oc_reg_count_tc)
                                   state <= STATE_OC_PLL_WAIT;
                              
            // wait PLL to lock
            STATE_OC_PLL_WAIT: if (wait_pll_tc)
                                   state <= STATE_OC_WR_12;
                               
            // offset cancellation
            // write to offset registers
            STATE_OC_WR_12:    if (ctrl_done)
                                   state <= STATE_OC_WR_15;
                                
            STATE_OC_WR_15:    if (ctrl_done && oc_done)
                                   state <= STATE_PI_SETUP;
                               else if (ctrl_done)
                                   state <= STATE_OC_WAIT;
        
            // wait cailbration time
            STATE_OC_WAIT:     if (wait_timer_tc)
                                   state <= STATE_OC_WR_12;
      
            // offset calibration complete
            // set registers for PI phase calibration
            STATE_PI_SETUP:    if (ctrl_done && pi_reg_count_tc)
                                   state <= STATE_PI_WR_13;
            
                             
            // PI phase calibration
            // write to step register
            STATE_PI_WR_13:    if (ctrl_done && pi_phase_done)
                                  state <= STATE_RESTORE;
                               else if (ctrl_done)
                                  state <= STATE_PI_WAIT;
                                
            // wait cailbration time
            STATE_PI_WAIT:     if (wait_timer_tc)
                                  state <= STATE_PI_WR_13;

            // calibration complete; restore registers to user settings
            // -- add static settings.
            STATE_RESTORE:     if (ctrl_done && restore_reg_count_tc)
                                   state <= STATE_DONE;
                               
            STATE_DONE:        state <= STATE_IDLE;
            
            default:           state <= STATE_IDLE;   
    endcase     
end

// outputs
always @(posedge clk)
begin
    // reg counter reset  
    reg_count_reset <= ((state == STATE_IDLE)     & go) |
                       ((state == STATE_SAVE)     & save_reg_count_tc & ctrl_done) |
                       ((state == STATE_OC_WR_15) & oc_done   & ctrl_done) |
                       ((state == STATE_PI_WR_13) & pi_phase_done & ctrl_done);
           
    // wait counter reset  
    wait_timer_reset <= ~(((state == STATE_OC_WR_15) & ctrl_done & ~oc_done) |
                          
                          ((state == STATE_OC_WAIT)  & ~wait_timer_tc) |
          
                          ((state == STATE_PI_SETUP) & ctrl_done & pi_reg_count_tc) |
 
                          ((state == STATE_OC_PLL_WAIT) & ~wait_pll_tc) |          
          
                          ((state == STATE_PI_WR_13) & ctrl_done & ~pi_phase_done) |

                          ((state == STATE_PI_WAIT)  & ~wait_timer_tc));
                       
    // offset and PI phase counter reset
    cal_count_reset <= ((state == STATE_PI_SETUP) & pi_reg_count_tc & ctrl_done) |
                       ((state == STATE_OC_PLL_WAIT) & wait_pll_tc); 
          
    // go for offset calibrator          
    oc_go <= ((state == STATE_OC_PLL_WAIT) & wait_pll_tc); 
                   
    // go for PI Phase calibrator          
    pi_phase_go <= ((state == STATE_PI_SETUP) & pi_reg_count_tc & ctrl_done); 
    
    // done
    done <= (state == STATE_DONE);     
 end

// ctrl go 
always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0;
    else
        begin
            case (state)
                STATE_IDLE:        ctrl_go <= 1'b0;
                STATE_SAVE:        ctrl_go <= reg_count_reset |(ctrl_done & ~save_reg_count_tc);
                STATE_OC_SETUP:    ctrl_go <= reg_count_reset |(ctrl_done & ~oc_reg_count_tc);
                STATE_OC_PLL_WAIT: ctrl_go <= wait_pll_tc;   
                STATE_OC_WR_12:    ctrl_go <= ctrl_done;
                STATE_OC_WR_15:    ctrl_go <= 1'b0;
                STATE_OC_WAIT:     ctrl_go <= wait_timer_tc;
                STATE_PI_SETUP:    ctrl_go <= reg_count_reset | ctrl_done;
                STATE_PI_WR_13:    ctrl_go <= 1'b0;
                STATE_PI_WAIT:     ctrl_go <= wait_timer_tc;
                STATE_RESTORE:     ctrl_go <= reg_count_reset |(ctrl_done & ~restore_reg_count_tc);
                STATE_DONE:        ctrl_go <= 1'b0;
                default:           ctrl_go <= 1'b0;
           endcase
    end    
end

// ctrl address, ctrl_lcok, ctrl opcode and ctrl wdata 
alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv inst_alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv (
  .clk                  (clk),
  
  .state                (state), 
  .reg_count_reset      (reg_count_reset),
  .save_reg_count_tc    (save_reg_count_tc ), 
  .oc_reg_count_tc      (oc_reg_count_tc),
  .pi_reg_count_tc      (pi_reg_count_tc),      
  .restore_reg_count_tc (restore_reg_count_tc),
  
  .oc_offset            (oc_offset), // calibration data to be written
  .pi_phase             (pi_phase),
  
  .ctrl_opcode          (ctrl_opcode),
  .ctrl_lock            (ctrl_lock),
  .ctrl_addr            (ctrl_addr),
  .ctrl_wdata           (ctrl_wdata),
  .ctrl_rdata           (ctrl_rdata),
  .ctrl_done            (ctrl_done)
);

// timer terminal counts
always @(posedge clk)
begin
    wait_timer_tc <= (wait_timer[12:5]  == interval_delay) &
                     (wait_timer[4:0]   ==  5'h1f);

    testbus_ready <= (wait_timer[12:5]  == testbus_ready_delay) &
                     (wait_timer[4:0]   == 5'h1f);

    wait_pll_tc   <= (wait_timer[29:14] == pll_lock_delay) &
                     (wait_timer[13:0]  == 14'h3fff);
end

// step counter
always @(posedge clk)
begin
    if (cal_count_reset)
        cal_count <= 7'h00;
    else if (wait_timer_tc)
        cal_count <= cal_count + 1'b1;
end

assign oc_count_tc       = (cal_count == 7'h10);
assign pi_phase_count_tc = (cal_count == 7'h7f);

// offset cancellation 
alt_xcvr_reconfig_dfe_oc_cal_sv
 inst_alt_xcvr_reconfig_dfe_oc_cal_sv[5:0] (
    .clk             (clk),
    .reset           (reset),

    .go              (oc_go),
    .enable          (wait_timer_tc),
    .count           (cal_count[4:0]),        
    .count_tc        (oc_count_tc),
              
    .testbus         ({ctrl_testbus[5], ctrl_testbus[4], ctrl_testbus[3],
                       ctrl_testbus[2], ctrl_testbus[1], ctrl_testbus[0]}),                   
                                   
    .testbus_ready   (testbus_ready),  // delay for testbus to change
      
    .offset          (oc_offset), // dfe register data
    .done            (local_oc_done)
    );         

assign oc_done = & local_oc_done;

// PI Phase calibration
alt_xcvr_reconfig_dfe_pi_phase_sv 
 inst_alt_xcvr_reconfig_dfe_pi_phase (
    .clk             (clk),
    .reset           (reset),

    .go              (pi_phase_go), 
    .enable          (wait_timer_tc),
    .count           (cal_count[5:0]),        
    .count_tc        (pi_phase_count_tc),
              
    .testbus         (ctrl_testbus[PI_TESTBUS_BIT]), 

    .testbus_ready   (testbus_ready),   // delay for testbus to change
    .testbus_samples (testbus_samples), // samples for testbus high 
              
    .pi_phase        (pi_phase),        // dfe register data
    .done            (pi_phase_done)
    );         

endmodule
