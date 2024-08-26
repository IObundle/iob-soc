`timescale 1 ns / 1 ps

`include "iob_bootrom_conf.vh"
`include "iob_bootrom_csrs_def.vh"
`include "iob_soc_conf.vh"

module iob_bootrom #(
        `include "iob_bootrom_params.vs"
    ) (
        `include "iob_bootrom_io.vs"
    );

    `include "iob_axistream_in_wires.vs"

    // configuration control and status register file.
    `include "iob_axistream_in_blocks.vs"

    // Instantiate preboot ROM //

    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(PREBOOTROM_ADDR_W),
        .HEXFILE("iob_soc_preboot.hex")
    ) preboot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i  (ibus_iob_valid_i),
        .addr_i  (ibus_iob_addr_i[2 +: PREBOOTROM_ADDR_W-2]),
        .r_data_o(ibus_iob_rdata_o)
    );


    assign ibus_iob_ready_o = 1'b1; // ROM is always ready
    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) ibus_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(ibus_iob_valid_i),
        .data_o(ibus_iob_rvalid_o)
    );

    // Link to boot ROM //

    assign ext_rom_en_o = ROM_ren_rd;
    assign ext_rom_addr_o = iob_addr_i[2 +: BOOTROM_ADDR_W-2];
    assign ROM_rdata_rd = ext_rom_rdata_i;
    assign ROM_rready_rd = 1'b1; // ROM is always ready
    reg ROM_rvalid_rd_middle; // Registered twice to align rvalid with rdata
    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) rom_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(iob_valid_i),
        .data_o(ROM_rvalid_rd_middle)
    );
    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) rom_rvalid_r_2nd (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(ROM_rvalid_rd_middle),
        .data_o(ROM_rvalid_rd)
    );


endmodule
