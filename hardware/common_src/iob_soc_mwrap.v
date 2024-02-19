`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
//`include "iob_soc.vh"
`include "iob_utils.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc_mwrap #(
   `include "iob_soc_params.vs"
) (
   `include "iob_soc_io.vs"
);


iob_soc #(
    .BOOTROM_ADDR_W(           BOOTROM_ADDR_W),
    .SRAM_ADDR_W(                 SRAM_ADDR_W),
    .MEM_ADDR_W(                   MEM_ADDR_W),
    .ADDR_W(                           ADDR_W),
    .DATA_W(                           DATA_W),
    .AXI_ID_W(                       AXI_ID_W),
    .AXI_ADDR_W(                   AXI_ADDR_W),
    .AXI_DATA_W(                   AXI_DATA_W),
    .AXI_LEN_W(                     AXI_LEN_W),
    .MEM_ADDR_OFFSET(         MEM_ADDR_OFFSET),
    .UART0_DATA_W(               UART0_DATA_W),
    .UART0_ADDR_W(               UART0_ADDR_W),
    .UART0_UART_DATA_W(     UART0_UART_DATA_W),
    .TIMER0_DATA_W(             TIMER0_DATA_W),
    .TIMER0_ADDR_W(             TIMER0_ADDR_W),
    .TIMER0_WDATA_W(           TIMER0_WDATA_W)
)iob_soc(
    .clk_i(                             clk_i),
    .cke_i(                             cke_i),
    .arst_i(                           arst_i),
    .trap_o(                           trap_o),
    `ifdef IOB_SOC_USE_EXTMEM
    .axi_awid_o(                   axi_awid_o),
    .axi_awaddr_o(               axi_awaddr_o),
    .axi_awlen_o(                 axi_awlen_o),
    .axi_awsize_o(               axi_awsize_o),
    .axi_awburst_o(             axi_awburst_o),
    .axi_awlock_o(               axi_awlock_o),
    .axi_awcache_o(             axi_awcache_o),
    .axi_awprot_o(               axi_awprot_o),
    .axi_awqos_o(                 axi_awqos_o),
    .axi_awvalid_o(             axi_awvalid_o),
    .axi_awready_i(             axi_awready_i),
    .axi_wdata_o(                 axi_wdata_o),
    .axi_wstrb_o(                 axi_wstrb_o),
    .axi_wlast_o(                 axi_wlast_o),
    .axi_wvalid_o(               axi_wvalid_o),
    .axi_wready_i(               axi_wready_i),
    .axi_bid_i(                     axi_bid_i),
    .axi_bresp_i(                 axi_bresp_i),
    .axi_bvalid_i(               axi_bvalid_i),
    .axi_bready_o(               axi_bready_o),
    .axi_arid_o(                   axi_arid_o),
    .axi_araddr_o(               axi_araddr_o),
    .axi_arlen_o(                 axi_arlen_o),
    .axi_arsize_o(               axi_arsize_o),
    .axi_arburst_o(             axi_arburst_o),
    .axi_arlock_o(               axi_arlock_o),
    .axi_arcache_o(             axi_arcache_o),
    .axi_arprot_o(               axi_arprot_o),
    .axi_arqos_o(                 axi_arqos_o),
    .axi_arvalid_o(             axi_arvalid_o),
    .axi_arready_i(             axi_arready_i),
    .axi_rid_i(                     axi_rid_i),
    .axi_rdata_i(                 axi_rdata_i),
    .axi_rresp_i(                 axi_rresp_i),
    .axi_rlast_i(                 axi_rlast_i),
    .axi_rvalid_i(               axi_rvalid_i),
    .axi_rready_o(               axi_rready_o),
    `endif
    .uart_txd_o(                   uart_txd_o),
    .uart_rxd_i(                   uart_rxd_i),
    .uart_cts_i(                   uart_cts_i),
    .uart_rts_o(                   uart_rts_o)

);


endmodule