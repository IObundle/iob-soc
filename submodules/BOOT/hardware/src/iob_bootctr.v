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

    assign bootctr_i_iob_valid_o  = cpu_i_iob_valid_i;
    assign bootctr_i_iob_addr_o   = cpu_i_iob_addr_i;
    assign bootctr_i_iob_wdata_o  = cpu_i_iob_wdata_i;
    assign bootctr_i_iob_wstrb_o  = cpu_i_iob_wstrb_i;

    assign cpu_i_iob_rvalid_o     = bootctr_i_iob_rvalid_i;
    assign cpu_i_iob_rdata_o      = bootctr_i_iob_rdata_i;
    assign cpu_i_iob_ready_o      = bootctr_i_iob_ready_i;


endmodule
