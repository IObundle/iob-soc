`timescale 1ns / 1ps

`include "bsp.vh"
`include "iob_soc_conf.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

`ifndef IOB_UART_SWREG_ADDR_W
`define IOB_UART_SWREG_ADDR_W 16
`endif
`ifndef IOB_SOC_DATA_W
`define IOB_SOC_DATA_W 32
`endif

module iob_soc_sim_wrapper (
   output trap_o,
   //IOb-SoC uart
   input uart_avalid,
   input [`IOB_UART_SWREG_ADDR_W-1:0] uart_addr,
   input [`IOB_SOC_DATA_W-1:0] uart_wdata,
   input [3:0] uart_wstrb,
   output [`IOB_SOC_DATA_W-1:0] uart_rdata,
   output uart_ready,
   output uart_rvalid,
   input [1-1:0] clk_i,  //V2TEX_IO System clock input.
   input [1-1:0] rst_i  //V2TEX_IO System reset, asynchronous and active high.
);

   localparam AXI_ID_W = 4;
   localparam AXI_LEN_W = 8;
   localparam AXI_ADDR_W = `DDR_ADDR_W;
   localparam AXI_DATA_W = `DDR_DATA_W;

   wire clk = clk_i;
   wire arst = rst_i;

   `include "iob_soc_wrapper_pwires.vs"


   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif
   end

   //
   // INSTANTIATE COMPONENTS
   //

   //
   // IOb-SoC (may also include Unit Under Test)
   //
   iob_soc #(
      .AXI_ID_W  (AXI_ID_W),
      .AXI_LEN_W (AXI_LEN_W),
      .AXI_ADDR_W(AXI_ADDR_W),
      .AXI_DATA_W(AXI_DATA_W)
   ) iob_soc0 (
      `include "iob_soc_pportmaps.vs"
      .clk_i (clk),
      .cke_i (1'b1),
      .arst_i(arst),
      .trap_o(trap_o)
   );

   `include "iob_soc_interconnect.vs"

`ifdef IOB_SOC_USE_EXTMEM
   //instantiate the axi memory
   //IOb-SoC and SUT access the same memory.
   axi_ram #(
`ifdef IOB_SOC_INIT_MEM
      .FILE      ("init_ddr_contents.hex"),  //This file contains firmware for both systems
      .FILE_SIZE (2 ** (AXI_ADDR_W - 2)),
`endif
      .ID_WIDTH  (AXI_ID_W),
      .DATA_WIDTH(AXI_DATA_W),
      .ADDR_WIDTH(AXI_ADDR_W)
   ) ddr_model_mem (
      `include "iob_memory_axi_s_portmap.vs"

      .clk_i(clk),
      .rst_i(arst)
   );
`endif
 
   //Manually added testbench uart core. RS232 pins attached to the same pins
   //of the iob_soc UART0 instance to communicate with it
   // The interface of iob_soc UART0 is assumed to be the first portmapped interface (UART_*)
   wire cke = 1'b1;
   iob_uart uart_tb (
      .clk_i (clk),
      .cke_i (cke),
      .arst_i(arst),

      .iob_avalid_i(uart_avalid),
      .iob_addr_i  (uart_addr),
      .iob_wdata_i (uart_wdata),
      .iob_wstrb_i (uart_wstrb),
      .iob_rdata_o (uart_rdata),
      .iob_rvalid_o(uart_rvalid),
      .iob_ready_o (uart_ready),

      .txd_o(uart_rxd_i),
      .rxd_i(uart_txd_o),
      .rts_o(uart_cts_i),
      .cts_i(uart_rts_o)
   );

   //Ethernet
`ifdef IOB_SOC_USE_ETHERNET
   //ethernet clock: 4x slower than system clock
   reg [1:0] eth_cnt = 2'b0;
   reg       eth_clk;

   always @(posedge clk) begin
      eth_cnt <= eth_cnt + 1'b1;
      eth_clk <= eth_cnt[1];
   end

   // Ethernet Interface signals
   assign ETHERNET0_MRxClk     = eth_clk;
   assign ETHERNET0_MTxClk     = eth_clk;

   //add core test module in testbench
   iob_eth_tb_gen eth_tb (
      .clk  (clk),
      .reset(arst),

      // This module acts like a loopback
      .MRxClk (ETHERNET0_MTxClk),
      .MRxD   (ETHERNET0_MTxD),
      .MRxDv  (ETHERNET0_MTxEn),
      .MRxErr (ETHERNET0_MTxErr),

      // The wires are thus reversed
      .MTxClk (ETHERNET0_MRxClk),
      .MTxD   (ETHERNET0_MRxD),
      .MTxEn  (ETHERNET0_MRxDv),
      .MTxErr (ETHERNET0_MRxErr),

      .MColl(1'b0),
      .MCrS(1'b0),

      .MDC(),
      .MDIO(),
   );
`endif

endmodule
