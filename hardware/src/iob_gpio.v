`timescale 1ns/1ps

`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_gpio.vh"
`include "GPIOsw_reg.vh"

module iob_gpio 
  # (
     parameter ADDR_W = `GPIO_ADDR_W,
     parameter DATA_W = `GPIO_RDATA_W,
     parameter WDATA_W = `GPIO_WDATA_W
     )
   (

   // CPU interface
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

    // additional inputs and outputs

`include "gen_if.v"
    );

   // BLOCK Register File & Holds the current configuration of the GPIO as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
`include "GPIOsw_reg.v"
`include "GPIOsw_reg_gen.v"

endmodule
