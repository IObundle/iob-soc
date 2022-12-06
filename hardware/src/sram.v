`timescale 1ns / 1ps
`include "iob_soc.vh"

module sram #(
              parameter DATA_W=`IOB_SOC_DATA_W,
              parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W,
              parameter HEXFILE = "none"
	      )
   (
    input                    clk_i,
    input                    rst_i,

    // intruction bus
    input                    i_valid,
    input [SRAM_ADDR_W-3:0] i_addr,
    input [DATA_W-1:0]      i_wdata, //used for booting
    input [DATA_W/8-1:0]    i_wstrb, //used for booting
    output [DATA_W-1:0]     i_rdata,
    output reg               i_ready,

    // data bus
    input                    d_valid,
    input [SRAM_ADDR_W-3:0] d_addr,
    input [DATA_W-1:0]      d_wdata,
    input [DATA_W/8-1:0]    d_wstrb,
    output [DATA_W-1:0]     d_rdata,
    output reg               d_ready
    );

`ifdef USE_SPRAM

   wire                     d_valid_int = i_valid? 1'b0: d_valid;
   wire                     valid = i_valid? i_valid: d_valid;
   wire [SRAM_ADDR_W-3:0]  addr  = i_valid? i_addr: d_addr;
   wire [DATA_W-1:0]       wdata = i_valid? i_wdata: d_wdata;
   wire [DATA_W/8-1:0]     wstrb = i_valid? i_wstrb: d_wstrb;
   wire [DATA_W-1:0]       rdata;
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
      .en_i   (valid),
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
      .enA_i   (d_valid),
      .addrA_i (d_addr),
      .weA_i   (d_wstrb),
      .dA_i  (d_wdata),
      .dA_o (d_rdata),

      // instruction port
      .enB_i   (i_valid),
      .addrB_i (i_addr),
      .weB_i   (i_wstrb),
      .dB_i  (i_wdata),
      .dB_o (i_rdata)
      );
`endif
   // reply with ready 
   always @(posedge clk_i, posedge rst_i)
     if(rst_i) begin
	    d_ready <= 1'b0;
	    i_ready <= 1'b0;
     end else begin 
	    d_ready <= d_valid;
	    i_ready <= i_valid;
     end
endmodule
