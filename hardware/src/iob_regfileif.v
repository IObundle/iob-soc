`timescale 1ns/1ps
`include "iob_utils.vh"
`include "iob_regfileif_conf.vh"
`include "iob_regfileif_swreg_def.vh"

module iob_regfileif # (
     `include "iob_regfileif_params.vs"
   ) (
     `include "iob_regfileif_io.vs"
   );

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt_o;
   wire iob_rvalid_nxt_o;

  //BLOCK Register File & Configuration control and status register file.
  `include "iob_regfileif_inverted_swreg_inst.vs"
  `include "iob_regfileif_swreg_inst.vs" //This file is modified by python scripts to have correct mapping with iob_regfileif_inverted_swreg_inst.vs

endmodule
