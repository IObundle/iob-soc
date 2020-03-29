`timescale 1 ns / 1 ps
`include "system.vh"

module addr_transf
  (
   input                      boot,
   input [`ADDR_W-1 : 0]      addr_in,
   output reg [`ADDR_W-1 : 0] addr_out
   );
          
   always @*
     if(!addr_in[`ADDR_W-1 -: `N_SLAVES_W])
       //main memory is being addressed
       if(boot)
         addr_out = addr_in + 2**`BOOTRAM_ADDR_W - 2**`BOOTROM_ADDR_W;
       else
`ifdef USE_DDR
          addr_out = {`N_SLAVES_W'd`CACHE_BASE, addr_in[`ADDR_W-`N_SLAVES_W-1:0]};
`else
          addr_out = addr_in;
`endif
     else
       addr_out = addr_in;

endmodule
