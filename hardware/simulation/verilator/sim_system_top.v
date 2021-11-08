`timescale 1ns / 1ps
`include "system.vh"
//`include "cpu_nat_s_if.v"

/*
This is a wrapper module for verilator simulation
that will communicate with the console and get things
done
Therefore it will be a module with inout unlike system_tb.v
*/

module sim_system_top(
            //cpu and uart related stuff
	          input                    clk,
	          input                    reset,
            output                   trap,

            // Interface from cpu i.e. parallel data
            input                    valid,
            input [`UART_ADDR_W-1:0] addr,
            input [`DATA_W-1:0]      wdata,
            input [3:0]              wstrb,
            output [`DATA_W-1:0]     rdata,
            output                   ready
 );

   // Wires that will connect both units
   wire iob_txd;
   wire iob_rxd;
   wire iob_rts; // pin with rts on iob_soc
   wire iob_cts; // pin with cts on iob_soc



system system (
   	  .clk           (clk),
		  .reset         (reset),
		  .trap          (trap),
                  //UART
		  .uart_txd      (iob_txd),
		  .uart_rxd      (iob_rxd),
		  .uart_rts      (iob_rts),
		  .uart_cts      (iob_cts)
		  );


iob_uart #(
                           .ADDR_W(`UART_ADDR_W),
                           .DATA_W(`DATA_W),
                           .WDATA_W(`DATA_W)
) testbench_uart
 (
      .clk       (clk),
      .rst       (reset),
      .valid     (valid),
      .address   (addr),
      .wdata     (wdata),
      .wstrb     (wstrb),
      .rdata     (rdata),
      .ready     (ready),
      .txd       (iob_rxd),
      .rxd       (iob_txd),
      .rts       (iob_cts),
      .cts       (iob_rts)
  );

  initial begin

    // configure uart
    cpu_inituart();


  end

endmodule
