`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_base_addr_selector #(
   parameter AXI_ADDR_W = 0,     // Number of bits in AXI address bus
   parameter MEM_ADDR_W = 0,     // Number of memory addressable bits
   parameter N_CONNECTIONS = 0   // Number of connections/buses to the external memory (each will have its own address zone)
) (
   input  [N_CONNECTIONS*AXI_ADDR_W-1:0] axi_awaddr_i,
   input  [N_CONNECTIONS*AXI_ADDR_W-1:0] axi_araddr_i,
   output [N_CONNECTIONS*AXI_ADDR_W-1:0] axi_awaddr_o,
   output [N_CONNECTIONS*AXI_ADDR_W-1:0] axi_araddr_o
);

   localparam ZONE_BITS = $clog2(N_CONNECTIONS); // Number of bits to use for address zone selection

   genvar i;

   generate
      for (i = 0; i < N_CONNECTIONS; i++)
         // Connect non-zone (lower) bits
         assign axi_awaddr_o[i*AXI_ADDR_W+:(MEM_ADDR_W-ZONE_BITS)] = axi_awaddr_i[i*AXI_ADDR_W+:(MEM_ADDR_W-ZONE_BITS)];
         // Connect zone bits, inverting them according to the zone.
         assign axi_awaddr_o[i*AXI_ADDR_W+(MEM_ADDR_W-ZONE_BITS)+:ZONE_BITS] = axi_awaddr_i[i*AXI_ADDR_W+(MEM_ADDR_W-ZONE_BITS)+:ZONE_BITS] ^ i;
         // Connect unused (higher) bits to ground
         assign axi_awaddr_o[i*AXI_ADDR_W+MEM_ADDR_W+:AXI_ADDR_W-MEM_ADDR_W] = 0;
   endgenerate

endmodule
