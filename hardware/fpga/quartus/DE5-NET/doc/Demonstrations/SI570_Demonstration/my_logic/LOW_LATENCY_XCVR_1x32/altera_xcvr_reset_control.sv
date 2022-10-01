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



// File Name: altera_xcvr_reset_control.sv
//
// Description:
//
//    A configurable reset controller intended to drive resets for HSSI transceiver PLLs and CHANNELS.
//  The reset controller makes use of individual reset counters to control reset timing for the various reset
//  outputs.
//
//    Features:
//      - Optional TX,RX,PLL reset control.
//      - Optional synchronization of the reset input
//      - Optional hysteresis for the pll_locked status inputs
//      - Reset control per channel or shared. (E.g. separate rx_digitalreset control for each channel
//        or one control for all channels)
//      - Configurable reset timings
//      - Optional automatic or manual reset control mode
//        (For TX, tx_digitalreset can automatically be restarted on loss of pll_locked)
//        (For RX, rx_digitalreset can automatically be restarted on loss of rx_is_lockedtodata)

`timescale 1ns / 1ns
`ifndef ALTERA_RESERVED_QIS_FAMILY_ARRIA10
(* altera_attribute = "-name MERGE_TX_PLL_DRIVEN_BY_REGISTERS_WITH_SAME_CLEAR ON -to \"alt_xcvr_reset_counter:g_pll.counter_pll_powerdown|r_reset\" " *)
`endif
//altera message_off 10036
module  altera_xcvr_reset_control
#(
    // General Options
    parameter CHANNELS          = 1,    // Number of CHANNELS
    parameter PLLS              = 1,    // Number of TX PLLs. For pll_powerdown and pll_locked
    parameter SYS_CLK_IN_MHZ    = 250,  // Clock frequency in MHz. Required for reset timers
    parameter SYNCHRONIZE_RESET = 1,    // (0,1) Synchronize the reset input
    parameter REDUCED_SIM_TIME  = 1,    // (0,1) 1=Reduced reset timings for simulation
    // PLL options
    parameter TX_PLL_ENABLE     = 0,    // (0,1) Enable TX PLL reset
    parameter T_PLL_POWERDOWN   = 1000, // pll_powerdown period in ns
    parameter SYNCHRONIZE_PLL_RESET = 0,// (0,1) Use synchronized reset input for PLL powerdown
                                        // !NOTE! Will prevent PLL merging across reset controllers
                                        // !NOTE! Requires SYNCHRONIZE_RESET == 1
    // TX options
    parameter TX_ENABLE         = 0,    // (0,1) Enable TX resets
    parameter TX_PER_CHANNEL    = 0,    // (0,1) 1=separate TX reset per channel
    parameter T_TX_ANALOGRESET  = 0,    // tx_analogreset period (after reset removal)
    parameter T_TX_DIGITALRESET = 20,   // tx_digitalreset period (after pll_powerdown)
    parameter T_PLL_LOCK_HYST   = 0,    // Amount of hysteresis to add to pll_locked status signal
    // RX options
    parameter RX_ENABLE         = 0,    // (0,1) Enable RX resets
    parameter RX_PER_CHANNEL    = 0,    // (0,1) 1=separate RX reset per channel
    parameter T_RX_ANALOGRESET  = 40,   // rx_analogreset period
    parameter T_RX_DIGITALRESET = 4000,  // rx_digitalreset period (after rx_is_lockedtodata)
    // CAL BUSY option
    parameter EN_PLL_CAL_BUSY = 0
) (
  // User inputs and outputs
  input   wire    clock,  // System clock
  input   wire    reset,  // Asynchronous reset

  // Reset signals
  output  wire  [PLLS-1:0]      pll_powerdown,      // reset TX PLL (to PHY/PLL)
  output  wire  [CHANNELS-1:0]  tx_analogreset,     // reset TX PMA (to PHY)
  output  wire  [CHANNELS-1:0]  tx_digitalreset,    // reset TX PCS (to PHY)
  output  wire  [CHANNELS-1:0]  rx_analogreset,     // reset RX PMA (to PHY)
  output  wire  [CHANNELS-1:0]  rx_digitalreset,    // reset RX PCS (to PHY)
  // Status output
  output  wire  [CHANNELS-1:0]  tx_ready, // TX is not in reset
  output  wire  [CHANNELS-1:0]  rx_ready, // RX is not in reset

  // Digital reset override inputs (must by synchronous with clock)
  input   wire  [CHANNELS-1:0]  tx_digitalreset_or, // reset request for tx_digitalreset
  input   wire  [CHANNELS-1:0]  rx_digitalreset_or, // reset request for rx_digitalreset

  // TX control inputs
  input   wire  [PLLS-1:0]      pll_locked,         // TX PLL lock status (from PHY/PLL)
  input   wire  [pll_select_width(PLLS,TX_PER_CHANNEL,CHANNELS)-1:0] pll_select, // Select TX PLL locked signal 
  input   wire  [CHANNELS-1:0]  tx_cal_busy,        // TX channel calibration status (from PHY/Reconfig)
  input   wire  [PLLS-1:0]      pll_cal_busy,       // TX PLL calibration status (from PLL)
  input   wire  [CHANNELS-1:0]  tx_manual,          // 0 = Automatically restart tx_digitalreset
                                                    // when pll_locked deasserts.
                                                    // 1 = Do nothing when pll_locked deasserts
  // RX control inputs
  input   wire  [CHANNELS-1:0]  rx_is_lockedtodata, // RX CDR PLL locked-to-data status (from PHY)
  input   wire  [CHANNELS-1:0]  rx_cal_busy,        // RX channel calibration status (from PHY/Reconfig)
  input   wire  [CHANNELS-1:0]  rx_manual           // 0 = Automatically restart rx_digitalreset
                                                    // when rx_is_lockedtodata deasserts
                                                    // 1 = Do nothing when rx_is_lockedtodata deasserts
);

// Faster reset time for simulation if indicated
localparam  SYNTH_CLK_IN_HZ = SYS_CLK_IN_MHZ * 1000000;
localparam  SIM_CLK_IN_HZ = (REDUCED_SIM_TIME == 1) 
                            ? 2 * 1000000 : SYNTH_CLK_IN_HZ;
`ifdef ALTERA_RESERVED_QIS
  localparam  SYS_CLK_IN_HZ = SYNTH_CLK_IN_HZ;
