`timescale 1ns / 1ps

`include "iob_soc_tester_conf.vh"

module sram #(
              parameter DATA_W=`IOB_SOC_TESTER_DATA_W,
              parameter SRAM_ADDR_W = `IOB_SOC_TESTER_SRAM_ADDR_W,
              parameter HEXFILE = "none"
	      )
   (
    input                    clk_i,
    input                    rst_i,

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
    output reg              d_ready
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
      .din_i  (wdata),
      .dout_o (rdata)
      );
`else
   iob_ram_dp_be
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(SRAM_ADDR_W-2),
       .DATA_W(DATA_W)
       )
   main_mem_byte
     (
      .clk_i   (clk_i),

      // data port
      .enA_i   (d_avalid),
      .addrA_i (d_addr),
      .weA_i   (d_wstrb),
      .dA_i  (d_wdata),
      .dA_o (d_rdata),

      // instruction port
      .enB_i   (i_avalid),
      .addrB_i (i_addr),
      .weB_i   (i_wstrb),
      .dB_i  (i_wdata),
      .dB_o (i_rdata)
      );
`endif
  // reply with ready 
  always @(posedge clk_i, posedge rst_i)
    if(rst_i) begin
      d_rvalid <= 1'b0;
      i_rvalid <= 1'b0;
      d_ready  <= 1'b1;
      i_ready  <= 1'b1;
    end else begin 
      d_rvalid <= d_avalid;
      i_rvalid <= i_avalid;
    end
endmodule
