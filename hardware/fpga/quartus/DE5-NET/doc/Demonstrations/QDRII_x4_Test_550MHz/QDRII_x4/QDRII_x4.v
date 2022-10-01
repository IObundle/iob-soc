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
//qdriix4 Architecture:  
//                     A & C : pll dll oct-slave (sharing from B)
//                     B     : pll dll oct-master
//                     D     : pll dll alone . oct sharing from B    
//clock source OSC_50_B4D for A B C ; OSC_50_B8D for D
// ============================================================================
// Author : Dee Zeng

module QDRII_x4 (
		input  wire        pll_ref_clk_for_A_B_C,              //  pll_ref_clk.clk
		input  wire        pll_ref_clk_for_D,              //  pll_ref_clk.clk

		input  wire        global_reset_n,           // global_reset.reset_n
		input  wire        soft_reset_n,             //   soft_reset.reset_n

		input  wire        oct_rzqin,                //          oct.rzqin
		
		output wire        afi_clk_of_A_B_C,                    //      afi_clk_in.clk
		output wire        afi_half_clk_of_A_B_C,               // afi_half_clk_in.clk
		output wire        afi_reset_n_of_A_B_C,               //    afi_reset_in.reset_n

		output wire        afi_clk_of_D,                    //      afi_clk_in.clk
		output wire        afi_half_clk_of_D,               // afi_half_clk_in.clk
		output wire        afi_reset_n_of_D,               //    afi_reset_in.reset_n
		
    // qdrii+  A
		output wire [17:0] qdriia_mem_d,                    //       memory.mem_d
		output wire        qdriia_mem_wps_n,                //             .mem_wps_n
		output wire [1:0]  qdriia_mem_bws_n,                //             .mem_bws_n
		output wire [19:0] qdriia_mem_a,                    //             .mem_a
		input  wire [17:0] qdriia_mem_q,                    //             .mem_q
		output wire        qdriia_mem_rps_n,                //             .mem_rps_n
		output wire        qdriia_mem_k,                    //             .mem_k
		output wire        qdriia_mem_k_n,                  //             .mem_k_n
		input  wire        qdriia_mem_cq,                   //             .mem_cq
		input  wire        qdriia_mem_cq_n,                 //             .mem_cq_n
		output wire        qdriia_mem_doff_n,               //             .mem_doff_n
		
		input  wire        qdriia_avl_w_write_req,            //        avl_w.write
		output wire        qdriia_avl_w_ready,                //             .waitrequest_n
		input  wire [19:0] qdriia_avl_w_addr,                 //             .address
		input  wire [2:0]  qdriia_avl_w_size,                 //             .burstcount
		input  wire [71:0] qdriia_avl_w_wdata,                //             .writedata
		input  wire        qdriia_avl_r_read_req,             //        avl_r.read
		output wire        qdriia_avl_r_ready,                //             .waitrequest_n
		input  wire [19:0] qdriia_avl_r_addr,                 //             .address
		input  wire [2:0]  qdriia_avl_r_size,                 //             .burstcount
		output wire        qdriia_avl_r_rdata_valid,          //             .readdatavalid
		output wire [71:0] qdriia_avl_r_rdata,                //             .readdata
		
		output wire        qdriia_local_init_done,            //       status.local_init_done
		output wire        qdriia_local_cal_success,          //             .local_cal_success
		output wire        qdriia_local_cal_fail,             //             .local_cal_fail
   
    // qdrii+  B
		output wire [17:0] qdriib_mem_d,                    //       memory.mem_d
		output wire        qdriib_mem_wps_n,                //             .mem_wps_n
		output wire [1:0]  qdriib_mem_bws_n,                //             .mem_bws_n
		output wire [19:0] qdriib_mem_a,                    //             .mem_a
		input  wire [17:0] qdriib_mem_q,                    //             .mem_q
		output wire        qdriib_mem_rps_n,                //             .mem_rps_n
		output wire        qdriib_mem_k,                    //             .mem_k
		output wire        qdriib_mem_k_n,                  //             .mem_k_n
		input  wire        qdriib_mem_cq,                   //             .mem_cq
		input  wire        qdriib_mem_cq_n,                 //             .mem_cq_n
		output wire        qdriib_mem_doff_n,               //             .mem_doff_n
		
		input  wire        qdriib_avl_w_write_req,            //        avl_w.write
		output wire        qdriib_avl_w_ready,                //             .waitrequest_n
		input  wire [19:0] qdriib_avl_w_addr,                 //             .address
		input  wire [2:0]  qdriib_avl_w_size,                 //             .burstcount
		input  wire [71:0] qdriib_avl_w_wdata,                //             .writedata
		input  wire        qdriib_avl_r_read_req,             //        avl_r.read
		output wire        qdriib_avl_r_ready,                //             .waitrequest_n
		input  wire [19:0] qdriib_avl_r_addr,                 //             .address
		input  wire [2:0]  qdriib_avl_r_size,                 //             .burstcount
		output wire        qdriib_avl_r_rdata_valid,          //             .readdatavalid
		output wire [71:0] qdriib_avl_r_rdata,                //             .readdata
		
		output wire        qdriib_local_init_done,            //       status.local_init_done
		output wire        qdriib_local_cal_success,          //             .local_cal_success
		output wire        qdriib_local_cal_fail,             //             .local_cal_fail
		
    // qdrii+  C
		output wire [17:0] qdriic_mem_d,                    //       memory.mem_d
		output wire        qdriic_mem_wps_n,                //             .mem_wps_n
		output wire [1:0]  qdriic_mem_bws_n,                //             .mem_bws_n
		output wire [19:0] qdriic_mem_a,                    //             .mem_a
		input  wire [17:0] qdriic_mem_q,                    //             .mem_q
		output wire        qdriic_mem_rps_n,                //             .mem_rps_n
		output wire        qdriic_mem_k,                    //             .mem_k
		output wire        qdriic_mem_k_n,                  //             .mem_k_n
		input  wire        qdriic_mem_cq,                   //             .mem_cq
		input  wire        qdriic_mem_cq_n,                 //             .mem_cq_n
		output wire        qdriic_mem_doff_n,               //             .mem_doff_n
		
		input  wire        qdriic_avl_w_write_req,            //        avl_w.write
		output wire        qdriic_avl_w_ready,                //             .waitrequest_n
		input  wire [19:0] qdriic_avl_w_addr,                 //             .address
		input  wire [2:0]  qdriic_avl_w_size,                 //             .burstcount
		input  wire [71:0] qdriic_avl_w_wdata,                //             .writedata
		input  wire        qdriic_avl_r_read_req,             //        avl_r.read
		output wire        qdriic_avl_r_ready,                //             .waitrequest_n
		input  wire [19:0] qdriic_avl_r_addr,                 //             .address
		input  wire [2:0]  qdriic_avl_r_size,                 //             .burstcount
		output wire        qdriic_avl_r_rdata_valid,          //             .readdatavalid
		output wire [71:0] qdriic_avl_r_rdata,                //             .readdata
		
		output wire        qdriic_local_init_done,            //       status.local_init_done
		output wire        qdriic_local_cal_success,          //             .local_cal_success
		output wire        qdriic_local_cal_fail,             //             .local_cal_fail
		
    // qdrii+  D
		output wire [17:0] qdriid_mem_d,                    //       memory.mem_d
		output wire        qdriid_mem_wps_n,                //             .mem_wps_n
		output wire [1:0]  qdriid_mem_bws_n,                //             .mem_bws_n
		output wire [19:0] qdriid_mem_a,                    //             .mem_a
		input  wire [17:0] qdriid_mem_q,                    //             .mem_q
		output wire        qdriid_mem_rps_n,                //             .mem_rps_n
		output wire        qdriid_mem_k,                    //             .mem_k
		output wire        qdriid_mem_k_n,                  //             .mem_k_n
		input  wire        qdriid_mem_cq,                   //             .mem_cq
		input  wire        qdriid_mem_cq_n,                 //             .mem_cq_n
		output wire        qdriid_mem_doff_n,               //             .mem_doff_n
		
		input  wire        qdriid_avl_w_write_req,            //        avl_w.write
		output wire        qdriid_avl_w_ready,                //             .waitrequest_n
		input  wire [19:0] qdriid_avl_w_addr,                 //             .address
		input  wire [2:0]  qdriid_avl_w_size,                 //             .burstcount
		input  wire [71:0] qdriid_avl_w_wdata,                //             .writedata
		input  wire        qdriid_avl_r_read_req,             //        avl_r.read
		output wire        qdriid_avl_r_ready,                //             .waitrequest_n
		input  wire [19:0] qdriid_avl_r_addr,                 //             .address
		input  wire [2:0]  qdriid_avl_r_size,                 //             .burstcount
		output wire        qdriid_avl_r_rdata_valid,          //             .readdatavalid
		output wire [71:0] qdriid_avl_r_rdata,                //             .readdata
		
		output wire        qdriid_local_init_done,            //       status.local_init_done
		output wire        qdriid_local_cal_success,          //             .local_cal_success
		output wire        qdriid_local_cal_fail            //             .local_cal_fail
		);
		
