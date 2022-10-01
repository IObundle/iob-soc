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


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altpcieav_dma_hprxm_rdwr # (

      parameter AVMM_WIDTH                      = 128,
      parameter HPRXM_BAR_TYPE                  = 64,
      parameter DMA_BRST_CNT_W                   = 6,
      parameter BAR2_SIZE_MASK                   = 20

   )
   
   
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,
      
            // Avalon HP Rx Master interface
      output logic                                 HPRxmWrite_o,
      output logic [HPRXM_BAR_TYPE-1:0]            HPRxmAddress_o,
      output logic [AVMM_WIDTH-1:0]                HPRxmWriteData_o,
      output logic [(AVMM_WIDTH/8)-1:0]            HPRxmByteEnable_o,
      output logic [DMA_BRST_CNT_W-1:0]            HPRxmBurstCount_o,
      input  logic                                 HPRxmWaitRequest_i,
      output logic                                 HPRxmRead_o,
      
     // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [265:0]                         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,
      
      /// Pending Read FIFO Interface
      output logic  [56:0]                         PndgRdHeader_o,   
      output logic                                 PndgRdFifoWrReq_o,
      input  logic  [3:0]                          PndgRdFifoCount_i,
      
      /// Read burst count fifo interface
      
      input  logic                                 ReadBcntFifoRdreq_i,
      output logic  [7:0]                          ReadBcntFifoq_o,
      
      input  logic                                 LastTxCplSent_i
      
   );
   
  localparam  HPRXM_IDLE                = 5'h0;
  localparam  HPRXM_WR_PIPE             = 5'h1;
  localparam  HPRXM_RD_PIPE             = 5'h2;
  localparam  HPRXM_WRITE               = 5'h3;
  localparam  HPRXM_READ                = 5'h4;   
  localparam  HPRXM_RD_SPLIT_REQUEST    = 5'h5;      
  
  localparam  RXM_AVMM_IDLE             = 2'h0;  
  localparam  RXM_AVMM_WR_PIPE          = 2'h1;
  localparam  RXM_AVMM_WR               = 2'h2;
  localparam  RXM_AVMM_RD               = 2'h3;
  
  
  localparam  RXM_RDSPLIT_IDLE          = 3'h0;
  localparam  RXM_RDSPLIT_PIPE          = 3'h1;
  localparam  RXM_RDSPLIT_SEND_FIRST    = 3'h2;
  localparam  RXM_RDSPLIT_SEND_MAX      = 3'h3;
  localparam  RXM_RDSPLIT_SEND_LAST     = 3'h4;
  localparam  RXM_RDSPLIT_WAIT_COUNT    = 3'h5;
  
  localparam  MAX_BCNT = (AVMM_WIDTH==128)? 32 : 16;
  
      
      
   logic                                  rx_sop;         
   logic    [9:0]                         rx_tlp_dwlen;   
   logic                                  is_rd;          
   logic                                  tlp_4dw_header; 
   logic    [63:0]                        rx_tlp_addr;    
   logic                                  tlp_addr_bit2;  
   logic                                  is_wr;          
        
   logic                                  rd_tlp_available;   
   logic                                  rxm_fifo_ok;        
   logic                                  wr_tlp_available;    
   logic                                  tlp_available; 
   logic                                  rx_fifo_empty;       
   logic                                  rxm_data_fifo_ok_reg;
   logic                                  rxm_cmd_fifo_ok_reg; 
   logic                                  hprxm_idle_state;   
   logic                                  hprxm_pipe_state;                                 
   logic                                  hprxm_write_state;  
   logic                                  hprxm_rd_pipe_state;
   logic                                  hprxm_rd_state;
   logic                                  hprxm_wr_pipe_state;  
   logic                                  hprxm_rd_pipe_state_reg;
   logic                                  hprxm_wr_pipe_state_reg;  
   logic                                  hprxm_rd_split_state;
         
   logic    [4:0]                         hprxm_state; 
   logic    [4:0]                         hprxm_nxt_state;  
   logic    [7:0]                         avmm_burst_cntr;
   logic    [7:0]                         avmm_burst_cnt_reg;
   logic                                  latch_header;
   logic                                  latch_header_from_idle_state;   
   logic                                  latch_header_from_write_state;  
   logic    [HPRXM_BAR_TYPE-1:0]          rx_addr_reg;  
   logic                                  addr_bit2_reg;            
   logic                                  tlp_4dw_header_reg;      
   logic                                  is_wr_reg;               
   logic   [265:0]                        tlp_reg;
   logic   [265:0]                        tlp_fifo;      
   logic   [265:0]                        tlp_hold_reg;   
   logic   [(AVMM_WIDTH/8)-1:0]           avmm_fbe; 
   logic   [9:0]                          first_dw_holes;             
   logic   [(AVMM_WIDTH/8)-1:0]           avmm_fbe_reg;
   logic   [9:0]                          adjusted_dw_count_reg;                       
   logic   [7 :0]                         avmm_burst_cnt;   
   logic   [(AVMM_WIDTH/8)-1:0]           adjusted_avmm_fbe_reg;
   logic   [(AVMM_WIDTH/8)-1:0]           avmm_first_byten_reg;
   logic   [(AVMM_WIDTH/8)-1:0]           avmm_last_byten_reg;
   logic   [(AVMM_WIDTH/8)-1:0]           adjusted_avmm_lbe;               
   logic   [(AVMM_WIDTH/8)-1:0]           rxm_byte_enable_reg;
   logic                                  hprxm_pipe_state_reg;
   logic                                  rx_eop;   
   logic                                  rx_eop_reg; 
   logic   [31:0]                         tlp_reg_dw0;
   logic   [31:0]                         tlp_reg_dw1;
   logic   [31:0]                         tlp_reg_dw2;
   logic   [31:0]                         tlp_reg_dw3;
   logic   [31:0]                         tlp_reg_dw4;
   logic   [31:0]                         tlp_reg_dw5;
   logic   [31:0]                         tlp_reg_dw6;
   logic   [31:0]                         tlp_reg_dw7;  
   logic   [31:0]                         tlp_hold_reg_dw4;  
   logic   [31:0]                         tlp_hold_reg_dw5;
   logic   [31:0]                         tlp_hold_reg_dw6;
   logic   [31:0]                         tlp_hold_reg_dw7;
   logic   [31:0]                         tlp_fifo_dw0;
   logic   [31:0]                         tlp_fifo_dw1;
   logic   [31:0]                         tlp_fifo_dw2;
   logic   [31:0]                         tlp_fifo_dw3;    
   logic   [31:0]                         tlp_fifo_dw4; 
   logic   [31:0]                         first_valid_addr;      
   logic   [31:0]                         avmm_3dwh_data_dw0; 
   logic   [31:0]                         avmm_3dwh_data_dw1; 
   logic   [31:0]                         avmm_3dwh_data_dw2; 
   logic   [31:0]                         avmm_3dwh_data_dw3; 
   logic   [31:0]                         avmm_3dwh_data_dw4; 
   logic   [31:0]                         avmm_3dwh_data_dw5; 
   logic   [31:0]                         avmm_3dwh_data_dw6; 
   logic   [31:0]                         avmm_3dwh_data_dw7; 
   logic   [31:0]                         avmm_4dwh_data_dw0; 
   logic   [31:0]                         avmm_4dwh_data_dw1; 
   logic   [31:0]                         avmm_4dwh_data_dw2; 
   logic   [31:0]                         avmm_4dwh_data_dw3; 
   logic   [31:0]                         avmm_4dwh_data_dw4; 
   logic   [31:0]                         avmm_4dwh_data_dw5; 
   logic   [31:0]                         avmm_4dwh_data_dw6; 
   logic   [31:0]                         avmm_4dwh_data_dw7;             
   logic   [(AVMM_WIDTH-1):0]             avmm_3dwh_data;
   logic   [(AVMM_WIDTH-1):0]             avmm_4dwh_data;
   logic [(AVMM_WIDTH+AVMM_WIDTH/8)-1:0]  rxm_fifo_data;
   logic   [(AVMM_WIDTH)-1:0]             rxm_write_data_reg;    
   logic                                  rxm_data_fifo_rdreq;
   logic   [8:0]                          rxm_fifo_usedw;
   logic   [(AVMM_WIDTH+AVMM_WIDTH/8)-1:0]  rxm_write_data;
   logic                                  rxm_cmd_fifo_rdreq;    
   logic   [HPRXM_BAR_TYPE+7:0]          rxm_cmd;                
   logic   [HPRXM_BAR_TYPE+7:0]          rxm_cmd_q;                 
   logic   [4:0]                          rxm_cmd_count;     
   logic                                  is_avmm_wr;          
   logic   [5:0]                          rxm_avmm_burst_count;
   logic   [1:0]                          rxm_avmm_state; 
   logic   [1:0]                          rxm_avmm_nxt_state;     
   logic   [5:0]                          rxm_burst_cntr;                 
   logic   [9:0]                          rx_dwlen_reg;        
   logic   [5:0]                          rxm_burst_count_reg;               
   logic   [HPRXM_BAR_TYPE-1:0]          rxm_address_reg;
   logic                                  pndgrd_fifo_ok_reg;
   
   logic   [7:0]                          rd_tag_reg;             
   logic   [15:0]                         req_id_reg;          
   logic   [7:0]                          rd_tag;          
   logic   [15:0]                         req_id; 
   logic   [1:0]                          rd_attr;
   logic   [2:0]                          rd_tc;    
   logic   [1:0]                          rd_attr_reg;
   logic   [2:0]                          rd_tc_reg; 
   logic                                  valid_bar_hit;
   logic   [5:0]                          bar_decode;     
   logic                                  rxm_data_fifo_empty;
   logic                                  rxm_avmm_idle_state;        
   logic                                  rxm_avmm_wrpipe_state;     
   logic                                  rxm_avmm_write_state;       
   logic                                  rxm_avmm_read_state;        
   logic                                  rx_fifo_rdreq_sreg;     
   logic   [3:0]                          outstanding_read_count;
   logic                                  avmm_256_core;
   
   
   logic                                  avmm_rdsplit_done     ;
   logic                                  rxm_rdsplit_send_first;
   logic                                  rxm_rdsplit_send_max  ;
   logic                                  rxm_rdsplit_send_last ;
   logic                                  rxm_rdsplit_send_first_reg;
   logic                                  rxm_rdsplit_send_max_reg  ;
   logic                                  rxm_rdsplit_send_last_reg ;
        
   logic   [6:0]                          rd_split_remain_cntr;         
   logic   [6:0]                          avmm_bcnt;
   logic   [3:0]                          rdcpl_cred_used;       
   logic   [3:0]                          cpl_credit_replenish;            
   logic   [5:0]                          cpl_space_credit         ;
   logic                                  credit_returned;                      
   logic                                  last_cpl_sent_sreg;
   logic                                  last_cpl_sent_sreg2;
   logic                                  last_cpl_sent_sreg_rise;      
   logic  [HPRXM_BAR_TYPE-1:0]            pipeline_adder_out;    
   logic                                  hprxm_rd_split_state_reg;          
   logic                                  cpl_buff_ok;
   logic                                  avmm_split_done;      
   logic  [2:0]                           rxm_rd_split_state;
   logic  [2:0]                           rxm_rd_split_nxt_state;
   logic                                  rd_splite_req_rise;
   
   
   generate if(AVMM_WIDTH == 256)
     assign avmm_256_core = 1'b1;
   else
     assign avmm_256_core = 1'b0;
   endgenerate
                
  assign rx_fifo_empty = (RxFifoCount_i == 4'h0);        
   /// Decode the Input stream from the RX FIFO
  assign rx_sop         = RxFifoDataq_i[256];
  assign rx_tlp_dwlen   = RxFifoDataq_i[9:0];
  assign is_rd          = ~RxFifoDataq_i[30] & (RxFifoDataq_i[28:26]== 3'b000) & ~RxFifoDataq_i[24];
  assign tlp_4dw_header = RxFifoDataq_i[29]; 
  assign rx_tlp_addr    = tlp_4dw_header? {RxFifoDataq_i[95:64], RxFifoDataq_i[127:96]} : {32'h0, RxFifoDataq_i[95:64]};
  assign tlp_addr_bit2  = rx_tlp_addr[2];
  assign is_wr          = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b00000);
  assign  bar_decode    = RxFifoDataq_i[265:260];
  
  assign rd_tag       = RxFifoDataq_i[47:40];
  assign req_id       = RxFifoDataq_i[63:48];
  assign rd_attr      = RxFifoDataq_i[13:12];
  assign rd_tc        = RxFifoDataq_i[22:20];
  
  assign valid_bar_hit  = bar_decode[2] & HPRXM_BAR_TYPE != 1;  
  
  
  
  //////////////////////////////////////////////
//// HPRX state machine //////////////
///////////////////////////////////////////////
assign rd_tlp_available = (is_rd & rx_sop & ~rx_fifo_empty & valid_bar_hit);  
assign rxm_fifo_ok = rxm_data_fifo_ok_reg & rxm_cmd_fifo_ok_reg;
assign wr_tlp_available = (is_wr & rx_sop & ~rx_fifo_empty &  valid_bar_hit);

/// read the input fifo

//assign RxFifoRdReq_o = (hprxm_idle_state &  wr_tlp_available & rxm_fifo_ok) | 
//                       (hprxm_pipe_state & ~rx_eop_reg) |                                                    
//                       ( hprxm_write_state & rxm_fifo_ok & ~rx_fifo_empty & avmm_burst_cnt_reg != 1);    
//
//

assign rx_eop = RxFifoDataq_i[257];
  
assign RxFifoRdReq_o = (hprxm_idle_state & rd_tlp_available & pndgrd_fifo_ok_reg &  rxm_fifo_ok & cpl_buff_ok & ~last_cpl_sent_sreg) | 
                       (hprxm_idle_state &  tlp_available & rxm_fifo_ok &  ~is_rd) |
                       (hprxm_pipe_state & ~rx_eop_reg) |
                       (rx_fifo_rdreq_sreg );    /// read till eop flag


 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rx_fifo_rdreq_sreg <= 1'b0;
         else if(rx_eop)
           rx_fifo_rdreq_sreg <= 1'b0;
         else if((hprxm_idle_state &  wr_tlp_available & rxm_fifo_ok) | (hprxm_pipe_state & ~rx_eop_reg) )
           rx_fifo_rdreq_sreg <= 1'b1;
         
     end

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           hprxm_state <= HPRXM_IDLE;
         else
           hprxm_state <= hprxm_nxt_state;
     end
     
     
always_comb
  begin
    case(hprxm_state)
      HPRXM_IDLE :
        if(wr_tlp_available & rxm_fifo_ok)
          hprxm_nxt_state <= HPRXM_WR_PIPE;
        else if(rd_tlp_available & pndgrd_fifo_ok_reg &  rxm_fifo_ok & cpl_buff_ok & ~last_cpl_sent_sreg )
          hprxm_nxt_state <= HPRXM_RD_PIPE;
        else
          hprxm_nxt_state <= HPRXM_IDLE;
          
      HPRXM_WR_PIPE :
          hprxm_nxt_state <= HPRXM_WRITE;
          
      HPRXM_RD_PIPE :
        if(avmm_256_core)
          hprxm_nxt_state <= HPRXM_READ;
        else
           hprxm_nxt_state <= HPRXM_IDLE;
          
      HPRXM_WRITE:   /// push AVMM format TLP to FIFO
         if(avmm_burst_cntr == 1)
             hprxm_nxt_state <= HPRXM_IDLE;
         else
             hprxm_nxt_state <= HPRXM_WRITE; 
            
      HPRXM_READ:
        if(rx_dwlen_reg == 10'h0 | avmm_burst_cnt > 16 )  /// avmm count more than 16 lines, split larg read into sub avmm read
          hprxm_nxt_state <= HPRXM_RD_SPLIT_REQUEST;
        else
           hprxm_nxt_state <= HPRXM_IDLE;
     
     HPRXM_RD_SPLIT_REQUEST:
        if(avmm_split_done)
           hprxm_nxt_state <= HPRXM_IDLE;
        else
          hprxm_nxt_state <= HPRXM_RD_SPLIT_REQUEST;
          
      default:
            hprxm_nxt_state <= HPRXM_IDLE;
    endcase
  end

 
/// state machine output decode
assign  hprxm_wr_pipe_state = (hprxm_state == HPRXM_WR_PIPE);   
assign  hprxm_rd_pipe_state = (hprxm_state == HPRXM_RD_PIPE);
assign  hprxm_rd_state      = (hprxm_state == HPRXM_READ);
assign hprxm_idle_state     = (hprxm_state == HPRXM_IDLE);
assign hprxm_pipe_state     = (hprxm_wr_pipe_state | hprxm_rd_pipe_state);
assign hprxm_write_state    = (hprxm_state == HPRXM_WRITE);
assign hprxm_rd_split_state = (hprxm_state == HPRXM_RD_SPLIT_REQUEST);

 always_ff @ (posedge Clk_i)
     begin
            hprxm_wr_pipe_state_reg           <= hprxm_wr_pipe_state;
            hprxm_rd_pipe_state_reg           <= hprxm_rd_pipe_state;
      end

assign tlp_available = wr_tlp_available | rd_tlp_available;

/// latching the header TLP from the rx input FIFO and hold the it for the duration of TLP
assign latch_header_from_idle_state   =  hprxm_idle_state & tlp_available & rxm_fifo_ok; 
assign latch_header_from_write_state  =  (hprxm_write_state & avmm_burst_cntr == 1 & wr_tlp_available  & rxm_fifo_ok);
assign latch_header = latch_header_from_idle_state |
                      latch_header_from_write_state; 

  always_ff @ (posedge Clk_i)
     begin
       if(latch_header)
         begin
            rx_dwlen_reg        <= rx_tlp_dwlen;
            addr_bit2_reg       <= tlp_addr_bit2;
            tlp_4dw_header_reg  <= tlp_4dw_header;
            is_wr_reg           <= is_wr;
            rd_tag_reg          <= rd_tag;    
            rd_attr_reg         <= rd_attr;
            rd_tc_reg           <= rd_tc;
            req_id_reg          <= req_id; 
            
         end
      end

always_ff @ (posedge Clk_i)
     begin
       if(latch_header)
            rx_addr_reg         <= rx_tlp_addr[HPRXM_BAR_TYPE-1:0];
       else if(rxm_rdsplit_send_first_reg | rxm_rdsplit_send_max_reg | rxm_rdsplit_send_last_reg)
            rx_addr_reg         <= pipeline_adder_out;
      end


/// pipeline adder 
        lpm_add_sub     LPM_DEST_ADD_SUB_component (
                                .clken (1'b1),
                                .clock (Clk_i),
                                .dataa ({rx_addr_reg[HPRXM_BAR_TYPE-1:2], 2'b00}),
                                .datab ({avmm_bcnt, 5'h0}),
                                .result (pipeline_adder_out)
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
                LPM_DEST_ADD_SUB_component.lpm_width = HPRXM_BAR_TYPE;


      

  assign tlp_fifo[265:0] = RxFifoDataq_i[265:0];          
                                 
 // pipe register
   always_ff @ (posedge Clk_i)
     begin
            tlp_reg[265:0] <= tlp_fifo;
      end
      
  always_ff @ (posedge Clk_i)
     begin
          tlp_hold_reg[265:0] <= tlp_reg;
     end             
         
/// Calculate adjusted write DW based on the address and rx_dwlen

 // calculate first byte enable for the first Write TLP     
 /// decode at the output of the RX Input FIFO (stage 0)
 
 generate if(AVMM_WIDTH == 256)
   begin
 
 
always_comb
  begin
    case(rx_tlp_addr[4:0])
        5'h0:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h0000_000F;
              10'h2 :  avmm_fbe[31:0] = 32'h0000_00FF;
              10'h3 :  avmm_fbe[31:0] = 32'h0000_0FFF;
              10'h4 :  avmm_fbe[31:0] = 32'h0000_FFFF;
              10'h5 :  avmm_fbe[31:0] = 32'h000F_FFFF;
              10'h6 :  avmm_fbe[31:0] = 32'h00FF_FFFF;
              10'h7 :  avmm_fbe[31:0] = 32'h0FFF_FFFF;
              default: avmm_fbe[31:0] = 32'hFFFF_FFFF;
            endcase
        5'h4:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h0000_00F0;
              10'h2 :  avmm_fbe[31:0] = 32'h0000_0FF0;
              10'h3 :  avmm_fbe[31:0] = 32'h0000_FFF0;
              10'h4 :  avmm_fbe[31:0] = 32'h000F_FFF0;
              10'h5 :  avmm_fbe[31:0] = 32'h00FF_FFF0;
              10'h6 :  avmm_fbe[31:0] = 32'h0FFF_FFF0;
              10'h7 :  avmm_fbe[31:0] = 32'hFFFF_FFF0;
              default: avmm_fbe[31:0] = 32'hFFFF_FFF0;
            endcase
         5'h8:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h0000_0F00;
              10'h2 :  avmm_fbe[31:0] = 32'h0000_FF00;
              10'h3 :  avmm_fbe[31:0] = 32'h000F_FF00;
              10'h4 :  avmm_fbe[31:0] = 32'h00FF_FF00;
              10'h5 :  avmm_fbe[31:0] = 32'h0FFF_FF00;
              10'h6 :  avmm_fbe[31:0] = 32'hFFFF_FF00;
              default: avmm_fbe[31:0] = 32'hFFFF_FF00;
            endcase
          5'hC:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h0000_F000;
              10'h2 :  avmm_fbe[31:0] = 32'h000F_F000;
              10'h3 :  avmm_fbe[31:0] = 32'h00FF_F000;
              10'h4 :  avmm_fbe[31:0] = 32'h0FFF_F000;
              10'h5 :  avmm_fbe[31:0] = 32'hFFFF_F000;
              default: avmm_fbe[31:0] = 32'hFFFF_F000;
            endcase
          5'h10:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h000F_0000;
              10'h2 :  avmm_fbe[31:0] = 32'h00FF_0000;
              10'h3 :  avmm_fbe[31:0] = 32'h0FFF_0000;
              10'h4 :  avmm_fbe[31:0] = 32'hFFFF_0000;
              default: avmm_fbe[31:0] = 32'hFFFF_0000;
            endcase
          5'h14:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h00F0_0000;
              10'h2 :  avmm_fbe[31:0] = 32'h0FF0_0000;
              10'h3 :  avmm_fbe[31:0] = 32'hFFF0_0000;
              default: avmm_fbe[31:0] = 32'hFFF0_0000;
            endcase
          5'h18:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'h0F00_0000;
              10'h2 :  avmm_fbe[31:0] = 32'hFF00_0000;
              default: avmm_fbe[31:0] = 32'hFF00_0000;
            endcase
         5'h1C:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[31:0] = 32'hF000_0000;
              default: avmm_fbe[31:0] = 32'hF000_0000;
            endcase
       default: avmm_fbe[31:0] = 32'hFFFF_FFFF;
      endcase
  end
  
end
else           /// generate for 128-bit
  begin 
    always_comb
  begin
    case(rx_tlp_addr[3:0])
        4'h0:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[15:0] = 16'h000F;
              10'h2 :  avmm_fbe[15:0] = 16'h00FF;
              10'h3 :  avmm_fbe[15:0] = 16'h0FFF;
              default: avmm_fbe[15:0] = 16'hFFFF;
            endcase
        4'h4:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[15:0] = 16'h00F0;
              10'h2 :  avmm_fbe[15:0] = 16'h0FF0;
              default: avmm_fbe[15:0] = 16'hFFF0;
            endcase
       4'h8:
            case (rx_tlp_dwlen)
              10'h1 :  avmm_fbe[15:0] = 16'h0F00;
              default: avmm_fbe[15:0] = 16'hFF00;
            endcase 
     
       default: avmm_fbe[15:0] = 16'hF000;
     
    endcase
  end
end
endgenerate // avmm_fbe logic


generate if(AVMM_WIDTH == 256)
 begin
  always_comb  /// decode empty holes based on avmm_fbe
     begin
      casez (avmm_fbe[31:0])
         32'h????_??F0: first_dw_holes <= 10'h1;
         32'h????_?F0?: first_dw_holes <= 10'h2;
         32'h????_F0??: first_dw_holes <= 10'h3;
         32'h???F_0???: first_dw_holes <= 10'h4;
         32'h??F0_????: first_dw_holes <= 10'h5;
         32'h?F0?_????: first_dw_holes <= 10'h6;
         32'hF0??_????: first_dw_holes <= 10'h7;
        default       : first_dw_holes <= 10'h0;
    endcase
 end  
end
  else  /// generate for 128
    begin
    always_comb  /// decode empty holes based on avmm_fbe
     begin
      casez (avmm_fbe[15:0])
         16'h??F0: first_dw_holes <= 10'h1;
         16'h?F0?: first_dw_holes <= 10'h2;
         16'hF0??: first_dw_holes <= 10'h3;
        default  : first_dw_holes <= 10'h0;
    endcase
 end  
        
 end
endgenerate
  
/// adjust the DW count based on the address alignment to 256-bit   
   always_ff @ (posedge Clk_i)
     if(latch_header)
       begin
        avmm_fbe_reg <= avmm_fbe;
        adjusted_dw_count_reg <=  rx_tlp_dwlen[9:0] + first_dw_holes[7:0]; 
       end
/// burst counter in 256-bit granuality
/// used to keep track of TLP duration in AVMM domain
generate if(AVMM_WIDTH == 256)
  begin
   assign avmm_burst_cnt[7:0] =(adjusted_dw_count_reg[2:0] == 3'b000)? {1'b0,adjusted_dw_count_reg[9:3]} :  {1'b0, adjusted_dw_count_reg[9:3]} + 8'h1;
  end
else
   assign avmm_burst_cnt[7:0] =(adjusted_dw_count_reg[1:0] == 2'b00)? {2'b00, adjusted_dw_count_reg[7:2]} :   (adjusted_dw_count_reg[8:2] + 4'h1);      
endgenerate


 always_ff @ (posedge Clk_i)
     begin
       if(hprxm_pipe_state)
            avmm_burst_cntr <=  avmm_burst_cnt;
       else if(hprxm_write_state)
            avmm_burst_cntr <= avmm_burst_cntr - 1'b1;
      end       

 always_ff @ (posedge Clk_i)
     avmm_burst_cnt_reg[7:0] <= avmm_burst_cnt[7:0];

/// the AVMM first BE logic
/// FBE needs ajusted if write length is small, < 8    
/// mask some BE for small payload

generate if(AVMM_WIDTH ==256)
  begin 
        always_comb
          begin
              case(adjusted_dw_count_reg[2:0])
              3'h1 : adjusted_avmm_fbe_reg <= 32'h0000_000F & avmm_fbe_reg[31:0];
              3'h2 : adjusted_avmm_fbe_reg <= 32'h0000_00FF & avmm_fbe_reg[31:0];
              3'h3 : adjusted_avmm_fbe_reg <= 32'h0000_0FFF & avmm_fbe_reg[31:0];
              3'h4 : adjusted_avmm_fbe_reg <= 32'h0000_FFFF & avmm_fbe_reg[31:0];
              3'h5 : adjusted_avmm_fbe_reg <= 32'h000F_FFFF & avmm_fbe_reg[31:0];    
              3'h6 : adjusted_avmm_fbe_reg <= 32'h00FF_FFFF & avmm_fbe_reg[31:0];
              3'h7 : adjusted_avmm_fbe_reg <= 32'h0FFF_FFFF & avmm_fbe_reg[31:0];	
              default:adjusted_avmm_fbe_reg <= 32'h0000_0000;
            endcase 
          end
  end
else  /// generate
  begin
        always_comb
          begin
              case(adjusted_dw_count_reg[1:0])
              2'h1 : adjusted_avmm_fbe_reg <=  16'h000F & avmm_fbe_reg;
              2'h2 : adjusted_avmm_fbe_reg <=  16'h00FF & avmm_fbe_reg;
              2'h3 : adjusted_avmm_fbe_reg <=  16'h0FFF & avmm_fbe_reg;
              default:adjusted_avmm_fbe_reg <= 16'h0000;
            endcase 
          end       
  end 
endgenerate

generate if(AVMM_WIDTH ==256)
  begin 
   always_ff @ (posedge Clk_i)
     begin
       if(hprxm_pipe_state)
             avmm_first_byten_reg <=(adjusted_dw_count_reg < 8)? adjusted_avmm_fbe_reg :  avmm_fbe_reg;
       else if(hprxm_write_state)
            avmm_first_byten_reg <= 32'hFFFF_FFFF;
      end
  end
else
  begin
   always_ff @ (posedge Clk_i)
     begin
       if(hprxm_pipe_state)
             avmm_first_byten_reg <=(adjusted_dw_count_reg < 4)? adjusted_avmm_fbe_reg :  avmm_fbe_reg;
       else if(hprxm_write_state)
            avmm_first_byten_reg <= 16'hFFFF;
      end
  end
endgenerate
  
generate if(AVMM_WIDTH ==256)
  begin    
      always_comb
       begin
        case(adjusted_dw_count_reg[2:0])
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
else
  begin
      always_comb
       begin
        case(adjusted_dw_count_reg[1:0])
          2'h1 : adjusted_avmm_lbe <=  16'h000F ;
          2'h2 : adjusted_avmm_lbe <=  16'h00FF ;
          2'h3 : adjusted_avmm_lbe <=  16'h0FFF ;
          default:adjusted_avmm_lbe <= 16'hFFFF;
        endcase 
       end      
  end           
endgenerate        

 always_ff @ (posedge Clk_i)
     begin
      if(hprxm_pipe_state)
           avmm_last_byten_reg <=adjusted_avmm_lbe;
      end         
   
 always_ff @ (posedge Clk_i)
    hprxm_pipe_state_reg <= hprxm_pipe_state;
      
generate if(AVMM_WIDTH == 256)   
  assign rxm_byte_enable_reg =  hprxm_pipe_state_reg? avmm_first_byten_reg : (avmm_burst_cntr == 1 )? avmm_last_byten_reg : 32'hFFFF_FFFF;
else
  assign rxm_byte_enable_reg =  hprxm_pipe_state_reg? avmm_first_byten_reg : (avmm_burst_cntr == 1 )? avmm_last_byten_reg : 16'hFFFF;    
endgenerate

// Muxing Write Data
assign rx_eop_reg = tlp_reg[257];
assign tlp_reg_dw0 = tlp_reg[31:0];
assign tlp_reg_dw1 = tlp_reg[63:32];
assign tlp_reg_dw2 = tlp_reg[95:64];
assign tlp_reg_dw3 = tlp_reg[127:96];
assign tlp_reg_dw4 = tlp_reg[159:128];
assign tlp_reg_dw5 = tlp_reg[191:160];
assign tlp_reg_dw6 = tlp_reg[223:192];
assign tlp_reg_dw7 = tlp_reg[255:224];


assign tlp_hold_reg_dw4 = tlp_hold_reg[159:128];
assign tlp_hold_reg_dw5 = tlp_hold_reg[191:160];
assign tlp_hold_reg_dw6 = tlp_hold_reg[223:192];
assign tlp_hold_reg_dw7 = tlp_hold_reg[255:224];

assign tlp_fifo_dw0 = tlp_fifo[31:0];
assign tlp_fifo_dw1 = tlp_fifo[63:32];
assign tlp_fifo_dw2 = tlp_fifo[95:64];
assign tlp_fifo_dw3 = tlp_fifo[127:96];
assign tlp_fifo_dw4 = tlp_fifo[159:128];

generate if(AVMM_WIDTH == 256)
  begin
         // calculate the first valid address based on FBE
           always_comb
             begin
               casez (avmm_fbe_reg[31:0])
                 32'h????_??F0 :first_valid_addr[7:0] <= 8'h04;
                 32'h????_?F00 :first_valid_addr[7:0] <= 8'h08;
                 32'h????_F000 :first_valid_addr[7:0] <= 8'h0C;
                 32'h???F_0000 :first_valid_addr[7:0] <= 8'h10;
                 32'h??F0_0000 :first_valid_addr[7:0] <= 8'h14;
                 32'h?F00_0000 :first_valid_addr[7:0] <= 8'h18;
                 32'hF000_0000 :first_valid_addr[7:0] <= 8'h1C;
                 32'hFFFF_FFFF: first_valid_addr[7:0] <= 8'h00;
                 default:       first_valid_addr[7:0] <= 8'h00;
               endcase
             end
  end
else
  begin
           always_comb
             begin
               casez (avmm_fbe_reg[15:0])
                 16'h??F0 :first_valid_addr[3:0] <= 4'h4;
                 16'h?F00 :first_valid_addr[3:0] <= 4'h8;
                 16'hF000 :first_valid_addr[3:0] <= 4'hC;
                 16'hFFFF: first_valid_addr[3:0] <= 4'h0;
                 default:  first_valid_addr[3:0] <= 4'h0;
               endcase
             end
  end
endgenerate

/// Mux the data to AVMM output FOR 3 DW header

generate if(AVMM_WIDTH == 256)
 begin
  always_comb
     begin
      case(addr_bit2_reg)
       1'b1:
         begin
           case (first_valid_addr[7:0])
             8'h04 :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw3;
                 avmm_3dwh_data_dw2    = tlp_reg_dw4;
                 avmm_3dwh_data_dw3    = tlp_reg_dw5;
                 avmm_3dwh_data_dw4    = tlp_reg_dw6;
                 avmm_3dwh_data_dw5    = tlp_reg_dw7;
                 avmm_3dwh_data_dw6    = tlp_fifo_dw0;  
                 avmm_3dwh_data_dw7    = tlp_fifo_dw1;
               end
 
             8'h08 :  // is this possible case?
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw3    = tlp_reg_dw4;   
                 avmm_3dwh_data_dw4    = tlp_reg_dw5;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw6;   
                 avmm_3dwh_data_dw6    = tlp_reg_dw7;  
                 avmm_3dwh_data_dw7    = tlp_fifo_dw0;  
               end
 
             8'h0C :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw0;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw3    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw4    = tlp_reg_dw4;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw5;   
                 avmm_3dwh_data_dw6    = tlp_reg_dw6;  
                 avmm_3dwh_data_dw7    = tlp_reg_dw7;                 
               end
 
             8'h10 :  // is this possible case?
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw7;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw0;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw3    = tlp_reg_dw2; 
                 avmm_3dwh_data_dw4    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw4;   
                 avmm_3dwh_data_dw6    = tlp_reg_dw5;  
                 avmm_3dwh_data_dw7    = tlp_reg_dw6;   
               end
 
             8'h14 :
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw6;   
                 avmm_3dwh_data_dw1    = tlp_hold_reg_dw7;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw0; 
                 avmm_3dwh_data_dw3    = tlp_reg_dw1; 
                 avmm_3dwh_data_dw4    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw6    = tlp_reg_dw4;  
                 avmm_3dwh_data_dw7    = tlp_reg_dw5;                 
               end
 
             8'h18 :  // is this possible case?
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw5;   
                 avmm_3dwh_data_dw1    = tlp_hold_reg_dw6;   
                 avmm_3dwh_data_dw2    = tlp_hold_reg_dw7; 
                 avmm_3dwh_data_dw3    = tlp_reg_dw0; 
                 avmm_3dwh_data_dw4    = tlp_reg_dw1; 
                 avmm_3dwh_data_dw5    = tlp_reg_dw2;
                 avmm_3dwh_data_dw6    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw7    = tlp_reg_dw4;                   
               end
 
             8'h1C :
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw4;   
                 avmm_3dwh_data_dw1    = tlp_hold_reg_dw5;   
                 avmm_3dwh_data_dw2    = tlp_hold_reg_dw6; 
                 avmm_3dwh_data_dw3    = tlp_hold_reg_dw7; 
                 avmm_3dwh_data_dw4    = tlp_reg_dw0; 
                 avmm_3dwh_data_dw5    = tlp_reg_dw1;
                 avmm_3dwh_data_dw6    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw7    = tlp_reg_dw3;                           
               end
 
             default :  // 8'h0
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw4;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw5; 
                 avmm_3dwh_data_dw3    = tlp_reg_dw6; 
                 avmm_3dwh_data_dw4    = tlp_reg_dw7; 
                 avmm_3dwh_data_dw5    = tlp_fifo_dw0;
                 avmm_3dwh_data_dw6    = tlp_fifo_dw1;  
                 avmm_3dwh_data_dw7    = tlp_fifo_dw2;
               end
           endcase
         end
 
      1'b0:
         begin
           case (first_valid_addr[7:0])
             8'h04 :
               begin
               	avmm_3dwh_data_dw0    = tlp_reg_dw3;
                 avmm_3dwh_data_dw1    = tlp_reg_dw4;      
                 avmm_3dwh_data_dw2    = tlp_reg_dw5;      
                 avmm_3dwh_data_dw3    = tlp_reg_dw6;      
                 avmm_3dwh_data_dw4    = tlp_reg_dw7;      
                 avmm_3dwh_data_dw5    = tlp_fifo_dw0;      
                 avmm_3dwh_data_dw6    = tlp_fifo_dw1;     
                 avmm_3dwh_data_dw7    = tlp_fifo_dw2;     
               end
 
             8'h08 :
               begin
               	avmm_3dwh_data_dw0    = tlp_reg_dw2;
                 avmm_3dwh_data_dw1    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw4;      
                 avmm_3dwh_data_dw3    = tlp_reg_dw5;      
                 avmm_3dwh_data_dw4    = tlp_reg_dw6;      
                 avmm_3dwh_data_dw5    = tlp_reg_dw7;      
                 avmm_3dwh_data_dw6    = tlp_fifo_dw0;     
                 avmm_3dwh_data_dw7    = tlp_fifo_dw1;   
               end
 
             8'h0C :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw1;
                 avmm_3dwh_data_dw1    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw4;      
                 avmm_3dwh_data_dw4    = tlp_reg_dw5;      
                 avmm_3dwh_data_dw5    = tlp_reg_dw6;      
                 avmm_3dwh_data_dw6    = tlp_reg_dw7;     
                 avmm_3dwh_data_dw7    = tlp_fifo_dw0;                  
               end
 
             8'h10 :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw0;
                 avmm_3dwh_data_dw1    = tlp_reg_dw1;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw4    = tlp_reg_dw4;      
                 avmm_3dwh_data_dw5    = tlp_reg_dw5;      
                 avmm_3dwh_data_dw6    = tlp_reg_dw6;     
                 avmm_3dwh_data_dw7    = tlp_reg_dw7;            
               end
 
             8'h14 :
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw7;
                 avmm_3dwh_data_dw1    = tlp_reg_dw0;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw1;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw4    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw4;      
                 avmm_3dwh_data_dw6    = tlp_reg_dw5;     
                 avmm_3dwh_data_dw7    = tlp_reg_dw6;  
               end
 
             8'h18 :
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw6;
                 avmm_3dwh_data_dw1    = tlp_hold_reg_dw7;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw0;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw1;  
                 avmm_3dwh_data_dw4    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw6    = tlp_reg_dw4;     
                 avmm_3dwh_data_dw7    = tlp_reg_dw5;  
               end
 
             8'h1C :
               begin
                 avmm_3dwh_data_dw0    = tlp_hold_reg_dw5;
                 avmm_3dwh_data_dw1    = tlp_hold_reg_dw6;  
                 avmm_3dwh_data_dw2    = tlp_hold_reg_dw7;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw0;  
                 avmm_3dwh_data_dw4    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw5    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw6    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw7    = tlp_reg_dw4;
               end
 
             default :  // 8'h0
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw4;
                 avmm_3dwh_data_dw1    = tlp_reg_dw5;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw6;  
                 avmm_3dwh_data_dw3    = tlp_reg_dw7;  
                 avmm_3dwh_data_dw4    = tlp_fifo_dw0;   
                 avmm_3dwh_data_dw5    = tlp_fifo_dw1;  
                 avmm_3dwh_data_dw6    = tlp_fifo_dw2;   
                 avmm_3dwh_data_dw7    = tlp_fifo_dw3;
               end
           endcase
         end
        default:
          begin
          	      avmm_3dwh_data_dw0    = 32'h0;
                 avmm_3dwh_data_dw1    = 32'h0;  
                 avmm_3dwh_data_dw2    = 32'h0;  
                 avmm_3dwh_data_dw3    = 32'h0;  
                 avmm_3dwh_data_dw4    = 32'h0;   
                 avmm_3dwh_data_dw5    = 32'h0;  
                 avmm_3dwh_data_dw6    = 32'h0;   
                 avmm_3dwh_data_dw7    = 32'h0;
          end
     endcase
     end

 end
else // generate 3DW Header MUX
 begin
     always_comb
     begin
      case(addr_bit2_reg)
       1'b1:
         begin
           case (first_valid_addr[3:0])
             4'h4 :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw3;
                 avmm_3dwh_data_dw2    = tlp_fifo_dw0;
                 avmm_3dwh_data_dw3    = tlp_fifo_dw1;
               end
 
             4'h8 :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw3    = tlp_fifo_dw0;   
               end
 
             4'hC :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw0;   
                 avmm_3dwh_data_dw1    = tlp_reg_dw1;   
                 avmm_3dwh_data_dw2    = tlp_reg_dw2;   
                 avmm_3dwh_data_dw3    = tlp_reg_dw3;   
               end
               
               default :  // 4'h0
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw3;   
                 avmm_3dwh_data_dw1    = tlp_fifo_dw0;   
                 avmm_3dwh_data_dw2    = tlp_fifo_dw1; 
                 avmm_3dwh_data_dw3    = tlp_fifo_dw2; 
               end
           endcase
         end
 
      1'b0:
         begin
           case (first_valid_addr[3:0])
             4'h4 :
               begin
               	avmm_3dwh_data_dw0     = tlp_reg_dw3;
                 avmm_3dwh_data_dw1    = tlp_fifo_dw0;      
                 avmm_3dwh_data_dw2    = tlp_fifo_dw1;      
                 avmm_3dwh_data_dw3    = tlp_fifo_dw2;      
               end
 
             4'h8 :
               begin
               	avmm_3dwh_data_dw0     = tlp_reg_dw2;
                 avmm_3dwh_data_dw1    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw2    = tlp_fifo_dw0;      
                 avmm_3dwh_data_dw3    = tlp_fifo_dw1;      
               end
 
             4'hC :
               begin
                 avmm_3dwh_data_dw0    = tlp_reg_dw1;
                 avmm_3dwh_data_dw1    = tlp_reg_dw2;  
                 avmm_3dwh_data_dw2    = tlp_reg_dw3;  
                 avmm_3dwh_data_dw3    = tlp_fifo_dw0;      
               end
               
             default :  // 8'h0
               begin
                 avmm_3dwh_data_dw0    = tlp_fifo_dw0;
                 avmm_3dwh_data_dw1    = tlp_fifo_dw1;  
                 avmm_3dwh_data_dw2    = tlp_fifo_dw2;  
                 avmm_3dwh_data_dw3    = tlp_fifo_dw3;  
               end
           endcase
         end
        default:
          begin
          	     avmm_3dwh_data_dw0    = 32'h0;
                 avmm_3dwh_data_dw1    = 32'h0;  
                 avmm_3dwh_data_dw2    = 32'h0;  
                 avmm_3dwh_data_dw3    = 32'h0;  
          end
     endcase
   end
 end
endgenerate




/// Mux the data to AVMM output FOR 4 DW header
generate if(AVMM_WIDTH == 256)
  begin
    always_comb
       begin
        case(addr_bit2_reg)
         1'b1:
           begin
             case (first_valid_addr[7:0])
               8'h04 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw4;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw5;
                   avmm_4dwh_data_dw2    = tlp_reg_dw6;
                   avmm_4dwh_data_dw3    = tlp_reg_dw7;
                   avmm_4dwh_data_dw4    = tlp_fifo_dw0;
                   avmm_4dwh_data_dw5    = tlp_fifo_dw1;
                   avmm_4dwh_data_dw6    = tlp_fifo_dw2;  
                   avmm_4dwh_data_dw7    = tlp_fifo_dw3;
                 end
   
               8'h08 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw3;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw4;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw5;   
                   avmm_4dwh_data_dw3    = tlp_reg_dw6;   
                   avmm_4dwh_data_dw4    = tlp_reg_dw7;   
                   avmm_4dwh_data_dw5    = tlp_fifo_dw0;   
                   avmm_4dwh_data_dw6    = tlp_fifo_dw1;  
                   avmm_4dwh_data_dw7    = tlp_fifo_dw2;  
                 end
   
               8'h0C :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw2;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw3;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw4;   
                   avmm_4dwh_data_dw3    = tlp_reg_dw5;   
                   avmm_4dwh_data_dw4    = tlp_reg_dw6;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw7;   
                   avmm_4dwh_data_dw6    = tlp_fifo_dw0;  
                   avmm_4dwh_data_dw7    = tlp_fifo_dw1;                 
                 end
   
               8'h10 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw1;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw2;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw3;   
                   avmm_4dwh_data_dw3    = tlp_reg_dw4; 
                   avmm_4dwh_data_dw4    = tlp_reg_dw5;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw6;   
                   avmm_4dwh_data_dw6    = tlp_reg_dw7;  
                   avmm_4dwh_data_dw7    = tlp_fifo_dw0;   
                 end
   
               8'h14 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw0;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw1;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw2; 
                   avmm_4dwh_data_dw3    = tlp_reg_dw3; 
                   avmm_4dwh_data_dw4    = tlp_reg_dw4;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw5;   
                   avmm_4dwh_data_dw6    = tlp_reg_dw6;  
                   avmm_4dwh_data_dw7    = tlp_reg_dw7;                 
                 end
   
               8'h18 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_hold_reg_dw7;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw0;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw1; 
                   avmm_4dwh_data_dw3    = tlp_reg_dw2; 
                   avmm_4dwh_data_dw4    = tlp_reg_dw3; 
                   avmm_4dwh_data_dw5    = tlp_reg_dw4;
                   avmm_4dwh_data_dw6    = tlp_reg_dw5;  
                   avmm_4dwh_data_dw7    = tlp_reg_dw6;                   
                 end
   
               8'h1C :
                 begin
                   avmm_4dwh_data_dw0    = tlp_hold_reg_dw6;   
                   avmm_4dwh_data_dw1    = tlp_hold_reg_dw7;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw0; 
                   avmm_4dwh_data_dw3    = tlp_reg_dw1; 
                   avmm_4dwh_data_dw4    = tlp_reg_dw2; 
                   avmm_4dwh_data_dw5    = tlp_reg_dw3;
                   avmm_4dwh_data_dw6    = tlp_reg_dw4;  
                   avmm_4dwh_data_dw7    = tlp_reg_dw5;                           
                 end
   
               default :  // 8'h0
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw5;   
                   avmm_4dwh_data_dw1    = tlp_reg_dw6;   
                   avmm_4dwh_data_dw2    = tlp_reg_dw7; 
                   avmm_4dwh_data_dw3    = tlp_fifo_dw0; 
                   avmm_4dwh_data_dw4    = tlp_fifo_dw1; 
                   avmm_4dwh_data_dw5    = tlp_fifo_dw2;
                   avmm_4dwh_data_dw6    = tlp_fifo_dw3;  
                   avmm_4dwh_data_dw7    = tlp_fifo_dw4;
                 end
             endcase
           end
   
        1'b0:
           begin
             case (first_valid_addr[7:0])
               8'h04 :
                 begin
                 	avmm_4dwh_data_dw0    = tlp_reg_dw3;
                   avmm_4dwh_data_dw1    = tlp_reg_dw4;      
                   avmm_4dwh_data_dw2    = tlp_reg_dw5;      
                   avmm_4dwh_data_dw3    = tlp_reg_dw6;      
                   avmm_4dwh_data_dw4    = tlp_reg_dw7;      
                   avmm_4dwh_data_dw5    = tlp_fifo_dw0;      
                   avmm_4dwh_data_dw6    = tlp_fifo_dw1;     
                   avmm_4dwh_data_dw7    = tlp_fifo_dw2;     
                 end
   
               8'h08 :
                 begin
                 	avmm_4dwh_data_dw0    = tlp_reg_dw2;
                   avmm_4dwh_data_dw1    = tlp_reg_dw3;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw4;      
                   avmm_4dwh_data_dw3    = tlp_reg_dw5;      
                   avmm_4dwh_data_dw4    = tlp_reg_dw6;      
                   avmm_4dwh_data_dw5    = tlp_reg_dw7;      
                   avmm_4dwh_data_dw6    = tlp_fifo_dw0;     
                   avmm_4dwh_data_dw7    = tlp_fifo_dw1;   
                 end
   
               8'h0C :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw1;
                   avmm_4dwh_data_dw1    = tlp_reg_dw2;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw3;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw4;      
                   avmm_4dwh_data_dw4    = tlp_reg_dw5;      
                   avmm_4dwh_data_dw5    = tlp_reg_dw6;      
                   avmm_4dwh_data_dw6    = tlp_reg_dw7;     
                   avmm_4dwh_data_dw7    = tlp_fifo_dw0;                  
                 end
   
               8'h10 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw0;
                   avmm_4dwh_data_dw1    = tlp_reg_dw1;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw2;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw3;  
                   avmm_4dwh_data_dw4    = tlp_reg_dw4;      
                   avmm_4dwh_data_dw5    = tlp_reg_dw5;      
                   avmm_4dwh_data_dw6    = tlp_reg_dw6;     
                   avmm_4dwh_data_dw7    = tlp_reg_dw7;            
                 end
   
               8'h14 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_hold_reg_dw7;
                   avmm_4dwh_data_dw1    = tlp_reg_dw0;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw1;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw2;  
                   avmm_4dwh_data_dw4    = tlp_reg_dw3;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw4;      
                   avmm_4dwh_data_dw6    = tlp_reg_dw5;     
                   avmm_4dwh_data_dw7    = tlp_reg_dw6;  
                 end
   
               8'h18 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_hold_reg_dw6;
                   avmm_4dwh_data_dw1    = tlp_hold_reg_dw7;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw0;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw1;  
                   avmm_4dwh_data_dw4    = tlp_reg_dw2;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw3;  
                   avmm_4dwh_data_dw6    = tlp_reg_dw4;     
                   avmm_4dwh_data_dw7    = tlp_reg_dw5;  
                 end
   
               8'h1C :
                 begin
                   avmm_4dwh_data_dw0    = tlp_hold_reg_dw5;
                   avmm_4dwh_data_dw1    = tlp_hold_reg_dw6;  
                   avmm_4dwh_data_dw2    = tlp_hold_reg_dw7;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw0;  
                   avmm_4dwh_data_dw4    = tlp_reg_dw1;   
                   avmm_4dwh_data_dw5    = tlp_reg_dw2;  
                   avmm_4dwh_data_dw6    = tlp_reg_dw3;   
                   avmm_4dwh_data_dw7    = tlp_reg_dw4;
                 end
   
               default :  // 8'h0
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw4;
                   avmm_4dwh_data_dw1    = tlp_reg_dw5;  
                   avmm_4dwh_data_dw2    = tlp_reg_dw6;  
                   avmm_4dwh_data_dw3    = tlp_reg_dw7;  
                   avmm_4dwh_data_dw4    = tlp_fifo_dw0;   
                   avmm_4dwh_data_dw5    = tlp_fifo_dw1;  
                   avmm_4dwh_data_dw6    = tlp_fifo_dw2;   
                   avmm_4dwh_data_dw7    = tlp_fifo_dw3;
                 end
             endcase
           end
          default:
            begin
            	      avmm_4dwh_data_dw0    = 32'h0;
                   avmm_4dwh_data_dw1    = 32'h0;  
                   avmm_4dwh_data_dw2    = 32'h0;  
                   avmm_4dwh_data_dw3    = 32'h0;  
                   avmm_4dwh_data_dw4    = 32'h0;   
                   avmm_4dwh_data_dw5    = 32'h0;  
                   avmm_4dwh_data_dw6    = 32'h0;   
                   avmm_4dwh_data_dw7    = 32'h0;
            end
       endcase
    end
  end
else  // generate 4DW header
  begin
    always_comb
       begin
        case(addr_bit2_reg)
         1'b1:
           begin
             case (first_valid_addr[3:0])
               4'h4 :
                 begin
                   avmm_4dwh_data_dw0    = tlp_fifo_dw0;   
                   avmm_4dwh_data_dw1    = tlp_fifo_dw1;
                   avmm_4dwh_data_dw2    = tlp_fifo_dw2;
                   avmm_4dwh_data_dw3    = tlp_fifo_dw3;
                 end
                      
               default :  //4'hC
                 begin
                   avmm_4dwh_data_dw0    = tlp_reg_dw2;    
                   avmm_4dwh_data_dw1    = tlp_reg_dw3;    
                   avmm_4dwh_data_dw2    = tlp_fifo_dw0;   
                   avmm_4dwh_data_dw3    = tlp_fifo_dw1;   
                 end
             endcase
           end
   
        1'b0:
           begin
             case (first_valid_addr[3:0])
                      
               4'h8 :
                 begin
                 	 avmm_4dwh_data_dw0    = tlp_reg_dw2;
                   avmm_4dwh_data_dw1    = tlp_reg_dw3;  
                   avmm_4dwh_data_dw2    = tlp_fifo_dw0;      
                   avmm_4dwh_data_dw3    = tlp_fifo_dw1;      
                 end
   
                   
               default :  // 8'h0
                 begin
                   avmm_4dwh_data_dw0    = tlp_fifo_dw0;
                   avmm_4dwh_data_dw1    = tlp_fifo_dw1;  
                   avmm_4dwh_data_dw2    = tlp_fifo_dw2;  
                   avmm_4dwh_data_dw3    = tlp_fifo_dw3;  
                 end
             endcase  
           end
        default:
          begin
          	     avmm_4dwh_data_dw0    = 32'h0;
                 avmm_4dwh_data_dw1    = 32'h0;  
                 avmm_4dwh_data_dw2    = 32'h0;  
                 avmm_4dwh_data_dw3    = 32'h0;  
          end
       endcase
    end
  end
endgenerate  // 4DW Header

generate if (AVMM_WIDTH == 256)
  begin
      assign avmm_3dwh_data =    {avmm_3dwh_data_dw7, avmm_3dwh_data_dw6, avmm_3dwh_data_dw5, avmm_3dwh_data_dw4, avmm_3dwh_data_dw3, avmm_3dwh_data_dw2, avmm_3dwh_data_dw1, avmm_3dwh_data_dw0}; 
      assign avmm_4dwh_data =    {avmm_4dwh_data_dw7, avmm_4dwh_data_dw6, avmm_4dwh_data_dw5, avmm_4dwh_data_dw4, avmm_4dwh_data_dw3, avmm_4dwh_data_dw2, avmm_4dwh_data_dw1, avmm_4dwh_data_dw0};  
 
  end
else
  begin
      assign avmm_3dwh_data =    {avmm_3dwh_data_dw3, avmm_3dwh_data_dw2, avmm_3dwh_data_dw1, avmm_3dwh_data_dw0}; 
      assign avmm_4dwh_data =    {avmm_4dwh_data_dw3, avmm_4dwh_data_dw2, avmm_4dwh_data_dw1, avmm_4dwh_data_dw0};  
  end 
endgenerate
  

 always_ff @ (posedge Clk_i)
       rxm_write_data_reg <= tlp_4dw_header_reg? avmm_4dwh_data : avmm_3dwh_data;

assign rxm_fifo_data = {rxm_byte_enable_reg, rxm_write_data_reg};

/// FIFO to store the AVMM write data and byte enable

	scfifo	rxm_data_fifo (
				.rdreq (rxm_data_fifo_rdreq),
				.clock (Clk_i),
				.wrreq (hprxm_write_state),
				.data (rxm_fifo_data),
				.usedw (rxm_fifo_usedw),
				.empty (rxm_data_fifo_empty),
				.q (rxm_write_data),
				.full (),
				.aclr (~Rstn_i),
				.almost_empty (),
				.almost_full (),
				.sclr ()
				);
	defparam
		rxm_data_fifo.add_ram_output_register = "ON",
		rxm_data_fifo.intended_device_family = "Stratix V",
		rxm_data_fifo.lpm_numwords = 512,
		rxm_data_fifo.lpm_showahead = "OFF",
		rxm_data_fifo.lpm_type = "scfifo",
		rxm_data_fifo.lpm_width = (AVMM_WIDTH+AVMM_WIDTH/8),
		rxm_data_fifo.lpm_widthu = 9,
		rxm_data_fifo.overflow_checking = "ON",
		rxm_data_fifo.underflow_checking = "ON",
		rxm_data_fifo.use_eab = "ON"; 
    
always_ff @ (posedge Clk_i)
    rxm_data_fifo_ok_reg <=  rxm_fifo_usedw < 496;
    
/// Command  fifo to hold the address and burst count

altpcie_fifo 
   #(
    .FIFO_DEPTH(16),    
    .DATA_WIDTH(8+HPRXM_BAR_TYPE)   /// address, burst count, write/read 
    )
 rxm_cmd_fifo   
(
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(1'b0),      
      .wrreq(hprxm_wr_pipe_state_reg | hprxm_rd_pipe_state_reg & (rx_dwlen_reg != 0 & avmm_burst_cnt_reg <= MAX_BCNT) | rxm_rdsplit_send_first | rxm_rdsplit_send_max | rxm_rdsplit_send_last),     
      .rdreq(rxm_cmd_fifo_rdreq),     
      .data(rxm_cmd),      
      .q(rxm_cmd_q),         
      .fifo_count(rxm_cmd_count) 
);

assign is_avmm_wr           = rxm_cmd_q[HPRXM_BAR_TYPE+7];
assign rxm_avmm_burst_count = rxm_cmd_q[HPRXM_BAR_TYPE+DMA_BRST_CNT_W:HPRXM_BAR_TYPE];


always_ff @ (posedge Clk_i)
    rxm_cmd_fifo_ok_reg <=  rxm_cmd_count < 14;
    
assign rxm_cmd = {is_wr_reg, avmm_bcnt[6:0], rx_addr_reg[HPRXM_BAR_TYPE-1:0]};

/// AVMM interface state machine

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rxm_avmm_state <= HPRXM_IDLE;
         else
           rxm_avmm_state <= rxm_avmm_nxt_state;
     end

always_comb
  begin
    case(rxm_avmm_state)
      RXM_AVMM_IDLE :
        if(rxm_cmd_count != 0 & is_avmm_wr & ~rxm_data_fifo_empty)
          rxm_avmm_nxt_state <= RXM_AVMM_WR_PIPE;
        else if (rxm_cmd_count != 0 & ~is_avmm_wr & rxm_cmd_count != 0)
          rxm_avmm_nxt_state <= RXM_AVMM_RD;
        else
           rxm_avmm_nxt_state <= RXM_AVMM_IDLE;
      
      RXM_AVMM_WR_PIPE:
          rxm_avmm_nxt_state <= RXM_AVMM_WR;
       
      RXM_AVMM_WR:
        if(~HPRxmWaitRequest_i & rxm_burst_cntr == 1)
          rxm_avmm_nxt_state <= RXM_AVMM_IDLE;
        else 
          rxm_avmm_nxt_state <= RXM_AVMM_WR;
          
      RXM_AVMM_RD:
        if(~HPRxmWaitRequest_i)
          rxm_avmm_nxt_state <= RXM_AVMM_IDLE;
        else
           rxm_avmm_nxt_state <= RXM_AVMM_RD;
          
      default:
            rxm_avmm_nxt_state <= RXM_AVMM_IDLE;
    endcase
  end
 
 assign rxm_avmm_idle_state  = rxm_avmm_state == RXM_AVMM_IDLE;   
 assign rxm_avmm_wrpipe_state = rxm_avmm_state == RXM_AVMM_WR_PIPE;
 assign rxm_avmm_write_state = rxm_avmm_state == RXM_AVMM_WR;
 assign rxm_avmm_read_state  = rxm_avmm_state == RXM_AVMM_RD;      
 assign rxm_data_fifo_rdreq  = (rxm_avmm_write_state & rxm_burst_cntr != 1 & ~HPRxmWaitRequest_i) | (rxm_avmm_wrpipe_state );
 
 
 assign rxm_cmd_fifo_rdreq = is_avmm_wr? (rxm_avmm_idle_state & rxm_cmd_count != 0 & ~rxm_data_fifo_empty) : (rxm_avmm_idle_state & rxm_cmd_count != 0) ;
// latch the address, 
    always_ff @ (posedge Clk_i)
     begin
       if(rxm_cmd_fifo_rdreq)
         begin
             rxm_address_reg[HPRXM_BAR_TYPE-1:0]     <=  rxm_cmd_q[HPRXM_BAR_TYPE-1:0];
             rxm_burst_count_reg <=  rxm_cmd_q[HPRXM_BAR_TYPE+5:HPRXM_BAR_TYPE];
         end
      end
      
// the rxm burst counter
    always_ff @ (posedge Clk_i)
     begin
       if(rxm_cmd_fifo_rdreq)
         rxm_burst_cntr <=  rxm_avmm_burst_count;
       else if(~HPRxmWaitRequest_i & rxm_avmm_write_state)
         rxm_burst_cntr <=  rxm_burst_cntr - 6'h1;
      end
      
      
assign HPRxmWrite_o       = rxm_avmm_write_state;
assign HPRxmRead_o        = rxm_avmm_read_state;
assign HPRxmAddress_o        = { {(HPRXM_BAR_TYPE-BAR2_SIZE_MASK ){1'b0}}, rxm_address_reg[BAR2_SIZE_MASK -1:0] };
assign HPRxmBurstCount_o  = rxm_burst_count_reg[DMA_BRST_CNT_W-1:0];
assign HPRxmWriteData_o   = rxm_write_data[AVMM_WIDTH-1:0];
assign HPRxmByteEnable_o  = rxm_avmm_write_state? rxm_write_data[(AVMM_WIDTH+AVMM_WIDTH/8)-1:AVMM_WIDTH] : {(AVMM_WIDTH/8){1'b1}};         

/// RXM Pending Read Interface          
//                            [51]   {50:47]   [50:48]      [47:46]      [45:42]   [41:32]                 [31:16]                     [15]                [14:8]                     [7:0] 
assign PndgRdHeader_o      = {1'b0,   4'hF,   rd_tc_reg,   rd_attr_reg,   4'hF,   rx_dwlen_reg,  req_id_reg[15:0],   1'b0,    rx_addr_reg[6:0],  rd_tag_reg};  

assign PndgRdFifoWrReq_o   = hprxm_rd_pipe_state;     


/// Pending credit Fifo

altpcie_fifo 
   #(
    .FIFO_DEPTH(32),    
    .DATA_WIDTH(4)   
    )
 cpl_pending_cred_fifo   
(
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(1'b0),      
      .wrreq(hprxm_rd_pipe_state),     
      .rdreq(credit_returned),     
      .data(rdcpl_cred_used[3:0]),      
      .q(cpl_credit_replenish[3:0]),         
      .fifo_count() 
);


   always_ff @ (posedge Clk_i)
     pndgrd_fifo_ok_reg <= (PndgRdFifoCount_i < 8);
     
/// FIFO to store the read burst count after sending reads to AVMM

logic rd_bcnt_fifo_wrreq;

assign rd_bcnt_fifo_wrreq = hprxm_rd_pipe_state & ~avmm_256_core | hprxm_rd_state & avmm_256_core;

altpcie_fifo 
   #(
    .FIFO_DEPTH(16),    
    .DATA_WIDTH(8)
    )
 rxm_rd_bcount_fifo   
(
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(1'b0),      
      .wrreq(rd_bcnt_fifo_wrreq),     
      .rdreq(ReadBcntFifoRdreq_i),     
      .data(avmm_burst_cnt[7:0]),
      .q(ReadBcntFifoq_o),         
      .fifo_count() 
);


/// tx cpl buffer management
/// allow 4 reads before back pressure to minimize tx cpl buffer space


 always @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
        outstanding_read_count <= 4'h0;
      else if(hprxm_rd_pipe_state) /// accepting a read
        outstanding_read_count <= outstanding_read_count +  4'h1;
      else if(LastTxCplSent_i)
        outstanding_read_count <= outstanding_read_count - 4'h1;
    end
  
/// state machine to slpit large read > 512B into smaller avmm reads

always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      hprxm_rd_split_state_reg <= 1'b0;
    else
      hprxm_rd_split_state_reg <= hprxm_rd_split_state;
   end
   
 assign rd_splite_req_rise = ~hprxm_rd_split_state_reg & hprxm_rd_split_state;
  
  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rxm_rd_split_state <= RXM_RDSPLIT_IDLE;
         else
           rxm_rd_split_state <= rxm_rd_split_nxt_state;
     end
   
always_comb
  begin
    case(rxm_rd_split_state)
      RXM_RDSPLIT_IDLE :
        if(rd_splite_req_rise)
          rxm_rd_split_nxt_state <= RXM_RDSPLIT_PIPE;
         else
          rxm_rd_split_nxt_state <= RXM_RDSPLIT_IDLE;
          
      RXM_RDSPLIT_PIPE:
        if(rx_addr_reg[4:0] != 5'h0)
          rxm_rd_split_nxt_state <= RXM_RDSPLIT_SEND_FIRST;
        else
         rxm_rd_split_nxt_state <= RXM_RDSPLIT_SEND_MAX;
         
      RXM_RDSPLIT_SEND_FIRST, RXM_RDSPLIT_SEND_MAX:
         rxm_rd_split_nxt_state <= RXM_RDSPLIT_WAIT_COUNT;   /// wait for counter to update
      
      RXM_RDSPLIT_WAIT_COUNT:
        if(rd_split_remain_cntr > 16)
          rxm_rd_split_nxt_state <= RXM_RDSPLIT_SEND_MAX;
        else
          rxm_rd_split_nxt_state <= RXM_RDSPLIT_SEND_LAST;
         
      RXM_RDSPLIT_SEND_LAST:
         rxm_rd_split_nxt_state <= RXM_RDSPLIT_IDLE;
      
      default:
        rxm_rd_split_nxt_state <= RXM_RDSPLIT_IDLE;
    endcase
  end  
    
    assign avmm_split_done        = (rxm_rd_split_state == RXM_RDSPLIT_SEND_LAST);
    assign rxm_rdsplit_send_first = (rxm_rd_split_state == RXM_RDSPLIT_SEND_FIRST);
    assign rxm_rdsplit_send_max   = (rxm_rd_split_state == RXM_RDSPLIT_SEND_MAX);
    assign rxm_rdsplit_send_last  = (rxm_rd_split_state == RXM_RDSPLIT_SEND_LAST);
    
    
    always_ff @ (posedge Clk_i)
     begin
          rxm_rdsplit_send_first_reg <= rxm_rdsplit_send_first;   
          rxm_rdsplit_send_max_reg   <=  rxm_rdsplit_send_max;   
          rxm_rdsplit_send_last_reg  <= rxm_rdsplit_send_last;   
     end
    
    
    
    always_ff @ (posedge Clk_i)
     begin
      if(hprxm_pipe_state)
        rd_split_remain_cntr <=  avmm_burst_cnt;
      else if(rxm_rdsplit_send_first)
         rd_split_remain_cntr <=  rd_split_remain_cntr -1;
      else if(rxm_rdsplit_send_max)
         rd_split_remain_cntr <=  rd_split_remain_cntr - 7'h10;
      end
  
  assign avmm_bcnt = rxm_rdsplit_send_first? 7'h1 : rxm_rdsplit_send_max? 7'd16 : rd_split_remain_cntr;  /// this is for both read and write
  
  
  /// Completion buffer space Count
  // 16K CPL buffer
  // credit is 512B each, total of 32 credits
  
  assign rdcpl_cred_used = (rx_dwlen_reg == 10'h0)? 4'h8 : (rx_dwlen_reg[9:7] != 3'h0)? {1'b0,rx_dwlen_reg[9:7]} : 4'h1; 
  
    always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
      if(~Rstn_i)
        cpl_space_credit <=  6'd16;
      else if(hprxm_rd_pipe_state)
         cpl_space_credit <=  cpl_space_credit - rdcpl_cred_used[3:0];
      else if(credit_returned)
         cpl_space_credit <= cpl_space_credit + cpl_credit_replenish;
      end
      
      assign cpl_buff_ok = (cpl_space_credit >= 8); 
      
   // holding last cpl signal
      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
      if(~Rstn_i)
        last_cpl_sent_sreg <=  1'b0;
      else if(LastTxCplSent_i)
         last_cpl_sent_sreg <= 1'b1;
      else if(credit_returned)
         last_cpl_sent_sreg <= 1'b0;
      end 
     
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
      if(~Rstn_i)
        last_cpl_sent_sreg2 <=  1'b0;
      else
         last_cpl_sent_sreg2 <= last_cpl_sent_sreg;
      end  
      
  assign last_cpl_sent_sreg_rise = ~last_cpl_sent_sreg2 & last_cpl_sent_sreg;
  
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
      if(~Rstn_i)
        credit_returned <=  1'b0;
      else
         credit_returned <= last_cpl_sent_sreg_rise;
      end  
      
endmodule
