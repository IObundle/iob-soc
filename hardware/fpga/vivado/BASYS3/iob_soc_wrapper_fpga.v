`timescale 1ns / 1ps

module iob_soc_fpga_wrapper(
	input         clk,
	input         reset,

	//uart
	output        uart_txd,
	input         uart_rxd
	);

	//
	// RESET MANAGEMENT
	//

	//system reset

	wire                         sys_rst;

	reg [15:0] 			rst_cnt;
	reg                          sys_rst_int;

	always @(posedge clk, posedge reset)
		if(reset) begin
			sys_rst_int <= 1'b0;
			rst_cnt <= 16'hFFFF;
		end else begin
			if(rst_cnt != 16'h0)
				rst_cnt <= rst_cnt - 1'b1;
			sys_rst_int <= (rst_cnt != 16'h0);
		end

	assign sys_rst = sys_rst_int;

	//
	// SYSTEM
	//
	iob_soc iob_soc (
		.clk_i (clk),
		.arst_i (sys_rst),
		.trap_o (trap),
		//UART
		.UART0_txd      (uart_txd),
		.UART0_rxd      (uart_rxd),
		.UART0_rts      (),
		.UART0_cts      (1'b1)
	);

endmodule
