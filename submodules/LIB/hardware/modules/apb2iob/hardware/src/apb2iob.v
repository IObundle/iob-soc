`timescale 1ns / 1ps


//
// APB slave port to IOb master interface

module apb2iob #(
   parameter APB_ADDR_W = 21,          // APB address bus width in bits
   parameter APB_DATA_W = 21,          // APB data bus width in bits
   parameter ADDR_W     = APB_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W     = APB_DATA_W   // IOb data bus width in bits
) (
   // Global signals
   `include "clk_en_rst_s_port.vs"

   // APB slave interface
   `include "apb_s_port.vs"

   // IOb master interface
   `include "iob_m_port.vs"
);
   localparam WSTRB_W = DATA_W / 8;

   reg apb_ready_nxt;
   reg iob_valid;
   assign iob_valid_o = iob_valid;

   assign iob_addr_o   = apb_addr_i;
   assign iob_wdata_o  = apb_wdata_i;
   assign iob_wstrb_o  = apb_write_i ? apb_wstrb_i : {WSTRB_W{1'b0}};

   //program counter
   wire [1:0]           pc;
   reg [1:0]            pc_nxt;
   iob_reg #(
      .DATA_W (2),
      .RST_VAL(2'd0)
   ) access_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(pc_nxt),
      .data_o(pc)
   );

   always @* begin

      pc_nxt         = pc + 1'b1;
      iob_valid      = 1'b0;
      apb_ready_nxt  = 1'b0;

      case (pc)
        0: begin
           if(!(apb_sel_i & apb_enable_i)) begin
              pc_nxt = pc;
           end else begin
              iob_valid     = 1'b1;
           end
        end
        1: begin
           iob_valid     = 1'b1;
           if(!iob_ready_i) begin
              pc_nxt = pc;
           end else begin
              if(apb_write_i) begin
                 apb_ready_nxt = 1'b1;
                 pc_nxt = 2'd3;
              end
           end
        end
        2: begin
           if (!iob_rvalid_i) begin
              pc_nxt = pc;
           end else begin
              apb_ready_nxt = 1'b1;
           end
        end
        default: begin
           pc_nxt = 2'd0;
        end
      endcase
   end // always @ *
   

  //APB outputs regs
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) apb_ready_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(apb_ready_nxt),
      .data_o(apb_ready_o)
   );

   iob_reg_e #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) apb_rdata_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .en_i(iob_rvalid_i),
      .data_i(iob_rdata_i),
      .data_o(apb_rdata_o)
   );


endmodule
