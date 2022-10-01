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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// Eye Monitor Data Control
//
// This module handles remapping and rearranging eyemon hardware
// registers to a nicer format for the user. 
//
// It receives user indirect registers from ALT_XRECONF_UIF and
// it generates write and read cycles to the ALT_XRECONF_BASIC.
//
// Setting REYE_PDB sets RCRU_EYE and writes 3'b010 to REYE_ISEL.
// Resetting REYE_PDB resets RCRU_EYE and writes 3'001 to REYE_ISEL.

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_eyemon_ctrl_sv #(
    parameter UIF_ADDR_WIDTH  = 6,
    parameter UIF_DATA_WIDTH  = 16,
    parameter CTRL_ADDR_WIDTH = 11,
    parameter CTRL_DATA_WIDTH = 16,
    parameter BER_COUNTER_EN  = 0
)
(
    input  wire                        clk,
    input  wire                        reset,
   
    // user interface
    input  wire                        uif_go,       // start user cycle
    input  wire [2:0]                  uif_mode,     // operation
    output reg                         uif_busy,     // transfer in process
    input  wire [UIF_ADDR_WIDTH -1:0]  uif_addr,     // address offset
    input  wire [UIF_DATA_WIDTH -1:0]  uif_wdata,    // data in
    output reg  [UIF_DATA_WIDTH -1:0]  uif_rdata,    // data out
    input  wire                        uif_chan_err, // illegal channel
    output reg                         uif_addr_err, // illegal address
   
    // basic block control interface
    output reg                         ctrl_go,      // start basic block cycle
    output reg  [2:0]                  ctrl_opcode,  // 0=read; 1=write;
    output reg                         ctrl_lock,    // multicycle lock 
    input  wire                        ctrl_wait,    // transfer in process
    output reg  [CTRL_ADDR_WIDTH -1:0] ctrl_addr,    // PHY register address
    input  wire [CTRL_DATA_WIDTH -1:0] ctrl_rdata,   // data in
    output reg  [CTRL_DATA_WIDTH -1:0] ctrl_wdata,   // data out

    // Testbus for the BER Counter
    input  wire [7:0]                  eyemon_testbus //testbus data in
);

//determin if the BER is on
reg ber_generate = (BER_COUNTER_EN == 1)? 1'b1 : 1'b0;

// done state machine
localparam [1:0] STATE_DONE0    = 2'b00;
localparam [1:0] STATE_DONE1    = 2'b01;
localparam [1:0] STATE_DONE2    = 2'b10;

// state assignments
localparam [3:0] STATE_IDLE     = 4'b0000;
localparam [3:0] STATE_RD       = 4'b0001;
localparam [3:0] STATE_RMW2_RD  = 4'b0010;
localparam [3:0] STATE_RMW2_WR  = 4'b0011;
localparam [3:0] STATE_RMW_RD   = 4'b0100;
localparam [3:0] STATE_RMW_WR   = 4'b0101;
localparam [3:0] STATE_RMW3_RD  = 4'b0110;
localparam [3:0] STATE_RMW3_WR  = 4'b0111;
localparam [3:0] STATE_RMW4_RD  = 4'b1000;
localparam [3:0] STATE_RMW4_WR  = 4'b1001;

// user modes
localparam UIF_MODE_RD          = 3'h0;
localparam UIF_MODE_WR          = 3'h1;
localparam UIF_MODE_PHYS        = 3'h2;


// basic control commands
localparam CTRL_OP_RD           = 3'h0;
localparam CTRL_OP_WR           = 3'h1;
localparam CTRL_OP_DIR_WR       = 3'h3;

// user bits
// control reg for the eyeQ
localparam UIF_REYE_PDB         = 0;

// user bits
// control registers for the BER Counter
localparam UIF_RBER_CLK_EN      = 1;
localparam UIF_RBER_COUNT_EN    = 2;
localparam UIF_RBER_SYNC_MODE   = 3;
localparam UIF_RBER_SNAP_SHOT   = 4;
localparam BER_STATUS           = 12;

// Testbus Select
localparam CTRL_EYEMON_ODI_TBUS = 4'b1100;

