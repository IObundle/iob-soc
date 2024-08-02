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



endmodule
