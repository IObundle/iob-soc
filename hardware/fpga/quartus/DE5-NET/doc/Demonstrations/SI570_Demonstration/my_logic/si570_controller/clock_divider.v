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
// Major Functions: This function is used for generating  I2C clock .
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

`define DIV_WITDH 9

module clock_divider(
iCLK,
iRST_n,
oCLK_OUT,
);

input iCLK;
input iRST_n;
output oCLK_OUT;

reg [`DIV_WITDH-1:0] clk_cnt;


always@(posedge iCLK or negedge iRST_n)	
	begin	
		if (!iRST_n)
			clk_cnt <= 0;
		else	
			clk_cnt <= clk_cnt + 1;
	end

assign oCLK_OUT = clk_cnt[`DIV_WITDH-1];


endmodule
