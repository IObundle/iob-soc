`timescale 1ns / 1ps
`include "system.vh"

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
            input                    tb_uart_valid,
            input                    tb_uart_address,
            input [`UART_ADDR_W-1:0] tb_uart_addr,
            input [`DATA_W-1:0]      tb_uart_wdata,
            input [3:0]              tb_uart_wstrb,
            output [`DATA_W-1:0]     tb_uart_rdata,
            output                   tb_uart_ready,

            input                    tb_uart_rts
   );

   // Wires that will connect both units
   wire serial_data_to_fpga;
   wire serial_data_from_fpga;
   wire fpga_rts; // pin with rts on fpga
   wire fpga_cts; // pin with cts on fpga

system system (
   	  .clk           (sys_clk),
		  .reset         (sys_rst),
		  .trap          (trap),
                  //UART
		  .uart_txd      (serial_data_from_fpga),
		  .uart_rxd      (serial_data_to_fpga),
		  .uart_rts      (fpga_rts),
		  .uart_cts      (fpga_cts)
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
      .txd       (serial_data_to_fpga),
      .rxd       (serial_data_from_fpga),
      .rts       (fpga_cts),
      .cts       (fpga_rts)
  );


endmodule
