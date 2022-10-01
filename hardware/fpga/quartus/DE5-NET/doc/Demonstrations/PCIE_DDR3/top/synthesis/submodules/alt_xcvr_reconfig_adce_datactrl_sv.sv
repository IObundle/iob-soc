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


// ADCE Data/Control Block
// This Block talks with the alt_xreconf_uif and alt_xreconf_cif blocks.
//
// $Header: //acds/rel/16.1/ip/alt_xcvr_reconfig/alt_xcvr_reconfig_adce/alt_xcvr_reconfig_adce_datactrl_sv.sv#1 $

`timescale 1 ns / 1 ps
`ifdef ALTERA_RESERVED_QIS
`define ALTERA_RESERVED_XCVR_FULL_ADCE 
`endif
// Function to map a 6-bit unsigned index to the 6-bit offset value required for offset cancelation:
// index should be between 0 and 6'b111110 inclusive, 
// index == 6'b111111 is not a legal value, but if index == 6'b111111 the resulting offset will be 0mV.
function logic [5:0] comparator_offset
(
 input [5:0] index
 );
   begin
      if( index < 6'b011111 ) begin
         comparator_offset = 6'b011110 - index;    // -90mV to -2mV
      end else if ( index == 6'b011111 ) begin
         comparator_offset = 6'b111111;            //   0mV
      end else begin
         comparator_offset = { 1'b1, index[4:0] }; //   2mV to 90mV
      end
   end
endfunction : comparator_offset

module alt_xcvr_reconfig_adce_datactrl_sv
  #(
    parameter NUMBER_OF_CHANNELS                        = 1,
    parameter logic [NUMBER_OF_CHANNELS-1:0] AUTO_START = { NUMBER_OF_CHANNELS { 1'b0 } },
    parameter RECONFIG_USER_ADDR_WIDTH                  = 3,
    parameter RECONFIG_USER_DATA_WIDTH                  = 32,
    parameter RECONFIG_USER_OFFSET_WIDTH                = 6,
    parameter RECONFIG_BASIC_OFFSET_ADDR_WIDTH          = 12,
    parameter LOGICAL_CHANNEL_NUMBER_WIDTH              = 10,
    parameter PHYSICAL_CHANNEL_NUMBER_WIDTH             = 10
    ) 
   (
    input wire                                          clk,
    input wire                                          reset,
    input wire                                          hold,
    
    // from/to uif module
    input wire                                          uif_go,
    input wire [2:0]                                    uif_mode,
    input wire [9:0]                                    uif_logical_ch_addr, // Logical channel number
    input wire [RECONFIG_USER_OFFSET_WIDTH-1:0]         uif_addr_offset, // Register address
    input wire [RECONFIG_USER_DATA_WIDTH-1:0]           uif_writedata,
    output logic [RECONFIG_USER_DATA_WIDTH-1:0]         uif_readdata,
    output wire                                         uif_busy,
    output logic                                        uif_illegal_pch_error, // Invalid physical channel
    output logic                                        uif_illegal_offset_error, // Invalid register
    
    // from/to cif module
    output logic                                        ctrl_go,
    output logic [2:0]                                  ctrl_opcode,
    output logic                                        ctrl_lock,
    output logic [RECONFIG_BASIC_OFFSET_ADDR_WIDTH-1:0] ctrl_addr_offset,
    output logic [RECONFIG_USER_DATA_WIDTH-1:0]         ctrl_writedata,
    input wire                                          ctrl_illegal_phy_ch,
    input wire [RECONFIG_USER_DATA_WIDTH-1:0]           ctrl_readdata,
    input wire                                          ctrl_waitrequest,
    
    // Directly from basic block
    input wire                                          adce_b_waitrequest, // Not used.
    // Digital test bus
    input wire [7:0]                                    adce_testbus
    );

   import alt_xcvr_reconfig_h::*; // alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   import sv_xcvr_h::*;           // altera_xcvr_generic/sv/sv_xcvr_h.sv

   typedef logic [RECONFIG_BASIC_OFFSET_ADDR_WIDTH-1:0] t_reconfig_basic_offset_addr;

   // modes of operation from uif (uif_mode) and opcodes for cif
   localparam READ_CH_ADD             = 3'b000; // AKA UIF_MODE_RD
   localparam WRITE_CH_ADD            = 3'b001; // AKA UIF_MODE_WR
   localparam READ_PHY_CH             = 3'b010; // AKA UIF_MODE_PHYS
   localparam WRITE_INTERNAL_REGISTER = 3'b011;

   // Default data rate
   localparam DEFAULT_DATA_RATE = 8; // PCIe Gen 3 data rate
   
   // ADCE Soft IP Registers
   // Global registers
   logic [LOGICAL_CHANNEL_NUMBER_WIDTH-1:0]             channel;          // Logical channel number
   logic [LOGICAL_CHANNEL_NUMBER_WIDTH-1:0]             channel_d1;       // To detect logical channel number changes.

   localparam ADCE_MODE_POWER_DOWN = 2'b00; // Also used for manual equalization.
   localparam ADCE_MODE_ONE_TIME   = 2'b01;
   localparam ADCE_MODE_CONTINUOUS = 2'b10;
   localparam ADCE_MODE_ONETIME_PLUS = 2'b11; // ONE_TIME plus forced offset recalibration.

   // One per channel registers.
   // Control register.
   logic [NUMBER_OF_CHANNELS-1: 0] [1:0]                channels_mode; 
   // EQ_Results register
   logic [NUMBER_OF_CHANNELS-1: 0] [3:0]                channels_results;
   
   // For testbus selection
   logic [3:0]                                          testbussel;
   logic                                                bb_wr_start;

   // For Metastable hardening
   logic                                                up_dnn_lf_meta/* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   logic                                                up_dnn_lf_hard/* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   logic                                                up_dnn_hf_meta/* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   logic                                                up_dnn_hf_hard/* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   
   // For UIF processing
   logic                                                uif_done;
   logic                                                uif_wr_start;
   logic                                                starting_continuous;
   logic                                                starting_onetime;
   logic                                                going_inactive;
   logic                                                reading_results;
   logic                                                starting_update_dr;

   
   // Main state machine
   localparam ADCE_STATE_IDLE             = 11'b00000000001; // 1 << 0;
   localparam ADCE_STATE_START_ONE_TIME   = 11'b00000000010; // 1 << 1;
   localparam ADCE_STATE_ONE_TIME         = 11'b00000000100; // 1 << 2;
   localparam ADCE_STATE_START_CONTINUOUS = 11'b00000001000; // 1 << 3;
   localparam ADCE_STATE_CONTINUOUS       = 11'b00000010000; // 1 << 4;
   localparam ADCE_STATE_GO_POWER_DOWN    = 11'b00000100000; // 1 << 5;
   localparam ADCE_STATE_POWER_DOWN       = 11'b00001000000; // 1 << 6;
   localparam ADCE_STATE_PAUSE            = 11'b00010000000; // 1 << 7;
   localparam ADCE_STATE_READ_RESULTS     = 11'b00100000000; // 1 << 8;
   localparam ADCE_STATE_RESUME           = 11'b01000000000; // 1 << 9;
   localparam ADCE_STATE_MODIFY_DR        = 11'b10000000000; // 1 << 10;
   localparam ADCE_STATES                 = 11;
   
   logic [NUMBER_OF_CHANNELS-1:0] [ ADCE_STATES-1 : 0 ] channels_state;    // Main state machine state, one per channel.
   logic [ ADCE_STATES-1 : 0 ]                          adce_state;        // Adjusted whenever channel changes.
   
   wire [1:0]                                           adce_mode;
   logic                                                auto_start_done;  // The auto-start phase has been completed.
   logic [NUMBER_OF_CHANNELS-1:0]                       offset_cancelled; // Offset cancellation has been performed, one bit per logical channel.
   logic                                                adce_rstb;
   logic                                                adce_pdb;
   logic                                                adce_adapt;
// logic                                                adce_standby;
   logic                                                adce_capture;
   logic                                                adce_change_rstb;
   logic                                                adce_change_pdb;
   logic                                                adce_change_adapt;
// logic                                                adce_change_standby;
   logic                                                adce_change_capture;
   logic                                                adce_read_results;
   logic                                                adce_do_changes;
   logic                                                adce_changes_done;
   logic                                                adce_change_dr_par;
   logic                                                adce_change_reg_ATT2;
   logic                                                adce_change_reg_ATT4;
   logic                                                adce_change_reg_ATT5;
   logic                                                adce_change_reg_ATT6;
   logic                                                adce_wr_start;
   

   //Array of pre-defined ADCE parameters for each datarate
   logic [3:0]                          adce_hfbw  = {1'b0,1'b1,1'b1,1'b1};
   logic [3:0] [3:0]                adce_hf_locks  = {4'b0,4'b0010,4'b0110,4'b0110};
   logic [3:0] [3:0]                adce_hf_edges  = {4'b0,4'b0110,4'b0110,4'b0110};
   logic [3:0] [3:0]                  adce_hf_dur  = {4'b0,4'b1111,4'b1111,4'b1111};
   logic [3:0] [2:0]            adce_hf_clk_macro  = {3'b0,3'b101,3'b101,3'b110};

   logic [3:0] [3:0]                adce_lf_locks  = {4'b0,4'b0010,4'b0110,4'b0110};
   logic [3:0] [3:0]                adce_lf_edges  = {4'b0,4'b0110,4'b0110,4'b0110};
   logic [3:0] [3:0]                 adce_lf_dur   = {4'b0,4'b1000,4'b1111,4'b1111};
   logic [3:0] [2:0]            adce_lf_clk_macro  = {3'b0,3'b100,3'b100,3'b110};

   logic [3:0] [1:0]               adce_rgen_mode  = {2'b0,2'b01,2'b01,2'b11};
   logic [3:0] [1:0]                 adce_rgen_bw  = {2'b0,2'b10,2'b10,2'b00};
	
   logic                                               timeout_count_active;
   logic                                               timeout_reached;
   logic [15:0]                                        timeout_counter;
   logic [15:0]                                        timeout_max;


   // For state machine for executing changes requested by the main state machine
   localparam CHANGES_IDLE      =  6'd1;
   localparam CHANGES_SELECTION =  6'd2;
   localparam CHANGES_READ      =  6'd4;
   localparam CHANGES_MODIFY    =  6'd8;
   localparam CHANGES_WRITE     =  6'd16;
   localparam CHANGES_DONE      =  6'd32;
   logic [5:0]                                          changes_state;
   logic                                                wr_start; // Straight write to hard ADCE registers.
   
   // For state machine for reading equalization results and converting to 4-bit value
   localparam RR_IDLE                     =  5'd1;
   localparam RR_GET_ACTIVE_STAGE         =  5'd2;
   localparam RR_GET_ACTIVE_STAGE_SETTING =  5'd4;
   localparam RR_CONVERT                  =  5'd8;
   localparam RR_DONE                     =  5'd16;
   logic [4:0]                                          rr_state;
   logic [4:0]                                          rr_stage;
   logic [5:0]                                          rr_setting;
   logic                                                rr_start;
   logic                                                rr_done;
   
   // For register writing state machine
   localparam WR_IDLE                 = 7'b0000001; // 1 << 0;
   localparam WR_WRITE                = 7'b0000010; // 1 << 1;
   localparam WR_ADCE_WRITE           = 7'b0000100; // 1 << 2;
   localparam WR_BB_WRITE             = 7'b0001000; // 1 << 3;
   localparam WR_OC_WRITE             = 7'b0010000; // 1 << 4;
   localparam WR_WAIT_FOR_WAITREQUEST = 7'b0100000; // 1 << 5;
   localparam WR_WRITING              = 7'b1000000; // 1 << 6;
   logic [6:0]                                          wr_state;
   logic                                                wr_done;

   // For register reading state machine
   localparam RD_IDLE                 = 6'b000001; // 1 << 0;
   localparam RD_ADCE_READ            = 6'b000010; // 1 << 1;
   localparam RD_REQUEST_READ         = 6'b000100; // 1 << 2;
   localparam RD_READ                 = 6'b001000; // 1 << 3;
   localparam RD_WAIT_FOR_WAITREQUEST = 6'b010000; // 1 << 4;
   localparam RD_READING              = 6'b100000; // 1 << 5;
   logic [5:0]                                          rd_state;
   logic                                                rd_start;         // To read the Hard ADCE's registers ( RECONF_READ )
   logic                                                adce_rd_start;    // To read the ADCE "local" channel register ( LOCAL_READ )
   logic                                                request_rd_start; // To read the REQUEST "local" channel register ( LOCAL_READ )
   logic                                                rd_done;
   
   // For offset cancelation state machine
   localparam OC_DELAY         =  32; // How long to wait for toggling. AA Need to change to real value.

   localparam OC_IDLE                  = 20'b0000_0000_0000_0000_0001; // ( 1 <<  0 );
   localparam OC_TURN_RX_BUFFER_OFF    = 20'b0000_0000_0000_0000_0010; // ( 1 <<  1 );
   localparam OC_SETUP_PCIE_EQZ_MUX    = 20'b0000_0000_0000_0000_0100; // ( 1 <<  2 );
   localparam OC_SETUP_PCIE_ADCE_MUX   = 20'b0000_0000_0000_0000_1000; // ( 1 <<  3 );
   localparam OC_SETUP_TESTBUS         = 20'b0000_0000_0000_0001_0000; // ( 1 <<  4 );
   localparam OC_SETUP_LOCALS          = 20'b0000_0000_0000_0010_0000; // ( 1 <<  5 );
   localparam OC_WR_ALL_REGS           = 20'b0000_0000_0000_0100_0000; // ( 1 <<  6 );
   localparam OC_SWEEP                 = 20'b0000_0000_0000_1000_0000; // ( 1 <<  7 );
   localparam OC_WR_LF_REG             = 20'b0000_0000_0001_0000_0000; // ( 1 <<  8 );
   localparam OC_WR_HF_REG             = 20'b0000_0000_0010_0000_0000; // ( 1 <<  9 );
   localparam OC_WAIT                  = 20'b0000_0000_0100_0000_0000; // ( 1 << 10 );
   localparam OC_PROCESS_LF            = 20'b0000_0000_1000_0000_0000; // ( 1 << 11 );
   localparam OC_PROCESS_HF            = 20'b0000_0001_0000_0000_0000; // ( 1 << 12 );
   localparam OC_RESTORE_PCIE_ADCE_MUX = 20'b0000_0010_0000_0000_0000; // ( 1 << 13 );
   localparam OC_RESTORE_PCIE_EQZ_MUX  = 20'b0000_0100_0000_0000_0000; // ( 1 << 14 );
   localparam OC_TURN_RX_BUFFER_ON     = 20'b0000_1000_0000_0000_0000; // ( 1 << 15 );
   localparam OC_READ                  = 20'b0001_0000_0000_0000_0000; // ( 1 << 16 );
   localparam OC_MODIFY                = 20'b0010_0000_0000_0000_0000; // ( 1 << 17 );
   localparam OC_WRITE                 = 20'b0100_0000_0000_0000_0000; // ( 1 << 18 );
   localparam OC_DONE                  = 20'b1000_0000_0000_0000_0000; // ( 1 << 19 );

   logic [19:0]                                         oc_state;
   logic [19:0]                                         oc_return_state;
   logic                                                oc_start;    // Assert to start offset cancellation process for current logical channel, self clears once process has started.
   logic                                                oc_wr_start;
   logic                                                oc_rpcie_eqz; 
   logic                                                oc_radce_reserved_0; 
   logic                                                oc_tmp_rpcie_eqz;
   logic                                                oc_tmp_radce_reserved_0; 
   logic                                                oc_rrx_pdb;
   logic                                                radce_sf_hfbw_tmp; //Readback sf_hfbw defined by Quartus 
   logic                                                rmw_done;
   logic [1:0]                                          adce_udr;       //User-specified data_rate
   logic                                                en_adjust_dr;  //
   logic						oc_forced;
	
   
   localparam OC_DEFAULT_OFFSET = 6'b111111; // 0mV
   logic [5:0]                                          radce_lf_os; // Automatically inserted when writing to appropriate hard ADCE register.
   logic [5:0]                                          radce_hf_os; // Automatically inserted when writing to appropriate hard ADCE register.
   logic [5:0]                                          oc_index;
   logic [$clog2(OC_DELAY+1)-1:0]                       oc_delay;
   
   logic                                                oc_up_dnn_lf_original;
   logic                                                oc_up_dnn_lf_transitioned;
   logic [5:0]                                          oc_min_toggle_lf;
   logic [5:0]                                          oc_max_toggle_lf;
   logic                                                oc_lf_toggled;
   logic [5:0]                                          oc_up_dnn_lf_transition;
    
   logic                                                oc_up_dnn_hf_original;
   logic                                                oc_up_dnn_hf_transitioned;
   logic [5:0]                                          oc_min_toggle_hf;
   logic [5:0]                                          oc_max_toggle_hf;
   logic                                                oc_hf_toggled;
   logic [5:0]                                          oc_up_dnn_hf_transition;
   logic [RECONFIG_BASIC_OFFSET_ADDR_WIDTH-1 : 0]       register_ptr;
   
   // Two circuits to capture toggling of each of the up_dnn signals.
   // Need to see at least two rising edges on the up_dnn signals to declare toggling.
   
   wire  up_dnn_lf; // Clock signal
   // In up_dnn_lf clock domain
   logic up_dnn_lf_rose;    // First rising edge detected.
   logic up_dnn_lf_toggled; // Second rising edge detected.
   // In clk clock domain
   logic clear_up_dnn_lf_toggled; // Reset signal for toggle detect flip-flop.
   logic up_dnn_lf_toggled_meta /* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   logic up_dnn_lf_toggled_hard /* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;

   assign up_dnn_lf = adce_testbus[0];
   always_ff @( posedge up_dnn_lf, posedge clear_up_dnn_lf_toggled ) begin
      if ( clear_up_dnn_lf_toggled ) begin
         up_dnn_lf_rose    <= 1'b0;
         up_dnn_lf_toggled <= 1'b0;
      end else begin
         // Posedge of up_dnn_lf
         up_dnn_lf_rose    <= 1'b1;   
         up_dnn_lf_toggled <= up_dnn_lf_rose;
      end
   end
   
   wire  up_dnn_hf; // Clock signal
   // In up_dnn_hf clock domain
   logic up_dnn_hf_rose;          // First rising edge detected.
   logic up_dnn_hf_toggled;       // Second rising edge detected.
   // In clk clock domain
   logic clear_up_dnn_hf_toggled; // Reset signal for toggle detect flip-flop.
   logic up_dnn_hf_toggled_meta /* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   logic up_dnn_hf_toggled_hard /* synthesis altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" */;
   
   assign up_dnn_hf = adce_testbus[1];
   always_ff @( posedge up_dnn_hf, posedge clear_up_dnn_hf_toggled ) begin
      if ( clear_up_dnn_hf_toggled ) begin
         up_dnn_hf_rose    <= 1'b0;
         up_dnn_hf_toggled <= 1'b0;
      end else begin
         // Posedge of up_dnn_hf
         up_dnn_hf_rose    <= 1'b1;   
         up_dnn_hf_toggled <= up_dnn_hf_rose;
      end
   end

   assign uif_illegal_pch_error = ctrl_illegal_phy_ch;
   assign uif_busy   = uif_go           || // To get busy asserted one cycle earlier.
                       ~auto_start_done || // To prevent getting user commands while performing auto-starts.
//                     adce_do_changes  || // Changing states in the main state machine. Might be redundant with the next line.
                       ~uif_done           // Processing commands from the alt_xreconf_uif module
                       ;

   // Select the relevant signals for the active logical channel.
   assign adce_mode       = channels_mode[channel];
   
   always_ff @( posedge clk, posedge reset ) begin
      if( reset ) begin
         // Output ports
         uif_readdata             <=   '0;
         uif_illegal_offset_error <= 1'b0;
         ctrl_go                  <= 1'b0;
         ctrl_opcode              <=   '0;
         ctrl_lock                <= 1'b0;
         ctrl_addr_offset         <=   '0;
         ctrl_writedata           <=   '0;


         // Reset signals for toggle detect circuits
         clear_up_dnn_lf_toggled <= 1'b1;
         clear_up_dnn_hf_toggled <= 1'b1;
           
         // Metastable hardening signals for toggle detect circuits.
         up_dnn_lf_meta <= 1'b0;
         up_dnn_lf_hard <= 1'b0;
         up_dnn_lf_toggled_meta <= 1'b0;
         up_dnn_lf_toggled_hard <= 1'b0;
         up_dnn_hf_meta <= 1'b0;
         up_dnn_hf_hard <= 1'b0;
         up_dnn_hf_toggled_meta <= 1'b0;
         up_dnn_hf_toggled_hard <= 1'b0;

         // For testbus selection
         testbussel <= 4'b0000;
         bb_wr_start <= 1'b0;
         
         // For UIF processing
         uif_done            <= 1'b1; // No unfinished commands yet.
         uif_wr_start        <= 1'b0;
         starting_continuous <= 1'b0;
         starting_onetime    <= 1'b0;
         going_inactive      <= 1'b0;
         reading_results     <= 1'b0;
         starting_update_dr  <= 1'b0;


         // For Offset cancellation state machine
         oc_state                  <= OC_IDLE;
         oc_return_state           <= OC_IDLE;
         oc_start                  <= 1'b0;
	 oc_forced                 <= 1'b0;
         oc_index                  <= 6'b000000;
         oc_wr_start               <= 1'b0;
         oc_rrx_pdb                <= 1'b0;
         oc_rpcie_eqz              <= 1'b0; 
         oc_radce_reserved_0       <= 1'b0; 
         radce_lf_os               <= comparator_offset(6'b000000);
         radce_hf_os               <= comparator_offset(6'b000000);

         oc_delay                  <=   '0;
         oc_up_dnn_lf_original     <= 1'b0;
         oc_up_dnn_lf_transitioned <= 1'b0;
         oc_min_toggle_lf          <= 1'b0;
         oc_max_toggle_lf          <= 6'b000000;
         oc_lf_toggled             <= 1'b0;
         oc_up_dnn_lf_transition   <= 6'b000000;

         oc_up_dnn_hf_original     <= 1'b0;
         oc_up_dnn_hf_transitioned <= 1'b0;
         oc_min_toggle_hf          <= 1'b0;
         oc_max_toggle_hf          <= 6'b000000;
         oc_hf_toggled             <= 1'b0;
         oc_up_dnn_hf_transition   <= 6'b000000;
         radce_sf_hfbw_tmp         <= 1'b0;     // 1 for 3 to 7 Gbps, 0 for 8 to 12 Gbps
         rmw_done                  <= 1'b0;
         adce_udr                  <= 2'b00;   // 2'b00 = Default settings
         en_adjust_dr              <= 1'b0;     // Enable adjust Data_rate
         
         // For register writing state machine
         wr_state      <= WR_IDLE;
         wr_done       <= 1'b0;
         wr_start      <= 1'b0;
         adce_wr_start <= 1'b0;
         register_ptr  <=   '0;

         // For register reading state machine
         rd_state    <= RD_IDLE;
         rd_start    <= 1'b0;
         rd_done     <= 1'b0;

         // For results reading state machine
         rr_state            <= RR_IDLE;
         rr_start            <= 1'b0;
         rr_done             <= 1'b0;
         rr_stage            <= 5'b00000;
         rr_setting          <= 6'b000000;
         
         channel             <=   '0;
         channel_d1          <=   '0;
         auto_start_done     <= 1'b0;
         offset_cancelled    <=   '0;       

         // For main state machine
         channels_mode          <=   '0;
         channels_results       <=   '0;
         channels_state         <=   {NUMBER_OF_CHANNELS {ADCE_STATE_IDLE} };
         changes_state          <= CHANGES_IDLE;
         adce_state             <=                        ADCE_STATE_IDLE;
         adce_rd_start          <= 1'b0;
         request_rd_start       <= 1'b0;
         adce_rstb              <= 1'b0;
         adce_pdb               <= 1'b0;
         adce_adapt             <= 1'b0;
//       adce_standby           <= 1'b0;
         adce_capture           <= 1'b0;
         adce_change_rstb       <= 1'b0;
         adce_change_pdb        <= 1'b0;
         adce_change_adapt      <= 1'b0;
//       adce_change_standby    <= 1'b0;
         adce_change_capture    <= 1'b0;
         adce_read_results      <= 1'b0;
         adce_do_changes        <= 1'b0;
         adce_changes_done      <= 1'b0;
         adce_change_dr_par     <= 1'b0;
         adce_change_reg_ATT2   <= 1'b0;
         adce_change_reg_ATT4   <= 1'b0;
         adce_change_reg_ATT5   <= 1'b0;
         adce_change_reg_ATT6   <= 1'b0;

         timeout_count_active   <= 1'b0;
         timeout_reached        <= 1'b0;
         timeout_counter        <= 16'b0000_0000_0000_0000;
         timeout_max            <= 16'b1001_1100_0100_0000; //0x9C40 = 40000 x 10ns = 0.4ms

      end else begin

         // Metastable harden signals from other clock domains
         up_dnn_lf_meta         <= up_dnn_lf;
         up_dnn_lf_hard         <= up_dnn_lf_meta;
         up_dnn_lf_toggled_meta <= up_dnn_lf_toggled;
         up_dnn_lf_toggled_hard <= up_dnn_lf_toggled_meta;
         up_dnn_hf_meta         <= up_dnn_hf;
         up_dnn_hf_hard         <= up_dnn_hf_meta;
         up_dnn_hf_toggled_meta <= up_dnn_hf_toggled;
         up_dnn_hf_toggled_hard <= up_dnn_hf_toggled_meta;
         
         // Delayed copies
         channel_d1 <= channel;
         
         // Clear signals that are only pulsed high for one cycle
         adce_changes_done   <= 1'b0;
         rr_done             <= 1'b0;
         ctrl_go             <= 1'b0;
         
         if ((timeout_count_active) && !timeout_reached) begin
             if (timeout_counter < timeout_max) begin
                timeout_counter <= timeout_counter + 1;
             end else begin
               timeout_reached <= 1'b1;
               timeout_counter <= 16'b0000_0000_0000_0000;
             end
         end

         // Launch ADCE on logical channels for which AUTO_START[channel] bit is set or for which one of the auto-start REQUEST bits is set.
         if( !hold && !auto_start_done ) begin // Do this only once after reset after higher priority reconfig modules have finished.
            if ( channel == channel_d1 ) begin
               if( going_inactive || starting_continuous || starting_onetime ) begin 
                  // Wait for ADCE to get into the desired adaptation mode.
                  if( ( going_inactive      && ( adce_state == ADCE_STATE_POWER_DOWN ) ) ||
                      ( starting_continuous && ( adce_state == ADCE_STATE_CONTINUOUS ) ) ||
                      ( starting_onetime    && ( adce_state == ADCE_STATE_ONE_TIME   ) ) ) begin
                     going_inactive      <= 1'b0;
                     starting_continuous <= 1'b0;
                     starting_onetime    <= 1'b0;
                     channel <= channel + 1'b1;
                     if( channel == (NUMBER_OF_CHANNELS-1) ) begin
                        auto_start_done <= 1'b1;
                        channel         <=   '0;
                     end
                  end
               end else begin
                  // Read REQUEST register
                  if( !request_rd_start ) begin
                     request_rd_start <= 1'b1;
                  end else begin
                     if( rd_done ) begin
                        request_rd_start <= 1'b0;
                        // Check status of SV_XR_REQUEST_ADCE_CONT_OFST, SV_XR_REQUEST_ADCE_SINGLE_OFST or SV_XR_REQUEST_ADCE_CANCEL_OFST bits to see if we need to auto start this channel.
                        // All channels are assumed to be in the POWER_DOWN mode when coming out of reset.
                        // So it safe to just activate them.
                        if( ctrl_readdata[SV_XR_REQUEST_ADCE_CANCEL_OFST] || ctrl_readdata[SV_XR_REQUEST_ADCE_SINGLE_OFST] || ctrl_readdata[SV_XR_REQUEST_ADCE_CONT_OFST] || AUTO_START[ channel ] ) begin
                           if( ctrl_readdata[SV_XR_REQUEST_ADCE_CANCEL_OFST] ) begin // Start offset cancellation only
                              going_inactive         <= 1'b1;
                              channels_mode[channel] <= ADCE_MODE_POWER_DOWN;
                           end else if( ( ctrl_readdata[SV_XR_REQUEST_ADCE_CONT_OFST] || AUTO_START[ channel ] ) ) begin
                              starting_continuous    <= 1'b1;
                              channels_mode[channel] <= ADCE_MODE_CONTINUOUS;
                           end else begin // ctrl_readdata[SV_XR_REQUEST_ADCE_SINGLE_OFST]
                              starting_onetime       <= 1'b1;
                              channels_mode[channel] <= ADCE_MODE_ONE_TIME;
                           end
                        end else begin
                           channel <= channel + 1'b1;
                           if( channel == (NUMBER_OF_CHANNELS-1) ) begin
                              auto_start_done <= 1'b1;
                              channel         <=   '0;
                           end
                        end
                     end
                  end
               end
            end
         end // if ( !hold && !auto_start_done )

         // Interface to UIF module
         if( uif_go || !uif_done ) begin
            uif_done <= 1'b0;
            // Set potentially new channel number
            channel <= uif_logical_ch_addr[LOGICAL_CHANNEL_NUMBER_WIDTH-1:0];
            // Wait for channel number to propagate
            if( channel == uif_logical_ch_addr[LOGICAL_CHANNEL_NUMBER_WIDTH-1:0] ) begin
               
               // Writes
               if( uif_mode == WRITE_CH_ADD )begin
                  uif_illegal_offset_error <= 1'b0;
                  case( uif_addr_offset )
                     XR_ADCE_OFFSET_CTRL: begin
                        case ( uif_writedata[1:0] )
                           ADCE_MODE_POWER_DOWN: begin
                              // De-activate ADCE
                              if( ! going_inactive ) begin
                                 // Power down ADCE
                                 going_inactive <= 1'b1;
                                 channels_mode[channel] <= ADCE_MODE_POWER_DOWN;
                              end else begin
                                 if( adce_state == ADCE_STATE_POWER_DOWN ) begin
                                    // Now inactive.
                                    going_inactive <= 1'b0;
                                    uif_done       <= 1'b1;
                                 end
                              end
                           end
                           ADCE_MODE_ONE_TIME: begin
                              // Start one-time adaptation
                              if( ! starting_onetime ) begin
                                 // Start one-time adaptation
                                 starting_onetime       <= 1'b1;
                                 channels_mode[channel] <= ADCE_MODE_ONE_TIME;
                              end else begin
                                 if ( adce_state == ADCE_STATE_ONE_TIME ) begin
                                    // Now running one time adaptation.
                                    starting_onetime <= 1'b0;
				    oc_forced        <= 1'b0;
                                    uif_done         <= 1'b1;
                                 end
                              end
                           end
                           ADCE_MODE_CONTINUOUS: begin
                              // Start continuous adaptation
                              if( ! starting_continuous ) begin
                                 // Start continuous adaptation
                                 starting_continuous    <= 1'b1;
                                 channels_mode[channel] <= ADCE_MODE_CONTINUOUS;
                              end else begin
                                 if( adce_state == ADCE_STATE_CONTINUOUS ) begin
                                    // Now running in continuous mode.
                                    starting_continuous <= 1'b0;
                                    uif_done            <= 1'b1;
                                 end
                              end
                           end
                           ADCE_MODE_ONETIME_PLUS: begin
                              // Start one-time adaptation with forced offset calibration
                              if( ! starting_onetime ) begin
                                 // Start one-time adaptation
                                 starting_onetime       <= 1'b1;
				 oc_forced		<= 1'b1;
                                 channels_mode[channel] <= ADCE_MODE_ONE_TIME;
                              end else begin
                                 if( adce_state == ADCE_STATE_ONE_TIME ) begin
                                    // Now running one time adaptation.
                                    starting_onetime <= 1'b0;
				    oc_forced        <= 1'b0;
                                    uif_done         <= 1'b1;
                                 end
                              end
                           end
                           default: begin
                              uif_done <= 1'b1;
                           end
                        endcase // case ( adce_mode )
                     end // case: XR_ADCE_OFFSET_CTRL

                     XR_ADCE_OFFSET_BW: begin // Write into newly specified User-Register = 0x02
                         adce_udr      <= uif_writedata[1:0]; //save user-defined bandwidth
                         en_adjust_dr  <= uif_writedata[3];   //save enable adjust bandwidth bit
                         if (uif_writedata[3]) begin //Do not execute update of parameters if bit3 <>1
                           if( ! starting_update_dr) begin
                            // Here starts bandwidth update
                              starting_update_dr    <= 1'b1;
                           end else begin
                              if( adce_state == ADCE_STATE_MODIFY_DR ) begin
                               // Wait until updates are done
                                 starting_update_dr <= 1'b0;
                                 uif_done            <= 1'b1;
                              end
                           end
                         end // End for bit3 <>1
                     end // case: XR_ADCE_OFFSET_BW

                     XR_ADCE_OFFSET_TIMEOUT: begin // Write into newly specified Timeout Register = 0x03
                        timeout_max <= uif_writedata[15:0];
                     end

                     // Write the hard ADCE's registers
                     XR_ADCE_OFFSET_RADCE_ATT_0,
                     XR_ADCE_OFFSET_RADCE_ATT_1,
                     XR_ADCE_OFFSET_RADCE_ATT_2,
                     XR_ADCE_OFFSET_RADCE_ATT_3,
                     XR_ADCE_OFFSET_RADCE_ATT_4,
                     XR_ADCE_OFFSET_RADCE_ATT_5,
                     XR_ADCE_OFFSET_RADCE_ATT_6: begin
//                      register_ptr     <= uif_addr_offset;
                        ctrl_addr_offset <= 8'h2A + uif_addr_offset;
                        ctrl_writedata   <= uif_writedata;
                        if( !uif_wr_start ) begin
                           uif_wr_start  <= 1'b1;
                        end else begin
                           if( wr_done ) begin
                              uif_wr_start <= 1'b0;
                              uif_done     <= 1'b1;
                           end
                        end
                     end // case: XR_ADCE_OFFSET_RADCE_ATT_0 ...

                     default: begin
                        uif_illegal_offset_error <= 1'b1;
                        uif_done <= 1'b1;
                     end
                  endcase // case ( uif_addr_offset )
               end // if ( uif_mode == WRITE_CH_ADD )
                  
               // Reads
               if( uif_mode == READ_CH_ADD )begin
                  uif_illegal_offset_error <= 1'b0;
                  case( uif_addr_offset )
                
                     XR_ADCE_OFFSET_CTRL: begin
                        if( !adce_rd_start ) begin
                           // Check status of ADCE_DONE bit to see if the adapt_done bit needs to be updated.
                           adce_rd_start <= 1'b1;
                        end else begin
                           if( rd_done ) begin
                              adce_rd_start <= 1'b0;
                              uif_readdata  <= {6'd0, ( timeout_reached & !ctrl_readdata[SV_XR_ADCE_DONE_OFST] ),
                                                ( (adce_mode ==  ADCE_MODE_ONE_TIME) || (adce_mode == ADCE_MODE_CONTINUOUS) ) ? ( ctrl_readdata[SV_XR_ADCE_DONE_OFST] | timeout_reached ) : 1'b0 , 
                                                6'd0, adce_mode };
                              if ( ctrl_readdata[SV_XR_ADCE_DONE_OFST]  && timeout_reached ) begin //ADCE macro generated a valid adapt_done signal, discard timeout.
                                  timeout_reached <= 1'b0;
                              end
                              uif_done      <= 1'b1;
                           end
                        end
                     end // case: XR_ADCE_OFFSET_CTRL
                     
                     XR_ADCE_OFFSET_RESULTS: begin
                        if( !adce_read_results ) begin
                           if( adce_mode == ADCE_MODE_CONTINUOUS || adce_mode == ADCE_MODE_ONE_TIME ) begin
                              adce_read_results <= 1'b1;
                           end else begin
                              // It is an error to try to read the results when not in one of those two states.
                              uif_illegal_offset_error <= 1'b1;
                              uif_readdata             <= '1; // Impossible value;
                              uif_done                 <= 1'b1;
                           end
                        end else begin
                           if( reading_results && ( adce_state == ADCE_STATE_IDLE ) ) begin
                              adce_read_results <= 1'b0;
                              reading_results   <= 1'b0;
                              uif_readdata <= { {(RECONFIG_USER_DATA_WIDTH-4) {1'b0} }, channels_results[channel] };
                              uif_done     <= 1'b1;
                           end
                        end
                     end // case: ADDR_XR_ADCE_RESULTS
                     XR_ADCE_OFFSET_BW: begin // Write into newly specified User-Register = 0x02
                         uif_readdata <= { 14'b0,adce_udr };
                         uif_done     <= 1'b1;                    
                     end // case: XR_ADCE_OFFSET_BW

                     XR_ADCE_OFFSET_TIMEOUT: begin // Write into newly specified Timeout Register = 0x03
                        uif_readdata <=  timeout_max [15:0];
                         uif_done     <= 1'b1;                    
                     end // case: XR_ADCE_OFFSET_TIMEOUT

                     // Read the hard ADCE's registers.
                     XR_ADCE_OFFSET_RADCE_ATT_0,
                     XR_ADCE_OFFSET_RADCE_ATT_1,
                     XR_ADCE_OFFSET_RADCE_ATT_2,
                     XR_ADCE_OFFSET_RADCE_ATT_3,
                     XR_ADCE_OFFSET_RADCE_ATT_4,
                     XR_ADCE_OFFSET_RADCE_ATT_5,
                     XR_ADCE_OFFSET_RADCE_ATT_6: begin
//                      register_ptr <= uif_addr_offset;
                        ctrl_addr_offset <= 8'h2A + uif_addr_offset;
                        if( !rd_start ) begin
                           rd_start <= 1'b1;
                        end else begin
                           if( rd_done ) begin
                              rd_start     <= 1'b0;
                              uif_readdata <= ctrl_readdata;
                              uif_done     <= 1'b1;
                           end
                        end
                     end
                     
                     default: begin
                        uif_illegal_offset_error <= 1'b1;
                        uif_readdata             <= '0;
                        uif_done                 <= 1'b1;
                     end
                  endcase // case ( uif_addr_offset )
               end // if ( uif_mode == READ_CH_ADD )
               
            end // if ( channel == uif_logical_ch_addr[LOGICAL_CHANNEL_NUMBER_WIDTH-1:0] )
         end // if ( uif_go || !uif_done )


         // Main ADCE state machine
         // One copy is shared between all the channels 
         // so only one channel's state machine is active at any time 
         // The mode bus causes transitions between states and so does the read signal.
         if( adce_changes_done ) begin
            adce_change_rstb    <= 1'b0;
            adce_change_pdb     <= 1'b0;
            adce_change_adapt   <= 1'b0;
//          adce_change_standby <= 1'b0;
            adce_change_capture <= 1'b0;
         end
         if ( channel != channel_d1 ) begin
            // Channel has been changed. 
            // Stall the state machine for one cycle 
            // while the state of the previous channel is saved and the state of the new channel is fetched.
            // It is assumed that channel changes will only be allowed when everyting is stable.
            // That should be garanteed by the uif busy/done signals.
            channels_state[channel_d1] <= adce_state;
            adce_state                 <= channels_state[channel];
         end else begin
            case( adce_state )
               ADCE_STATE_IDLE: begin
                  // Wait here for commands from user.
                  if (starting_update_dr) begin
                      adce_state          <= ADCE_STATE_MODIFY_DR;
                  end else if (timeout_count_active && timeout_reached) begin
                              timeout_count_active <= 1'b0;
                  end else if( going_inactive || starting_onetime || starting_continuous ) begin
                     if ((offset_cancelled[channel]) && (!oc_forced)) begin   // will execute as soon as calibration step is finished
                        // Assert adce_rstb before changing states.
                        if ( !adce_do_changes ) begin
                           adce_rstb           <= 1'b0;

                           adce_change_rstb    <= 1'b1;

                           adce_do_changes     <= 1'b1;
                        end else begin
                           if( adce_changes_done ) begin
                              adce_do_changes <= 1'b0;
                              if( going_inactive ) begin
                                 adce_state <= ADCE_STATE_GO_POWER_DOWN;
                              end else if( starting_continuous ) begin
                                 adce_state <= ADCE_STATE_START_CONTINUOUS;
                              end else begin // starting_onetime
                                 adce_state <= ADCE_STATE_START_ONE_TIME;
                              end
                           end
                        end
                     end else begin
                        oc_start <= 1'b1; // Will self clear when offset cancelation has completed. Calibration will activate for initial command or if forced
                     end
                  end
                  if( adce_read_results && !reading_results )begin
                     adce_state        <= ADCE_STATE_PAUSE;
                  end
               end
               ADCE_STATE_START_ONE_TIME: begin
                  if ( !adce_do_changes ) begin
                     adce_adapt          <= 1'b1;                    
                     adce_pdb            <= 1'b0;
                     adce_capture        <= 1'b0;
//                   adce_standby        <= 1'b0;
                     adce_rstb           <= 1'b1;	
                     timeout_count_active <= 1'b1;
                     timeout_reached     <= 1'b0;
                    
                     adce_change_adapt   <= 1'b1;
                     adce_change_pdb     <= 1'b1;
                     adce_change_capture <= 1'b1;
//                   adce_change_standby <= 1'b1;
                     adce_change_rstb    <= 1'b1;
                     
                     adce_do_changes     <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_ONE_TIME;
                     end
                  end
               end
               ADCE_STATE_ONE_TIME: begin
                 adce_state <= ADCE_STATE_IDLE;
               end
               ADCE_STATE_START_CONTINUOUS: begin
                  if ( !adce_do_changes ) begin
                     adce_adapt          <= 1'b1;                    
                     adce_pdb            <= 1'b1;
                     adce_capture        <= 1'b0;
//                   adce_standby        <= 1'b0;
                     adce_rstb           <= 1'b1;
                     timeout_count_active <= 1'b1;
                     timeout_reached     <= 1'b0;
                    
                     adce_change_adapt   <= 1'b1;                    
                     adce_change_pdb     <= 1'b1;
                     adce_change_capture <= 1'b1;
//                   adce_change_standby <= 1'b1;
                     adce_change_rstb    <= 1'b1;

                     adce_do_changes     <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_CONTINUOUS;
                     end
                  end
               end
               ADCE_STATE_CONTINUOUS: begin
                  adce_state <= ADCE_STATE_IDLE;
               end
               ADCE_STATE_GO_POWER_DOWN: begin
                  if ( !adce_do_changes ) begin
                     adce_adapt          <= 1'b0;                    
                     adce_pdb            <= 1'b0;
                     adce_capture        <= 1'b0;
//                   adce_standby        <= 1'b0;
                     adce_rstb           <= 1'b1;
                    
                     adce_change_adapt   <= 1'b1;                    
                     adce_change_pdb     <= 1'b1;
                     adce_change_capture <= 1'b1;
//                   adce_change_standby <= 1'b1;
                     adce_change_rstb    <= 1'b1;
                     
                     adce_do_changes     <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_POWER_DOWN;                 
                     end
                  end
               end
               ADCE_STATE_POWER_DOWN: begin
                  adce_state <= ADCE_STATE_IDLE;
               end
               ADCE_STATE_MODIFY_DR: begin
                  if ( !adce_do_changes ) begin
                     adce_do_changes       <= 1'b1;
                     adce_change_dr_par    <= 1'b1;
                     adce_change_reg_ATT2  <= 1'b1;
                     adce_change_reg_ATT4  <= 1'b1;
                     adce_change_reg_ATT5  <= 1'b1;
                     adce_change_reg_ATT6  <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_IDLE;//
                     end
                  end
               end
					
               ADCE_STATE_PAUSE: begin
                  if ( !adce_do_changes ) begin
                     adce_capture        <= 1'b1;
                     
                     adce_change_capture <= 1'b1;
                     
                     adce_do_changes     <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_READ_RESULTS;
                     end
                  end
               end
               ADCE_STATE_READ_RESULTS: begin
                  reading_results     <= 1'b1;
                  if ( !rr_start ) begin
                     rr_start        <= 1'b1;
                  end else begin
                     if( rr_done ) begin
                        rr_start        <= 1'b0;
                        adce_state      <= ADCE_STATE_RESUME;
                     end
                  end
               end
               ADCE_STATE_RESUME: begin
                  if ( !adce_do_changes ) begin
                     adce_capture        <= 1'b0;
                     
                     adce_change_capture <= 1'b1;
                     
                     adce_do_changes     <= 1'b1;
                  end else begin
                     if( adce_changes_done ) begin
                        adce_do_changes <= 1'b0;
                        adce_state      <= ADCE_STATE_IDLE  ;
                     end
                  end
               end
            endcase // case ( adce_state )
         end

         // State machine for executing changes requested by the main state machine
         // Requires doing read-modify-write cycles for radce_pbd radce_rstb and radce_adapt.
         case ( changes_state )
            CHANGES_IDLE: begin
               if( adce_changes_done ) begin
                  adce_changes_done <= 1'b0;
               end else begin
                  if( adce_do_changes )begin
                     changes_state <= CHANGES_SELECTION;
                  end
               end
            end
            CHANGES_SELECTION: begin
               if( adce_change_capture /*|| adce_change_standby */) begin
                  if( !adce_wr_start ) begin
                     adce_wr_start <= 1'b1;
                  end else begin
                     if( wr_done )begin
                        adce_wr_start       <= 1'b0;
//                      adce_change_standby <= 1'b0;
                        adce_change_capture <= 1'b0;
                        if( adce_change_rstb || adce_change_pdb || adce_change_adapt ) begin
                           changes_state <= CHANGES_READ;
                        end else begin
                           changes_state <= CHANGES_DONE;
                        end
                     end
                  end
               end else if( adce_change_rstb || adce_change_pdb || adce_change_adapt || adce_change_dr_par ) begin
                  changes_state <= CHANGES_READ;
               end else begin
                  changes_state <= CHANGES_IDLE;
               end
            end
            CHANGES_READ: begin
               // Grab mutex
               if( ctrl_lock || !ctrl_waitrequest )begin
               ctrl_lock <= 1'b1;
               if( !rd_start ) begin
                  if( adce_change_pdb ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_4);
                  end else if( adce_change_adapt ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_0);
                  end else if( adce_change_reg_ATT2 ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_2);
                  end else if( adce_change_reg_ATT4 ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_4);
                  end else if( adce_change_rstb || adce_change_reg_ATT5 ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_5);
                  end else if( adce_change_reg_ATT6 ) begin
                     ctrl_addr_offset <= 8'h2A + t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_6);
                  end
                  rd_start <= 1'b1;
               end else begin
                  if( rd_done )begin
                     rd_start <= 1'b0;
                     changes_state <= CHANGES_MODIFY;
                  end
               end
               end // if ( ctrl_lock || !ctrl_waitrequest )            
            end
            CHANGES_MODIFY: begin
               if( adce_change_pdb ) begin
                  ctrl_writedata <= { ctrl_readdata[15:1], adce_pdb };
                  adce_change_pdb <= 1'b0;
                  if( !adce_change_adapt && !adce_change_rstb ) begin
                     // This is the last write, release mutex
                     ctrl_lock <= 1'b0;
                  end
               end else if( adce_change_adapt ) begin
                  ctrl_writedata <= { ctrl_readdata[15:1], adce_adapt };
                  adce_change_adapt <= 1'b0;
                  if( !adce_change_rstb ) begin
                     // This is the last write, release mutex
                     ctrl_lock <= 1'b0;
                  end
               end else if( adce_change_rstb ) begin
                  ctrl_writedata <= { adce_rstb, ctrl_readdata[14:0] };
                  adce_change_rstb <= 1'b0;
                  // This is the last write, release mutex
                  ctrl_lock <= 1'b0;
               end else if( adce_change_reg_ATT2 ) begin
                  ctrl_writedata <= { ctrl_readdata[15],adce_hf_locks[adce_udr],adce_hf_edges[adce_udr],adce_hf_dur[adce_udr], adce_hf_clk_macro[adce_udr] };
                  adce_change_reg_ATT2 <= 1'b0;
               end else if( adce_change_reg_ATT4 ) begin
                  ctrl_writedata <= { adce_lf_locks[adce_udr],adce_lf_edges[adce_udr],adce_lf_dur[adce_udr], adce_lf_clk_macro[adce_udr],ctrl_readdata[0] };
                  adce_change_reg_ATT4 <= 1'b0;
               end else if( adce_change_reg_ATT5 ) begin
                  ctrl_writedata <= { ctrl_readdata[15:6],adce_rgen_mode[adce_udr],adce_rgen_bw[adce_udr],ctrl_readdata[1:0] };
                  adce_change_reg_ATT5 <= 1'b0;
               end else if( adce_change_reg_ATT6 ) begin
                  ctrl_writedata <= { ctrl_readdata[15:4], adce_hfbw[adce_udr],ctrl_readdata[2:0] };
                  adce_change_reg_ATT6 <= 1'b0;
						adce_change_dr_par <= 1'b0;
                  // This is the last write, release mutex
                  ctrl_lock <= 1'b0;
               end
               changes_state <= CHANGES_WRITE;
            end
            CHANGES_WRITE: begin
               if( ! wr_start )begin
                  wr_start <= 1'b1;
               end else begin
                  if( wr_done )begin
                     wr_start <= 1'b0;
                     if(  adce_change_adapt || adce_change_rstb || adce_change_reg_ATT4 || adce_change_reg_ATT5 || adce_change_reg_ATT6 ) begin
                        // Still more to do.
                        changes_state <= CHANGES_READ;
                     end else begin
                        changes_state <= CHANGES_DONE;
                     end
                  end
               end
            end
            CHANGES_DONE: begin
               adce_changes_done <= 1'b1;
               changes_state     <= CHANGES_IDLE;
            end
         endcase // case ( changes_state )
         // State machine for reading equalization results and converting to 4-bit value
         case( rr_state )
           RR_IDLE: begin
              rr_done <= 1'b0;
              if( ! rr_done ) begin
                 if( rr_start ) begin
                    rr_state <= RR_GET_ACTIVE_STAGE;
                 end
              end
           end
           RR_GET_ACTIVE_STAGE: begin
              if( ! bb_wr_start ) begin
                 // Set testbus to show tmxsel
                 testbussel  <= 4'b0010;
                 bb_wr_start <= 1'b1;
              end else begin
                 if( wr_done ) begin
                    rr_stage    <= adce_testbus[7:3];
                    bb_wr_start <= 1'b0;
                    rr_state    <= RR_GET_ACTIVE_STAGE_SETTING;
                 end
              end
           end
           RR_GET_ACTIVE_STAGE_SETTING: begin
              if( ! bb_wr_start ) begin
                 // Set testbus to show eqctrlout
                 testbussel <= 4'b0000;
                 bb_wr_start <= 1'b1;
              end else begin
                 if( wr_done ) begin
                    rr_setting  <= adce_testbus[7:2];
                    bb_wr_start <= 1'b0;
                    rr_state    <= RR_CONVERT;
                 end
              end
           end
           RR_CONVERT: begin
              if( rr_stage[0] ) begin
                 case( rr_setting[5:3] )
                    3'b000: channels_results[channel] <= 4'd15; // Fogbugz case 32763 - note that 'V' tap is inverted, so "111" is really the smallest value
                    3'b001: channels_results[channel] <= 4'd14;   
                    3'b010: channels_results[channel] <= 4'd14;   
                    3'b011: channels_results[channel] <= 4'd13;   
                    3'b100: channels_results[channel] <= 4'd13;   
                    3'b101: channels_results[channel] <= 4'd12;   
                    3'b110: channels_results[channel] <= 4'd12;   
                    3'b111: channels_results[channel] <= 4'd11;   
                 endcase
              end else if( rr_stage[1] ) begin
                 case( rr_setting[5:3] )
                    3'b111: channels_results[channel] <= 4'd11;   
                    3'b110: channels_results[channel] <= 4'd10;   
                    3'b101: channels_results[channel] <= 4'd10;   
                    3'b100: channels_results[channel] <= 4'd10;   
                    3'b011: channels_results[channel] <= 4'd09;   
                    3'b010: channels_results[channel] <= 4'd09;   
                    3'b001: channels_results[channel] <= 4'd08;   
                    3'b000: channels_results[channel] <= 4'd08;   
                 endcase
              end else if( rr_stage[2] ) begin
                 case( rr_setting[5:3] )
                    3'b111: channels_results[channel] <= 4'd08;   
                    3'b110: channels_results[channel] <= 4'd08;   
                    3'b101: channels_results[channel] <= 4'd07;   
                    3'b100: channels_results[channel] <= 4'd07;   
                    3'b011: channels_results[channel] <= 4'd07;   
                    3'b010: channels_results[channel] <= 4'd07;   
                    3'b001: channels_results[channel] <= 4'd06;   
                    3'b000: channels_results[channel] <= 4'd05;   
                 endcase
              end else if( rr_stage[3] ) begin
                 case( rr_setting[5:3] )
                    3'b111: channels_results[channel] <= 4'd05;   
                    3'b110: channels_results[channel] <= 4'd05;   
                    3'b101: channels_results[channel] <= 4'd05;   
                    3'b100: channels_results[channel] <= 4'd04;   
                    3'b011: channels_results[channel] <= 4'd04;   
                    3'b010: channels_results[channel] <= 4'd04;   
                    3'b001: channels_results[channel] <= 4'd03;   
                    3'b000: channels_results[channel] <= 4'd03;   
                 endcase
              end else if( rr_stage[4] ) begin
                 case( rr_setting[5:3] )
                    3'b111: channels_results[channel] <= 4'd03;   
                    3'b110: channels_results[channel] <= 4'd03;   
                    3'b101: channels_results[channel] <= 4'd02;   
                    3'b100: channels_results[channel] <= 4'd02;   
                    3'b011: channels_results[channel] <= 4'd01;   
                    3'b010: channels_results[channel] <= 4'd01;   
                    3'b001: channels_results[channel] <= 4'd01;   
                    3'b000: channels_results[channel] <= 4'd00;   
                 endcase
              end // if ( rr_stage[4] )
              rr_state <= RR_DONE;
           end
           RR_DONE: begin
              rr_done  <= 1'b1; // Only pulsed high for one cycle.
              rr_state <= RR_IDLE;
           end
         endcase
                   
         // Offset cancellation state machine
         // Offset cancellation is performed for both comparators in parallel.
         // - Turn off rx buffer - (Update: This is done by powering-down the Rx Buffer via oc_rrx_pdb=1'b0)
         // - Remember the EQ mux setting and put it in non-PCIe mode (Offset=0x01B, bit 9)  
         // - Remember the ADCE mux setting anf put it in non-PCIe mode (Offset=0x039, bit30)st
         // - Write default values to registers including setting offset to minimum.
         // - Capture up_dnn value for later comparison
         // - Enable toggle detection
         // - Wait for a while
         // - Check if toggling happened, or if static value changed. 
         // - Increase offset and repeat
         // - Capture minimum and maximum offsets at which toggling occurs.
         // - If toggling occured set offset to average of min and max values at which toggling occured.
         // - If toggling did not occur
         // -    If static value changed set offset to value at which static value changed
         // -    If static value did not change, set offset to fixed value.
         // - Put the ADCE mux back to the configured setting (Offset=0x039, bit30) 
         // - Put the EQ mux back to the configured setting (Offset=0x01B, bit 9) 
         // - Turn rx buffer back on - (Update: Restore oc_rrx_pdb=1'b1)
         
         case( oc_state )
            OC_IDLE: begin
               // Wait here until asked to start.
               if( oc_start ) begin
                  // Initialise various registers for the offset cancellation process.
                  oc_index                  <= 6'b000000; // comparator_offset(oc_index) is writen to radce_lf_os and radce_hf_os
                  radce_lf_os               <= comparator_offset(6'b000000);
                  radce_hf_os               <= comparator_offset(6'b000000);
                  // Prepare register values to be set when we write all registers.
                  adce_adapt   <= 1'b1;
                  adce_pdb     <= 1'b1;
                  adce_rstb    <= 1'b1;
                  adce_capture <= 1'b0;
//                adce_standby <= 1'b0;
                    
                  oc_state     <= OC_TURN_RX_BUFFER_OFF;
               end
            end // case: OC_IDLE
            
            // Turn-off Rx buffer 
            // Updated 12_06_29: This is done by setting the power-down signal  oc_rrx_pdb = 1'b0
            OC_TURN_RX_BUFFER_OFF: begin
               // Grab mutex access for the duration of offset cancellation.
               if( ctrl_lock || !ctrl_waitrequest )begin
                 ctrl_lock       <= 1'b1;
                 rd_start         <= 1'b0;
                 
                 // Preferred method of deactivating RX channel is setting power_down signal oc_rrx_pdb=1'b0   (as on 12_06_29)  
                 // Need to do a Read-Modify-Write
                 oc_return_state <= OC_SETUP_PCIE_EQZ_MUX;
                 oc_rrx_pdb      <= 1'b0;
                 oc_state        <= OC_READ;
               end
            end
            
            // Store the rpcie_eqz value and write 1'b0 to this bit to disable PCIe path for OC.
            OC_SETUP_PCIE_EQZ_MUX: begin
               // Need to do a Read-Modify-Write 
               oc_return_state     <= OC_SETUP_PCIE_ADCE_MUX;
               oc_rpcie_eqz        <= 1'b0;
               oc_state            <= OC_READ;
            end
           
            OC_SETUP_PCIE_ADCE_MUX: begin
               // Need to do a Read-Modify-Write 
               oc_return_state     <= OC_SETUP_TESTBUS;
               oc_radce_reserved_0 <= 1'b0;
               oc_state            <= OC_READ;
            end
            OC_SETUP_TESTBUS : begin
               if( ! bb_wr_start ) begin
                  // testbussel is in the Basic block
                  testbussel <= 4'b0000;
                  bb_wr_start  <= 1'b1;
               end else begin
                  if( wr_done )begin
                     bb_wr_start  <= 1'b0;
//                   register_ptr <= XR_ADCE_OFFSET_RADCE_ATT_0;
                     oc_state     <= OC_SETUP_LOCALS;
                  end
               end
            end 
            OC_SETUP_LOCALS : begin
               // Write to the registers that control ADCE_CAPTURE and ADCE_STANDBY.
               if( ! adce_wr_start ) begin
                  adce_wr_start <= 1'b1;
               end else begin
                  if( wr_done )begin
                     adce_wr_start  <= 1'b0;
                     // Prepare for next state.
                     register_ptr   <= t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_0);
                     oc_state       <= OC_WR_ALL_REGS;
                  end 
               end
            end
            OC_WR_ALL_REGS: begin
               // Write default value to XR_ADCE_OFFSET_RADCE_ATT_0 - XR_ADCE_OFFSET_RADCE_ATT_6 registers
               if( (!oc_wr_start ) && (!rd_start ) && (!rmw_done)) begin
                   if ( register_ptr == XR_ADCE_OFFSET_RADCE_ATT_6) begin //Read-Modified-Write required only for  ATT6 ATT5 (rgen_mode and rgen_bw) are initialized by IP-core 
                       oc_return_state <= OC_WR_ALL_REGS;
                       oc_state        <= OC_READ;
                   end else begin
                       oc_wr_start <= 1'b1;
                   end
               end else begin
                  if( wr_done || rmw_done) begin
                     if (rmw_done) begin 
                        rmw_done <= 1'b0;  // rmw_done only 1 cycle active
                     end
                     register_ptr <= register_ptr + 1'd1;
                     oc_wr_start     <= 1'b0;
                     if( register_ptr == XR_ADCE_OFFSET_RADCE_ATT_6 ) begin
                        oc_min_toggle_lf          <= 6'b111111; // Has not toggled
                        oc_max_toggle_lf          <= 6'b000000; // Has not toggled
                        oc_lf_toggled             <= 1'b0;      // Has not toggled
                        oc_min_toggle_hf          <= 6'b111111; // Has not toggled
                        oc_max_toggle_hf          <= 6'b000000; // Has not toggled
                        oc_hf_toggled             <= 1'b0;      // Has not toggled
                        oc_up_dnn_lf_original     <= up_dnn_lf_hard;
                        oc_up_dnn_hf_original     <= up_dnn_hf_hard;
`ifdef ALTERA_RESERVED_XCVR_FULL_ADCE
                        oc_up_dnn_lf_transitioned <= 1'b0;      // Has not transitioned
                        oc_up_dnn_lf_transition   <= 6'b111111; // Has not transitioned
                        oc_up_dnn_hf_transitioned <= 1'b0;      // Has not transitioned
                        oc_up_dnn_hf_transition   <= 6'b111111; // Has not transitioned
                        oc_state <= OC_SWEEP;
`else                   
                        // Bypass offset cancellation in simulation.
                        oc_up_dnn_lf_transitioned <= 1'b1;      // Pretend it has transitioned
                        oc_up_dnn_lf_transition   <= 6'b100000; // About halfway through
                        oc_up_dnn_hf_transitioned <= 1'b1;      // Pretend it has transitioned
                        oc_up_dnn_hf_transition   <= 6'b100000; // About halfway through
                        oc_state <= OC_PROCESS_LF;
`endif
                     end
                  end
               end
            end
            OC_SWEEP: begin
               // Start writing to register containing radce_lf_os
               register_ptr <= t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_3); 
               oc_wr_start  <= 1'b1;
               oc_state     <= OC_WR_LF_REG;
            end
            OC_WR_LF_REG: begin
               if( wr_done )begin
                  // Finished writing to register containing radce_lf_os
                  oc_wr_start <= 1'b0;       
               end else begin
                  if( !oc_wr_start ) begin
                     // Start writing to register containing radce_hf_os
                     register_ptr <= t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_1);
                     oc_wr_start     <= 1'b1;
                     oc_state     <= OC_WR_HF_REG;
                  end
               end
            end
            OC_WR_HF_REG: begin
               if( wr_done )begin
                  // Finished writing to register containing radce_hf_os
                  oc_wr_start <= 1'b0;
                  oc_delay <=   '0;
                  // Release toggle detect circuit.
                  clear_up_dnn_lf_toggled <= 1'b0;
                  clear_up_dnn_hf_toggled <= 1'b0;
                  oc_state <= OC_WAIT;
               end
            end
            OC_WAIT: begin
               // Wait here for a while or until toggling is detected on both comparators
               oc_delay <= oc_delay + 1'd1;
               if( ( oc_delay == OC_DELAY ) || ( up_dnn_lf_toggled_hard && up_dnn_hf_toggled_hard ) )begin
                  // Capture any relevant indices.
                  if ( up_dnn_lf_toggled_hard ) begin
                     // Signal toggled with this offset.
                     oc_lf_toggled <= 1'b1;
                     oc_max_toggle_lf <= oc_index;
                     if( !oc_lf_toggled ) begin
                        oc_min_toggle_lf <= oc_index;
                     end
                  end else begin
                     if( !oc_lf_toggled && !oc_up_dnn_lf_transitioned ) begin
                        if( up_dnn_lf_hard != oc_up_dnn_lf_original )begin
                           oc_up_dnn_lf_transition   <= oc_index;
                           oc_up_dnn_lf_transitioned <= 1'b1;
                        end 
                     end
                  end
                  if ( up_dnn_hf_toggled_hard ) begin
                     // Signal toggled with this offset.
                     oc_hf_toggled <= 1'b1;
                     oc_max_toggle_hf <= oc_index;
                     if( !oc_hf_toggled ) begin
                        oc_min_toggle_hf <= oc_index;
                     end
                  end else begin
                     if( !oc_hf_toggled && !oc_up_dnn_hf_transitioned ) begin
                        if( up_dnn_hf_hard != oc_up_dnn_hf_original )begin
                           oc_up_dnn_hf_transition   <= oc_index;
                           oc_up_dnn_hf_transitioned <= 1'b1;
                        end 
                     end
                  end
                  // Reset toggling detection circuit and increment offset.
                  clear_up_dnn_lf_toggled <= 1'b1;
                  clear_up_dnn_hf_toggled <= 1'b1;
                  radce_lf_os <= comparator_offset(oc_index + 1'd1);
                  radce_hf_os <= comparator_offset(oc_index + 1'd1);
                  oc_index    <= oc_index + 1'd1;
                  if( oc_index == 6'b111110 )begin
                     oc_state <= OC_PROCESS_LF;
                  end else begin
                     oc_state <= OC_SWEEP;
                  end
               end
            end
            OC_PROCESS_LF: begin
              if( !oc_wr_start ) begin
                 if( oc_lf_toggled ) begin
                    // Set offset to middle of toggling zone.
                    radce_lf_os <= comparator_offset( ( {1'b0, oc_min_toggle_lf} + {1'b0, oc_max_toggle_lf} ) >> 1'd1 );
                 end else if( oc_up_dnn_lf_transitioned ) begin
                    // Set offset to point of transition.
                    radce_lf_os <= comparator_offset( oc_up_dnn_lf_transition - 1'd1 );
                 end else begin
                    // Set offset to default value.
                    radce_lf_os <= comparator_offset(OC_DEFAULT_OFFSET);
                 end
                 register_ptr <= t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_3);
                 oc_wr_start  <= 1'b1;
              end else begin // if ( !oc_wr_start )
                 if( wr_done )begin
                    oc_wr_start <= 1'b0;
                    oc_state <= OC_PROCESS_HF;
                 end
              end
           end
          
           OC_PROCESS_HF: begin
              if( !oc_wr_start ) begin
                 if( oc_hf_toggled ) begin
                    // Set offset to middle of toggling zone.
                    radce_hf_os <= comparator_offset( ({1'b0, oc_min_toggle_hf} + {1'b0, oc_max_toggle_hf}) >> 1'd1 );
                 end else if( oc_up_dnn_hf_transitioned ) begin
                    // Set offset to point of transition.
                    radce_hf_os <= comparator_offset( oc_up_dnn_hf_transition - 1'd1 );
                 end else begin
                    // Set offset to default value.
                    radce_hf_os <= comparator_offset(OC_DEFAULT_OFFSET);
                 end
                 register_ptr <= t_reconfig_basic_offset_addr'(XR_ADCE_OFFSET_RADCE_ATT_1);
                 oc_wr_start <= 1'b1;
              end else begin // if ( !oc_wr_start )
                 if( wr_done )begin
                    oc_wr_start <= 1'b0;
                    oc_state <= OC_RESTORE_PCIE_ADCE_MUX;
                 end
              end
           end 
          
           OC_RESTORE_PCIE_ADCE_MUX: begin
               // Need to do a Read-Modify-Write
               oc_return_state <= OC_RESTORE_PCIE_EQZ_MUX;
               oc_state        <= OC_READ;
           end

          OC_RESTORE_PCIE_EQZ_MUX: begin
               // Need to do a Read-Modify-Write
               oc_return_state <= OC_TURN_RX_BUFFER_ON;
               oc_state        <= OC_READ;
            end

           OC_TURN_RX_BUFFER_ON: begin
              // Need to do a Write (not R-M-W)
              rd_start         <= 1'b0;
              // Returning Rx to normal state (not power-down) via restoring oc_rrx_pdb=1'b11;
              oc_rrx_pdb      <= 1'b1;
              oc_return_state  <= OC_DONE;
              oc_state         <= OC_READ;
            end

            
            
            // Three states for read-modify-write.
            OC_READ: begin
               if( !rd_start ) begin
                  rd_start         <= 1'b1;      // Normal read, not "oc_rd_start".
                  rmw_done         <= 1'b0;      // Reset Read_Modify_Write_done bit
                  if( oc_return_state == OC_SETUP_PCIE_ADCE_MUX ||  oc_return_state == OC_TURN_RX_BUFFER_ON) begin
                    // Need to do R-M-W of rpcie_eqz bit
                    ctrl_addr_offset <= RECONFIG_PMA_CH0_RPCIE_EQZ;  
                    oc_state         <= OC_MODIFY;
                  end
                  if( oc_return_state == OC_SETUP_TESTBUS || oc_return_state == OC_RESTORE_PCIE_EQZ_MUX) begin
                    // Need to do R-M-W of radce_reserved[0] bit 
                    ctrl_addr_offset <= RECONFIG_PMA_CH0_ADCE_RADCE_ATT_111_96;     
                    oc_state         <= OC_MODIFY;
                  end
                  if( oc_return_state == OC_SETUP_PCIE_EQZ_MUX ||  oc_return_state == OC_DONE) begin
                    // Need to do R-M-W of of the rrx_pdb bit. 
                    ctrl_addr_offset <= t_reconfig_basic_offset_addr'(8'h1B);  // Should find a symbolic name for this register.
                    oc_state         <= OC_MODIFY;
                  end 
                  if( oc_return_state == OC_WR_ALL_REGS ) begin
                    // Need to do R-M-W of on XR_ADCE_OFFSET_RADCE_ATT_6 register. 
                    ctrl_addr_offset <= 8'h2A + register_ptr; // 0x33 to 0x39
                    oc_state         <= OC_MODIFY;
                  end 
              end
            end
            OC_MODIFY: begin
               if( rd_done )begin
                 rd_start         <= 1'b0;
                 oc_state         <= OC_WRITE;
                 if( oc_return_state == OC_WR_ALL_REGS ) begin
                    oc_wr_start   <= 1'b1;
                    if( register_ptr == XR_ADCE_OFFSET_RADCE_ATT_6 ) begin
                      // Save radce_sf_hfbw
                      radce_sf_hfbw_tmp <= ctrl_readdata[3];
                      // ctrl_writedata will be constructed within the write state machine
                    end
                 end else begin
                    wr_start         <= 1'b1; // Normal write, not "oc_wr_start".
                    if( oc_return_state == OC_SETUP_PCIE_ADCE_MUX) begin
                      // Store the current rpcie_eqz setting
                      // Write rpcie_eqz = 1'b0 (non-PCIe mode)
                      oc_tmp_rpcie_eqz <= ctrl_readdata[9]; 
                      ctrl_writedata   <= { ctrl_readdata[15:10], oc_rpcie_eqz, ctrl_readdata[8:0] };
                    end
                    if( oc_return_state == OC_SETUP_TESTBUS ) begin
                      // Store the current radce_reserved[0] setting
                      // Write radce_reserved[0] = 1'b0 (non-PCIe mode)
                      oc_tmp_radce_reserved_0 <= ctrl_readdata[14];
                      ctrl_writedata          <= { ctrl_readdata[15], oc_radce_reserved_0, ctrl_readdata[13:0] };
                    end
                    if( oc_return_state == OC_RESTORE_PCIE_EQZ_MUX ) begin
                      // Restore the radce_reserved[0] bit to its original value
                      ctrl_writedata   <= { ctrl_readdata[15], oc_tmp_radce_reserved_0, ctrl_readdata[13:0] };
                    end
                    if( oc_return_state == OC_TURN_RX_BUFFER_ON) begin
                      // Restore the rpcie_eqz bit to its original value
                      ctrl_writedata   <= { ctrl_readdata[15:10], oc_tmp_rpcie_eqz, ctrl_readdata[8:0] };
                    end
                    if( oc_return_state == OC_SETUP_PCIE_EQZ_MUX || oc_return_state == OC_DONE  ) begin
                      // Restore the rrx_pdb bit to its original value
                      ctrl_writedata <= { ctrl_readdata[15:1], oc_rrx_pdb };
                      if( oc_return_state == OC_DONE ) begin
                          // This will be the last write for offset cancellation, release mutex access
                          ctrl_lock <= 1'b0;
                      end
                    end
                 end
               end
             end
            OC_WRITE: begin
               if( wr_done )begin
                 wr_start  <= 1'b0;
                 if (oc_return_state == OC_WR_ALL_REGS) begin 
                    rmw_done	 <= 1'b1;   // Set Read_Modify_Write_done bit for read-modify-write registers
                    oc_wr_start <= 1'b0;
                 end
                 oc_state <= oc_return_state;
               end
            end

            OC_DONE: begin
               offset_cancelled[channel] <= 1'b1; // Offset cancellation has been performed for this channel.
               oc_start <= 1'b0; // Self clear oc_start.
               oc_forced <= 1'b0; // clear of oc_forced, if we arrived to this state via ONE_TIME_PLUS command.
               oc_state <= OC_IDLE;
            end
            
            default: begin
               oc_state <= OC_IDLE;
            end
         endcase // case ( oc_state )

         // Linear state machine for writing to one register
         case( wr_state )
            WR_IDLE: begin
               wr_done <= 1'b0;
               if( ! wr_done ) begin
                  if( oc_wr_start ) begin
                     wr_state <= WR_OC_WRITE;     // write to hard ADCE registers for offset cancellation state machine
                  end
                  if( bb_wr_start ) begin
                     wr_state <= WR_BB_WRITE;     // write to Basic block for offset cancellation state machine
                  end
                  if( adce_wr_start ) begin
                     wr_state <= WR_ADCE_WRITE;   // write to ADCE_CAPTURE and ADCE_STANDBY control register for OC and main state machine
                  end
                  if( uif_wr_start | wr_start ) begin
                     wr_state <= WR_WRITE;     // Straight write, write ctrl_write data to ctrl_addr_offset
                  end
               end
            end
            WR_WRITE: begin
               // Write to hard DPRIO registers 
               ctrl_go          <= 1'b1;
               ctrl_opcode      <= WRITE_CH_ADD; // XR_DIRECT_CONTROL_RECONF_WRITE;
//             ctrl_addr_offset <= Provided by caller
//             ctrl_writedata   <= Provided by caller
               wr_state         <= WR_WAIT_FOR_WAITREQUEST;
            end
            WR_ADCE_WRITE: begin
               // Write to ADCE_CAPTURE and ADCE_STANDBY control register 
               ctrl_go          <= 1'b1;
               ctrl_opcode      <= WRITE_CH_ADD; // XR_DIRECT_CONTROL_LOCAL_WRITE;
               ctrl_addr_offset <= SV_XR_ABS_ADDR_ADCE;
               ctrl_writedata   <= ( (~adce_capture) ? SV_XR_ADCE_CAPTURE_MASK : {RECONFIG_USER_DATA_WIDTH {1'b0} } ) | 
                                   ( /*(~adce_standby) ? */SV_XR_ADCE_STANDBY_MASK /*: {RECONFIG_USER_DATA_WIDTH {1'b0} }*/ );
               wr_state         <= WR_WAIT_FOR_WAITREQUEST;
            end
            WR_BB_WRITE: begin
               // Only used for testbus selection.
               ctrl_go          <= 1'b1;
               ctrl_opcode      <= WRITE_INTERNAL_REGISTER; // XR_DIRECT_CONTROL_INTERNAL_WRITE;
               ctrl_addr_offset <= XR_DIRECT_OFFSET_TESTBUS_SEL;
               ctrl_writedata   <= 16'h0000 |  testbussel;
               wr_state         <= WR_WAIT_FOR_WAITREQUEST;
            end
            WR_OC_WRITE: begin
               ctrl_go          <= 1'b1;
               ctrl_opcode      <= WRITE_CH_ADD; // XR_DIRECT_CONTROL_RECONF_WRITE;
               ctrl_addr_offset <= 8'h2A + register_ptr; // 0x33 to 0x39
               wr_state         <= WR_WAIT_FOR_WAITREQUEST;
               // Straight write of default register values with offsets inserted in appropriate registers.
               case( register_ptr )
                  XR_ADCE_OFFSET_RADCE_ATT_0: begin
                     ctrl_writedata <= { 
                                         3'b111,      // radce_eqd_set[2:0]
                                         3'b111,      // radce_eqc_set[2:0]
                                         3'b111,      // radce_eqb_set[2:0]
                                         3'b111,      // radce_eqa_set[2:0]
                                         1'b0,        // radce_eq_min
                                         2'b00,       // radce_dc_freq[1:0]
                                         adce_adapt   // radce_adapt,
                                         };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_1: begin
                     ctrl_writedata <= {
                                        3'b101,      // radce_hfclk_div[2:0]
                                        radce_hf_os, // radce_hf_os[5:0] 
                                        2'b01,       // radce_f_lpf[1:0]
                                        2'b01,       // radce_f_hpf[1:0]
                                        3'b111       // radce_eqv_set[2:0]
                                        };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_2: begin
                     ctrl_writedata <= {
                                        1'b0,                   // radce_lflp_manovd
                                        15'b0110_0110_1111_110  // radce_hflck[14:0] {hfclk_lock_for_adapt_done[3:0],hfclk_edge_lock[3:0],hfclk_duration[3:0],macro_hfclk_divide[2:0]}
                                        };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_3: begin
                     ctrl_writedata <= {
                                        4'b0000,     // radce_lst[3:0]
                                        2'b00,       // radce_lpf_gain[1:0]
                                        1'b0,        // radce_lock_lf_ovd
                                        3'b100,      // radce_lfclk_div[2:0]
                                        radce_lf_os  // radce_lf_os[5:0]
                                        };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_4: begin
                     ctrl_writedata <= {
                                        15'b0110_0110_1111_110, // radce_lflck[14:0] {lfclk_lock_for_adapt_done[3:0],lfclk_edge_lock[3:0],lfclk_duration[3:0],macro_lfclk_divide[2:0]}
                                        adce_pdb                // radce_pdb
                                        };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_5: begin
                     ctrl_writedata <= {
                                        adce_rstb, // radce_rstb
                                        3'b000,    // radce_rgen_vod_min[2:0]
                                        3'b111,    // radce_rgen_vod_max[2:0]
                                        3'b000,    // radce_rgen_vod_int[2:0]
                                        2'b01,     // radce_rgen_mode[1:0] (8 and 10GHz)
                                        2'b10,     // radce_rgen_bw[1:0] (8 and 10GHz)
                                        2'b00      // radce_rect_adj[1:0]
                                        };
                  end
                  XR_ADCE_OFFSET_RADCE_ATT_6: begin
                     ctrl_writedata <= {
                                        1'b0,    // NOT DEFINED                                     
                                        1'b0,    // radce_reserved[0] // PCIe mode
                                        4'b0000, // radce_reserved[4:1]
                                        2'b11,   // radce_hfos_step[1:0]
                                        2'b11,   // radce_lfos_step[1:0]
                                        2'b00,   // radce_sf_hx[1:0]
                                        radce_sf_hfbw_tmp,  // radce_sf_hfbw[1:0] was saved from Quartus initialized values
//                                        (DEFAULT_DATA_RATE < 7) ? 1'b1: 1'b0,    // radce_sf_hfbw // 1 for 3 to 7 Gbps, 0 for 8 to 12 Gbps 
                                        1'b0,    // radce_dfeadapt
                                        2'b11    // radce_seq_sel[1:0]
                                        };
                  end
                  default : begin
                     // This cannot happen.
                     ctrl_go        <= 1'b0;
                     ctrl_writedata <=   '0;
                     wr_done        <= 1'b1;
                     wr_state       <= WR_IDLE;
                  end
               endcase // case ( register_ptr )
            end
            WR_WAIT_FOR_WAITREQUEST: begin 
               // Wait for waitrequest
               if( ctrl_waitrequest ) begin
                  wr_state <= WR_WRITING;
               end
            end
            WR_WRITING: begin
               if( !ctrl_waitrequest ) begin
                  ctrl_go  <= 1'b0;
                  wr_done <= 1'b1; // Only pulsed high for one cycle.
                  wr_state <= WR_IDLE;            
               end
            end
         endcase // case ( wr_state )
         
         // Linear state machine for reading one of the hard ADCE's register.
         // Reads the register pointed to by register_ptr
         // Returns the read value on ctrl_readdata
         case( rd_state )
           RD_IDLE: begin
              rd_done <= 1'b0;
              if( ! rd_done ) begin
                 if( adce_rd_start ) begin
                    rd_state <= RD_ADCE_READ;
                 end
                 if( request_rd_start ) begin
                    rd_state <= RD_REQUEST_READ;
                 end
                 if( rd_start ) begin
                    rd_state <= RD_READ;
                 end
              end
           end
           RD_ADCE_READ: begin
              // Read from "local" channel ADCE register 
              ctrl_go          <= 1'b1;
              ctrl_opcode      <= READ_CH_ADD; // XR_DIRECT_CONTROL_LOCAL_READ;
              ctrl_addr_offset <= SV_XR_ABS_ADDR_ADCE;
              rd_state         <= RD_WAIT_FOR_WAITREQUEST;
           end
           RD_REQUEST_READ: begin
              // Read from "local" channel REQUEST register 
              ctrl_go          <= 1'b1;
              ctrl_opcode      <= READ_CH_ADD; // XR_DIRECT_CONTROL_LOCAL_READ;
              ctrl_addr_offset <= SV_XR_ABS_ADDR_REQUEST;
              rd_state         <= RD_WAIT_FOR_WAITREQUEST;
           end
           RD_READ: begin // Read from any register
              ctrl_go          <= 1'b1;
              ctrl_opcode      <= READ_CH_ADD; // XR_DIRECT_CONTROL_RECONF_READ;
//            ctrl_addr_offset <= Provided by caller
              rd_state         <= RD_WAIT_FOR_WAITREQUEST;
           end // case: RD_READ
            RD_WAIT_FOR_WAITREQUEST: begin
              // Wait for waitrequest
              if( ctrl_waitrequest ) begin
                 rd_state <= RD_READING;
              end
            end
           RD_READING: begin
              if( !ctrl_waitrequest ) begin
                 ctrl_go  <= 1'b0;
                 rd_done  <= 1'b1; // Only pulsed high for one cycle.
                 rd_state <= RD_IDLE;
              end
           end
         endcase // case ( rd_state )

      end // else: !if( reset )
   end // always_ff @
   


// This module assumes that the logical channel number is between 0 and NUMBER_OF_CHANNELS-1 inclusive.

endmodule : alt_xcvr_reconfig_adce_datactrl_sv
