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


// $Id: //acds/rel/16.1/ip/merlin/altera_merlin_demultiplexer/altera_merlin_demultiplexer.sv.terp#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

// -------------------------------------
// Merlin Demultiplexer
//
// Asserts valid on the appropriate output
// given a one-hot channel signal.
// -------------------------------------

`timescale 1 ns / 1 ns

// ------------------------------------------
// Generation parameters:
//   output_name:         ddr3_b_example_if1_s0_mm_interconnect_1_rsp_demux
//   ST_DATA_W:           92
//   ST_CHANNEL_W:        5
//   NUM_OUTPUTS:         1
//   VALID_WIDTH:         1
// ------------------------------------------

//------------------------------------------
// Message Supression Used
// QIS Warnings
// 15610 - Warning: Design contains x input pin(s) that do not drive logic
//------------------------------------------

module ddr3_b_example_if1_s0_mm_interconnect_1_rsp_demux
(
    // -------------------
    // Sink
    // -------------------
    input  [1-1      : 0]   sink_valid,
    input  [92-1    : 0]   sink_data, // ST_DATA_W=92
    input  [5-1 : 0]   sink_channel, // ST_CHANNEL_W=5
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    // -------------------
    // Sources 
    // -------------------
    output reg                      src0_valid,
    output reg [92-1    : 0] src0_data, // ST_DATA_W=92
    output reg [5-1 : 0] src0_channel, // ST_CHANNEL_W=5
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,


    // -------------------
    // Clock & Reset
    // -------------------
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on clk
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on reset
    input reset

);

    localparam NUM_OUTPUTS = 1;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    // -------------------
    // Demux
    // -------------------
    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid;

    end

    // -------------------
    // Backpressure
    // -------------------
    assign ready_vector[0] = src0_ready;

    assign sink_ready = |(sink_channel & {{4{1'b0}},{ready_vector[NUM_OUTPUTS - 1 : 0]}});

endmodule