// Boundaries for the MSB and LSB for the BER Threshold
localparam UIF_RBER_THRESHOLD_0 = 0;
localparam UIF_RBER_THRESHOLD_7 = 7;

// horizontal phase reg
localparam UIF_REYE_MONITOR_0   = 0; // bit 0
localparam UIF_REYE_MONITOR_1   = 1; // bit 1
localparam UIF_REYE_MONITOR_2   = 2; 
localparam UIF_REYE_MONITOR_3   = 3; 
localparam UIF_REYE_MONITOR_4   = 4; 
localparam UIF_REYE_MONITOR_5   = 5; 

// vertical height reg
localparam UIF_REYE_VERTICAL_0  = 0;
localparam UIF_REYE_VERTICAL_1  = 1;
localparam UIF_REYE_VERTICAL_2  = 2;
localparam UIF_REYE_VERTICAL_3  = 3;
localparam UIF_REYE_VERTICAL_4  = 4;
localparam UIF_REYE_VERTICAL_5  = 5;

// PHY bits
// reg 16
localparam CTRL_REYE_ISEL_0     = 0;
localparam CTRL_REYE_ISEL_1     = 1;
localparam CTRL_REYE_ISEL_2     = 2;
localparam CTRL_REYE_MONITOR_0  = 3; 
localparam CTRL_REYE_MONITOR_1  = 4; 
localparam CTRL_REYE_MONITOR_2  = 5; 
localparam CTRL_REYE_MONITOR_3  = 6; 
localparam CTRL_REYE_MONITOR_4  = 7; 
localparam CTRL_REYE_MONITOR_5  = 8; 
localparam CTRL_REYE_PDB        = 11;  

// reg 17
localparam CTRL_REYE_BER_CHK_EN = 4;
localparam CTRL_REYE_VERTICAL_0 = 5;  
localparam CTRL_REYE_VERTICAL_1 = 6;
localparam CTRL_REYE_VERTICAL_2 = 7;
localparam CTRL_REYE_VERTICAL_3 = 8;
localparam CTRL_REYE_VERTICAL_4 = 9; 
localparam CTRL_REYE_VERTICAL_5 = 10;

// reg C
localparam CTRL_REYE_RCRU       = 5;

// REYE_ISEL values
localparam [2:0] REYE_ISEL_OFF  = 3'b001;
localparam [2:0] REYE_ISEL_ON   = 3'b010;

// register addresses
import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*;

// declarations
reg  [1:0] state_done;
wire       ctrl_done;
reg  [3:0] state;
reg        ctrl_go_ff;
reg  [5:0] mon_data;
reg  [5:0] step_data;
reg  [3:0] reset_ff;
wire       reset_sync;
reg        ber_clk_en;    
reg        ber_soft_reset; 
reg        ber_snap_shot; 
reg        ber_count_en;  
wire [31:0] ber_bit_hi_data;
wire [31:0] ber_bit_low_data;
wire [31:0] ber_err_hi_data;
wire [31:0] ber_err_low_data;
wire [31:0] ber_excp_low_data;
reg  [UIF_RBER_THRESHOLD_7:UIF_RBER_THRESHOLD_0]      ber_threshold = 8'hA;

// creating CTRL_DONE from CTRL_WAIT
always @(posedge clk)
begin
    if (reset)
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

