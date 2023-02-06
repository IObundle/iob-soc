`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_regfileif_conf.vh"
`include "iob_regfileif_swreg_def.vh"

module iob_regfileif # (
     `include "iob_regfileif_params.vh"
   ) (
     `include "iob_regfileif_io.vh"
   );

	// This mapping is required because "iob_regfileif_inverted_swreg_inst.vh" uses "iob_s_portmap.vh" (This would not be needed if mkregs used "iob_s_s_portmap.vh" instead)
	wire [1-1:0] iob_avalid = iob_avalid_i; //Request valid.
	wire [ADDR_W-1:0] iob_addr = iob_addr_i; //Address.
	wire [DATA_W-1:0] iob_wdata = iob_wdata_i; //Write data.
	wire [(DATA_W/8)-1:0] iob_wstrb = iob_wstrb_i; //Write strobe.
	wire [1-1:0] iob_rvalid; assign iob_rvalid_o = iob_rvalid; //Read data valid.
	wire [DATA_W-1:0] iob_rdata; assign iob_rdata_o = iob_rdata; //Read data.
	wire [1-1:0] iob_ready; assign iob_ready_o = iob_ready; //Interface ready.

	//BLOCK Register File & Configuration control and status register file.
	`include "iob_regfileif_inverted_swreg_inst.vh"
	`include "iob_regfileif_swreg_inst.vh" //This file is modified by python scripts to have correct mapping with iob_regfileif_inverted_swreg_inst.vh

endmodule
