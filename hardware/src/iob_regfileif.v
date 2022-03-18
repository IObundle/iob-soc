`timescale 1ns/1ps

`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_regfileif.vh"
// `include "REGFILEIFsw_reg.vh"

module iob_regfileif 
  # (
     parameter ADDR_W = `REGFILEIF_ADDR_W,
     parameter DATA_W = `REGFILEIF_DATA_W,
     parameter WDATA_W = `REGFILEIF_DATA_W
     )
   (

   // CPU interface
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

    // additional inputs and outputs
    `INPUT(valid_ext,   1),
    `INPUT(address_ext, ADDR_W),
    `INPUT(wdata_ext,   WDATA_W),
    `INPUT(wstrb_ext,   WDATA_W/8),
    `OUTPUT(rdata_ext,  DATA_W),
    `OUTPUT(ready_ext,  1),

`include "gen_if.v"
    );

	// BLOCK Register File & Holds the current configuration of the system as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
	`include "REGFILEIFsw_reg.v"
	`include "REGFILEIFsw_reg_inverted.v"
	`include "REGFILEIFsw_reg_gen.v"
	`include "REGFILEIFsw_reg_inverted_gen.v"
	`include "REGFILEIFsw_reg_wire_connections.v"

endmodule
