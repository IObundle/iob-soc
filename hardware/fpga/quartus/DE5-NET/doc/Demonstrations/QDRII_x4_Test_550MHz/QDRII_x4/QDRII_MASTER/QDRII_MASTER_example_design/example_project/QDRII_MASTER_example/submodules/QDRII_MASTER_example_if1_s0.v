// QDRII_MASTER_example_if1_s0.v

// This file was auto-generated from qsys_sequencer_110_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 16.1 203

`timescale 1 ps / 1 ps
module QDRII_MASTER_example_if1_s0 (
		input  wire        avl_clk,                     //          avl_clk.clk
		input  wire        avl_reset_n,                 //    sequencer_rst.reset
		input  wire        phy_clk,                     //              phy.phy_clk
		input  wire        phy_reset_n,                 //                 .phy_reset_n
		output wire [3:0]  phy_read_latency_counter,    //                 .phy_read_latency_counter
		output wire [5:0]  phy_afi_wlat,                //                 .phy_afi_wlat
		output wire [5:0]  phy_afi_rlat,                //                 .phy_afi_rlat
		output wire [0:0]  phy_read_increment_vfifo_fr, //                 .phy_read_increment_vfifo_fr
		output wire [0:0]  phy_read_increment_vfifo_hr, //                 .phy_read_increment_vfifo_hr
		output wire [0:0]  phy_read_increment_vfifo_qr, //                 .phy_read_increment_vfifo_qr
		output wire        phy_reset_mem_stable,        //                 .phy_reset_mem_stable
		output wire        phy_cal_success,             //                 .phy_cal_success
		output wire        phy_cal_fail,                //                 .phy_cal_fail
		output wire [31:0] phy_cal_debug_info,          //                 .phy_cal_debug_info
		output wire [0:0]  phy_read_fifo_reset,         //                 .phy_read_fifo_reset
		output wire [0:0]  phy_vfifo_rd_en_override,    //                 .phy_vfifo_rd_en_override
		input  wire [71:0] phy_read_fifo_q,             //                 .phy_read_fifo_q
		output wire [1:0]  phy_write_fr_cycle_shifts,   //                 .phy_write_fr_cycle_shifts
		output wire        phy_mux_sel,                 //          mux_sel.mux_sel
		input  wire [7:0]  calib_skip_steps,            //            calib.calib_skip_steps
		input  wire        afi_clk,                     //          afi_clk.clk
		input  wire        afi_reset_n,                 //        afi_reset.reset_n
		output wire [39:0] afi_addr,                    //              afi.afi_addr
		output wire [1:0]  afi_wps_n,                   //                 .afi_wps_n
		output wire [1:0]  afi_rps_n,                   //                 .afi_rps_n
		output wire [1:0]  afi_doff_n,                  //                 .afi_doff_n
		output wire [71:0] afi_wdata,                   //                 .afi_wdata
		output wire [1:0]  afi_wdata_valid,             //                 .afi_wdata_valid
		output wire [7:0]  afi_bws_n,                   //                 .afi_bws_n
		output wire [1:0]  afi_rdata_en,                //                 .afi_rdata_en
		output wire [1:0]  afi_rdata_en_full,           //                 .afi_rdata_en_full
		input  wire [71:0] afi_rdata,                   //                 .afi_rdata
		input  wire [1:0]  afi_rdata_valid,             //                 .afi_rdata_valid
		output wire [0:0]  scc_data,                    //              scc.scc_data
		output wire [0:0]  scc_dqs_ena,                 //                 .scc_dqs_ena
		output wire [0:0]  scc_dqs_io_ena,              //                 .scc_dqs_io_ena
		output wire [17:0] scc_dq_ena,                  //                 .scc_dq_ena
		output wire [1:0]  scc_dm_ena,                  //                 .scc_dm_ena
		input  wire [0:0]  capture_strobe_tracking,     //                 .capture_strobe_tracking
		output wire [0:0]  scc_upd,                     //                 .scc_upd
		input  wire        afi_init_req,                // afi_init_cal_req.afi_init_req
		input  wire        afi_cal_req,                 //                 .afi_cal_req
		input  wire        scc_clk,                     //          scc_clk.clk
		input  wire        reset_n_scc_clk              //        scc_reset.reset_n
	);

	wire         sequencer_rst_reset_out_reset;                             // sequencer_rst:reset_out -> [cpu_inst:reset_n, irq_mapper:reset, mm_interconnect_0:cpu_inst_reset_n_reset_bridge_in_reset_reset, sequencer_data_mgr_inst:avl_reset_n, sequencer_mem:reset1, sequencer_phy_mgr_inst:avl_reset_n, sequencer_reg_file_inst:avl_reset_n, sequencer_rw_mgr_inst:avl_reset_n, sequencer_scc_mgr_inst:avl_reset_n]
	wire         sequencer_rst_clken_out_clken;                             // sequencer_rst:clken_out -> sequencer_mem:clken1
	wire  [31:0] cpu_inst_data_master_readdata;                             // mm_interconnect_0:cpu_inst_data_master_readdata -> cpu_inst:d_readdata
	wire         cpu_inst_data_master_waitrequest;                          // mm_interconnect_0:cpu_inst_data_master_waitrequest -> cpu_inst:d_waitrequest
	wire  [19:0] cpu_inst_data_master_address;                              // cpu_inst:d_address -> mm_interconnect_0:cpu_inst_data_master_address
	wire   [3:0] cpu_inst_data_master_byteenable;                           // cpu_inst:d_byteenable -> mm_interconnect_0:cpu_inst_data_master_byteenable
	wire         cpu_inst_data_master_read;                                 // cpu_inst:d_read -> mm_interconnect_0:cpu_inst_data_master_read
	wire         cpu_inst_data_master_write;                                // cpu_inst:d_write -> mm_interconnect_0:cpu_inst_data_master_write
	wire  [31:0] cpu_inst_data_master_writedata;                            // cpu_inst:d_writedata -> mm_interconnect_0:cpu_inst_data_master_writedata
	wire  [31:0] cpu_inst_instruction_master_readdata;                      // mm_interconnect_0:cpu_inst_instruction_master_readdata -> cpu_inst:i_readdata
	wire         cpu_inst_instruction_master_waitrequest;                   // mm_interconnect_0:cpu_inst_instruction_master_waitrequest -> cpu_inst:i_waitrequest
	wire  [16:0] cpu_inst_instruction_master_address;                       // cpu_inst:i_address -> mm_interconnect_0:cpu_inst_instruction_master_address
	wire         cpu_inst_instruction_master_read;                          // cpu_inst:i_read -> mm_interconnect_0:cpu_inst_instruction_master_read
	wire  [31:0] mm_interconnect_0_sequencer_phy_mgr_inst_avl_readdata;     // sequencer_phy_mgr_inst:avl_readdata -> mm_interconnect_0:sequencer_phy_mgr_inst_avl_readdata
	wire         mm_interconnect_0_sequencer_phy_mgr_inst_avl_waitrequest;  // sequencer_phy_mgr_inst:avl_waitrequest -> mm_interconnect_0:sequencer_phy_mgr_inst_avl_waitrequest
	wire  [12:0] mm_interconnect_0_sequencer_phy_mgr_inst_avl_address;      // mm_interconnect_0:sequencer_phy_mgr_inst_avl_address -> sequencer_phy_mgr_inst:avl_address
	wire         mm_interconnect_0_sequencer_phy_mgr_inst_avl_read;         // mm_interconnect_0:sequencer_phy_mgr_inst_avl_read -> sequencer_phy_mgr_inst:avl_read
	wire         mm_interconnect_0_sequencer_phy_mgr_inst_avl_write;        // mm_interconnect_0:sequencer_phy_mgr_inst_avl_write -> sequencer_phy_mgr_inst:avl_write
	wire  [31:0] mm_interconnect_0_sequencer_phy_mgr_inst_avl_writedata;    // mm_interconnect_0:sequencer_phy_mgr_inst_avl_writedata -> sequencer_phy_mgr_inst:avl_writedata
	wire  [31:0] mm_interconnect_0_sequencer_data_mgr_inst_avl_readdata;    // sequencer_data_mgr_inst:avl_readdata -> mm_interconnect_0:sequencer_data_mgr_inst_avl_readdata
	wire         mm_interconnect_0_sequencer_data_mgr_inst_avl_waitrequest; // sequencer_data_mgr_inst:avl_waitrequest -> mm_interconnect_0:sequencer_data_mgr_inst_avl_waitrequest
	wire  [12:0] mm_interconnect_0_sequencer_data_mgr_inst_avl_address;     // mm_interconnect_0:sequencer_data_mgr_inst_avl_address -> sequencer_data_mgr_inst:avl_address
	wire         mm_interconnect_0_sequencer_data_mgr_inst_avl_read;        // mm_interconnect_0:sequencer_data_mgr_inst_avl_read -> sequencer_data_mgr_inst:avl_read
	wire         mm_interconnect_0_sequencer_data_mgr_inst_avl_write;       // mm_interconnect_0:sequencer_data_mgr_inst_avl_write -> sequencer_data_mgr_inst:avl_write
	wire  [31:0] mm_interconnect_0_sequencer_data_mgr_inst_avl_writedata;   // mm_interconnect_0:sequencer_data_mgr_inst_avl_writedata -> sequencer_data_mgr_inst:avl_writedata
	wire  [31:0] mm_interconnect_0_sequencer_rw_mgr_inst_avl_readdata;      // sequencer_rw_mgr_inst:avl_readdata -> mm_interconnect_0:sequencer_rw_mgr_inst_avl_readdata
	wire         mm_interconnect_0_sequencer_rw_mgr_inst_avl_waitrequest;   // sequencer_rw_mgr_inst:avl_waitrequest -> mm_interconnect_0:sequencer_rw_mgr_inst_avl_waitrequest
	wire  [12:0] mm_interconnect_0_sequencer_rw_mgr_inst_avl_address;       // mm_interconnect_0:sequencer_rw_mgr_inst_avl_address -> sequencer_rw_mgr_inst:avl_address
	wire         mm_interconnect_0_sequencer_rw_mgr_inst_avl_read;          // mm_interconnect_0:sequencer_rw_mgr_inst_avl_read -> sequencer_rw_mgr_inst:avl_read
	wire         mm_interconnect_0_sequencer_rw_mgr_inst_avl_write;         // mm_interconnect_0:sequencer_rw_mgr_inst_avl_write -> sequencer_rw_mgr_inst:avl_write
	wire  [31:0] mm_interconnect_0_sequencer_rw_mgr_inst_avl_writedata;     // mm_interconnect_0:sequencer_rw_mgr_inst_avl_writedata -> sequencer_rw_mgr_inst:avl_writedata
	wire         mm_interconnect_0_sequencer_mem_s1_chipselect;             // mm_interconnect_0:sequencer_mem_s1_chipselect -> sequencer_mem:s1_chipselect
	wire  [31:0] mm_interconnect_0_sequencer_mem_s1_readdata;               // sequencer_mem:s1_readdata -> mm_interconnect_0:sequencer_mem_s1_readdata
	wire  [11:0] mm_interconnect_0_sequencer_mem_s1_address;                // mm_interconnect_0:sequencer_mem_s1_address -> sequencer_mem:s1_address
	wire   [3:0] mm_interconnect_0_sequencer_mem_s1_byteenable;             // mm_interconnect_0:sequencer_mem_s1_byteenable -> sequencer_mem:s1_be
	wire         mm_interconnect_0_sequencer_mem_s1_write;                  // mm_interconnect_0:sequencer_mem_s1_write -> sequencer_mem:s1_write
	wire  [31:0] mm_interconnect_0_sequencer_mem_s1_writedata;              // mm_interconnect_0:sequencer_mem_s1_writedata -> sequencer_mem:s1_writedata
	wire  [31:0] mm_interconnect_0_sequencer_scc_mgr_inst_avl_readdata;     // sequencer_scc_mgr_inst:avl_readdata -> mm_interconnect_0:sequencer_scc_mgr_inst_avl_readdata
	wire         mm_interconnect_0_sequencer_scc_mgr_inst_avl_waitrequest;  // sequencer_scc_mgr_inst:avl_waitrequest -> mm_interconnect_0:sequencer_scc_mgr_inst_avl_waitrequest
	wire  [12:0] mm_interconnect_0_sequencer_scc_mgr_inst_avl_address;      // mm_interconnect_0:sequencer_scc_mgr_inst_avl_address -> sequencer_scc_mgr_inst:avl_address
	wire         mm_interconnect_0_sequencer_scc_mgr_inst_avl_read;         // mm_interconnect_0:sequencer_scc_mgr_inst_avl_read -> sequencer_scc_mgr_inst:avl_read
	wire         mm_interconnect_0_sequencer_scc_mgr_inst_avl_write;        // mm_interconnect_0:sequencer_scc_mgr_inst_avl_write -> sequencer_scc_mgr_inst:avl_write
	wire  [31:0] mm_interconnect_0_sequencer_scc_mgr_inst_avl_writedata;    // mm_interconnect_0:sequencer_scc_mgr_inst_avl_writedata -> sequencer_scc_mgr_inst:avl_writedata
	wire  [31:0] mm_interconnect_0_sequencer_reg_file_inst_avl_readdata;    // sequencer_reg_file_inst:avl_readdata -> mm_interconnect_0:sequencer_reg_file_inst_avl_readdata
	wire         mm_interconnect_0_sequencer_reg_file_inst_avl_waitrequest; // sequencer_reg_file_inst:avl_waitrequest -> mm_interconnect_0:sequencer_reg_file_inst_avl_waitrequest
	wire   [3:0] mm_interconnect_0_sequencer_reg_file_inst_avl_address;     // mm_interconnect_0:sequencer_reg_file_inst_avl_address -> sequencer_reg_file_inst:avl_address
	wire         mm_interconnect_0_sequencer_reg_file_inst_avl_read;        // mm_interconnect_0:sequencer_reg_file_inst_avl_read -> sequencer_reg_file_inst:avl_read
	wire   [3:0] mm_interconnect_0_sequencer_reg_file_inst_avl_byteenable;  // mm_interconnect_0:sequencer_reg_file_inst_avl_byteenable -> sequencer_reg_file_inst:avl_be
	wire         mm_interconnect_0_sequencer_reg_file_inst_avl_write;       // mm_interconnect_0:sequencer_reg_file_inst_avl_write -> sequencer_reg_file_inst:avl_write
	wire  [31:0] mm_interconnect_0_sequencer_reg_file_inst_avl_writedata;   // mm_interconnect_0:sequencer_reg_file_inst_avl_writedata -> sequencer_reg_file_inst:avl_writedata
	wire  [31:0] cpu_inst_d_irq_irq;                                        // irq_mapper:sender_irq -> cpu_inst:d_irq

	altera_mem_if_sequencer_rst #(
		.DEPTH            (10),
		.CLKEN_LAGS_RESET (0)
	) sequencer_rst (
		.clk       (avl_clk),                       //       clk.clk
		.rst       (avl_reset_n),                   //       rst.reset
		.reset_out (sequencer_rst_reset_out_reset), // reset_out.reset
		.clken_out (sequencer_rst_clken_out_clken)  // clken_out.clken
	);

	altera_mem_if_sequencer_cpu_no_ifdef_params_synth_cpu_inst #(
		.DEVICE_FAMILY ("STRATIXV")
	) cpu_inst (
		.clk           (avl_clk),                                 //                       clk.clk
		.reset_n       (~sequencer_rst_reset_out_reset),          //                   reset_n.reset_n
		.d_address     (cpu_inst_data_master_address),            //               data_master.address
		.d_byteenable  (cpu_inst_data_master_byteenable),         //                          .byteenable
		.d_read        (cpu_inst_data_master_read),               //                          .read
		.d_readdata    (cpu_inst_data_master_readdata),           //                          .readdata
		.d_waitrequest (cpu_inst_data_master_waitrequest),        //                          .waitrequest
		.d_write       (cpu_inst_data_master_write),              //                          .write
		.d_writedata   (cpu_inst_data_master_writedata),          //                          .writedata
		.i_address     (cpu_inst_instruction_master_address),     //        instruction_master.address
		.i_read        (cpu_inst_instruction_master_read),        //                          .read
		.i_readdata    (cpu_inst_instruction_master_readdata),    //                          .readdata
		.i_waitrequest (cpu_inst_instruction_master_waitrequest), //                          .waitrequest
		.d_irq         (cpu_inst_d_irq_irq),                      //                     d_irq.irq
		.no_ci_readra  ()                                         // custom_instruction_master.readra
	);

	sequencer_scc_mgr #(
		.AVL_DATA_WIDTH         (32),
		.AVL_ADDR_WIDTH         (13),
		.MEM_IF_READ_DQS_WIDTH  (1),
		.MEM_IF_WRITE_DQS_WIDTH (1),
		.MEM_IF_DQ_WIDTH        (18),
		.MEM_IF_DM_WIDTH        (2),
		.MEM_NUMBER_OF_RANKS    (1),
		.DLL_DELAY_CHAIN_LENGTH (8),
		.FAMILY                 ("STRATIXV"),
		.USE_2X_DLL             ("false"),
		.USE_SHADOW_REGS        (0),
		.USE_DQS_TRACKING       (0),
		.DUAL_WRITE_CLOCK       (0),
		.SCC_DATA_WIDTH         (1),
		.TRK_PARALLEL_SCC_LOAD  (0)
	) sequencer_scc_mgr_inst (
		.avl_clk                      (avl_clk),                                                  //          avl_clk.clk
		.avl_reset_n                  (~sequencer_rst_reset_out_reset),                           //        avl_reset.reset_n
		.avl_address                  (mm_interconnect_0_sequencer_scc_mgr_inst_avl_address),     //              avl.address
		.avl_write                    (mm_interconnect_0_sequencer_scc_mgr_inst_avl_write),       //                 .write
		.avl_writedata                (mm_interconnect_0_sequencer_scc_mgr_inst_avl_writedata),   //                 .writedata
		.avl_read                     (mm_interconnect_0_sequencer_scc_mgr_inst_avl_read),        //                 .read
		.avl_readdata                 (mm_interconnect_0_sequencer_scc_mgr_inst_avl_readdata),    //                 .readdata
		.avl_waitrequest              (mm_interconnect_0_sequencer_scc_mgr_inst_avl_waitrequest), //                 .waitrequest
		.scc_clk                      (scc_clk),                                                  //          scc_clk.clk
		.scc_reset_n                  (reset_n_scc_clk),                                          //        scc_reset.reset_n
		.scc_data                     (scc_data),                                                 //              scc.scc_data
		.scc_dqs_ena                  (scc_dqs_ena),                                              //                 .scc_dqs_ena
		.scc_dqs_io_ena               (scc_dqs_io_ena),                                           //                 .scc_dqs_io_ena
		.scc_dq_ena                   (scc_dq_ena),                                               //                 .scc_dq_ena
		.scc_dm_ena                   (scc_dm_ena),                                               //                 .scc_dm_ena
		.capture_strobe_tracking      (capture_strobe_tracking),                                  //                 .capture_strobe_tracking
		.scc_upd                      (scc_upd),                                                  //                 .scc_upd
		.afi_init_req                 (afi_init_req),                                             // afi_init_cal_req.afi_init_req
		.afi_cal_req                  (afi_cal_req),                                              //                 .afi_cal_req
		.scc_sr_dqsenable_delayctrl   (),                                                         //      (terminated)
		.scc_sr_dqsdisablen_delayctrl (),                                                         //      (terminated)
		.scc_sr_multirank_delayctrl   ()                                                          //      (terminated)
	);

	sequencer_reg_file #(
		.AVL_DATA_WIDTH    (32),
		.AVL_ADDR_WIDTH    (4),
		.AVL_NUM_SYMBOLS   (4),
		.AVL_SYMBOL_WIDTH  (8),
		.REGISTER_RDATA    (0),
		.NUM_REGFILE_WORDS (16)
	) sequencer_reg_file_inst (
		.avl_clk         (avl_clk),                                                   //   avl_clk.clk
		.avl_reset_n     (~sequencer_rst_reset_out_reset),                            // avl_reset.reset_n
		.avl_address     (mm_interconnect_0_sequencer_reg_file_inst_avl_address),     //       avl.address
		.avl_write       (mm_interconnect_0_sequencer_reg_file_inst_avl_write),       //          .write
		.avl_writedata   (mm_interconnect_0_sequencer_reg_file_inst_avl_writedata),   //          .writedata
		.avl_read        (mm_interconnect_0_sequencer_reg_file_inst_avl_read),        //          .read
		.avl_readdata    (mm_interconnect_0_sequencer_reg_file_inst_avl_readdata),    //          .readdata
		.avl_waitrequest (mm_interconnect_0_sequencer_reg_file_inst_avl_waitrequest), //          .waitrequest
		.avl_be          (mm_interconnect_0_sequencer_reg_file_inst_avl_byteenable)   //          .byteenable
	);

	sequencer_phy_mgr #(
		.AVL_DATA_WIDTH                    (32),
		.AVL_ADDR_WIDTH                    (13),
		.MAX_LATENCY_COUNT_WIDTH           (4),
		.MEM_IF_READ_DQS_WIDTH             (1),
		.MEM_IF_WRITE_DQS_WIDTH            (1),
		.AFI_DQ_WIDTH                      (72),
		.AFI_DEBUG_INFO_WIDTH              (32),
		.AFI_MAX_WRITE_LATENCY_COUNT_WIDTH (6),
		.AFI_MAX_READ_LATENCY_COUNT_WIDTH  (6),
		.CALIB_VFIFO_OFFSET                (9),
		.CALIB_LFIFO_OFFSET                (3),
		.CALIB_REG_WIDTH                   (8),
		.READ_VALID_FIFO_SIZE              (16),
		.MEM_T_WL                          (1),
		.MEM_T_RL                          (2),
		.CTL_REGDIMM_ENABLED               (0),
		.NUM_WRITE_FR_CYCLE_SHIFTS         (1),
		.VFIFO_CONTROL_WIDTH_PER_DQS       (1),
		.DEVICE_FAMILY                     ("STRATIXV")
	) sequencer_phy_mgr_inst (
		.avl_clk                     (avl_clk),                                                  //   avl_clk.clk
		.avl_reset_n                 (~sequencer_rst_reset_out_reset),                           // avl_reset.reset_n
		.avl_address                 (mm_interconnect_0_sequencer_phy_mgr_inst_avl_address),     //       avl.address
		.avl_write                   (mm_interconnect_0_sequencer_phy_mgr_inst_avl_write),       //          .write
		.avl_writedata               (mm_interconnect_0_sequencer_phy_mgr_inst_avl_writedata),   //          .writedata
		.avl_read                    (mm_interconnect_0_sequencer_phy_mgr_inst_avl_read),        //          .read
		.avl_readdata                (mm_interconnect_0_sequencer_phy_mgr_inst_avl_readdata),    //          .readdata
		.avl_waitrequest             (mm_interconnect_0_sequencer_phy_mgr_inst_avl_waitrequest), //          .waitrequest
		.phy_clk                     (phy_clk),                                                  //       phy.phy_clk
		.phy_reset_n                 (phy_reset_n),                                              //          .phy_reset_n
		.phy_read_latency_counter    (phy_read_latency_counter),                                 //          .phy_read_latency_counter
		.phy_afi_wlat                (phy_afi_wlat),                                             //          .phy_afi_wlat
		.phy_afi_rlat                (phy_afi_rlat),                                             //          .phy_afi_rlat
		.phy_read_increment_vfifo_fr (phy_read_increment_vfifo_fr),                              //          .phy_read_increment_vfifo_fr
		.phy_read_increment_vfifo_hr (phy_read_increment_vfifo_hr),                              //          .phy_read_increment_vfifo_hr
		.phy_read_increment_vfifo_qr (phy_read_increment_vfifo_qr),                              //          .phy_read_increment_vfifo_qr
		.phy_reset_mem_stable        (phy_reset_mem_stable),                                     //          .phy_reset_mem_stable
		.phy_cal_success             (phy_cal_success),                                          //          .phy_cal_success
		.phy_cal_fail                (phy_cal_fail),                                             //          .phy_cal_fail
		.phy_cal_debug_info          (phy_cal_debug_info),                                       //          .phy_cal_debug_info
		.phy_read_fifo_reset         (phy_read_fifo_reset),                                      //          .phy_read_fifo_reset
		.phy_vfifo_rd_en_override    (phy_vfifo_rd_en_override),                                 //          .phy_vfifo_rd_en_override
		.phy_read_fifo_q             (phy_read_fifo_q),                                          //          .phy_read_fifo_q
		.phy_write_fr_cycle_shifts   (phy_write_fr_cycle_shifts),                                //          .phy_write_fr_cycle_shifts
		.calib_skip_steps            (calib_skip_steps),                                         //     calib.calib_skip_steps
		.phy_mux_sel                 (phy_mux_sel)                                               //   mux_sel.mux_sel
	);

	sequencer_data_mgr #(
		.AVL_DATA_WIDTH                    (32),
		.AVL_ADDR_WIDTH                    (13),
		.MAX_LATENCY_COUNT_WIDTH           (4),
		.MEM_READ_DQS_WIDTH                (1),
		.AFI_DEBUG_INFO_WIDTH              (32),
		.AFI_MAX_WRITE_LATENCY_COUNT_WIDTH (6),
		.AFI_MAX_READ_LATENCY_COUNT_WIDTH  (6),
		.CALIB_VFIFO_OFFSET                (9),
		.CALIB_LFIFO_OFFSET                (3),
		.CALIB_SKIP_STEPS_WIDTH            (8),
		.READ_VALID_FIFO_SIZE              (16),
		.MEM_T_WL                          (1),
		.MEM_T_RL                          (2),
		.CTL_REGDIMM_ENABLED               (0),
		.SEQUENCER_VERSION                 (16)
	) sequencer_data_mgr_inst (
		.avl_clk         (avl_clk),                                                   //   avl_clk.clk
		.avl_reset_n     (~sequencer_rst_reset_out_reset),                            // avl_reset.reset_n
		.avl_address     (mm_interconnect_0_sequencer_data_mgr_inst_avl_address),     //       avl.address
		.avl_write       (mm_interconnect_0_sequencer_data_mgr_inst_avl_write),       //          .write
		.avl_writedata   (mm_interconnect_0_sequencer_data_mgr_inst_avl_writedata),   //          .writedata
		.avl_read        (mm_interconnect_0_sequencer_data_mgr_inst_avl_read),        //          .read
		.avl_readdata    (mm_interconnect_0_sequencer_data_mgr_inst_avl_readdata),    //          .readdata
		.avl_waitrequest (mm_interconnect_0_sequencer_data_mgr_inst_avl_waitrequest)  //          .waitrequest
	);

	rw_manager_qdrii #(
		.RATE                                 ("Half"),
		.AVL_DATA_WIDTH                       (32),
		.AVL_ADDR_WIDTH                       (13),
		.MEM_ADDRESS_WIDTH                    (20),
		.MEM_CONTROL_WIDTH                    (1),
		.MEM_DQ_WIDTH                         (18),
		.MEM_DM_WIDTH                         (2),
		.MEM_CHIP_SELECT_WIDTH                (1),
		.VIRTUAL_MEM_READ_DQS_WIDTH           (2),
		.MEM_READ_DQS_WIDTH                   (1),
		.VIRTUAL_MEM_WRITE_DQS_WIDTH          (2),
		.MEM_WRITE_DQS_WIDTH                  (1),
		.MEM_BURST_LENGTH                     (4),
		.AFI_RATIO                            (2),
		.AC_BUS_WIDTH                         (27),
		.HCX_COMPAT_MODE                      (0),
		.DEVICE_FAMILY                        ("STRATIXV"),
		.AC_ROM_INIT_FILE_NAME                ("QDRII_MASTER_example_if1_s0_AC_ROM.hex"),
		.INST_ROM_INIT_FILE_NAME              ("QDRII_MASTER_example_if1_s0_inst_ROM.hex"),
		.DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT (2),
		.DEBUG_WRITE_TO_READ_RATIO            (3),
		.MAX_DI_BUFFER_WORDS_LOG_2            (3)
	) sequencer_rw_mgr_inst (
		.avl_clk           (avl_clk),                                                 //   avl_clk.clk
		.avl_reset_n       (~sequencer_rst_reset_out_reset),                          // avl_reset.reset_n
		.avl_address       (mm_interconnect_0_sequencer_rw_mgr_inst_avl_address),     //       avl.address
		.avl_write         (mm_interconnect_0_sequencer_rw_mgr_inst_avl_write),       //          .write
		.avl_writedata     (mm_interconnect_0_sequencer_rw_mgr_inst_avl_writedata),   //          .writedata
		.avl_read          (mm_interconnect_0_sequencer_rw_mgr_inst_avl_read),        //          .read
		.avl_readdata      (mm_interconnect_0_sequencer_rw_mgr_inst_avl_readdata),    //          .readdata
		.avl_waitrequest   (mm_interconnect_0_sequencer_rw_mgr_inst_avl_waitrequest), //          .waitrequest
		.afi_clk           (afi_clk),                                                 //   afi_clk.clk
		.afi_reset_n       (afi_reset_n),                                             // afi_reset.reset_n
		.afi_addr          (afi_addr),                                                //       afi.afi_addr
		.afi_wps_n         (afi_wps_n),                                               //          .afi_wps_n
		.afi_rps_n         (afi_rps_n),                                               //          .afi_rps_n
		.afi_doff_n        (afi_doff_n),                                              //          .afi_doff_n
		.afi_wdata         (afi_wdata),                                               //          .afi_wdata
		.afi_wdata_valid   (afi_wdata_valid),                                         //          .afi_wdata_valid
		.afi_bws_n         (afi_bws_n),                                               //          .afi_bws_n
		.afi_rdata_en      (afi_rdata_en),                                            //          .afi_rdata_en
		.afi_rdata_en_full (afi_rdata_en_full),                                       //          .afi_rdata_en_full
		.afi_rdata         (afi_rdata),                                               //          .afi_rdata
		.afi_rdata_valid   (afi_rdata_valid),                                         //          .afi_rdata_valid
		.csr_clk           (),                                                        //       csr.csr_clk
		.csr_ena           (),                                                        //          .csr_ena
		.csr_dout_phy      (),                                                        //          .csr_dout_phy
		.csr_dout          ()                                                         //          .csr_dout
	);

	altera_mem_if_sequencer_mem_no_ifdef_params #(
		.AVL_DATA_WIDTH   (32),
		.AVL_ADDR_WIDTH   (12),
		.AVL_NUM_SYMBOLS  (4),
		.AVL_SYMBOL_WIDTH (8),
		.MEM_SIZE         (11264),
		.INIT_FILE        ("QDRII_MASTER_example_if1_s0_sequencer_mem.hex"),
		.RAM_BLOCK_TYPE   ("AUTO")
	) sequencer_mem (
		.clk1          (avl_clk),                                       //   clk1.clk
		.reset1        (sequencer_rst_reset_out_reset),                 // reset1.reset
		.clken1        (sequencer_rst_clken_out_clken),                 // clken1.clken
		.s1_address    (mm_interconnect_0_sequencer_mem_s1_address),    //     s1.address
		.s1_write      (mm_interconnect_0_sequencer_mem_s1_write),      //       .write
		.s1_writedata  (mm_interconnect_0_sequencer_mem_s1_writedata),  //       .writedata
		.s1_readdata   (mm_interconnect_0_sequencer_mem_s1_readdata),   //       .readdata
		.s1_be         (mm_interconnect_0_sequencer_mem_s1_byteenable), //       .byteenable
		.s1_chipselect (mm_interconnect_0_sequencer_mem_s1_chipselect)  //       .chipselect
	);

	QDRII_MASTER_example_if1_s0_mm_interconnect_0 mm_interconnect_0 (
		.avl_clk_out_clk_clk                          (avl_clk),                                                   //                        avl_clk_out_clk.clk
		.cpu_inst_reset_n_reset_bridge_in_reset_reset (sequencer_rst_reset_out_reset),                             // cpu_inst_reset_n_reset_bridge_in_reset.reset
		.cpu_inst_data_master_address                 (cpu_inst_data_master_address),                              //                   cpu_inst_data_master.address
		.cpu_inst_data_master_waitrequest             (cpu_inst_data_master_waitrequest),                          //                                       .waitrequest
		.cpu_inst_data_master_byteenable              (cpu_inst_data_master_byteenable),                           //                                       .byteenable
		.cpu_inst_data_master_read                    (cpu_inst_data_master_read),                                 //                                       .read
		.cpu_inst_data_master_readdata                (cpu_inst_data_master_readdata),                             //                                       .readdata
		.cpu_inst_data_master_write                   (cpu_inst_data_master_write),                                //                                       .write
		.cpu_inst_data_master_writedata               (cpu_inst_data_master_writedata),                            //                                       .writedata
		.cpu_inst_instruction_master_address          (cpu_inst_instruction_master_address),                       //            cpu_inst_instruction_master.address
		.cpu_inst_instruction_master_waitrequest      (cpu_inst_instruction_master_waitrequest),                   //                                       .waitrequest
		.cpu_inst_instruction_master_read             (cpu_inst_instruction_master_read),                          //                                       .read
		.cpu_inst_instruction_master_readdata         (cpu_inst_instruction_master_readdata),                      //                                       .readdata
		.sequencer_data_mgr_inst_avl_address          (mm_interconnect_0_sequencer_data_mgr_inst_avl_address),     //            sequencer_data_mgr_inst_avl.address
		.sequencer_data_mgr_inst_avl_write            (mm_interconnect_0_sequencer_data_mgr_inst_avl_write),       //                                       .write
		.sequencer_data_mgr_inst_avl_read             (mm_interconnect_0_sequencer_data_mgr_inst_avl_read),        //                                       .read
		.sequencer_data_mgr_inst_avl_readdata         (mm_interconnect_0_sequencer_data_mgr_inst_avl_readdata),    //                                       .readdata
		.sequencer_data_mgr_inst_avl_writedata        (mm_interconnect_0_sequencer_data_mgr_inst_avl_writedata),   //                                       .writedata
		.sequencer_data_mgr_inst_avl_waitrequest      (mm_interconnect_0_sequencer_data_mgr_inst_avl_waitrequest), //                                       .waitrequest
		.sequencer_mem_s1_address                     (mm_interconnect_0_sequencer_mem_s1_address),                //                       sequencer_mem_s1.address
		.sequencer_mem_s1_write                       (mm_interconnect_0_sequencer_mem_s1_write),                  //                                       .write
		.sequencer_mem_s1_readdata                    (mm_interconnect_0_sequencer_mem_s1_readdata),               //                                       .readdata
		.sequencer_mem_s1_writedata                   (mm_interconnect_0_sequencer_mem_s1_writedata),              //                                       .writedata
		.sequencer_mem_s1_byteenable                  (mm_interconnect_0_sequencer_mem_s1_byteenable),             //                                       .byteenable
		.sequencer_mem_s1_chipselect                  (mm_interconnect_0_sequencer_mem_s1_chipselect),             //                                       .chipselect
		.sequencer_phy_mgr_inst_avl_address           (mm_interconnect_0_sequencer_phy_mgr_inst_avl_address),      //             sequencer_phy_mgr_inst_avl.address
		.sequencer_phy_mgr_inst_avl_write             (mm_interconnect_0_sequencer_phy_mgr_inst_avl_write),        //                                       .write
		.sequencer_phy_mgr_inst_avl_read              (mm_interconnect_0_sequencer_phy_mgr_inst_avl_read),         //                                       .read
		.sequencer_phy_mgr_inst_avl_readdata          (mm_interconnect_0_sequencer_phy_mgr_inst_avl_readdata),     //                                       .readdata
		.sequencer_phy_mgr_inst_avl_writedata         (mm_interconnect_0_sequencer_phy_mgr_inst_avl_writedata),    //                                       .writedata
		.sequencer_phy_mgr_inst_avl_waitrequest       (mm_interconnect_0_sequencer_phy_mgr_inst_avl_waitrequest),  //                                       .waitrequest
		.sequencer_reg_file_inst_avl_address          (mm_interconnect_0_sequencer_reg_file_inst_avl_address),     //            sequencer_reg_file_inst_avl.address
		.sequencer_reg_file_inst_avl_write            (mm_interconnect_0_sequencer_reg_file_inst_avl_write),       //                                       .write
		.sequencer_reg_file_inst_avl_read             (mm_interconnect_0_sequencer_reg_file_inst_avl_read),        //                                       .read
		.sequencer_reg_file_inst_avl_readdata         (mm_interconnect_0_sequencer_reg_file_inst_avl_readdata),    //                                       .readdata
		.sequencer_reg_file_inst_avl_writedata        (mm_interconnect_0_sequencer_reg_file_inst_avl_writedata),   //                                       .writedata
		.sequencer_reg_file_inst_avl_byteenable       (mm_interconnect_0_sequencer_reg_file_inst_avl_byteenable),  //                                       .byteenable
		.sequencer_reg_file_inst_avl_waitrequest      (mm_interconnect_0_sequencer_reg_file_inst_avl_waitrequest), //                                       .waitrequest
		.sequencer_rw_mgr_inst_avl_address            (mm_interconnect_0_sequencer_rw_mgr_inst_avl_address),       //              sequencer_rw_mgr_inst_avl.address
		.sequencer_rw_mgr_inst_avl_write              (mm_interconnect_0_sequencer_rw_mgr_inst_avl_write),         //                                       .write
		.sequencer_rw_mgr_inst_avl_read               (mm_interconnect_0_sequencer_rw_mgr_inst_avl_read),          //                                       .read
		.sequencer_rw_mgr_inst_avl_readdata           (mm_interconnect_0_sequencer_rw_mgr_inst_avl_readdata),      //                                       .readdata
		.sequencer_rw_mgr_inst_avl_writedata          (mm_interconnect_0_sequencer_rw_mgr_inst_avl_writedata),     //                                       .writedata
		.sequencer_rw_mgr_inst_avl_waitrequest        (mm_interconnect_0_sequencer_rw_mgr_inst_avl_waitrequest),   //                                       .waitrequest
		.sequencer_scc_mgr_inst_avl_address           (mm_interconnect_0_sequencer_scc_mgr_inst_avl_address),      //             sequencer_scc_mgr_inst_avl.address
		.sequencer_scc_mgr_inst_avl_write             (mm_interconnect_0_sequencer_scc_mgr_inst_avl_write),        //                                       .write
		.sequencer_scc_mgr_inst_avl_read              (mm_interconnect_0_sequencer_scc_mgr_inst_avl_read),         //                                       .read
		.sequencer_scc_mgr_inst_avl_readdata          (mm_interconnect_0_sequencer_scc_mgr_inst_avl_readdata),     //                                       .readdata
		.sequencer_scc_mgr_inst_avl_writedata         (mm_interconnect_0_sequencer_scc_mgr_inst_avl_writedata),    //                                       .writedata
		.sequencer_scc_mgr_inst_avl_waitrequest       (mm_interconnect_0_sequencer_scc_mgr_inst_avl_waitrequest)   //                                       .waitrequest
	);

	QDRII_MASTER_example_if1_s0_irq_mapper irq_mapper (
		.clk        (avl_clk),                       //       clk.clk
		.reset      (sequencer_rst_reset_out_reset), // clk_reset.reset
		.sender_irq (cpu_inst_d_irq_irq)             //    sender.irq
	);

endmodule