//=======================================================
//  REG/WIRE declarations
//=======================================================

       wire [15:0] seriesterminationcontrol;     //   oct_sharing.seriesterminationcontrol
		 wire [15:0] parallelterminationcontrol;   //              .parallelterminationcontrol
		 wire [15:0] seriesterminationcontrol_1;   // oct_sharing_1.seriesterminationcontrol
		 wire [15:0] parallelterminationcontrol_1; //              .parallelterminationcontrol
		 wire [15:0] seriesterminationcontrol_2;   // oct_sharing_2.seriesterminationcontrol
		 wire [15:0] parallelterminationcontrol_2; //              .parallelterminationcontrol
		
	    wire        pll_mem_clk;                  //   pll_sharing.pll_mem_clk
		 wire        pll_write_clk;                //              .pll_write_clk
		 wire        pll_write_clk_pre_phy_clk;    //              .pll_write_clk_pre_phy_clk
		 wire        pll_addr_cmd_clk;             //              .pll_addr_cmd_clk
		 wire        pll_locked;                   //              .pll_locked
		 wire        pll_avl_clk;                  //              .pll_avl_clk
		 wire        pll_config_clk;               //              .pll_config_clk
		 wire        pll_p2c_read_clk;             //              .pll_p2c_read_clk
		 wire        pll_c2p_write_clk;            //              .pll_c2p_write_clk
		 wire        pll_mem_clk_1;                // pll_sharing_1.pll_mem_clk
		 wire        pll_write_clk_1;              //              .pll_write_clk
		 wire        pll_write_clk_pre_phy_clk_1;  //              .pll_write_clk_pre_phy_clk
		 wire        pll_addr_cmd_clk_1;           //              .pll_addr_cmd_clk
		 wire        pll_locked_1;                 //              .pll_locked
		 wire        pll_avl_clk_1;                //              .pll_avl_clk
		 wire        pll_config_clk_1;             //              .pll_config_clk
		 wire        pll_p2c_read_clk_1;           //              .pll_p2c_read_clk
		 wire        pll_c2p_write_clk_1;          //              .pll_c2p_write_clk
		 wire [6:0]  dll_delayctrl;                //   dll_sharing.dll_delayctrl
		 wire [6:0]  dll_delayctrl_1 ;             // dll_sharing_1.dll_delayctrl
