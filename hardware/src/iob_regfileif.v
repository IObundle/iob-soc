`timescale 1ns/1ps

`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_regfileif.vh"

module iob_regfileif 
  # (
     parameter ADDR_W = `REGFILEIF_ADDR_W,
     parameter DATA_W = `REGFILEIF_DATA_W,
     parameter WDATA_W = `REGFILEIF_DATA_W
     )
   (

   // CPU interface
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

    // additional inputs and outputs
    `INPUT(valid_ext,   1),
    `INPUT(address_ext, ADDR_W),
    `INPUT(wdata_ext,   WDATA_W),
    `INPUT(wstrb_ext,   WDATA_W/8),
    `OUTPUT(rdata_ext,  DATA_W),
    `OUTPUT(ready_ext,  1),

`include "gen_if.v"
    );

   // BLOCK Register file interface.

   iob_dp_reg_file
     #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W)	        
	   )
   dp_reg_file
     (
      .clk    (clk),
      .rst    (rst),

      .enA    (valid),
      .addrA  (address),
      .wdataA (wdata),
      .weA    (|wstrb & valid),
      .rdataA (rdata),

      .enB    (valid_ext),
      .addrB  (address_ext),
      .wdataB (wdata_ext),
      .weB    (|wstrb_ext & valid_ext),
      .rdataB (rdata_ext)
      );

   `VAR(ready_var, 1)
   `REG_AR(clk, rst, 1'b0, ready_var, valid)
   `VAR2WIRE(ready, ready_var)

   `VAR(ready_ext_var, 1)
   `REG_AR(clk, rst, 1'b0, ready_ext_var, valid_ext)
   `VAR2WIRE(ready_ext, ready_ext_var)

endmodule
