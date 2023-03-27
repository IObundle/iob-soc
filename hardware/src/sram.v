`timescale 1ns / 1ps
`include "iob_soc_conf.vh"
`include "bsp.vh"

module sram #(
              parameter DATA_W=`IOB_SOC_DATA_W,
              parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W,
              parameter HEXFILE = "none"
	      )
   (
    // intruction bus
    input                   i_avalid,
    input [SRAM_ADDR_W-3:0] i_addr,
    input [DATA_W-1:0]      i_wdata, //used for booting
    input [DATA_W/8-1:0]    i_wstrb, //used for booting
    output [DATA_W-1:0]     i_rdata,
    output reg              i_rvalid,
    output reg              i_ready,

    // data bus
    input                   d_avalid,
    input [SRAM_ADDR_W-3:0] d_addr,
    input [DATA_W-1:0]      d_wdata,
    input [DATA_W/8-1:0]    d_wstrb,
    output [DATA_W-1:0]     d_rdata,
    output reg              d_rvalid,
    output reg              d_ready,

    `include "iob_clkenrst_port.vh"
    );

`ifdef USE_SPRAM

   wire                   d_avalid_int = i_avalid? 1'b0: d_avalid;
   wire                   avalid = i_avalid? i_avalid: d_avalid;
   wire [SRAM_ADDR_W-3:0] addr   = i_avalid? i_addr: d_addr;
   wire [DATA_W-1:0]      wdata  = i_avalid? i_wdata: d_wdata;
   wire [DATA_W/8-1:0]    wstrb  = i_avalid? i_wstrb: d_wstrb;
   wire [DATA_W-1:0]      rdata;
   assign d_rdata = rdata;
   assign i_rdata = rdata;

   iob_ram_sp_be
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(SRAM_ADDR_W-2),
       .DATA_W(DATA_W)
       )
   main_mem_byte
     (
      .clk_i   (clk_i),

      // data port
      .en_i   (avalid),
      .addr_i (addr),
      .we_i   (wstrb),
      .d_i  (wdata),
      .dt_o (rdata)
      );
`else // !`ifdef USE_SPRAM
 `ifdef MEM_NO_READ_ON_WRITE
   iob_ram_dp_be
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(SRAM_ADDR_W-2),
       .DATA_W(DATA_W),
       .MEM_NO_READ_ON_WRITE(1)
       )
   main_mem_byte
     (
      .clk_i   (clk_i),

      // data port
      .enA_i (d_avalid),
      .addrA_i (d_addr),
      .weA_i (d_wstrb),
      .dA_i (d_wdata),
      .dA_o (d_rdata),

      // instruction port
      .enB_i   (i_avalid),
      .addrB_i (i_addr),
      .weB_i   (i_wstrb),
      .dB_i  (i_wdata),
      .dB_o (i_rdata)
      );
 `else // !`ifdef MEM_NO_READ_ON_WRITE
   iob_ram_dp_be_xil
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(SRAM_ADDR_W-2),
       .DATA_W(DATA_W)
       )
   main_mem_byte
     (
      .clk_i   (clk_i),

      // data port
      .enA_i (d_avalid),
      .addrA_i (d_addr),
      .weA_i (d_wstrb),
      .dA_i (d_wdata),
      .dA_o (d_rdata),

      // instruction port
      .enB_i (i_avalid),
      .addrB_i (i_addr),
      .weB_i (i_wstrb),
      .dB_i (i_wdata),
      .dB_o (i_rdata)
      );   
 `endif
`endif

  // reply with ready 

  iob_reg #(1,0) i_rvalid_reg (clk_i, arst_i, cke_i, i_avalid & ~(| i_wstrb), i_rvalid);
  iob_reg #(1,0) d_rvalid_reg (clk_i, arst_i, cke_i, d_avalid & ~(| d_wstrb), d_rvalid);
  assign i_ready = 1'b1; // SRAM ready is supposed to always be 1 since requests can be continuous
  assign d_ready = 1'b1;

endmodule
