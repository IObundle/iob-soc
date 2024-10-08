// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

// A generic axi like handshake delay for testbenches. 
// For axi, the write and read cases are "different" in name usage.
// Use the modules below for axi connections
module axidelay #(
   parameter MAX_DELAY = 3
) (
   // Master interface. Connect to a slave interface
   output reg m_valid_o,
   input      m_ready_i,

   // Slave interface. Connect to a master interface
   input      s_valid_i,
   output reg s_ready_o,

   input clk_i,
   input rst_i
);

   generate
      if (MAX_DELAY == 0) begin
         always @* begin
            s_ready_o = m_ready_i;
            m_valid_o = s_valid_i;
         end
      end else begin
         reg [$clog2(MAX_DELAY):0] counter;
         always @(posedge clk_i, posedge rst_i) begin
            if (rst_i) begin
               counter <= 0;
            end else begin
               if (counter == 0 && m_valid_o && m_ready_i) begin
                  counter <= ($urandom % MAX_DELAY);
               end

               if (counter) counter <= counter - 1;
            end
         end

         always @* begin
            s_ready_o = 1'b0;
            m_valid_o = 1'b0;

            if (counter == 0) begin
               s_ready_o = m_ready_i;
               m_valid_o = s_valid_i;
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
   output m_rvalid_o,
   input  m_rready_i,

   // Connect directly to the same named axi read wires in the slave interface
   input  s_rvalid_i,
   output s_rready_o,

   input clk_i,
   input rst_i
);

   axidelay #(
      .MAX_DELAY(MAX_DELAY)
   ) Read (
      .s_valid_i(s_rvalid_i),
      .s_ready_o(s_rready_o),

      .m_valid_o(m_rvalid_o),
      .m_ready_i(m_rready_i),

      .clk_i(clk_i),
      .rst_i(rst_i)
   );

endmodule

// A simple interface change, make it easier to figure out the connections for the AXI Write case
// An AXI write is controlled by the master. No change to the default handshake
module axidelayWrite #(
   parameter MAX_DELAY = 3
) (
   // Connect directly to the same named axi write wires in the master interface
   input  m_wvalid_i,
   output m_wready_o,

   // Connect directly to the same named axi write wires in the slave interface
   output s_wvalid_o,
   input  s_wready_i,

   input clk_i,
   input rst_i
);

   axidelay #(
      .MAX_DELAY(MAX_DELAY)
   ) Write (
      .s_valid_i(m_wvalid_i),
      .s_ready_o(m_wready_o),

      .m_valid_o(s_wvalid_o),
      .m_ready_i(s_wready_i),

      .clk_i(clk_i),
      .rst_i(rst_i)
   );

endmodule
