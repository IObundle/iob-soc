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

`ifdef IOB_SOC_USE_EXTMEM

    `include "iob_mwrap_extmem_wires.vs"

    assign axi_awid_o = axi_awid;
    assign axi_awaddr_o = axi_awaddr;
    assign axi_awlen_o = axi_awlen;
    assign axi_awsize_o = axi_awsize;
    assign axi_awburst_o = axi_awburst;
    assign axi_awlock_o = axi_awlock;
    assign axi_awcache_o = axi_awcache;
    assign axi_awprot_o = axi_awprot;
    assign axi_awqos_o = axi_awqos;
    assign axi_awvalid_o = axi_awvalid;
    assign axi_awready = axi_awready_i;    
    assign axi_wdata_o = axi_wdata;
    assign axi_wstrb_o = axi_wstrb;
    assign axi_wlast_o = axi_wlast;
    assign axi_wvalid_o = axi_wvalid;
    assign  axi_wready = axi_wready_i;
    assign axi_bid = axi_bid_i;   
    assign axi_bresp = axi_bresp_i;
    assign axi_bvalid = axi_bvalid_i;
    assign axi_bready_o = axi_bready;
    assign axi_arid_o = axi_arid;
    assign axi_araddr_o = axi_araddr;
    assign axi_arlen_o = axi_arlen;
    assign axi_arsize_o = axi_arsize;
    assign axi_arburst_o = axi_arburst;
    assign axi_arlock_o = axi_arlock;
    assign axi_arcache_o = axi_arcache;
    assign axi_arprot_o = axi_arprot;
    assign axi_arqos_o = axi_arqos;
    assign axi_arvalid_o = axi_arvalid;
    assign axi_arready = axi_arready_i;
    assign  axi_rid = axi_rid_i;
    assign  axi_rdata = axi_rdata_i;
    assign  axi_rresp = axi_rresp_i;
    assign  axi_rlast = axi_rlast_i;
    assign  axi_rvalid = axi_rvalid_i;
    assign axi_rready_o = axi_rready;


`endif



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
    wire                       spram_en;
    wire     [SRAM_ADDR_W-3:0] spram_addr;
    wire     [DATA_W/8-1:0]    spram_we;
    wire     [DATA_W-1:0]      spram_di;
    wire     [DATA_W-1:0]      spram_do;
`endif

iob_soc #(
    `include "iob_soc_inst_params.vs"
)iob_soc(
    `include "iob_soc_pportmaps.vs"
    .clk_i(                             clk_i),
    .cke_i(                             cke_i),
    .arst_i(                           arst_i),
    .trap_o(                           trap_o),
        //SPRAM  
`ifdef USE_SPRAM
    .valid_spram_o(spram_en),
    .addr_spram_o(spram_addr),
    .wstrb_spram_o(spram_we),
    .wdata_spram_o(spram_di),
    .rdata_spram_i(spram_do),
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
            .en_i  (spram_en),
            .addr_i(spram_addr),
            .we_i  (spram_we),
            .d_i   (spram_di),
            .dt_o  (spram_do)
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
