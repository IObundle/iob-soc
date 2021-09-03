`timescale 1ns/1ps

`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_regfileif.vh"
`include "REGFILEIFsw_reg.vh"

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

   // BLOCK Register File data to exchange between cores.
`include "REGFILEIFsw_reg.v"
`include "REGFILEIFsw_reg_gen.v"

   iob_dp_reg_file
     #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W)	        
	   )
   dp_reg_file
     (
      .clk    (clk),
      .rst    (rst),

      .addrA  (address_ext),
      .wdataA (wdata_ext),
      .weA    (|wstrb_ext & valid_ext),
      .rdataA (rdata_ext),

      .addrB  (address),
      .wdataB (wdata),
      .weB    (|wstrb & valid),
      .rdataB (rdata)
      );

   always @(posedge clk) begin
      if (rst) begin
         ready     <= 1'b0;
         ready_ext <= 1'b0;
      end else begin
         ready     <= valid;
         ready_ext <= valid_ext;
      end
   end

endmodule
