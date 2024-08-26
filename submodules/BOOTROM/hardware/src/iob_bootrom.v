`timescale 1 ns / 1 ps

`include "iob_bootrom_conf.vh"
`include "iob_bootrom_csrs_def.vh"
`include "iob_soc_conf.vh"

module iob_bootrom #(
        `include "iob_bootrom_params.vs"
    ) (
        `include "iob_bootrom_io.vs"
    );

    `include "iob_bootrom_csrs_inst.vs"

    // Instantiate preboot ROM //

    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(PREBOOTROM_ADDR_W),
        .HEXFILE("iob_soc_preboot.hex")
    ) preboot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i  (bootrom_i_iob_valid_i),
        .addr_i  (bootrom_i_iob_addr_i[2 +: PREBOOTROM_ADDR_W-2]),
        .r_data_o(bootrom_i_iob_rdata_o)
    );

   
    assign bootrom_i_iob_ready_o = 1'b1; // ROM is always ready
    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) ibus_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(bootrom_i_iob_valid_i),
        .data_o(bootrom_i_iob_rvalid_o)
    );

    // Link to boot ROM //

    assign boot_rom_en_o = ROM_ren_rd;
    assign boot_rom_addr_o = iob_addr_i[2 +: BOOTROM_ADDR_W-2];
    assign ROM_rdata_rd = boot_rom_rdata_i;
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
