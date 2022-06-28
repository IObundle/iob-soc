`timescale 1ns / 1ps
`include "system.vh"

module sram #(
              parameter HEXFILE = "none"
	      )
   (
    input                    clk,
    input                    rst,

    // intruction bus
    input                    i_valid,
    input [`SRAM_ADDR_W-3:0] i_addr,
    input [`DATA_W-1:0]      i_wdata, //used for booting
    input [`DATA_W/8-1:0]    i_wstrb, //used for booting
    output [`DATA_W-1:0]     i_rdata,
    output reg               i_ready,

    // data bus
    input                    d_valid,
    input [`SRAM_ADDR_W-3:0] d_addr,
    input [`DATA_W-1:0]      d_wdata,
    input [`DATA_W/8-1:0]    d_wstrb,
    output [`DATA_W-1:0]     d_rdata,
    output reg               d_ready
    );

`ifdef USE_SPRAM

   wire                     d_valid_int = i_valid? 1'b0: d_valid;
   wire                     valid = i_valid? i_valid: d_valid;
   wire [`SRAM_ADDR_W-3:0]  addr  = i_valid? i_addr: d_addr;
   wire [`DATA_W-1:0]       wdata = i_valid? i_wdata: d_wdata;
   wire [`DATA_W/8-1:0]     wstrb = i_valid? i_wstrb: d_wstrb;
   wire [`DATA_W-1:0]       rdata;
   assign d_rdata = rdata;
   assign i_rdata = rdata;

   iob_ram_sp_be
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(`SRAM_ADDR_W-2),
       .DATA_W(`DATA_W)
       )
   main_mem_byte
     (
      .clk   (clk),

      // data port
      .en   (valid),
      .addr (addr),
      .we   (wstrb),
      .din  (wdata),
      .dout (rdata)
      );
`else
   iob_ram_dp_be
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(`SRAM_ADDR_W-2),
       .DATA_W(`DATA_W)
       )
   main_mem_byte
     (
      .clk   (clk),

      // data port
      .enA   (d_valid),
      .addrA (d_addr),
      .weA   (d_wstrb),
      .dinA  (d_wdata),
      .doutA (d_rdata),

      // instruction port
      .enB   (i_valid),
      .addrB (i_addr),
      .weB   (i_wstrb),
      .dinB  (i_wdata),
      .doutB (i_rdata)
      );
`endif
   // reply with ready 
   always @(posedge clk, posedge rst)
     if(rst) begin
	    d_ready <= 1'b0;
	    i_ready <= 1'b0;
     end else begin 
	    d_ready <= d_valid;
	    i_ready <= i_valid;
     end
endmodule
