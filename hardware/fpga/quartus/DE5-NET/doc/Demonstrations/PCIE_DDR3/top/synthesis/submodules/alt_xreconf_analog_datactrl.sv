// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Analog Data control Interface Block
// This Block talks with common uif (alt_xreconf_uif) and cif (alt_xreconf_cif) interface
//
// $Header$

`timescale 1 ns / 1 ps

module alt_xreconf_analog_datactrl
  #(
    parameter RECONFIG_USER_ADDR_WIDTH = 3,
    parameter RECONFIG_USER_DATA_WIDTH = 32,
    parameter RECONFIG_USER_OFFSET_WIDTH=6,
    parameter RECONFIG_BASIC_OFFSET_ADDR_WIDTH=11
    ) (
       // Inputs
    input wire clk,
    input wire reset,
       // from/to uif module
    input wire [RECONFIG_USER_OFFSET_WIDTH-1:0] uif_addr_offset,
    input wire 					uif_go,
    input wire [2:0] 				uif_mode,
    input wire [RECONFIG_USER_DATA_WIDTH-1:0] 	uif_writedata,

    output wire 				uif_busy ,
    output reg 					uif_illegal_pch_error = 1'b0,
    output reg 					uif_illegal_offset_error = 1'b0,       
    output reg [RECONFIG_USER_DATA_WIDTH-1:0] 	uif_readdata = 32'd0,


       // from/to cif module

    output wire 				ctrl_go,
    output wire [2:0] 				ctrl_opcode,
    output wire 				ctrl_lock,

    input wire 					ctrl_wait,   // connect this to waitrequest from cif block

    input wire 					ctrl_illegal_phy_ch,
    input wire [RECONFIG_USER_DATA_WIDTH-1:0] 	ctrl_readdata,	// readadata from cif block
    output wire [RECONFIG_USER_DATA_WIDTH-1:0] 				ctrl_writedata, // this is read modified data from rmw block
    output reg [RECONFIG_BASIC_OFFSET_ADDR_WIDTH-1:0] ctrl_addr_offset, // ch_offset_addr

    input wire 					       waitrequest_from_base
       );


   reg [4:0] 					       analog_offset = 5'b00000;
   reg [4:0] 					       analog_length = 5'b00000;




   import alt_xcvr_reconfig_h::*; //alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   import sv_xcvr_h::*; //altera_xcvr_generic/sv/sv_xcvr_h.sv

   // Preempashsis pretap and Posttap2 Implementation

    // RX DCGAIN implemnatation is similar to SIVGX
    // Following mapping is there till 12.0
    //////////////////////////////////////////////////
    //Port              |       DRIO CRAM bit value
    //2..0              |       10..7
    //////////////////////////////////////////////////
    //000               |       0000
    //001               |       0001
    //010               |       0011
    //011               |       0111
    //100               |       1111
    //Others            |       Assume to be 1's   

    // Mapping is updated from 12.1 onwards FB case:72667
    //////////////////////////////////////////////////
    //Port              |       DRIO CRAM bit value
    //2..0              |       10..7
    //////////////////////////////////////////////////
    //000               |       0000
    //001               |       1000
    //010               |       1100
    //011               |       1110
    //100               |       1111
    //Others            |       Assume to be 1's   

   // bit offsets and bit length for all features
   
   localparam [4:0] TX_VOD_BIT_OFFSET = 0;
   localparam [4:0] TX_VOD_BIT_LENGTH = 6;

// pretap, 1st posttap and 2nd psoattap all backened address is same ch_reg_3

   localparam [4:0] TX_PRETAP_INV_BIT_OFFSET = 1;
   localparam [4:0] TX_PRETAP_INV_LENGTH = 1;
   localparam [4:0] TX_PRETAP_BIT_OFFSET = 12;
   localparam [4:0] TX_PRETAP_LENGTH = 4;

   localparam [4:0] TX_POSTTAP1_BIT_OFFSET = 3;
   localparam [4:0] TX_POSTTAP1_LENGTH = 5;

   localparam [4:0] TX_POSTTAP_2INV_BIT_OFFSET = 0;
   localparam [4:0] TX_POSTTAP_2INV_LENGTH = 1;
   localparam [4:0] TX_POSTTAP2_BIT_OFFSET = 8;
   localparam [4:0] TX_POSTTAP2_LENGTH = 4;

   localparam [4:0] RX_DCGAIN_BIT_OFFSET = 0;
   localparam [4:0] RX_DCGAIN_LENGTH = 4;

   // For Loopback need to do 2 cosecutive writes
   // First write to CRAM rrevlb_sw (1 for postcdr and 0 for precdr)
   // Then write to cram rrx_dlpbk for pre-cdr and rcru_rlpbk for postcdr
   localparam [4:0] RCRU_RLBK_BIT_OFFSET = 0;
   localparam [4:0] RCRU_RLBK_BIT_LENGTH = 1;

   localparam [4:0] RREVLB_SW_BIT_OFFSET = 14;
   localparam [4:0] RREVLB_SW_BIT_LENGTH = 1;

   localparam [4:0] RRX_DLPBK_BIT_OFFSET = 4;
   localparam [4:0] RRX_DLPBK_BIT_LENGTH = 1;      
   

// Following are the parameters for equalizer controls

   // L - Low (5-10dB gain)      
   localparam [2:0] L0_EQA = 3'b011;
   localparam [2:0] L0_EQB = 3'b000;
   localparam [2:0] L0_EQC = 3'b000;
   localparam [2:0] L0_EQD = 3'b000;
   localparam [2:0] L0_EQV = 3'b000;

   localparam [2:0] L1_EQA = 3'b100;
   localparam [2:0] L1_EQB = 3'b000;
   localparam [2:0] L1_EQC = 3'b000;
   localparam [2:0] L1_EQD = 3'b000;
   localparam [2:0] L1_EQV = 3'b000;

   localparam [2:0] L2_EQA = 3'b111;
   localparam [2:0] L2_EQB = 3'b000;
   localparam [2:0] L2_EQC = 3'b000;
   localparam [2:0] L2_EQD = 3'b000;
   localparam [2:0] L2_EQV = 3'b100;            

   localparam [2:0] L3_EQA = 3'b111;
   localparam [2:0] L3_EQB = 3'b000;
   localparam [2:0] L3_EQC = 3'b000;
   localparam [2:0] L3_EQD = 3'b000;
   localparam [2:0] L3_EQV = 3'b111;            

   localparam [2:0] L4_EQA = 3'b111;
   localparam [2:0] L4_EQB = 3'b111;
   localparam [2:0] L4_EQC = 3'b000;
   localparam [2:0] L4_EQD = 3'b000;
   localparam [2:0] L4_EQV = 3'b000;


   // M - Medium (8-14dB gain)   
   localparam [2:0] M0_EQA = 3'b111;
   localparam [2:0] M0_EQB = 3'b111;
   localparam [2:0] M0_EQC = 3'b000;
   localparam [2:0] M0_EQD = 3'b000;
   localparam [2:0] M0_EQV = 3'b100;

   localparam [2:0] M1_EQA = 3'b111;
   localparam [2:0] M1_EQB = 3'b111;
   localparam [2:0] M1_EQC = 3'b011;
   localparam [2:0] M1_EQD = 3'b000;
   localparam [2:0] M1_EQV = 3'b000;                  

   localparam [2:0] M2_EQA = 3'b111;
   localparam [2:0] M2_EQB = 3'b111;
   localparam [2:0] M2_EQC = 3'b111;
   localparam [2:0] M2_EQD = 3'b000;
   localparam [2:0] M2_EQV = 3'b000;

   localparam [2:0] M3_EQA = 3'b111;
   localparam [2:0] M3_EQB = 3'b111;
   localparam [2:0] M3_EQC = 3'b111;
   localparam [2:0] M3_EQD = 3'b000;
   localparam [2:0] M3_EQV = 3'b010;

   localparam [2:0] M4_EQA = 3'b111;
   localparam [2:0] M4_EQB = 3'b111;
   localparam [2:0] M4_EQC = 3'b111;
   localparam [2:0] M4_EQD = 3'b000;
   localparam [2:0] M4_EQV = 3'b100;

   // H - High (14-18dB gain)
   localparam [2:0] H0_EQA = 3'b111;
   localparam [2:0] H0_EQB = 3'b111;
   localparam [2:0] H0_EQC = 3'b111;
   localparam [2:0] H0_EQD = 3'b111;
   localparam [2:0] H0_EQV = 3'b000;

   localparam [2:0] H1_EQA = 3'b111;
   localparam [2:0] H1_EQB = 3'b111;
   localparam [2:0] H1_EQC = 3'b111;
   localparam [2:0] H1_EQD = 3'b111;
   localparam [2:0] H1_EQV = 3'b010;

   localparam [2:0] H2_EQA = 3'b111;
   localparam [2:0] H2_EQB = 3'b111;
   localparam [2:0] H2_EQC = 3'b111;
   localparam [2:0] H2_EQD = 3'b111;
   localparam [2:0] H2_EQV = 3'b100;   

   localparam [2:0] H3_EQA = 3'b111;
   localparam [2:0] H3_EQB = 3'b111;
   localparam [2:0] H3_EQC = 3'b111;
   localparam [2:0] H3_EQD = 3'b111;
   localparam [2:0] H3_EQV = 3'b110;

   localparam [2:0] H4_EQA = 3'b111;
   localparam [2:0] H4_EQB = 3'b111;
   localparam [2:0] H4_EQC = 3'b111;
   localparam [2:0] H4_EQD = 3'b111;
   localparam [2:0] H4_EQV = 3'b111;
   
   
   // user modes
   localparam [2:0] UIF_MODE_RD    = 3'b000;
   localparam [2:0] UIF_MODE_WR    = 3'b001;
   localparam [2:0] UIF_MODE_PHYS  = 3'b010;



   
/*
    // Following PMA RECONFIG Address defined in sv_xcvr_h.sv
 localparam RECONFIG_PMA_CH0_VOD = RECONFIG_PMA_CH0_BASE + 11'h005;
 localparam RECONFIG_PMA_CH0_PRETAP = RECONFIG_PMA_CH0_BASE + 11'h003;
 localparam RECONFIG_PMA_CH0_POSTTAP1 = RECONFIG_PMA_CH0_BASE + 11'h003;
 localparam RECONFIG_PMA_CH0_POSTTAP2 = RECONFIG_PMA_CH0_BASE + 11'h003;
 localparam RECONFIG_PMA_CH0_RX_EQA = RECONFIG_PMA_CH0_BASE + 11'h018;
 localparam RECONFIG_PMA_CH0_RX_EQB = RECONFIG_PMA_CH0_BASE + 11'h018;
 localparam RECONFIG_PMA_CH0_RX_EQC = RECONFIG_PMA_CH0_BASE + 11'h018;
 localparam RECONFIG_PMA_CH0_RX_EQD = RECONFIG_PMA_CH0_BASE + 11'h018;
 localparam RECONFIG_PMA_CH0_RX_EQV = RECONFIG_PMA_CH0_BASE + 11'h018;
 localparam RECONFIG_PMA_CH0_RX_EQDCGAIN = RECONFIG_PMA_CH0_BASE + 11'h019;
 
 localparam RECONFIG_PMA_CH0_RCRU_RLBK = RECONFIG_PMA_CH0_BASE + 11'h00F;
 localparam RECONFIG_PMA_CH0_RREVLB_SW = RECONFIG_PMA_CH0_BASE + 11'h017;
 localparam RECONFIG_PMA_CH0_RRX_DLPBK = RECONFIG_PMA_CH0_BASE + 11'h019;
 

*/

   // enable this only in case of retap and postap where need to insert pretap_inv and postatp_inv at proper while doing read modify writes
   reg [31:0] 					       datain_rmw = 32'h00000000;
   wire [3:0] 					       pretap_data;
   wire 					       pretap_inv;
   wire [3:0] 					       posttap2_data;
   wire 					       posttap2_inv;
   wire [3:0] 					       result_data;
   wire [3:0] 					       p2result_data;   
   wire [3:0] 					       lpmaddsub_rddata;
   wire [3:0] 					       p2lpmaddsub_rddata;   
   reg 						       pretap_invrddata = 1'b0;
   reg 						       posttap2_invrddata = 1'b0;

   reg 						       pretap_f = 1'b0;
   reg 						       posttap2_f = 1'b0;
   reg [4:0] 					       pretap_datain = 5'd0;
   reg [4:0] 					       posttap2_datain = 5'd0;
   wire 					       pretap_rden;
   wire 					       pretap_wren;
   wire 					       posttap2_rden;
   wire 					       posttap2_wren;   
   wire [31:0] 					       analog_rddata;
   

   integer 					       i =0;
					       
   reg 						       rxdcgain_f = 1'b0;
   reg 						       lpbk_lock = 1'b0;
   wire 					       lpbk_lock_ack;
   reg 						       lpbk_go = 1'b0;
   reg 						       lpbk_done = 1'b0;
   reg  					       lpbk_precdr_reg = 1'b0;
   reg  					       lpbk_postcdr_reg = 1'b0;
   reg 						       precdr_lpbk_f = 1'b0;
   reg 						       postcdr_lpbk_f = 1'b0;
   reg 						       eqctrl_f = 1'b0;
   reg [3:0] 					       eqctrl_reg = 4'b0000;
   reg 						       illegal_offset_f = 1'b0;
   
   
   
   
   
   
   
// This block decodes the uif_addr_offset and assigns proper bit_offset, bit_length and
// write data for read modify write (rmw) module
// It also assigns the ctrl_addr_offset for CIF function
// uif_addr_offset is from UIF block when address is offset address and write is enabled

   always @(*)
     begin
	pretap_datain = uif_writedata[4:0];
	posttap2_datain = uif_writedata[4:0];
	rxdcgain_f = 1'b0;
	precdr_lpbk_f = 1'b0;
	postcdr_lpbk_f = 1'b0;
	eqctrl_f = 1'b0;
	pretap_f = 1'b0;
	posttap2_f = 1'b0;
	illegal_offset_f = 1'b0;	
	case (uif_addr_offset)
	  XR_ANALOG_OFFSET_VOD:
	    begin
	       analog_offset= TX_VOD_BIT_OFFSET;
	       analog_length = TX_VOD_BIT_LENGTH;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_VOD;
	       datain_rmw = uif_writedata;
	    end
	  XR_ANALOG_OFFSET_PREEMPH0T:
	    begin
	       analog_offset =  TX_PRETAP_BIT_OFFSET;
	       analog_length = TX_PRETAP_LENGTH;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_PRETAP;
	       datain_rmw = (32'b0 | pretap_data);
	       pretap_f = 1'b1;
	       posttap2_f = 1'b0;
	    end

	  XR_ANALOG_OFFSET_PREEMPH1T:
	    begin
	       analog_offset =  TX_POSTTAP1_BIT_OFFSET;
	       analog_length = TX_POSTTAP1_LENGTH;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_POSTTAP1;
	       datain_rmw = uif_writedata;
	       pretap_f = 1'b0;
	       posttap2_f = 1'b0;
	    end
	  
	  XR_ANALOG_OFFSET_PREEMPH2T:
	    begin
	       analog_offset =  TX_POSTTAP2_BIT_OFFSET;
	       analog_length = TX_POSTTAP2_LENGTH;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_POSTTAP2;
	       posttap2_datain = uif_writedata[4:0];
	       datain_rmw = (32'b0 | posttap2_data);
	       pretap_f = 1'b0;
	       posttap2_f = 1'b1;
	    end // case: XR_ANALOG_OFFSET_PREEMPH2T

	  XR_ANALOG_OFFSET_RXDCGAIN:
	    begin
	       analog_offset = RX_DCGAIN_BIT_OFFSET;
	       analog_length = RX_DCGAIN_LENGTH;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_RX_EQDCGAIN;	       
	       rxdcgain_f = 1'b1;
	       datain_rmw [31:3] = 28'd0;
	       if (uif_writedata[2:0] == 3'b000)
		 datain_rmw[3:0] = 4'b0000;
	       else if (uif_writedata[2:0] == 3'b001)
		 datain_rmw[3:0] = 4'b1000;
	       else if (uif_writedata[2:0] == 3'b010)
		 datain_rmw[3:0] = 4'b1100;
	       else if (uif_writedata[2:0] == 3'b011)
		 datain_rmw[3:0] = 4'b1110;	       	       
	       else if (uif_writedata[2:0] == 3'b100)
		 datain_rmw[3:0] = 4'b1111;
	       else
		 datain_rmw[3:0] = 4'b1111;		 
	    end // case: XR_ANALOG_OFFSET_RXDCGAIN

	  // For PRECDR Loopback need to do 2 cosecutive writes
	  // First write to CRAM rrevlb_sw 0 for precdr
	  // Then write to cram rrx_dlpbk to 1"	  
	  XR_ANALOG_OFFSET_PRECDRLPBK:
	    begin
	       precdr_lpbk_f = 1'b1;
	       if (!lpbk_lock_ack & !lpbk_done)
		 begin
		    datain_rmw = {{31{1'b0}}, 1'b0};   // First write 0 to rrevlb_sw
		    analog_offset = RREVLB_SW_BIT_OFFSET;
		    analog_length = RREVLB_SW_BIT_LENGTH;
		    ctrl_addr_offset = RECONFIG_PMA_CH0_RREVLB_SW;
		 end
	       else
		 begin
		    datain_rmw = {{31{1'b0}}, uif_writedata[0]};   // Now write user entered data[0] to cram rrx_dlpbk
		    analog_offset = RRX_DLPBK_BIT_OFFSET;
		    analog_length = RRX_DLPBK_BIT_LENGTH;
		    ctrl_addr_offset = RECONFIG_PMA_CH0_RRX_DLPBK;
		 end // else: !if(!lpbk_lock_ack)
	    end // case: XR_ANALOG_OFFSET_PRECDRLPBK

	  // For POSTCDR Loopback need to do 2 cosecutive writes
	  // First write to CRAM rrevlb_sw 1 for precdr
	  // Then write to cram rcru_rlpbk to 1"	  
	  XR_ANALOG_OFFSET_POSTCDRLPBK:
	    begin
	       postcdr_lpbk_f = 1'b1;	       
	       if (!lpbk_lock_ack & !lpbk_done)
		 begin
		    datain_rmw = {{31{1'b0}}, 1'b1};   // First write 1 to rrevlb_sw
		    analog_offset = RREVLB_SW_BIT_OFFSET;
		    analog_length = RREVLB_SW_BIT_LENGTH;
		    ctrl_addr_offset = RECONFIG_PMA_CH0_RREVLB_SW;
		 end
	       else
		 begin
		    datain_rmw = {{31{1'b0}}, uif_writedata[0]};   // Now write user entered data[0] to cram rrx_dlpbk
		    analog_offset = RCRU_RLBK_BIT_OFFSET;
		    analog_length = RCRU_RLBK_BIT_LENGTH;
		    ctrl_addr_offset = RECONFIG_PMA_CH0_RCRU_RLBK;
		 end // else: !if(!lpbk_lock_ack)
	    end // case: XR_ANALOG_OFFSET_PRECDRLPBK


	  // EQCTRL 
	  XR_ANALOG_OFFSET_RXEQCTRL:
	    begin
	       analog_offset = 5'b00000;
	       analog_length = 5'b00000;
	       eqctrl_f = 1'b1;
	       ctrl_addr_offset = RECONFIG_PMA_CH0_RX_EQA;
	       datain_rmw [31:4] = 28'd0;
	       datain_rmw [0] = 1'b0;
	       // internally eqctrl offset address is 0x18 and 1:15 bits are used for eqa, eqb, eqc, eqd and eqv
	       // these 5 equalizer mappings, 
	       // 3:1 = rrx_eqa_ctrl[2:0]
	       // 6:4 = rrx_eqb_ctrl[2:0]
	       // 9:7 = rrx_eqc_ctrl[2:0]
	       // 12:10 = rrx_eqd_ctrl[2:0]
	       // 15:13 = rrx_eqe_ctrl[2:0]      
	       // use following mapping table
	       case (uif_writedata[3:0])
		 // 0000 => 00101 for Low gain
		 4'b0000:
		   begin
		      datain_rmw[3:1] = 3'b000;  //eqa
		      datain_rmw[6:4] = 3'b000;  //eqb
		      datain_rmw[9:7] = 3'b000;  //eqc
		      datain_rmw[12:10] = 3'b000; //eqd
		      datain_rmw[15:13] = 3'b000; //eqv      		      
		   end
		 4'b0001:
		   begin
		      datain_rmw[3:1] = L0_EQA;  //eqa
		      datain_rmw[6:4] = L0_EQB;  //eqb
		      datain_rmw[9:7] = L0_EQC;  //eqc
		      datain_rmw[12:10] = L0_EQD; //eqd
		      datain_rmw[15:13] = L0_EQV; //eqv      		      
		   end
		 4'b0010:
		   begin
		      datain_rmw[3:1] = L1_EQA;  //eqa
		      datain_rmw[6:4] = L1_EQB;  //eqb
		      datain_rmw[9:7] = L1_EQC;  //eqc
		      datain_rmw[12:10] = L1_EQD; //eqd
		      datain_rmw[15:13] = L1_EQV; //eqv      		      
		   end
		 4'b0011:
		   begin
		      datain_rmw[3:1] = L2_EQA;  //eqa
		      datain_rmw[6:4] = L2_EQB;  //eqb
		      datain_rmw[9:7] = L2_EQC;  //eqc
		      datain_rmw[12:10] =L2_EQD; //eqd
		      datain_rmw[15:13] = L2_EQV; //eqv      		      
		   end
		 4'b0100:
		   begin
		      datain_rmw[3:1] = L3_EQA;  //eqa
		      datain_rmw[6:4] = L3_EQB;  //eqb
		      datain_rmw[9:7] = L3_EQC;  //eqc
		      datain_rmw[12:10] =L3_EQD; //eqd
		      datain_rmw[15:13] = L3_EQV; //eqv      		      
		   end		 		 
		 4'b0101:
		   begin
		      datain_rmw[3:1] = L4_EQA;  //eqa
		      datain_rmw[6:4] = L4_EQB;  //eqb
		      datain_rmw[9:7] = L4_EQC;  //eqc
		      datain_rmw[12:10] =L4_EQD; //eqd
		      datain_rmw[15:13] = L4_EQV; //eqv      		      
		   end		 		 

		 // 0110 => 1010 for Medium gain
		 4'b0110:
		   begin
		      datain_rmw[3:1] = M0_EQA;  //eqa
		      datain_rmw[6:4] = M0_EQB;  //eqb
		      datain_rmw[9:7] = M0_EQC;  //eqc
		      datain_rmw[12:10] = M0_EQD; //eqd
		      datain_rmw[15:13] = M0_EQV; //eqv      		      
		   end
		 4'b0111:
		   begin
		      datain_rmw[3:1] = M1_EQA;  //eqa
		      datain_rmw[6:4] = M1_EQB;  //eqb
		      datain_rmw[9:7] = M1_EQC;  //eqc
		      datain_rmw[12:10] = M1_EQD; //eqd
		      datain_rmw[15:13] = M1_EQV; //eqv      		      
		   end
		 4'b1000:
		   begin
		      datain_rmw[3:1] = M2_EQA;  //eqa
		      datain_rmw[6:4] = M2_EQB;  //eqb
		      datain_rmw[9:7] = M2_EQC;  //eqc
		      datain_rmw[12:10] =M2_EQD; //eqd
		      datain_rmw[15:13] = M2_EQV; //eqv      		      
		   end
		 4'b1001:
		   begin
		      datain_rmw[3:1] = M3_EQA;  //eqa
		      datain_rmw[6:4] = M3_EQB;  //eqb
		      datain_rmw[9:7] = M3_EQC;  //eqc
		      datain_rmw[12:10] =M3_EQD; //eqd
		      datain_rmw[15:13] = M3_EQV; //eqv      		      
		   end		 		 
		 4'b1010:
		   begin
		      datain_rmw[3:1] = M4_EQA;  //eqa
		      datain_rmw[6:4] = M4_EQB;  //eqb
		      datain_rmw[9:7] = M4_EQC;  //eqc
		      datain_rmw[12:10] =M4_EQD; //eqd
		      datain_rmw[15:13] = M4_EQV; //eqv      		      
		   end		 		 
		 

		 // 1011 => 1111 for High gain
		 4'b1011:
		   begin
		      datain_rmw[3:1] = H0_EQA;  //eqa
		      datain_rmw[6:4] = H0_EQB;  //eqb
		      datain_rmw[9:7] = H0_EQC;  //eqc
		      datain_rmw[12:10] = H0_EQD; //eqd
		      datain_rmw[15:13] = H0_EQV; //eqv      		      
		   end
		 4'b1100:
		   begin
		      datain_rmw[3:1] = H1_EQA;  //eqa
		      datain_rmw[6:4] = H1_EQB;  //eqb
		      datain_rmw[9:7] = H1_EQC;  //eqc
		      datain_rmw[12:10] = H1_EQD; //eqd
		      datain_rmw[15:13] = H1_EQV; //eqv      		      
		   end
		 4'b1101:
		   begin
		      datain_rmw[3:1] = H2_EQA;  //eqa
		      datain_rmw[6:4] = H2_EQB;  //eqb
		      datain_rmw[9:7] = H2_EQC;  //eqc
		      datain_rmw[12:10] =H2_EQD; //eqd
		      datain_rmw[15:13] = H2_EQV; //eqv      		      
		   end
		 4'b1110:
		   begin
		      datain_rmw[3:1] = H3_EQA;  //eqa
		      datain_rmw[6:4] = H3_EQB;  //eqb
		      datain_rmw[9:7] = H3_EQC;  //eqc
		      datain_rmw[12:10] =H3_EQD; //eqd
		      datain_rmw[15:13] = H3_EQV; //eqv      		      
		   end		 		 
		 4'b1111:
		   begin
		      datain_rmw[3:1] = H4_EQA;  //eqa
		      datain_rmw[6:4] = H4_EQB;  //eqb
		      datain_rmw[9:7] = H4_EQC;  //eqc
		      datain_rmw[12:10] =H4_EQD; //eqd
		      datain_rmw[15:13] = H4_EQV; //eqv      		      
		   end
		 default:
		   begin
		      datain_rmw[3:1] = 3'b000;  //eqa
		      datain_rmw[6:4] = 3'b000;  //eqb
		      datain_rmw[9:7] = 3'b000;  //eqc
		      datain_rmw[12:10] = 3'b000; //eqd
		      datain_rmw[15:13] = 3'b000; //eqv      		      
		   end
	       endcase // case (uif_writedata[3:0])
	    end // case: XR_ANALOG_OFFSET_RXEQCTRL
	  
	  default:
	    begin
	       analog_offset= 5'b00000;
	       analog_length = 5'b00000;
	       ctrl_addr_offset = 11'd0;
	       datain_rmw = 32'd0;
	       illegal_offset_f = 1'b1;
	    end
	endcase // case (add_offset)
     end // always @ (*)


   

   // assert lpbk_lock only if PRECDR or POSTCDR loopback offset is enabled
   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  lpbk_lock <= 1'b0;
	else
	  begin
	     if ((uif_addr_offset == XR_ANALOG_OFFSET_PRECDRLPBK || uif_addr_offset == XR_ANALOG_OFFSET_POSTCDRLPBK)  & !lpbk_lock_ack)
	       begin
		  if (analog_offset == RREVLB_SW_BIT_OFFSET)
		    lpbk_lock <= 1'b1;
		  else
		    lpbk_lock <= 1'b0;
	       end
	     else
	       lpbk_lock <= 1'b0;		    	       
	  end // else: !if(reset)
     end // always @ (posedge clk or posedge reset)
   


   // Following block asserts the lpbk_go signal for control state machien which controls the ctrl_lock, ctrl_go
   // and ctrl_opcode for CIF block
   
   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  begin
	     lpbk_go <= 1'b0;
	  end	     
	
	else
	  begin
	     if (uif_addr_offset == XR_ANALOG_OFFSET_PRECDRLPBK || uif_addr_offset == XR_ANALOG_OFFSET_POSTCDRLPBK)
	       begin
		  if (lpbk_lock_ack)
		    begin
		       lpbk_go <= 1'b1;
		    end		       
		  else
		    lpbk_go <= 1'b0;
	       end
	     else
	       begin
		  lpbk_go <= 1'b0;
	       end		  
	  end // always @ (posedge clk or posedge reset)
     end // always @ (posedge clk or posedge reset)

   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  lpbk_done <= 1'b0;	     
	else
	  begin
	     if (uif_addr_offset == XR_ANALOG_OFFSET_PRECDRLPBK || uif_addr_offset == XR_ANALOG_OFFSET_POSTCDRLPBK)
	       begin
		  if (lpbk_lock_ack)
		       lpbk_done <= 1'b1;
		  else
		    if (lpbk_done & !lpbk_go & !uif_busy)
		      begin
			 lpbk_done <= 1'b0;
		      end
	       end
	     else
	       lpbk_done <= 1'b0;
	  end // else: !if(reset)
     end // always @ (posedge clk or posedge reset)


   

   // Store precdr and postcdr Loopback values in internal register for reading purpose
   
   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  begin
	     lpbk_precdr_reg <= 1'b0;
	     lpbk_postcdr_reg <= 1'b0;	     
	  end
	else
	  begin
	     if (uif_addr_offset == XR_ANALOG_OFFSET_PRECDRLPBK && uif_mode == UIF_MODE_WR)
	       lpbk_precdr_reg <= uif_writedata[0];
	     else if (uif_addr_offset == XR_ANALOG_OFFSET_POSTCDRLPBK && uif_mode == UIF_MODE_WR)
	       lpbk_postcdr_reg <= uif_writedata[0];	       
	  end // else: !if(reset)
     end // always @ (posedge clk or posedge reset)

   
   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  begin
	     eqctrl_reg <= 1'b0;
	  end
	else
	  begin
	     if (eqctrl_f && uif_mode == UIF_MODE_WR)
	       eqctrl_reg <= uif_writedata[3:0];
	  end // else: !if(reset)
     end // always @ (posedge clk or posedge reset)



   // Assert uif_illegal_pch_error

   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  uif_illegal_pch_error <= 1'b0;
	else
	  begin
	     if (ctrl_illegal_phy_ch)
	       uif_illegal_pch_error <= 1'b1;
	     else
	       uif_illegal_pch_error <= 1'b0;	       
	  end
     end

   // Assert uif_illegal_offset_error

   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  uif_illegal_offset_error <= 1'b0;
	else
	  begin
	     if (illegal_offset_f)
	       uif_illegal_offset_error <= 1'b1;
	     else
	       uif_illegal_offset_error <= 1'b0;	       
	  end
     end



   
   // Control state machine which reads uif and lpbk go signal
   // and gives ctrl_go, ctrl_opcode and ctrl_lock to ths cif block
   // this state machine looks for the lpbk_lock signal and does 2 consecutive writes
   // at the end of first write aserted the lpbk_ack signal for 1 clock cycle
   
   alt_xreconf_analog_ctrlsm
     inst_analog_ctrlsm (
      .clk(clk),
      .reset(reset),
      .uif_go(uif_go | lpbk_go),
      .uif_mode(uif_mode),
      .uif_busy(uif_busy),
      .ctrl_go(ctrl_go),
      .ctrl_opcode(ctrl_opcode),
      .ctrl_lock(ctrl_lock),
      .ctrl_wait(ctrl_wait),
      .lpbk_lock(lpbk_lock),
      .lpbk_lock_ack(lpbk_lock_ack),
      .illegal_offset_f(illegal_offset_f),
      .illegal_ph_ch(ctrl_illegal_phy_ch)
      );


   // Read modify write module - Takes in the writedata from user and readdata from control block (cif block)
   // and does masking and shifting and returns the modified data for Basic
   
   alt_xreconf_analog_rmw #(
			    .DATA_WIDTH(32)
			    ) inst_rmw_sm (
					   .clk(clk),
					   .reset(reset),
					   .offset(analog_offset),
					   .length(analog_length),
					   .waitrequest_from_base(waitrequest_from_base),
					   .uif_mode(uif_mode),
					   .writedata(datain_rmw),
					   .pretap_f(pretap_f),
					   .posttap2_f(posttap2_f),
					   .eqctrl_f(eqctrl_f),
					   .pretap_inv(pretap_inv),
					   .posttap2_inv(posttap2_inv),
					   .readdata(ctrl_readdata),
					   .outdata(ctrl_writedata)
					   );


   //right shift the read data from control block (basic block) with offset to align it to lsb
   assign analog_rddata = ctrl_readdata >> analog_offset;


   // Read logic, assign uf_readdata with proper value when mode is UIF_MODE_RD
   always @(*)
     begin
	pretap_invrddata = 1'b0;
	posttap2_invrddata = 1'b0;
	i = 0;
	if (uif_mode == UIF_MODE_RD)
	  begin
	     if (pretap_f)
	       begin
		  pretap_invrddata = ctrl_readdata[1];
		  uif_readdata = {{27{1'b0}}, ~pretap_invrddata, lpmaddsub_rddata};		       
	       end
	     else if (posttap2_f)
	       begin
		  posttap2_invrddata = ctrl_readdata[0];
		  uif_readdata = {{27{1'b0}}, ~posttap2_invrddata, p2lpmaddsub_rddata};		       		       
	       end
	     else if (rxdcgain_f)
	       begin
		  uif_readdata[31:3] = 29'd0;
		  if (analog_rddata[3:0] == 4'b0000)
		    uif_readdata[2:0] = 3'b000;
		  else if (analog_rddata[3:0] == 4'b1000)
		    uif_readdata[2:0] = 3'b001;
		  else if (analog_rddata[3:0] == 4'b1100)
		    uif_readdata[2:0] = 3'b010;
		  else if (analog_rddata[3:0] == 4'b1110)
		    uif_readdata[2:0] = 3'b011;
		  else if (analog_rddata[3:0] == 4'b1111)
		    uif_readdata[2:0] = 3'b100;
		  else
		    uif_readdata[2:0] = 3'b000;		    
	       end // if (rxdcgain_f)
	     else if (precdr_lpbk_f)
	       begin
		  uif_readdata[31:1] = 31'd0;	       
		  uif_readdata[0] = lpbk_precdr_reg;
	       end
	     else if (postcdr_lpbk_f)
	       begin
		  uif_readdata[31:1] = 31'd0;	       		  
		  uif_readdata[0] = lpbk_postcdr_reg;
	       end
	     else if (eqctrl_f)
	       begin
		  uif_readdata[31:4] = 28'd0;
		  if (analog_rddata[15:1] == { L0_EQV, L0_EQD, L0_EQC, L0_EQB, L0_EQA })
		    uif_readdata[3:0] = 4'b0001;
		  else if (analog_rddata[15:1] == { L1_EQV, L1_EQD, L1_EQC, L1_EQB, L1_EQA })
		    uif_readdata[3:0] = 4'b0010;
		  else if (analog_rddata[15:1] == { L2_EQV, L2_EQD, L2_EQC, L2_EQB, L2_EQA })
		    uif_readdata[3:0] = 4'b0011;
		  else if (analog_rddata[15:1] == { L3_EQV, L3_EQD, L3_EQC, L3_EQB, L3_EQA })
		    uif_readdata[3:0] = 4'b0100;
		  else if (analog_rddata[15:1] == { L4_EQV, L4_EQD, L4_EQC, L4_EQB, L4_EQA })
		    uif_readdata[3:0] = 4'b0101;
		  else if (analog_rddata[15:1] == { M0_EQV, M0_EQD, M0_EQC, M0_EQB, M0_EQA })
		    uif_readdata[3:0] = 4'b0110;
		  else if (analog_rddata[15:1] == { M1_EQV, M1_EQD, M1_EQC, M1_EQB, M1_EQA })
		    uif_readdata[3:0] = 4'b0111;
		  else if (analog_rddata[15:1] == { M2_EQV, M2_EQD, M2_EQC, M2_EQB, M2_EQA })
		    uif_readdata[3:0] = 4'b1000;
		  else if (analog_rddata[15:1] == { M3_EQV, M3_EQD, M3_EQC, M3_EQB, M3_EQA })
		    uif_readdata[3:0] = 4'b1001;
		  else if (analog_rddata[15:1] == { M4_EQV, M4_EQD, M4_EQC, M4_EQB, M4_EQA })
		    uif_readdata[3:0] = 4'b1010;
		  else if (analog_rddata[15:1] == { H0_EQV, H0_EQD, H0_EQC, H0_EQB, H0_EQA })
		    uif_readdata[3:0] = 4'b1011;
		  else if (analog_rddata[15:1] == { H1_EQV, H1_EQD, H1_EQC, H1_EQB, H1_EQA })
		    uif_readdata[3:0] = 4'b1100;
		  else if (analog_rddata[15:1] == { H2_EQV, H2_EQD, H2_EQC, H2_EQB, H2_EQA })
		    uif_readdata[3:0] = 4'b1101;
		  else if (analog_rddata[15:1] == { H3_EQV, H3_EQD, H3_EQC, H3_EQB, H3_EQA })
		    uif_readdata[3:0] = 4'b1110;
		  else if (analog_rddata[15:1] == { H4_EQV, H4_EQD, H4_EQC, H4_EQB, H4_EQA })
		    uif_readdata[3:0] = 4'b1111;
		  else
		    uif_readdata[3:0] = 4'b0000;
	       end
	     
	     else
	       begin
		  for (i = 0; i<= 31; i=i+1)
		    begin
		       if (i >= analog_length)
			 uif_readdata[i] = 1'b0;
		       else
			 uif_readdata[i] = analog_rddata[i];
		    end
	       end // else: !if(posttap2_f)
	  end // if (uif_mode == UIF_MODE_RD)
	else
	  uif_readdata = analog_rddata;
	
     end // always @ (*)
   


   

   // lpm_add_sub function for pretap write

   assign pretap_wren = (uif_mode == UIF_MODE_WR) ? 1'b1:1'b0;

   lpm_add_sub
     #(
       .lpm_width(4),
       .lpm_type("lpm_add_sub"),
       .lpm_pipeline(1)
       ) inst_ptap_add_sub_wr (
			  .aclr(reset),
			  .clock(clk),
			  .clken(pretap_wren),
			  .dataa({4{1'b0}}),
			  .datab(pretap_datain[3:0]),
			  .add_sub(pretap_datain[4]),
			  .cin(),
			  .cout(),
			  .overflow(),
			  .result(result_data)
			  );

   assign pretap_inv = !uif_writedata[4];
   assign pretap_data = result_data[3:0];




   assign pretap_rden = (uif_mode == UIF_MODE_RD) ? 1'b1:1'b0;
   // lpm_add_sub function for pretap read
   lpm_add_sub
     #(
       .lpm_width(4),
       .lpm_type("lpm_add_sub"),
       .lpm_pipeline(1)
       ) inst_ptap_add_sub_rd (
			  .aclr(reset),
			  .clock(clk),
			  .clken(pretap_rden),
			  .dataa({4{1'b0}}),
			  .datab(analog_rddata[3:0]),			  
			  .add_sub(~pretap_invrddata),
			  .cin(),
			  .cout(),
			  .overflow(),
			  .result(lpmaddsub_rddata)
			  );



   

//    // lpm_add_sub function for posttap2 write

   assign posttap2_wren = (uif_mode == UIF_MODE_WR) ? 1'b1:1'b0;

   lpm_add_sub
     #(
       .lpm_width(4),
       .lpm_type("lpm_add_sub"),
       .lpm_pipeline(1)
       ) inst_p2add_sub_wr (
			  .aclr(reset),
			  .clock(clk),
			  .clken(posttap2_wren),
			  .dataa({4{1'b0}}),
			  .datab(posttap2_datain[3:0]),
			  .add_sub(posttap2_datain[4]),
			  .cin(),
			  .cout(),
			  .overflow(),
			  .result(p2result_data)
			  );

   assign posttap2_inv = !uif_writedata[4];
   assign posttap2_data = p2result_data[3:0];




   assign posttap2_rden = (uif_mode == UIF_MODE_RD) ? 1'b1:1'b0;
   // lpm_add_sub function for posttap2 read
   lpm_add_sub
     #(
       .lpm_width(4),
       .lpm_type("lpm_add_sub"),
       .lpm_pipeline(1)
       ) inst_p2add_sub_rd (
			  .aclr(reset),
			  .clock(clk),
			  .clken(posttap2_rden),
			  .dataa({4{1'b0}}),
			  .datab(analog_rddata[3:0]),			  
			  .add_sub(~posttap2_invrddata),
			  .cin(),
			  .cout(),
			  .overflow(),
			  .result(p2lpmaddsub_rddata)
			  );



   


endmodule // alt_xreconf_analog_datactrl




