`timescale 1ns/1ps
`include "iob_utils.vh"
`include "iob_regfileif_conf.vh"
`include "iob_regfileif_swreg_def.vh"

module iob_regfileif # (
     `include "iob_regfileif_params.vs"
   ) (
     `include "iob_regfileif_io.vs"
   );

   `include "iob_wire.vs"

   assign iob_avalid = iob_avalid_i;
   assign iob_addr = iob_addr_i;
   assign iob_wdata = iob_wdata_i;
   assign iob_wstrb = iob_wstrb_i;
   assign iob_rvalid_o = iob_rvalid;
   assign iob_rdata_o = iob_rdata;
   assign iob_ready_o = iob_ready;

   //Dummy iob_ready_nxt and iob_rvalid_nxt to be used in swreg (unused ports)
   wire iob_ready_nxt;
   wire iob_rvalid_nxt;

  //BLOCK Register File & Configuration control and status register file.
  `include "iob_regfileif_inverted_swreg_inst.vs"
  `include "iob_regfileif_swreg_inst.vs" //This file is modified by python scripts to have correct mapping with iob_regfileif_inverted_swreg_inst.vs

endmodule
