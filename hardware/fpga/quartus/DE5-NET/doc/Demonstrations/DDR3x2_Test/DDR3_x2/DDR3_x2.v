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
// Major Functions:	DDR3 x2
//             in this case ddr3 slave shares pll & dll & oct from ddr3 master
//             master : DDR3B        slave : DDR3A
// ============================================================================
// Author : Dee Zeng

module DDR3_x2 (
		input  wire        pll_ref_clk,              //  pll_ref_clk.clk
		input  wire        global_reset_n,           // global_reset.reset_n
		input  wire        soft_reset_n,             //   soft_reset.reset_n

		input  wire        oct_rzqin,                //          oct.rzqin
		
		output wire        afi_clk,                    //      afi_clk_in.clk
		output wire        afi_half_clk,               // afi_half_clk_in.clk
		output wire        afi_reset_n,               //    afi_reset_in.reset_n

		// DDR3A  
   	output wire [14:0]  ddr3a_mem_a,                      //          ddr3a_memory.ddr3a_mem_a
		output wire [2:0]   ddr3a_mem_ba,                     //                .ddr3a_mem_ba
		output wire [0:0]   ddr3a_mem_ck,                     //                .ddr3a_mem_ck
		output wire [0:0]   ddr3a_mem_ck_n,                   //                .ddr3a_mem_ck_n
		output wire [0:0]   ddr3a_mem_cke,                    //                .ddr3a_mem_cke
		output wire [0:0]   ddr3a_mem_cs_n,                   //                .ddr3a_mem_cs_n
		output wire [7:0]   ddr3a_mem_dm,                     //                .ddr3a_mem_dm
		output wire [0:0]   ddr3a_mem_ras_n,                  //                .ddr3a_mem_ras_n
		output wire [0:0]   ddr3a_mem_cas_n,                  //                .ddr3a_mem_cas_n
		output wire [0:0]   ddr3a_mem_we_n,                   //                .ddr3a_mem_we_n
		output wire         ddr3a_mem_reset_n,                //                .ddr3a_mem_reset_n
		inout  wire [63:0]  ddr3a_mem_dq,                     //                .ddr3a_mem_dq
		inout  wire [7:0]   ddr3a_mem_dqs,                    //                .ddr3a_mem_dqs
		inout  wire [7:0]   ddr3a_mem_dqs_n,                  //                .ddr3a_mem_dqs_n
		output wire [0:0]   ddr3a_mem_odt,                    //                .ddr3a_mem_odt
		
		output wire         ddr3a_avl_ready,                  //             ddr3a_avl.waitrequest_n
		input  wire         ddr3a_avl_burstbegin,             //                .beginbursttransfer
		input  wire [24:0]  ddr3a_avl_addr,                   //                .address
		output wire         ddr3a_avl_rdata_valid,            //                .readdatavalid
		output wire [511:0] ddr3a_avl_rdata,                  //                .readdata
		input  wire [511:0] ddr3a_avl_wdata,                  //                .writedata
		input  wire         ddr3a_avl_read_req,               //                .read
		input  wire         ddr3a_avl_write_req,              //                .write
		input  wire [2:0]   ddr3a_avl_size,                   //                .burstcount
		
		output wire         ddr3a_local_init_done,            //       status.ddr3a_local_init_done
		output wire         ddr3a_local_cal_success,          //             .ddr3a_local_cal_success
		output wire         ddr3a_local_cal_fail,             //             .ddr3a_local_cal_fail
		
		//DDR3B
		output wire [14:0]  ddr3b_mem_a,                      //          ddr3b_memory.ddr3b_mem_a
		output wire [2:0]   ddr3b_mem_ba,                     //                .ddr3b_mem_ba
		output wire [0:0]   ddr3b_mem_ck,                     //                .ddr3b_mem_ck
		output wire [0:0]   ddr3b_mem_ck_n,                   //                .ddr3b_mem_ck_n
		output wire [0:0]   ddr3b_mem_cke,                    //                .ddr3b_mem_cke
		output wire [0:0]   ddr3b_mem_cs_n,                   //                .ddr3b_mem_cs_n
		output wire [7:0]   ddr3b_mem_dm,                     //                .ddr3b_mem_dm
		output wire [0:0]   ddr3b_mem_ras_n,                  //                .ddr3b_mem_ras_n
		output wire [0:0]   ddr3b_mem_cas_n,                  //                .ddr3b_mem_cas_n
		output wire [0:0]   ddr3b_mem_we_n,                   //                .ddr3b_mem_we_n
		output wire         ddr3b_mem_reset_n,                //                .ddr3b_mem_reset_n
		inout  wire [63:0]  ddr3b_mem_dq,                     //                .ddr3b_mem_dq
		inout  wire [7:0]   ddr3b_mem_dqs,                    //                .ddr3b_mem_dqs
		inout  wire [7:0]   ddr3b_mem_dqs_n,                  //                .ddr3b_mem_dqs_n
		output wire [0:0]   ddr3b_mem_odt,                    //                .ddr3b_mem_odt
		
		output wire         ddr3b_avl_ready,                  //             ddr3b_avl.waitrequest_n
		input  wire         ddr3b_avl_burstbegin,             //                .beginbursttransfer
		input  wire [24:0]  ddr3b_avl_addr,                   //                .address
		output wire         ddr3b_avl_rdata_valid,            //                .readdatavalid
		output wire [511:0] ddr3b_avl_rdata,                  //                .readdata
		input  wire [511:0] ddr3b_avl_wdata,                  //                .writedata
		input  wire         ddr3b_avl_read_req,               //                .read
		input  wire         ddr3b_avl_write_req,              //                .write
		input  wire [2:0]   ddr3b_avl_size,                   //                .burstcount
		
		output wire         ddr3b_local_init_done,            //       status.ddr3b_local_init_done
		output wire         ddr3b_local_cal_success,          //             .ddr3b_local_cal_success
		output wire         ddr3b_local_cal_fail             //             .ddr3b_local_cal_fail
			
		);
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [15:0] seriesterminationcontrol;   //  oct_sharing.seriesterminationcontrol
wire [15:0] parallelterminationcontrol;  //             .parallelterminationcontrol
		
