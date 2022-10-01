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


//////////////////////////////////////////////////////////////////////////////
// The data interface module controls the Avalon interface by accepting
// requests when the controller is ready, and putting the Avalon bus into a
// wait state when the controller is busy by deasserting 'avl_ready'.  This
// module also breaks Avalon bursts into individual memory requests by
// generating sequential addresses for each beat of the burst.
//////////////////////////////////////////////////////////////////////////////

module QDRII_SLAVE_c0_memctl_data_if(
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
    next_cmd1_addr,
    cmd1_addr_can_merge,
    cmd1_wdata,
    rdata_valid,
    rdata,
    pop_req
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon interface parameters
parameter AVL_ADDR_WIDTH    = "";
parameter AVL_SIZE_WIDTH    = "";
parameter AVL_DWIDTH        = "";
parameter BEATADDR_WIDTH    = "";

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
output  [AVL_ADDR_WIDTH-1:0]        next_cmd1_addr;
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
reg [1:0]                           cmd1_write_req_dup_reg /* synthesis dont_merge */;
reg [1:0]                           cmd1_read_req_dup_reg /* synthesis dont_merge */;

assign cmd1_write_req = cmd1_write_req_dup_reg[0];
assign cmd1_read_req = cmd1_read_req_dup_reg[0];

reg [AVL_ADDR_WIDTH-1:0]            cmd1_addr;
reg                                 cmd1_addr_can_merge;

logic [AVL_ADDR_WIDTH-1:0]			next_cmd1_addr;
logic [1:0]							next_cmd1_write_req;
logic [1:0]							next_cmd1_read_req;

reg [AVL_SIZE_WIDTH-1:0]            beats_left;
reg [AVL_DWIDTH-1:0]                cmd1_wdata;

// Wires
wire                                next_cmd1_addr_can_merge;
reg                                 cmd1_valid;
reg									state_normal_or_write_burst;

assign local_init_done = init_complete & ~init_fail;
// Command valid
always_ff @(posedge clk, negedge reset_n)
begin
	if (!reset_n) begin
		cmd1_valid <= 1'b0;
	end else begin
		cmd1_valid <= next_cmd1_write_req[1] ^ next_cmd1_read_req[1];
	end
end

// Connect Avalon signals
assign avl_ready = (reset_n) & (state_normal_or_write_burst) & ~(cmd1_valid & ~pop_req) & (local_init_done);
assign avl_rdata_valid = rdata_valid;
assign avl_rdata = rdata;

// Merging is not possible with a burst length of 1
assign next_cmd1_addr_can_merge = 1'b0;



always_comb
begin
	next_cmd1_addr <= cmd1_addr;
	case (state)
		INIT:
			next_cmd1_addr <= '0;
		NORMAL:
			if (avl_ready)
				next_cmd1_addr <= avl_addr;
		WRITE_BURST:
			if (avl_ready)
				if (avl_write_req && !avl_read_req)
					next_cmd1_addr <= cmd1_addr + 1'b1;
		READ_BURST:
				if (pop_req)
					next_cmd1_addr <= cmd1_addr + 1'b1;
		default:
			next_cmd1_addr <= cmd1_addr;								
	endcase
end

always_comb
begin
	next_cmd1_write_req <= cmd1_write_req_dup_reg;
	next_cmd1_read_req <= cmd1_read_req_dup_reg;
	
	case (state)
		NORMAL:
			if (avl_ready) begin
				next_cmd1_write_req <= {2{avl_write_req}};
				next_cmd1_read_req <= {2{avl_read_req}};
			end
		WRITE_BURST:
			if (avl_ready) begin
				next_cmd1_write_req <= {2{avl_write_req}};
				next_cmd1_read_req <= {2{avl_read_req}};	
			end
		READ_BURST:
			if (pop_req) begin
				next_cmd1_write_req <= 2'b00;
				next_cmd1_read_req <= 2'b11;
			end
		default:
		begin
			next_cmd1_write_req <= cmd1_write_req_dup_reg;
			next_cmd1_read_req <= cmd1_read_req_dup_reg;
		end	
	endcase
end

// Avalon signal capturing state machine
always_ff @(posedge clk, negedge reset_n)
begin
    if (!reset_n) begin
        state_normal_or_write_burst <= 1'b0;
        state <= RESET_STATE;
        cmd1_write_req_dup_reg <= 2'b00;
        cmd1_read_req_dup_reg <= 2'b00;
        cmd1_addr <= '0;
        cmd1_addr_can_merge <= '0;
        beats_left <= '0;
    end
    else
    begin

        state_normal_or_write_burst <= state_normal_or_write_burst;
        state <= state;
        cmd1_write_req_dup_reg <= next_cmd1_write_req;
        cmd1_read_req_dup_reg <= next_cmd1_read_req;
        cmd1_addr <= next_cmd1_addr;
        cmd1_addr_can_merge <= cmd1_addr_can_merge;
        beats_left <= beats_left;

        case (state)
            RESET_STATE:
                begin
                    state <= INIT;
                    state_normal_or_write_burst <= 1'b0;
                end

            INIT:
                begin
                    cmd1_wdata <= '0;
                    beats_left <= '0;

                    if (local_init_done) begin
                        state <= NORMAL;
                        state_normal_or_write_burst <= 1'b1;
                    end
                end
            NORMAL:
                // Capture the request from the Avalon interface
                if (avl_ready)
                begin
                    cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                    beats_left <= avl_size;
                    cmd1_wdata <= avl_wdata;

                    if (avl_size > 1)
                    begin
                        if (avl_write_req && !avl_read_req) begin
                            state <= WRITE_BURST;
                            state_normal_or_write_burst <= 1'b1;
                        end else if (avl_read_req && !avl_write_req) begin
                            state <= READ_BURST;
                            state_normal_or_write_burst <= 1'b0;
                        end
                    end
                end

            WRITE_BURST:
                // Capture the request from the Avalon interface and
                // increment the address for the current write burst
                if (avl_ready)
                begin
                    cmd1_wdata <= avl_wdata;

                    if (avl_write_req && !avl_read_req)
                    begin
                        cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                        beats_left <= beats_left - 1'b1;

                        if (beats_left == 2) begin
                            state <= NORMAL;
                            state_normal_or_write_burst <= 1'b1;
                        end
                    end
                end

            READ_BURST:
                // Issue read request with incrementing address for current read burst
                if (pop_req)
                begin
                    cmd1_addr_can_merge <= next_cmd1_addr_can_merge;
                    beats_left <= beats_left - 1'b1;

                    if (beats_left == 2) begin
                        state <= NORMAL;
                        state_normal_or_write_burst <= 1'b1;
                    end
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

