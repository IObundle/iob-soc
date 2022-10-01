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


// altera message_off  10036 10034 10229 10230 10764 10229
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpcieav128_dma_wr_wdalign # (
   parameter WRDMA_AVL_ADDR_WIDTH            = 20
   )
(
   input    logic                        Clk_i,
   input    logic                        Srst_i,
      // Raw Data RAM input interface
   input    logic   [10:0]                RawBufferLimit_i,

   output   logic                        RawBuffRelease_o,
   output   logic   [9:0]                RawBuffReleaseSize_o,
   output   logic   [9:0]                RawRamAddress_o,
   input    logic   [127:0]              RawRamData_i,

   input    logic  [159:0]               DescFifo_i,
   input    logic  [3:0]                 DescFifoCount_i,
   output   logic                        DescFifoRdreq_o,

   output   logic                        DescDataCompleteFifoRdReq_o,
   input    logic [4:0]                  DescDataCompleteFifoCount_i,

   /// Aligned RAM output
   input    logic  [9:0]                 AlignedRamRdAddr_i,
   output   logic  [129:0]               AlignedRamData_o,

   /// Credit Update from TLP Gen
   input                                 TlpGenCreditUp_i,
   input    logic [10:0]                  TlpGenCred_i,

   output   logic  [10:0]                 TLPGenBuffLimit_o,

   input    logic                        TLPHeaderFifoRdReq_i,
   output   logic                        TLPHeaderFifoEmpty_o,
   output   logic   [138:0]              TLPHeaderFifoData_o,

   input    logic   [12:0]               BusDev_i,
   input    logic   [31:0]               DevCsr_i

  );

logic               descriptor_available;
logic               all_desc_payload_available;
logic               desc_read_state;
logic               buffer_prefetch_state;
logic               send_16B_state;
logic               send_16B_state_2;
logic               send_16B_state_reg;
logic               send_16B_state_2_reg;
logic               send_16B_state_reg2;
logic               send_16B_state_2_reg2;
logic               send_4KB_state;
logic               send_last_state;
logic               send_max_state;
logic               send_max_state_reg;
logic               send_max_state_rise;
logic               send_4KB_state_reg;
logic               send_4KB_state_rise;
logic               data_decode_state_reg;
logic               data_decode_state;
logic               data_decode_state_rise;
logic  [31:0]       cur_src_addr_reg;
logic  [4:0]        orig_dest_addr_reg;
logic  [11:0]       cur_dest_addr_reg;
logic  [7:0]        bytes_to_16B;
logic  [3:0]        dw_to_16B;
logic  [3:0]        dw_to_16B_reg;
logic  [1:0]        first_dw_position_reg;
logic  [16:0]       desc_remain_lines_cntr;
logic               buffer_read_enable;
logic  [9:0]        ram_addr_reg;
logic               is_mwr64_reg;
logic  [1:0]        wr64_odd_addr;
logic  [10:0]        buffer_consume_cntr;
logic  [10:0]        buffer_available_sub;
logic               buffer_ok;
logic               raw_buffer_ok_reg;
logic               prefetch_data;
logic  [4:0]        wralign_data_nxt_state;
logic  [4:0]        wralign_data_state;
logic  [9:0]        ram_read_address_counter;
logic  [127:0]      raw_data_reg;
logic  [127:0]      wralign16B1_data;
logic  [127:0]      wralign16B2_data;
logic  [129:0]      wralign16B1_data_reg;
logic  [129:0]      wralign16B2_data_reg;
logic  [129:0]      wralign16B_data_reg;
logic  [129:0]      wralign16B_data;
logic  [129:0]      wralign_data_reg;
logic  [129:0]      wralign_data_reg2;
logic  [129:0]      aligned_data_muxout;
logic  [129:0]      align_buffer_datain_reg;
logic               pcie_address_b2_reg;
logic  [31:0]       raw_data_reg_dw0;
logic  [31:0]       raw_data_reg_dw1;
logic  [31:0]       raw_data_reg_dw2;
logic  [31:0]       raw_data_reg_dw3;
logic  [31:0]       raw_data_dw0;
logic  [31:0]       raw_data_dw1;
logic  [31:0]       raw_data_dw2;
logic  [31:0]       raw_data_dw3;
logic               data_is_aligned;
logic  [31:0]       wralign_dw0;
logic  [31:0]       wralign_dw1;
logic  [31:0]       wralign_dw2;
logic  [31:0]       wralign_dw3;
logic  [31:0]       wralign16B1_dw0;
logic  [31:0]       wralign16B1_dw1;
logic  [31:0]       wralign16B1_dw2;
logic  [31:0]       wralign16B1_dw3;
logic  [31:0]       wralign16B2_dw0;
logic  [31:0]       wralign16B2_dw1;
logic  [31:0]       wralign16B2_dw2;
logic  [31:0]       wralign16B2_dw3;
logic  [127:0]      wralign16B1;
logic  [127:0]      wralign16B2;
logic  [127:0]      wralign_data;
logic               wralign_buff_wren;
logic               wralign_data_wren_reg;
logic               wralign_data_wren_reg2;
logic               wralign_data_wren_reg3;
logic  [9:0]        aligned_wr_address_counter;
logic  [10:0]        tlpgen_buffer_limit_cntr;
logic  [12:0]       hdr_bytes_to_4KB;
logic  [12:0]       data_bytes_to_4KB;
logic  [63:0]       hdr_dest_addr_reg;
logic  [7:0]        hdr_bytes_to_16B;
logic  [10:0]       hdr_dw_to_4KB;
logic  [10:0]       data_dw_to_4KB;
logic  [7:0]        data_lines_to_4KB;
logic  [3:0]        hdr_dw_to_16B;
logic               hdr_mwr64;
logic  [10:0]       hdr_dw_to_4KB_reg;
logic  [10:0]       data_dw_to_4KB_reg;

logic  [3:0]        hdr_dw_to_16B_reg;

logic  [63:0]       hdr_dest_addr_adder_out;
logic  [9:0]        sent_dw;
logic  [9:0]        sent_dw_reg;
logic               hdr_mwr64_reg;
logic  [17:0]       hdr_remain_dw_reg;
logic               tlp_header_sent;
logic               remain_dw_sel;
logic  [6:0]        max_payload_dw;
logic               to_4KB_sel;
logic               to_16B_sel;
logic  [2:0]        sent_dw_sel_reg;
logic  [3:0]        align_header_nxt_state;
logic  [3:0]        align_header_state;
logic               descriptor_done;

logic               hdr_idle_state;
logic               hdr_sent_16B_state;
logic               hdr_sent_4KB_state;
logic               hdr_sent_max_state;
logic               header_pipe1_state;     

logic  [7:0]        cmd;
logic  [3:0]        lbe;
logic  [15:0]       requestor_id;
logic  [31:0]       tlp_hdr_dw0;
logic  [31:0]       tlp_hdr_dw1;
logic  [31:0]       tlp_hdr_dw2;
logic  [31:0]       tlp_hdr_dw3;
logic  [31:0]       tlp_immwr_hdr_dw0;
logic  [31:0]       tlp_immwr_hdr_dw1;
logic  [31:0]       tlp_immwr_hdr_dw2;
logic  [31:0]       tlp_immwr_hdr_dw3;

logic  [127:0]      tlp_header_reg;
logic               tlp_header_wrreq_reg;
logic               boundary_16B_span_2cycles;
logic               boundary_16B_span_2cycles_reg;
logic               prefetch_data_reg;
logic [3:0]         tlp_emp_sel;

logic [1:0]         tlp_empty_reg;
logic [4:0]         sent_max_payload_cntr;
logic               tx_eop_flag;  
logic               tx_eop_flag_reg;
logic               tx_sop_flag;
logic  [7:0]        hdr_desc_id_reg;
logic  [17:0]       desc_remain_dw_counter;
logic  [4:0]        max_pay_load_line_counter;
logic  [4:0]        to_4KB_line_counter;
logic  [14:0]       buffer_stop_limit_cntr;
logic               check_for_accessive_state;
logic               data_recover_state;
logic               accessive_data_supply;
logic               stop_data_at_4KB;
logic  [7:0]        last_tlp_dw_count;
logic  [5:0]        last_tlp_clk_counter;
logic               data_pause_state;
logic               post_16B_align_pipe_state;
logic               buffer_line_advance;
logic  [9:0]        desc_line_size_reg;

