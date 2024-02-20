`timescale 1ns / 1ps

module iob_aoi
(
	input a_i,
	input b_i,
	input c_i,
	input d_i,
	output y_o
);

	wire aab;
	wire cad;
	wire or_out;

	iob_and #(
		.W(1),
		.N(2)
	) iob_and_ab (
		.in_i({a_i,b_i}),
		.out_o(aab)
	);

	iob_and #(
		.W(1),
		.N(2)
	) iob_and_cd (
		.in_i({c_i,d_i}),
		.out_o(cad)
	);

	iob_or #(
		.W(1),
		.N(2)
	) iob_or_abcd (
		.in_i({aab,cad}),
		.out_o(or_out)
	);

	iob_inv #(
		.W(1)
	) iob_inv_out (
		.in_i(or_out),
		.out_o(y_o)
	);

endmodule
