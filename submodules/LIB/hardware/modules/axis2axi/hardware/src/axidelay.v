`timescale 1ns / 1ps

// A generic axi like handshake delay for testbenches. 
// For axi, the write and read cases are "different" in name usage.
// Use the modules below for axi connections
module axidelay #(
   parameter MAX_DELAY = 3
) (
   // Master interface. Connect to a slave interface
   output reg m_valid,
   input      m_ready,

   // Slave interface. Connect to a master interface
   input      s_valid,
   output reg s_ready,

   input clk,
   input rst
);

   generate
      if (MAX_DELAY == 0) begin
         always @* begin
            s_ready = m_ready;
            m_valid = s_valid;
         end
      end else begin
         reg [$clog2(MAX_DELAY):0] counter;
         always @(posedge clk, posedge rst) begin
            if (rst) begin
               counter <= 0;
            end else begin
               if (counter == 0 && m_valid && m_ready) begin
                  counter <= ($urandom % MAX_DELAY);
               end

               if (counter) counter <= counter - 1;
            end
         end

         always @* begin
            s_ready = 1'b0;
            m_valid = 1'b0;

            if (counter == 0) begin
               s_ready = m_ready;
               m_valid = s_valid;
            end
         end
      end
   endgenerate

endmodule

// A simple interface change, make it easier to figure out the connections for the AXI Read case
// An AXI read is controlled by the slave. The AXI slave is the master of the Read channel
module axidelayRead #(
   parameter MAX_DELAY = 3
) (
   // Connect directly to the same named axi read wires in the master interface
   output m_rvalid,
   input  m_rready,

   // Connect directly to the same named axi read wires in the slave interface
   input  s_rvalid,
   output s_rready,

   input clk,
   input rst
);

   axidelay #(
      .MAX_DELAY(MAX_DELAY)
   ) Read (
      .s_valid(s_rvalid),
      .s_ready(s_rready),

      .m_valid(m_rvalid),
      .m_ready(m_rready),

      .clk(clk),
      .rst(rst)
   );

endmodule

// A simple interface change, make it easier to figure out the connections for the AXI Write case
// An AXI write is controlled by the master. No change to the default handshake
module axidelayWrite #(
   parameter MAX_DELAY = 3
) (
   // Connect directly to the same named axi write wires in the master interface
   input  m_wvalid,
   output m_wready,

   // Connect directly to the same named axi write wires in the slave interface
   output s_wvalid,
   input  s_wready,

   input clk,
   input rst
);

   axidelay #(
      .MAX_DELAY(MAX_DELAY)
   ) Write (
      .s_valid(m_wvalid),
      .s_ready(m_wready),

      .m_valid(s_wvalid),
      .m_ready(s_wready),

      .clk(clk),
      .rst(rst)
   );

endmodule
