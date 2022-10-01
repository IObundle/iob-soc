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


// $Id: //acds/rel/12.1/ip/merlin/altera_merlin_traffic_limiter/altera_merlin_traffic_limiter.sv#1 $
// $Revision: #1 $
// $Date: 2012/08/12 $
// $Author: swbranch $

// -----------------------------------------------------
// Merlin Traffic Limiter
//
// Ensures that non-posted transaction responses are returned 
// in order of request. Out-of-order responses can happen 
// when a master does a non-posted transaction on a slave 
// while responses are pending from a different slave.
// Examples
//  1) read to any latent slave, followed by a read to a 
//   variable-latent slave
//  2) read to any fixed-latency slave, followed by a read 
//   to another fixed-latency slave whose fixed latency is smaller.
//
// For now, we'll backpressure to prevent a master from
// switching slaves until all outstanding read responses have
// returned. We also have to suppress the read, obviously.
//
// Note: folding this into the router may give better fmax,
// consider after profiling. If folding into router, break
// into separate components: address router and destid router.
// This only needs to be in the address router.
// -----------------------------------------------------

`timescale 1 ns / 1 ns
// altera message_off 10036
module altera_merlin_traffic_limiter
#(
    parameter PKT_TRANS_POSTED          = 1,
              PKT_DEST_ID_H             = 0,
              PKT_DEST_ID_L             = 0,
              ST_DATA_W                 = 72,
              ST_CHANNEL_W              = 32,
              MAX_OUTSTANDING_RESPONSES = 1,
              PIPELINED                 = 0,
              ENFORCE_ORDER             = 1,
              PKT_BYTE_CNT_H            = 0,
              PKT_BYTE_CNT_L            = 0,
              PKT_BYTEEN_H              = 0,
              PKT_BYTEEN_L              = 0,
              PKT_TRANS_WRITE           = 0,
              PKT_TRANS_READ            = 0,

              // -------------------------------------
              // internal: allows optimization between this
              // component and the demux
              // -------------------------------------
              VALID_WIDTH               = 1,
              // -------------------------------------
              // beta: prevents all RAW and WAR hazards by
              // waiting for responses to return before issuing
              // a command with different direction.
              //
              // this is intended for Avalon masters that are
              // connected to AXI slaves.
              //
              // expect this to be replaced with a less
              // restrictive scheme in the future.
              // -------------------------------------
              PREVENT_HAZARDS           = 0
)
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command
    // -------------------
    input                           cmd_sink_valid,
    input  [ST_DATA_W-1 : 0]        cmd_sink_data,
    input  [ST_CHANNEL_W-1 : 0]     cmd_sink_channel,
    input                           cmd_sink_startofpacket,
    input                           cmd_sink_endofpacket,
    output                          cmd_sink_ready,

    output reg [VALID_WIDTH-1  : 0] cmd_src_valid,
    output reg [ST_DATA_W-1    : 0] cmd_src_data,
    output reg [ST_CHANNEL_W-1 : 0] cmd_src_channel,
    output reg                      cmd_src_startofpacket,
    output reg                      cmd_src_endofpacket,
    input                           cmd_src_ready,

    // -------------------
    // Response
    // -------------------
    input                           rsp_sink_valid,
    input  [ST_DATA_W-1 : 0]        rsp_sink_data,
    input  [ST_CHANNEL_W-1 : 0]     rsp_sink_channel,
    input                           rsp_sink_startofpacket,
    input                           rsp_sink_endofpacket,
    output reg                      rsp_sink_ready,

    output reg                      rsp_src_valid,
    output reg [ST_DATA_W-1    : 0] rsp_src_data,
    output reg [ST_CHANNEL_W-1 : 0] rsp_src_channel,
    output reg                      rsp_src_startofpacket,
    output reg                      rsp_src_endofpacket,
    input                           rsp_src_ready
);

    // -------------------------------------
    // Local Parameters
    // -------------------------------------
    localparam DEST_ID_W  = PKT_DEST_ID_H - PKT_DEST_ID_L + 1;
    localparam COUNTER_W  = log2ceil(MAX_OUTSTANDING_RESPONSES + 1);
    localparam PAYLOAD_W  = ST_DATA_W + ST_CHANNEL_W + 4;
    localparam NUMSYMBOLS = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    // -----------------------------------------------------
    // Input Stage
    //
    // Figure out if the destination id has changed
    // -----------------------------------------------------
    wire                    stage1_nonposted_cmd;
    wire                    stage1_dest_changed;
    wire                    stage1_trans_changed;
    wire [PAYLOAD_W-1 : 0]  stage1_payload;
    wire [DEST_ID_W-1 : 0]  dest_id;
    reg  [DEST_ID_W-1 : 0]  last_dest_id;
    reg  [ST_CHANNEL_W-1:0] last_channel;
    reg                     was_write;
    wire                    is_write;
    wire                    suppress;
    wire                    save_dest_id;

    assign dest_id = cmd_sink_data[PKT_DEST_ID_H:PKT_DEST_ID_L];

    generate if (PREVENT_HAZARDS == 1) begin : stage1_nonposted_block
        assign stage1_nonposted_cmd = 1'b1;
    end else begin
        assign stage1_nonposted_cmd = (cmd_sink_data[PKT_TRANS_POSTED] == 0);
    end
    endgenerate

    // ------------------------------------
    // Optimization: for the unpipelined case, we can save the destid if
    // this is an unsuppressed nonposted command. This eliminates
    // dependence on the backpressure signal.
    //
    // Not a problem for the pipelined case.
    // ------------------------------------
    generate begin : pipelined_save_dest_id
        if (PIPELINED)
            assign save_dest_id = cmd_sink_valid & cmd_sink_ready & stage1_nonposted_cmd;
        else
            assign save_dest_id = cmd_sink_valid & ~suppress & stage1_nonposted_cmd;
    end endgenerate

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            last_dest_id <= 0;
            last_channel <= 0;
            was_write    <= 0;
        end
        else if (save_dest_id) begin
            last_dest_id <= dest_id;
            last_channel <= cmd_sink_channel;
            was_write    <= is_write;
        end
    end

    assign is_write = cmd_sink_data[PKT_TRANS_WRITE];
    assign stage1_dest_changed = (last_dest_id != dest_id);
    assign stage1_trans_changed = (was_write != is_write);

    assign stage1_payload = { cmd_sink_data, 
        cmd_sink_channel,
        cmd_sink_startofpacket,
        cmd_sink_endofpacket,
        stage1_dest_changed,
        stage1_trans_changed };
        
    // -----------------------------------------------------
    // (Optional) pipeline between input and output
    // -----------------------------------------------------
    wire                    stage2_valid;
    reg                     stage2_ready;
    wire [PAYLOAD_W-1 : 0]  stage2_payload;

    generate begin : pipelined_limiter
        if (PIPELINED == 1) begin
            altera_avalon_st_pipeline_base
            #(
                .BITS_PER_SYMBOL(PAYLOAD_W)
            ) stage1_pipe (
                .clk        (clk),
                .reset      (reset),
                .in_ready   (cmd_sink_ready),
                .in_valid   (cmd_sink_valid),
                .in_data    (stage1_payload),
                .out_valid  (stage2_valid),
                .out_ready  (stage2_ready),
                .out_data   (stage2_payload)
            );
        end else begin
            assign stage2_valid   = cmd_sink_valid;
            assign stage2_payload = stage1_payload;
            assign cmd_sink_ready = stage2_ready;
        end
    end endgenerate

    // -----------------------------------------------------
    // Output Stage
    // -----------------------------------------------------
    wire [ST_DATA_W-1 : 0]  stage2_data;
    wire [ST_CHANNEL_W-1:0] stage2_channel;
    wire                    stage2_startofpacket;
    wire                    stage2_endofpacket;
    wire                    stage2_dest_changed;                   
    wire                    stage2_trans_changed;                   
    reg                     has_pending_responses;
    reg  [COUNTER_W-1 : 0]  pending_response_count;
    reg  [COUNTER_W-1 : 0]  next_pending_response_count;
    wire                    nonposted_cmd;
    wire                    nonposted_cmd_accepted;
    wire                    response_accepted;
    wire                    count_is_1;
    wire                    count_is_0;
    reg                     internal_valid;

    assign { stage2_data, 
        stage2_channel,
        stage2_startofpacket,
        stage2_endofpacket,
        stage2_dest_changed,
        stage2_trans_changed } = stage2_payload;

    generate if (PREVENT_HAZARDS == 1) begin : stage2_nonposted_block
        assign nonposted_cmd = 1'b1;
    end else begin
        assign nonposted_cmd = (stage2_data[PKT_TRANS_POSTED] == 0);
    end
    endgenerate

    assign nonposted_cmd_accepted = nonposted_cmd && internal_valid && (cmd_src_ready && cmd_src_endofpacket);

    // -----------------------------------------------------
    // Use the sink's control signals here, because write responses may be dropped
    // when hazard prevention is on.
    // -----------------------------------------------------
    assign response_accepted = rsp_sink_valid && rsp_sink_ready && rsp_sink_endofpacket;

    always @* begin
        next_pending_response_count = pending_response_count;

        if (nonposted_cmd_accepted)
            next_pending_response_count = pending_response_count + 1'b1;
        if (response_accepted)
            next_pending_response_count = pending_response_count - 1'b1;
        if (nonposted_cmd_accepted && response_accepted)
            next_pending_response_count = pending_response_count;
    end

    assign count_is_1 = (pending_response_count == 1);
    assign count_is_0 = (pending_response_count == 0);

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pending_response_count <= 0;
            has_pending_responses  <= 0;
        end
        else begin
            pending_response_count <= next_pending_response_count;
            // synthesis translate_off
            if (count_is_0 && response_accepted)
                $display("%t: %m: Error: unexpected response: pending_response_count underflow", $time());
            // synthesis translate_on
            has_pending_responses  <= has_pending_responses 
                && ~(count_is_1 && response_accepted && ~nonposted_cmd_accepted)
                || (count_is_0 && nonposted_cmd_accepted && ~response_accepted);
        end
    end

    // -------------------------------------
    // Pass-through command and response
    // -------------------------------------
    always @* begin
        cmd_src_channel       = stage2_channel;
        cmd_src_startofpacket = stage2_startofpacket;
        cmd_src_endofpacket   = stage2_endofpacket;
        cmd_src_data          = stage2_data;

        rsp_src_valid         = rsp_sink_valid;
        rsp_src_data          = rsp_sink_data;
        rsp_src_channel       = rsp_sink_channel;
        rsp_src_startofpacket = rsp_sink_startofpacket;
        rsp_src_endofpacket   = rsp_sink_endofpacket;
        rsp_sink_ready        = rsp_src_ready;

        // -------------------------------------
        // Forces commands to be non-posted if hazard prevention
        // is on, also drops write responses
        // -------------------------------------
        if (PREVENT_HAZARDS == 1) begin
            cmd_src_data[PKT_TRANS_POSTED] = 1'b0;

            if (rsp_sink_data[PKT_TRANS_WRITE] == 1'b1) begin
                rsp_src_valid  = 1'b0;
                rsp_sink_ready = 1'b1;
            end
        end
    end

    // -------------------------------------
    // Backpressure & Suppression
    // -------------------------------------
    generate begin : enforce_order_block
        if (ENFORCE_ORDER) begin
            assign suppress = nonposted_cmd && has_pending_responses && 
                                (stage2_dest_changed || (PREVENT_HAZARDS == 1 && stage2_trans_changed));
        end else begin
            assign suppress = 1'b0;
        end
    end endgenerate

    always @* begin
        stage2_ready = cmd_src_ready;
        internal_valid = stage2_valid;

        if (suppress) begin
            stage2_ready = 0;
            internal_valid = 0;
        end

        if (VALID_WIDTH == 1) begin
            cmd_src_valid = internal_valid;
        end else begin
            // -------------------------------------
            // Use the one-hot channel to determine if the destination
            // has changed. This results in a wide valid bus
            // -------------------------------------
            cmd_src_valid = { VALID_WIDTH {stage2_valid} } & cmd_sink_channel;
            if (nonposted_cmd & has_pending_responses) begin
                cmd_src_valid = cmd_src_valid & last_channel;
                // -------------------------------------
                // Mask the valid signals if the transaction type has changed
                // if hazard prevention is enabled
                // -------------------------------------
                if (PREVENT_HAZARDS == 1)
                    cmd_src_valid = cmd_src_valid & { VALID_WIDTH {!stage2_trans_changed} };
            end
        end
    end

    // --------------------------------------------------
    // Calculates the log2ceil of the input value.
    //
    // This function occurs a lot... please refactor.
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule

