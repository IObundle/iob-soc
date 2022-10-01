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


// altera message_off  10036 10034 10230 10764
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altpcieav_dma_rd # (
      parameter                                   dma_use_scfifo_ext   = 0,
      parameter                                   DEVICE_FAMILY        = "Stratix V",
      parameter                                   DMA_WIDTH            = 256,
      parameter                                   DMA_BE_WIDTH         = 5,
      parameter                                   DMA_BRST_CNT_W       = 5,
      parameter                                   RDDMA_AVL_ADDR_WIDTH = 20,
      parameter                                   TX_FIFO_WIDTH        = (DMA_WIDTH == 256) ? 260 : 131,   //Data+Sop+Eop+Empty
      parameter                                   NUM_TAG              = 16,
      parameter                                   NUM_TAG_WIDTH        = 4,
      parameter                                   RDDMA_RXDATA_WIDTH   = 160,
      parameter                                   RXFIFO_DATA_WIDTH    = 266,
      parameter                                   EXTENDED_TAG_ENABLE  = 0
) (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,

      // Avalon-MM Interface
      output  logic                                RdDmaWrite_o,
      output  logic  [63:0]                        RdDmaAddress_o,  // If One function = {actual address}. If SRIOV={funcno[7:0], actual address}
      output  logic  [DMA_WIDTH-1:0]               RdDmaWriteData_o,
      output  logic  [DMA_BRST_CNT_W-1:0]          RdDmaBurstCount_o,
      output  logic  [DMA_BE_WIDTH-1:0]            RdDmaWriteEnable_o,
      input   logic                                RdDmaWaitRequest_i,

      /// AST Inteface
      // Read DMA AST Rx port
      input   logic  [RDDMA_RXDATA_WIDTH-1:0]                       RdDmaRxData_i,
      input   logic                                RdDmaRxValid_i,
      output  logic                                RdDmaRxReady_o,

      // Read DMA AST Tx port
      output   logic  [31:0]                       RdDmaTxData_o,
      output   logic                               RdDmaTxValid_o,

      // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [RXFIFO_DATA_WIDTH-1:0]         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,

      /// Tag predecode
      output  logic                                 PreDecodeTagRdReq_o,
      input   logic [7:0]                           PreDecodeTag_i,
      input   logic [NUM_TAG_WIDTH-1:0]             PreDecodeTagCount_i,

      // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [TX_FIFO_WIDTH-1:0]             TxFifoData_o,
      input  logic [3:0]                           TxFifoCount_i,

      // General CRA interface
      input                                        RdDMACntrlLoad_i,
      input   logic [31:0]                         RdDMACntrlData_i,
      output  logic [31:0]                         RdDMAStatus_o,

       // Arbiter Interface
      output  logic                                RdDMmaArbReq_o,
      input   logic                                RdDMmaArbGranted_i,

      input   logic   [12:0]                       BusDev_i,
      input   logic   [31:0]                       DevCsr_i,
      input   logic                                MasterEnable_i,    // PF Master Enable

      /// rx completion space
     input  logic [7:0]                             ko_cpl_spc_header,
     input  logic [11:0]                            ko_cpl_spc_data


  );

  localparam  RD_IDLE                = 9'h001;
  localparam  RD_POP_DESC            = 9'h002;
  localparam  RD_ARB_REQ             = 9'h004;
  localparam  RD_SEND                = 9'h008;
  localparam  RD_WAIT_TAG            = 9'h010;
  localparam  RD_PAUSE               = 9'h020;
  localparam  RD_PIPE                = 9'h040;
  localparam  RD_CHECK_SUB_DESC      = 9'h080;
  localparam  RD_LD_SUB_DESC         = 9'h100;


  localparam RDCPL_IDLE             = 3'b001;
  localparam RDCPL_WAIT             = 3'b010;
  localparam RDCPL_WRITE            = 3'b100;

  logic                                 flush_all_desc;
  logic                                 rd_pop_desc_state;
  logic  [RDDMA_RXDATA_WIDTH-1:0]       desc_head;
  logic  [3:0]                          desc_fifo_count;
  logic                                 desc_fifo_wrreq;
  logic  [RDDMA_RXDATA_WIDTH-1:0]       desc_fifo_wrdat;
  logic  [RDDMA_AVL_ADDR_WIDTH-1:0]     cur_dest_addr_reg;
  logic  [RDDMA_AVL_ADDR_WIDTH-1:0]     cur_dest_addr_adder_out;
  logic  [63:0]                         cur_src_addr_reg;
  logic  [63:0]                         cur_src_addr_adder_out;
  logic                                 rd_header_state;
  logic  [7:0]                          cur_desc_id_reg;
  logic                                 cur_dma_abort_reg;
  logic                                 cur_dma_pause_reg;
  logic                                 cur_dma_pause;
  logic                                 flush_all_desc_reg;
  logic                                 cur_dma_abort;
  logic                                 cur_dma_resume_reg;
  logic                                 cur_dma_resume;
  logic                                 rd_pause_state;
  logic  [17:0]                         remain_dwcnt_reg;
  logic  [9:0]                          adjusted_dw_count;
  logic  [9:0]                          adjusted_dw_count_reg;

  logic  [9:0]                          rd_dw_size;
  logic  [9:0]                          rd_dw_size_reg;
  logic  [9:0]                          max_rd_dw;
  logic  [9:0]                          max_rd;

  logic  [10:0]                         dw_to_4KB;
  logic  [10:0]                         dw_to_128;
  logic  [10:0]                         dw_to_256;
  logic  [10:0]                         dw_to_512;

  logic                                 alignment_sel;
  logic                                 to_4KB_sel;
  logic                                 remain_dw_sel;
  logic  [1:0]                          rdsize_sel_reg;
  logic                                 last_rd_segment;
  logic  [8:0]                          rd_dma_state;
  logic  [8:0]                          rd_dma_nxt_state;
  logic                                 desc_fifo_empty;
  logic                                 tag_available_reg;


  logic                                 rd_arb_req_state;
  logic                                 rd_arb_req_state_reg;
  logic                                 arbiter_req_rise;
  logic                                 tag_fifo_wrreq;
  logic                                 tag_fifo_rdreq;
  logic  [NUM_TAG_WIDTH-1:0]            tag_fifo_wrdat;
  logic  [NUM_TAG_WIDTH-1:0]            tag;
  logic  [NUM_TAG_WIDTH:0]              tag_fifo_count;
  logic  [NUM_TAG_WIDTH+2:0]            tag_counter;
  logic  [7:0]                          rd_tag_reg;
  logic  [31:0]                         first_avmm_be;
  logic  [7:0]                          tag_desc_id_reg [16];
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      tag_address_reg [16];
  logic [31:0]                          tag_fbe_reg [16];
  logic [9:0]                           tag_remain_dw_reg[16];
  logic [9:0]                           remain_dw;
 // logic [NUM_TAG-1:0]                   tag_desc_last_rd_reg;
  logic                                 cpl_update_tag;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      next_dest_addr_reg;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      avmm_addr_reg;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]     avmm_dest_addr_tagramq;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]     tagram_dest_addr_wrdata;
  logic [2:0]                           rd_cpl_state;
  logic [2:0]                           rdcpl_nxt_state;
  logic                                 rx_sop;
  logic                                 rx_eop_reg;
  logic [9:0]                           rx_dwlen;
  logic [7:0]                           cpl_tag;
  logic [7:0]                           rx_cpl_addr;
  logic                                 addr_bit2;
  logic [11:0]                          cpl_bytecount;
  logic                                 is_cpl_wd;
  logic                                 last_cpl;
  logic [255:0]                         avmm_write_data;

  logic [31:0]                          avmm_write_data_dw0;
  logic [31:0]                          avmm_write_data_dw1;
  logic [31:0]                          avmm_write_data_dw2;
  logic [31:0]                          avmm_write_data_dw3;
  logic [31:0]                          avmm_write_data_dw4;
  logic [31:0]                          avmm_write_data_dw5;
  logic [31:0]                          avmm_write_data_dw6;
  logic [31:0]                          avmm_write_data_dw7;

  logic                                 rdcpl_idle_state;
  logic                                 rdcpl_wait_state;
  logic                                 rdcpl_write_state;
  logic [7:0]                           first_valid_addr;
  logic                                 rd_idle_state;
  logic                                 is_rd32;
  logic [7:0]                           cmd;
  logic [15:0]                          requestor_id;
  logic [31:0]                          tlp_dw2;
  logic [31:0]                          tlp_dw3;
  logic [63:0]                          req_header1;
  logic [63:0]                          req_header2;
  logic [12:0]                          bytes_to_4KB;
  logic [7:0]                           bytes_to_128;
  logic [8:0]                           bytes_to_256;
  logic [9:0]                           bytes_to_512;

  logic [265:0]                         tlp_reg;
  logic [31:0]                          tlp_reg_dw0;
  logic [31:0]                          tlp_reg_dw1;
  logic [31:0]                          tlp_reg_dw2;
  logic [31:0]                          tlp_reg_dw3;
  logic [31:0]                          tlp_reg_dw4;
  logic [31:0]                          tlp_reg_dw5;
  logic [31:0]                          tlp_reg_dw6;
  logic [31:0]                          tlp_reg_dw7;
  logic [265:0]                         tlp_hold_reg;
  logic [31:0]                          tlp_hold_reg_dw1;
  logic [31:0]                          tlp_hold_reg_dw2;
  logic [31:0]                          tlp_hold_reg_dw3;
  logic [31:0]                          tlp_hold_reg_dw4;
  logic [31:0]                          tlp_hold_reg_dw5;
  logic [31:0]                          tlp_hold_reg_dw6;
  logic [31:0]                          tlp_hold_reg_dw7;
  logic [265:0]                         tlp_fifo;
  logic [31:0]                          tlp_fifo_dw0;
  logic [31:0]                          tlp_fifo_dw1;
  logic [31:0]                          tlp_fifo_dw2;
  logic [31:0]                          tlp_fifo_dw3;

  logic [31:0]                          avmm_fbe_reg;
  logic [31:0]                          tag_first_enable_reg;
  logic                                 avmm_first_write_reg;
  logic [31:0]                          avmm_lbe_reg;
  logic [31:0]                          avmm_fbe;
  logic [31:0]                          avmm_fbe_pre;
  logic [7:0]                           cpl_desc_id_reg;
  logic                                 last_cpl_reg;
  logic [7:0]                           cpl_tag_reg;
  logic [9:0]                           rx_dwlen_reg;
  logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cnt_reg;
  logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cntr;
  logic                                 cpl_addr_bit2;
  logic                                 cpl_addr_bit2_reg;
  logic [1:0]                           tx_tlp_empty;
  logic                                 rx_fifo_empty;
  logic                                 tag_release;
  logic                                 latch_header;
  logic                                 latch_header_from_write_state;
  logic                                 latch_header_from_idle_state;
  logic                                 latch_header_reg;
  logic  [63:0]                         sub_desc_src_addr_reg;
  logic  [63:0]                         sub_desc_dest_addr_reg;
  logic  [17:0]                         sub_desc_length_reg;
  logic                                 sub_desc_load;
  logic                                 sub_desc_load_reg;
  logic  [12:0]                         bytes_to_4K;
  logic  [10:0]                         dw_to_4K;
  logic  [63:0]                         next_sub_src_addr;
  logic  [63:0]                         next_sub_dest_addr;
  logic  [17:0]                         next_length;
  logic                                 rd_check_sub_desc_state;
  logic                                 load_cur_desc_size;
  logic                                 load_cur_desc_size_reg;
  logic                                 rd_pipe_state;
  logic                                 last_sub_desc_reg;
  logic                                 last_sub_desc;
  logic                                 rd_pipe_state_reg;
  logic  [17:0]                         main_desc_remain_length_reg;
  logic  [17:0]                         orig_desc_dw_reg;
  logic  [17:0]                         culmutive_sent_dw;
  logic  [17:0]                         culmutive_remain_dw;
  logic  [NUM_TAG-1:0]                  tag_outstanding_reg;
  logic                                 last_desc_cpl_reg;

  logic                                 cpl_on_progress_sreg;
  logic                                 tx_fifo_ok;
  logic                                 tag_release_queuing;
  logic                                 tag_queu_rdreq;
  logic [NUM_TAG_WIDTH-1:0]             released_tag;
  logic [NUM_TAG_WIDTH-1:0]             tag_queu_count;
  logic                                 write_stall_reg;
  logic [10:0]                          dw_to_legal_bound;
  logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cnt;
  logic [9:0]                           first_dw_holes;
  logic [9:0]                           first_dw_holes_pre;
  logic [9:0]                           first_dw_holes_pre_reg;

  logic [9:0]                           empty_dw_reg;
  logic [31:0]                          updated_fbe;
  logic [31:0]                          updated_fbe_reg;
  logic [31:0]                          adjusted_avmm_fbe;
  logic [31:0]                          adjusted_avmm_lbe;
  logic                                 desc_completed;
  logic                                 desc_flushed;
  logic                                 desc_aborted;
  logic                                 desc_paused;
  logic [4:0]                           flush_count;
  logic                                 b2b_same_tag;
  logic                                 valid_cpl_available;
  logic [NUM_TAG-1:0]                   tag_ready;

  // SRIOV signals
  logic                                 cur_MasterEnable;
  logic  [7:0]                          tag_func_reg [16];
  logic  [7:0]                          cpl_func_reg;
  logic                                 error_status;
  logic                                 desc_error;
  logic                                 error_status_reg;
  logic                                 vf_master_en;
  logic  [16:0]                         desc_completed_reg;
  //===========================================================================
  //Status FIFO Read DMA AST Tx port: DMA status back to Descriptor Controller
  //===========================================================================
  logic  [31:0]                         RdDmaTxData;
  logic                                 RdDmaTxValid;
  logic                                 RdDmaStatus; // 1: successfully completed, 0: Not completed dued to either error, aborted, flush or paused ...etc
  logic  [ 2:0]                         RdDmaStatus_code; // 0: completed, 1: error, 2: flush, 3: aborted, 4: paused

  // Status FIFO
  logic                                 status_fifo_ok_reg;
  logic                                 status_fifo_not_empty;
  logic   [6:0]                         status_fifo_count;
  logic                                 status_fifo_wr, status_fifo_rd;
  logic                                 status_fifo_rd_reg;
  logic   [19:0]                        status_fifo_in, status_fifo_out; //cpl_func_reg[7:0],RdDmaStatus, RdDmaStatus_code[2:0],cpl_desc_id_reg[7:0]

  logic                                 last_RdDmaWriteData;
  logic                                 last_avmmdata_sent_reg;
  // decoding status output from FIFO
  logic [7:0]                           status_func_no;
  logic [7:0]                           status_desc_id;
  logic                                 status_desc_completed;
  logic                                 status_error;

  logic                                 RdDmaWrite_d1;
  logic  [DMA_WIDTH-1:0]                RdDmaWriteData_d1;
  logic  [DMA_BE_WIDTH-1:0]             RdDmaWriteEnable_d1;
  logic  [4:0]                          RdDmaBurstCount_d1;
  logic                                 latch_header_reg_d1;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      avmm_addr_reg_d1;
  logic [15:0]                          rx_match_desc_id;
  logic [5:0]                           counter_id;

 logic                                  desc_outstanding_reads_queue_wrreq;
 logic                                  desc_outstanding_reads_queue_rdreq;
 logic  [3:0]                           desc_outstanding_reads_queue_wrdat;
 logic  [3:0]                           desc_outstanding_reads_queue_num;
 logic  [3:0]                           released_counter;
 logic  [16:0]                          descriptor_outstanding_read_id[15:0];
 logic  [7:0]                           descriptor_outstanding_read_cntr[15:0];
 logic  [15:0]                          descriptor_outstanding_read_pending;
 logic  [5:0]                           desc_outstanding_fifo_count;
 logic  [4:0]                           current_cntr_reg;
 logic  [3:0]                           current_cntr;
 logic  [15:0]                          up_count_en;
 logic  [15:0]                          down_count_en;
 logic                                  desc_outstanding_reads_queue_fifo_ok;
 logic  [15:0]                          desc_rd_tlp_stil_in_progress;
 logic  [7:0]                           func_head;

 /// AVMM WR FIFO for Fmax
   logic [(DMA_WIDTH+DMA_WIDTH/8)-1:0]    avmmwr_fifo_data;
   logic   [(DMA_WIDTH)-1:0]              avmmwr_write_data_reg;
   logic                                  avmmwr_data_fifo_rdreq;
   logic   [8:0]                          avmmwr_fifo_usedw;
   logic                                  avmmwr_data_fifo_ok_reg;
   logic                                  avmmwr_fifo_ok;
   logic   [287:0]                        avmmwr_write_data;
   logic                                  avmmwr_cmd_fifo_wrreq;
   logic                                  avmmwr_cmd_fifo_rdreq;
   logic   [64+7:0]                       avmmwr_cmd;
   logic   [64+7:0]                       avmmwr_cmd_q;
   logic   [4:0]                          avmmwr_cmd_count;
   logic                                  avmmwr_cmd_fifo_ok_reg;
   logic   [5:0]                          avmmwr_burst_count;
   logic   [1:0]                          avmmwr_state;
   logic   [1:0]                          avmmwr_nxt_state;
   logic   [5:0]                          avmmwr_burst_cntr;
   logic   [5:0]                          avmmwr_burst_count_reg;
   logic   [63:0]                         avmmwr_address_reg;
   logic                                  avmmwr_data_fifo_empty;
   logic                                  avmmwr_idle_state;
   logic                                  avmmwr_wrpipe_state;
   logic                                  avmmwr_write_state;
   logic [DMA_WIDTH-1:0]                  avmmwr_data_reg;
   logic [(DMA_WIDTH/8)-1:0]              avmmwr_byteen_reg;
   logic [DMA_BRST_CNT_W-1:0]             avmmwr_burstcnt_reg;
   logic                                  rdcpl_write_state_reg;
   logic                                  tlp_processable;
   logic                                  waitreq_duo_to_avmmwr_fifo;
   logic [RDDMA_AVL_ADDR_WIDTH-1:0]      avmm_address_reg2;
   logic                                 latch_header_reg2;
   logic [3:0]                           upper_nibble_rd_be;
   logic                                 rd_header_state_reg;
   logic                                 rd_tx_valid_reg;
   logic  [31:0]                         rd_tx_data_reg;
   logic                                 rd_status_fifo_rdreq;
   logic  [4:0]                          rd_status_fifo_count;
   logic                                 status_frequency_cntr;
   logic                                 end_avmm_cycle;
   logic  [7:0]                         cpl_header_cnt;
   logic  [11:0]                        cpl_data_cnt;
   logic  [7:0]                         cpl_header_reg;
   logic  [11:0]                        cpl_data_reg;
   logic                                cpl_data_available;
   logic                                cpl_header_available;

   logic [63:0]                         tagram_address_wrdata;
   logic [7:0]                          tagram_address_wraddr;
   logic [31:0]                         tagram_fbe_wrdata;
   logic [7:0]                          tagram_fbe_wraddr;
   logic [63:0]                         tagram_address_rddata;
   logic [7:0]                          tagram_fbe_rddata;

   logic [31:0]                          avmm_lbe_reg_2;
   logic [7:0]                           first_valid_addr_2;
    logic [7:0]                           first_valid_addr_sig;

   logic  [31:0]                               avmm_fbe_reg_sig;
   logic  [DMA_BRST_CNT_W-1:0]                 avmm_burst_cntr_sig;
   logic  [DMA_BRST_CNT_W-1:0]                 avmm_burst_cnt_reg_sig;
   logic  [31:0]                               avmm_lbe_reg_sig;
   logic  [31:0]                               avmm_fbe_pre_tagramq;
   logic [RDDMA_AVL_ADDR_WIDTH-1:0]            tag_address_reg_2;

   logic [25:0]                                avmm_mis_tagramq;
   logic [9:0]                                 tag_remain_dw_reg_2;
   logic [7:0]                                 tag_desc_id_reg_2;
  logic  [7:0]                                 tag_func_reg_2;
  logic  [25:0] tagram_misc_wrdata;
  logic  [7:0] tagram_misc_wraddr;

  logic                                         tagram_outstanding_wrdata;
  logic [7:0]                                   tagramoutstanding_wraddr;
  logic                                         tag_outstanding_reg_2;
  logic                                         avmm_outstanding_tagramq;
  logic                                         tag_ready_2;
  logic                                         cpl_update_tag_reg;
  logic                                         rd_and_cpl_same_clock_reg;
  logic                                         update_address_array;
  logic                                         rd_and_latch_reg_same_clock;
  logic                                         rd_and_latch_reg_same_clock_reg;
  logic [7:0]                                   tagram_destaddr_wraddr;

   logic [31:0]                          avmm_fbe_pre_2;
   logic [9:0]                           first_dw_holes_pre_2;
   logic [9:0]                           first_dw_holes_pre_reg_2;
   logic [31:0]                          avmm_fbe_2;
   logic [31:0]                          tag_first_enable_reg_2;
   logic [31:0]                          adjusted_avmm_fbe_2;
   logic [9:0]                           first_dw_holes_2;
   logic [31:0]                          updated_fbe_reg_2;
   logic  [9:0]                          adjusted_dw_count_2;
   logic  [9:0]                          adjusted_dw_count_reg_2;
   logic [9:0]                           empty_dw_reg_2;
   logic [31:0]                          updated_fbe_2;
   logic [31:0]                          avmm_fbe_reg_2;
   logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cntr_2;
   logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cnt_2;
   logic [DMA_BRST_CNT_W-1:0]            avmm_burst_cnt_reg_2;
   logic [31:0]                          adjusted_avmm_lbe_2;
   logic                                 rd_and_cpl_same_clock;
   logic                                 small_desc_size;
   logic [7:0]                           adjusted_cpl_spc_header;
   logic [7:0]                           a5_max_hdr_space;

    localparam  AVMMWR_IDLE     = 2'h0;
    localparam  AVMMWR_PIPE     = 2'h1;
    localparam  AVMMWR_WR       = 2'h2;
    localparam  AVMMWR_RD       = 2'h3;

