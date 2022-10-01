// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions: Master Controller Module for extern PLL.
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Rosaline Lin 	   :| 10/03/31  :| Initial Revision
// ============================================================================

module ext_pll_ctrl
(
    // system input
    osc_50,                
    rstn,
    // device 1
    clk1_set_wr,
    clk1_set_rd,
    // device 2
    clk2_set_wr,
    clk2_set_rd,
    // device 3
    clk3_set_wr,
    clk3_set_rd,
    // setting trigger
    conf_wr, // postive edge 
    conf_rd, // postive edge
    // status 
    conf_ready, // high level
    // 2-wire interface 
    max_sclk,
    max_sdat
);


//=======================================================
//  Port declarations
//=======================================================
// system input
input           osc_50;                
input           rstn;
// device 1
input     [3:0] clk1_set_wr;
output    [3:0] clk1_set_rd;
// device 2
input     [3:0] clk2_set_wr;
output    [3:0] clk2_set_rd;
// device 3
input     [3:0] clk3_set_wr;
output    [3:0] clk3_set_rd;
// setting trigger
input           conf_wr;
input           conf_rd;
// status
output          conf_ready;
// 2-wire interface
output          max_sclk;
inout           max_sdat;


//=======================================================
//  Parameter declarations
//=======================================================


//=======================================================
//  Signal declarations
//=======================================================
reg      [2:0] conf_wr_d, conf_rd_d;
reg      [7:0] slow_counter;
reg            slow_counter_d;
wire           clk_enable;
wire           conf_wr_trigger, conf_rd_trigger;
reg            conf_ready;
reg            conf_wr_p2s;
wire    [13:0] conf_data;
reg      [4:0] conf_counter;
reg            conf_end;
reg            p2s;
reg            s2p_act_pre;
reg      [1:0] s2p_act;
reg     [11:0] s2p;
reg            sclk;
reg            sclk_mask;


//=======================================================
//  Structural coding
//=======================================================
assign clk1_set_rd = s2p[3:0];
assign clk2_set_rd = s2p[7:4];
assign clk3_set_rd = s2p[11:8];
assign max_sclk = sclk || (sclk_mask ? slow_counter[7] : 1'b0);
assign max_sdat = (s2p_act_pre || s2p_act[1]) ? 1'bz : p2s;
assign clk_enable = slow_counter_d && !slow_counter[7];
assign conf_wr_trigger = !conf_wr_d[2] && conf_wr_d[1];
assign conf_rd_trigger = !conf_rd_d[2] && conf_rd_d[1];
assign conf_data = conf_wr_p2s ? {2'b10, clk3_set_wr, clk2_set_wr, clk1_set_wr} : 14'hfff;


//--- pipe delay ---//
always @ (posedge osc_50 or negedge rstn)
	if(!rstn)
	begin
     conf_wr_d <= 3'b0;
     conf_rd_d <= 3'b0;
	end
  else
  begin
     conf_wr_d <= {conf_wr_d[1:0], conf_wr};
     conf_rd_d <= {conf_rd_d[1:0], conf_rd};
  end

//--- clock slow down enable ---//
always @ (posedge osc_50 or negedge rstn)
	if(!rstn)
	begin
		slow_counter <= 8'b0;
		slow_counter_d <= 1'b0;
	end
	else
	begin
		slow_counter <= slow_counter + 1;
		slow_counter_d <= slow_counter[7];
  end

//--- config status ---//
always @ (posedge osc_50 or negedge rstn)
	if(!rstn)
		conf_ready <= 1'b1;
	else if (conf_wr_trigger || conf_rd_trigger)
	begin
		conf_ready <=	1'b0;
		conf_wr_p2s <= conf_wr_trigger;
	end
	else if (clk_enable && conf_end)
		conf_ready <=	1'b1;

//--- config counter ---//
always @ (posedge osc_50 or negedge rstn)
	if(!rstn)
		conf_counter <= 5'b0;
	else if (conf_ready)
		conf_counter <= 5'b0;
	else if (clk_enable)
		conf_counter <= conf_counter + 1;

//--- p2s convert ---//
always @ (posedge osc_50 or negedge rstn)
  if (!rstn) 
  begin 
  	sclk <= 1'b1; p2s <= 1'b1; sclk_mask <= 1'b0; conf_end <= 1'b0; s2p_act_pre <= 1'b0;
  end
  else if (clk_enable)
    case (conf_counter)
    	5'd1    : p2s <= 1'b0;
    	5'd2    : sclk <= 1'b0;
    	5'd3    : begin p2s <= conf_data[13]; sclk_mask <= 1'b1; end
    	5'd4    : begin p2s <= conf_data[12]; s2p_act_pre <= !conf_wr_p2s; end
    	5'd5    : p2s <= conf_data[11];
    	5'd6    : p2s <= conf_data[10];
    	5'd7    : p2s <= conf_data[9]; 
    	5'd8    : p2s <= conf_data[8]; 
    	5'd9    : p2s <= conf_data[7]; 
    	5'd10   : p2s <= conf_data[6]; 
    	5'd11   : p2s <= conf_data[5]; 
    	5'd12   : p2s <= conf_data[4]; 
    	5'd13   : p2s <= conf_data[3]; 
    	5'd14   : p2s <= conf_data[2]; 
    	5'd15   : p2s <= conf_data[1]; 
    	5'd16   : begin p2s <= conf_data[0]; s2p_act_pre <= 1'b0; end 
      5'd17   : begin sclk <= 1'b0; p2s <= 1'b0; sclk_mask <= 1'b0; end	
      5'd18   : sclk <= 1'b1;
      5'd19   : begin p2s <= 1'b1; conf_end <= 1'b1; end 
    	default : begin sclk <= 1'b1; p2s <= 1'b1; sclk_mask <= 1'b0; conf_end <= 1'b0; s2p_act_pre <= 1'b0; end
    endcase

//--- s2p convert ---//
always @ (posedge max_sclk)
	if (s2p_act[0])
    s2p <= {s2p[10:0], max_sdat};

always @ (posedge osc_50 or negedge rstn)
  if (!rstn)
  	s2p_act <= 2'b0;
  else if (clk_enable)
  	s2p_act <= {s2p_act[0], s2p_act_pre};

endmodule
