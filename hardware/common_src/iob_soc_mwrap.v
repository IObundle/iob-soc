`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_utils.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc_mwrap #(

`ifdef IOB_SOC_INIT_MEM
    parameter HEXFILE  = "iob_soc_firmware",
`else
    parameter HEXFILE  = "none",
`endif
    parameter BOOT_HEXFILE = "iob_soc_boot",
    parameter MEM_NO_READ_ON_WRITE = 1,        //no simultaneous read/write
   `include "iob_soc_params.vs"
) (
   `include "iob_soc_io.vs"
);


//rom wires
wire rom_r_valid;
wire [BOOTROM_ADDR_W-3:0] rom_r_addr;
wire [DATA_W-1:0] rom_r_rdata;


//ram wires
wire                               i_valid;
wire          [SRAM_ADDR_W-3:0]    i_addr;
wire          [     DATA_W-1:0]    i_wdata;
wire          [   DATA_W/8-1:0]    i_wstrb;
wire          [     DATA_W-1:0]    i_rdata;
wire                               d_valid;
wire          [SRAM_ADDR_W-3:0]    d_addr;
wire          [     DATA_W-1:0]    d_wdata;
wire          [   DATA_W/8-1:0]    d_wstrb;
wire          [     DATA_W-1:0]    d_rdata;
//

`ifdef USE_SPRAM
    wire                       en;
    wire     [SRAM_ADDR_W-3:0] addr;
    wire     [DATA_W/8-1:0]    we;
    wire     [DATA_W-1:0]      di;
    wire     [DATA_W-1:0]      do;
`endif

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
    .uart_rts_o(                   uart_rts_o),
        //SPRAM  
`ifdef USE_SPRAM
    .valid_spram_o(en),
    .addr_spram_o(addr),
    .wstrb_spram_o(we),
    .wdata_spram_o(di),
    .rdata_spram_i(do),
`endif

    //rom
    .rom_r_valid_o(rom_r_valid),
    .rom_r_addr_o(rom_r_addr),
    .rom_r_rdata_i(rom_r_rdata),
    //

    //ram
    .i_valid_o(i_valid),
    .i_addr_o(i_addr),
    .i_wdata_o(i_wdata),
    .i_wstrb_o(i_wstrb),
    .i_rdata_i(i_rdata),
    .d_valid_o(d_valid),
    .d_addr_o(d_addr),
    .d_wdata_o(d_wdata),
    .d_wstrb_o(d_wstrb),
    .d_rdata_i(d_rdata)
   //

);


    `ifdef USE_SPRAM
        iob_ram_sp_be #(
            .HEXFILE(HEXFILE),
            .ADDR_W (SRAM_ADDR_W - 2),
            .DATA_W (DATA_W)
        ) main_mem_byte (
            .clk_i(clk_i),
            // data port
            .en_i  (en),
            .addr_i(addr),
            .we_i  (wstrb),
            .d_i   (wdata),
            .dt_o  (rdata)
        );
    `else
        `ifdef IOB_MEM_NO_READ_ON_WRITE
            iob_ram_dp_be #(
            .HEXFILE             (HEXFILE),
            .ADDR_W              (SRAM_ADDR_W - 2),
            .DATA_W              (DATA_W),
            .MEM_NO_READ_ON_WRITE(1)
            ) main_mem_byte (
            .clk_i(clk_i),
            // data port
            .enA_i  (d_valid),
            .addrA_i(d_addr),
            .weA_i  (d_wstrb),
            .dA_i   (d_wdata),
            .dA_o   (d_rdata),

            // instruction port
            .enB_i  (i_valid),
            .addrB_i(i_addr),
            .weB_i  (i_wstrb),
            .dB_i   (i_wdata),
            .dB_o   (i_rdata)
        );
        `else  // !`ifdef IOB_MEM_NO_READ_ON_WRITE
            iob_ram_dp_be_xil #(
                .HEXFILE(HEXFILE),
                .ADDR_W (SRAM_ADDR_W - 2),
                .DATA_W (DATA_W)
            ) main_mem_byte (
                .clk_i(clk_i),

                // data port
                .enA_i  (d_valid),
                .addrA_i(d_addr),
                .weA_i  (d_wstrb),
                .dA_i   (d_wdata),
                .dA_o   (d_rdata),
                // instruction port
                .enB_i  (i_valid),
                .addrB_i(i_addr),
                .weB_i  (i_wstrb),
                .dB_i   (i_wdata),
                .dB_o   (i_rdata)
            );
        `endif
    `endif 


    //rom instatiation
    iob_rom_sp #(
        .DATA_W (DATA_W),
        .ADDR_W (BOOTROM_ADDR_W - 2),
        .HEXFILE({BOOT_HEXFILE, ".hex"})
    ) sp_rom0 (
        .clk_i   (clk_i),
        .r_en_i  (rom_r_valid),
        .addr_i  (rom_r_addr),
        .r_data_o(rom_r_rdata)
    );
endmodule