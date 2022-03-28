
`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_nativebridgeif_swreg_def.vh"

module iob_nativebridgeif
  # (
     parameter DATA_W = `DATA_W,
     parameter ADDR_W = `iob_nativebridgeif_swreg_ADDR_W
     )
   (

    // CPU interface
`include "iob_s_if.vh"

    // External interface
    `IOB_OUTPUT(valid_ext,   1),
    `IOB_OUTPUT(address_ext, ADDR_W),
    `IOB_OUTPUT(wdata_ext,   DATA_W),
    `IOB_OUTPUT(wstrb_ext,   DATA_W/8),
    `IOB_INPUT(rdata_ext,  DATA_W),
    `IOB_INPUT(ready_ext,  1),


`include "gen_if.vh"
    );

    // Connect interfaces
    assign valid_ext = valid;
    assign address_ext = address;
    assign wdata_ext = wdata;
    assign wstrb_ext = wstrb;
    assign rdata = rdata_ext;
    assign ready = ready_ext;

endmodule
    