wire        pll_mem_clk;                //  pll_sharing.pll_mem_clk
wire        pll_write_clk;              //             .pll_write_clk
wire        pll_addr_cmd_clk;           //             .pll_addr_cmd_clk
wire        pll_locked;                 //             .pll_locked
wire        pll_p2c_read_clk;           //             .pll_p2c_read_clk
wire        pll_c2p_write_clk;          //             .pll_c2p_write_clk
wire [6:0]  dll_delayctrl;               //  dll_sharing.dll_delayctrl		

wire        pll_write_clk_pre_phy_clk;  //             .pll_write_clk_pre_phy_clk
wire        pll_avl_clk;                //             .pll_avl_clk
wire        pll_config_clk;             //             .pll_config_clk
wire        pll_hr_clk;        		
//=======================================================
//  Structural coding
//=======================================================
// slave  DDR3A
ddr3_a DDR3A(
//	   /*input  wire         */    .pll_ref_clk(pll_ref_clk),                
		/*input  wire         */    .global_reset_n(global_reset_n),             
		/*input  wire         */    .soft_reset_n(soft_reset_n),               
		/*input  wire         */    .afi_clk(afi_clk),                    
		/*input  wire         */    .afi_half_clk(afi_half_clk),               
		/*input  wire         */    .afi_reset_n(afi_reset_n),    
		
		/*output wire [14:0]  */    .mem_a(ddr3a_mem_a),                      
		/*output wire [2:0]   */    .mem_ba(ddr3a_mem_ba),                     
		/*output wire [0:0]   */    .mem_ck(ddr3a_mem_ck),                     
		/*output wire [0:0]   */    .mem_ck_n(ddr3a_mem_ck_n),                   
		/*output wire [0:0]   */    .mem_cke(ddr3a_mem_cke),                    
		/*output wire [0:0]   */    .mem_cs_n(ddr3a_mem_cs_n),                   
		/*output wire [7:0]   */    .mem_dm(ddr3a_mem_dm),                     
		/*output wire [0:0]   */    .mem_ras_n(ddr3a_mem_ras_n),                  
		/*output wire [0:0]   */    .mem_cas_n(ddr3a_mem_cas_n),                  
		/*output wire [0:0]   */    .mem_we_n(ddr3a_mem_we_n),                   
		/*output wire         */    .mem_reset_n(ddr3a_mem_reset_n),                
		/*inout  wire [63:0]  */    .mem_dq(ddr3a_mem_dq),                     
		/*inout  wire [7:0]   */    .mem_dqs(ddr3a_mem_dqs),                    
		/*inout  wire [7:0]   */    .mem_dqs_n(ddr3a_mem_dqs_n),                  
		/*output wire [0:0]   */    .mem_odt(ddr3a_mem_odt),  
		
		/*output wire         */    .avl_ready(ddr3a_avl_ready),                  
		/*input  wire         */    .avl_burstbegin(ddr3a_avl_burstbegin),             
		/*input  wire [24:0]  */    .avl_addr(ddr3a_avl_addr),                   
		/*output wire         */    .avl_rdata_valid(ddr3a_avl_rdata_valid),            
		/*output wire [511:0] */    .avl_rdata(ddr3a_avl_rdata),                  
		/*input  wire [511:0] */    .avl_wdata(ddr3a_avl_wdata),                  
		/*input  wire [63:0]  */    .avl_be(64'hFFFF_FFFF_FFFF_FFFF),                     
		/*input  wire         */    .avl_read_req(ddr3a_avl_read_req),               
		/*input  wire         */    .avl_write_req(ddr3a_avl_write_req),              
		/*input  wire [2:0]   */    .avl_size(ddr3a_avl_size),                   
		/*output wire         */    .local_init_done(ddr3a_local_init_done),            
		/*output wire         */    .local_cal_success(ddr3a_local_cal_success),          
		/*output wire        */    .local_cal_fail(ddr3a_local_cal_fail), 

   	///////////pll dll oct--Sharing --slave /////////////////////////////
		/*input  wire [15:0]  */    .seriesterminationcontrol(seriesterminationcontrol),   
		/*input  wire [15:0]  */    .parallelterminationcontrol(parallelterminationcontrol), 
		/*input  wire         */    .pll_mem_clk(pll_mem_clk),                
		/*input  wire         */    .pll_write_clk(pll_write_clk),              
		/*input  wire         */    .pll_write_clk_pre_phy_clk(pll_write_clk_pre_phy_clk),  
		/*input  wire         */    .pll_addr_cmd_clk(pll_addr_cmd_clk),           
		/*input  wire         */    .pll_locked(pll_locked),                 
		/*input  wire         */    .pll_avl_clk(pll_avl_clk),                
		/*input  wire         */    .pll_config_clk(pll_config_clk),             
		/*input  wire         */    .pll_hr_clk(pll_hr_clk),                 
		/*input  wire         */    .pll_p2c_read_clk(pll_p2c_read_clk),           
		/*input  wire         */    .pll_c2p_write_clk(pll_c2p_write_clk),          
		/*input  wire [6:0]   */    .dll_delayctrl(dll_delayctrl)               
	);
	
	
// master  DDR3B

ddr3_b DDR3B(
      /*input  wire         */    .pll_ref_clk(pll_ref_clk),                
		/*input  wire         */    .global_reset_n(global_reset_n),             
		/*input  wire         */    .soft_reset_n(soft_reset_n),               
		/*output wire         */    .afi_clk(afi_clk),                    
		/*output wire         */    .afi_half_clk(afi_half_clk),               
		/*output wire         */    .afi_reset_n(afi_reset_n),           
		
		/*output wire [14:0]  */    .mem_a(ddr3b_mem_a),                      
		/*output wire [2:0]   */    .mem_ba(ddr3b_mem_ba),                     
		/*output wire [0:0]   */    .mem_ck(ddr3b_mem_ck),                     
		/*output wire [0:0]   */    .mem_ck_n(ddr3b_mem_ck_n),                   
		/*output wire [0:0]   */    .mem_cke(ddr3b_mem_cke),                    
		/*output wire [0:0]   */    .mem_cs_n(ddr3b_mem_cs_n),                   
		/*output wire [7:0]   */    .mem_dm(ddr3b_mem_dm),                     
		/*output wire [0:0]   */    .mem_ras_n(ddr3b_mem_ras_n),                  
		/*output wire [0:0]   */    .mem_cas_n(ddr3b_mem_cas_n),                  
		/*output wire [0:0]   */    .mem_we_n(ddr3b_mem_we_n),                   
		/*output wire         */    .mem_reset_n(ddr3b_mem_reset_n),                
		/*inout  wire [63:0]  */    .mem_dq(ddr3b_mem_dq),                     
		/*inout  wire [7:0]   */    .mem_dqs(ddr3b_mem_dqs),                    
		/*inout  wire [7:0]   */    .mem_dqs_n(ddr3b_mem_dqs_n),                  
		/*output wire [0:0]   */    .mem_odt(ddr3b_mem_odt),                
		
		/*output wire         */    .avl_ready(ddr3b_avl_ready),                  
		/*input  wire         */    .avl_burstbegin(ddr3b_avl_burstbegin),             
		/*input  wire [24:0]  */    .avl_addr(ddr3b_avl_addr),                   
		/*output wire         */    .avl_rdata_valid(ddr3b_avl_rdata_valid),            
		/*output wire [511:0] */    .avl_rdata(ddr3b_avl_rdata),                  
		/*input  wire [511:0] */    .avl_wdata(ddr3b_avl_wdata),                  
		/*input  wire [63:0]  */    .avl_be(64'hFFFF_FFFF_FFFF_FFFF),                     
		/*input  wire         */    .avl_read_req(ddr3b_avl_read_req),               
		/*input  wire         */    .avl_write_req(ddr3b_avl_write_req),              
		/*input  wire [2:0]   */    .avl_size(ddr3b_avl_size),              
		
		/*output wire         */    .local_init_done(ddr3b_local_init_done),            
		/*output wire         */    .local_cal_success(ddr3b_local_cal_success),          
		/*output wire         */    .local_cal_fail(ddr3b_local_cal_fail),         
		
		///////////pll dll oct--Sharing --master /////////////////////////////
		/*input  wire         */    .oct_rzqin(oct_rzqin),                  
		/*output wire [15:0]  */    .seriesterminationcontrol(seriesterminationcontrol),   
		/*output wire [15:0]  */    .parallelterminationcontrol(parallelterminationcontrol), 
		/*output wire         */    .pll_mem_clk(pll_mem_clk),                
		/*output wire         */    .pll_write_clk(pll_write_clk),              
		/*output wire         */    .pll_write_clk_pre_phy_clk(pll_write_clk_pre_phy_clk),  
		/*output wire         */    .pll_addr_cmd_clk(pll_addr_cmd_clk),           
		/*output wire         */    .pll_locked(pll_locked),                 
		/*output wire         */    .pll_avl_clk(pll_avl_clk),                
		/*output wire         */    .pll_config_clk(pll_config_clk),             
		/*output wire         */    .pll_hr_clk(pll_hr_clk),                 
		/*output wire         */    .pll_p2c_read_clk(pll_p2c_read_clk),           
		/*output wire         */    .pll_c2p_write_clk(pll_c2p_write_clk),          
		/*output wire [6:0]   */    .dll_delayctrl(dll_delayctrl)               
	);
endmodule
