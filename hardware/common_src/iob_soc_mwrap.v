`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
//`include "iob_soc.vh"
`include "iob_utils.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc_mwrap #(

    parameter HEXFILE  = "iob_soc_firmware",
    parameter BOOT_HEXFILE = "iob_soc_boot",
   `include "iob_soc_params.vs"
) (
   `include "iob_soc_io.vs"
);


//rom wires
wire rom_r_valid;
wire [BOOTROM_ADDR_W-3:0] rom_r_addr;
wire [DATA_W-1:0] rom_r_rdata;

`ifdef USE_SPRAM
    wire                       en_i;
    wire     [SRAM_ADDR_W-3:0] addr_i;
    wire     [DATA_W/8-1:0]    we_i;
    wire     [DATA_W-1:0]      d_i;
    wire     [DATA_W-1:0]      d_o;
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
    .valid_SPRAM(en_i),
    .addr_SPRAM(addr_i),
    .wstrb_SPRAM(we_i),
    .wdata_SPRAM(d_i),
    .rdata_SPRAM(d_o),
`endif
    //rom
    .rom_r_valid(rom_r_valid),
    .rom_r_addr(rom_r_addr),
    .rom_r_rdata(rom_r_rdata)
    //

);


    `ifdef USE_SPRAM
        localparam COL_W = 8;
        localparam NUM_COL = DATA_W / COL_W;
        `ifdef IOB_MEM_NO_READ_ON_WRITE
            localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};
            genvar i;
            generate
                for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
                    localparam mem_init_file_int = (HEXFILE != "none") ?
                    {HEXFILE, "_", file_suffix[8*(i+1)-1-:8], ".hex"} : "none";

                    iob_ram_sp #(
                        .HEXFILE(mem_init_file_int),
                        .ADDR_W (SRAM_ADDR_W - 2),
                        .DATA_W (COL_W)
                    ) ram (
                        .clk_i(clk_i),
                        .en_i  (en_i),
                        .addr_i(addr_i),
                        .d_i   (d_i[i*COL_W+:COL_W]),
                        .we_i  (we_i[i]),
                        .d_o   (d_o[i*COL_W+:COL_W])
                    );
                end
            endgenerate
        `else  // !IOB_MEM_NO_READ_ON_WRITE
            // this allows ISE 14.7 to work; do not remove
            localparam mem_init_file_int = {HEXFILE, ".hex"};

            // Core Memory
            reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];

            // Initialize the RAM
            initial
                if (mem_init_file_int != "none.hex")
                    $readmemh(mem_init_file_int, ram_block, 0, 2 ** ADDR_W - 1);
            reg     [DATA_W-1:0] d_o_int;
            integer              i;
            always @(posedge clk_i) begin
                if (en_i) begin
                    for (i = 0; i < NUM_COL; i = i + 1) begin
                        if (we_i[i]) begin
                            ram_block[addr_i][i*COL_W+:COL_W] <= d_i[i*COL_W+:COL_W];
                        end
                    end
                d_o_int <= ram_block[addr_i];  // Send Feedback
                end
            end
            assign d_o = d_o_int;
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