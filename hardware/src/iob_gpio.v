`timescale 1ns / 1ps

`include "iob_gpio_conf.vh"
`include "iob_gpio_swreg_def.vh"

module iob_gpio #(
   `include "iob_gpio_params.vs"
) (
   `include "iob_gpio_io.vs"
);

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt;
   wire iob_rvalid_nxt;

   //BLOCK Register File & Configuration control and status register file.
   `include "iob_gpio_swreg_inst.vs"

   // Write GPIO
   assign output_ports  = GPIO_OUTPUT_wr;
   assign output_enable = GPIO_OUTPUT_ENABLE_wr;

   // Read GPIO
   assign GPIO_INPUT_rd = input_ports;

endmodule
