`timescale 1ns / 1ps

module iob_soc_tester_fpga_wrapper(
	input         clk,
	input         resetn,

	//uart
	output        uart_txd,
	input         uart_rxd,

	output        trap
	);

	//
	// RESET MANAGEMENT
	//

	//system reset

	wire                         sys_rst;

	reg [15:0] 			rst_cnt;

	always @(posedge clk, negedge resetn)
		if(!resetn)
			rst_cnt <= 16'hFFFF;
		else if (rst_cnt != 16'h0)
			rst_cnt <= rst_cnt - 1'b1;

	assign sys_rst  = (rst_cnt != 16'h0);

	//
	// SYSTEM
	//
	iob_soc_tester iob_soc_tester (
		.clk_i (clk),
		.arst_i (sys_rst),
		.trap_o (trap),
		//UART
		.portmap_0_txd (uart_txd),
		.portmap_0_rxd (uart_rxd),
		.portmap_0_rts (),
		.portmap_0_cts (1'b1)
	);

endmodule
