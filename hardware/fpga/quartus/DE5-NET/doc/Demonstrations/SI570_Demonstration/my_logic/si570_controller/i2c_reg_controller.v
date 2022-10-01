// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
// Terasic grants permission to use and modify this code for use
// in synthesis for all Terasic Development Boards and Altera Development
// Kits made by Terasic. Other use of this code, including the selling
// ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
// This VHDL/Verilog or C/C++ source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Terasic provides no warranty regarding the use
// or functionality of this code.
//
// ============================================================================
//
// Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
// HsinChu County, Taiwan
// 302
//
// web: http://www.terasic.com/
// email: support@terasic.com
//
// ============================================================================
// Major Functions: This function is used for configuring si570 register value via 
// i2c_bus_controller .
//
//
// ============================================================================
// Design Description:
//
//
//
//
// ===========================================================================
// Revision History :
// ============================================================================
// Ver :| Author :| Mod. Date :| Changes Made:
// V1.0 :| Johnny Fan :| 11/09/30 :| Initial Version
// ============================================================================


//`define REG_NUM 9  // fang
`define REG_NUM 16  // fang

module i2c_reg_controller(

iCLK, // system   clock 50mhz 
iRST_n, // system reset 
iENABLE, // i2c reg contorl enable signale , high for enable
iI2C_CONTROLLER_STATE, //  i2c controller  state ,  high for  i2c controller  state not in idel 
iI2C_CONTROLLER_CONFIG_DONE,
oController_Ready,
iFREQ_MODE,
oSLAVE_ADDR, 
oBYTE_ADDR,
oBYTE_DATA,
oWR_CMD, // write or read commnad for  i2c controller , 1 for write command 
oStart,  // i2c controller   start control signal, high for start to send signal 
HS_DIV_reg,
N1_reg,
RFREG_reg,
oSI570_ONE_CLK_CONFIG_DONE,
i2c_read_data,
i2c_read_data_rdy
);

//=============================================================================
// PARAMETER declarations
//=============================================================================
parameter write_cmd = 1'b1;
parameter read_cmd = 1'b0;	

//===========================================================================
// PORT declarations
//===========================================================================
input iCLK;
input iRST_n;
input iENABLE;
input iI2C_CONTROLLER_STATE;
input iI2C_CONTROLLER_CONFIG_DONE;
input [2:0] iFREQ_MODE;
output  [6:0] oSLAVE_ADDR;
output [7:0] oBYTE_ADDR;
output [7:0] oBYTE_DATA ;
output oWR_CMD;
output oStart;
output oSI570_ONE_CLK_CONFIG_DONE;	
output [2:0] HS_DIV_reg;
output [6:0] N1_reg;
output [37:0] RFREG_reg; 
output	oController_Ready;
input [7:0] i2c_read_data ;
input i2c_read_data_rdy ;

wire [7:0] i2c_read_data ;

//=============================================================================
// REG/WIRE declarations
//=============================================================================

wire [2:0] iFREQ_MODE;
wire [2:0] HS_DIV_reg;
wire [6:0] N1_reg;
wire [37:0] RFREG_reg; 

reg i2c_read_data_rdy_n ;
reg read_latch ;
reg [2:0] startup_hs_div_reg ;
reg [6:0] startup_n1_reg ;
wire [2:0] startup_hs_div ;
wire [3:0] startup_n1 ;
reg [37:0] startup_refeq ;
reg [2:0] new_hs_div ;
reg [3:0] new_n1 ;
reg [22:0] fdco ;
reg [6:0] n1xhsdiv ;
reg [22:0] f1 ;
reg [29:0] fratio_30b ;
wire [8:0] fratio ;
reg [47:0] new_refeq_49b ;
wire [37:0] new_refeq ;
//reg new_value_ready ;

////////////// write data ////
//wire [7:0] regx_data = 8'h01; // RECALL
wire [7:0] reg0_data = 8'h10; // free DCO
wire [7:0] reg1_data = {HS_DIV_reg,N1_reg[6:2]};
wire [7:0] reg2_data = {N1_reg[1:0],RFREG_reg[37:32]};
wire [7:0] reg3_data = RFREG_reg[31:24];
wire [7:0] reg4_data = RFREG_reg[23:16];
wire [7:0] reg5_data = RFREG_reg[15:8];
wire [7:0] reg6_data = RFREG_reg[7:0];
wire [7:0] reg7_data = 8'h00; // unfree DCO
wire [7:0] reg8_data = 8'h40; //New Freq


//////////////  ctrl addr ////
//wire [7:0] byte_addrx = 8'd135;
wire [7:0] byte_addr0 = 8'd137;
wire [7:0] byte_addr1 = 8'd7;
wire [7:0] byte_addr2 = 8'd8;
wire [7:0] byte_addr3 = 8'd9;
wire [7:0] byte_addr4 = 8'd10;
wire [7:0] byte_addr5 = 8'd11;
wire [7:0] byte_addr6 = 8'd12;
wire [7:0] byte_addr7 = 8'd137;
wire [7:0] byte_addr8 = 8'd135;

wire [6:0] slave_addr = 0;

reg [19:0]  delay_cnt ;
reg delay_10m ;
reg config_done_keep ;
reg [`REG_NUM/2:0] i2c_reg_state;
reg [23:0] 	i2c_ctrl_data;//  slave_addr(7bit) + byte_addr(8bit) + byte_data(8bit)+ wr_cmd (1bit) = 24bit
reg state_ready ;

