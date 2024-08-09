`timescale 1 ns / 1 ps

`include "iob_bootctr_conf.vh"
`include "iob_bootctr_swreg_def.vh"
`include "iob_soc_conf.vh"

module iob_bootctr #(
        `include "iob_bootctr_params.vs"
    ) (
        `include "iob_bootctr_io.vs"
    );

    `include "iob_bootctr_swreg_inst.vs"



    wire cpu_1st_rst;
    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) cpu_1st_rst_store (
        .clk_i (clk_i),
        .arst_i(arst_i),
        .cke_i (cke_i),
        .data_i(1'b1),
        .data_o(cpu_1st_rst)
    );
    // Can't reset CTR_r_o ever again. Only once. Else it'll forget in which boot stage it is. Only the CPU can change
    // it afterwards.
    iob_reg_e #(
        .DATA_W (`IOB_BOOTCTR_CTR_W),
        .RST_VAL(0)
    ) ctr_r (
        .clk_i (clk_i),
        .arst_i(arst_i && ~cpu_1st_rst),
        .cke_i (cke_i),
        .en_i  (CPU_RST_r_o),
        .data_i(CTR_wr),
        .data_o(CTR_r_o)
    );

    iob_pulse_gen #(
        .START   (100),
        .DURATION(100)
    ) reset_pulse (
        .clk_i  (clk_i),
        .arst_i (1'b0),
        .cke_i  (cke_i),
        .start_i(CPU_RST_wr | arst_i),
        .pulse_o(CPU_RST_r_o)
    );

    //
    //INSTANTIATE BOOT ROM
    //
    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(PREBOOT_ROM_ADDR_W),
        .HEXFILE("iob_soc_preboot.hex")
    ) preboot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i  (bootctr_i_iob_valid_i),
        .addr_i  (bootctr_i_iob_addr_i[2 +: PREBOOT_ROM_ADDR_W]),
        .r_data_o(bootctr_i_iob_rdata_o)
    );
    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(BOOT_ROM_ADDR_W),
        .HEXFILE("iob_soc_boot.hex")
    ) boot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i(ROM_ren_rd),
        .addr_i(iob_addr_i[2 +: BOOT_ROM_ADDR_W]), // Equivalent to what would be (iob_addr_i >> 2)[0 +: 10]
        .r_data_o(ROM_rdata_rd)
    );
    assign ROM_rready_rd = 1'b1;
    assign bootctr_i_iob_ready_o = 1'b1;

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) rom_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(iob_valid_i),
        .data_o(ROM_rvalid_rd)
    );

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) ibus_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(bootctr_i_iob_valid_i),
        .data_o(bootctr_i_iob_rvalid_o)
    );


endmodule
