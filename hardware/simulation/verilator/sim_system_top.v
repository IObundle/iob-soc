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
            input                    address,
            input [`UART_ADDR_W-1:0] addr,
            input [`DATA_W-1:0]      wdata,
            input [3:0]              wstrb,
            output [`DATA_W-1:0]     rdata,
            output                   ready,
            input                    system_uart_cts
 );

   // Wires that will connect both units
   wire serial_data_to_iob_soc;
   wire serial_data_from_iob_soc;
   wire fpga_rts; // pin with rts on fpga
   wire fpga_cts; // pin with cts on fpga



system system (
   	  .clk           (clk),
		  .reset         (reset),
		  .trap          (trap),
                  //UART
		  .uart_txd      (serial_data_from_iob_soc),
		  .uart_rxd      (serial_data_to_iob_soc),
		  .uart_rts      (),
		  .uart_cts      (test_wire)
		  );


iob_uart #(
                           .ADDR_W(`UART_ADDR_W),
                           .DATA_W(`DATA_W),
                           .WDATA_W(`DATA_W)
) testbench_uart
 (
      .clk       (clk),
      .rst       (reset),
      .valid     (tb_uart_valid),
      .address   (tb_uart_addr),
      .wdata     (tb_uart_wdata),
      .wstrb     (tb_uart_wstrb),
      .rdata     (tb_uart_rdata),
      .ready     (tb_uart_ready),
      .txd       (serial_data_to_iob_soc),
      .rxd       (serial_data_from_iob_soc),
      .rts       (fpga_cts),
      .cts       (fpga_rts)
  );


endmodule