//=======================================================
//  Structural coding
//=======================================================
//QDRII_A
QDRII_SLAVE QDRII_A (
//		.pll_ref_clk                (pll_ref_clk_for_A_B_C),                //     pll_ref_clk.clk
		.global_reset_n             (global_reset_n),             //    global_reset.reset_n
		.soft_reset_n               (soft_reset_n),               //      soft_reset.reset_n
		.afi_clk                    (afi_clk_of_A_B_C),                    //      afi_clk_in.clk
		.afi_half_clk               (afi_half_clk_of_A_B_C),               // afi_half_clk_in.clk
		.afi_reset_n                (afi_reset_n_of_A_B_C),                //    afi_reset_in.reset_n
		///////////////////////////////////////////////////////////////////////////////////////////////////
    
   	.mem_d                      (qdriia_mem_d),                      //          memory.mem_d
		.mem_wps_n                  (qdriia_mem_wps_n),                  //                .mem_wps_n
		.mem_bws_n                  (qdriia_mem_bws_n),                  //                .mem_bws_n
		.mem_a                      (qdriia_mem_a),                      //                .mem_a
		.mem_q                      (qdriia_mem_q),                      //                .mem_q
		.mem_rps_n                  (qdriia_mem_rps_n),                  //                .mem_rps_n
		.mem_k                      (qdriia_mem_k),                      //                .mem_k
		.mem_k_n                    (qdriia_mem_k_n),                    //                .mem_k_n
		.mem_cq                     (qdriia_mem_cq),                     //                .mem_cq
		.mem_cq_n                   (qdriia_mem_cq_n),                   //                .mem_cq_n
		.mem_doff_n                 (qdriia_mem_doff_n),                 //                .mem_doff_n
		
		.avl_w_write_req            (qdriia_avl_w_write_req),            //           avl_w.write
		.avl_w_ready                (qdriia_avl_w_ready),                //                .waitrequest_n
		.avl_w_addr                 (qdriia_avl_w_addr),                 //                .address
		.avl_w_size                 (qdriia_avl_w_size),                 //                .burstcount
		.avl_w_wdata                (qdriia_avl_w_wdata),                //                .writedata
		.avl_r_read_req             (qdriia_avl_r_read_req),             //           avl_r.read
		.avl_r_ready                (qdriia_avl_r_ready),                //                .waitrequest_n
		.avl_r_addr                 (qdriia_avl_r_addr),                 //                .address
		.avl_r_size                 (qdriia_avl_r_size),                 //                .burstcount
		.avl_r_rdata_valid          (qdriia_avl_r_rdata_valid),          //                .readdatavalid
		.avl_r_rdata                (qdriia_avl_r_rdata),                //                .readdata
		
		.local_init_done            (qdriia_local_init_done),            //          status.local_init_done
		.local_cal_success          (qdriia_local_cal_success),          //                .local_cal_success
		.local_cal_fail             (qdriia_local_cal_fail),             //                .local_cal_failal_fail
		
		///////////pll dll oct--Sharing /////////////////////////////

		.seriesterminationcontrol   (seriesterminationcontrol),   //     oct_sharing.seriesterminationcontrol
		.parallelterminationcontrol (parallelterminationcontrol), //                .parallelterminationcontrol
		.pll_mem_clk                (pll_mem_clk),                //     pll_sharing.pll_mem_clk
		.pll_write_clk              (pll_write_clk),              //                .pll_write_clk
		.pll_write_clk_pre_phy_clk  (pll_write_clk_pre_phy_clk),  //                .pll_write_clk_pre_phy_clk
		.pll_addr_cmd_clk           (pll_addr_cmd_clk),           //                .pll_addr_cmd_clk
		.pll_locked                 (pll_locked),                 //                .pll_locked
		.pll_avl_clk                (pll_avl_clk),                //                .pll_avl_clk
		.pll_config_clk             (pll_config_clk),             //                .pll_config_clk
		.pll_p2c_read_clk           (pll_p2c_read_clk),           //                .pll_p2c_read_clk
		.pll_c2p_write_clk          (pll_c2p_write_clk),          //                .pll_c2p_write_clk
		.dll_delayctrl              (dll_delayctrl)               //     dll_sharing.dll_delayctrl
	);
	