wire [6:0] oSLAVE_ADDR = i2c_ctrl_data[23:17];
wire [7:0] oBYTE_ADDR = i2c_ctrl_data[16:9];
wire [7:0] oBYTE_DATA = i2c_ctrl_data[8:1];
wire  oWR_CMD = i2c_ctrl_data[0];

reg next_cmd ;
wire i2c_controller_state_rising ;
wire access_next_i2c_reg_cmd ;
wire oStart = access_next_i2c_reg_cmd;
wire i2c_controller_config_done;

wire access_i2c_reg_start;
wire oSI570_ONE_CLK_CONFIG_DONE;
reg	oController_Ready;
//=============================================================================
// Structural coding
//=============================================================================

//=====================================
//  Write & Read  reg flow control 
//=====================================

assign HS_DIV_reg = new_hs_div - 3'b100 ;
assign N1_reg = new_n1 - 1'b1 ;
assign RFREG_reg = new_refeq ;

always @(*)
  begin
    case(iFREQ_MODE)
      3'h0 :   //100Mhz
        begin
          new_hs_div = 3'b101 ;
          new_n1 = 4'b1010 ;
          fdco = 23'h04_E200 ;
        end
      3'h1 :   //125Mhz
        begin
          new_hs_div = 3'b101 ;
          new_n1 = 4'b1000 ;
          fdco = 23'h04_E200 ;
        end
      3'h2 :   //156.25Mhz
        begin
          new_hs_div = 3'b100 ;
          new_n1 = 4'b1000 ;
          fdco = 23'h04_E200 ;
        end			
      3'h3 :   //250Mhz
        begin
          new_hs_div = 3'b101 ;
          new_n1 = 4'b0100 ;
          fdco = 23'h04_E200 ;
        end
      3'h4 :   //312.5Mhz
        begin
          new_hs_div = 3'b100 ;
          new_n1 = 4'b0100 ;
          fdco = 23'h04_E200 ;
        end	
      3'h5 :   //322.265625Mhz
        begin
          new_hs_div = 3'b100 ;
          new_n1 = 4'b0100 ;
          fdco = 23'h05_0910 ;
        end			
      3'h6 :   //644.53125Mhz
        begin
          new_hs_div = 3'b100 ;
          new_n1 = 4'b0010 ;
          fdco = 23'h05_0910 ;
        end			
      default :   //100Mhz
        begin
          new_hs_div = 3'b101 ;
          new_n1 = 4'b1010 ;
          fdco = 23'h04_E200 ;
        end			
    endcase
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      i2c_read_data_rdy_n <= 1'b0 ;
    else
      i2c_read_data_rdy_n <= i2c_read_data_rdy ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      read_latch <= 1'b0 ;
    else
      if (i2c_read_data_rdy && !i2c_read_data_rdy_n)
        read_latch <= 1'b1 ;
      else
        read_latch <= 1'b0 ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      startup_hs_div_reg <= 'b0 ;
    else
      if (read_latch && (oBYTE_ADDR == 8'h07))
        startup_hs_div_reg <= i2c_read_data[7:5] ;
      else
        startup_hs_div_reg <= startup_hs_div_reg ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      startup_n1_reg <= 'b0 ;
    else
      if (read_latch)
        case(oBYTE_ADDR)
          8'h07 : startup_n1_reg <= {i2c_read_data[4:0], startup_n1_reg[1:0]} ;
          8'h08 : startup_n1_reg <= {startup_n1_reg[6:2], i2c_read_data[7:6]} ;
          default : startup_n1_reg <= startup_n1_reg ;
        endcase // oBYTE_ADDR
      else
        startup_n1_reg <= startup_n1_reg ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      startup_refeq <= 'b0 ;
    else
      if (read_latch)
        case(oBYTE_ADDR)
          8'h08 : startup_refeq <= {i2c_read_data[5:0], startup_refeq[31:0]} ;
          8'h09 : startup_refeq <= {startup_refeq[37:32], i2c_read_data[7:0], startup_refeq[23:0]} ;
          8'h0a : startup_refeq <= {startup_refeq[37:24], i2c_read_data[7:0], startup_refeq[15:0]} ;
          8'h0b : startup_refeq <= {startup_refeq[37:16], i2c_read_data[7:0], startup_refeq[7:0]} ;
          8'h0c : startup_refeq <= {startup_refeq[37:8], i2c_read_data[7:0]} ;
          default : startup_refeq <= startup_refeq ;
        endcase // oBYTE_ADDR
      else
        startup_refeq <= startup_refeq ;
  end

assign startup_hs_div = startup_hs_div_reg + 3'b100 ;
assign startup_n1 = startup_n1_reg + 1'b1 ;

// mul_3x4 n1_mul_hsdiv(
// 	.clock(iCLK),
// 	.dataa(startup_hs_div),
// 	.datab(startup_n1),
// 	.result(n1xhsdiv));
always @(posedge iCLK)
  begin
    n1xhsdiv <= startup_hs_div * startup_n1 ;
  end

// mul_7x16 f1_mul(
// 	.clock(iCLK),
// 	.dataa(n1xhsdiv),
// 	.datab(16'h1900),
// 	.result(f1));
always @(posedge iCLK)
  begin
    f1 <= n1xhsdiv * 16'h1900 ;
  end

// div_30_23 fratio_div(
// 	.clock(iCLK),
// 	.denom(f1),
// 	.numer({fdco,7'b0}),
// 	.quotient(fratio_30b),
// 	.remain());
always @(posedge iCLK)
  begin
    fratio_30b <= {fdco, 7'h00} / f1 ;
  end

assign fratio = fratio_30b[8:0] ;

// mul_9x40 new_refeq_mul(
// 	.clock(iCLK),
// 	.dataa(fratio),
// 	.datab({2'b0, startup_refeq}),
// 	.result(new_refeq_49b));
always @(posedge iCLK)
  begin
    new_refeq_49b <= fratio * {2'b0, startup_refeq} ;
  end

assign new_refeq = new_refeq_49b[6:0] >= 64 ? new_refeq_49b[44:7]+1'b1 : new_refeq_49b[44:7] ;


//=====================================
//  State control
//=====================================

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      delay_cnt <= 'b0 ;
    else
      if (i2c_reg_state == 1)
        if (delay_cnt == 20'h3_ffff)
          delay_cnt <= delay_cnt ;
        else
          delay_cnt <= delay_cnt + 1'b1 ;
      else
        delay_cnt <= 'b0 ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      delay_10m <= 1'b0 ;
    else
      if (i2c_reg_state == 1)
        if (delay_cnt == 20'h3_fffe)
          delay_10m <= 1'b1 ;
        else
          delay_10m <= 1'b0 ;
      else
        delay_10m <= 'b0 ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      config_done_keep <= 1'b0 ;
    else
      if (i2c_reg_state == 1)
        if (i2c_controller_config_done)
          config_done_keep <= 1'b1 ;
        else
          if (delay_10m)
            config_done_keep <= 1'b0 ;
          else
            config_done_keep <= config_done_keep ;
      else
        config_done_keep <= 'b0 ;
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      i2c_reg_state <= 0;
    else
      begin
        if (access_i2c_reg_start)
          i2c_reg_state <= 1 ;
        else
          if (i2c_controller_config_done || config_done_keep)
            if (i2c_reg_state == 1)
              if (delay_10m)
                i2c_reg_state <= i2c_reg_state+1 ;
              else
                i2c_reg_state <= i2c_reg_state ;
            else
              i2c_reg_state <= i2c_reg_state+1 ;
          else
            if (i2c_reg_state == (`REG_NUM+1))
              i2c_reg_state <= 0 ;
            else
              i2c_reg_state <= i2c_reg_state ;
      end
  end

always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      state_ready <= 1'b0 ;
    else
      begin
        if (next_cmd)
          state_ready <= 1'b0 ;
        else
          if (access_i2c_reg_start)
            state_ready <= 1'b1 ;
          else
            if (i2c_controller_config_done || config_done_keep)
              if (i2c_reg_state == 1)
                if (delay_10m)
                  state_ready <= 1'b1 ;
                else
                  state_ready <= state_ready ;
              else
                state_ready <= 1'b1 ;
            else
              if (i2c_reg_state == (`REG_NUM+1))
                state_ready <= 1'b0 ;
              else
                state_ready <= state_ready ;
      end
  end

//=====================================
//  i2c bus address & data control 
//=====================================	
// always@(i2c_reg_state or i2c_ctrl_data)
always@(*)
  begin
    i2c_ctrl_data = 0;
    case (i2c_reg_state)
      0:  i2c_ctrl_data = 0; // don't forget to change REG_NUM value 
      1:  i2c_ctrl_data = {slave_addr,byte_addr8,    8'h80,write_cmd};	
      2:  i2c_ctrl_data = {slave_addr,byte_addr1,    8'h00,read_cmd};
      3:  i2c_ctrl_data = {slave_addr,byte_addr2,    8'h00,read_cmd};
      4:  i2c_ctrl_data = {slave_addr,byte_addr3,    8'h00,read_cmd};
      5:  i2c_ctrl_data = {slave_addr,byte_addr4,    8'h00,read_cmd};
      6:  i2c_ctrl_data = {slave_addr,byte_addr5,    8'h00,read_cmd};		
      7:  i2c_ctrl_data = {slave_addr,byte_addr6,    8'h00,read_cmd};
      8:  i2c_ctrl_data = {slave_addr,byte_addr0,reg0_data,write_cmd};
      9:  i2c_ctrl_data = {slave_addr,byte_addr1,reg1_data,write_cmd};
     10:  i2c_ctrl_data = {slave_addr,byte_addr2,reg2_data,write_cmd};
     11:  i2c_ctrl_data = {slave_addr,byte_addr3,reg3_data,write_cmd};
     12:  i2c_ctrl_data = {slave_addr,byte_addr4,reg4_data,write_cmd};
     13:  i2c_ctrl_data = {slave_addr,byte_addr5,reg5_data,write_cmd};		
     14:  i2c_ctrl_data = {slave_addr,byte_addr6,reg6_data,write_cmd};
     15:  i2c_ctrl_data = {slave_addr,byte_addr7,reg7_data,write_cmd};
     16:  i2c_ctrl_data = {slave_addr,byte_addr8,reg8_data,write_cmd};	
//	  10:  i2c_ctrl_data = {slave_addr,byte_addr8,reg8_data,write_cmd};	
    endcase	
  end 


edge_detector u1(

.iCLK(iCLK),
.iRST_n(iRST_n),
.iIn(iI2C_CONTROLLER_CONFIG_DONE),
.oFallING_EDGE(),
.oRISING_EDGE(i2c_controller_config_done)
);

edge_detector i2c_state_rising(

.iCLK(iCLK),
.iRST_n(iRST_n),
.iIn(iI2C_CONTROLLER_STATE),
.oFallING_EDGE(),
.oRISING_EDGE(i2c_controller_state_rising)
);


always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oController_Ready <= 1'b1;
			end
		else if (i2c_reg_state == `REG_NUM+1)	
			begin
				oController_Ready <= 1'b1;
			end
		else if (i2c_reg_state >0)
			begin
				oController_Ready <= 1'b0;
			end
	end


always @(posedge iCLK or negedge iRST_n)
  begin
    if (!iRST_n)
      next_cmd <= 1'b0 ;
    else
      if (i2c_controller_state_rising)
        next_cmd <= 1'b0 ;
      else
        if (state_ready && !iI2C_CONTROLLER_STATE)
          next_cmd <= 1'b1 ;
        else
          next_cmd <= next_cmd ;
  end

assign oSI570_ONE_CLK_CONFIG_DONE = ((i2c_reg_state == `REG_NUM) &&(i2c_controller_config_done)) ? 1'b1 : 1'b0;
assign access_next_i2c_reg_cmd = (next_cmd &&
                                  ((i2c_reg_state <= `REG_NUM) && (i2c_reg_state > 0))
                                 ) ? 1'b1 : 1'b0;
assign access_i2c_reg_start = ((iENABLE == 1'b1)&&(iI2C_CONTROLLER_STATE == 1'b0)) ? 1'b1 : 1'b0;
		
		
		
endmodule