`else
  localparam  SYS_CLK_IN_HZ = SIM_CLK_IN_HZ;
`endif

// Calculate delays
wire  reset_sync;         // Synchronized reset input
wire  stat_pll_powerdown; // PLL powerdown status

genvar ig;

//**************************************************************************
//************************ Synchronize Reset Input *************************
generate if(SYNCHRONIZE_RESET == 1) begin: g_reset_sync
  // Synchronize reset input
  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b1)
  ) alt_xcvr_resync_reset (
    .clk    (clock      ),
    .reset  (reset      ),
    .d      (1'b0       ),
    .q      (reset_sync )
  );
end else begin: g_no_reset_sync
  assign  reset_sync = reset;
end
endgenerate
//************************ Synchronize Reset Input *************************
//**************************************************************************


//***************************************************************************
//*************************** TX PLL Reset Logic ****************************
generate if(TX_PLL_ENABLE) begin: g_pll
  wire  lcl_pll_powerdown;
  wire  reset_pll;
  assign  pll_powerdown = {PLLS{lcl_pll_powerdown}};
  if(SYNCHRONIZE_PLL_RESET == 1) begin : g_sync_pll_reset
    assign  reset_pll = reset_sync;
  end else begin : g_no_sync_pll_reset
    assign  reset_pll = reset;
  end
  // pll_powerdown 
  alt_xcvr_reset_counter #(
      .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
      .RESET_PER_NS (T_PLL_POWERDOWN  ), // Reset period in ns
      .ACTIVE_LEVEL (0                )
  ) counter_pll_powerdown (
    .clk        (clock              ),
    .async_req  (reset_pll          ),  // asynchronous reset request
    .sync_req   (1'b0               ),  // synchronous reset request
    .reset_or   (1'b0               ),
    .reset      (lcl_pll_powerdown  ),  // synchronous reset out
    .reset_n    (/*unused*/         ),
    .reset_stat (stat_pll_powerdown )
  );
end else begin : g_no_pll
  assign  pll_powerdown = {PLLS{1'b0}};
  assign  stat_pll_powerdown  = 1'b0;
end
endgenerate
//************************* End TX PLL Reset Logic **************************
//***************************************************************************


//***************************************************************************
//***************************** TX Reset Logic ******************************
generate if(TX_ENABLE) begin: g_tx
  localparam  PLL_SEL_WIDTH = altera_xcvr_functions::clogb2(PLLS-1);

  for (ig=0;ig<CHANNELS;ig=ig+1) begin : g_tx
    if(ig == 0 || TX_PER_CHANNEL == 1) begin : g_tx
      wire  lcl_tx_cal_busy;
      wire  lcl_tx_manual;
      wire  lcl_tx_digitalreset_or; // tx_digitalreset_or for this channel
      wire  lcl_pll_locked;   // pll_locked[lcl_pll_select]
      wire  lcl_pll_cal_busy;   // pll_cal_busy[lcl_pll_select]
      wire  [PLL_SEL_WIDTH-1:0]  lcl_pll_select;
      // Synchronized signals
      wire  tx_cal_busy_sync; // tx_cal_busy after synchronization
      wire  pll_cal_busy_sync;// pll_cal_busy after synchronization
      wire  tx_manual_sync;   // Synchronous reset trigger for TX resets
      wire  pll_locked_sync;  // pll_locked after synchronization
      wire  pll_locked_hyst;  // pll_locked after hysteresis
      reg   pll_locked_latch; // One shot latched pll_locked
      wire  tx_or_pll_cal_busy_sync; //output of OR between synchronized tx_cal_busy and pll_cal_busy
      // Reset status signals
      wire  stat_tx_analogreset;
      wire  stat_tx_digitalreset;
  
      // Control signal for this channel. With separate reset control per channel, each channel
      // listens to its own control signal. Otherwise the control signals for all channels are
      // combined for the shared reset control.
      assign  lcl_tx_cal_busy       = TX_PER_CHANNEL ? tx_cal_busy[ig]  : |tx_cal_busy;
      assign  lcl_tx_manual         = TX_PER_CHANNEL ? tx_manual  [ig]  : |tx_manual;
      assign  lcl_tx_digitalreset_or= TX_PER_CHANNEL ? tx_digitalreset_or [ig] : |tx_digitalreset_or;
      assign  lcl_pll_locked        = pll_locked[lcl_pll_select];
      if(EN_PLL_CAL_BUSY==1) begin : cal_busy
          assign  lcl_pll_cal_busy      = pll_cal_busy[lcl_pll_select];
      end else begin : no_cal_busy
          assign  lcl_pll_cal_busy      = 1'b0;
      end

      assign  lcl_pll_select        = TX_PER_CHANNEL ? pll_select[ig*PLL_SEL_WIDTH+:PLL_SEL_WIDTH]
                                                     : (PLLS > 1)   ? pll_select
                                                     : 1'b0;
      
      assign tx_or_pll_cal_busy_sync = tx_cal_busy_sync | pll_cal_busy_sync;

      // Synchonize TX inputs
      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (4),
          .INIT_VALUE (0)
      ) resync_tx_cal_busy (
        .clk    (clock            ),
        .reset  (reset_sync       ),
        .d      ({lcl_tx_cal_busy ,lcl_pll_cal_busy ,lcl_tx_manual ,lcl_pll_locked }),
        .q      ({tx_cal_busy_sync,pll_cal_busy_sync,tx_manual_sync,pll_locked_sync})
      );

      // Add hysteresis to pll_locked if needed
      // Reset counter works fine for hysteresis
      if(T_PLL_LOCK_HYST != 0) begin : g_pll_locked_hyst
        alt_xcvr_reset_counter #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ  ), // Clock frequency in Hz
            .RESET_PER_NS (T_PLL_LOCK_HYST)  // Reset period in ns
        ) counter_pll_locked_hyst (
          .clk        (clock            ),
          .async_req  (reset_sync       ),  // asynchronous reset request
          .sync_req   (~pll_locked_sync ),  // synchronous reset request
          .reset_or   (1'b0             ),
          .reset      (/*unused*/       ),  // synchronous reset out
          .reset_n    (pll_locked_hyst  ),
          .reset_stat (/*unused*/       )
        );
      end else begin : g_no_pll_locked_hyst
        // No hysteresis added; use synchronized pll_locked directly.
        assign  pll_locked_hyst = pll_locked_sync;
      end

      // Add one-shot latch to pll_locked for initial reset sequence
      always @(posedge clock or posedge reset_sync)
      if(reset_sync)  pll_locked_latch  <= 1'b0;
      else if(pll_locked_hyst & ~tx_cal_busy_sync)
                      pll_locked_latch  <= 1'b1;
  
      // tx_analogreset
      if(T_TX_ANALOGRESET == 0) begin
        // Tie tx_analogreset to pll_powerdown if used, otherwise tie to reset input (which may be synchronized)
        assign  tx_analogreset[ig]  = TX_PLL_ENABLE ? pll_powerdown[0] : reset_sync;
        assign  stat_tx_analogreset = stat_pll_powerdown;
      end else begin
        // Assert rx_analogreset during RX calibration and for "T_RX_ANALOGRESET" ns thereafter
        alt_xcvr_reset_counter #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
            .RESET_PER_NS (T_TX_ANALOGRESET )  // Reset period in ns
        ) counter_tx_analogreset (
          .clk        (clock                  ),
          .async_req  (reset_sync             ),  // asynchronous reset request
          .sync_req   (tx_or_pll_cal_busy_sync),  // synchronous reset request
          .reset_or   (1'b0                   ),  // auxilliary reset override
          .reset      (tx_analogreset [ig]    ),  // synchronous reset out
          .reset_n    (/*unused*/             ),
          .reset_stat (stat_tx_analogreset    )
        );
      end

      // tx_digitalreset
      // Assert tx_digitalreset while any of the following
      // 1 - pll_powerdown is asserted.
      // 2 - TX calibration is in progress
      // 3 - PLL has not reached initial lock (pll_locked_latch)
      // 4 - PLL is not locked AND TX reset is NOT under manual control
      // 5 - Reset override
      alt_xcvr_reset_counter #(
          .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
          .RESET_PER_NS (T_TX_DIGITALRESET )  // Reset period in ns
      ) counter_tx_digitalreset (
        .clk        (clock                  ),
        .async_req  (reset_sync             ),  // asynchronous reset request
        .sync_req   (stat_tx_analogreset | tx_cal_busy_sync | ~pll_locked_latch | (~pll_locked_hyst&~tx_manual_sync)),  // synchronous reset request
        .reset_or   (lcl_tx_digitalreset_or ),  // auxilliary reset override
        .reset      (tx_digitalreset[ig]    ),  // synchronous reset out
        .reset_n    (/*unused*/             ),
        .reset_stat (stat_tx_digitalreset   )
      );
  
      // tx_ready
      alt_xcvr_reset_counter #(
          .RESET_COUNT(3)
      ) counter_tx_ready (
        .clk        (clock                ),
        .async_req  (reset_sync           ),  // asynchronous reset request
        .sync_req   (stat_tx_digitalreset ),  // synchronous reset request
        .reset_or   (1'b0                 ),  // auxilliary reset override
        .reset      (/*unused*/           ),  // synchronous reset out
        .reset_n    (tx_ready       [ig]  ),
        .reset_stat (/*unused*/           )   // reset status
      );
    end else begin : g_fanout_tx
      assign  tx_analogreset  [ig]  = tx_analogreset  [0];
      assign  tx_digitalreset [ig]  = tx_digitalreset [0];
      assign  tx_ready        [ig]  = tx_ready        [0];
    end
  end
end else begin : g_no_tx
  assign  tx_analogreset  = {CHANNELS{1'b0}};
  assign  tx_digitalreset = {CHANNELS{1'b0}};
  assign  tx_ready        = {CHANNELS{1'b0}};
end
endgenerate
//*************************** End TX Reset Logic ****************************
//***************************************************************************


//***************************************************************************
//***************************** RX Reset Logic ******************************
generate if (RX_ENABLE) begin : g_rx
  for (ig=0;ig<CHANNELS;ig=ig+1) begin : g_rx
    if(ig == 0 || RX_PER_CHANNEL == 1) begin : g_rx
      wire  lcl_rx_cal_busy;        // rx_cal_busy for this channel
      wire  lcl_rx_manual;          // rx_manual for this channel
      wire  lcl_rx_is_lockedtodata; // rx_is_lockedtodata for this channel
      wire  lcl_rx_digitalreset_or; // rx_digitalreset_or for this channel
      // Synchronized signals
      wire  rx_cal_busy_sync;         // rx_cal_busy after synchronization
      wire  rx_manual_sync;           // rx_manual after synchronization
      wire  rx_is_lockedtodata_sync;  // rx_is_lockedtodata after synchronization
      // Reset status signals
      wire  stat_rx_analogreset;
      wire  stat_rx_digitalreset;     
    
      // Control signal for this channel. With separate reset control per channel, each channel
      // listens to its own control signal. Otherwise the control signals for all channels are
      // combined for the shared reset control.
      assign  lcl_rx_manual           = RX_PER_CHANNEL ? rx_manual          [ig] : |rx_manual;
      assign  lcl_rx_cal_busy         = RX_PER_CHANNEL ? rx_cal_busy        [ig] : |rx_cal_busy;
      assign  lcl_rx_is_lockedtodata  = RX_PER_CHANNEL ? rx_is_lockedtodata [ig] : &rx_is_lockedtodata;
      assign  lcl_rx_digitalreset_or  = RX_PER_CHANNEL ? rx_digitalreset_or [ig] : |rx_digitalreset_or;
      
      // Synchonize RX inputs
      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH            (3),
          .INIT_VALUE       (3'b100)
      ) resync_rx_cal_busy (
        .clk    (clock            ),
        .reset  (reset_sync       ),
        .d      ({lcl_rx_cal_busy, lcl_rx_is_lockedtodata ,lcl_rx_manual }),
        .q      ({rx_cal_busy_sync,rx_is_lockedtodata_sync,rx_manual_sync})
      );
    
      // rx_analogreset
      // Assert rx_analogreset during RX calibration and for "T_RX_ANALOGRESET" ns thereafter
      alt_xcvr_reset_counter #(
          .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
          .RESET_PER_NS (T_RX_ANALOGRESET )  // Reset period in ns
      ) counter_rx_analogreset (
        .clk        (clock              ),
        .async_req  (reset_sync         ),  // asynchronous reset request
        .sync_req   (rx_cal_busy_sync   ),  // synchronous reset request
        .reset_or   (1'b0               ),  // auxilliary reset override
        .reset      (rx_analogreset [ig]),  // synchronous reset out
        .reset_n    (/*unused*/         ),
        .reset_stat (stat_rx_analogreset)
      );
    
      // rx_digitalreset
      // Assert rx_digitalreset while any of the following:
      // 1 - RX calibration is in progress
      // 2 - rx_analogreset is asserted
      // 3 - RX is not locked to data AND RX reset is NOT under manual control
      //        (meaning user wants us to respond to loss of RX data lock)
      alt_xcvr_reset_counter #(
          .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
          .RESET_PER_NS (T_RX_DIGITALRESET )  // Reset period in ns
      ) counter_rx_digitalreset (
        .clk        (clock                  ),
        .async_req  (reset_sync             ),  // asynchronous reset request
        .sync_req   (rx_cal_busy_sync|stat_rx_analogreset|(~rx_is_lockedtodata_sync&~rx_manual_sync)),  // synchronous reset request
        .reset_or   (lcl_rx_digitalreset_or ),  // auxilliary reset override
        .reset      (rx_digitalreset[ig]    ),  // synchronous reset out
        .reset_n    (/*unused*/             ),
        .reset_stat (stat_rx_digitalreset   )
      );
    
      // rx_ready
      alt_xcvr_reset_counter #(
          .RESET_COUNT(3)
      ) counter_rx_ready (
        .clk        (clock                ),
        .async_req  (reset_sync           ),  // asynchronous reset request
        .sync_req   (stat_rx_digitalreset ),  // synchronous reset request
        .reset_or   (1'b0                 ),  // auxilliary reset override
        .reset      (/*unused*/           ),  // synchronous reset out
        .reset_n    (rx_ready[ig]         ),
        .reset_stat (/*unused*/           )
      );
    
    end else begin : g_fanout_rx
      assign  rx_analogreset  [ig]  = rx_analogreset  [0];
      assign  rx_digitalreset [ig]  = rx_digitalreset [0];
      assign  rx_ready        [ig]  = rx_ready        [0];
    end
  end
end else begin : g_no_rx
  assign  rx_analogreset  = {CHANNELS{1'b0}};
  assign  rx_digitalreset = {CHANNELS{1'b0}};
  assign  rx_ready        = {CHANNELS{1'b0}};
end
endgenerate
//*************************** End RX Reset Logic ****************************
//***************************************************************************

// pll_select_width
// Internal function to calculate the width of pll_select port.
// @param PLLS - Number of TX PLLs
// @param TX_PER_CHANNEL - Separate TX reset controller per channel
// @param CHANNELS - The number of TX CHANNELS
//
// @return - The width of the pll_select port
function integer pll_select_width;
  input integer PLLS;
  input integer TX_PER_CHANNEL;
  input integer CHANNELS;
  begin
    pll_select_width = altera_xcvr_functions::clogb2(PLLS-1);
    if(TX_PER_CHANNEL) pll_select_width = pll_select_width * CHANNELS;
  end
endfunction

endmodule