//QDRII_B
QDRII_MASTER QDRII_B (
		.pll_ref_clk                (pll_ref_clk_for_A_B_C),                //     pll_ref_clk.clk
		.global_reset_n             (global_reset_n),             //    global_reset.reset_n
		.soft_reset_n               (soft_reset_n),               //      soft_reset.reset_n
		.afi_clk                    (afi_clk_of_A_B_C),                    //      afi_clk_in.clk
		.afi_half_clk               (afi_half_clk_of_A_B_C),               // afi_half_clk_in.clk
		.afi_reset_n                (afi_reset_n_of_A_B_C),                //    afi_reset_in.reset_n
		///////////////////////////////////////////////////////////////////////////////////////////////////
    
   	.mem_d                      (qdriib_mem_d),                      //          memory.mem_d
		.mem_wps_n                  (qdriib_mem_wps_n),                  //                .mem_wps_n
		.mem_bws_n                  (qdriib_mem_bws_n),                  //                .mem_bws_n
		.mem_a                      (qdriib_mem_a),                      //                .mem_a
		.mem_q                      (qdriib_mem_q),                      //                .mem_q
		.mem_rps_n                  (qdriib_mem_rps_n),                  //                .mem_rps_n
		.mem_k                      (qdriib_mem_k),                      //                .mem_k
		.mem_k_n                    (qdriib_mem_k_n),                    //                .mem_k_n
		.mem_cq                     (qdriib_mem_cq),                     //                .mem_cq
		.mem_cq_n                   (qdriib_mem_cq_n),                   //                .mem_cq_n
		.mem_doff_n                 (qdriib_mem_doff_n),                 //                .mem_doff_n
		
		.avl_w_write_req            (qdriib_avl_w_write_req),            //           avl_w.write
		.avl_w_ready                (qdriib_avl_w_ready),                //                .waitrequest_n
		.avl_w_addr                 (qdriib_avl_w_addr),                 //                .address
		.avl_w_size                 (qdriib_avl_w_size),                 //                .burstcount
		.avl_w_wdata                (qdriib_avl_w_wdata),                //                .writedata
		.avl_r_read_req             (qdriib_avl_r_read_req),             //           avl_r.read
		.avl_r_ready                (qdriib_avl_r_ready),                //                .waitrequest_n
		.avl_r_addr                 (qdriib_avl_r_addr),                 //                .address
		.avl_r_size                 (qdriib_avl_r_size),                 //                .burstcount
		.avl_r_rdata_valid          (qdriib_avl_r_rdata_valid),          //                .readdatavalid
		.avl_r_rdata                (qdriib_avl_r_rdata),                //                .readdata
		
		.local_init_done            (qdriib_local_init_done),            //          status.local_init_done
		.local_cal_success          (qdriib_local_cal_success),          //                .local_cal_success
		.local_cal_fail             (qdriib_local_cal_fail),             //                .local_cal_failal_fail

		.oct_rzqin                  (oct_rzqin),                  //          oct.rzqin
		
		///////////pll dll oct--Sharing /////////////////////////////
		/*output wire [15:0] */    .seriesterminationcontrol(seriesterminationcontrol),     
		/*output wire [15:0] */    .parallelterminationcontrol(parallelterminationcontrol),   
		/*output wire [15:0] */    .seriesterminationcontrol_1(seriesterminationcontrol_1),   
		/*output wire [15:0] */    .parallelterminationcontrol_1(parallelterminationcontrol_1), 
		/*output wire [15:0] */    .seriesterminationcontrol_2(seriesterminationcontrol_2),   
		/*output wire [15:0] */    .parallelterminationcontrol_2(parallelterminationcontrol_2), 
		/*output wire        */    .pll_mem_clk(pll_mem_clk),                  
		/*output wire        */    .pll_write_clk(pll_write_clk),                
		/*output wire        */    .pll_write_clk_pre_phy_clk(pll_write_clk_pre_phy_clk),    
		/*output wire        */    .pll_addr_cmd_clk(pll_addr_cmd_clk),             
		/*output wire        */    .pll_locked(pll_locked),                   
		/*output wire        */    .pll_avl_clk(pll_avl_clk),                  
		/*output wire        */    .pll_config_clk(pll_config_clk),               
		/*output wire        */    .pll_p2c_read_clk(pll_p2c_read_clk),             
		/*output wire        */    .pll_c2p_write_clk(pll_c2p_write_clk),            
		/*output wire        */    .pll_mem_clk_1(pll_mem_clk_1),                
		/*output wire        */    .pll_write_clk_1(pll_write_clk_1),              
		/*output wire        */    .pll_write_clk_pre_phy_clk_1(pll_write_clk_pre_phy_clk_1),  
		/*output wire        */    .pll_addr_cmd_clk_1(pll_addr_cmd_clk_1),           
		/*output wire        */    .pll_locked_1(pll_locked_1),                 
		/*output wire        */    .pll_avl_clk_1(pll_avl_clk_1),                
		/*output wire        */    .pll_config_clk_1(pll_config_clk_1),             
		/*output wire        */    .pll_p2c_read_clk_1(pll_p2c_read_clk_1),           
		/*output wire        */    .pll_c2p_write_clk_1(pll_c2p_write_clk_1),          
		/*output wire [6:0]  */    .dll_delayctrl(dll_delayctrl),                
		/*output wire [6:0]  */    .dll_delayctrl_1(dll_delayctrl_1)               
		
	);