// control state machine
always @(posedge clk)
begin
    if (reset)
        state <= STATE_IDLE;
    else
        case (state)
            STATE_IDLE:    if (uif_go && (uif_mode == UIF_MODE_WR))
                                case (uif_addr)
                                    //if the BER counters are enabled, then starte from a RMW operation in the master statemachine
                                    //This state controls the other sequence blocks, which assign the address offsets and data values
                                    XR_EYEMON_OFFSET_CTRL:     state <= (ber_generate == 1'b1)? STATE_RMW4_WR: STATE_RMW2_RD;
                                    XR_EYEMON_OFFSET_HPHASE:   state <= STATE_RMW_RD; 
                                    XR_EYEMON_OFFSET_VHEIGHT:  state <= STATE_RMW_RD;
                                    XR_EYEMON_OFFSET_EYEMON16: state <= STATE_RMW_WR;
                                    XR_EYEMON_OFFSET_EYEMON17: state <= STATE_RMW_WR;
                                    XR_EYEMON_OFFSET_BERTHRESH: state <= STATE_RMW_WR;
                                    default:                   state <= STATE_IDLE;
                                endcase //if uif_go and uif_mode_read and the uif_addr matches an offset
                            else if ((uif_go && (uif_mode == UIF_MODE_RD)) &&
                                               ((uif_addr == XR_EYEMON_OFFSET_CTRL)     ||
                                                (uif_addr == XR_EYEMON_OFFSET_HPHASE)   ||
                                                (uif_addr == XR_EYEMON_OFFSET_VHEIGHT)  ||
                                                (uif_addr == XR_EYEMON_OFFSET_EYEMON16) ||
                                                (uif_addr == XR_EYEMON_OFFSET_EYEMON17) ||
                                                (uif_addr == XR_EYEMON_OFFSET_BIT_HI)   ||
                                                (uif_addr == XR_EYEMON_OFFSET_BIT_LOW)  ||
                                                (uif_addr == XR_EYEMON_OFFSET_ERR_HI)   ||
                                                (uif_addr == XR_EYEMON_OFFSET_ERR_LOW)  ||
                                                (uif_addr == XR_EYEMON_OFFSET_EXCP_LOW) ||
                                                (uif_addr == XR_EYEMON_OFFSET_BERTHRESH)) )
                                              
                                     state <= STATE_RD;
                                                               
            // read cycle
            STATE_RD:       if (ctrl_done)
                                 state <= STATE_IDLE;

             // read cycle for 1 of 4 read-modify-writes 
            STATE_RMW4_RD:  if (ctrl_done && uif_chan_err)
                                 state <= STATE_IDLE;
                            else if (ctrl_done)
                                 state <= STATE_RMW4_WR;
                                
            // write cycle for 1 of 4 read-modify-writes    
            STATE_RMW4_WR:  if (ctrl_done)
                                 state <= STATE_RMW3_RD;
                                      
            // read cycle for 2 of 4 read-modify-writes 
            STATE_RMW3_RD:  if (ctrl_done && uif_chan_err)
                                 state <= STATE_IDLE;
                            else if (ctrl_done)
                                 state <= STATE_RMW3_WR;
                         
            // write cycle for 2 of 4 read-modify-writes    
            STATE_RMW3_WR:  if (ctrl_done)
                                 state <= STATE_RMW2_RD;
                                      
            // read cycle for 3 of 4 read-modify-writes 
            STATE_RMW2_RD:  if (ctrl_done && uif_chan_err)
                                 state <= STATE_IDLE;
                            else if (ctrl_done)
                                 state <= STATE_RMW2_WR;
                         
            // write cycle for 3 of 4 read-modify-writes    
            STATE_RMW2_WR:  if (ctrl_done)
                                 state <= STATE_RMW_RD;
                              
            // read cycle of last read-modify-write
            STATE_RMW_RD:   if (ctrl_done && uif_chan_err)
                                state <= STATE_IDLE;
                            else if (ctrl_done)
                                state <= STATE_RMW_WR;      
                                               
            // write cycle of last read-modify-write    
            STATE_RMW_WR:   if (ctrl_done)
                                 state <= STATE_IDLE;
                                                
            default:         state <= STATE_IDLE;
    endcase     
end

// outputs
always @(posedge clk)
begin
    if (reset_sync)
         begin
              uif_busy      <= 1'b0;
              ctrl_go_ff    <= 1'b0;
              ctrl_go       <= 1'b0;
              ctrl_lock     <= 1'b0;
              ctrl_opcode   <= 3'b000;
              uif_addr_err  <= 1'b0; 
          end
    else
         begin
              // busy to user 
              // UIF module add a wait state 
              uif_busy <= uif_go | (state !== STATE_IDLE); 
            
              // go to basic
              case (state)
                  STATE_IDLE:   if ((uif_addr == XR_EYEMON_OFFSET_CTRL)     ||
                                    (uif_addr == XR_EYEMON_OFFSET_HPHASE)   ||
                                    (uif_addr == XR_EYEMON_OFFSET_VHEIGHT)  || 
                                    (uif_addr == XR_EYEMON_OFFSET_BIT_HI)   ||   
                                    (uif_addr == XR_EYEMON_OFFSET_BIT_LOW)  ||  
                                    (uif_addr == XR_EYEMON_OFFSET_ERR_HI)   ||   
                                    (uif_addr == XR_EYEMON_OFFSET_ERR_LOW)  ||  
                                    (uif_addr == XR_EYEMON_OFFSET_EXCP_LOW) || 
                                    (uif_addr == XR_EYEMON_OFFSET_BERTHRESH)||
                                    (uif_addr == XR_EYEMON_OFFSET_EYEMON16) ||
                                    (uif_addr == XR_EYEMON_OFFSET_EYEMON17))
                                       ctrl_go_ff <= uif_go;
                                       
                  STATE_RD:      ctrl_go_ff <= 1'b0;
                  STATE_RMW4_RD: ctrl_go_ff <= ctrl_done;
                  STATE_RMW4_WR: ctrl_go_ff <= ctrl_done;
                  STATE_RMW3_RD: ctrl_go_ff <= ctrl_done;
                  STATE_RMW3_WR: ctrl_go_ff <= ctrl_done;
                  STATE_RMW2_RD: ctrl_go_ff <= ctrl_done;
                  STATE_RMW2_WR: ctrl_go_ff <= ctrl_done;
                  STATE_RMW_RD:  ctrl_go_ff <= ctrl_done;
                  STATE_RMW_WR:  ctrl_go_ff <= 1'b0;
                  default:       ctrl_go_ff <= 1'b0;
             endcase 
      
             // delay to provide setup time for address, write data, opcode and lock      
             ctrl_go <= ctrl_go_ff;
            
             // lock to basic
             ctrl_lock <= (state == STATE_RMW4_RD) | (state == STATE_RMW4_WR) |
                          (state == STATE_RMW3_RD) | (state == STATE_RMW3_WR) |
                          (state == STATE_RMW2_RD) | (state == STATE_RMW2_WR) |
                          (state == STATE_RMW_RD);
          
             // opcode to basic
              case (state)
                  STATE_IDLE:    ctrl_opcode <= 3'b000;
                  STATE_RD:      ctrl_opcode <= CTRL_OP_RD;  
                  STATE_RMW4_RD: ctrl_opcode <= CTRL_OP_RD;
                  STATE_RMW4_WR: ctrl_opcode <= CTRL_OP_DIR_WR;//if BER Clk is enabled, configure the testbus
                  STATE_RMW3_RD: ctrl_opcode <= CTRL_OP_RD;
                  STATE_RMW3_WR: ctrl_opcode <= CTRL_OP_WR;
                  STATE_RMW2_RD: ctrl_opcode <= CTRL_OP_RD; 
                  STATE_RMW2_WR: ctrl_opcode <= CTRL_OP_WR;
                  STATE_RMW_RD:  ctrl_opcode <= CTRL_OP_RD;
                  STATE_RMW_WR:  ctrl_opcode <= CTRL_OP_WR;
                  default:       ctrl_opcode <= 3'b000;
               endcase
               
              // illegal address status for user
              if (uif_go && (uif_addr != XR_EYEMON_OFFSET_CTRL)     &&
                            (uif_addr != XR_EYEMON_OFFSET_HPHASE)   &&
                            (uif_addr != XR_EYEMON_OFFSET_VHEIGHT)  &&
                            (uif_addr != XR_EYEMON_OFFSET_BIT_HI)   &&    
                            (uif_addr != XR_EYEMON_OFFSET_BIT_LOW)  &&   
                            (uif_addr != XR_EYEMON_OFFSET_ERR_HI)   &&    
                            (uif_addr != XR_EYEMON_OFFSET_ERR_LOW)  &&   
                            (uif_addr != XR_EYEMON_OFFSET_EXCP_LOW) &&  
                            (uif_addr != XR_EYEMON_OFFSET_BERTHRESH)&& 
                            (uif_addr != XR_EYEMON_OFFSET_EYEMON16) &&
                            (uif_addr != XR_EYEMON_OFFSET_EYEMON17))
                  uif_addr_err <= 1'b1;   
              else if (uif_go)       
                  uif_addr_err <= 1'b0;
        end
end

// ctrl_address 
always @(posedge clk)
 begin
     case (uif_addr)
        //needs to be four read-modified writes to address the testbus, configure the data path, configure
        //the eye monitor powerdown and de-assert the Serial Bit comparator reset.
        XR_EYEMON_OFFSET_CTRL:    //sequence the order the reconfig_address is assigned based upon the sequence
                                  //of the reconfiguration
                                  if (ber_generate == 1'b1) begin
                                    if ((state == STATE_RMW4_WR)) 
                                        ctrl_addr <= XR_DIRECT_OFFSET_TESTBUS_SEL; //configure testbus
                                    else if ((state == STATE_RMW3_RD) || (state == STATE_RMW3_WR))
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON0C; // reye_rcru
                                    else if ((state ==  STATE_RMW2_RD) || (state ==  STATE_RMW2_WR))  
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON16; // pdb & isel
                                    else if ((state == STATE_RMW_RD) || (state == STATE_RMW_WR))
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON17; // BER RST_N 
                                    else
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON16; // pdb & isel
                                  end else begin //perform the original sequence
                                     if ((state ==  STATE_RMW2_RD) || (state ==  STATE_RMW2_WR))  
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON0C; // reye_rcru
                                    else 
                                        ctrl_addr <= RECONFIG_PMA_CH0_EYMON16; // pdb & isel
                                  end

         XR_EYEMON_OFFSET_HPHASE:   ctrl_addr <= RECONFIG_PMA_CH0_EYMON16; // h phase 

         XR_EYEMON_OFFSET_VHEIGHT:  ctrl_addr <= RECONFIG_PMA_CH0_EYMON17; // v height

         XR_EYEMON_OFFSET_EYEMON16: ctrl_addr <= RECONFIG_PMA_CH0_EYMON16; // pass thru 16

         XR_EYEMON_OFFSET_EYEMON17: ctrl_addr <= RECONFIG_PMA_CH0_EYMON17; // pass thru 17

         default:                   ctrl_addr <= 'h0;
     endcase
end

// binary to grey conversion for reye_monitor register for horizontal phase
step_to_mon_sv inst_step_to_mon (
     .clk      (clk),
     .step     (uif_wdata[UIF_REYE_MONITOR_5 : UIF_REYE_MONITOR_0]),
     .monitor  (mon_data)
);

// basic write data
always @(posedge clk)
begin
    ctrl_wdata <= ctrl_rdata;
    if (reset_sync == 1'b1 ) begin
      if(ber_generate) begin
              ber_clk_en    <= 1'b0; 
              ber_soft_reset <= 1'b0; //BER soft_reset is reset high, to mask out a glitchy test_bus clock
              ber_snap_shot <= 1'b0; 
              ber_count_en  <= 1'b0; 
              ber_threshold <= 8'h0A;
      end
    end else begin
      if (ber_generate == 1'b1) begin
        ber_clk_en    <= ber_clk_en;
        ber_soft_reset <= ber_soft_reset;
        ber_snap_shot <= ber_snap_shot;
        ber_count_en  <= ber_count_en;
        ber_threshold <= ber_threshold;
      end
      case (uif_addr)
        XR_EYEMON_OFFSET_CTRL:
        begin
          //if the BER generate is enabled, then perform the full sequence, which involves configureing
          //th testbus, data path, eyemonitor powerdown, hard serial bit comparator and the BER control registers
          //if the BER is not enabled, run the original configuration sequence
          if (ber_generate == 1'b1) begin
            //Configure the testbus
            if (( state == STATE_RMW4_WR )) begin
              ber_soft_reset                      <= uif_wdata[UIF_RBER_SYNC_MODE]; //set the local reset for the BER
              ber_snap_shot                       <= uif_wdata[UIF_RBER_SNAP_SHOT]; //Takes a snapshot of the local counters.
              ctrl_wdata[3:0]                     <= CTRL_EYEMON_ODI_TBUS; 
            end else begin
              if (( state == STATE_RMW3_WR )) begin
                //Configure reye_rcru. If BER clk is disabled AND eye monitor is enabled, configure the data path
                //to be the EYEMON data path else, configure the data path to be the CDR.
                ctrl_wdata[CTRL_REYE_RCRU]        <= (uif_wdata[UIF_REYE_PDB] && ~uif_wdata[UIF_RBER_CLK_EN]); 
              end else begin
                if (( state == STATE_RMW2_WR )) begin
                  //Configure the Eye Powerdown
                  ctrl_wdata[CTRL_REYE_PDB]       <= uif_wdata[UIF_REYE_PDB]; 
                  if (uif_wdata[UIF_REYE_PDB])        // isel
                    ctrl_wdata[CTRL_REYE_ISEL_2 : CTRL_REYE_ISEL_0] <= REYE_ISEL_ON;
                  else
                    ctrl_wdata[CTRL_REYE_ISEL_2 : CTRL_REYE_ISEL_0] <= REYE_ISEL_OFF;
                end else begin
                  //Configure the RST for the hard Serial Bit comparator
                  ctrl_wdata[CTRL_REYE_BER_CHK_EN]  <= (uif_wdata[UIF_RBER_CLK_EN] && uif_wdata[UIF_REYE_PDB]); //Enable the Hard BER checker
                  if (ctrl_done == 1'b1 && state == STATE_RMW_WR)
                  begin
                    //Ber Clock can only be enabled if the EYE is powered on.  configure soft BER Control Signals.
                    ber_clk_en                   <= (uif_wdata[UIF_RBER_CLK_EN] && uif_wdata[UIF_REYE_PDB]); 
                    ber_soft_reset               <= 1'b0; //clear the local reset
                    ber_snap_shot                <= 1'b0; //clear the snap shot
                    ber_count_en                 <= uif_wdata[UIF_RBER_COUNT_EN];  //Set the Count Enable for the BER
                  end
                end
              end
            end
          end else begin
            if ((state == STATE_RMW2_WR))
              ctrl_wdata[CTRL_REYE_RCRU]          <= uif_wdata[UIF_REYE_PDB]; // reye_rcru
            else begin 
              ctrl_wdata[CTRL_REYE_PDB]           <= uif_wdata[UIF_REYE_PDB]; //pdb   
              if (uif_wdata[UIF_REYE_PDB])        // isel
                ctrl_wdata[CTRL_REYE_ISEL_2 : CTRL_REYE_ISEL_0] <= REYE_ISEL_ON;
              else
                ctrl_wdata[CTRL_REYE_ISEL_2 : CTRL_REYE_ISEL_0] <= REYE_ISEL_OFF;
            end
          end
        end

        XR_EYEMON_OFFSET_HPHASE:   ctrl_wdata[CTRL_REYE_MONITOR_5 : CTRL_REYE_MONITOR_0]   
                                              <= mon_data;
        XR_EYEMON_OFFSET_VHEIGHT:  ctrl_wdata[CTRL_REYE_VERTICAL_5 : CTRL_REYE_VERTICAL_0]   
                                              <= uif_wdata[UIF_REYE_VERTICAL_5 : UIF_REYE_VERTICAL_0];
        XR_EYEMON_OFFSET_EYEMON16: ctrl_wdata <= uif_wdata;
        XR_EYEMON_OFFSET_EYEMON17: ctrl_wdata <= uif_wdata;

        //Sets the threshold, allows debugging and refinment of the soft BER.
        XR_EYEMON_OFFSET_BERTHRESH: if (state == STATE_RMW_WR) ber_threshold <= uif_wdata[UIF_RBER_THRESHOLD_7:UIF_RBER_THRESHOLD_0]; 
      endcase
    end
end

// grey to binary conversion for reye_monitor to user step data for horizontal phase
mon_to_step_sv inst_mon_to_step (
     .clk      (clk),
     .monitor  (ctrl_rdata[CTRL_REYE_MONITOR_5 : CTRL_REYE_MONITOR_0]),
     .step     (step_data)
);

// user read data
always @(posedge clk)
begin
    if (ctrl_done && (uif_mode == UIF_MODE_RD) && (state == STATE_RD))
        begin
            uif_rdata <= 0;
            case (uif_addr) 
                XR_EYEMON_OFFSET_CTRL:      //if BER is generated, then assign the control registers as necessary
                                            //Read the status of the Eye Monitor Power down signal and the control
                                            //signals of the soft BER.
                                            if (ber_generate == 1'b1) begin 
                                              uif_rdata[UIF_REYE_PDB]       <= ctrl_rdata[CTRL_REYE_PDB];
                                              uif_rdata[UIF_RBER_SYNC_MODE] <= ber_soft_reset;
                                              uif_rdata[UIF_RBER_SNAP_SHOT] <= ber_snap_shot;
                                              uif_rdata[UIF_RBER_COUNT_EN]  <= ber_count_en;
                                              uif_rdata[UIF_RBER_CLK_EN]    <= ber_clk_en;
                                              uif_rdata[BER_STATUS]         <= 1'b1;
                                            end else begin
                                              uif_rdata[UIF_REYE_PDB]       <= ctrl_rdata[CTRL_REYE_PDB];
                                              uif_rdata[BER_STATUS]         <= 1'b0;
                                            end
                                           
                XR_EYEMON_OFFSET_HPHASE:    uif_rdata[UIF_REYE_MONITOR_5 : UIF_REYE_MONITOR_0]
                                                <= step_data;
                                             
                XR_EYEMON_OFFSET_VHEIGHT:   uif_rdata[UIF_REYE_VERTICAL_5 : UIF_REYE_VERTICAL_0]
                                                <= ctrl_rdata[CTRL_REYE_VERTICAL_5 : CTRL_REYE_VERTICAL_0];

                XR_EYEMON_OFFSET_BIT_LOW:   uif_rdata <= ber_bit_low_data;

                XR_EYEMON_OFFSET_BIT_HI:    uif_rdata <= ber_bit_hi_data;

                XR_EYEMON_OFFSET_ERR_LOW:   uif_rdata <= ber_err_low_data;

                XR_EYEMON_OFFSET_ERR_HI:    uif_rdata <= ber_err_hi_data;

                XR_EYEMON_OFFSET_EXCP_LOW:  uif_rdata <= ber_excp_low_data;

                XR_EYEMON_OFFSET_EYEMON16:  uif_rdata <= ctrl_rdata;
                                          
                XR_EYEMON_OFFSET_EYEMON17:  uif_rdata <= ctrl_rdata;

                XR_EYEMON_OFFSET_BERTHRESH: uif_rdata <= ber_threshold; 
            endcase
        end
end

// synchronize reset
always @(posedge clk or posedge reset)
begin   
    if (reset)
       reset_ff <= 4'h0;
    else
       reset_ff <= {reset_ff[2:0], 1'b1};    
end

assign reset_sync = ~reset_ff[3];


generate 
if (BER_COUNTER_EN == 1) begin: gen_ber_counters
  alt_xcvr_reconfig_eyemon_ber_sv alt_xcvr_reconfig_eyemon_ber_sv_inst(
    .clk                                   (clk),
    .reset                                 (reset_sync),
    .ber_threshold                         (ber_threshold),
    .testbus                               (eyemon_testbus),
    .ber_clk_en                            (ber_clk_en),
    .ber_count_rst                         (ber_soft_reset),
    .ber_snap_shot                         (ber_snap_shot), 
    .ber_count_en                          (ber_count_en),
    .ber_bit_high                          (ber_bit_hi_data),
    .ber_bit_low                           (ber_bit_low_data),
    .ber_err_high                          (ber_err_hi_data),
    .ber_err_low                           (ber_err_low_data),
    .ber_excp                              (ber_excp_low_data)
  );
end else begin
  assign ber_bit_hi_data = 32'b0;
  assign ber_bit_low_data = 32'b0;
  assign ber_err_hi_data = 32'b0;
  assign ber_err_low_data = 32'b0;
  assign ber_excp_low_data = 32'b0;
end
endgenerate

endmodule
