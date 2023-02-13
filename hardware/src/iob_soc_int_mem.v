/*
 This optional module is the main memory of the processor when the user chooses to have a memory internal to the 
 device. It is a 32-bit memory, implemented in the FPGA or ASIC, using SRAM technology.
 */

`timescale 1ns / 1ps
`include "build_configuration.vh"
`include "iob_soc_conf.vh"

module iob_soc_int_mem
  #(
    parameter DATA_W = 0,
    parameter ADDR_W = 0,
    parameter HEXFILE = "none"
    )
   (
    // intruction bus
    input                i_avalid_i,
    input [ADDR_W-3:0]   i_addr_i,
    output [DATA_W-1:0]  i_rdata_i,
    output reg           i_rvalid_o,
    output reg           i_ready_o,

    // data bus
    input                d_avalid_i,
    input [ADDR_W-3:0]   d_addr_i,
    input [DATA_W-1:0]   d_wdata_i,
    input [DATA_W/8-1:0] d_wstrb_i,
    output [DATA_W-1:0]  d_rdata_o,
    output reg           d_rvalid_o,
    output reg           d_ready_o,
    
`include "iob_clkenrst_port.vh"
    );

   //assign ready signals to 1 since RAM is always ready
   assign i_ready_o = 1'b1;
   assign d_ready_o = 1'b1;

   wire                  i_rvalid_nxt = i_avalid_i;                 
   iob_reg #(1,0) i_rvalid_reg 
     (
      .clk(clk),
      .rst(rst),
      .d(i_rvalid_nxt),
      .q(i_rvalid_o)
      );

   wire                  d_rvalid_nxt = d_avalid_i & ~|d_wstrb_i;
   iob_reg #(1,0) d_rvalid_reg 
     (
      .clk(clk),
      .rst(rst),
      .d(d_rvalid_nxt),
      .q(d_rvalid)
      );

`ifdef USE_SPRAM
   wire                  avalid = i_avalid_i | d_avalid_i;
   wire [ADDR_W-3:0]     addr   = i_avalid_i? i_addr_i: d_addr_i;
   wire [DATA_W-1:0]     wdata  = d_wdata_i;
   wire [DATA_W/8-1:0]   wstrb  = d_wstrb_i;
   wire [DATA_W-1:0]     rdata;
   assign d_rdata_o = rdata;
   assign i_rdata_o = rdata;

   iob_ram_sp_be
     #(
       .DATA_W(DATA_W),
       .ADDR_W(ADDR_W-2),
       .HEXFILE(HEXFILE)
       )
   main_mem_byte
     (
      .clk_i (clk_i),

      // data port
      .en_i (avalid),
      .addr_i (addr),
      .we_i (wstrb),
      .d_i (wdata),
      .dt_o (rdata)
      );
`else // !`ifdef USE_SPRAM
 `ifdef MEM_NO_READ_ON_WRITE
   iob_ram_dp_be
     #(
       .DATA_W(DATA_W),
       .ADDR_W(ADDR_W-2),
       .MEM_NO_READ_ON_WRITE(1),
       .HEXFILE(HEXFILE)
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
 `else // !`ifdef MEM_NO_READ_ON_WRITE
   iob_ram_dp_be_xil
     #(
       .HEXFILE(HEXFILE),
       .ADDR_W(ADDR_W-2),
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

endmodule
