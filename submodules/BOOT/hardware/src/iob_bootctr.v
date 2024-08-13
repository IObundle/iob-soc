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

    //
    // Instantiate preboot and boot ROMs
    //

    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(PREBOOTROM_ADDR_W),
        .HEXFILE("iob_soc_preboot.hex")
    ) preboot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i  (bootctr_i_iob_valid_i),
        .addr_i  (bootctr_i_iob_addr_i[2 +: PREBOOTROM_ADDR_W]),
        .r_data_o(bootctr_i_iob_rdata_o)
    );
    assign bootctr_i_iob_ready_o = 1'b1; // ROM is always ready
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

    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(BOOTROM_ADDR_W),
        .HEXFILE("iob_soc_boot.hex")
    ) boot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i(ROM_ren_rd),
        .addr_i(iob_addr_i[2 +: BOOTROM_ADDR_W]), // Equivalent to what would be (iob_addr_i >> 2)[0 +: 10]
        .r_data_o(ROM_rdata_rd)
    );
    assign ROM_rready_rd = 1'b1; // ROM is always ready
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


endmodule