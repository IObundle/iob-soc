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
`include "clk_rst_s_port.vs"
   output                             trap_o,

   // UART for testbench
   input                              uart_avalid_i,
   input [`IOB_UART_SWREG_ADDR_W-1:0] uart_addr_i,
   input [`IOB_SOC_DATA_W-1:0]        uart_wdata_i,
   input [3:0]                        uart_wstrb_i,
   output [`IOB_SOC_DATA_W-1:0]       uart_rdata_o,
   output                             uart_ready_o,
   output                             uart_rvalid_o
);

   localparam AXI_ID_W = 4;
   localparam AXI_LEN_W = 8;
   localparam AXI_ADDR_W = `DDR_ADDR_W;
   localparam AXI_DATA_W = `DDR_DATA_W;

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
      .clk_i (clk_i),
      .cke_i (1'b1),
      .arst_i(arst_i),
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

      .clk_i(clk_i),
      .rst_i(arst_i)
   );
`endif
 
   //Manually added testbench uart core. RS232 pins attached to the same pins
   //of the iob_soc UART0 instance to communicate with it
   // The interface of iob_soc UART0 is assumed to be the first portmapped interface (UART_*)
   wire cke = 1'b1;
   iob_uart uart_tb (
      .clk_i (clk_i),
      .cke_i (cke),
      .arst_i(arst_i),

      .iob_avalid_i(uart_avalid_i),
      .iob_addr_i  (uart_addr_i),
      .iob_wdata_i (uart_wdata_i),
      .iob_wstrb_i (uart_wstrb_i),
      .iob_rdata_o (uart_rdata_o),
      .iob_rvalid_o(uart_rvalid_o),
      .iob_ready_o (uart_ready_o),

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

   always @(posedge clk_i) begin
      eth_cnt <= eth_cnt + 1'b1;
      eth_clk <= eth_cnt[1];
   end

   // Ethernet Interface signals
   assign ETHERNET0_MRxClk     = eth_clk;
   assign ETHERNET0_MTxClk     = eth_clk;

   //add core test module in testbench
   iob_eth_tb_gen eth_tb (
      .clk_i    (clk_i),
      .arst_i   (arst_i),

      // This module acts like a loopback
      .mrxclk_i (ETHERNET0_MTxClk),
      .mrxd_i   (ETHERNET0_MTxD),
      .mrxdv_i  (ETHERNET0_MTxEn),
      .mrxerr_i (ETHERNET0_MTxErr),

      // The wires are thus reversed
      .mtxclk_o (ETHERNET0_MRxClk),
      .mtxd_o   (ETHERNET0_MRxD),
      .mtxen_o  (ETHERNET0_MRxDv),
      .mtxerr_i (ETHERNET0_MRxErr),

      .mcoll_o(1'b0),
      .mcrs_o(1'b0),

      .mdc_o(),
      .mdio_io(),
   );
`endif

endmodule
