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


//Use: When switching logical channels, or whenever the testbus is reconfigured,
//the reset for the ber must be asserted.  The reset and snapshot are self-clearing
//bits, and do not need to be manually de-asserted.

`timescale 1ns / 1ps

(* ALTERA_ATTRIBUTE = {"suppress_da_rule_internal=\"C101,C105,C104,R101,S104\""} *) module alt_xcvr_reconfig_eyemon_ber_sv (
  input         clk,
  input         reset,
  input [7:0]   ber_threshold,
  input [7:0]   testbus,
  input         ber_clk_en,
  input         ber_count_rst,
  input         ber_snap_shot,
  input         ber_count_en,
  output [31:0] ber_bit_high,
  output [31:0] ber_bit_low,
  output [31:0] ber_err_high,
  output [31:0] ber_err_low,
  output [31:0] ber_excp
);

localparam CDC_SYNC_DEPTH = 3;

//Registers for the Counters used by the BER
reg [43:0] bit_count, bit_count_snap;
reg [43:0] ber_count, ber_count_snap;
reg [31:0] excp_count, excp_count_snap;
reg        reset_status;

// DC FIFO connections
wire [6: 0]                              ber_data_from_fifo;
reg  [6: 0]                              ber_data_from_fifo_d1;
reg                                      snap_shot_prev;
reg                                      count_rst_prev;
wire                                     ber_fifo_empty;
wire                                     ber_clk_en_sync;
wire                                     reset_sync_tbclk;
wire                                     ber_clk;
wire                                     snap_shot_edge;
wire                                     count_rst_posedge;

//assign outputs from the appropriate counter.
assign ber_bit_high   = {20'b0, bit_count_snap[43:32]};
assign ber_bit_low    = bit_count_snap[31:0];
assign ber_err_high   = {20'b0, ber_count_snap[43:32]};
assign ber_err_low    = ber_count_snap[31:0];
assign ber_excp       = excp_count_snap;

//Rebuffer the testbus[7]
lcell ber_clk_lcell (.in(testbus[7]), .out(ber_clk));

//Synchronizes the reset signal to the write side of the dc fifo.
alt_xcvr_resync
#(.SYNC_CHAIN_LENGTH (CDC_SYNC_DEPTH),
  .WIDTH             (1),
  .INIT_VALUE        (1'b1)
) tb_reset_synchronizer (
  .clk      (ber_clk), 
  .reset    (reset | ber_count_rst), 
  .d        (1'b0), 
  .q        (reset_sync_tbclk)
); 

//synchronize the fifo write request to the write side of the dc fifo.
alt_xcvr_resync
#(.SYNC_CHAIN_LENGTH (CDC_SYNC_DEPTH),
  .WIDTH             (1)
) ber_clk_en_synchronizer (
  .clk      (ber_clk), 
  .reset    (reset_sync_tbclk), 
  .d        (ber_clk_en), 
  .q        (ber_clk_en_sync)
); 

//A rate match fifo to safely cross clock doamins.
ber_reader_dcfifo ber_fifo (
  .aclr(reset_sync_tbclk),
  .data(testbus[6:0]),
  .rdclk(clk),
  .rdreq(~ber_fifo_empty),
  .wrclk(ber_clk),
  .wrreq(ber_clk_en_sync),
  .q(ber_data_from_fifo),
  .rdempty(ber_fifo_empty));


//Edge detector for capturing a snapshot of the counters so all the counter values are in sync with each other.
assign snap_shot_edge    = (ber_snap_shot && ~snap_shot_prev);
assign count_rst_posedge = (ber_count_rst && ~count_rst_prev);

//Logic for taking a Snap shot of the counters
always@(posedge clk or posedge reset) begin
  if(reset == 1'b1) begin
    bit_count_snap                        <= 44'h0;
    ber_count_snap                        <= 44'h0;
    excp_count_snap                       <= 32'h0;
  end else begin
    //if snap shot is asserted, then capture the values of the counters in the snap shot
    count_rst_prev                        <= ber_count_rst;
    snap_shot_prev                        <= ber_snap_shot;
    if (snap_shot_edge == 1'b1)
    begin
      bit_count_snap                      <= bit_count;
      ber_count_snap                      <= ber_count;
      excp_count_snap                     <= excp_count;
    end else begin
      //if snapshot is not asserted, and the reset is asserted, then reset the snapshot
      if (count_rst_posedge == 1'b1)
      begin
        bit_count_snap                    <= 44'h0;
        ber_count_snap                    <= 44'h0;
        excp_count_snap                   <= 32'h0;
      //if neither is asserted, recycle the values in the snapshot
      end else begin
        bit_count_snap                    <= bit_count_snap;
        ber_count_snap                    <= ber_count_snap;
        excp_count_snap                   <= excp_count_snap;
      end
    end
  end
end

always@(posedge clk or posedge reset) begin
  //global reset
  if(reset == 1'b1) begin
    bit_count                             <= 44'h0;
    ber_count                             <= 44'h0;
    excp_count                            <= 32'h0;
    reset_status                          <= 1'b1;
    ber_data_from_fifo_d1                 <= 7'b0000000;
  end else begin 
    //soft csr-driven reset
    if(ber_count_rst == 1'b1) begin
      bit_count                           <= 44'h0;
      ber_count                           <= 44'h0;
      excp_count                          <= 32'h0;
      reset_status                        <= 1'b1;
      ber_data_from_fifo_d1               <= 7'b0000000;
    end else begin
      //To avoid double counting bits, make sure the fifo is not empty
      if(ber_count_en == 1'b1 && ber_fifo_empty == 1'b0) begin
        ber_data_from_fifo_d1             <= ber_data_from_fifo; 
        reset_status                      <= 1'b0;
        //On reset, mask the first read from the fifo
        if(reset_status == 1'b0) begin
          if((ber_data_from_fifo - ber_data_from_fifo_d1) <= ber_threshold) begin
            bit_count                      <= bit_count + 1;
            ber_count                      <= ber_count + (ber_data_from_fifo - ber_data_from_fifo_d1);
          end else if(ber_data_from_fifo <= ber_threshold) begin
            bit_count                      <= bit_count + 1;
            ber_count                      <= ber_count + ber_data_from_fifo;
          end else begin
            excp_count                      <= excp_count + 1;
          end
        end
      end // count_en && ~fifo_empty
    end // ber_count_reset
  end
end
endmodule
