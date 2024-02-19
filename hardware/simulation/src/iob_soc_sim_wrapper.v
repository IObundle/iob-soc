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
`ifndef IOB_ETH_SWREG_ADDR_W
`define IOB_ETH_SWREG_ADDR_W 12
`endif

module iob_soc_sim_wrapper (
`include "clk_rst_s_port.vs"
   output                             trap_o,

`ifdef IOB_SOC_USE_ETHERNET
   // Ethernet for testbench
   input                              ethernet_valid_i,
   input [`IOB_ETH_SWREG_ADDR_W-1:0]  ethernet_addr_i,
   input [`IOB_SOC_DATA_W-1:0]        ethernet_wdata_i,
   input [3:0]                        ethernet_wstrb_i,
   output [`IOB_SOC_DATA_W-1:0]       ethernet_rdata_o,
   output                             ethernet_ready_o,
   output                             ethernet_rvalid_o,
`endif

   // UART for testbench
   input                              uart_valid_i,
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
   iob_soc_mwrap #(
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


    // interconnect clk and arst
    wire clk_interconnect;
    wire arst_interconnect;
    assign clk_interconnect = clk_i;
    assign arst_interconnect = arst_i;

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
   iob_uart uart_tb (
      .clk_i (clk_i),
      .cke_i (1'b1),
      .arst_i(arst_i),

      .iob_valid_i(uart_valid_i),
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
   assign ETH0_MRxClk     = eth_clk;
   assign ETH0_MTxClk     = eth_clk;

   //Manually added testbench ethernet core. MII pins attached to the same pins
   //of the iob_soc ETH0 instance to communicate with it
   // The interface of iob_soc ETH0 is assumed to be the first portmapped interface (ETH_*)
   iob_eth
     #(
      .AXI_ID_W(AXI_ID_W),
      .AXI_ADDR_W(AXI_ADDR_W),
      .AXI_DATA_W(AXI_DATA_W),
      .AXI_LEN_W(AXI_LEN_W)
   ) eth_tb (
      .inta_o(),
      .MTxClk(eth_clk),
      .MTxD(ETH0_MRxD),
      .MTxEn(ETH0_MRxDv),
      .MTxErr(ETH0_MRxErr),
      .MRxClk(eth_clk),
      .MRxDv(ETH0_MTxEn),
      .MRxD(ETH0_MTxD),
      .MRxErr(ETH0_MTxErr),
      .MColl(1'b0),
      .MCrS(1'b0),
      .MDC(),
      .MDIO(),
      .iob_valid_i(ethernet_valid_i),
      .iob_addr_i  (ethernet_addr_i),
      .iob_wdata_i (ethernet_wdata_i),
      .iob_wstrb_i (ethernet_wstrb_i),
      .iob_rvalid_o(ethernet_rvalid_o),
      .iob_rdata_o (ethernet_rdata_o),
      .iob_ready_o (ethernet_ready_o),
      .axi_awid_o        (),
      .axi_awaddr_o      (),
      .axi_awlen_o       (),
      .axi_awsize_o      (),
      .axi_awburst_o     (),
      .axi_awlock_o      (),
      .axi_awcache_o     (),
      .axi_awprot_o      (),
      .axi_awqos_o       (),
      .axi_awvalid_o     (),
      .axi_awready_i     (1'b0),
      .axi_wdata_o       (),
      .axi_wstrb_o       (),
      .axi_wlast_o       (),
      .axi_wvalid_o      (),
      .axi_wready_i      (1'b0),
      .axi_bid_i         ({AXI_ID_W{1'b0}}),
      .axi_bresp_i       (2'b0),
      .axi_bvalid_i      (1'b0),
      .axi_bready_o      (),
      .axi_arid_o        (),
      .axi_araddr_o      (),
      .axi_arlen_o       (),
      .axi_arsize_o      (),
      .axi_arburst_o     (),
      .axi_arlock_o      (),
      .axi_arcache_o     (),
      .axi_arprot_o      (),
      .axi_arqos_o       (),
      .axi_arvalid_o     (),
      .axi_arready_i     (1'b0),
      .axi_rid_i         ({AXI_ID_W{1'b0}}),
      .axi_rdata_i       ({AXI_DATA_W{1'b0}}),
      .axi_rresp_i       (2'b0),
      .axi_rlast_i       (1'b0),
      .axi_rvalid_i      (1'b0),
      .axi_rready_o      (),
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(1'b1)
      );
`endif

endmodule
