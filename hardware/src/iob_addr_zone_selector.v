`timescale 1 ns / 1 ps

module iob_addr_zone_selector #(
   parameter ADDR_W = 0,  // Number of bits in address bus
   parameter MEM_ADDR_W = 0,  // Number of memory addressable bits
   parameter N_CONNECTIONS = 0   // Number of connections/buses to the external memory (each will have its own address zone)
) (
   input  [N_CONNECTIONS*ADDR_W-1:0] addr_i,
   output [N_CONNECTIONS*ADDR_W-1:0] addr_o
);

   localparam ZONE_BITS = $clog2(
       N_CONNECTIONS
   );  // Number of bits to use for address zone selection

   genvar i;

   generate
      for (i = 0; i < N_CONNECTIONS; i++) begin : bit_inverter
         // Connect non-zone (lower) bits
         assign addr_o[i*ADDR_W+:(MEM_ADDR_W-ZONE_BITS)] = addr_i[i*ADDR_W+:(MEM_ADDR_W-ZONE_BITS)];
         // Connect zone bits, inverting them according to the zone.
         if (ZONE_BITS > 0)
            assign addr_o[i*ADDR_W+(MEM_ADDR_W-ZONE_BITS)+:ZONE_BITS] = addr_i[i*ADDR_W+(MEM_ADDR_W-ZONE_BITS)+:ZONE_BITS] ^ i;
         // Connect unused (higher) bits to ground
         if ((ADDR_W - MEM_ADDR_W) > 0) assign addr_o[i*ADDR_W+MEM_ADDR_W+:(ADDR_W-MEM_ADDR_W)] = 0;
      end
   endgenerate

endmodule