/// ko_ for cpl

assign adjusted_cpl_spc_header = (DEVICE_FAMILY=="Arria V" | DEVICE_FAMILY=="Cyclone V")? a5_max_hdr_space : ko_cpl_spc_header;

// Mux the 256-tag signals based on parameterc


generate if(EXTENDED_TAG_ENABLE)

begin

  assign  avmm_fbe_reg_sig            = avmm_fbe_reg_2            ;
  assign  avmm_burst_cntr_sig         = avmm_burst_cntr_2         ;
  assign  avmm_burst_cnt_reg_sig      = avmm_burst_cnt_reg_2      ;
  assign  avmm_lbe_reg_sig            = avmm_lbe_reg_2            ;
  assign  first_valid_addr_sig        = first_valid_addr_2        ;

end
  else
     begin
  assign  avmm_fbe_reg_sig            =   avmm_fbe_reg            ;
  assign  avmm_burst_cntr_sig         =   avmm_burst_cntr         ;
  assign  avmm_burst_cnt_reg_sig      =   avmm_burst_cnt_reg      ;
  assign  avmm_lbe_reg_sig            =   avmm_lbe_reg            ;
  assign  first_valid_addr_sig        =   first_valid_addr        ;
    end
 endgenerate




always_comb
  begin
    case(DevCsr_i[14:12])
      3'b000  : max_rd_dw = 32;
      3'b001  : max_rd_dw = 64;
      default : max_rd_dw = 128;
    endcase
  end

always_comb
  begin
    case(DevCsr_i[14:12])
      3'b000  : a5_max_hdr_space = 8'd16;
      3'b001  : a5_max_hdr_space = 8'd9;
      default : a5_max_hdr_space = 8'd5;
    endcase
  end

  // Descriptor FIFO
   altpcie_fifo
   #(
    .FIFO_DEPTH(6),
    .DATA_WIDTH(RDDMA_RXDATA_WIDTH)
    )
 read_desc_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(flush_all_desc & RdDMACntrlLoad_i ),
      .wrreq(desc_fifo_wrreq),
      .rdreq(rd_pop_desc_state),
      .data(desc_fifo_wrdat),
      .q(desc_head),
      .fifo_count(desc_fifo_count)
);
assign desc_fifo_empty = (desc_fifo_count == 0);
assign desc_fifo_wrreq   = RdDmaRxValid_i;
assign desc_fifo_wrdat   = RdDmaRxData_i;

