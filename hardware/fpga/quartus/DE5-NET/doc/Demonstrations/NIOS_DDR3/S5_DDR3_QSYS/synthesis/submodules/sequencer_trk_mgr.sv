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


// ******
// trk_mgr
// ******
//
// TRK Manager
//
// General Description
// -------------------
//
// This component interface to the controller to stall it after refresh
// takes over AFI interface, trigger RW manager to issue DQS calibration routine
// and issue scc manager to update its dqs delay chain when count is reached
//

`timescale 1 ps / 1 ps

module sequencer_trk_mgr #
    ( parameter
        MEM_CHIP_SELECT_WIDTH   = 1,
        MEM_NUMBER_OF_RANKS     = 1,
        MEM_READ_DQS_WIDTH      = 2,
        AVL_DATA_WIDTH          = 32,
        AVL_MTR_ADDR_WIDTH      = 20, // should be larger than slave address since master is addressing a few slaves
        AVL_ADDR_WIDTH          = 6,
        RATE                    = "Half",
        PHASE_WIDTH             = 3,
        READ_VALID_FIFO_SIZE    = 5,
        MUX_SEL_SEQUENCER_VAL   = 1,
        MUX_SEL_CONTROLLER_VAL  = 0,
        PHY_MGR_BASE            = 20'h00000,
        RW_MGR_BASE             = 20'h08000,
        SCC_MGR_BASE            = 20'h10000,
        HARD_PHY                = 0,
        HARD_VFIFO              = 0,
        IO_DQS_EN_DELAY_OFFSET  = 0,
        LONGIDLE_COUNTER_WIDTH  = 24,
        TRK_PARALLEL_SCC_LOAD   = 0
    )
    (
    // AFI interface to controller
    afi_ctl_refresh_done,
    afi_seq_busy,
    afi_ctl_long_idle,
    
	// Avalon Interface	
	avl_clk,
	avl_reset_n,
	
	trkm_address,
	trkm_write,
	trkm_writedata,
	trkm_read,
	trkm_readdata,
	trkm_waitrequest,
	
	trks_address,
	trks_write,
	trks_writedata,
	trks_read,
	trks_readdata,
	trks_waitrequest
);

	input [MEM_NUMBER_OF_RANKS - 1:0] afi_ctl_refresh_done;
	output [MEM_NUMBER_OF_RANKS - 1:0] afi_seq_busy;
	input [MEM_NUMBER_OF_RANKS - 1:0] afi_ctl_long_idle;

	input avl_clk;
	input avl_reset_n;
	
	output [AVL_MTR_ADDR_WIDTH - 1:0] trkm_address;
	output trkm_write;
	output [AVL_DATA_WIDTH - 1:0] trkm_writedata;
	output trkm_read;
	input [AVL_DATA_WIDTH - 1:0] trkm_readdata;
	input trkm_waitrequest;
	
	input [AVL_ADDR_WIDTH - 1:0] trks_address;
	input trks_write;
	input [AVL_DATA_WIDTH - 1:0] trks_writedata;
	input trks_read;
	output [AVL_DATA_WIDTH - 1:0] trks_readdata;
	output trks_waitrequest;
	
    localparam PHY_MGR_MUX_SEL  =    PHY_MGR_BASE+20'h04008;
    localparam PHY_MGR_CMD_INC_VFIFO_FR         =   PHY_MGR_BASE+20'h00;
    localparam PHY_MGR_CMD_INC_VFIFO_HR         =   PHY_MGR_BASE+20'h04;
    localparam PHY_MGR_CMD_INC_VFIFO_HARD_PHY   =   PHY_MGR_BASE+20'h04;
    localparam PHY_MGR_CMD_INC_VFIFO_FR_HR      =   PHY_MGR_BASE+20'h0C;
    localparam PHY_MGR_CMD_INC_VFIFO_QR         =   PHY_MGR_BASE+20'h10;
    localparam RW_MGR_JMPCOUNT  =    RW_MGR_BASE+20'h800;
    localparam RW_MGR_JMPADDR   =    RW_MGR_BASE+20'hC00;
    localparam SCC_MGR_DO_SMPL  =    SCC_MGR_BASE+20'h00FFF;
    localparam SCC_MGR_SAMPLE   =    SCC_MGR_BASE+20'h00F00;
    localparam SCC_MGR_PHS      =    SCC_MGR_BASE+20'h00200;
    localparam SCC_MGR_DEL      =    SCC_MGR_BASE+20'h00300;
    localparam SCC_MGR_SER_SCAN =    SCC_MGR_BASE+20'h00E00;
    localparam SCC_MGR_PAR_SCAN =    SCC_MGR_BASE+20'h01E00; 
    localparam SCC_MGR_UPDATE   =    SCC_MGR_BASE+20'h00E20;
    localparam REG_FILE_DTAP    =    0;
    localparam REG_FILE_SMPL    =    1;
    localparam REG_FILE_LGIDL   =    2;
    localparam REG_FILE_DELAY   =    3;
    localparam REG_FILE_ADDR    =    4;
    localparam REG_FILE_NUM_DQS =    5;
    localparam REG_FILE_RFSH    =    6;
    localparam REG_FILE_STALL   =    7;
    localparam REG_FILE_VPOINT  =    8; 
	localparam REG_FILE_DEPTH   =    REG_FILE_VPOINT + MEM_READ_DQS_WIDTH; 
    
    localparam VFIFO_DEPTH	= READ_VALID_FIFO_SIZE;
    localparam VFIFO_DEPTH_LOG2	= ceil_log2(READ_VALID_FIFO_SIZE);
    localparam ARF_COUNTER_WIDTH = 24;
    localparam UPDATE_MAGNITUDE_THRESHOLD = 1;
    
    logic [LONGIDLE_COUNTER_WIDTH-1:0] longidle_counter;
	logic afi_ctl_trk_req_r;
	logic afi_ctl_trk_req_r2;
	logic afi_ctl_trk_req_r3;
	logic [MEM_NUMBER_OF_RANKS - 1:0] afi_seq_busy;
	
	logic [AVL_MTR_ADDR_WIDTH - 1:0] trkm_address;
	logic trkm_write;
	logic [AVL_DATA_WIDTH - 1:0] trkm_writedata;
	logic trkm_read;
	logic [AVL_DATA_WIDTH - 1:0] sample;
	logic [AVL_DATA_WIDTH - 1:0] delay;
	logic [AVL_DATA_WIDTH - 1:0] delay_result;
	logic [AVL_DATA_WIDTH - 1:0] phase;
	logic [AVL_DATA_WIDTH - 1:0] phase_result;
	logic increment_vfifo;
	logic decrement_vfifo;
	
	logic reset_jumplogic_done;
	logic avl_prdc_ack;
	logic avl_long_ack;
	logic [5:0] substate; // for max of 32 groups
	
	logic [AVL_DATA_WIDTH - 1:0] count; 
	logic [AVL_DATA_WIDTH - 1:0] longidle_outer_loop;
	
	logic [AVL_DATA_WIDTH - 1:0] cfg_dtap_per_ptap;
	logic [PHASE_WIDTH - 1:0] max_phase_value;
	logic [5:0] afi_mux_delay;
	logic [5:0] vfifo_wait; // temporary storage for cfg_vfifo_wait
	logic [VFIFO_DEPTH_LOG2:0] vfifo_decr_loop;
	logic [5:0] trcd; // temporary storage for cfg_trcd
	logic [7:0] trfc;
	
	logic [AVL_DATA_WIDTH - 1:0] reg_file [REG_FILE_DEPTH];
	
	logic [AVL_DATA_WIDTH - 1:0] cfg_sample_count;
	logic [15:0] cfg_longidle_smpl_count;
	logic [5:0] cfg_afi_mux_delay;
	logic [5:0] cfg_vfifo_wait;
	logic [AVL_DATA_WIDTH - 1:0] cfg_num_dqs;
	logic [5:0] cfg_trcd;
	logic [15:0] cfg_longidle_outer_loop;
	logic [ARF_COUNTER_WIDTH - 1:0] cfg_refresh_interval;
	logic [7:0] cfg_trfc;
	logic stall_req;
	logic stall_ack;
	
	logic [7:0] rw_mgr_idle;
	logic [7:0] rw_mgr_activate_0_and_1;
	logic [7:0] rw_mgr_sgle_read;
	logic [7:0] rw_mgr_precharge_all;
	logic [7:0] rw_mgr_refresh;
	
	logic [ARF_COUNTER_WIDTH - 1 : 0] refresh_cnt;
	logic refresh_req;
	logic do_refresh;
	logic refresh_while_scan;
	
	logic [AVL_DATA_WIDTH - 1:0] trks_readdata;
	logic trks_waitrequest;
	
	typedef enum int unsigned {
		TRK_MGR_STATE_IDLE,
		TRK_MGR_STATE_JMPCOUNT,
		TRK_MGR_STATE_JMPADDR,
		TRK_MGR_STATE_INIT,
		TRK_MGR_STATE_REFRESH,
		TRK_MGR_STATE_ACTIVATE,
		TRK_MGR_STATE_READ,
		TRK_MGR_STATE_PRECHARGE,
		TRK_MGR_STATE_DO_SAMPLE,
		TRK_MGR_STATE_RD_SAMPLE,
		TRK_MGR_STATE_CLR_ALL_SMPL,
		TRK_MGR_STATE_CLR_SAMPLE,
		TRK_MGR_STATE_RD_DELAY,
		TRK_MGR_STATE_RD_PHASE,
		TRK_MGR_STATE_WR_DELAY,
		TRK_MGR_STATE_WR_PHASE,
		TRK_MGR_STATE_INCR_VFIFO,
		TRK_MGR_STATE_DECR_VFIFO,
		TRK_MGR_STATE_SER_SCAN,
		TRK_MGR_STATE_PAR_SCAN_1,
		TRK_MGR_STATE_PAR_SCAN_2,
		TRK_MGR_STATE_UPDATE,
		TRK_MGR_STATE_RELEASE,
		TRK_MGR_STATE_DONE
	} TRK_MGR_STATE;

	TRK_MGR_STATE avl_state;
	
	assign afi_seq_busy = {MEM_NUMBER_OF_RANKS{avl_prdc_ack | avl_long_ack}};
	assign max_phase_value = {PHASE_WIDTH{1'b1}};
	
	// synchronizer
	always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                begin
                    afi_ctl_trk_req_r  <=  0;
                    afi_ctl_trk_req_r2 <=  0;
                    afi_ctl_trk_req_r3 <=  0;
                end
            else
                begin
                    afi_ctl_trk_req_r  <=  afi_ctl_refresh_done[0] | afi_ctl_long_idle[0]; 
                    afi_ctl_trk_req_r2 <=  afi_ctl_trk_req_r;
                    afi_ctl_trk_req_r3 <=  afi_ctl_trk_req_r2;
                end
        end
    
    // Clock counter
	always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                longidle_counter  <= 0;
            else
                begin
                    if (afi_seq_busy)
                        longidle_counter  <= 0;
                    else if (!(&longidle_counter))
                        longidle_counter <= longidle_counter + 1'b1;
                end
        end
	
	// calculate resulting delay
	always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                begin
                    delay_result  <=  0;
                    phase_result  <=  0;
                    increment_vfifo <=  0;
                    decrement_vfifo <=  0;
                end
            else
                begin
                    if (avl_state == TRK_MGR_STATE_WR_DELAY)
                        begin
                            if (!sample[AVL_DATA_WIDTH-1])
                                begin
                                    if (delay == 0)
                                        begin
                                            delay_result    <=  cfg_dtap_per_ptap;
                                            if (phase == 0)
                                                begin
                                                    phase_result    <=  max_phase_value;
                                                    decrement_vfifo <=  1'b1;
                                                end
                                            else
                                                phase_result    <=  phase - 1'b1;
                                        end
                                    else
                                        begin
                                            delay_result  <=  delay - 1'b1;
                                            phase_result  <=  phase;
                                        end
                                end
                            else
                                begin
                                    if (delay == cfg_dtap_per_ptap)
                                        begin
                                            delay_result    <=  0;
                                            if (phase == max_phase_value)
                                                begin
                                                    phase_result    <=  0;
                                                    increment_vfifo <=  1'b1;
                                                end
                                            else
                                                phase_result    <=  phase + 1'b1;
                                        end
                                    else
                                        begin
                                            delay_result    <=  delay + 1'b1;
                                            phase_result    <=  phase;
                                        end
                                end
                        end
                    else if (avl_state == TRK_MGR_STATE_SER_SCAN || avl_state == TRK_MGR_STATE_PAR_SCAN_1)
                        begin
                            increment_vfifo <=  0;
                            decrement_vfifo <=  0;
                        end
                end
        end
    
    assign do_refresh = (avl_state == TRK_MGR_STATE_REFRESH);
    
    always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                refresh_cnt <= 0;
            else
                begin
                    if (do_refresh || (afi_ctl_trk_req_r2 && !afi_ctl_trk_req_r3))
                        refresh_cnt <= 1;
                    else if (refresh_cnt != {ARF_COUNTER_WIDTH{1'b1}})
                        refresh_cnt <= refresh_cnt + 1'b1;
                end
        end
    
    always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                refresh_req <= 1'b0;
            else
                begin
                    if (do_refresh)
                        refresh_req <= 1'b0;
                    else if (refresh_cnt >= cfg_refresh_interval)
                        refresh_req <= 1'b1;
                    else
                        refresh_req <= 1'b0;
                end
        end
    
    always_comb
        if ((avl_state == TRK_MGR_STATE_INCR_VFIFO || avl_state == TRK_MGR_STATE_DECR_VFIFO) && !trkm_waitrequest && trkm_write)
            trks_waitrequest    <=  1;
        else
            trks_waitrequest    <=  0;
    
    assign  trks_readdata   =   reg_file[trks_address];
    
    always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                for (int i=0; i< REG_FILE_DEPTH; i++)
                    reg_file[i] <=  0;
            else
                begin
                    if ((avl_state == TRK_MGR_STATE_INCR_VFIFO || avl_state == TRK_MGR_STATE_DECR_VFIFO) && !trkm_waitrequest && trkm_write)
                        reg_file[REG_FILE_VPOINT+substate]    <=  reg_file[REG_FILE_VPOINT+substate] + 1'b1;
                    else if (trks_write)
                        reg_file[trks_address]  <=  trks_writedata;
                    else
                        reg_file[REG_FILE_STALL][AVL_DATA_WIDTH-1]   <=  stall_ack;
                end
        end
    
    assign cfg_dtap_per_ptap        = reg_file[REG_FILE_DTAP];
    assign cfg_sample_count         = reg_file[REG_FILE_SMPL];
    assign cfg_longidle_smpl_count  = reg_file[REG_FILE_LGIDL][15:0];
    assign cfg_longidle_outer_loop  = reg_file[REG_FILE_LGIDL][31:16];
    assign cfg_afi_mux_delay        = reg_file[REG_FILE_DELAY][7:0];
    assign cfg_vfifo_wait           = reg_file[REG_FILE_DELAY][15:8];
    assign cfg_trcd                 = reg_file[REG_FILE_DELAY][23:16];
    assign cfg_trfc                 = reg_file[REG_FILE_DELAY][31:24];
    assign rw_mgr_precharge_all     = reg_file[REG_FILE_ADDR][7:0];
    assign rw_mgr_sgle_read         = reg_file[REG_FILE_ADDR][15:8];
    assign rw_mgr_activate_0_and_1  = reg_file[REG_FILE_ADDR][23:16];
    assign rw_mgr_idle              = reg_file[REG_FILE_ADDR][31:24];
    assign cfg_num_dqs              = reg_file[REG_FILE_NUM_DQS];
    assign cfg_refresh_interval     = reg_file[REG_FILE_RFSH][23:0];
    assign rw_mgr_refresh           = reg_file[REG_FILE_RFSH][31:24];
    assign stall_req                = reg_file[REG_FILE_STALL][0];
	
	always_ff @(posedge avl_clk, negedge avl_reset_n)
        begin
            if (!avl_reset_n)
                begin
                    avl_state       <=  TRK_MGR_STATE_IDLE;
                    reset_jumplogic_done    <=  0;
                    substate        <=  0;
                    avl_prdc_ack    <=  0;
                    avl_long_ack    <=  0;
                    count           <=  0;
                    trkm_address    <=  0;
	                trkm_write      <=  1'b0;
	                trkm_writedata  <=  0;
	                trkm_read       <=  1'b0;
	                sample          <=  0;
	                delay           <=  0;
	                phase           <=  0;
	                afi_mux_delay   <=  0;
	                vfifo_wait      <=  0;
	                vfifo_decr_loop <=  0;
	                trcd            <=  0;
	                trfc            <=  0;
	                longidle_outer_loop <=  0;
	                refresh_while_scan  <=  1'b0;
	                stall_ack       <=  1'b0;
                end
            else
                case(avl_state)
                    TRK_MGR_STATE_IDLE :
                        begin
                            trkm_read        <=  1'b0;
                            stall_ack        <=  1'b0;
                            if (stall_req)
                                begin
                                    avl_state <= TRK_MGR_STATE_IDLE;
                                    stall_ack <= 1'b1;
                                end
                            else if (afi_ctl_trk_req_r2)
                                begin
                                    if (reset_jumplogic_done)
                                        avl_state <= TRK_MGR_STATE_INIT;
                                    else
                                        avl_state <= TRK_MGR_STATE_JMPCOUNT;
                                    
                                    avl_long_ack    <=  &longidle_counter;
                                    avl_prdc_ack    <=  ~(&longidle_counter);
                                end
                            else
                                begin
                                    avl_state <= TRK_MGR_STATE_IDLE;
                                end
                        end
                    TRK_MGR_STATE_JMPCOUNT :
                        begin
                            // loop through substate value, empty all jump counter value
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_JMPCOUNT + {substate,2'b00}; // append two zeros because masters are byte addressed
                            trkm_writedata <= 32'h00;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    avl_state <= TRK_MGR_STATE_JMPADDR;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_JMPADDR :
                        begin
                            // loop through substate value, set jump address to idle
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_JMPADDR + {substate,2'b00};
                            trkm_writedata <= rw_mgr_idle;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (substate == 3) // this is 3 because RW has four jump counters
                                        begin
                                            avl_state   <=  TRK_MGR_STATE_INIT;
                                            reset_jumplogic_done    <=  1;
                                            substate    <=    0;
                                        end
                                    else
                                        begin
                                            avl_state   <=  TRK_MGR_STATE_JMPCOUNT;
                                            substate  <= substate + 1'b1;
                                        end
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_INIT :
                        begin
                            // sequencer takes control over path to memory
                            trkm_write <= 1'b1;
                            trkm_address <= PHY_MGR_MUX_SEL;
                            trkm_writedata <= MUX_SEL_SEQUENCER_VAL;
                            if (cfg_afi_mux_delay == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (avl_prdc_ack)
                                        avl_state <= TRK_MGR_STATE_ACTIVATE;
                                    else
                                        begin
                                            avl_state <= TRK_MGR_STATE_CLR_ALL_SMPL;
                                            count   <=  0;
                                            longidle_outer_loop <=  cfg_longidle_outer_loop;
                                        end
                                end
                            else if (afi_mux_delay != 0)
                                begin
                                    trkm_write <= 1'b0;
                                    if (afi_mux_delay == 1)
                                        begin
                                            afi_mux_delay   <=  0;
                                            if (avl_prdc_ack)
                                                avl_state <= TRK_MGR_STATE_ACTIVATE;
                                            else
                                                begin
                                                    avl_state <= TRK_MGR_STATE_CLR_ALL_SMPL;
                                                    count   <=  0;
                                                    longidle_outer_loop <=  cfg_longidle_outer_loop;
                                                end
                                        end
                                    else
                                        afi_mux_delay   <=  afi_mux_delay - 1'b1;
                                end
                            else if (afi_mux_delay == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    afi_mux_delay   <=  cfg_afi_mux_delay;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_REFRESH :
                        begin                            
                            // command to RW MGR to refresh
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_BASE;
                            trkm_writedata <= rw_mgr_refresh;
                            
                            if (trfc !=0)
                                begin
                                    trkm_write <= 1'b0;
                                    if (trfc == 1)
                                        begin
                                            trfc   <=  0;
                                            if (refresh_while_scan)
                                                begin
                                                    avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                                    refresh_while_scan  <=  1'b0;
                                                end
                                            else
                                                avl_state <= TRK_MGR_STATE_ACTIVATE;
                                        end
                                    else
                                        trfc   <=  trfc - 1'b1;
                                end
                            else if (trfc == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trfc  <=  cfg_trfc;
                                    trkm_write <= 1'b0;                                    
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_ACTIVATE :
                        begin                            
                            // command to RW MGR to activate
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_BASE;
                            trkm_writedata <= rw_mgr_activate_0_and_1;
                            
                            if (cfg_trcd == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    avl_state <= TRK_MGR_STATE_READ;
                                end
                            else if (trcd !=0)
                                begin
                                    trkm_write <= 1'b0;
                                    if (trcd == 1)
                                        begin
                                            trcd   <=  0;
                                            avl_state <= TRK_MGR_STATE_READ;
                                        end
                                    else
                                        trcd   <=  trcd - 1'b1;
                                end
                            else if (trcd == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trcd  <=  cfg_trcd;
                                    trkm_write <= 1'b0;                                    
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_READ :
                        begin                            
                            // command to RW MGR to read
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_BASE;
                            trkm_writedata <= rw_mgr_sgle_read;
                            
                            if (cfg_vfifo_wait == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    avl_state <= TRK_MGR_STATE_DO_SAMPLE;
                                end
                            else if (vfifo_wait != 0)
                                begin
                                    trkm_write <= 1'b0;
                                    if (vfifo_wait == 1)
                                        begin
                                            vfifo_wait   <=  0;
                                            avl_state <= TRK_MGR_STATE_DO_SAMPLE;
                                        end
                                    else
                                        vfifo_wait   <=  vfifo_wait - 1'b1;
                                end
                            else if (vfifo_wait == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    vfifo_wait   <=  cfg_vfifo_wait;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_DO_SAMPLE :
                        begin
                            if (count != {AVL_DATA_WIDTH{1'b1}} && !trkm_write)
                                count <= count + 1'b1;
                            
                            // command for SCC manager to take sample
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_DO_SMPL;
                            trkm_writedata <= 32'hFF; // data is the group to take sample FF is all groups
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (avl_prdc_ack)
                                        avl_state <= TRK_MGR_STATE_PRECHARGE;
                                    else
                                        begin
                                            if (count >= cfg_longidle_smpl_count)
                                                begin
                                                    avl_state <= TRK_MGR_STATE_PRECHARGE;
                                                    count   <= 0;
                                                end
                                            else
                                                begin
                                                    if (refresh_req)
                                                        avl_state <= TRK_MGR_STATE_PRECHARGE;
                                                    else
                                                        avl_state <= TRK_MGR_STATE_READ;
                                                end
                                        end
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_PRECHARGE :
                        begin                            
                            // command to RW MGR to precharge
                            trkm_write <= 1'b1;
                            trkm_address <= RW_MGR_BASE;
                            trkm_writedata <= rw_mgr_precharge_all;
                            
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (avl_prdc_ack)
                                        begin
                                            if (count >= cfg_sample_count)
                                                begin
                                                    avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                                    count   <= 0;
                                                end
                                            else
                                                avl_state <= TRK_MGR_STATE_RELEASE;
                                        end
                                    else
                                        begin
                                            if (count == 0)
                                                avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                            else
                                                avl_state <= TRK_MGR_STATE_REFRESH;
                                        end
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_RD_SAMPLE :
                        begin
                            // read scc manager sample
                            trkm_read <= 1'b1;
                            trkm_address <= SCC_MGR_SAMPLE + {substate,2'b00}; // loops through all groups
                            if (!trkm_waitrequest && trkm_read)
                                begin
                                    avl_state <= TRK_MGR_STATE_CLR_SAMPLE;
                                    trkm_read <= 1'b0;
                                    sample  <= trkm_readdata;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_CLR_ALL_SMPL :
                        begin
                            // clear all scc manager sample
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_SAMPLE + {substate,2'b00};
                            trkm_writedata <= 32'h0;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    if (substate == MEM_READ_DQS_WIDTH-1) // to be safe, we clear all possible samples
                                        begin
                                            avl_state <= TRK_MGR_STATE_ACTIVATE;
                                            substate  <= 0;
                                        end
                                    else
                                        begin
                                            avl_state <= TRK_MGR_STATE_CLR_ALL_SMPL;
                                            substate  <= substate + 1'b1;
                                        end
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_CLR_SAMPLE :
                        begin
                            // clear scc manager sample
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_SAMPLE + {substate,2'b00};
                            trkm_writedata <= 32'h0;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (TRK_PARALLEL_SCC_LOAD == 0 && sample[AVL_DATA_WIDTH - 2:0] < UPDATE_MAGNITUDE_THRESHOLD)
                                        begin
                                            if (substate == cfg_num_dqs-1)
                                                begin
                                                    avl_state <= TRK_MGR_STATE_UPDATE;
                                                    substate  <= 0;
                                                end
                                            else
                                                begin
                                                    substate  <= substate + 1'b1;
                                                    avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                                end
                                        end
                                    else
                                        avl_state <= TRK_MGR_STATE_RD_DELAY;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_RD_DELAY :
                        begin
                            // read existing scc manager delay
                            trkm_read <= 1'b1;
                            trkm_address <= SCC_MGR_DEL + {substate,2'b00};
                            if (!trkm_waitrequest && trkm_read)
                                begin
                                    avl_state <= TRK_MGR_STATE_RD_PHASE;
                                    trkm_read <= 1'b0;
                                    delay  <= trkm_readdata - IO_DQS_EN_DELAY_OFFSET;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_RD_PHASE :
                        begin
                            // read existing scc manager delay
                            trkm_read <= 1'b1;
                            trkm_address <= SCC_MGR_PHS + {substate,2'b00};
                            if (!trkm_waitrequest && trkm_read)
                                begin
                                    avl_state <= TRK_MGR_STATE_WR_DELAY;
                                    trkm_read <= 1'b0;
                                    phase  <= trkm_readdata;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_WR_DELAY :
                        begin
                            // write new value into scc manager
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_DEL + {substate,2'b00};
                            trkm_writedata <= delay_result + IO_DQS_EN_DELAY_OFFSET;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    avl_state <= TRK_MGR_STATE_WR_PHASE;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_WR_PHASE :
                        begin
                            // write new value into scc manager
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_PHS + {substate,2'b00};
                            trkm_writedata <= phase_result;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (increment_vfifo)
                                        avl_state <= TRK_MGR_STATE_INCR_VFIFO;
                                    else if (decrement_vfifo)
                                        begin
                                            avl_state <= TRK_MGR_STATE_DECR_VFIFO;
                                            vfifo_decr_loop <=  VFIFO_DEPTH;
                                        end
                                    else
                                        begin
                                            if (TRK_PARALLEL_SCC_LOAD == 1)
                                                avl_state <= TRK_MGR_STATE_PAR_SCAN_1;
                                            else
                                                avl_state <= TRK_MGR_STATE_SER_SCAN;
                                        end
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_INCR_VFIFO :
                        begin
                            // increment vfifo
                            trkm_write <= 1'b1;
                            
                            task_increment_vfifo_address;
                            
                            trkm_writedata <= substate;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    if (TRK_PARALLEL_SCC_LOAD == 1)
                                        avl_state <= TRK_MGR_STATE_PAR_SCAN_1;
                                    else
                                        avl_state <= TRK_MGR_STATE_SER_SCAN;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_DECR_VFIFO :
                        begin
                            // decrement vfifo
                            trkm_write <= 1'b1;
                            
                            task_increment_vfifo_address;
                            
                            trkm_writedata <= substate;
                            if (!trkm_waitrequest && trkm_write && vfifo_decr_loop == 2)
                                begin
                                    trkm_write <= 1'b0;
                                    if (TRK_PARALLEL_SCC_LOAD == 1)
                                        avl_state <= TRK_MGR_STATE_PAR_SCAN_1;
                                    else
                                        avl_state <= TRK_MGR_STATE_SER_SCAN;
                                end
                            else if (!trkm_waitrequest && trkm_write && vfifo_decr_loop > 0)
                                begin
                                    vfifo_decr_loop <=  vfifo_decr_loop - 1'b1;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_SER_SCAN :
                        begin
                            // scan new value
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_SER_SCAN;
                            trkm_writedata <= substate;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    if (substate == cfg_num_dqs-1)
                                        begin
                                            avl_state <= TRK_MGR_STATE_UPDATE;
                                            substate  <= 0;
                                        end
                                    else
                                        begin
                                            substate  <= substate + 1'b1;
                                            if (refresh_req)
                                                begin
                                                    refresh_while_scan  <=  1'b1;
                                                    avl_state <= TRK_MGR_STATE_REFRESH;
                                                end
                                            else
                                                avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                        end
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_PAR_SCAN_1 :
                        begin
                            // loop-deciding state
                            if (substate == cfg_num_dqs-1)
                                begin
                                    avl_state <= TRK_MGR_STATE_PAR_SCAN_2;
                                    substate  <= 0;
                                end
                            else
                                begin
                                    substate  <= substate + 1'b1;
                                    avl_state <= TRK_MGR_STATE_RD_SAMPLE;
                                end
                        end
                    TRK_MGR_STATE_PAR_SCAN_2 :
                        begin
                            // scan new value
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_PAR_SCAN;
                            trkm_writedata <= 32'hFF;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    avl_state <= TRK_MGR_STATE_UPDATE;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_UPDATE :
                        begin
                            // command for scc manager to update its DQS delay
                            trkm_write <= 1'b1;
                            trkm_address <= SCC_MGR_UPDATE;
                            trkm_writedata <= 32'h01;
                            if (!trkm_waitrequest && trkm_write)
                                begin
                                    if ((avl_long_ack && longidle_outer_loop == 0) || avl_prdc_ack)
                                        begin
                                            avl_state <= TRK_MGR_STATE_RELEASE;
                                        end
                                    else
                                        begin
                                            avl_state <= TRK_MGR_STATE_ACTIVATE;
                                            longidle_outer_loop <=  longidle_outer_loop - 1'b1;
                                        end
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_RELEASE :
                        begin
                            // sequencer gives control over path to memory
                            trkm_write <= 1'b1;
                            trkm_address <= PHY_MGR_MUX_SEL;
                            trkm_writedata <= MUX_SEL_CONTROLLER_VAL;
                            if (cfg_afi_mux_delay == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    trkm_write <= 1'b0;
                                    avl_state <= TRK_MGR_STATE_DONE;
                                    avl_long_ack <= 0;
                                    avl_prdc_ack <= 0;
                                end
                            else if (afi_mux_delay != 0)
                                begin
                                    trkm_write <= 1'b0;
                                    if (afi_mux_delay == 1)
                                        begin
                                            afi_mux_delay   <=  0;
                                            avl_state <= TRK_MGR_STATE_DONE;
                                            avl_long_ack <= 0;
                                            avl_prdc_ack <= 0;
                                        end
                                    else
                                        afi_mux_delay   <=  afi_mux_delay - 1'b1;
                                end
                            else if (afi_mux_delay == 0 && !trkm_waitrequest && trkm_write)
                                begin
                                    afi_mux_delay   <=  cfg_afi_mux_delay;
                                    trkm_write <= 1'b0;
                                end
                            else
                                avl_state <= avl_state;
                        end
                    TRK_MGR_STATE_DONE :
                        begin
                            if (!afi_ctl_trk_req_r2)
                                avl_state <= TRK_MGR_STATE_IDLE;
                            else
                                avl_state <= TRK_MGR_STATE_DONE;
                        end
                endcase
        end
    
    task task_increment_vfifo_address;
        begin
            if (HARD_PHY)
                trkm_address <= PHY_MGR_CMD_INC_VFIFO_HARD_PHY;
            else if (HARD_VFIFO)
                trkm_address <= PHY_MGR_CMD_INC_VFIFO_FR;
            else if (RATE == "Quarter")
                begin
                    if ((reg_file[REG_FILE_VPOINT+substate] & 3) == 3)
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_QR;
                    else if ((reg_file[REG_FILE_VPOINT+substate] & 2) == 2)
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_FR_HR;
                    else if ((reg_file[REG_FILE_VPOINT+substate] & 1) == 1)
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_HR;
                    else
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_FR;
                end
            else if (RATE == "Half")
                begin
                    if ((reg_file[REG_FILE_VPOINT+substate] & 1) == 1)
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_HR;
                    else
                        trkm_address <= PHY_MGR_CMD_INC_VFIFO_FR;
                end
            else 
                trkm_address <= PHY_MGR_CMD_INC_VFIFO_HR;
        end
    endtask
	
	function integer ceil_log2;
		input integer value;
		begin
			value = value - 1;
			for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
				value = value >> 1;
		end
	endfunction	

endmodule
