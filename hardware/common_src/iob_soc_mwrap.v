`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_soc.vh"
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
    .clk_i(          clk_i),
    .cke_i(          cke_i),
    .arst_i(        arst_i),
    .trap_o(        trap_o),
    `ifdef IOB_SOC_USE_EXTMEM
    output [      AXI_ID_W-1:0] axi_awid_o,


);







endmodule