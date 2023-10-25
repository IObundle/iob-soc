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
   output [         1-1:0] iob_avalid_o,      //Request valid.
   output [    ADDR_W-1:0] iob_addr_o,        //Address.
   output [    DATA_W-1:0] iob_wdata_o,       //Write data.
   output [(DATA_W/8)-1:0] iob_wstrb_o,       //Write strobe.
   input  [         1-1:0] iob_rvalid_nxt_i,  //Read data valid.
   input  [    DATA_W-1:0] iob_rdata_i,       //Read data.
   input  [         1-1:0] iob_ready_nxt_i   //Interface ready.
);


   // APB outputs
   reg apb_ready_nxt;

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b0),
      .CLKEDGE("posedge")
   ) apb_ready_reg_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(apb_ready_nxt),
      .data_o(apb_ready_o)
   );

   assign apb_rdata_o = iob_rdata_i;

   wire pc;
   reg  pc_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b0),
      .CLKEDGE("posedge")
   ) pc_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(pc_nxt),
      .data_o(pc)
   );

   always @* begin

      pc_nxt        = pc + 1'b1;
      apb_ready_nxt = apb_write_i ? iob_ready_nxt_i : iob_rvalid_nxt_i;

      case (pc)
         0: begin
            if (!apb_sel_i) begin  //wait periph selection
               pc_nxt        = pc;
               apb_ready_nxt = 1'd0;
            end
         end

         default: begin
            if (apb_enable_i && !apb_ready_o)  //wait periph ready
               pc_nxt = pc;
         end
      endcase
   end

   assign iob_avalid_o = pc;
   assign iob_addr_o   = apb_addr_i;
   assign iob_wdata_o  = apb_wdata_i;
   assign iob_wstrb_o  = apb_wstrb_i;

endmodule
