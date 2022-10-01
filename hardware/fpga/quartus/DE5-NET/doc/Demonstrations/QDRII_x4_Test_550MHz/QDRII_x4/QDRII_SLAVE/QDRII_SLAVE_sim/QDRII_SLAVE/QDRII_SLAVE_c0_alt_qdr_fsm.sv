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
// This is the main state machine of the QDR II/II+ Memory Controller.  It
// accepts user requests from the Avalon interface and issues memory commands
// while satisfying timing requirements.
//////////////////////////////////////////////////////////////////////////////

module QDRII_SLAVE_c0_alt_qdr_fsm(
	clk,
	reset_n,
	init_complete,
	init_fail,
	write_req,
	read_req,
	do_write,
	do_read
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input clk;
input reset_n;

// PHY initialization and calibration status
input init_complete;
input init_fail;

// User memory requests
input write_req;
input read_req;

// State machine command outputs
output do_write;
output do_read;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// FSM states
enum int unsigned {
	INIT,
	INIT_FAIL,
	INIT_COMPLETE
} state;


reg do_write;
reg do_read;


always_ff @(posedge clk, negedge reset_n)
begin
	if (!reset_n)
		begin
			state <= INIT;
		end
	else
		case(state)
			INIT :
				if (init_complete == 1'b1)
					state <= INIT_COMPLETE;
				else if (init_fail == 1'b1)
					state <= INIT_FAIL;
				else
					state <= INIT;
			INIT_FAIL :
				state <= INIT_FAIL;
			INIT_COMPLETE :
				state <= INIT_COMPLETE;
		endcase
end

always_comb
begin
	do_write <= 1'b0;
	do_read <= 1'b0;
	if (state == INIT_COMPLETE)
	begin
		if (write_req)
			do_write <= 1'b1;
		if (read_req)
			do_read <= 1'b1;
	end
end


endmodule