//QDRII_C
QDRII_SLAVE QDRII_C (
//		.pll_ref_clk                (pll_ref_clk_for_A_B_C),                //     pll_ref_clk.clk
		.global_reset_n             (global_reset_n),             //    global_reset.reset_n
		.soft_reset_n               (soft_reset_n),               //      soft_reset.reset_n
		.afi_clk                    (afi_clk_of_A_B_C),                    //      afi_clk_in.clk
		.afi_half_clk               (afi_half_clk_of_A_B_C),               // afi_half_clk_in.clk
		.afi_reset_n                (afi_reset_n_of_A_B_C),                //    afi_reset_in.reset_n
	///////////////////////////////////////////////////////////////////////////////////////////////////
    
   	.mem_d                      (qdriic_mem_d),                      //          memory.mem_d
		.mem_wps_n                  (qdriic_mem_wps_n),                  //                .mem_wps_n
		.mem_bws_n                  (qdriic_mem_bws_n),                  //                .mem_bws_n
		.mem_a                      (qdriic_mem_a),                      //                .mem_a
		.mem_q                      (qdriic_mem_q),                      //                .mem_q
		.mem_rps_n                  (qdriic_mem_rps_n),                  //                .mem_rps_n
		.mem_k                      (qdriic_mem_k),                      //                .mem_k
		.mem_k_n                    (qdriic_mem_k_n),                    //                .mem_k_n
		.mem_cq                     (qdriic_mem_cq),                     //                .mem_cq
		.mem_cq_n                   (qdriic_mem_cq_n),                   //                .mem_cq_n
		.mem_doff_n                 (qdriic_mem_doff_n),                 //                .mem_doff_n
		
		.avl_w_write_req            (qdriic_avl_w_write_req),            //           avl_w.write
		.avl_w_ready                (qdriic_avl_w_ready),                //                .waitrequest_n
		.avl_w_addr                 (qdriic_avl_w_addr),                 //                .address
		.avl_w_size                 (qdriic_avl_w_size),                 //                .burstcount
		.avl_w_wdata                (qdriic_avl_w_wdata),                //                .writedata
		.avl_r_read_req             (qdriic_avl_r_read_req),             //           avl_r.read
		.avl_r_ready                (qdriic_avl_r_ready),                //                .waitrequest_n
		.avl_r_addr                 (qdriic_avl_r_addr),                 //                .address
		.avl_r_size                 (qdriic_avl_r_size),                 //                .burstcount
		.avl_r_rdata_valid          (qdriic_avl_r_rdata_valid),          //                .readdatavalid
		.avl_r_rdata                (qdriic_avl_r_rdata),                //                .readdata
		
		.local_init_done            (qdriic_local_init_done),            //          status.local_init_done
		.local_cal_success          (qdriic_local_cal_success),          //                .local_cal_success
		.local_cal_fail             (qdriic_local_cal_fail),             //                .local_cal_failal_fail

		///////////pll dll oct--Sharing /////////////////////////////
		.seriesterminationcontrol   (seriesterminationcontrol_1),   //     oct_sharing.seriesterminationcontrol
		.parallelterminationcontrol (parallelterminationcontrol_1), //                .parallelterminationcontrol
		.pll_mem_clk                (pll_mem_clk_1),                //     pll_sharing.pll_mem_clk
		.pll_write_clk              (pll_write_clk_1),              //                .pll_write_clk
		.pll_write_clk_pre_phy_clk  (pll_write_clk_pre_phy_clk_1),  //                .pll_write_clk_pre_phy_clk
		.pll_addr_cmd_clk           (pll_addr_cmd_clk_1),           //                .pll_addr_cmd_clk
		.pll_locked                 (pll_locked_1),                 //                .pll_locked
		.pll_avl_clk                (pll_avl_clk_1),                //                .pll_avl_clk
		.pll_config_clk             (pll_config_clk_1),             //                .pll_config_clk
		.pll_p2c_read_clk           (pll_p2c_read_clk_1),           //                .pll_p2c_read_clk
		.pll_c2p_write_clk          (pll_c2p_write_clk_1),          //                .pll_c2p_write_clk
		.dll_delayctrl              (dll_delayctrl_1)               //     dll_sharing.dll_delayctrl
	);
	
	