logic  [17:0]       desc_size;

logic  [17:0]       orig_desc_size_reg;
logic  [10:0]        saved_consume_ptr_reg;
logic               complete_desc_data_rdreq;


logic  [1:0]        hdr_mwr64_addr2;

logic  [9:0]        tlp_dw_size_with_header_reg;
logic  [9:0]        tlp_dw_size_with_header;

logic  [9:0]        desc_lines_release_reg;

logic  [3:0]        hdr_fifo_count;
logic  [138:0]      tlp_header_fifo_input;
logic               desc_size_gt_16B_boundary;
logic               desc_size_lt_16B_boundary;
logic               desc_size_lte_16B_boundary;
logic               exit_max;

logic  [10:0]          align_buffer_limit_counter;
logic  [10:0]          align_buffer_consume_counter;
logic                 align_buff_ok;
logic                 align_buff_ok_reg;
logic  [10:0]          align_buff_sub;
logic  [4:0]          tlp_hdr_fifo_usedw;
logic                 tlp_hdr_fifo_ok_reg;
logic                 tlp_hdr_fifo_ok;
logic  [9:0]          saved_ram_address_reg;
logic                 data_idle_state;
logic                 data_idle_state_reg;
logic                 data_idle_state_rise;
logic  [4:0]          first_available_dw;
logic  [4:0]          first_available_dw_reg;
logic  [7:0]          bytes_needed_to_16B;
logic  [3:0]          dw_needed_to_16B;
logic  [2:0]          dw_needed_to_16B_reg;
logic  [4:0]          available_dw_after_16B_allignment_reg;
logic                 dw_over_read;
logic                 dw_over_read_reg;
logic                 dw_under_read_reg;
logic                 dw_under_read;
logic                 read_more_dw;
logic                 desc_read_state_reg;
logic                 dw_start_at_register;
logic                 dw_start_at_buffer;

logic                 immediate_write_descriptor_reg;
logic                 send_immwr_state;
logic                 hdr_immwr_state;
logic                 immwr_tlp_empty;
logic                 tlp_empty; 
logic                 release_raw_buffer;
logic                 tlp_in_one_clk;   
logic  [4:0]          max_lines;
logic  [1:0]          first_tlp_lines_reg;
logic  [3:0]          first_tlp_dw_size;    



localparam           WRALIGN_DATA_IDLE                 = 5'h00;
localparam           WRALIGN_DATA_RD_DESC              = 5'h01;
localparam           WRALIGN_DATA_LATCH_DESC           = 5'h02;
localparam           WRALIGN_DATA_DESC_DECODE          = 5'h03;
localparam           WRALIGN_DATA_PREFETCH             = 5'h04;
localparam           WRALIGN_DATA_SEND_16B_BOUNDARY    = 5'h05;
localparam           WRALIGN_DATA_SEND_16B_BOUNDARY2   = 5'h06;
localparam           WRALIGN_DATA_SEND_LAST            = 5'h07;
localparam           WRALIGN_DATA_WAIT                 = 5'h08;
localparam           WRALIGN_DATA_SEND_MAX             = 5'h09;
localparam           WRALIGN_DATA_PAUSE                = 5'h0A;
localparam           WRALIGN_DATA_CHECK_ACCESSIVE_DATA = 5'h0B;
localparam           WRALIGN_DATA_ACCESSIVE_RECOVER    = 5'h0C;
localparam           WRALIGN_DATA_SEND_4KB_BOUNDARY    = 5'h0D;
localparam           WRALIGN_DATA_16B_PIPE             = 5'h0E;
localparam           WRALIGN_DATA_LINES_CALC_PIPE      = 5'h0F;
localparam           WRALIGN_DATA_16B_PIPE2            = 5'h10;
localparam           WRALIGN_DATA_BUFF_FULL            = 5'h11;
localparam           WRALIGN_DATA_SEND_IMMWR           = 5'h12;       
localparam           WRALIGN_DATA_POST_4K_PIPE         = 5'h14; 



localparam           ALIGN_HDR_IDLE                    = 4'h0;
localparam           ALIGN_HDR_LATCH                   = 4'h1;
localparam           ALIGN_HDR_DECODE                  = 4'h2;
localparam           ALIGN_HDR_4KB                     = 4'h3;
localparam           ALIGN_HDR_MAX                     = 4'h4;
localparam           ALIGN_HDR_16B                     = 4'h5;
localparam           ALIGN_HDR_PIPE1                   = 4'h6;
localparam           ALIGN_HDR_PIPE2                   = 4'h7;
localparam           ALIGN_HDR_PIPE3                   = 4'h8;
localparam           ALIGN_HDR_IMM_WR                  = 4'h9;

/// Max Payload

always_comb
begin
   case(DevCsr_i[7:5])
      3'b000  : max_payload_dw = 7'd32;  //128b
      3'b001  : max_payload_dw = 7'd64; // 256B
      default : max_payload_dw = 7'd128;  //512b
   endcase
end




 assign descriptor_available = DescFifoCount_i != 0;
 assign all_desc_payload_available = DescDataCompleteFifoCount_i != 0;

 /// reading and latching descriptor fields
always @ (posedge Clk_i)
begin
  if(desc_read_state)
   begin
    cur_src_addr_reg  <= DescFifo_i[31:0];
    orig_dest_addr_reg <= DescFifo_i[68:64];
    immediate_write_descriptor_reg <=  1'b0; 
   end
end


