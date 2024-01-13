`timescale 1ns / 1ps
`include "iob_soc_conf.vh"
`include "bsp.vh"

module iob_soc_sram #(
   parameter DATA_W      = `IOB_SOC_DATA_W,
   parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W,
   parameter HEXFILE     = "none"
) (
   // intruction bus
   input                        i_valid_i,
   input      [SRAM_ADDR_W-3:0] i_addr_i,
   input      [     DATA_W-1:0] i_wdata_i,   //used for booting
   input      [   DATA_W/8-1:0] i_wstrb_i,   //used for booting
   output     [     DATA_W-1:0] i_rdata_o,
   output                       i_rvalid_o,
   output                       i_ready_o,

   // data bus
   input                        d_valid_i,
   input      [SRAM_ADDR_W-3:0] d_addr_i,
   input      [     DATA_W-1:0] d_wdata_i,
   input      [   DATA_W/8-1:0] d_wstrb_i,
   output     [     DATA_W-1:0] d_rdata_o,
   output                       d_rvalid_o,
   output                       d_ready_o,

   `include "clk_en_rst_s_port.vs"
);

`ifdef USE_SPRAM

   wire d_valid_int = i_valid_i ? 1'b0 : d_valid_i;
   wire valid = i_valid_i ? i_valid_i : d_valid_i;
   wire [SRAM_ADDR_W-3:0] addr = i_valid_i ? i_addr_i : d_addr_i;
   wire [DATA_W-1:0] wdata = i_valid_i ? i_wdata_i : d_wdata_i;
   wire [DATA_W/8-1:0] wstrb = i_valid_i ? i_wstrb_i : d_wstrb_i;
   wire [DATA_W-1:0] rdata;
   assign d_rdata_o = rdata;
   assign i_rdata_o = rdata;

   iob_ram_sp_be #(
      .HEXFILE(HEXFILE),
      .ADDR_W (SRAM_ADDR_W - 2),
      .DATA_W (DATA_W)
   ) main_mem_byte (
      .clk_i(clk_i),

      // data port
      .en_i  (valid),
      .addr_i(addr),
      .we_i  (wstrb),
      .d_i   (wdata),
      .dt_o  (rdata)
   );
`else  // !`ifdef USE_SPRAM
`ifdef IOB_MEM_NO_READ_ON_WRITE
   iob_ram_dp_be #(
      .HEXFILE             (HEXFILE),
      .ADDR_W              (SRAM_ADDR_W - 2),
      .DATA_W              (DATA_W),
      .MEM_NO_READ_ON_WRITE(1)
   ) main_mem_byte (
      .clk_i(clk_i),

      // data port
      .enA_i  (d_valid_i),
      .addrA_i(d_addr_i),
      .weA_i  (d_wstrb_i),
      .dA_i   (d_wdata_i),
      .dA_o   (d_rdata_o),

      // instruction port
      .enB_i  (i_valid_i),
      .addrB_i(i_addr_i),
      .weB_i  (i_wstrb_i),
      .dB_i   (i_wdata_i),
      .dB_o   (i_rdata_o)
   );
`else  // !`ifdef IOB_MEM_NO_READ_ON_WRITE
   iob_ram_dp_be_xil #(
      .HEXFILE(HEXFILE),
      .ADDR_W (SRAM_ADDR_W - 2),
      .DATA_W (DATA_W)
   ) main_mem_byte (
      .clk_i(clk_i),

      // data port
      .enA_i  (d_valid_i),
      .addrA_i(d_addr_i),
      .weA_i  (d_wstrb_i),
      .dA_i   (d_wdata_i),
      .dA_o   (d_rdata_o),

      // instruction port
      .enB_i  (i_valid_i),
      .addrB_i(i_addr_i),
      .weB_i  (i_wstrb_i),
      .dB_i   (i_wdata_i),
      .dB_o   (i_rdata_o)
   );
`endif
`endif

   // reply with ready 
   wire i_rvalid_nxt;
   assign i_rvalid_nxt = i_valid_i & ~(|i_wstrb_i);

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) i_rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(i_rvalid_nxt),
      .data_o(i_rvalid_o)
   );

   wire d_rvalid_nxt;
   assign d_rvalid_nxt = d_valid_i & ~(|d_wstrb_i);

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) d_rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(d_rvalid_nxt),
      .data_o(d_rvalid_o)
   );
   assign i_ready_o = 1'b1;  // SRAM ready is supposed to always be 1 since requests can be continuous
   assign d_ready_o = 1'b1;

endmodule
