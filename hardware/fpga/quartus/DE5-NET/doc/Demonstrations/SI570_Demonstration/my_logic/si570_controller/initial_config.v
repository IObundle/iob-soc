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
// Major Functions:
//  This code is using for generating a pulse while FPGA is configured 
// ============================================================================
// Design Description:
// 
//
//
// ===========================================================================
// Revision History :
// ============================================================================
// Ver :| Author :| Mod. Date :| Changes Made:
// V1.0 :| Johnny Fan :| 12/02/20 :| Initial Version
// ============================================================================

`define REG_SIZE 21
module initial_config(

iCLK, // system   clock 50mhz 
iRST_n, // system reset 
oINITIAL_START,
iINITIAL_ENABLE,
);


//=============================================================================
// PARAMETER declarations
//=============================================================================

//===========================================================================
// PORT declarations
//===========================================================================
input iCLK;
input iRST_n;
output oINITIAL_START;
input	iINITIAL_ENABLE;

//=============================================================================
// REG/WIRE declarations
//=============================================================================
wire oINITIAL_START;
reg [`REG_SIZE-1:0] cnt;

//=============================================================================
// Structural coding
//=============================================================================
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin 
				cnt <= 0;
			end
		else if (cnt == 21'h1fffff)

			begin
				cnt <=21'h1fffff;

			end
		else
			begin
				cnt <= cnt + 1;	
			end
	end
	
	
assign oINITIAL_START = ((cnt == 21'h1ffffe)&iINITIAL_ENABLE) ? 1'b1: 1'b0;


endmodule




