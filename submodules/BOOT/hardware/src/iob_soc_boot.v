`timescale 1 ns / 1 ps

`include "iob_utils.vh"
`include "iob_soc_boot_conf.vh"
`include "iob_soc_boot_swreg_def.vh"
`include "iob_soc_conf.vh"

module iob_soc_boot #(
        `include "iob_soc_boot_params.vs"
    ) (
        `include "iob_soc_boot_io.vs"
    );

    `include "iob_soc_boot_swreg_inst.vs"


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
        .DATA_W (`IOB_SOC_BOOT_CTR_W),
        .RST_VAL(0)
    ) ctr_r (
        .clk_i (clk_i),
        .arst_i(arst_i && ~cpu_1st_rst),
        .cke_i (cke_i),
        .en_i  (iob_avalid_i),
        .data_i(CTR),
        .data_o(CTR_r_o)
    );

    // CPU reset
    reg cpu_rst;
    wire cpu_rst_r_o;
    assign cpu_rst_o = cpu_rst_r_o;
    always @(posedge CTR) begin
        cpu_rst = 1'b1;
    end
    always @(posedge clk_i, posedge arst_i) begin
        if (cpu_rst | arst_i) begin
            cpu_rst = 1'b0;
        end
    end
    iob_pulse_gen #(
        .START   (0),
        .DURATION(100)
    ) reset_pulse (
        .clk_i  (clk_i),
        .arst_i (arst_i),
        .cke_i  (cke_i),
        .start_i(cpu_rst | arst_i),
        .pulse_o(cpu_rst_r_o)
    );

    //
    //INSTANTIATE PREBOOT AND BOOTLOADER ROMs
    //
    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(BOOT_ROM_ADDR_W),
        .HEXFILE("iob_soc_preboot.hex")
    ) preboot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i  (ctr_ibus_avalid_i),
        .addr_i  ({2'b00, ctr_ibus_addr_i[2 +: BOOT_ROM_ADDR_W-2]}), // Equivalent to what would be (iob_addr_i >> 2)[0 +: 10]
        .r_data_o(ctr_ibus_rdata_o)
    );
    iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(PREBOOT_ROM_ADDR_W),
        .HEXFILE("iob_soc_boot.hex")
    ) boot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i(ROM_ren),
        .addr_i({2'b00, iob_addr_i[2 +: PREBOOT_ROM_ADDR_W-2]}), // Equivalent to what would be (iob_addr_i >> 2)[0 +: 10]
        .r_data_o(ROM)
    );
    assign ROM_ready = 1'b1;
    assign ctr_ibus_ready_o = 1'b1;

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) rom_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(iob_avalid_i),
        .data_o(ROM_rvalid)
    );

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(0)
    ) ibus_rvalid_r (
        .clk_i (clk_i),
        .cke_i (cke_i),
        .arst_i(arst_i),
        .data_i(ctr_ibus_avalid_i),
        .data_o(ctr_ibus_rvalid_o)
    );

endmodule
