`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_regfileif_swreg_def.vh"

module iob_regfileif 
  # (
     parameter DATA_W = `DATA_W,
     parameter ADDR_W = `iob_regfileif_swreg_ADDR_W
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs
   `IOB_INPUT(valid_ext,   1),
   `IOB_INPUT(address_ext, ADDR_W),
   `IOB_INPUT(wdata_ext,   DATA_W),
   `IOB_INPUT(wstrb_ext,   DATA_W/8),
   `IOB_OUTPUT(rdata_ext,  DATA_W),
   `IOB_OUTPUT(ready_ext,  1),
`include "iob_gen_if.vh"
   );

// BLOCK Register File & Holds the current configuration of the system as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
`include "iob_regfileif_swreg_gen.vh"
`include "iob_regfileif_inverted_swreg_gen.vh"
`include "iob_regfileif_swreg_wire_connections.vh"
endmodule
