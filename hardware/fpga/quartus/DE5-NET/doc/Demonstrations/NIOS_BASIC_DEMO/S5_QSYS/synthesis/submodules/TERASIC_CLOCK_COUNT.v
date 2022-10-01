module TERASIC_CLOCK_COUNT(
	// avalon bus
	s_clk_in,
	s_reset_in,
	s_address_in,
	s_read_in,
	s_readdata_out,
	s_write_in,
	s_writedata_in,
	// clock bus
	CLK_1,
	CLK_2
	
);

`define REG_START		2'b00
`define REG_READ_CLK1	2'b01
`define REG_READ_CLK2	2'b10

input			s_clk_in;
input			s_reset_in;
input	[1:0]	s_address_in;
input			s_read_in;
output	[31:0]	s_readdata_out;
input			s_write_in;
input	[31:0]	s_writedata_in;

input			CLK_1;
input			CLK_2;

reg		[31:0]	s_readdata_out;

reg				counting_now;
reg		[31:0]	cnt_down;



//===== control
// avalon write
always @ (posedge s_clk_in or posedge s_reset_in)
begin
	if (s_reset_in)
		cnt_down <= 0;
	else if (s_write_in && s_address_in == `REG_START)
	begin
		cnt_down <= s_writedata_in;//[15:0];
		counting_now <= (s_writedata_in == 0)?1'b0:1'b1;
	end
	else if (cnt_down > 1)
		cnt_down <= cnt_down - 1;
	else
		counting_now <= 1'b0;
end

// avalon read
always @ (posedge s_clk_in or posedge s_reset_in)
begin
	if (s_reset_in)
		s_readdata_out <= 0;
	else if (s_read_in && s_address_in == `REG_START)
		s_readdata_out <= {31'h0, counting_now};
	else if (s_read_in && s_address_in == `REG_READ_CLK1)
		s_readdata_out <= clk1_cnt;//{16'h0000, clk1_cnt};
	else if (s_read_in && s_address_in == `REG_READ_CLK2)
		s_readdata_out <= clk2_cnt;//{16'h0000, clk2_cnt};
end

// generate async count tigger
reg pre_counting_now;
always @ (posedge s_clk_in or posedge s_reset_in)
begin
	if (s_reset_in)
		pre_counting_now <= 1'b0;
	else
		pre_counting_now <= counting_now;
		
end

reg	trigger_send;
always @ (posedge s_clk_in or posedge s_reset_in)
begin
	if (s_reset_in)
		trigger_send <= 1'b0;
	else if (~pre_counting_now & counting_now)
		trigger_send <= 1'b1;
	else
		trigger_send <= 1'b0;
end


//===== count
reg		[31:0]	clk1_cnt;
reg		[31:0]	clk2_cnt;

//assign counting_now = (cnt_down == 32'b0)?1'b0:1'b1;

always @ (posedge CLK_1 or posedge trigger_send)
begin
	if (trigger_send)
		clk1_cnt <= 0;
	else if (counting_now)
	begin
		clk1_cnt <= clk1_cnt + 1;
	end
end

always @ (posedge CLK_2 or posedge trigger_send)
begin
	if (trigger_send)
	begin
		clk2_cnt <= 0;
	end
	else if (counting_now)
	begin
		clk2_cnt <= clk2_cnt + 1;
	end
end


endmodule

