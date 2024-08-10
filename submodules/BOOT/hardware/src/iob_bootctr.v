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



    // Can't reset boot_ctr_o ever again. Only once. Else it'll forget in which boot stage it is. Only the CPU can change
    // it afterwards.
    iob_reg #(
        .DATA_W (2),
        .RST_VAL(0)
    ) ctr_r (
        .clk_i (clk_i),
        .arst_i(arst_i),
        .cke_i (cke_i),
        .data_i(CPU_CTR_wr[1 +: 2]),
        .data_o(boot_ctr_o)
    );

    // Copied from iob_bootctr_swreg_gen.v
    // Only when the CPU_CTR register has 1 written to its first bit (whether the value was already there or not), the
    // cpu_reset_o signal is set to an active pulse for some time.
    wire CPU_CTR_addressed_w;
    assign CPU_CTR_addressed_w = (iob_addr_i >= 0) && (iob_addr_i < 1);
    wire CPU_CTR_wen;
    assign CPU_CTR_wen = (iob_valid_i & iob_ready_o) & ((|iob_wstrb_i) & CPU_CTR_addressed_w);

    wire cpu_rst_req;
    assign cpu_rst_req = CPU_CTR_wen & iob_wdata_i[0]; // The first bit of the data is the only one that matters
    wire cpu_rst_start_pulse;
    assign cpu_rst_start_pulse = cpu_rst_req | arst_i; // FIXME: No logic with the "magic signals"
    iob_pulse_gen #(
        .START   (0),
        .DURATION(100)
    ) reset_pulse (
        .clk_i  (clk_i),
        .arst_i (arst_i),
        .cke_i  (cke_i),
        .start_i(cpu_rst_start_pulse),
        .pulse_o(cpu_reset_o)
    );

    //
    // Instantiate preboot and boot ROMs
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
    assign bootctr_i_iob_ready_o = 1'b1; // ROM is always ready

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
