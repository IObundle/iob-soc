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


//////////////////////////////////////////////////////////////////////////////
// The data interface module controls the Avalon interface by accepting
// requests when the controller is ready, and putting the Avalon bus into a
// wait state when the controller is busy by deasserting 'avl_ready'.  This
// module also breaks Avalon bursts into individual memory requests by
// generating sequential addresses for each beat of the burst.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_data_if_ctl_bl_is_one_qdrii (
    clk,
    reset_n,
    init_complete,
    init_fail,
    local_init_done,
    avl_ready,
    avl_write_req,
    avl_read_req,
    avl_addr,
    avl_size,
    avl_wdata,
    avl_rdata_valid,
    avl_rdata,
    cmd1_write_req,
    cmd1_read_req,
    cmd1_addr,
    cmd1_addr_can_merge,
    cmd1_wdata,
    rdata_valid,
    rdata,
    pop_req
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon interface parameters
parameter AVL_ADDR_WIDTH    = 0;
parameter AVL_SIZE_WIDTH    = 0;
parameter AVL_DWIDTH        = 0;
parameter BEATADDR_WIDTH    = 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input                               clk;
input                               reset_n;

// PHY initialization and calibration status
input                               init_complete;
input                               init_fail;
output                              local_init_done;

// Avalon data slave interface
output                              avl_ready;
input                               avl_write_req;
input                               avl_read_req;
input   [AVL_ADDR_WIDTH-1:0]        avl_addr;
input   [AVL_SIZE_WIDTH-1:0]        avl_size;
input   [AVL_DWIDTH-1:0]            avl_wdata;
output                              avl_rdata_valid;
output  [AVL_DWIDTH-1:0]            avl_rdata;

// User interface module signals
output                              cmd1_write_req;
output                              cmd1_read_req;
output  [AVL_ADDR_WIDTH-1:0]        cmd1_addr;
output                              cmd1_addr_can_merge;
output  [AVL_DWIDTH-1:0]            cmd1_wdata;
input                               rdata_valid;
input   [AVL_DWIDTH-1:0]            rdata;

// Write or read command issued by the state machine
input                               pop_req;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// FSM states
enum int unsigned {
    RESET_STATE,
    INIT,
    NORMAL,
    WRITE_BURST,
    READ_BURST
} state;


// CMD1 registered signals
reg                                 cmd1_write_req;
reg                                 cmd1_read_req;
reg [AVL_ADDR_WIDTH-1:0]            cmd1_addr;
reg                                 cmd1_addr_can_merge;
reg [AVL_SIZE_WIDTH-1:0]            beats_left;
reg [AVL_DWIDTH-1:0]                cmd1_wdata;

// Wires
wire                                next_cmd1_addr_can_merge;
wire                                cmd1_valid;

assign local_init_done = init_complete & ~init_fail;
// Command valid
assign cmd1_valid = cmd1_write_req ^ cmd1_read_req;

// Connect Avalon signals
assign avl_ready = (reset_n) & (state == NORMAL | state == WRITE_BURST) & ~(cmd1_valid & ~pop_req) & (local_init_done);
assign avl_rdata_valid = rdata_valid;
assign avl_rdata = rdata;

// Merging is not possible with a burst length of 1
assign next_cmd1_addr_can_merge = 1'b0;


// Avalon signal capturing state machine
always_ff @(posedge clk, negedge reset_n)
begin
    if (!reset_n) begin
        state <= RESET_STATE;
        cmd1_write_req <= '0;
        cmd1_read_req <= '0;
        cmd1_addr <= '0;
        cmd1_addr_can_merge <= '0;
        beats_left <= '0;
    end
    else
    begin

        state <= state;
        cmd1_write_req <= cmd1_write_req;
        cmd1_read_req <= cmd1_read_req;
        cmd1_addr <= cmd1_addr;
        cmd1_addr_can_merge <= cmd1_addr_can_merge;
        beats_left <= beats_left;

        case (state)
            RESET_STATE:
                begin
                    state <= INIT;
                end

            INIT:
                begin
                    cmd1_addr <= '0;
                    cmd1_wdata <= '0;
                    beats_left <= '0;

                    if (local_init_done)
                        state <= NORMAL;
                end
            NORMAL:
                // Capture the request from the Avalon interface
                if (avl_ready)
                begin
                    cmd1_write_req <= avl_write_req;
                    cmd1_read_req <= avl_read_req;
                    cmd1_addr <= avl_addr;
                    cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                    beats_left <= avl_size;
                    cmd1_wdata <= avl_wdata;

                    if (avl_size > 1)
                    begin
                        if (avl_write_req && !avl_read_req)
                            state <= WRITE_BURST;
                        else if (avl_read_req && !avl_write_req)
                            state <= READ_BURST;
                    end
                end

            WRITE_BURST:
                // Capture the request from the Avalon interface and
                // increment the address for the current write burst
                if (avl_ready)
                begin
                    cmd1_write_req <= avl_write_req;
                    cmd1_read_req <= avl_read_req;
                    cmd1_wdata <= avl_wdata;

                    if (avl_write_req && !avl_read_req)
                    begin
                        cmd1_addr <= cmd1_addr + 1'b1;
                        cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                        beats_left <= beats_left - 1'b1;

                        if (beats_left == 2)
                            state <= NORMAL;
                    end
                end

            READ_BURST:
                // Issue read request with incrementing address for current read burst
                if (pop_req)
                begin
                    cmd1_write_req <= '0;
                    cmd1_read_req <= 1'b1;
                    cmd1_addr <= cmd1_addr + 1'b1;
                    cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                    beats_left <= beats_left - 1'b1;

                    if (beats_left == 2)
                        state <= NORMAL;
                end
        endcase
    end
end


// Simulation assertions
// synthesis translate_off
always_ff @(posedge clk)
begin
    if (reset_n)
    begin
        assert (!(avl_write_req && avl_read_req)) else $error ("Illegal Avalon input");
    end
end
// synthesis translate_on


endmodule

