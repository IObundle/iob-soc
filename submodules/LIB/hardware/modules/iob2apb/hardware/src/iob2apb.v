`timescale 1ns / 1ps


//
// IOb slave interface to APB master interface
//

module iob2apb #(
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

   //APB outputs
   reg apb_enable;
   assign apb_sel_o = apb_enable;
   assign apb_enable_o = apb_enable;
   
   assign apb_addr_o = iob_addr_i;
   assign apb_wstrb_o = iob_wstrb_i;
   assign apb_write_o = |iob_wstrb_i;
   
 

   //IOb outputs
   reg [DATA_W-1:0]     iob_rdata_nxt;
   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) iob_rdata_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(iob_rdata_nxt),
      .data_o(iob_rdata_o)
   );

   reg                  iob_ready;
   assign iob_ready_o = iob_ready;

   reg                  iob_rvalid;
   assign iob_rvalid_o = iob_rvalid;

   //program counter
   wire [1:0]           pc;
   reg [1:0]            pc_nxt;
   iob_reg #(
      .DATA_W (2),
      .RST_VAL(0)
   ) access_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(pc_nxt),
      .data_o(pc)
   );

  

   always @* begin

      pc_nxt         = pc + 1'b1;

      apb_enable = 1'b0;
      iob_rdata_nxt  = iob_rdata_o;
      iob_rvalid  = 1'b0;
      iob_ready   = 1'b0;
      
      case (pc)
        0: begin
           if (!iob_valid_i)  //wait for iob request
             pc_nxt = pc;
           else begin  // sample iob signals and initiate apb transaction
              apb_enable = 1'b1;
           end
        end // case: 0
        1: begin // wait for apb_ready
           apb_enable = 1'b1;
           if (!apb_ready_i) begin
             pc_nxt = pc;
           end else begin
              iob_ready = 1'b1;
              if (!iob_wstrb_i) begin // wait for iob_ready
                 iob_rdata_nxt = apb_rdata_i;
              end
           end
        end
        default: begin // read case: assert iob_rvalid and terminate transaction
           pc_nxt         = 0;
           iob_rvalid   = 1'b1;
        end
      endcase
   end

endmodule
