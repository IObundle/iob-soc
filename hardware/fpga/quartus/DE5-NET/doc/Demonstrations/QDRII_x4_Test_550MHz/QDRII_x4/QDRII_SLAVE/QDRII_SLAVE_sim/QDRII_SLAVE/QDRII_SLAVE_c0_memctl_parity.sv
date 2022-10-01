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

module QDRII_SLAVE_c0_memctl_parity(
	wdata_in,
	wdata_out,
	rdata_valid,
	rdata_in,
	rdata_out,
	parity_error
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter NUM_BYTES			= "";
parameter ENCODED_DWIDTH	= "";
parameter DECODED_DWIDTH	= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input	[DECODED_DWIDTH-1:0]	wdata_in;
output	[ENCODED_DWIDTH-1:0]	wdata_out;
input							rdata_valid;
input	[ENCODED_DWIDTH-1:0]	rdata_in;
output	[DECODED_DWIDTH-1:0]	rdata_out;
output	[NUM_BYTES-1:0]			parity_error;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

genvar i;
generate
for (i = 0; i < NUM_BYTES; i++)
begin : parity_gen
	// encode
	assign wdata_out[(i+1)*9-2:i*9] = wdata_in[(i+1)*8-1:i*8];
	assign wdata_out[(i+1)*9-1] = ^(wdata_in[(i+1)*8-1:i*8]);

	// decode
	assign rdata_out[(i+1)*8-1:i*8] = rdata_in[(i+1)*9-2:i*9];
	assign parity_error[i] = rdata_valid & (^(rdata_in[(i+1)*9-1:i*9]));
end
endgenerate


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (DECODED_DWIDTH == NUM_BYTES*8) else $error ("Parity width mismatch");
	assert (ENCODED_DWIDTH == NUM_BYTES*9) else $error ("Parity width mismatch");
end
// synthesis translate_on


endmodule

