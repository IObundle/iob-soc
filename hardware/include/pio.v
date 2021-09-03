   // REGFILEIF
   input                           regfileif_valid,
   input [`REGFILEIF_ADDR_W-1:0]   regfileif_address,
   input [`REGFILEIF_DATA_W-1:0]   regfileif_wdata,
   input [`REGFILEIF_DATA_W/8-1:0] regfileif_wstrb,
   output [`REGFILEIF_DATA_W-1:0]  regfileif_rdata,
   output                          regfileif_ready,