always @ (posedge Clk_i)
begin
  if(desc_read_state)
    cur_dest_addr_reg[11:0] <= DescFifo_i[75:64];
  else if(send_16B_state)  /// reset to a 16B boundary
    cur_dest_addr_reg <= cur_dest_addr_reg + {dw_to_16B_reg[3:0], 2'b00};
  else if(send_max_state_rise | send_max_state & max_pay_load_line_counter == 0)
     cur_dest_addr_reg <= cur_dest_addr_reg + {max_payload_dw, 2'b00};
  else if(send_4KB_state_rise)
     cur_dest_addr_reg <= cur_dest_addr_reg + {data_dw_to_4KB_reg, 2'b00};
end

 assign bytes_to_16B = (cur_dest_addr_reg[3:0] == 4'h0)? 8'h10 : (5'h10 - cur_dest_addr_reg[3:0]);
 assign dw_to_16B   = bytes_to_16B[4:2];
always @ (posedge Clk_i)
  data_bytes_to_4KB = (cur_dest_addr_reg[11:0] == 12'h0)? 13'h1000 : (13'h1000 - cur_dest_addr_reg[11:0]);
 
 assign data_dw_to_4KB   = data_bytes_to_4KB[12:2];
 assign data_lines_to_4KB = data_dw_to_4KB[10:2];

 assign stop_data_at_4KB = (data_dw_to_4KB < max_payload_dw) & (desc_remain_dw_counter > data_dw_to_4KB);


 always @ (posedge Clk_i)
   begin
      dw_to_16B_reg <= dw_to_16B;
      data_dw_to_4KB_reg <=  data_dw_to_4KB;
   end

always @ (posedge Clk_i)
begin
  if(desc_read_state)
    first_dw_position_reg[1:0] <= DescFifo_i[3:2];
  else if(send_16B_state & ~boundary_16B_span_2cycles_reg | send_16B_state_2)
     first_dw_position_reg[1:0] <= first_dw_position_reg + dw_to_16B_reg;
 end

assign buffer_line_advance = (send_16B_state & ~prefetch_data_reg | send_last_state |  send_max_state & max_pay_load_line_counter != 1 | send_4KB_state & to_4KB_line_counter != 1); /// buff_enable but not prefetch state
/// remaining lines counter for a descriptor
always @ (posedge Clk_i)
begin
  if(desc_read_state)
    desc_remain_lines_cntr[16:0] <= DescFifo_i[48:32];
  else if(accessive_data_supply)  // back-up
    desc_remain_lines_cntr <= desc_remain_lines_cntr + 1;
  else if(buffer_line_advance)
    desc_remain_lines_cntr <= desc_remain_lines_cntr - 1;
end

/// # lines for first 16B allign
assign first_tlp_dw_size =  (desc_remain_dw_counter <= dw_to_16B_reg)? desc_remain_dw_counter[3:0] : dw_to_16B_reg[3:0];
always @ (posedge Clk_i)
    first_tlp_lines_reg <= (~is_mwr64_reg & cur_dest_addr_reg[2] & first_tlp_dw_size == 4'h1)? 2'h1 : 2'h2;
    
always @ (posedge Clk_i)
  if(desc_read_state)
    is_mwr64_reg <= DescFifo_i[127:96] != 32'h0 ;


assign wr64_odd_addr = {is_mwr64_reg,cur_dest_addr_reg[2]};


/// buffer credit
 always @(posedge Clk_i)
      begin
        if(Srst_i)
          buffer_consume_cntr <= 11'h40;
        else if(desc_read_state & ~DescFifo_i[159]) // reload saved pointer value
          buffer_consume_cntr <= saved_consume_ptr_reg;
        else if (buffer_read_enable)
          buffer_consume_cntr <= buffer_consume_cntr + 11'h1;
      end

assign buffer_available_sub = RawBufferLimit_i - buffer_consume_cntr; // 2's complement

assign buffer_ok = buffer_available_sub <= 1024;

   always @ (posedge Clk_i)
     begin
       raw_buffer_ok_reg <= buffer_ok;
       boundary_16B_span_2cycles_reg <=   boundary_16B_span_2cycles;
       prefetch_data_reg <= prefetch_data;
       send_max_state_reg <= send_max_state;
       send_4KB_state_reg <= send_4KB_state;
       data_decode_state_reg <= data_decode_state;
     end

/// state machine to read the raw buffer and realign and store in another buffer
//  and ready to transmit, from true table


assign boundary_16B_span_2cycles =      
                                     ~is_mwr64_reg &  cur_dest_addr_reg[2] & dw_to_16B > 1 & first_tlp_lines_reg > 1;
                                     
                                     
//always @ (posedge Clk_i)
//  begin
//       prefetch_data  <= first_available_dw[4:0] < dw_needed_to_16B;
//  end     

assign       prefetch_data = 1'b1; /// always prefetch                         
                                     

//assign prefetch_data =    orig_dest_addr_reg[3:0] == 4'h0 & first_dw_position_reg[1:0] != 0;

/// there are cases that the first 16B boundary requires 2 256-data slices written into aligned buffer


 assign send_max_state_rise = send_max_state & ~send_max_state_reg;
 assign send_4KB_state_rise = send_4KB_state & ~send_4KB_state_reg;
 assign data_decode_state_rise = data_decode_state & ~data_decode_state_reg;
 assign  desc_size[17:0] =   DescFifo_i[145:128];

 /// store origninal desc size
   always @(posedge Clk_i)
     if(Srst_i)
       orig_desc_size_reg  <= 18'h0;
     else if(desc_read_state)
          orig_desc_size_reg  <= desc_size[17:0];

 

   always @(posedge Clk_i)
      begin
        if(desc_read_state)
          desc_remain_dw_counter  <= desc_size;           
        else if(send_16B_state & desc_remain_dw_counter < dw_to_16B_reg)
          desc_remain_dw_counter  <= 12'h0;
        else if(send_16B_state)
          desc_remain_dw_counter <= desc_remain_dw_counter - dw_to_16B_reg;
        else if(send_max_state & max_pay_load_line_counter == 0)
          desc_remain_dw_counter <= desc_remain_dw_counter - max_payload_dw;
        else if(send_4KB_state_rise)
          desc_remain_dw_counter <= desc_remain_dw_counter - data_dw_to_4KB_reg;
      end

   always @(posedge Clk_i)
      begin
        if(Srst_i)
          to_4KB_line_counter <= 5'h0;
       else if(send_4KB_state_rise)
          to_4KB_line_counter  <= data_lines_to_4KB - 1;
        else if(send_4KB_state)
          to_4KB_line_counter  <= to_4KB_line_counter - 4'h1;
      end


    always @(posedge Clk_i)
      begin
        if(Srst_i)
          max_pay_load_line_counter <= 5'h0;
       else if(send_max_state_rise | send_max_state & max_pay_load_line_counter == 0)
          max_pay_load_line_counter  <= max_payload_dw[6:2] -1 ;
        else if(send_max_state)
          max_pay_load_line_counter  <= max_pay_load_line_counter - 1;
      end

 /// last cycle count
 // the number of clocks the last tlp of a descriptor needed

 always @(posedge Clk_i)
      last_tlp_dw_count <= desc_remain_dw_counter[7:0]; /// add 4/3 DW header of TLP

 always @(posedge Clk_i)
  begin
    if(data_pause_state | post_16B_align_pipe_state | check_for_accessive_state | data_decode_state_rise | data_recover_state )
      last_tlp_clk_counter <= (last_tlp_dw_count[1:0] == 2'h0)? last_tlp_dw_count[7:2] : last_tlp_dw_count[7:2] + 1'b1;
    else if (send_last_state)
      last_tlp_clk_counter <= last_tlp_clk_counter - 1'b1;
   end
 always @(posedge Clk_i)
   begin
     desc_size_gt_16B_boundary <= orig_desc_size_reg  > dw_to_16B_reg;
     desc_size_lt_16B_boundary <= orig_desc_size_reg  < dw_to_16B_reg;
     desc_size_lte_16B_boundary <= orig_desc_size_reg  <= dw_to_16B_reg;
   end



  /// exit max state to go to send last or 4KB boundary

 assign exit_max = ((data_dw_to_4KB_reg < max_payload_dw) & max_pay_load_line_counter == 1) |   // may be able to register part of this logic for fmax
                    ((desc_remain_dw_counter < max_payload_dw) & max_pay_load_line_counter == 1);

  always @(posedge Clk_i)
      begin
        if(Srst_i)
          wralign_data_state <= 5'h0;
        else
          wralign_data_state <= wralign_data_nxt_state;
      end


  always_comb
  begin
    case(wralign_data_state)
        WRALIGN_DATA_IDLE:
          if(descriptor_available & hdr_idle_state & tlp_hdr_fifo_ok_reg & align_buff_ok_reg) // wait for the hdr sm to catch up when small payload
           wralign_data_nxt_state <= WRALIGN_DATA_RD_DESC;
        else
           wralign_data_nxt_state <= WRALIGN_DATA_IDLE;

      WRALIGN_DATA_RD_DESC:
        if(desc_size[11:0] < max_payload_dw)
           wralign_data_nxt_state <= WRALIGN_DATA_LINES_CALC_PIPE; /// needed for Fmax
        else
          wralign_data_nxt_state <= WRALIGN_DATA_DESC_DECODE;

      WRALIGN_DATA_LINES_CALC_PIPE:
        wralign_data_nxt_state <= WRALIGN_DATA_DESC_DECODE;

      WRALIGN_DATA_DESC_DECODE :
      if (immediate_write_descriptor_reg)
        wralign_data_nxt_state <= WRALIGN_DATA_SEND_IMMWR;
      else if (prefetch_data  & (raw_buffer_ok_reg | all_desc_payload_available))
            wralign_data_nxt_state <= WRALIGN_DATA_PREFETCH;  ///
       else  if((raw_buffer_ok_reg | all_desc_payload_available != 0) & cur_dest_addr_reg[3:0] != 0) // address not aligned and do not need to prefetch, send to 128-bit address
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_16B_BOUNDARY;
       else if(stop_data_at_4KB & (raw_buffer_ok_reg | all_desc_payload_available != 0))
            wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
       else if((raw_buffer_ok_reg | all_desc_payload_available != 0) & (desc_remain_dw_counter >= max_payload_dw))
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;
        else if(raw_buffer_ok_reg  | all_desc_payload_available) // data already aligned to 256-bit and no prefetch needed
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;
        else
           wralign_data_nxt_state <= WRALIGN_DATA_DESC_DECODE;

       WRALIGN_DATA_PREFETCH:
         if(cur_dest_addr_reg[3:0] != 0)
             wralign_data_nxt_state <= WRALIGN_DATA_SEND_16B_BOUNDARY;
        else if(stop_data_at_4KB )
            wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
        else if(desc_remain_dw_counter >= max_payload_dw)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;
        else
            wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;

       WRALIGN_DATA_SEND_IMMWR:
         wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
       
       WRALIGN_DATA_SEND_16B_BOUNDARY:
       //  if(desc_remain_lines_cntr == 1)
        //   wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
          if(boundary_16B_span_2cycles_reg)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_16B_BOUNDARY2;
         else
            wralign_data_nxt_state <= WRALIGN_DATA_16B_PIPE2;


      WRALIGN_DATA_16B_PIPE2:
         if((desc_remain_lines_cntr == 0 & ~desc_size_gt_16B_boundary) | desc_size_lt_16B_boundary)
           wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_CHECK_ACCESSIVE_DATA;

      WRALIGN_DATA_SEND_16B_BOUNDARY2:
        if((desc_remain_lines_cntr == 0 & ~desc_size_gt_16B_boundary)| desc_size_lte_16B_boundary)
         wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
        else
         wralign_data_nxt_state <= WRALIGN_DATA_16B_PIPE;  // pipe for fmax on arithmetic calcuation

      WRALIGN_DATA_16B_PIPE:
       if(stop_data_at_4KB)
         wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
       else if(desc_remain_dw_counter >= max_payload_dw)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;
       else
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;


       WRALIGN_DATA_CHECK_ACCESSIVE_DATA:
          if(desc_remain_dw_counter == 0)
            wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
          else if(accessive_data_supply)
            wralign_data_nxt_state <= WRALIGN_DATA_ACCESSIVE_RECOVER;
         else if(stop_data_at_4KB)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
         else if(desc_remain_dw_counter >= max_payload_dw)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;


       WRALIGN_DATA_ACCESSIVE_RECOVER:
         if(desc_remain_dw_counter == 0)
           wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
         else if(stop_data_at_4KB)
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
        else if(desc_remain_dw_counter >= max_payload_dw)
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;

       WRALIGN_DATA_SEND_4KB_BOUNDARY:
          if((to_4KB_line_counter == 1 | data_lines_to_4KB == 1) & desc_remain_dw_counter == 0)
              wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
         else if(to_4KB_line_counter == 1 | data_lines_to_4KB == 1)
            wralign_data_nxt_state <= WRALIGN_DATA_POST_4K_PIPE;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
      
      WRALIGN_DATA_POST_4K_PIPE:  /// pipe wait for dest address reg to be updated
          wralign_data_nxt_state <= WRALIGN_DATA_PAUSE;  

       WRALIGN_DATA_SEND_MAX:
         if (max_pay_load_line_counter == 4'h1 & (desc_remain_dw_counter == 18'h0)) /// MPS measured in lines including header and holes
          wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
        else if((~align_buff_ok_reg | ~raw_buffer_ok_reg) & max_pay_load_line_counter == 1)
           wralign_data_nxt_state <= WRALIGN_DATA_BUFF_FULL;
         else if(exit_max)
           wralign_data_nxt_state <= WRALIGN_DATA_PAUSE;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;

       WRALIGN_DATA_BUFF_FULL:
       if(align_buff_ok_reg & (raw_buffer_ok_reg | all_desc_payload_available))      
       // if(align_buff_ok_reg)
           wralign_data_nxt_state <= WRALIGN_DATA_PAUSE;
         else
           wralign_data_nxt_state <= WRALIGN_DATA_BUFF_FULL;

       WRALIGN_DATA_PAUSE:
        if((desc_remain_dw_counter < max_payload_dw) & (desc_remain_dw_counter <= data_dw_to_4KB))
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;
        else if(stop_data_at_4KB)
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_4KB_BOUNDARY;
        else
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_MAX;

       WRALIGN_DATA_SEND_LAST:  // send the rest
       if(last_tlp_clk_counter == 1)
          wralign_data_nxt_state <= WRALIGN_DATA_IDLE;
       else if(~raw_buffer_ok_reg & ~all_desc_payload_available)  /// data payload is low and not all data is there
          wralign_data_nxt_state <= WRALIGN_DATA_WAIT;
       else
          wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;

      WRALIGN_DATA_WAIT:
       if (raw_buffer_ok_reg | all_desc_payload_available)
         wralign_data_nxt_state <= WRALIGN_DATA_SEND_LAST;
       else
         wralign_data_nxt_state <= WRALIGN_DATA_WAIT;

        default:
          wralign_data_nxt_state <= WRALIGN_DATA_IDLE;

   endcase
end

  assign data_idle_state       = (wralign_data_state == WRALIGN_DATA_IDLE);
  assign desc_read_state       = (wralign_data_state == WRALIGN_DATA_IDLE) & (descriptor_available & hdr_idle_state & tlp_hdr_fifo_ok_reg & align_buff_ok_reg); /// read one clock ahead
  assign buffer_prefetch_state = (wralign_data_state == WRALIGN_DATA_PREFETCH);
  assign data_decode_state     = (wralign_data_state == WRALIGN_DATA_DESC_DECODE);
  assign send_immwr_state      = (wralign_data_state == WRALIGN_DATA_SEND_IMMWR);
  assign send_16B_state        = (wralign_data_state == WRALIGN_DATA_SEND_16B_BOUNDARY);
  assign send_16B_state_2      = (wralign_data_state == WRALIGN_DATA_SEND_16B_BOUNDARY2);
  assign send_last_state       = (wralign_data_state == WRALIGN_DATA_SEND_LAST);
  assign send_max_state        = (wralign_data_state == WRALIGN_DATA_SEND_MAX);
  assign send_4KB_state        = (wralign_data_state == WRALIGN_DATA_SEND_4KB_BOUNDARY);
  assign data_pause_state      = (wralign_data_state == WRALIGN_DATA_PAUSE);
  assign check_for_accessive_state = (wralign_data_state == WRALIGN_DATA_CHECK_ACCESSIVE_DATA);
  assign data_recover_state = (wralign_data_state == WRALIGN_DATA_ACCESSIVE_RECOVER);
  assign post_16B_align_pipe_state = (wralign_data_state == WRALIGN_DATA_16B_PIPE);
  assign DescFifoRdreq_o       = desc_read_state;

  assign DescDataCompleteFifoRdReq_o = complete_desc_data_rdreq;



/// counter to count total lines to max payload sent used to generate sop,eop flags
always @ (posedge Clk_i)
begin
  if(Srst_i)
    sent_max_payload_cntr[4:0] <= 5'h0;
  else if(sent_max_payload_cntr == (max_payload_dw[6:2]) | desc_read_state)
    sent_max_payload_cntr[4:0] <= 5'h0;
  else if(send_last_state | send_max_state)
     sent_max_payload_cntr <= sent_max_payload_cntr + 1;
 end

assign tx_eop_flag = (send_max_state & max_pay_load_line_counter == 5'h1) |
                     (send_4KB_state & (to_4KB_line_counter == 5'h1 | data_lines_to_4KB == 5'h1)) |
                     (send_last_state & last_tlp_clk_counter == 5'h1) |
                     (send_16B_state_2) |
                     (send_16B_state & ~boundary_16B_span_2cycles_reg);
                    
assign tx_sop_flag = (sent_max_payload_cntr == 5'h0 &  (send_last_state | send_max_state)) |
                     (send_4KB_state_rise) |
                     (send_16B_state);

always @(posedge Clk_i)
   tx_eop_flag_reg <= tx_eop_flag;                    

/// Buffer address pointer

always @ (posedge Clk_i)
 begin
  if(data_decode_state)
    saved_ram_address_reg <= ram_addr_reg;
 end


assign RawRamAddress_o[9:0] = (buffer_read_enable)? (ram_addr_reg + 1'b1) : ram_addr_reg;
always @ (posedge Clk_i)
begin
  if(Srst_i)
    ram_addr_reg[9:0] <= 10'h0;
  else if(desc_read_state)
     ram_addr_reg[9:0] <= desc_line_size_reg;
   else if(accessive_data_supply)
     ram_addr_reg <= saved_ram_address_reg;
  //else if(buffer_stop_limit_cntr != 1)
    else
     ram_addr_reg <= RawRamAddress_o;

 end

assign buffer_read_enable = (read_more_dw |
                             send_last_state  |
                             send_max_state | //& max_pay_load_line_counter != 1|
                             send_4KB_state  |  //& to_4KB_line_counter != 1 |
                             buffer_prefetch_state
                             );


always @(posedge Clk_i)     /// pipeline registers
 begin
   desc_read_state_reg     <= desc_read_state;
   send_16B_state_2_reg    <= send_16B_state_2;
   send_16B_state_reg      <= send_16B_state;
   send_16B_state_2_reg2    <= send_16B_state_2_reg;
   send_16B_state_reg2      <= send_16B_state_reg;
   data_idle_state_reg      <= data_idle_state;
 end
//assign RawBufferReadReq_o = buffer_line_advance_reg & ~accessive_data_supply;

// Data path
always @ (posedge Clk_i)
begin
  if(buffer_read_enable)
     raw_data_reg <= RawRamData_i;
 end

always @ (posedge Clk_i)
begin
 if(Srst_i)
   pcie_address_b2_reg <= 1'b0;
 else if(desc_read_state)
    pcie_address_b2_reg <= DescFifo_i[66];
 else if(send_16B_state & ~boundary_16B_span_2cycles_reg | send_16B_state_2)
    pcie_address_b2_reg <= 1'b0;
 end

assign raw_data_reg_dw0 = raw_data_reg[31:0];
assign raw_data_reg_dw1 = raw_data_reg[63:32];
assign raw_data_reg_dw2 = raw_data_reg[95:64];
assign raw_data_reg_dw3 = raw_data_reg[127:96];

assign raw_data_dw0 = RawRamData_i[31:0];
assign raw_data_dw1 = RawRamData_i[63:32];
assign raw_data_dw2 = RawRamData_i[95:64];
assign raw_data_dw3 = RawRamData_i[127:96];


/// muxing logic for the first clock of the aligned TLP
always_comb
    begin
     case({is_mwr64_reg, pcie_address_b2_reg} )            ////// address bit 2 is always OFF
      2'b01: // 3dw-hdr and address bit2 on
        begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw2;
                wralign16B1_dw1    = raw_data_reg_dw3;
                wralign16B1_dw2    = raw_data_reg_dw0;
                wralign16B1_dw3    = raw_data_reg_dw1;
              end

            2'h2 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw3;
                wralign16B1_dw1    = raw_data_reg_dw0;
                wralign16B1_dw2    = raw_data_reg_dw1;
                wralign16B1_dw3    = raw_data_reg_dw2;
              end

            2'h3 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw0;
                wralign16B1_dw1    = raw_data_reg_dw1;
                wralign16B1_dw2    = raw_data_reg_dw1;
                wralign16B1_dw3    = raw_data_reg_dw3;
              end

            default:
              begin
                wralign16B1_dw0    = raw_data_reg_dw1;
                wralign16B1_dw1    = raw_data_reg_dw2;
                wralign16B1_dw2    = raw_data_reg_dw3;
                wralign16B1_dw3    = raw_data_reg_dw0;
              end
         endcase
        end
     
      2'b11: // 4dw-hdr and address bit2 on
        begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B1_dw0    = raw_data_dw0;
                wralign16B1_dw1    = raw_data_reg_dw1;
                wralign16B1_dw2    = raw_data_reg_dw2;
                wralign16B1_dw3    = raw_data_reg_dw3;
              end

            2'h2 :    //
              begin
                wralign16B1_dw0    = raw_data_reg_dw1;
                wralign16B1_dw1    = raw_data_reg_dw2;
                wralign16B1_dw2    = raw_data_reg_dw3;
                wralign16B1_dw3    = raw_data_dw0;
              end

            2'h3 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw2;
                wralign16B1_dw1    = raw_data_reg_dw3;
                wralign16B1_dw2    = raw_data_dw0;
                wralign16B1_dw3    = raw_data_dw1;
              end

           default :  // 3h0
              begin
                wralign16B1_dw0    = raw_data_reg_dw3;
                wralign16B1_dw1    = raw_data_reg_dw0;
                wralign16B1_dw2    = raw_data_reg_dw1;
                wralign16B1_dw3    = raw_data_reg_dw2;
              end
     endcase
  end
       default: //address bit2 off
         begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw1;
                wralign16B1_dw1    = raw_data_reg_dw2;
                wralign16B1_dw2    = raw_data_reg_dw3;
                wralign16B1_dw3    = raw_data_dw0;
              end

            2'h2 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw2;
                wralign16B1_dw1    = raw_data_reg_dw3;
                wralign16B1_dw2    = raw_data_dw0;
                wralign16B1_dw3    = raw_data_dw1;
              end

            2'h3 :
              begin
                wralign16B1_dw0    = raw_data_reg_dw3;
                wralign16B1_dw1    = raw_data_dw0;
                wralign16B1_dw2    = raw_data_dw1;
                wralign16B1_dw3    = raw_data_dw2;
              end


            default: // 3h0
              begin
                wralign16B1_dw0    = raw_data_reg_dw0;
                wralign16B1_dw1    = raw_data_reg_dw1;
                wralign16B1_dw2    = raw_data_reg_dw2;
                wralign16B1_dw3    = raw_data_reg_dw3;
              end
        endcase
      end
     endcase
    end


/// muxing logic for the second clock of the aligned TLP
always_comb
    begin
     case({is_mwr64_reg, pcie_address_b2_reg} )
      2'b01: // 3dw-hdr and address bit2 on
        begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw2;
                wralign16B2_dw1    = raw_data_reg_dw3;
                wralign16B2_dw2    = raw_data_dw0;
                 wralign16B2_dw3    = raw_data_dw1;
              end

            2'h2 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw3;
                wralign16B2_dw1    = raw_data_dw0;
                wralign16B2_dw2    = raw_data_dw1;
                wralign16B2_dw3    = raw_data_dw2;
              end

            2'h3 :
              begin
                wralign16B2_dw0    = raw_data_dw0;
                wralign16B2_dw1    = raw_data_dw1;
                wralign16B2_dw2    = raw_data_dw2;
                wralign16B2_dw3    = raw_data_dw3;
              end

            default:
              begin
                wralign16B2_dw0    = raw_data_reg_dw1;
                wralign16B2_dw1    = raw_data_reg_dw2;
                wralign16B2_dw2    = raw_data_reg_dw3;
                wralign16B2_dw3    = raw_data_dw0;
              end
         endcase
        end
    
      2'b11: // 4dw-hdr and address bit2 on
        begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw0;
                wralign16B2_dw1    = raw_data_reg_dw1;
                wralign16B2_dw2    = raw_data_reg_dw2;
                wralign16B2_dw3    = raw_data_reg_dw3;
              end

            2'h2 :    //
              begin
                wralign16B2_dw0    = raw_data_reg_dw0;
                wralign16B2_dw1    = raw_data_reg_dw2;
                wralign16B2_dw2    = raw_data_reg_dw3;
                wralign16B2_dw3    = raw_data_dw0;
              end

            2'h3 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw0;
                wralign16B2_dw1    = raw_data_reg_dw3;
                wralign16B2_dw2    = raw_data_dw0;
                wralign16B2_dw3    = raw_data_dw1;
              end

           default :  // 3h0
              begin
                wralign16B2_dw0    = raw_data_reg_dw0;
                wralign16B2_dw1    = raw_data_reg_dw0;
                wralign16B2_dw2    = raw_data_reg_dw1;
                wralign16B2_dw3    = raw_data_reg_dw2;
              end
     endcase
  end
       default: /// 2'b00: //  address bit2 off
        begin
          case (first_dw_position_reg[1:0])
             2'h1 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw1;
                wralign16B2_dw1    = raw_data_reg_dw2;
                wralign16B2_dw2    = raw_data_reg_dw3;
                wralign16B2_dw3    = raw_data_dw0;
              end

            2'h2 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw2;
                wralign16B2_dw1    = raw_data_reg_dw3;
                wralign16B2_dw2    = raw_data_dw0;
                wralign16B2_dw3    = raw_data_dw1;
              end

            2'h3 :
              begin
                wralign16B2_dw0    = raw_data_reg_dw3;
                wralign16B2_dw1    = raw_data_dw0;
                wralign16B2_dw2    = raw_data_dw1;
                wralign16B2_dw3    = raw_data_dw2;
              end

            default: // 3h0
              begin
                wralign16B2_dw0    = raw_data_reg_dw0;
                wralign16B2_dw1    = raw_data_reg_dw1;
                wralign16B2_dw2    = raw_data_reg_dw2;
                wralign16B2_dw3    = raw_data_reg_dw3;
              end
        endcase
      end
    endcase
   end

assign wralign16B1_data = {wralign16B1_dw3, wralign16B1_dw2, wralign16B1_dw1, wralign16B1_dw0};
assign wralign16B2_data = {wralign16B2_dw3, wralign16B2_dw2, wralign16B2_dw1, wralign16B2_dw0};


///// ***********************************************************************/
//// Muxing logic for the main data path after alignment to 16B PCIe address
//*****************************************************************************/

/// Calculating the first DW available afer the 16B alignment TLP has been sent

/// First available DW based on the source address
always_comb
    case(cur_src_addr_reg[3:0])   /// with additional 4 dw prefetch upto 7 available
          4'h04: first_available_dw[4:0] = 3'h3;
          4'h08: first_available_dw[4:0] = 3'h2;
          4'h0C: first_available_dw[4:0] = 3'h1;
          default: first_available_dw[4:0] = 3'h4;
    endcase

always @ (posedge Clk_i)
  begin
     if(desc_read_state_reg)
       first_available_dw_reg[4:0]  <= first_available_dw[4:0];
     else if(buffer_prefetch_state)
       first_available_dw_reg[4:0]  <= first_available_dw[4:0] + 4;
  end

 assign bytes_needed_to_16B = (orig_dest_addr_reg[3:0] == 4'h0)? 8'h10 : (8'h10 - orig_dest_addr_reg[3:0]);
 assign dw_needed_to_16B   = bytes_needed_to_16B[5:2];

 always @ (posedge Clk_i)
   dw_needed_to_16B_reg[2:0] <= dw_needed_to_16B[2:0];

always @ (posedge Clk_i)
  begin
       available_dw_after_16B_allignment_reg[4:0]  <= first_available_dw_reg[4:0] - dw_needed_to_16B_reg;
  end



 // assign dw_over_read = (available_dw_after_16B_allignment_reg == 4'd7);
                      
 assign dw_over_read = 1'b0;                           

assign dw_under_read =  (available_dw_after_16B_allignment_reg == 4'd0) |
                       (available_dw_after_16B_allignment_reg == 4'd1) |
                       (available_dw_after_16B_allignment_reg == 4'd2) |
                       (available_dw_after_16B_allignment_reg == 4'd3) |
                       (available_dw_after_16B_allignment_reg == 4'd4);


always @ (posedge Clk_i)
  begin
       dw_over_read_reg  <=dw_over_read;
       dw_under_read_reg <= dw_under_read;
  end

assign read_more_dw = dw_under_read & (check_for_accessive_state | send_16B_state_2);
assign accessive_data_supply = dw_over_read_reg & (check_for_accessive_state | send_16B_state_2);


//assign dw_start_at_buffer =    
//                               (available_dw_after_16B_allignment_reg == 4'd8) |
//                               (orig_dest_addr_reg == 4'h0 & (first_dw_position_reg <= 2'h4));

 assign dw_start_at_buffer = 1'b0;

always_comb
    begin
      case (dw_start_at_buffer)
        1'b1:   /// start from buffer
              begin
                 case (first_dw_position_reg[1:0])
                    2'h1 :
                     begin
                       wralign_dw0    = raw_data_dw1;
                       wralign_dw1    = raw_data_dw2;
                       wralign_dw2    = raw_data_dw3;
                       wralign_dw3    = raw_data_reg_dw0;
                     end

                   2'h2 :
                     begin
                       wralign_dw0    = raw_data_dw2;
                       wralign_dw1    = raw_data_dw3;
                       wralign_dw2    = raw_data_reg_dw0;
                       wralign_dw3    = raw_data_reg_dw1;
                     end

                   2'h3 :
                     begin
                       wralign_dw0    = raw_data_dw3;
                       wralign_dw1    = raw_data_reg_dw0;
                       wralign_dw2    = raw_data_reg_dw1;
                       wralign_dw3    = raw_data_reg_dw2;
                     end

                   default: // 3h0
                     begin
                       wralign_dw0    = raw_data_dw0;
                       wralign_dw1    = raw_data_dw1;
                       wralign_dw2    = raw_data_dw2;
                       wralign_dw3    = raw_data_dw3;
                     end
                 endcase
              end

        default:  // start at register
              begin
                 case (first_dw_position_reg[1:0])
                    2'h1 :
                     begin
                       wralign_dw0    = raw_data_reg_dw1;
                       wralign_dw1    = raw_data_reg_dw2;
                       wralign_dw2    = raw_data_reg_dw3;
                       wralign_dw3    = raw_data_dw0;
                     end

                   2'h2 :
                     begin
                       wralign_dw0    = raw_data_reg_dw2;
                       wralign_dw1    = raw_data_reg_dw3;
                       wralign_dw2    = raw_data_dw0;
                       wralign_dw3    = raw_data_dw1;
                     end

                   2'h3 :
                     begin
                       wralign_dw0    = raw_data_reg_dw3;
                       wralign_dw1    = raw_data_dw0;
                       wralign_dw2    = raw_data_dw1;
                       wralign_dw3    = raw_data_dw2;
                     end

                   default: // 3h0
                     begin
                       wralign_dw0    = raw_data_reg_dw0;
                       wralign_dw1    = raw_data_reg_dw1;
                       wralign_dw2    = raw_data_reg_dw2;
                       wralign_dw3    = raw_data_reg_dw3;
                     end
                 endcase
              end
      endcase
    end

/// the main stream data path pipeline

 assign wralign_data[127:0]   = {wralign_dw3, wralign_dw2, wralign_dw1, wralign_dw0};
 always @ (posedge Clk_i)
     begin
       wralign_data_reg <= {tx_eop_flag, tx_sop_flag, wralign_data};
     end

 always @ (posedge Clk_i)
     begin
        wralign_data_reg2 <= immediate_write_descriptor_reg? 130'h0 : wralign_data_reg; 
     end     

/// Muxing the 16B TLP and main stream TLPs

assign aligned_data_muxout[129:0] = (send_16B_state_2_reg2 | send_16B_state_reg2)?  wralign16B_data_reg :  wralign_data_reg2;

always @ (posedge Clk_i)
   align_buffer_datain_reg[129:0] <= aligned_data_muxout;

  //// Align buffer protection logic

    always @ (posedge Clk_i)
     begin
        if(Srst_i)
          align_buffer_limit_counter <= 11'h3BF;  // leave some margin
        else if(TlpGenCreditUp_i)
          align_buffer_limit_counter <= align_buffer_limit_counter + TlpGenCred_i;
     end

     always @ (posedge Clk_i)
     begin
        if(Srst_i)
          align_buffer_consume_counter <= 11'h0;
        else if(wralign_data_wren_reg3)
          align_buffer_consume_counter <= align_buffer_consume_counter + 11'h1;
     end

     assign align_buff_sub = align_buffer_limit_counter - align_buffer_consume_counter;

     assign align_buff_ok = align_buff_sub <= 11'd1024;

     always @ (posedge Clk_i)
         align_buff_ok_reg <= align_buff_ok;

  ///// end of Align buffer protection logic


  assign wralign_buff_wren = send_16B_state |send_16B_state_2|  send_last_state |  send_max_state | send_4KB_state  | send_immwr_state;


   always @ (posedge Clk_i)
     begin
         wralign16B1_data_reg <= {tx_eop_flag, tx_sop_flag, wralign16B1_data};
         wralign16B2_data_reg <= {tx_eop_flag, tx_sop_flag, wralign16B2_data};
     end

   always @ (posedge Clk_i)
   begin
        if(Srst_i)
         begin
           wralign_data_wren_reg <= 1'b0;
       wralign_data_wren_reg2 <= 1'b0;
       wralign_data_wren_reg3 <= 1'b0;
     end
     begin
       wralign_data_wren_reg <= wralign_buff_wren;
       wralign_data_wren_reg2 <= wralign_data_wren_reg;
       wralign_data_wren_reg3 <= wralign_data_wren_reg2;
     end
   end

/// Muxing the first and second aligned TLP data phases

assign wralign16B_data = send_16B_state_2_reg? wralign16B2_data_reg : wralign16B1_data_reg;

always @ (posedge Clk_i)
  wralign16B_data_reg <= wralign16B_data;



  /// ram write address counter
always @ (posedge Clk_i)
begin
  if(Srst_i)
    aligned_wr_address_counter[9:0] <= 10'h0;
  else if(wralign_data_wren_reg3)
    aligned_wr_address_counter <= aligned_wr_address_counter + 1;
 end

  /// 32KB buffer
         altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(130),
                        .widthad_a(10),
                        .numwords_a(1024),
                        .width_b(130),
                        .widthad_b(10),
                        .numwords_b(1024),
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


        aligned_data_buff (
                                        .wren_a (wralign_data_wren_reg3),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (aligned_wr_address_counter),
                                        .address_b (AlignedRamRdAddr_i),
                                        .data_a (align_buffer_datain_reg),
                                        .q_b (AlignedRamData_o),
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

 /// TLP gen Limit pointer
   always @(posedge Clk_i)
      begin
        if(Srst_i)
          tlpgen_buffer_limit_cntr <= 11'h0;
        else if (wralign_data_wren_reg3)
          tlpgen_buffer_limit_cntr <= tlpgen_buffer_limit_cntr + 11'h1;
      end
  assign TLPGenBuffLimit_o = tlpgen_buffer_limit_cntr;
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         


  ///// Process the Descriptor Header TLP

 assign hdr_bytes_to_4KB = (hdr_dest_addr_reg[11:0] == 12'h0)? 13'h1000 : (13'h1000 - hdr_dest_addr_reg[11:0]);
 assign hdr_bytes_to_16B = (hdr_dest_addr_reg[3:0] == 4'h0)? 8'h10 : (8'h10 - hdr_dest_addr_reg[3:0]);
 assign hdr_dw_to_4KB   = hdr_bytes_to_4KB[12:2];
 assign hdr_dw_to_16B   = hdr_bytes_to_16B[3:2];
 assign hdr_mwr64 = hdr_dest_addr_reg[63:32]!= 32'h0;

 always @(posedge Clk_i)
   begin
     hdr_dw_to_4KB_reg <= hdr_dw_to_4KB;
     hdr_dw_to_16B_reg <= hdr_dw_to_16B;
   end


    lpm_add_sub     LPM_DEST_ADD_SUB_component (
                                .clken (1'b1),
                                .clock (Clk_i),
                                .dataa (hdr_dest_addr_reg),
                                .datab ({52'h0,sent_dw, 2'b00}),
                                .result (hdr_dest_addr_adder_out)
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
                LPM_DEST_ADD_SUB_component.lpm_width = 64;



 always @(posedge Clk_i)
   begin
         if(Srst_i)
           hdr_dest_addr_reg <= 64'h0;
     else if(desc_read_state)
       hdr_dest_addr_reg <= DescFifo_i[127:64];
     else if(header_pipe1_state)
       hdr_dest_addr_reg <= hdr_dest_addr_adder_out;
   end

 always @(posedge Clk_i)
   begin
     if(desc_read_state)
       hdr_desc_id_reg <= DescFifo_i[153:146];
   end

 always @(posedge Clk_i)
  begin

   hdr_mwr64_reg <= hdr_mwr64;
 end

always @ (posedge Clk_i)
  begin
    if(desc_read_state)
      hdr_remain_dw_reg <= DescFifo_i[145:128];
    else if(tlp_header_sent)
      hdr_remain_dw_reg <= hdr_remain_dw_reg - sent_dw;
  end


 assign to_4KB_sel = (max_payload_dw >= hdr_dw_to_4KB) & ~to_16B_sel & ~remain_dw_sel;


 assign remain_dw_sel = ((hdr_dest_addr_reg[3:0] != 4'h0) & (hdr_remain_dw_reg < hdr_dw_to_16B_reg) ) |   /// smaller than 16B boundary
                        ((hdr_remain_dw_reg <= max_payload_dw) & (hdr_remain_dw_reg <= hdr_dw_to_4KB) & (hdr_dest_addr_reg[3:0] == 4'h0))  ; // does not exceed mps and 4KB boundary

assign to_16B_sel = (hdr_dest_addr_reg[3:0] != 4'h0) & hdr_remain_dw_reg >= hdr_dw_to_16B_reg;

  always @(posedge Clk_i)
   begin
        if(to_16B_sel)
       sent_dw_sel_reg <= 3'b100;
    else if(remain_dw_sel)
      sent_dw_sel_reg <= 3'b001;
    else if(to_4KB_sel)
       sent_dw_sel_reg <= 3'b010;
    else
        sent_dw_sel_reg <= 3'b000;
   end


  always_comb
    begin
      case(sent_dw_sel_reg)
        3'b001 : sent_dw = hdr_remain_dw_reg[9:0];
        3'b010 : sent_dw = hdr_dw_to_4KB_reg[9:0];
        3'b100 : sent_dw = {6'h0,hdr_dw_to_16B_reg[3:0]};
        default : sent_dw = {3'h0, max_payload_dw};
      endcase
    end

always @(posedge Clk_i)
   sent_dw_reg <= sent_dw;

assign descriptor_done = (hdr_remain_dw_reg == 0) | immediate_write_descriptor_reg;



  always @(posedge Clk_i)
      begin
        if(Srst_i)
          align_header_state <= 4'h0;
        else
          align_header_state <= align_header_nxt_state;
      end


  always_comb
  begin
    case(align_header_state)
      ALIGN_HDR_IDLE :
        if(desc_read_state)
           align_header_nxt_state <= ALIGN_HDR_LATCH;
        else
           align_header_nxt_state <= ALIGN_HDR_IDLE;

      ALIGN_HDR_LATCH:
        align_header_nxt_state <= ALIGN_HDR_DECODE;

      ALIGN_HDR_DECODE:
       if(immediate_write_descriptor_reg)
         align_header_nxt_state <= ALIGN_HDR_IMM_WR;
       else if(hdr_dest_addr_reg[3:0] != 4'h0)
          align_header_nxt_state <= ALIGN_HDR_16B;
        else if((hdr_dw_to_4KB_reg < max_payload_dw))
         align_header_nxt_state <= ALIGN_HDR_4KB;
        else
          align_header_nxt_state <= ALIGN_HDR_MAX;

      ALIGN_HDR_IMM_WR:
        align_header_nxt_state <= ALIGN_HDR_IDLE;
        
      ALIGN_HDR_4KB, ALIGN_HDR_MAX, ALIGN_HDR_16B:
        if(descriptor_done)
          align_header_nxt_state <= ALIGN_HDR_IDLE;
        else
          align_header_nxt_state <= ALIGN_HDR_PIPE1;


      ALIGN_HDR_PIPE1:
       if(descriptor_done)
         align_header_nxt_state <= ALIGN_HDR_IDLE;
       else
         align_header_nxt_state <= ALIGN_HDR_PIPE2;
      ALIGN_HDR_PIPE2:
        align_header_nxt_state <= ALIGN_HDR_PIPE3;

       ALIGN_HDR_PIPE3:
        if(tlp_hdr_fifo_ok_reg)
          align_header_nxt_state <= ALIGN_HDR_DECODE;
        else
          align_header_nxt_state <= ALIGN_HDR_PIPE3;

      default:
        align_header_nxt_state <= ALIGN_HDR_IDLE;
    endcase
  end

  assign hdr_idle_state     = (align_header_state == ALIGN_HDR_IDLE);
  assign hdr_sent_16B_state = (align_header_state == ALIGN_HDR_16B);
  assign hdr_sent_4KB_state = (align_header_state == ALIGN_HDR_4KB);
  assign hdr_sent_max_state = (align_header_state == ALIGN_HDR_MAX);
  assign header_pipe1_state = (align_header_state == ALIGN_HDR_PIPE1);
  assign hdr_immwr_state    = (align_header_state == ALIGN_HDR_IMM_WR);
  assign tlp_header_sent = hdr_sent_16B_state | hdr_sent_4KB_state | hdr_sent_max_state | hdr_immwr_state;

  assign cmd = hdr_mwr64_reg? 8'h60 : 8'h40;
  assign lbe = (sent_dw == 10'h1)? 4'h0 : 4'hF;
  assign requestor_id = {BusDev_i, 3'b000};

  assign tlp_hdr_dw0 = {cmd[7:0], 8'h0, 6'h0, sent_dw[9:0]};
  assign tlp_hdr_dw1 = {requestor_id[15:0], 8'h0, lbe ,4'hF};
  assign tlp_hdr_dw2     = hdr_mwr64_reg?  hdr_dest_addr_reg[63:32] : hdr_dest_addr_reg[31:0];
  assign tlp_hdr_dw3     = hdr_dest_addr_reg[31:0];

  assign tlp_immwr_hdr_dw0 = {cmd[7:0], 8'h0, 6'h0, 10'h1};
  assign tlp_immwr_hdr_dw1 = {requestor_id[15:0], 8'h0, 4'h0 ,4'hF};
  assign tlp_immwr_hdr_dw2     = hdr_mwr64_reg?  hdr_dest_addr_reg[63:32] : hdr_dest_addr_reg[31:0];
  assign tlp_immwr_hdr_dw3     = hdr_dest_addr_reg[31:0];
  
  /// emty decode
       assign tlp_emp_sel = {hdr_dest_addr_reg[2], sent_dw[2:0]};

   

  always @ *
   begin
      case(hdr_mwr64_addr2)
        2'b01 : tlp_dw_size_with_header[9:0] =  sent_dw + 10'h3;
        2'b11 : tlp_dw_size_with_header[9:0] =  sent_dw + 10'h5;
        default: tlp_dw_size_with_header[9:0] =  sent_dw + 10'h4;
      endcase
   end

always @(posedge Clk_i)
  tlp_dw_size_with_header_reg <= tlp_dw_size_with_header;


always @ *
   begin
      case(tlp_dw_size_with_header_reg[1:0])    // number of qw using modulo 4
        2'b01 :  tlp_empty_reg =   1'b1;
        2'b10 :  tlp_empty_reg =   1'b1;
        default: tlp_empty_reg =   1'b0;
      endcase
   end


assign hdr_mwr64_addr2 = {hdr_mwr64_reg,hdr_dest_addr_reg[2]};


  always @(posedge Clk_i)
    begin
     tlp_header_reg <= immediate_write_descriptor_reg? 128'h0:{tlp_hdr_dw3, tlp_hdr_dw2, tlp_hdr_dw1, tlp_hdr_dw0};
     tlp_header_wrreq_reg <= tlp_header_sent;
    end

  /// TLP HEADER FIFO
      scfifo  # (
           .add_ram_output_register    ("ON"          ),
           .intended_device_family     ("Stratix V"   ),
           .lpm_numwords               (32           ),
           .lpm_showahead              ("ON"          ),
           .lpm_type                   ("scfifo"      ),
           .lpm_width                  (139 ),
           .lpm_widthu                 (5            ),
           .overflow_checking          ("OFF"          ),
           .underflow_checking         ("OFF"          ),
           .use_eab                    ("OFF"          )
         )  tlp_header_fifo             (
            .rdreq                     (TLPHeaderFifoRdReq_i),
            .clock                     (Clk_i),
            .wrreq                     (tlp_header_wrreq_reg),
            .data                      (tlp_header_fifo_input),
            .usedw                     (tlp_hdr_fifo_usedw),
            .empty                     (TLPHeaderFifoEmpty_o),
            .q                         (TLPHeaderFifoData_o),
            .full                      (),
            .aclr                      (1'b0),
            .almost_empty              (),
            .almost_full               (),
            .sclr                      (Srst_i)
         );

assign tlp_in_one_clk = sent_dw_reg[6:0] == 7'h1 & ~hdr_mwr64_reg;
assign immwr_tlp_empty =( hdr_mwr64_addr2 == 2'b01)? 2'b10 : 2'b01;
assign tlp_empty  = immediate_write_descriptor_reg? immwr_tlp_empty : (tlp_empty_reg);

assign tlp_header_fifo_input = {descriptor_done, hdr_desc_id_reg[7:0],1'b0,tlp_empty, tlp_header_reg};
assign tlp_hdr_fifo_ok = tlp_hdr_fifo_usedw < 5'd24;
 always @(posedge Clk_i)
   tlp_hdr_fifo_ok_reg <= tlp_hdr_fifo_ok;

//assign TLPHeaderFifoEmpty_o = hdr_fifo_count == 4'h0;

/// Buffer EOD  (end of descriptor marker)

/// read pointer stop limit
always @ (posedge Clk_i)
begin
  if(desc_read_state)
    buffer_stop_limit_cntr[14:0] <= DescFifo_i[46:32];
  if(accessive_data_supply)
     buffer_stop_limit_cntr <= buffer_stop_limit_cntr + 1;  /// backing up
  else if(buffer_read_enable) /// buff_enable but not prefetch state
    buffer_stop_limit_cntr <= buffer_stop_limit_cntr - 1;
end

/// store max limit pointer to later load back to the ram_address_reg
always @ (posedge Clk_i)
begin
        if(Srst_i)
          desc_line_size_reg[9:0] <= 10'h0;
  if(desc_read_state & ~DescFifo_i[159] )
    desc_line_size_reg[9:0] <= desc_line_size_reg[9:0] + DescFifo_i[41:32];
  end

always @ (posedge Clk_i)
begin
        if(Srst_i)
          saved_consume_ptr_reg[10:0] <= 10'h40;
  else if(desc_read_state & ~DescFifo_i[159])
    saved_consume_ptr_reg[10:0] <= saved_consume_ptr_reg[10:0] + DescFifo_i[42:32];
  end



 // assign complete_desc_data_rdreq = desc_read_state & complete_flag_read_enable_sreg;
   assign data_idle_state_rise = data_idle_state & ~data_idle_state_reg;
   assign complete_desc_data_rdreq = data_idle_state_rise & ~immediate_write_descriptor_reg;
  /// buffer lines release
     
assign max_lines =  max_payload_dw[6:2];   

always @ (posedge Clk_i)
     begin
        if(Srst_i)
          desc_lines_release_reg[9:0] <= 10'h0;
        else if(desc_read_state)
          desc_lines_release_reg[9:0] <=  DescFifo_i[41:32];
        else if(send_max_state & tx_eop_flag)
          desc_lines_release_reg[9:0] <= desc_lines_release_reg[9:0] - max_lines;  // release some at max send
        end

  assign release_raw_buffer = data_idle_state_rise & ~immediate_write_descriptor_reg;
  assign RawBuffRelease_o = release_raw_buffer | (send_max_state & tx_eop_flag);  // release at every max send eop
  assign RawBuffReleaseSize_o =  (send_max_state & tx_eop_flag)? {5'h0, max_lines[4:0]} : desc_lines_release_reg;
  
    //synthesis translate_off
 initial begin
     send_16B_state_reg = 0;
     send_16B_state_2_reg = 0;
     send_16B_state_reg2 = 0;
     send_16B_state_2_reg2 = 0;
     send_max_state_reg = 0;
     send_4KB_state_reg = 0;
     data_decode_state_reg = 0;
     cur_src_addr_reg = 0;
     orig_dest_addr_reg = 0;
     cur_dest_addr_reg = 0;
     dw_to_16B_reg = 0;
     first_dw_position_reg = 0;
     ram_addr_reg = 0;
     is_mwr64_reg = 0;
     raw_buffer_ok_reg = 0;
     raw_data_reg = 0;
     wralign16B1_data_reg = 0;
     wralign16B2_data_reg = 0;
     wralign16B_data_reg = 0;
     wralign_data_reg = 0;
     wralign_data_reg2 = 0;
     align_buffer_datain_reg = 0;
     pcie_address_b2_reg = 0;
     wralign_data_wren_reg = 0;
     wralign_data_wren_reg2 = 0;
     wralign_data_wren_reg3 = 0;
     hdr_dest_addr_reg = 0;
     hdr_dw_to_4KB_reg = 0;
     data_dw_to_4KB_reg = 0;
     hdr_dw_to_16B_reg = 0;
  
     hdr_mwr64_reg = 0;
     hdr_remain_dw_reg = 0;
     sent_dw_sel_reg = 0;

     tlp_header_reg = 0;
     tlp_header_wrreq_reg = 0;
     boundary_16B_span_2cycles_reg = 0;
     prefetch_data_reg = 0;
     tlp_empty_reg = 0;
     hdr_desc_id_reg = 0;
     desc_line_size_reg = 0;
    
     orig_desc_size_reg = 0;
     saved_consume_ptr_reg = 0;
     tlp_dw_size_with_header_reg = 0;
     desc_lines_release_reg = 0;
     align_buff_ok_reg = 0;
     tlp_hdr_fifo_ok_reg = 0;
     saved_ram_address_reg = 0;
     data_idle_state_reg = 0;
     first_available_dw_reg = 0;
     dw_needed_to_16B_reg = 0;
     available_dw_after_16B_allignment_reg = 0;
     dw_over_read_reg = 0;
     dw_under_read_reg = 0;
     desc_read_state_reg = 0;
     immediate_write_descriptor_reg = 0;

   end
     //synthesis translate_on

endmodule


