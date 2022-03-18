
`timescale 1ns/1ps

`include "iob_lib.vh"
`include "iob_nativebridgeif.vh"

module iob_nativebridgeif
  # (
     parameter ADDR_W = `NATIVEBRIDGEIF_ADDR_W,
     parameter DATA_W = `NATIVEBRIDGEIF_DATA_W,
     parameter WDATA_W = `NATIVEBRIDGEIF_DATA_W
     )
   (

    // CPU interface
    `INPUT(valid,   1),
    `INPUT(address, ADDR_W),
    `INPUT(wdata,   WDATA_W),
    `INPUT(wstrb,   WDATA_W/8),
    `OUTPUT(rdata,  DATA_W),
    `OUTPUT(ready,  1),

    // External interface
    `OUTPUT(valid_ext,   1),
    `OUTPUT(address_ext, ADDR_W),
    `OUTPUT(wdata_ext,   WDATA_W),
    `OUTPUT(wstrb_ext,   WDATA_W/8),
    `INPUT(rdata_ext,  DATA_W),
    `INPUT(ready_ext,  1),


    `INPUT(clk,  1),
    `INPUT(rst,  1)
    );

    // Connect interfaces
    assign valid_ext = valid;
    assign address_ext = address;
    assign wdata_ext = wdata;
    assign wstrb_ext = wstrb;
    assign rdata = rdata_ext;
    assign ready = ready_ext;

endmodule
    