//QDRII_D
QDRII_D QDRII_D (
		.pll_ref_clk                (pll_ref_clk_for_D),                //     pll_ref_clk.clk
		.global_reset_n             (global_reset_n),             //    global_reset.reset_n
		.soft_reset_n               (soft_reset_n),               //      soft_reset.reset_n
		.afi_clk                    (afi_clk_of_D),                    //      afi_clk_in.clk
		.afi_half_clk               (afi_half_clk_of_D),               // afi_half_clk_in.clk
		.afi_reset_n                (afi_reset_n_of_D),                //    afi_reset_in.reset_n
		///////////////////////////////////////////////////////////////////////////////////////////////////
    
   	.mem_d                      (qdriid_mem_d),                      //          memory.mem_d
		.mem_wps_n                  (qdriid_mem_wps_n),                  //                .mem_wps_n
		.mem_bws_n                  (qdriid_mem_bws_n),                  //                .mem_bws_n
		.mem_a                      (qdriid_mem_a),                      //                .mem_a
		.mem_q                      (qdriid_mem_q),                      //                .mem_q
		.mem_rps_n                  (qdriid_mem_rps_n),                  //                .mem_rps_n
		.mem_k                      (qdriid_mem_k),                      //                .mem_k
		.mem_k_n                    (qdriid_mem_k_n),                    //                .mem_k_n
		.mem_cq                     (qdriid_mem_cq),                     //                .mem_cq
		.mem_cq_n                   (qdriid_mem_cq_n),                   //                .mem_cq_n
		.mem_doff_n                 (qdriid_mem_doff_n),                 //                .mem_doff_n
		
		.avl_w_write_req            (qdriid_avl_w_write_req),            //           avl_w.write
		.avl_w_ready                (qdriid_avl_w_ready),                //                .waitrequest_n
		.avl_w_addr                 (qdriid_avl_w_addr),                 //                .address
		.avl_w_size                 (qdriid_avl_w_size),                 //                .burstcount
		.avl_w_wdata                (qdriid_avl_w_wdata),                //                .writedata
		.avl_r_read_req             (qdriid_avl_r_read_req),             //           avl_r.read
		.avl_r_ready                (qdriid_avl_r_ready),                //                .waitrequest_n
		.avl_r_addr                 (qdriid_avl_r_addr),                 //                .address
		.avl_r_size                 (qdriid_avl_r_size),                 //                .burstcount
		.avl_r_rdata_valid          (qdriid_avl_r_rdata_valid),          //                .readdatavalid
		.avl_r_rdata                (qdriid_avl_r_rdata),                //                .readdata
		
		.local_init_done            (qdriid_local_init_done),            //          status.local_init_done
		.local_cal_success          (qdriid_local_cal_success),          //                .local_cal_success
		.local_cal_fail             (qdriid_local_cal_fail),             //                .local_cal_failal_fail
		
		///////////oct-Sharing from QDRII B /////////////////////////////
		.seriesterminationcontrol   (seriesterminationcontrol_2),   //     oct_sharing.seriesterminationcontrol
		.parallelterminationcontrol (parallelterminationcontrol_2) //                .parallelterminationcontrol
		);

endmodule
