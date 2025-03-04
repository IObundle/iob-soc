`timescale 1ns / 1ps


//
// IOb slave interface to APB master interface
//

module iob_iob2apb #(
   parameter APB_ADDR_W = 22,          // APB address bus width in bits
   parameter APB_DATA_W = 22,          // APB data bus width in bits
   parameter ADDR_W     = APB_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W     = APB_DATA_W   // IOb data bus width in bits
) (
   // Global signals
   `include "clk_en_rst_s_port.vs"

   // IOb slave interface
   `include "iob_s_port.vs"

   // APB master interface
   `include "apb_m_port.vs"
);

   localparam WAIT_VALID = 2'd0;
   localparam WAIT_READY = 2'd1;

   //IOb outputs
   assign iob_ready_o = apb_ready_i;

   //APB outputs
   reg apb_enable;
   assign apb_sel_o    = apb_enable;
   assign apb_enable_o = apb_enable;
   assign apb_wdata_o  = iob_wdata_i;

   assign apb_addr_o   = iob_addr_i;
   assign apb_wstrb_o  = iob_wstrb_i;
   assign apb_write_o  = |iob_wstrb_i;

   reg        iob_rvalid_nxt;

   //program counter
   wire [1:0] pc;
   reg  [1:0] pc_nxt;
   iob_reg #(
      .DATA_W (2),
      .RST_VAL(0)
   ) pc_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(pc_nxt),
      .data_o(pc)
   );

   always @* begin
      pc_nxt         = pc + 1'b1;
      apb_enable     = 1'b0;
      iob_rvalid_nxt = 1'b0;

      case (pc)
         WAIT_VALID: begin
            if (!iob_valid_i) begin
               pc_nxt = pc;
            end else begin
               apb_enable = 1'b1;
            end
         end
         WAIT_READY: begin
            apb_enable = 1'b1;
            if (!apb_ready_i) begin
               pc_nxt = pc;
            end else if (apb_write_o) begin  // No need to wait for rvalid
               pc_nxt = WAIT_VALID;
            end else begin
               iob_rvalid_nxt = 1'd1;
            end
         end
         default: begin // WAIT_RREADY
            if (iob_rready_i) begin
               pc_nxt = WAIT_VALID;
            end else begin
               iob_rvalid_nxt = iob_rvalid_o;
               pc_nxt         = pc;
            end
         end
      endcase
   end

   //IOb outputs
   iob_reg_e #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) iob_rdata_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .en_i  (apb_ready_i),
      .data_i(apb_rdata_i),
      .data_o(iob_rdata_o)
   );

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_rvalid_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(iob_rvalid_nxt),
      .data_o(iob_rvalid_o)
   );

endmodule
