module TERASIC_EXT_PLL(
	clk,  // must be 50 MHZ
	reset_n,
	
	// avalon slave
	s_cs,
	s_addr,
	s_read,
	s_readdata,
	s_write,
	s_writedata,
	
	// export
	i2c_scl,
	i2c_sda
);

input			clk;
input			reset_n;
input			s_cs;
input			s_addr;
input			s_read;
output	reg	[15:0]	s_readdata;
input			s_write;
input	[15:0]	s_writedata;
output			i2c_scl;
inout			i2c_sda;

//
reg			[3:0]	clk1_set_wr;
wire		[3:0]	clk1_set_rd;
reg			[3:0]	clk2_set_wr;
wire 		[3:0]	clk2_set_rd;
reg			[3:0]	clk3_set_wr;
wire 		[3:0]	clk3_set_rd;
wire 				conf_wr;
wire 				conf_rd;
wire 				conf_ready;

`define REG_SET_CONFIG  0
`define REG_GET_CONFIG  1

always @ (posedge clk)
begin
	if (s_cs & s_read)
		s_readdata <= {conf_ready, 3'b0, clk3_set_rd, clk2_set_rd, clk1_set_rd};
	else if (conf_wr)
		{clk3_set_wr, clk2_set_wr, clk1_set_wr} <= s_writedata[11:0];
end

wire write_active;
assign write_active = s_cs & s_write;
assign conf_wr = (write_active && (s_addr == `REG_SET_CONFIG))?1'b1:1'b0;
assign conf_rd = (write_active && (s_addr == `REG_GET_CONFIG))?1'b1:1'b0;

//
ext_pll_ctrl ext_pll_ctrl_inst
(
    // system input
    .osc_50(clk),                
    .rstn(reset_n),
    // device 1
    .clk1_set_wr(clk1_set_wr),  //4
    .clk1_set_rd(clk1_set_rd),  // 4
    // device 2
    .clk2_set_wr(clk2_set_wr),
    .clk2_set_rd(clk2_set_rd),
    // device 3
    .clk3_set_wr(clk3_set_wr),
    .clk3_set_rd(clk3_set_rd),
    // setting trigger
    .conf_wr(conf_wr), // postive edge 
    .conf_rd(conf_rd), // postive edge
    // status 
    .conf_ready(conf_ready), // high level
    // 2-wire interface 
    .max_sclk(i2c_scl),
    .max_sdat(i2c_sda)
);







endmodule