/// current descriptor

 always_ff @ (posedge Clk_i)
           rd_header_state_reg <= rd_header_state;

  always_ff @ (posedge Clk_i)
     begin
       if(rd_pop_desc_state)   /// load the output reg
           cur_dest_addr_reg <= desc_head[RDDMA_AVL_ADDR_WIDTH+63:64];
       else if (rd_header_state_reg)
           cur_dest_addr_reg <= cur_dest_addr_adder_out;
     end


        lpm_add_sub     LPM_DEST_ADD_SUB_component (
                                .clken (1'b1),
                                .clock (Clk_i),
                                .dataa (cur_dest_addr_reg),
                                .datab ({rd_dw_size, 2'b00}),
                                .result (cur_dest_addr_adder_out)
                                // synopsys translate_off
                                ,
                                .aclr (),
                                .add_sub (),
                                .cin (),
                                .cout (),
                                .overflow ()
                                // synopsys translate_on
                                );
        defparam
                LPM_DEST_ADD_SUB_component.lpm_direction = "ADD",
                LPM_DEST_ADD_SUB_component.lpm_hint = "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
                LPM_DEST_ADD_SUB_component.lpm_pipeline = 1,
                LPM_DEST_ADD_SUB_component.lpm_representation = "UNSIGNED",
                LPM_DEST_ADD_SUB_component.lpm_type = "LPM_ADD_SUB",
                LPM_DEST_ADD_SUB_component.lpm_width = RDDMA_AVL_ADDR_WIDTH;


  always_ff @ (posedge Clk_i)
     begin
      if(rd_pop_desc_state)   /// load the output reg
           cur_src_addr_reg <= desc_head[63:0];
       else if(rd_header_state_reg)
           cur_src_addr_reg <= cur_src_addr_adder_out;
     end


        lpm_add_sub     LPM_SRC_ADD_SUB_component (
                                .clken (1'b1),
                                .clock (Clk_i),
                                .dataa (cur_src_addr_reg),
                                .datab ({52'h0,rd_dw_size, 2'b00}),
                                .result (cur_src_addr_adder_out)
                                // synopsys translate_off
                                ,
                                .aclr (),
                                .add_sub (),
                                .cin (),
                                .cout (),
                                .overflow ()
                                // synopsys translate_on
                                );
        defparam
                LPM_SRC_ADD_SUB_component.lpm_direction = "ADD",
                LPM_SRC_ADD_SUB_component.lpm_hint = "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
                LPM_SRC_ADD_SUB_component.lpm_pipeline = 1,
                LPM_SRC_ADD_SUB_component.lpm_representation = "UNSIGNED",
                LPM_SRC_ADD_SUB_component.lpm_type = "LPM_ADD_SUB",
                LPM_SRC_ADD_SUB_component.lpm_width = 64;


  /// current Desc ID

      always_ff @ (posedge Clk_i)
      if(rd_pop_desc_state)
        begin
         cur_desc_id_reg  <= desc_head[153:146];
         orig_desc_dw_reg      <= desc_head[145:128];
        end


/// current desc control reg

assign cur_dma_pause = RdDMACntrlData_i[0];
assign cur_dma_resume = RdDMACntrlData_i[1];
assign cur_dma_abort = RdDMACntrlData_i[2];
assign flush_all_desc = RdDMACntrlData_i[3];

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_abort_reg  <= 1'b0;
           flush_all_desc_reg <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_abort_reg  <=  cur_dma_abort;
           flush_all_desc_reg <=  flush_all_desc;
         end
       else if ((cur_dma_abort_reg | flush_all_desc_reg) & rd_idle_state)
         begin
           cur_dma_abort_reg  <= 1'b0;
           flush_all_desc_reg <= 1'b0;
         end
     end


 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_pause_reg  <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_pause_reg  <= cur_dma_pause;
         end
       else if (cur_dma_pause_reg & cur_dma_resume_reg)
         begin
           cur_dma_pause_reg  <= 1'b0;
         end
     end

always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_resume_reg <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_resume_reg <=  cur_dma_resume;
         end
       else if (~rd_pause_state)
         begin
           cur_dma_resume_reg  <= 1'b0;
         end
     end

  assign cur_MasterEnable =  MasterEnable_i;



//========================================================================
// Descriptor Error, set when either of the following conditions are true
// 1. MasterEnable bit is not set for this function in RD_ARB state

 assign  error_status = rd_arb_req_state & ~cur_MasterEnable;

 always_ff @ (posedge Clk_i ) begin
    if(~Rstn_i)
      error_status_reg <= 1'b0;
    else if(rd_pop_desc_state)
      error_status_reg <= 1'b0;
    else
      error_status_reg <= error_status;
 end

 always_ff @ (posedge Clk_i )
      desc_error   <= ~error_status_reg & error_status;

/// for un-aligned DMA where the address is not 32*n, the first TLP will bring it to 32-bytes aligned address



  /// the reaming byte count after a read TLP is sent
  /// for the current sub descriptor
always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      remain_dwcnt_reg <= 18'h0;
    else if(rd_pipe_state)
      remain_dwcnt_reg <=(orig_desc_dw_reg <= dw_to_4KB)? orig_desc_dw_reg : dw_to_4KB;
    else if(load_cur_desc_size_reg)
       remain_dwcnt_reg <= sub_desc_length_reg[17:0];
    else if(rd_header_state)
      remain_dwcnt_reg <= remain_dwcnt_reg - rd_dw_size;
  end

  assign bytes_to_4KB = (cur_src_addr_reg[11:0] == 12'h0)? 13'h1000 : (13'h1000 - cur_src_addr_reg[11:0]);
  assign bytes_to_128[7:0] = (cur_src_addr_reg[6:0] == 7'h0)? 8'h80 : (8'h80 - cur_src_addr_reg[6:0]);
  assign bytes_to_256[8:0] = (cur_src_addr_reg[7:0] == 8'h0)? 9'h100 : (9'h100 - cur_src_addr_reg[7:0]);
  assign bytes_to_512[9:0] = (cur_src_addr_reg[8:0] == 9'h0)? 10'h200 : (10'h200 - cur_src_addr_reg[8:0]);

  assign dw_to_4KB   = bytes_to_4KB[12:2];
  assign dw_to_128   = {5'h0, bytes_to_128[7:2]};
  assign dw_to_256   = {4'h0, bytes_to_256[8:2]};
  assign dw_to_512   = {3'h0, bytes_to_512[9:2]};

  always_comb
    begin
      case(max_rd_dw)
        10'd32 : max_rd = dw_to_128[9:0];
        10'd64 : max_rd = dw_to_256[9:0];
        default: max_rd = dw_to_512[9:0];
      endcase
    end


 assign  to_4KB_sel       = 1'b0;
 assign  remain_dw_sel    = (remain_dwcnt_reg <= max_rd) & (remain_dwcnt_reg <= dw_to_4KB);

 always @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
        begin
          rdsize_sel_reg <= 2'b00;
          rd_dw_size_reg[9:0] <= 10'h0;
        end
      else
        begin
          rdsize_sel_reg <= {remain_dw_sel,to_4KB_sel};
          rd_dw_size_reg[9:0] <= rd_dw_size;
      end
    end

  always_comb
    begin
      case(rdsize_sel_reg)
        2'b10  :  rd_dw_size   = remain_dwcnt_reg[9:0];
        default:  rd_dw_size   = max_rd;
      endcase
    end


 assign last_rd_segment = ((remain_dwcnt_reg <= max_rd) & (remain_dwcnt_reg <= dw_to_4KB) );


/// Read control state machine

// assign small_desc_size = desc_head[145:128] <= 18'd32 & desc_head[7:0] == 8'h0 ;
  assign small_desc_size = 1'b0;
assign tx_fifo_ok = (TxFifoCount_i <= 4'hD);

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_dma_state <= RD_IDLE;
         else
           rd_dma_state <= rd_dma_nxt_state;
     end

 always_comb
  begin
    case(rd_dma_state)
      RD_IDLE :
        if(~desc_fifo_empty & (desc_outstanding_reads_queue_fifo_ok| small_desc_size) & rd_status_fifo_count <= 5'h4)
          rd_dma_nxt_state <= RD_PIPE;
        else
          rd_dma_nxt_state <= RD_IDLE;

//      RD_POP_DESC:
//          rd_dma_nxt_state <= RD_PIPE;

     RD_PIPE:
       if(tag_available_reg & cpl_header_available & cpl_data_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      RD_ARB_REQ:
        if(cur_dma_abort_reg | flush_all_desc_reg | ~cur_MasterEnable) // If master_enable is not set, discard this request
          rd_dma_nxt_state <= RD_IDLE;
        else if(cur_dma_pause_reg)
          rd_dma_nxt_state <= RD_PAUSE;
        else if(RdDMmaArbGranted_i & tx_fifo_ok)
          rd_dma_nxt_state <= RD_SEND;
        else
          rd_dma_nxt_state <= RD_ARB_REQ;

      RD_SEND:
        if(cur_dma_abort_reg | flush_all_desc_reg)
          rd_dma_nxt_state <= RD_IDLE;
        else if(last_rd_segment)
          rd_dma_nxt_state <= RD_CHECK_SUB_DESC;
        else if(cur_dma_pause_reg)
          rd_dma_nxt_state <= RD_PAUSE;
        else if(tag_available_reg & cpl_header_available & cpl_data_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      RD_WAIT_TAG:
        if(tag_available_reg & cpl_header_available & cpl_data_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
         rd_dma_nxt_state <= RD_WAIT_TAG;

       RD_PAUSE:
         if(cur_dma_resume_reg & tag_available_reg)
            rd_dma_nxt_state <= RD_ARB_REQ;
         else
           rd_dma_nxt_state <= RD_PAUSE;

      RD_CHECK_SUB_DESC:
        if(last_sub_desc_reg)
           rd_dma_nxt_state <= RD_IDLE;
        else
           rd_dma_nxt_state <= RD_LD_SUB_DESC;

      RD_LD_SUB_DESC:
         if(tag_available_reg & cpl_header_available & cpl_data_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      default:
        rd_dma_nxt_state <= RD_IDLE;
    endcase
  end

  // state assignment
  assign rd_idle_state      = rd_dma_state[0]; // RD_IDLE
  //assign rd_pop_desc_state  = rd_dma_state[1]; // RD_POP_DESC
  assign rd_pop_desc_state = rd_dma_state[0] & ~desc_fifo_empty & (desc_outstanding_reads_queue_fifo_ok | small_desc_size) &  rd_status_fifo_count <= 5'h4;
  assign rd_header_state    = rd_dma_state[3]; // RD_SEND
  assign rd_arb_req_state   = rd_dma_state[2]; // RD_ARB_REQ
  assign rd_pause_state     = rd_dma_state[5]; // RD_PAUSE
  assign rd_pipe_state      = rd_dma_state[6]; // RD_PIPE
  assign rd_check_sub_desc_state  = rd_dma_state[7]; // RD_CHECK_SUB_DESC
  assign load_cur_desc_size  = rd_dma_state[8]; // RD_LD_SUB_DESC

  assign sub_desc_load =  rd_check_sub_desc_state & ~last_sub_desc_reg;

  assign RdDMmaArbReq_o =  rd_arb_req_state | rd_pipe_state;

/// tag management

     altpcie_fifo
   #(
    .FIFO_DEPTH(NUM_TAG),
    .DATA_WIDTH(NUM_TAG_WIDTH)
    )
 tag_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(tag_fifo_wrreq),
      .rdreq(tag_fifo_rdreq),
      .data(tag_fifo_wrdat),
      .q(tag),
      .fifo_count(tag_fifo_count)
);


   always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
            begin
              rd_arb_req_state_reg <= 1'b0;
              sub_desc_load_reg <= 1'b0;
              load_cur_desc_size_reg <= 1'b0;

            end
           else
            begin
              rd_arb_req_state_reg <= rd_arb_req_state;
              sub_desc_load_reg    <= sub_desc_load;
              load_cur_desc_size_reg   <= load_cur_desc_size;

            end
         end

assign  arbiter_req_rise =  ~rd_arb_req_state_reg & rd_arb_req_state;

/// init counter

generate if(EXTENDED_TAG_ENABLE == 1)
 begin
     always_ff @ (posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
               tag_counter <= {(NUM_TAG_WIDTH+3){1'b0}};
             else if(tag_counter < 11'h1FC  )  /// FC
               tag_counter <= tag_counter + 1'b1;
         end
     assign tag_fifo_wrreq = ((tag_counter[NUM_TAG_WIDTH+1:NUM_TAG_WIDTH] == 2'b01) && (tag_counter[7:0] <= 8'hFB)) | tag_release;
     assign tag_fifo_wrdat[NUM_TAG_WIDTH-1:0] = (tag_counter  < 11'h1FC)? tag_counter[NUM_TAG_WIDTH-1:0] : released_tag[NUM_TAG_WIDTH-1:0];
 end
   else
     begin
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tag_counter <= 7'h0;
         else if(tag_counter < 7'b1000000 )
           tag_counter <= tag_counter + 1'b1;
     end
      assign tag_fifo_wrreq = (tag_counter[NUM_TAG_WIDTH+1:NUM_TAG_WIDTH] == 2'b01) | tag_release;
       assign tag_fifo_wrdat[NUM_TAG_WIDTH-1:0] = (tag_counter[NUM_TAG_WIDTH+1:NUM_TAG_WIDTH] == 2'b01)? tag_counter[NUM_TAG_WIDTH-1:0] : released_tag[NUM_TAG_WIDTH-1:0];
   end
 endgenerate


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_tag_reg <= 8'h0;
         else if(tag_fifo_rdreq)
           rd_tag_reg <= {{(8-NUM_TAG_WIDTH){1'b0}}, tag[NUM_TAG_WIDTH-1:0]};
     end


generate if(EXTENDED_TAG_ENABLE == 0)
begin
 genvar j;
 for(j=0; j < NUM_TAG; j=j+1)
   begin: tag_ready_gen
     assign tag_ready[j] =  (~tag_outstanding_reg[j] & tag[NUM_TAG_WIDTH-1:0] == j);
   end
end
endgenerate

generate if(EXTENDED_TAG_ENABLE == 1)
   assign tag_ready_2 = ~tag_outstanding_reg_2;
endgenerate

generate if(EXTENDED_TAG_ENABLE == 0)
      assign tag_available_reg = (tag_fifo_count != 0) & |tag_ready[NUM_TAG-1:0];
else
      assign tag_available_reg = (tag_fifo_count != 0) & tag_ready_2;
endgenerate



 //  assign tag_available = 1'b1;
 assign tag_fifo_rdreq = arbiter_req_rise;


 // calculate first byte enable for the first TLP

generate if (DMA_WIDTH == 256)
begin

always_comb
  begin
    case(cur_dest_addr_reg[4:0])
        5'h0:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_000F;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_00FF;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_0FFF;
              10'h4 :  first_avmm_be[31:0] = 32'h0000_FFFF;
              10'h5 :  first_avmm_be[31:0] = 32'h000F_FFFF;
              10'h6 :  first_avmm_be[31:0] = 32'h00FF_FFFF;
              10'h7 :  first_avmm_be[31:0] = 32'h0FFF_FFFF;
              default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
            endcase
        5'h4:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_00F0;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_0FF0;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_FFF0;
              10'h4 :  first_avmm_be[31:0] = 32'h000F_FFF0;
              10'h5 :  first_avmm_be[31:0] = 32'h00FF_FFF0;
              10'h6 :  first_avmm_be[31:0] = 32'h0FFF_FFF0;
              10'h7 :  first_avmm_be[31:0] = 32'hFFFF_FFF0;
              default: first_avmm_be[31:0] = 32'hFFFF_FFF0;
            endcase
         5'h8:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_0F00;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_FF00;
              10'h3 :  first_avmm_be[31:0] = 32'h000F_FF00;
              10'h4 :  first_avmm_be[31:0] = 32'h00FF_FF00;
              10'h5 :  first_avmm_be[31:0] = 32'h0FFF_FF00;
              10'h6 :  first_avmm_be[31:0] = 32'hFFFF_FF00;
              default: first_avmm_be[31:0] = 32'hFFFF_FF00;
            endcase
          5'hC:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_F000;
              10'h2 :  first_avmm_be[31:0] = 32'h000F_F000;
              10'h3 :  first_avmm_be[31:0] = 32'h00FF_F000;
              10'h4 :  first_avmm_be[31:0] = 32'h0FFF_F000;
              10'h5 :  first_avmm_be[31:0] = 32'hFFFF_F000;
              default: first_avmm_be[31:0] = 32'hFFFF_F000;
            endcase
          5'h10:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h000F_0000;
              10'h2 :  first_avmm_be[31:0] = 32'h00FF_0000;
              10'h3 :  first_avmm_be[31:0] = 32'h0FFF_0000;
              10'h4 :  first_avmm_be[31:0] = 32'hFFFF_0000;
              default: first_avmm_be[31:0] = 32'hFFFF_0000;
            endcase
          5'h14:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h00F0_0000;
              10'h2 :  first_avmm_be[31:0] = 32'h0FF0_0000;
              10'h3 :  first_avmm_be[31:0] = 32'hFFF0_0000;
              default: first_avmm_be[31:0] = 32'hFFF0_0000;
            endcase
          5'h18:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0F00_0000;
              10'h2 :  first_avmm_be[31:0] = 32'hFF00_0000;
              default: first_avmm_be[31:0] = 32'hFF00_0000;
            endcase
         5'h1C:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'hF000_0000;
              default: first_avmm_be[31:0] = 32'hF000_0000;
            endcase
       default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
      endcase
  end
end
  else   /// 128-bit mux
    begin
    	always_comb
     begin
    case(cur_dest_addr_reg[3:0])
        4'h0:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_000F;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_00FF;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_0FFF;
              10'h4 :  first_avmm_be[31:0] = 32'h0000_FFFF;
              10'h5 :  first_avmm_be[31:0] = 32'h000F_FFFF;
              10'h6 :  first_avmm_be[31:0] = 32'h00FF_FFFF;
              10'h7 :  first_avmm_be[31:0] = 32'h0FFF_FFFF;
              default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
            endcase
        4'h4:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_00F0;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_0FF0;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_FFF0;
              10'h4 :  first_avmm_be[31:0] = 32'h000F_FFF0;
              10'h5 :  first_avmm_be[31:0] = 32'h00FF_FFF0;
              10'h6 :  first_avmm_be[31:0] = 32'h0FFF_FFF0;
              10'h7 :  first_avmm_be[31:0] = 32'hFFFF_FFF0;  
              default: first_avmm_be[31:0] = 32'hFFFF_FFF0;
            endcase
         4'h8:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_0F00;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_FF00;
              10'h3 :  first_avmm_be[31:0] = 32'h000F_FF00;
              10'h4 :  first_avmm_be[31:0] = 32'h00FF_FF00;
              10'h5 :  first_avmm_be[31:0] = 32'h0FFF_FF00;
              10'h6 :  first_avmm_be[31:0] = 32'hFFFF_FF00;
              default: first_avmm_be[31:0] = 32'hFFFF_FF00;
            endcase
          4'hC:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_F000;
              10'h2 :  first_avmm_be[31:0] = 32'h000F_F000;
              10'h3 :  first_avmm_be[31:0] = 32'h00FF_F000;
              10'h4 :  first_avmm_be[31:0] = 32'h0FFF_F000;
              10'h5 :  first_avmm_be[31:0] = 32'hFFFF_F000;
              default: first_avmm_be[31:0] = 32'hFFFF_F000;
            endcase
        
       default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
      endcase
  end
    end
endgenerate
  
// calculate the updated FBE after each completion
/// based on the first FBE and the Rx CPL length



generate if(EXTENDED_TAG_ENABLE == 1 && DMA_WIDTH == 256)
  begin
        always_comb
          begin
            case(adjusted_dw_count_reg_2[2:0])
              3'h1 : updated_fbe_2 <= 32'hFFFF_FFF0;
              3'h2 : updated_fbe_2 <= 32'hFFFF_FF00;
              3'h3 : updated_fbe_2 <= 32'hFFFF_F000;
              3'h4 : updated_fbe_2 <= 32'hFFFF_0000;
              3'h5 : updated_fbe_2 <= 32'hFFF0_0000;
              3'h6 : updated_fbe_2 <= 32'hFF00_0000;
              3'h7 : updated_fbe_2 <= 32'hF000_0000;
              default:updated_fbe_2 <= 32'hFFFF_FFFF;
            endcase
          end
  end
 endgenerate
 
generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 256)
    begin
           always_comb
               begin
                 case( adjusted_dw_count_reg[2:0])
                   3'h1 : updated_fbe <= 32'hFFFF_FFF0;
                   3'h2 : updated_fbe <= 32'hFFFF_FF00;
                   3'h3 : updated_fbe <= 32'hFFFF_F000;
                   3'h4 : updated_fbe <= 32'hFFFF_0000;
                   3'h5 : updated_fbe <= 32'hFFF0_0000;
                   3'h6 : updated_fbe <= 32'hFF00_0000;
                   3'h7 : updated_fbe <= 32'hF000_0000;
                   default:updated_fbe <= 32'hFFFF_FFFF;
                 endcase
               end
    end
  endgenerate

generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 128)
    begin
           always_comb
               begin
                 case( adjusted_dw_count_reg[1:0])
                   2'h1 : updated_fbe <= 32'hFFFF_FFF0;
                   2'h2 : updated_fbe <= 32'hFFFF_FF00;
                   2'h3 : updated_fbe <= 32'hFFFF_F000;
                   default:updated_fbe <= 32'hFFFF_FFFF;
                 endcase
               end
    end
endgenerate


    
/// calculate the last avalon-MM BE




 /// tag array
 generate
  genvar i;
  for(i=0; i< NUM_TAG; i=i+1)
    begin: tag_status_register

  always_ff @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
         tag_outstanding_reg[i] <= 1'b0;
      else if(rd_header_state & rd_tag_reg == i)
         tag_outstanding_reg[i] <= 1'b1;
      else if(tag_release & released_tag == i)
         tag_outstanding_reg[i] <= 1'b0;
    end


    always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_desc_id_reg[i] <= 0;
           else if(rd_header_state & rd_tag_reg == i)
              tag_desc_id_reg[i] <= cur_desc_id_reg;
         end


      always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_address_reg[i] <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
           else if(rd_header_state & rd_tag_reg == i)
              tag_address_reg[i] <= cur_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
           else if(cpl_update_tag & cpl_tag_reg == i)
              tag_address_reg[i] <= next_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
         end

       always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_fbe_reg[i] <= 32'hFFFF_FFFF;
           else if(rd_header_state & rd_tag_reg == i)
              tag_fbe_reg[i] <= first_avmm_be[31:0];
           else if(latch_header_reg & cpl_tag_reg == i)
              tag_fbe_reg[i] <= updated_fbe;
         end


// Store the total read DW's for each tag
   always_ff @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
         tag_remain_dw_reg[i] <= 10'b0;
      else if(rd_header_state & rd_tag_reg == i )
         tag_remain_dw_reg[i] <= rd_dw_size;
      else if((latch_header & cpl_tag == i))
         tag_remain_dw_reg[i] <= remain_dw - rx_dwlen;
    end

    // SRIOV save Requestor function number
    always_ff @(posedge Clk_i )
         begin
           if(~Rstn_i)
              tag_func_reg[i] <= 8'h0;
           else if(rd_header_state & rd_tag_reg == i)
              tag_func_reg[i] <= 8'h0;
         end

    end
  endgenerate

/// ************************************************** ///
//// TAG RAM Mirror Logic ///////////////////BEGIN BEGIN////////////
//**********************************************

  /// TAG RAm Byte enable pre-decode
generate if(EXTENDED_TAG_ENABLE == 1)
  begin

        assign rd_and_latch_reg_same_clock = rd_header_state & latch_header_reg;
    always_ff @(posedge Clk_i )
      rd_and_latch_reg_same_clock_reg <= rd_and_latch_reg_same_clock;

   // assign tagram_fbe_wraddr =  rd_header_state? rd_tag_reg : cpl_tag_reg;
    assign tagram_fbe_wraddr =  latch_header_reg? cpl_tag_reg : rd_tag_reg;

     // assign tagram_fbe_wrdata  =  rd_header_state? first_avmm_be[31:0]: updated_fbe_2[31:0];

    assign tagram_fbe_wrdata  =  latch_header_reg?  updated_fbe_2[31:0] : first_avmm_be[31:0];

            altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(32),
                        .widthad_a(8),
                        .numwords_a(256),
                        .width_b(32),
                        .widthad_b(8),
                        .numwords_b(256),
                        .lpm_type("altsyncram"),
                        .width_byteena_a(1),
                        .outdata_reg_b("UNREGISTERED"),
                        .indata_aclr_a("NONE"),
                        .wrcontrol_aclr_a("NONE"),
                        .address_aclr_a("NONE"),
                        .address_reg_b("CLOCK0"),
                        .address_aclr_b("NONE"),
                        .outdata_aclr_b("NONE"),
                        .power_up_uninitialized("FALSE"),
                        .ram_block_type("AUTO"),
                        .read_during_write_mode_mixed_ports("DONT_CARE")


        )

        ext_tagram_byteenable (
                                        .wren_a (rd_header_state | latch_header_reg | rd_and_latch_reg_same_clock_reg),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (tagram_fbe_wraddr),
                                        .address_b (PreDecodeTag_i),
                                        .data_a (tagram_fbe_wrdata),
                                        .q_b (avmm_fbe_pre_tagramq),
                                        .aclr0 (),
                                        .aclr1 (),
                                        .addressstall_a (),
                                        .addressstall_b (),
                                        .byteena_a (),
                                        .byteena_b (),
                                        .clocken0 (),
                                        .data_b (),
                                        .q_a (),
                                        .rden_b (),
                                        .wren_b ()
                        );
    assign   avmm_fbe_pre_2 = avmm_fbe_pre_tagramq;
    assign   avmm_fbe_pre = 32'h0;

 //////////////////////////////////////////////////////////////


  always @(posedge Clk_i)
  begin
   cpl_update_tag_reg <= cpl_update_tag;
  end

// assign tagram_dest_addr_wrdata = rd_header_state? cur_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0] : next_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
assign tagram_destaddr_wraddr  = cpl_update_tag_reg? cpl_tag_reg : rd_tag_reg;
assign tagram_dest_addr_wrdata = cpl_update_tag_reg? next_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0] :  cur_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
             altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(RDDMA_AVL_ADDR_WIDTH),
                        .widthad_a(8),
                        .numwords_a(256),
                        .width_b(RDDMA_AVL_ADDR_WIDTH),
                        .widthad_b(8),
                        .numwords_b(256),
                        .lpm_type("altsyncram"),
                        .width_byteena_a(1),
                        .outdata_reg_b("UNREGISTERED"),
                        .indata_aclr_a("NONE"),
                        .wrcontrol_aclr_a("NONE"),
                        .address_aclr_a("NONE"),
                        .address_reg_b("CLOCK0"),
                        .address_aclr_b("NONE"),
                        .outdata_aclr_b("NONE"),
                        .power_up_uninitialized("FALSE"),
                        .ram_block_type("AUTO"),
                        .read_during_write_mode_mixed_ports("DONT_CARE")


        )

        ext_tagram_dest_address (
                                        .wren_a (update_address_array),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (tagram_destaddr_wraddr),
                                        .address_b (PreDecodeTag_i),
                                        .data_a (tagram_dest_addr_wrdata),
                                        .q_b (avmm_dest_addr_tagramq),
                                        .aclr0 (),
                                        .aclr1 (),
                                        .addressstall_a (),
                                        .addressstall_b (),
                                        .byteena_a (),
                                        .byteena_b (),
                                        .clocken0 (),
                                        .data_b (),
                                        .q_a (),
                                        .rden_b (),
                                        .wren_b ()
                        );

    assign tag_address_reg_2 = avmm_dest_addr_tagramq;

 //////// Misc ... desc ID, function, remain dw...


 assign tagram_misc_wrdata = rd_header_state? { 8'h0 ,cur_desc_id_reg[7:0] ,rd_dw_size[9:0]} : { avmm_mis_tagramq[25:18],avmm_mis_tagramq[17:10] , (remain_dw - rx_dwlen)};
 assign tagram_misc_wraddr =  rd_header_state? rd_tag_reg : cpl_tag;


              altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(26),
                        .widthad_a(8),
                        .numwords_a(256),
                        .width_b(26),
                        .widthad_b(8),
                        .numwords_b(256),
                        .lpm_type("altsyncram"),
                        .width_byteena_a(1),
                        .outdata_reg_b("UNREGISTERED"),
                        .indata_aclr_a("NONE"),
                        .wrcontrol_aclr_a("NONE"),
                        .address_aclr_a("NONE"),
                        .address_reg_b("CLOCK0"),
                        .address_aclr_b("NONE"),
                        .outdata_aclr_b("NONE"),
                        .power_up_uninitialized("FALSE"),
                        .ram_block_type("AUTO"),
                        .read_during_write_mode_mixed_ports("DONT_CARE")


        )

        ext_tagram_misc (
                                        .wren_a (rd_header_state | latch_header),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (tagram_misc_wraddr),
                                        .address_b (PreDecodeTag_i),
                                        .data_a (tagram_misc_wrdata),
                                        .q_b (avmm_mis_tagramq),
                                        .aclr0 (),
                                        .aclr1 (),
                                        .addressstall_a (),
                                        .addressstall_b (),
                                        .byteena_a (),
                                        .byteena_b (),
                                        .clocken0 (),
                                        .data_b (),
                                        .q_a (),
                                        .rden_b (),
                                        .wren_b ()
                        );

assign tag_remain_dw_reg_2 = avmm_mis_tagramq[9:0];
assign tag_desc_id_reg_2   = avmm_mis_tagramq[17:10];
assign tag_func_reg_2      = avmm_mis_tagramq[25:18];

///////////////////////////////////////// outstanding tag flag //////////////


 assign tagram_outstanding_wrdata = rd_header_state? 1'b1 : 1'b0;
 assign tagramoutstanding_wraddr =  rd_header_state? rd_tag_reg : released_tag;

             altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(1),
                        .widthad_a(8),
                        .numwords_a(256),
                        .width_b(1),
                        .widthad_b(8),
                        .numwords_b(256),
                        .lpm_type("altsyncram"),
                        .width_byteena_a(1),
                        .outdata_reg_b("UNREGISTERED"),
                        .indata_aclr_a("NONE"),
                        .wrcontrol_aclr_a("NONE"),
                        .address_aclr_a("NONE"),
                        .address_reg_b("CLOCK0"),
                        .address_aclr_b("NONE"),
                        .outdata_aclr_b("NONE"),
                        .power_up_uninitialized("FALSE"),
                        .ram_block_type("AUTO"),
                        .read_during_write_mode_mixed_ports("DONT_CARE")


        )

        ext_tagram_outstanding (
                                        .wren_a (rd_header_state | tag_release),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (tagramoutstanding_wraddr),
                                        .address_b (tag[7:0]),
                                        .data_a (tagram_outstanding_wrdata),
                                        .q_b (avmm_outstanding_tagramq),
                                        .aclr0 (),
                                        .aclr1 (),
                                        .addressstall_a (),
                                        .addressstall_b (),
                                        .byteena_a (),
                                        .byteena_b (),
                                        .clocken0 (),
                                        .data_b (),
                                        .q_a (),
                                        .rden_b (),
                                        .wren_b ()
                        );

  assign tag_outstanding_reg_2 = avmm_outstanding_tagramq;

  end
endgenerate


/// ************************************************** ///
////ENDING TAG RAM Mirror Logic ///////END END END ////////////////////////
//**********************************************
/// detect if the read and completion try to write to the array at the same clock

generate if(EXTENDED_TAG_ENABLE)
  begin
      assign rd_and_cpl_same_clock = rd_header_state & cpl_update_tag_reg;

       always_ff @(posedge Clk_i )
           rd_and_cpl_same_clock_reg <= rd_and_cpl_same_clock;

      assign update_address_array =  (rd_header_state |cpl_update_tag_reg) | rd_and_cpl_same_clock_reg; /// same cpl/rd update at same time, assert additional pulse;
  end
endgenerate


/// holding updated FBE values for used in B2B tag case

generate if(EXTENDED_TAG_ENABLE)
  begin
           always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
            begin
              updated_fbe_reg_2 <= 32'hFFFF_FFFF;
            end
           else if(latch_header_reg)
             begin
              updated_fbe_reg_2 <= updated_fbe_2;
             end
         end
  end
else
  begin
           always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
            begin
              updated_fbe_reg <= 32'hFFFF_FFFF;
            end
           else if(latch_header_reg)
             begin
              updated_fbe_reg <= updated_fbe;
             end
         end
  end
endgenerate


/// Processing the CPL TLP comming back from TLP reads

  assign rx_sop        = RxFifoDataq_i[256];
  assign rx_dwlen      = RxFifoDataq_i[9:0];
  assign cpl_tag       = RxFifoDataq_i[79:72];
  assign rx_cpl_addr   = RxFifoDataq_i[71:64];
  assign cpl_addr_bit2 =  rx_cpl_addr[2];
  assign cpl_bytecount = RxFifoDataq_i[43:32];
  assign is_cpl_wd     = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b01010);
  assign last_cpl      = ((cpl_bytecount[11:2] == rx_dwlen ) | (cpl_bytecount <= 4)) & is_cpl_wd & rx_sop;
  assign rx_fifo_empty = (RxFifoCount_i == 4'h0);
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_cpl_state <= RDCPL_IDLE;
         else
           rd_cpl_state <= rdcpl_nxt_state;
      end
//////////////////////////////////////////////
//// Completion state machine //////////////
///////////////////////////////////////////////

//assign valid_cpl_available = (is_cpl_wd & rx_sop & cpl_tag <= (NUM_TAG - 1) & ~rx_fifo_empty);  // & avmm_fifo_ok);
generate if(EXTENDED_TAG_ENABLE == 1)
  assign valid_cpl_available = (cpl_tag < 8'hfc & is_cpl_wd & rx_sop & ~rx_fifo_empty);
else
  assign  valid_cpl_available = (is_cpl_wd & rx_sop & cpl_tag <= (NUM_TAG - 1) & ~rx_fifo_empty);
endgenerate

always_comb
  begin
    case(rd_cpl_state)
      RDCPL_IDLE :
        if(valid_cpl_available & ~latch_header_reg2)  /// delayed if the last latch header is too close since the tag ram takes 2 clocks
          rdcpl_nxt_state <= (DMA_WIDTH == 256) ? RDCPL_WRITE : RDCPL_WAIT;
        else
          rdcpl_nxt_state <= RDCPL_IDLE;
      RDCPL_WAIT:
          if (~rx_fifo_empty | avmm_burst_cnt_reg_sig == 1)
             rdcpl_nxt_state <= RDCPL_WRITE;
          else
             rdcpl_nxt_state <= RDCPL_WAIT;
      RDCPL_WRITE:
         if(avmm_burst_cntr_sig == 1 & (~waitreq_duo_to_avmmwr_fifo)) begin
            if (~(valid_cpl_available & ~latch_header_reg2)  |((DMA_WIDTH == 256) & (avmm_burst_cnt_reg_sig == 1)))
               rdcpl_nxt_state <= RDCPL_IDLE;
            else
               rdcpl_nxt_state <= (DMA_WIDTH == 256) ? RDCPL_WRITE : RDCPL_WAIT;
         end
         else
            rdcpl_nxt_state <= RDCPL_WRITE;
      default:
         rdcpl_nxt_state <= RDCPL_IDLE;
    endcase
  end

assign rdcpl_idle_state  = rd_cpl_state[0];
assign rdcpl_wait_state  = rd_cpl_state[1];
assign rdcpl_write_state = rd_cpl_state[2];

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           latch_header_reg <= 1'b0;
           latch_header_reg2 <= 1'b0;
           adjusted_dw_count_reg <= 10'h0;
           rdcpl_write_state_reg <= 1'b0;
         end
       else
        begin
           latch_header_reg <= latch_header;
           latch_header_reg2 <= latch_header_reg;
           adjusted_dw_count_reg <= adjusted_dw_count;
           rdcpl_write_state_reg <= rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo;

        end
      end

generate if(EXTENDED_TAG_ENABLE == 1)
  begin
        always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           adjusted_dw_count_reg_2 <= 10'h0;
         end
       else if(latch_header)
        begin
           adjusted_dw_count_reg_2 <= adjusted_dw_count_2;
        end
      end
end

endgenerate
// assign tag_release  = latch_header_reg &  last_cpl_reg;

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_on_progress_sreg <= 1'b0;
       else if(latch_header)
           cpl_on_progress_sreg <= 1'b1;
       else if(rx_eop_reg)
           cpl_on_progress_sreg <= 1'b0;
      end

assign tag_release_queuing  = (latch_header_reg &  last_cpl_reg & rx_eop_reg)  |
                             (cpl_on_progress_sreg & last_cpl_reg & rx_eop_reg) ;

 altpcie_fifo
   #(
    .FIFO_DEPTH(4),
    .DATA_WIDTH(NUM_TAG_WIDTH)
    )
 tag_queu  // tag release queu
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(tag_release_queuing),
      .rdreq(tag_queu_rdreq),
      .data(cpl_tag_reg[NUM_TAG_WIDTH-1:0]),
      .q(released_tag),
      .fifo_count(tag_queu_count)
);
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
          write_stall_reg <= 1'b0;
       else
           write_stall_reg <= rdcpl_write_state & waitreq_duo_to_avmmwr_fifo;
     end

assign tag_queu_rdreq = (tag_queu_count != 0 ) & ~write_stall_reg & ~rd_header_state;
assign tag_release = tag_queu_rdreq;


assign latch_header_from_idle_state   =  (rdcpl_idle_state & valid_cpl_available & ~latch_header_reg2);
//assign latch_header_from_idle_state   =  (rdcpl_idle_state & valid_cpl_available);
assign latch_header_from_write_state  =   (rdcpl_write_state & avmm_burst_cntr_sig == 1 & (valid_cpl_available & ~latch_header_reg2)    & ~waitreq_duo_to_avmmwr_fifo &
                                          ((DMA_WIDTH == 256) ? (avmm_burst_cnt_reg_sig != 1) : 1'b1));

assign latch_header = latch_header_from_idle_state |
                      latch_header_from_write_state;

generate if(EXTENDED_TAG_ENABLE == 1)
  assign cpl_update_tag =  latch_header & ~last_cpl;
else
  assign cpl_update_tag =  latch_header & ~last_cpl_reg;
endgenerate

assign next_dest_addr_reg =  avmm_addr_reg + {rx_dwlen_reg[9:0], 2'b00};

// latching the header


generate if(EXTENDED_TAG_ENABLE == 1)
 begin
  assign avmm_burst_cnt_2[DMA_BRST_CNT_W-1:0] = (DMA_WIDTH == 256) ? ((adjusted_dw_count_2[2:0] == 3'b000)? {1'b0, adjusted_dw_count_2[6:3]} :  {1'b0, adjusted_dw_count_2[6:3] + 4'h1}) :
                                                  ((adjusted_dw_count_2[1:0] == 2'b00)? {1'b0, adjusted_dw_count_2[6:2]} :  {1'b0, adjusted_dw_count_2[6:2] + 4'h1});
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
            avmm_burst_cnt_reg_2 <= 5'h0;
         end
       else if(latch_header)
         begin
              avmm_burst_cnt_reg_2 <=avmm_burst_cnt_2;
         end
      end
 end
else
  begin
  assign avmm_burst_cnt[DMA_BRST_CNT_W-1:0] = (DMA_WIDTH == 256) ? ((adjusted_dw_count[2:0] == 3'b000)? {1'b0, adjusted_dw_count[6:3]} :  {1'b0, adjusted_dw_count[6:3] + 4'h1}) :
                                                  ((adjusted_dw_count[1:0] == 2'b00)? {1'b0, adjusted_dw_count[6:2]} :  {1'b0, adjusted_dw_count[6:2] + 4'h1});
  end
endgenerate


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           rx_dwlen_reg <= 10'h0;
           avmm_burst_cnt_reg <= 5'h0;
           cpl_addr_bit2_reg  <= 1'b0;
           last_cpl_reg  <= 1'b0;
         end
       else if(latch_header)
         begin
            rx_dwlen_reg <= rx_dwlen;
            avmm_burst_cnt_reg <=avmm_burst_cnt;
            cpl_addr_bit2_reg <= cpl_addr_bit2;
            last_cpl_reg <= last_cpl;
         end
      end


always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_tag_reg <= 8'hFE;
       else if(latch_header)
            cpl_tag_reg <= cpl_tag;
       else if(tag_release_queuing)
             cpl_tag_reg <= 8'hFE;
      end

// burst counter


generate if(EXTENDED_TAG_ENABLE == 1)
   begin
            assign first_dw_holes_2 = (updated_fbe_reg_2[4:3]  ==2'b10)?10'h1:
                           (updated_fbe_reg_2[8:7]  ==2'b10)?10'h2:
                           (updated_fbe_reg_2[12:11]==2'b10)?10'h3:
                           ((DMA_WIDTH==256) && (updated_fbe_reg_2[16:15]==2'b10))?10'h4:
                           ((DMA_WIDTH==256) && (updated_fbe_reg_2[20:19]==2'b10))?10'h5:
                           ((DMA_WIDTH==256) && (updated_fbe_reg_2[24:23]==2'b10))?10'h6:
                           ((DMA_WIDTH==256) && (updated_fbe_reg_2[28:27]==2'b10))?10'h7: 10'h0;

     assign first_dw_holes_pre_2 = (avmm_fbe_pre_2[4:3]  ==2'b10)?10'h1:
                               (avmm_fbe_pre_2[8:7]  ==2'b10)?10'h2:
                               (avmm_fbe_pre_2[12:11]==2'b10)?10'h3:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre_2[16:15]==2'b10))?10'h4:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre_2[20:19]==2'b10))?10'h5:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre_2[24:23]==2'b10))?10'h6:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre_2[28:27]==2'b10))?10'h7: 10'h0;

      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
      if(~Rstn_i)
       begin
         first_dw_holes_pre_reg_2<= 10'h0;
       end
      else
       begin
         first_dw_holes_pre_reg_2 <= first_dw_holes_pre_2;
       end
   end

assign empty_dw_reg_2 = b2b_same_tag?  first_dw_holes_2 : first_dw_holes_pre_reg_2;

assign adjusted_dw_count_2 = rx_dwlen[6:0] + empty_dw_reg_2[6:0];

   end
else
  begin
    assign first_dw_holes = (updated_fbe_reg[4:3]  ==2'b10)?10'h1:
                           (updated_fbe_reg[8:7]  ==2'b10)?10'h2:
                           (updated_fbe_reg[12:11]==2'b10)?10'h3:
                           ((DMA_WIDTH==256) && (updated_fbe_reg[16:15]==2'b10))?10'h4:
                           ((DMA_WIDTH==256) && (updated_fbe_reg[20:19]==2'b10))?10'h5:
                           ((DMA_WIDTH==256) && (updated_fbe_reg[24:23]==2'b10))?10'h6:
                           ((DMA_WIDTH==256) && (updated_fbe_reg[28:27]==2'b10))?10'h7: 10'h0;



   assign first_dw_holes_pre = (avmm_fbe_pre[4:3]  ==2'b10)?10'h1:
                               (avmm_fbe_pre[8:7]  ==2'b10)?10'h2:
                               (avmm_fbe_pre[12:11]==2'b10)?10'h3:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre[16:15]==2'b10))?10'h4:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre[20:19]==2'b10))?10'h5:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre[24:23]==2'b10))?10'h6:
                               ((DMA_WIDTH==256) && (avmm_fbe_pre[28:27]==2'b10))?10'h7: 10'h0;

     always_ff @ (posedge Clk_i or negedge Rstn_i) begin
      if(~Rstn_i)
       begin
         first_dw_holes_pre_reg<= 10'h0;
       end
      else
       begin
         first_dw_holes_pre_reg <= first_dw_holes_pre;
       end
   end



assign empty_dw_reg = b2b_same_tag?  first_dw_holes : first_dw_holes_pre_reg;


assign adjusted_dw_count = rx_dwlen[6:0] + empty_dw_reg[6:0];
  end
endgenerate


generate if(EXTENDED_TAG_ENABLE)
  begin
          always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_burst_cntr_2 <= 5'h0;
       else if(latch_header)
            avmm_burst_cntr_2 <=  (DMA_WIDTH == 256) ? ((adjusted_dw_count_2[2:0] == 3'b000)? {1'b0, adjusted_dw_count_2[6:3]} :  {1'b0, adjusted_dw_count_2[6:3] + 4'h1}) :
                                                     ((adjusted_dw_count_2[1:0] == 2'b00)? {1'b0, adjusted_dw_count_2[6:2]} :  {1'b0, adjusted_dw_count_2[6:2] + 4'h1});
       else if(rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo)
            avmm_burst_cntr_2 <= avmm_burst_cntr_2 - 1'b1;
      end
  end
else
  begin
          always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_burst_cntr <= 5'h0;
       else if(latch_header)
            avmm_burst_cntr <=  (DMA_WIDTH == 256) ? ((adjusted_dw_count[2:0] == 3'b000)? {1'b0, adjusted_dw_count[6:3]} :  {1'b0, adjusted_dw_count[6:3] + 4'h1}) :
                                                     ((adjusted_dw_count[1:0] == 2'b00)? {1'b0, adjusted_dw_count[6:2]} :  {1'b0, adjusted_dw_count[6:2] + 4'h1});
       else if(rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo)
            avmm_burst_cntr <= avmm_burst_cntr - 1'b1;
      end
  end
endgenerate



 // pipe register
   always_ff @ (posedge Clk_i)
     begin
       if(RxFifoRdReq_o)
         begin
            tlp_reg[265:0] <= tlp_fifo;
         end
      end

  always_ff @ (posedge Clk_i)
     begin
       if((rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo) || (rd_cpl_state[1] && cpl_addr_bit2_reg & (first_valid_addr == 8'h00)))
            tlp_hold_reg[265:0] <= tlp_reg;
      end

  assign tlp_fifo[265:0] = RxFifoDataq_i[265:0];
  assign rx_eop_reg = tlp_reg[257];

assign tlp_reg_dw0 = tlp_reg[31:0];
assign tlp_reg_dw1 = tlp_reg[63:32];
assign tlp_reg_dw2 = tlp_reg[95:64];
assign tlp_reg_dw3 = tlp_reg[127:96];
assign tlp_reg_dw4 = (DMA_WIDTH == 256) ? tlp_reg[159:128] : tlp_reg[31:0];
assign tlp_reg_dw5 = (DMA_WIDTH == 256) ? tlp_reg[191:160] : tlp_reg[63:32];
assign tlp_reg_dw6 = (DMA_WIDTH == 256) ? tlp_reg[223:192] : tlp_reg[95:64];
assign tlp_reg_dw7 = (DMA_WIDTH == 256) ? tlp_reg[255:224] : tlp_reg[127:96];

assign tlp_hold_reg_dw1 = tlp_hold_reg[63:32];
assign tlp_hold_reg_dw2 = tlp_hold_reg[95:64];
assign tlp_hold_reg_dw3 = tlp_hold_reg[127:96];

assign tlp_hold_reg_dw4 = (DMA_WIDTH == 256) ? tlp_hold_reg[159:128] : tlp_hold_reg[31:0];
assign tlp_hold_reg_dw5 = (DMA_WIDTH == 256) ? tlp_hold_reg[191:160] : tlp_hold_reg[63:32];
assign tlp_hold_reg_dw6 = (DMA_WIDTH == 256) ? tlp_hold_reg[223:192] : tlp_hold_reg[95:64];
assign tlp_hold_reg_dw7 = (DMA_WIDTH == 256) ? tlp_hold_reg[255:224] : tlp_hold_reg[127:96];


assign tlp_fifo_dw0 = tlp_fifo[31:0];
assign tlp_fifo_dw1 = tlp_fifo[63:32];
assign tlp_fifo_dw2 = tlp_fifo[95:64];
assign tlp_fifo_dw3 = tlp_fifo[127:96];



 // load the AVMM address and BE registers based on tag

generate if(EXTENDED_TAG_ENABLE == 1)
  assign b2b_same_tag = (cpl_tag == cpl_tag_reg);
else
  assign b2b_same_tag = (cpl_tag == cpl_tag_reg);
endgenerate

  generate if(EXTENDED_TAG_ENABLE == 0)
    begin
           always_ff @ (posedge Clk_i or negedge Rstn_i)
              begin
                if(~Rstn_i)
                    avmm_addr_reg <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
                else if(latch_header & ~b2b_same_tag)
                    case (cpl_tag[7:0])
                      8'd0 : avmm_addr_reg <=  tag_address_reg[0][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd1 : avmm_addr_reg <=  tag_address_reg[1][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd2 : avmm_addr_reg <=  tag_address_reg[2][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd3 : avmm_addr_reg <=  tag_address_reg[3][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd4 : avmm_addr_reg <=  tag_address_reg[4][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd5 : avmm_addr_reg <=  tag_address_reg[5][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd6 : avmm_addr_reg <=  tag_address_reg[6][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd7 : avmm_addr_reg <=  tag_address_reg[7][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd8 : avmm_addr_reg <=  tag_address_reg[8][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd9 : avmm_addr_reg <=  tag_address_reg[9][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd10 : avmm_addr_reg <= tag_address_reg[10][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd11 : avmm_addr_reg <= tag_address_reg[11][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd12 : avmm_addr_reg <= tag_address_reg[12][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd13 : avmm_addr_reg <= tag_address_reg[13][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd14 : avmm_addr_reg <= tag_address_reg[14][RDDMA_AVL_ADDR_WIDTH-1:0];
                      8'd15 : avmm_addr_reg <= tag_address_reg[15][RDDMA_AVL_ADDR_WIDTH-1:0];
                      default : avmm_addr_reg <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
                  endcase
                else if(latch_header)   /// same tag, just update the register not the tag ram
                    avmm_addr_reg <= avmm_addr_reg + {rx_dwlen_reg[9:0], 2'b00};
               end

  end

else
     begin

             always_ff @ (posedge Clk_i or negedge Rstn_i)
              begin
                if(~Rstn_i)
                    avmm_addr_reg <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
                else if(latch_header & ~b2b_same_tag)
                      avmm_addr_reg <=  tag_address_reg_2[RDDMA_AVL_ADDR_WIDTH-1:0];
                else if(latch_header)   /// same tag, just update the register not the tag ram
                    avmm_addr_reg <= avmm_addr_reg + {rx_dwlen_reg[9:0], 2'b00};
               end
      end
endgenerate


generate if(EXTENDED_TAG_ENABLE)
  begin
              always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_fbe_reg_2 <= 32'h0;
       else if(latch_header & b2b_same_tag)
             avmm_fbe_reg_2 <=(adjusted_dw_count_2 < (DMA_WIDTH/32))? adjusted_avmm_fbe_2 : updated_fbe_2;
       else if(latch_header)
             avmm_fbe_reg_2 <=(adjusted_dw_count_2 < (DMA_WIDTH/32))? adjusted_avmm_fbe_2 :  avmm_fbe_2;
       else if(rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo)
            avmm_fbe_reg_2 <= 32'hFFFF_FFFF;
      end

   assign avmm_fbe_2 = avmm_fbe_pre_2;
  end
else
  begin
         /// FBE needs ajusted if CPL length is small < 8
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_fbe_reg <= 32'h0;
       else if(latch_header)
             avmm_fbe_reg <=(adjusted_dw_count < (DMA_WIDTH/32))? adjusted_avmm_fbe :  avmm_fbe;
       else if(rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo)
            avmm_fbe_reg <= 32'hFFFF_FFFF;
      end
  end
endgenerate

       always_comb
         begin
          case (cpl_tag[7:0])
             8'd0 :  avmm_fbe  <= tag_fbe_reg[0] ;
             8'd1 :  avmm_fbe  <= tag_fbe_reg[1] ;
             8'd2 :  avmm_fbe  <= tag_fbe_reg[2] ;
             8'd3 :  avmm_fbe  <= tag_fbe_reg[3] ;
             8'd4 :  avmm_fbe  <= tag_fbe_reg[4] ;
             8'd5 :  avmm_fbe  <= tag_fbe_reg[5] ;
             8'd6 :  avmm_fbe  <= tag_fbe_reg[6] ;
             8'd7 :  avmm_fbe  <= tag_fbe_reg[7] ;
             8'd8 :  avmm_fbe  <= tag_fbe_reg[8] ;
             8'd9 :  avmm_fbe  <= tag_fbe_reg[9] ;
             8'd10 : avmm_fbe  <= tag_fbe_reg[10];
             8'd11 : avmm_fbe  <= tag_fbe_reg[11];
             8'd12 : avmm_fbe  <= tag_fbe_reg[12];
             8'd13 : avmm_fbe  <= tag_fbe_reg[13];
             8'd14 : avmm_fbe  <= tag_fbe_reg[14];
             8'd15 : avmm_fbe  <= tag_fbe_reg[15];
             default : avmm_fbe <= 32'hFFFFFFFF;
           endcase
         end



generate if(EXTENDED_TAG_ENABLE == 0)
  begin
       always_comb
         begin
          case (PreDecodeTag_i[7:0])
             8'd0 :  avmm_fbe_pre <= tag_fbe_reg[0] ;
             8'd1 :  avmm_fbe_pre <= tag_fbe_reg[1] ;
             8'd2 :  avmm_fbe_pre <= tag_fbe_reg[2] ;
             8'd3 :  avmm_fbe_pre <= tag_fbe_reg[3] ;
             8'd4 :  avmm_fbe_pre <= tag_fbe_reg[4] ;
             8'd5 :  avmm_fbe_pre <= tag_fbe_reg[5] ;
             8'd6 :  avmm_fbe_pre <= tag_fbe_reg[6] ;
             8'd7 :  avmm_fbe_pre <= tag_fbe_reg[7] ;
             8'd8 :  avmm_fbe_pre <= tag_fbe_reg[8] ;
             8'd9 :  avmm_fbe_pre <= tag_fbe_reg[9] ;
             8'd10 : avmm_fbe_pre <= tag_fbe_reg[10];
             8'd11 : avmm_fbe_pre <= tag_fbe_reg[11];
             8'd12 : avmm_fbe_pre <= tag_fbe_reg[12];
             8'd13 : avmm_fbe_pre <= tag_fbe_reg[13];
             8'd14 : avmm_fbe_pre <= tag_fbe_reg[14];
             8'd15 : avmm_fbe_pre <= tag_fbe_reg[15];
            default : avmm_fbe_pre <= 32'hFFFFFFFF;
           endcase
         end
  end
endgenerate


generate if(EXTENDED_TAG_ENABLE == 1 && DMA_WIDTH == 256 )
        begin
          always_comb
               begin
                 case(adjusted_dw_count_2[2:0])
                   3'h1 : adjusted_avmm_fbe_2 <= 32'h0000_000F & avmm_fbe_2[31:0];
                   3'h2 : adjusted_avmm_fbe_2 <= 32'h0000_00FF & avmm_fbe_2[31:0];
                   3'h3 : adjusted_avmm_fbe_2 <= 32'h0000_0FFF & avmm_fbe_2[31:0];
                   3'h4 : adjusted_avmm_fbe_2 <= 32'h0000_FFFF & avmm_fbe_2[31:0];
                   3'h5 : adjusted_avmm_fbe_2 <= 32'h000F_FFFF & avmm_fbe_2[31:0];
                   3'h6 : adjusted_avmm_fbe_2 <= 32'h00FF_FFFF & avmm_fbe_2[31:0];
                   3'h7 : adjusted_avmm_fbe_2 <= 32'h0FFF_FFFF & avmm_fbe_2[31:0];
                   default:adjusted_avmm_fbe_2 <= 32'h0000_0000;
                 endcase
               end       
        end
 endgenerate
 
generate if (EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 256 )
  begin
      always_comb
        begin
          case(adjusted_dw_count[2:0])
            3'h1 : adjusted_avmm_fbe <= 32'h0000_000F & avmm_fbe[31:0];
            3'h2 : adjusted_avmm_fbe <= 32'h0000_00FF & avmm_fbe[31:0];
            3'h3 : adjusted_avmm_fbe <= 32'h0000_0FFF & avmm_fbe[31:0];
            3'h4 : adjusted_avmm_fbe <= 32'h0000_FFFF & avmm_fbe[31:0];
            3'h5 : adjusted_avmm_fbe <= 32'h000F_FFFF & avmm_fbe[31:0];
            3'h6 : adjusted_avmm_fbe <= 32'h00FF_FFFF & avmm_fbe[31:0];
            3'h7 : adjusted_avmm_fbe <= 32'h0FFF_FFFF & avmm_fbe[31:0];
            default:adjusted_avmm_fbe <= 32'h0000_0000;
          endcase
        end
  end
endgenerate


generate if (EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 128 )
  begin
      always_comb
        begin
          case(adjusted_dw_count[1:0])
            2'h1 : adjusted_avmm_fbe <= 32'h0000_000F & avmm_fbe[31:0];
            2'h2 : adjusted_avmm_fbe <= 32'h0000_00FF & avmm_fbe[31:0];
            2'h3 : adjusted_avmm_fbe <= 32'h0000_0FFF & avmm_fbe[31:0];
            default:adjusted_avmm_fbe <= 32'h0000_0000;
          endcase
        end
  end
endgenerate



generate if(EXTENDED_TAG_ENABLE == 1 && DMA_WIDTH == 256)
  begin
        always_comb
        begin
          case(adjusted_dw_count_2[2:0])
            3'h1 : adjusted_avmm_lbe_2 <= 32'h0000_000F ;
            3'h2 : adjusted_avmm_lbe_2 <= 32'h0000_00FF ;
            3'h3 : adjusted_avmm_lbe_2 <= 32'h0000_0FFF ;
            3'h4 : adjusted_avmm_lbe_2 <= 32'h0000_FFFF ;
            3'h5 : adjusted_avmm_lbe_2 <= 32'h000F_FFFF ;
            3'h6 : adjusted_avmm_lbe_2 <= 32'h00FF_FFFF ;
            3'h7 : adjusted_avmm_lbe_2 <= 32'h0FFF_FFFF ;
           default:adjusted_avmm_lbe_2 <= 32'hFFFF_FFFF;
          endcase
        end
   end  
endgenerate


generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 256)
    begin
         always_comb
             begin
               case(adjusted_dw_count[2:0])
                 3'h1 : adjusted_avmm_lbe <= 32'h0000_000F ;
                 3'h2 : adjusted_avmm_lbe <= 32'h0000_00FF ;
                 3'h3 : adjusted_avmm_lbe <= 32'h0000_0FFF ;
                 3'h4 : adjusted_avmm_lbe <= 32'h0000_FFFF ;
                 3'h5 : adjusted_avmm_lbe <= 32'h000F_FFFF ;
                 3'h6 : adjusted_avmm_lbe <= 32'h00FF_FFFF ;
                 3'h7 : adjusted_avmm_lbe <= 32'h0FFF_FFFF ;
                default:adjusted_avmm_lbe <= 32'hFFFF_FFFF;
               endcase
             end
    end
endgenerate

generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 128)
  begin
         always_comb
            begin
              case(adjusted_dw_count[1:0])
                2'h1 : adjusted_avmm_lbe <= 32'h0000_000F ;
                2'h2 : adjusted_avmm_lbe <= 32'h0000_00FF ;
                2'h3 : adjusted_avmm_lbe <= 32'h0000_0FFF ;
                default:adjusted_avmm_lbe <= 32'hFFFF_FFFF;
              endcase
            end
   end
endgenerate



generate if(EXTENDED_TAG_ENABLE == 1)
  begin
          always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tag_first_enable_reg_2 <= 32'hFFFFFFFF;
       else if(latch_header & b2b_same_tag)
         tag_first_enable_reg_2 <= updated_fbe_2;
       else if(latch_header)
           tag_first_enable_reg_2 <= avmm_fbe_2;
      end
  end
else
  begin
            always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tag_first_enable_reg <= 32'hFFFFFFFF;
       else if(latch_header)
           tag_first_enable_reg <= avmm_fbe;
      end
  end
endgenerate



 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_first_write_reg <= 1'b0;
       else if(latch_header)
           avmm_first_write_reg <= 1'b1;
       else if(rdcpl_write_state & ~waitreq_duo_to_avmmwr_fifo)
            avmm_first_write_reg <= 1'b0;
      end


generate if(EXTENDED_TAG_ENABLE == 0)
  begin
    always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_desc_id_reg <= 8'h0;
       else if(latch_header)
           case (cpl_tag[7:0])
             8'd0 :  cpl_desc_id_reg  <=  tag_desc_id_reg[0]  ;
             8'd1 :  cpl_desc_id_reg  <=  tag_desc_id_reg[1]  ;
             8'd2 :  cpl_desc_id_reg  <=  tag_desc_id_reg[2]  ;
             8'd3 :  cpl_desc_id_reg  <=  tag_desc_id_reg[3]  ;
             8'd4 :  cpl_desc_id_reg  <=  tag_desc_id_reg[4]  ;
             8'd5 :  cpl_desc_id_reg  <=  tag_desc_id_reg[5]  ;
             8'd6 :  cpl_desc_id_reg  <=  tag_desc_id_reg[6]  ;
             8'd7 :  cpl_desc_id_reg  <=  tag_desc_id_reg[7]  ;
             8'd8 :  cpl_desc_id_reg  <=  tag_desc_id_reg[8]  ;
             8'd9 :  cpl_desc_id_reg  <=  tag_desc_id_reg[9]  ;
             8'd10 : cpl_desc_id_reg  <= tag_desc_id_reg[10];
             8'd11 : cpl_desc_id_reg  <= tag_desc_id_reg[11];
             8'd12 : cpl_desc_id_reg  <= tag_desc_id_reg[12];
             8'd13 : cpl_desc_id_reg  <= tag_desc_id_reg[13];
             8'd14 : cpl_desc_id_reg  <= tag_desc_id_reg[14];
             8'd15 : cpl_desc_id_reg  <= tag_desc_id_reg[15];
             default : cpl_desc_id_reg <= 7'h0;
         endcase
      end
  end
else
  begin

    always_ff @ (posedge Clk_i)
     begin
        if(latch_header)
            cpl_desc_id_reg  <=  tag_desc_id_reg_2  ;
      end
  end
endgenerate

generate if(EXTENDED_TAG_ENABLE == 0)
   begin
       always_comb
         begin
          case (cpl_tag[7:0])
             8'd0 :  remain_dw  <=  tag_remain_dw_reg[0]  ;
             8'd1 :  remain_dw  <=  tag_remain_dw_reg[1]  ;
             8'd2 :  remain_dw  <=  tag_remain_dw_reg[2]  ;
             8'd3 :  remain_dw  <=  tag_remain_dw_reg[3]  ;
             8'd4 :  remain_dw  <=  tag_remain_dw_reg[4]  ;
             8'd5 :  remain_dw  <=  tag_remain_dw_reg[5]  ;
             8'd6 :  remain_dw  <=  tag_remain_dw_reg[6]  ;
             8'd7 :  remain_dw  <=  tag_remain_dw_reg[7]  ;
             8'd8 :  remain_dw  <=  tag_remain_dw_reg[8]  ;
             8'd9 :  remain_dw  <=  tag_remain_dw_reg[9]  ;
             8'd10 : remain_dw  <= tag_remain_dw_reg[10];
             8'd11 : remain_dw  <= tag_remain_dw_reg[11];
             8'd12 : remain_dw  <= tag_remain_dw_reg[12];
             8'd13 : remain_dw  <= tag_remain_dw_reg[13];
             8'd14 : remain_dw  <= tag_remain_dw_reg[14];
             8'd15 : remain_dw  <= tag_remain_dw_reg[15];
             default : remain_dw <= 10'h0;
           endcase
         end
   end
 else
   begin
          assign  remain_dw  =  tag_remain_dw_reg_2;
   end
endgenerate


    // Decode function number
generate if(EXTENDED_TAG_ENABLE == 0)
   begin
      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_func_reg <= 8'h0;
       else if(latch_header)
           case (cpl_tag[7:0])
             8'h0 : cpl_func_reg <= tag_func_reg[0];
             8'h1 : cpl_func_reg <= tag_func_reg[1];
             8'h2 : cpl_func_reg <= tag_func_reg[2];
             8'h3 : cpl_func_reg <= tag_func_reg[3];
             8'h4 : cpl_func_reg <= tag_func_reg[4];
             8'h5 : cpl_func_reg <= tag_func_reg[5];
             8'h6 : cpl_func_reg <= tag_func_reg[6];
             8'h7 : cpl_func_reg <= tag_func_reg[7];
             8'h8 : cpl_func_reg <= tag_func_reg[8];
             8'h9 : cpl_func_reg <= tag_func_reg[9];
             8'hA : cpl_func_reg <= tag_func_reg[10];
             8'hB : cpl_func_reg <= tag_func_reg[11];
             8'hC : cpl_func_reg <= tag_func_reg[12];
             8'hD : cpl_func_reg <= tag_func_reg[13];
             8'hE : cpl_func_reg <= tag_func_reg[14];
             8'hF : cpl_func_reg <= tag_func_reg[15];
             default : cpl_func_reg <= 8'h0;
         endcase
      end
   end
else
   begin
    always_ff @ (posedge Clk_i)
         cpl_func_reg <= tag_func_reg_2;
   end
endgenerate

generate if(EXTENDED_TAG_ENABLE)
  begin
          always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_lbe_reg_2 <= 32'hFFFF_FFFF;
       else if(latch_header)
           avmm_lbe_reg_2 <=adjusted_avmm_lbe_2;
      end
  end
else
  begin
     always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_lbe_reg <= 32'hFFFF_FFFF;
       else if(latch_header)
           avmm_lbe_reg <=adjusted_avmm_lbe;
      end
  end
endgenerate


/// Muxing the data based on CPL address bit 2  and AVMM FBE

// calculate the first valid address based on FBE

generate if(EXTENDED_TAG_ENABLE == 1 && DMA_WIDTH == 256)
  begin
         always_comb
           begin
             casez (tag_first_enable_reg_2[31:0])
               32'h????_??F0 :first_valid_addr_2[7:0] <= 8'h04;
               32'h????_?F00 :first_valid_addr_2[7:0] <= 8'h08;
               32'h????_F000 :first_valid_addr_2[7:0] <= 8'h0C;
               32'h???F_0000 :first_valid_addr_2[7:0] <= 8'h10;
               32'h??F0_0000 :first_valid_addr_2[7:0] <= 8'h14;
               32'h?F00_0000 :first_valid_addr_2[7:0] <= 8'h18;
               32'hF000_0000 :first_valid_addr_2[7:0] <= 8'h1C;
               32'hFFFF_FFFF: first_valid_addr_2[7:0] <= 8'h00;
               default:  first_valid_addr_2[7:0] <= 8'h00;
             endcase
           end
  end
endgenerate  
  
  
generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 256)
  begin
           always_comb
            begin
              casez (tag_first_enable_reg[31:0])
                32'h????_??F0 :first_valid_addr[7:0] <= 8'h04;
                32'h????_?F00 :first_valid_addr[7:0] <= 8'h08;
                32'h????_F000 :first_valid_addr[7:0] <= 8'h0C;
                32'h???F_0000 :first_valid_addr[7:0] <= 8'h10;
                32'h??F0_0000 :first_valid_addr[7:0] <= 8'h14;
                32'h?F00_0000 :first_valid_addr[7:0] <= 8'h18;
                32'hF000_0000 :first_valid_addr[7:0] <= 8'h1C;
                32'hFFFF_FFFF: first_valid_addr[7:0] <= 8'h00;
                default:  first_valid_addr[7:0] <= 8'h00;
              endcase
            end
  end
endgenerate


generate if(EXTENDED_TAG_ENABLE == 0 && DMA_WIDTH == 128)
  begin
            always_comb
             begin
               casez (tag_first_enable_reg[15:0])
                 16'h??F0 :first_valid_addr[7:0] <= 8'h04;
                 16'h?F00 :first_valid_addr[7:0] <= 8'h08;
                 16'hF000 :first_valid_addr[7:0] <= 8'h0C;
                 16'h0000 :first_valid_addr[7:0] <= 8'h10;
                 default:  first_valid_addr[7:0] <= 8'h00;
               endcase
             end
   end
endgenerate



 always_comb
    begin
     case(cpl_addr_bit2_reg)
      1'b1:
        begin
          case (first_valid_addr_sig[7:0])
            8'h04 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw2;
                avmm_write_data_dw1    = tlp_reg_dw3;
                avmm_write_data_dw2    = (DMA_WIDTH == 256)? tlp_reg_dw4 : tlp_fifo_dw0;
                avmm_write_data_dw3    = (DMA_WIDTH == 256)? tlp_reg_dw5 : tlp_fifo_dw1;
                avmm_write_data_dw4    = tlp_reg_dw6;
                avmm_write_data_dw5    = tlp_reg_dw7;
                avmm_write_data_dw6    = tlp_fifo_dw0;
                avmm_write_data_dw7    = tlp_fifo_dw1;
              end

            8'h08 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw1;
                avmm_write_data_dw1    = tlp_reg_dw2;
                avmm_write_data_dw2    = tlp_reg_dw3;
                avmm_write_data_dw3    = (DMA_WIDTH == 256)? tlp_reg_dw4 : tlp_fifo_dw0;
                avmm_write_data_dw4    = tlp_reg_dw5;
                avmm_write_data_dw5    = tlp_reg_dw6;
                avmm_write_data_dw6    = tlp_reg_dw7;
                avmm_write_data_dw7    = tlp_fifo_dw0;
              end

            8'h0C :
              begin
                avmm_write_data_dw0    = tlp_reg_dw0;
                avmm_write_data_dw1    = tlp_reg_dw1;
                avmm_write_data_dw2    = tlp_reg_dw2;
                avmm_write_data_dw3    = tlp_reg_dw3;
                avmm_write_data_dw4    = tlp_reg_dw4;
                avmm_write_data_dw5    = tlp_reg_dw5;
                avmm_write_data_dw6    = tlp_reg_dw6;
                avmm_write_data_dw7    = tlp_reg_dw7;
              end

            8'h10 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw7;
                avmm_write_data_dw1    = tlp_reg_dw0;
                avmm_write_data_dw2    = tlp_reg_dw1;
                avmm_write_data_dw3    = tlp_reg_dw2;
                avmm_write_data_dw4    = tlp_reg_dw3;
                avmm_write_data_dw5    = tlp_reg_dw4;
                avmm_write_data_dw6    = tlp_reg_dw5;
                avmm_write_data_dw7    = tlp_reg_dw6;
              end

            8'h14 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw6;
                avmm_write_data_dw1    = tlp_hold_reg_dw7;
                avmm_write_data_dw2    = tlp_reg_dw0;
                avmm_write_data_dw3    = tlp_reg_dw1;
                avmm_write_data_dw4    = tlp_reg_dw2;
                avmm_write_data_dw5    = tlp_reg_dw3;
                avmm_write_data_dw6    = tlp_reg_dw4;
                avmm_write_data_dw7    = tlp_reg_dw5;
              end

            8'h18 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw5;
                avmm_write_data_dw1    = tlp_hold_reg_dw6;
                avmm_write_data_dw2    = tlp_hold_reg_dw7;
                avmm_write_data_dw3    = tlp_reg_dw0;
                avmm_write_data_dw4    = tlp_reg_dw1;
                avmm_write_data_dw5    = tlp_reg_dw2;
                avmm_write_data_dw6    = tlp_reg_dw3;
                avmm_write_data_dw7    = tlp_reg_dw4;
              end

            8'h1C :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw4;
                avmm_write_data_dw1    = tlp_hold_reg_dw5;
                avmm_write_data_dw2    = tlp_hold_reg_dw6;
                avmm_write_data_dw3    = tlp_hold_reg_dw7;
                avmm_write_data_dw4    = tlp_reg_dw0;
                avmm_write_data_dw5    = tlp_reg_dw1;
                avmm_write_data_dw6    = tlp_reg_dw2;
                avmm_write_data_dw7    = tlp_reg_dw3;
              end

            default :  // 8'h0
              begin
                avmm_write_data_dw0    = (DMA_WIDTH == 256)? tlp_reg_dw3 : tlp_hold_reg_dw3;
                avmm_write_data_dw1    = tlp_reg_dw4;
                avmm_write_data_dw2    = tlp_reg_dw5;
                avmm_write_data_dw3    = tlp_reg_dw6;
                avmm_write_data_dw4    = tlp_reg_dw7;
                avmm_write_data_dw5    = tlp_fifo_dw0;
                avmm_write_data_dw6    = tlp_fifo_dw1;
                avmm_write_data_dw7    = tlp_fifo_dw2;
              end
          endcase
        end

     1'b0:
        begin
          case (first_valid_addr_sig[7:0])
            8'h04 :
              begin
                avmm_write_data_dw0    = (DMA_WIDTH == 256)? tlp_reg_dw3 : tlp_hold_reg_dw3;
                avmm_write_data_dw1    = tlp_reg_dw4;
                avmm_write_data_dw2    = tlp_reg_dw5;
                avmm_write_data_dw3    = tlp_reg_dw6;
                avmm_write_data_dw4    = tlp_reg_dw7;
                avmm_write_data_dw5    = tlp_fifo_dw0;
                avmm_write_data_dw6    = tlp_fifo_dw1;
                avmm_write_data_dw7    = tlp_fifo_dw2;
              end

            8'h08 :
              begin
                avmm_write_data_dw0    = (DMA_WIDTH == 256)? tlp_reg_dw2 : tlp_hold_reg_dw2;
                avmm_write_data_dw1    = (DMA_WIDTH == 256)? tlp_reg_dw3 : tlp_hold_reg_dw3;
                avmm_write_data_dw2    = tlp_reg_dw4;
                avmm_write_data_dw3    = tlp_reg_dw5;
                avmm_write_data_dw4    = tlp_reg_dw6;
                avmm_write_data_dw5    = tlp_reg_dw7;
                avmm_write_data_dw6    = tlp_fifo_dw0;
                avmm_write_data_dw7    = tlp_fifo_dw1;
              end

            8'h0C :
              begin
                avmm_write_data_dw0    = (DMA_WIDTH == 256)? tlp_reg_dw1 : tlp_hold_reg_dw1;
                avmm_write_data_dw1    = (DMA_WIDTH == 256)? tlp_reg_dw2 : tlp_hold_reg_dw2;
                avmm_write_data_dw2    = (DMA_WIDTH == 256)? tlp_reg_dw3 : tlp_hold_reg_dw3;
                avmm_write_data_dw3    = tlp_reg_dw4;
                avmm_write_data_dw4    = tlp_reg_dw5;
                avmm_write_data_dw5    = tlp_reg_dw6;
                avmm_write_data_dw6    = tlp_reg_dw7;
                avmm_write_data_dw7    = tlp_fifo_dw0;
              end

            8'h10 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw0;
                avmm_write_data_dw1    = tlp_reg_dw1;
                avmm_write_data_dw2    = tlp_reg_dw2;
                avmm_write_data_dw3    = tlp_reg_dw3;
                avmm_write_data_dw4    = tlp_reg_dw4;
                avmm_write_data_dw5    = tlp_reg_dw5;
                avmm_write_data_dw6    = tlp_reg_dw6;
                avmm_write_data_dw7    = tlp_reg_dw7;
              end

            8'h14 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw7;
                avmm_write_data_dw1    = tlp_reg_dw0;
                avmm_write_data_dw2    = tlp_reg_dw1;
                avmm_write_data_dw3    = tlp_reg_dw2;
                avmm_write_data_dw4    = tlp_reg_dw3;
                avmm_write_data_dw5    = tlp_reg_dw4;
                avmm_write_data_dw6    = tlp_reg_dw5;
                avmm_write_data_dw7    = tlp_reg_dw6;
              end

            8'h18 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw6;
                avmm_write_data_dw1    = tlp_hold_reg_dw7;
                avmm_write_data_dw2    = tlp_reg_dw0;
                avmm_write_data_dw3    = tlp_reg_dw1;
                avmm_write_data_dw4    = tlp_reg_dw2;
                avmm_write_data_dw5    = tlp_reg_dw3;
                avmm_write_data_dw6    = tlp_reg_dw4;
                avmm_write_data_dw7    = tlp_reg_dw5;
              end

            8'h1C :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw5;
                avmm_write_data_dw1    = tlp_hold_reg_dw6;
                avmm_write_data_dw2    = tlp_hold_reg_dw7;
                avmm_write_data_dw3    = tlp_reg_dw0;
                avmm_write_data_dw4    = tlp_reg_dw1;
                avmm_write_data_dw5    = tlp_reg_dw2;
                avmm_write_data_dw6    = tlp_reg_dw3;
                avmm_write_data_dw7    = tlp_reg_dw4;
              end

            default :  // 8'h0
              begin
                avmm_write_data_dw0    = tlp_reg_dw4;
                avmm_write_data_dw1    = tlp_reg_dw5;
                avmm_write_data_dw2    = tlp_reg_dw6;
                avmm_write_data_dw3    = tlp_reg_dw7;
                avmm_write_data_dw4    = tlp_fifo_dw0;
                avmm_write_data_dw5    = tlp_fifo_dw1;
                avmm_write_data_dw6    = tlp_fifo_dw2;
                avmm_write_data_dw7    = tlp_fifo_dw3;
              end
          endcase
        end
       default:
         begin
                avmm_write_data_dw0    = 32'h0;
                avmm_write_data_dw1    = 32'h0;
                avmm_write_data_dw2    = 32'h0;
                avmm_write_data_dw3    = 32'h0;
                avmm_write_data_dw4    = 32'h0;
                avmm_write_data_dw5    = 32'h0;
                avmm_write_data_dw6    = 32'h0;
                avmm_write_data_dw7    = 32'h0;
         end
    endcase
    end


/// Tx Fifo Interface for sending read TLP
assign is_rd32 = (cur_src_addr_reg[63:32] == 32'h0);
assign cmd = is_rd32? 8'h00 : 8'h20;

// SR-IOV Generate requestor ID
assign requestor_id =  {BusDev_i[12:0],3'b000};

assign tlp_dw2     = is_rd32?  cur_src_addr_reg[31:0] : cur_src_addr_reg[63:32];
assign tlp_dw3     = cur_src_addr_reg[31:0];

assign upper_nibble_rd_be = (rd_dw_size[9:0] > 10'h1)? 4'hF : 4'h0;
assign req_header1 = {requestor_id[15:0], rd_tag_reg[7:0], upper_nibble_rd_be, 4'hF, cmd[7:0], 8'h0, 6'h0, rd_dw_size[9:0]};
assign req_header2 = { tlp_dw3, tlp_dw2 };
assign tx_tlp_empty = (DMA_WIDTH == 256) ? 2'b10 : 2'b00;
assign TxFifoData_o = (DMA_WIDTH == 256) ? {tx_tlp_empty, 1'b1,1'b1,128'h0,req_header2, req_header1} : {tx_tlp_empty, 1'b1,1'b1,req_header2, req_header1};
assign TxFifoWrReq_o = rd_header_state;


/// Update to the Desc controller
//assign reported_desc_id = tag_release? cpl_desc_id_reg : cur_desc_id_reg;
// assign desc_completed   = (tag_release_queuing & last_desc_cpl_reg & last_cpl_reg);

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           rd_tx_valid_reg <= 1'b0;
           rd_tx_data_reg  <= 32'h0;
         end
       else
         begin
            rd_tx_valid_reg <= desc_completed | desc_flushed | desc_aborted |  desc_paused | desc_error;
            rd_tx_data_reg  <= {cpl_func_reg[7:0], 5'h0, 1'b0, 5'h0, 1'b0, 1'b0, 1'b0, 1'b0, desc_completed,cpl_desc_id_reg[7:0]};
         end
     end

assign desc_flushed     = ~flush_all_desc_reg &  flush_all_desc;
assign desc_aborted     = ~cur_dma_abort_reg  & cur_dma_abort;
assign desc_paused      =  ~cur_dma_pause_reg  & cur_dma_pause;
assign flush_count      = desc_flushed? (desc_fifo_count + 1'b1) : 5'h0;
assign RdDmaStatus      = !(desc_error  | desc_flushed | desc_aborted | desc_paused) & desc_completed;

assign RdDMAStatus_o[7:0]  = cur_desc_id_reg;
assign RdDMAStatus_o[31:8] = 24'h0;

// Rx FIFO interface
assign RxFifoRdReq_o = (rdcpl_idle_state &  (is_cpl_wd & rx_sop & cpl_tag <= NUM_TAG-1 & ~rx_fifo_empty) & ~latch_header_reg2) |
                       (rdcpl_wait_state & (cpl_addr_bit2_reg ? ((first_valid_addr == 8'h00) & (rx_dwlen_reg!=1)): 1'b1) & ~rx_fifo_empty) |
                       (rdcpl_write_state & ~( (avmm_burst_cntr_sig == 2 & rx_sop) | (((DMA_WIDTH == 256) ? (avmm_burst_cnt_reg_sig == 1) : 1'b0) & rx_sop)) & ~waitreq_duo_to_avmmwr_fifo & ~rx_fifo_empty & ~(rx_sop & ~(valid_cpl_available & ~latch_header_reg2)));  /// do not read if avmm is behind and there is a valid sop at the fifo OR burst count is 1

assign RdDmaRxReady_o = desc_fifo_count < 4'h3;

/// Sub descriptors:


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           sub_desc_src_addr_reg <= 64'h0;
           sub_desc_dest_addr_reg <= 64'h0;
         end
       else if(rd_pop_desc_state)
         begin
           sub_desc_src_addr_reg <= desc_head[63:0];
           sub_desc_dest_addr_reg <= desc_head[127:64];
         end
       else if(sub_desc_load)
         begin
           sub_desc_src_addr_reg <= next_sub_src_addr[63:0] ;
           sub_desc_dest_addr_reg <= next_sub_dest_addr[63:0];
         end
     end


      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           sub_desc_length_reg <= 18'h0;
         end
       else if(rd_pipe_state)
         begin
           sub_desc_length_reg <= (orig_desc_dw_reg <= dw_to_4KB)? orig_desc_dw_reg : dw_to_4KB;
         end
       else if(sub_desc_load_reg)
         begin
           sub_desc_length_reg <= (main_desc_remain_length_reg <= dw_to_legal_bound)? main_desc_remain_length_reg : dw_to_legal_bound;
         end
     end


   assign bytes_to_4K  = (sub_desc_src_addr_reg[11:0] == 12'h0)? 13'h1000 : 13'h1000 - sub_desc_src_addr_reg[11:0];

   assign dw_to_4K =  bytes_to_4K[12:2];

   assign dw_to_legal_bound = dw_to_4K;

   assign next_sub_src_addr[63:0] = sub_desc_src_addr_reg[63:0] + bytes_to_4K[12:0];
   assign next_sub_dest_addr[63:0] = sub_desc_dest_addr_reg + bytes_to_4K[12:0];

   /// main descriptor outstanding logic, remaining after sub-descriptor is loaded

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           rd_pipe_state_reg <= 1'b0;
         end
       else
         begin
           rd_pipe_state_reg <= rd_pipe_state;
         end
     end


   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           main_desc_remain_length_reg <= 18'h0;
         end
       else if(rd_pipe_state_reg) // delay one clock
         begin
           main_desc_remain_length_reg <= orig_desc_dw_reg;
         end
       else if(sub_desc_load)
         begin
           main_desc_remain_length_reg <= main_desc_remain_length_reg - sub_desc_length_reg;
         end
     end

   assign last_sub_desc = (main_desc_remain_length_reg <= dw_to_legal_bound);

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           last_sub_desc_reg <= 1'b0;
       else
           last_sub_desc_reg <= last_sub_desc;
     end

// predecode tag interface

assign PreDecodeTagRdReq_o = latch_header;

/// for monotoring purpose

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           culmutive_sent_dw <= 18'h0;
       else if(rd_pop_desc_state)
          culmutive_sent_dw <= 18'h0;
       else if(rd_header_state)
          culmutive_sent_dw <=  culmutive_sent_dw + rd_dw_size;
     end

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           culmutive_remain_dw <= 18'h0;
       else if(rd_pop_desc_state)
          culmutive_remain_dw <= desc_head[145:128];
       else if(rd_header_state)
          culmutive_remain_dw <=  culmutive_remain_dw - rd_dw_size;
     end


//// Logic to keep track of out order completion status report back to the controller

/// Up down counter to count outstanding reads for each descriptor ID
/// 16 is implemented with the Descriptor ID assigned to each


/// recycle 16 counters queue

/// init counter
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           counter_id <= 6'h0;
         else if(counter_id < 6'b100000 )
           counter_id <= counter_id + 1'b1;
     end

 altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(4)
    )
 desc_outstanding_reads_queue
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(desc_outstanding_reads_queue_wrreq),
      .rdreq(desc_outstanding_reads_queue_rdreq),
      .data(desc_outstanding_reads_queue_wrdat),
      .q(desc_outstanding_reads_queue_num),
      .fifo_count(desc_outstanding_fifo_count)
);

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           desc_outstanding_reads_queue_wrdat[3:0] <= 4'h0;
           desc_outstanding_reads_queue_wrreq <= 1'b0;
         end
         else
           begin
              desc_outstanding_reads_queue_wrdat[3:0] <= (counter_id[5:4] == 2'b01)? counter_id[3:0] : released_counter[3:0];
              desc_outstanding_reads_queue_wrreq <= (counter_id[5:4] == 2'b01 | (|desc_completed_reg[15:0] & rx_eop_reg));
           end
     end

assign desc_outstanding_reads_queue_fifo_ok = desc_outstanding_fifo_count != 0;
assign desc_outstanding_reads_queue_rdreq = rd_pop_desc_state & ~small_desc_size;
assign func_head[7:0] =  8'h0;

 generate
  genvar k;
  for(k=0; k< 16; k=k+1)
    begin: desc_outstanding_read_count

       assign rx_match_desc_id[k] = descriptor_outstanding_read_id[k] ==  {1'b0,cpl_func_reg, cpl_desc_id_reg};
       assign up_count_en[k]   = rd_header_state & current_cntr_reg == k;
       assign down_count_en[k] = latch_header_reg & last_cpl_reg & rx_match_desc_id[k] & descriptor_outstanding_read_pending[k];

       always_ff @ (posedge Clk_i)
           begin
             if(rd_pop_desc_state & ~small_desc_size & current_cntr == k) // load
               begin
                descriptor_outstanding_read_cntr[k] <=  8'h0;                       /// [pending, desc_id, count_value]
               end
             else if(up_count_en[k] & ~down_count_en[k])
               begin
                descriptor_outstanding_read_cntr[k] <=  descriptor_outstanding_read_cntr[k] + 1'b1;
               end
             else if(down_count_en[k] & ~up_count_en[k])
               begin
                 descriptor_outstanding_read_cntr[k] <=  descriptor_outstanding_read_cntr[k] - 1'b1;
               end
           end



        always_ff @ (posedge Clk_i or negedge Rstn_i)   // descriptor ID of the counter k
                   begin
                     if(~Rstn_i)
                      descriptor_outstanding_read_id[k]   <= 17'h100;
                     else if(rd_pop_desc_state & ~small_desc_size & current_cntr[3:0] == k) // load
                        descriptor_outstanding_read_id[k]   <= {1'b0, func_head[7:0], desc_head[153:146]};
                   end

        always_ff @ (posedge Clk_i or negedge Rstn_i)   // conter k pending status
                   begin
                     if(~Rstn_i)
                        descriptor_outstanding_read_pending[k]   <= 1'b0;
                     else if(rd_pop_desc_state & ~small_desc_size & current_cntr[3:0] == k) // load
                        descriptor_outstanding_read_pending[k]   <= 1'b1;
                     else if(desc_completed_reg[k] )
                        descriptor_outstanding_read_pending[k]   <= 1'b0;
                   end

       assign desc_rd_tlp_stil_in_progress[k] = (descriptor_outstanding_read_pending[k] & ~rd_idle_state & current_cntr_reg == k & rx_match_desc_id[k]);

        always_ff @ (posedge Clk_i or negedge Rstn_i)   // descriptor ID of the counter k
         begin
          if(~Rstn_i)
             desc_completed_reg[k] <= 1'b0;
          else if (latch_header_reg)
            desc_completed_reg[k]   <= (descriptor_outstanding_read_cntr[k] == 8'h1 & descriptor_outstanding_read_pending[k] & rx_match_desc_id[k] & latch_header_reg & last_cpl_reg) & ~desc_rd_tlp_stil_in_progress[k];
          else if(rx_eop_reg)
             desc_completed_reg[k]  <= 1'b0;
          end

    end
 endgenerate

 always_ff @ (posedge Clk_i or negedge Rstn_i)   // small descriptor <= Max Read Size
         begin
          if(~Rstn_i)
             desc_completed_reg[16] <= 1'b0;
          else if (latch_header_reg)
            desc_completed_reg[16]   <= rx_match_desc_id == 16'h0 & latch_header_reg & last_cpl_reg; // not match descriptor ID
          else if(rx_eop_reg)
            desc_completed_reg[16]  <= 1'b0;
          end

 assign current_cntr = desc_outstanding_reads_queue_num;
 always_ff @ (posedge Clk_i)
   begin
    if(rd_pop_desc_state & ~small_desc_size)
       current_cntr_reg <= current_cntr;  // the counter being used next is at the output of the FIFO
    else if(rd_pop_desc_state & small_desc_size)
        current_cntr_reg <= 5'h10;
  end

 assign desc_completed = |desc_completed_reg & rx_eop_reg;

 always_comb
  begin
    case(desc_completed_reg[15:0])
       16'b0000_0000_0000_0001 : released_counter[3:0] = 4'h0;
       16'b0000_0000_0000_0010 : released_counter[3:0] = 4'h1;
       16'b0000_0000_0000_0100 : released_counter[3:0] = 4'h2;
       16'b0000_0000_0000_1000 : released_counter[3:0] = 4'h3;
       16'b0000_0000_0001_0000 : released_counter[3:0] = 4'h4;
       16'b0000_0000_0010_0000 : released_counter[3:0] = 4'h5;
       16'b0000_0000_0100_0000 : released_counter[3:0] = 4'h6;
       16'b0000_0000_1000_0000 : released_counter[3:0] = 4'h7;
       16'b0000_0001_0000_0000 : released_counter[3:0] = 4'h8;
       16'b0000_0010_0000_0000 : released_counter[3:0] = 4'h9;
       16'b0000_0100_0000_0000 : released_counter[3:0] = 4'hA;
       16'b0000_1000_0000_0000 : released_counter[3:0] = 4'hB;
       16'b0001_0000_0000_0000 : released_counter[3:0] = 4'hC;
       16'b0010_0000_0000_0000 : released_counter[3:0] = 4'hD;
       16'b0100_0000_0000_0000 : released_counter[3:0] = 4'hE;
       16'b1000_0000_0000_0000 : released_counter[3:0] = 4'hF;
       default: released_counter[3:0] = 4'h0;
    endcase
  end

/// FIFO to buffer Write Data to cut the Wait Request timming path from fabric.

 always_ff @ (posedge Clk_i)
   begin
     avmmwr_data_reg     <= {avmm_write_data_dw7, avmm_write_data_dw6, avmm_write_data_dw5, avmm_write_data_dw4, avmm_write_data_dw3, avmm_write_data_dw2, avmm_write_data_dw1, avmm_write_data_dw0};
     avmmwr_byteen_reg   <=  avmm_first_write_reg? avmm_fbe_reg_sig : (avmm_burst_cntr_sig == 1 )? avmm_lbe_reg_sig : 32'hFFFF_FFFF;
     avmmwr_burstcnt_reg <=  avmm_burst_cnt_reg_sig;
     avmm_address_reg2  <= (DMA_WIDTH == 256) ? {{(64-RDDMA_AVL_ADDR_WIDTH){1'b0}}, avmm_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:5], 5'b00000} :
                                                 {{(64-RDDMA_AVL_ADDR_WIDTH){1'b0}}, avmm_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:4], 4'b0000};



   end

assign avmmwr_fifo_data = {avmmwr_byteen_reg, avmmwr_data_reg};

generate begin : g_avmmwr_data_fifo
   if (dma_use_scfifo_ext==1) begin
      altpcie_a10_scfifo_ext       # (
         .add_ram_output_register    ("ON"                       ),
         .intended_device_family     ("Stratix V"                ),
         .lpm_numwords               (512                        ),
         .lpm_showahead              ("OFF"                      ),
         .lpm_type                   ("scfifo"                   ),
         .lpm_width                  ((DMA_WIDTH+(DMA_WIDTH/8))  ),
         .lpm_widthu                 (9                          ),
         .overflow_checking          ("ON"                       ),
         .underflow_checking         ("ON"                       ),
         .use_eab                    ("ON"                       )
      ) avmmwr_data_fifo             (
         .rdreq                      (avmmwr_data_fifo_rdreq),
         .clock                      (Clk_i),
         .wrreq                      (rdcpl_write_state_reg),
         .data                       (avmmwr_fifo_data),
         .usedw                      (avmmwr_fifo_usedw),
         .empty                      (avmmwr_data_fifo_empty),
         .q                          (avmmwr_write_data),
         .full                       (),
         .aclr                       (~Rstn_i),
         .almost_empty               (),
         .almost_full                (),
         .sclr                       (1'b0)
      );
   end
   else if (dma_use_scfifo_ext==2) begin
      altpcie_sv_scfifo_ext        # (
         .add_ram_output_register    ("ON"                       ),
         .intended_device_family     ("Stratix V"                ),
         .lpm_numwords               (512                        ),
         .lpm_showahead              ("OFF"                      ),
         .lpm_type                   ("scfifo"                   ),
         .lpm_width                  ((DMA_WIDTH+(DMA_WIDTH/8))  ),
         .lpm_widthu                 (9                          ),
         .overflow_checking          ("ON"                       ),
         .underflow_checking         ("ON"                       ),
         .use_eab                    ("ON"                       )
      ) avmmwr_data_fifo             (
         .rdreq                      (avmmwr_data_fifo_rdreq),
         .clock                      (Clk_i),
         .wrreq                      (rdcpl_write_state_reg),
         .data                       (avmmwr_fifo_data),
         .usedw                      (avmmwr_fifo_usedw),
         .empty                      (avmmwr_data_fifo_empty),
         .q                          (avmmwr_write_data),
         .full                       (),
         .aclr                       (~Rstn_i),
         .almost_empty               (),
         .almost_full                (),
         .sclr                       (1'b0)
      );
   end
   else begin
      scfifo                       # (
         .add_ram_output_register    ("ON"                       ),
         .intended_device_family     ("Stratix V"                ),
         .lpm_numwords               (512                        ),
         .lpm_showahead              ("OFF"                      ),
         .lpm_type                   ("scfifo"                   ),
         .lpm_width                  ((DMA_WIDTH+(DMA_WIDTH/8))  ),
         .lpm_widthu                 (9                          ),
         .overflow_checking          ("ON"                       ),
         .underflow_checking         ("ON"                       ),
         .use_eab                    ("ON"                       )
      ) avmmwr_data_fifo             (
         .rdreq                      (avmmwr_data_fifo_rdreq),
         .clock                      (Clk_i),
         .wrreq                      (rdcpl_write_state_reg),
         .data                       (avmmwr_fifo_data),
         .usedw                      (avmmwr_fifo_usedw),
         .empty                      (avmmwr_data_fifo_empty),
         .q                          (avmmwr_write_data),
         .full                       (),
         .aclr                       (~Rstn_i),
         .almost_empty               (),
         .almost_full                (),
         .sclr                       (1'b0)
      );
   end
end
endgenerate

always_ff @ (posedge Clk_i)
    avmmwr_data_fifo_ok_reg <=  avmmwr_fifo_usedw < 496;



/// Command  fifo to hold the address and burst count

assign avmmwr_cmd = {1'b0,{(6-DMA_BRST_CNT_W){1'b0}} , avmmwr_burstcnt_reg[DMA_BRST_CNT_W-1:0], {(64-RDDMA_AVL_ADDR_WIDTH){1'b0}} ,avmm_address_reg2[RDDMA_AVL_ADDR_WIDTH-1:0]};
altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(1+6+64)   /// address, burst count, write/read
    )
 rxm_cmd_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(latch_header_reg2),
      .rdreq(avmmwr_cmd_fifo_rdreq),
      .data(avmmwr_cmd),
      .q(avmmwr_cmd_q),
      .fifo_count(avmmwr_cmd_count)
);

always_ff @ (posedge Clk_i)
    avmmwr_cmd_fifo_ok_reg <=  avmmwr_cmd_count < 8;

assign waitreq_duo_to_avmmwr_fifo = ~avmmwr_fifo_ok;
/// AVMM WR interface state machine

// the rxm burst counter
assign avmmwr_burst_count = avmmwr_cmd_q[64+5:64];

    always_ff @ (posedge Clk_i)
     begin
       if(avmmwr_cmd_fifo_rdreq)
         avmmwr_burst_cntr <=  avmmwr_burst_count;
       else if(~RdDmaWaitRequest_i & avmmwr_write_state)
         avmmwr_burst_cntr <=  avmmwr_burst_cntr - 1'b1;
      end

// latch the address,
    always_ff @ (posedge Clk_i)
     begin
       if(avmmwr_cmd_fifo_rdreq)
         begin
             avmmwr_address_reg[63:0]     <=  avmmwr_cmd_q[63:0];
             avmmwr_burst_count_reg <=  avmmwr_cmd_q[64+5:64];
         end
      end

assign avmmwr_fifo_ok = avmmwr_data_fifo_ok_reg & avmmwr_cmd_fifo_ok_reg;

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmmwr_state <= AVMMWR_IDLE;
         else
           avmmwr_state <= avmmwr_nxt_state;
     end

always_comb
  begin
    case(avmmwr_state)
      AVMMWR_IDLE :
        if(avmmwr_cmd_count != 0  & ~avmmwr_data_fifo_empty)
          avmmwr_nxt_state <= AVMMWR_PIPE;
        else
           avmmwr_nxt_state <= AVMMWR_IDLE;

      AVMMWR_PIPE:
          avmmwr_nxt_state <= AVMMWR_WR;

      AVMMWR_WR:
        if(~RdDmaWaitRequest_i & avmmwr_burst_cntr == 1 & (avmmwr_cmd_count == 0 | avmmwr_data_fifo_empty))
          avmmwr_nxt_state <= AVMMWR_IDLE;
        else
          avmmwr_nxt_state <= AVMMWR_WR;

      default:
            avmmwr_nxt_state <= AVMMWR_IDLE;
    endcase
  end
 assign avmmwr_idle_state   = avmmwr_state == AVMMWR_IDLE;
 assign avmmwr_wrpipe_state = avmmwr_state == AVMMWR_PIPE;
 assign avmmwr_write_state  = avmmwr_state == AVMMWR_WR;
 assign avmmwr_data_fifo_rdreq  = (avmmwr_write_state & ~RdDmaWaitRequest_i & ~avmmwr_data_fifo_empty) | (avmmwr_wrpipe_state );
 assign end_avmm_cycle = avmmwr_write_state & ~RdDmaWaitRequest_i & avmmwr_burst_cntr == 1;


 assign avmmwr_cmd_fifo_rdreq = (avmmwr_idle_state & avmmwr_cmd_count != 0 & ~avmmwr_data_fifo_empty) |
                                ( avmmwr_write_state & ~RdDmaWaitRequest_i & avmmwr_burst_cntr == 1 & avmmwr_cmd_count != 0 & ~avmmwr_data_fifo_empty);


assign RdDmaWrite_o       = avmmwr_write_state;
assign RdDmaAddress_o     = avmmwr_address_reg[63:0];
assign RdDmaBurstCount_o  = avmmwr_burst_count_reg[DMA_BRST_CNT_W-1:0];
assign RdDmaWriteData_o   = avmmwr_write_data[DMA_WIDTH-1:0];
assign RdDmaWriteEnable_o  = avmmwr_write_data[(DMA_WIDTH+DMA_BE_WIDTH)-1:DMA_WIDTH];

/// To prevent premature completion status being reported, the status will be buffered in a FIFO
//  and only sent it back when the avmmwr_state is in idle state
altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(32)   /// address, burst count, write/read
    )
 rd_status_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(rd_tx_valid_reg),
      .rdreq(rd_status_fifo_rdreq),
      .data(rd_tx_data_reg),
      .q(RdDmaTxData_o),
      .fifo_count(rd_status_fifo_count)
);

// free running counter to periodically returns status
always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           status_frequency_cntr <= 1'b0;
       else
           status_frequency_cntr <= status_frequency_cntr + 1'b1;
      end
assign RdDmaTxValid_o = rd_status_fifo_rdreq;
assign rd_status_fifo_rdreq = end_avmm_cycle  & rd_status_fifo_count!=0 ;


/// Checking the RX CPL space

always_ff @ (posedge Clk_i)
     begin
            cpl_header_reg <= adjusted_cpl_spc_header;
            cpl_data_reg   <= ko_cpl_spc_data;
     end

/// header credit counter

always_ff @ (posedge Clk_i)
     begin
       if(tag_counter == 63)
           cpl_header_cnt <= cpl_header_reg;
       else if(rd_header_state & ~tag_release_queuing)
           cpl_header_cnt <= cpl_header_cnt - 1'b1;
       else if(~rd_header_state & tag_release_queuing)
           cpl_header_cnt <= cpl_header_cnt + 1'b1;
      end

always_ff @ (posedge Clk_i)
     begin
       if(tag_counter == 63)
           cpl_data_cnt <= cpl_data_reg;
       else if(rd_header_state & ~tag_release_queuing)
           cpl_data_cnt <= cpl_data_cnt - max_rd_dw[7:2];
       else if(~rd_header_state & tag_release_queuing)
           cpl_data_cnt <= cpl_data_cnt + max_rd_dw[7:2];
      end

always_ff @ (posedge Clk_i)
begin
 cpl_header_available <= (cpl_header_cnt > 2);
 cpl_data_available   <= (cpl_data_cnt > 64);
end



endmodule



