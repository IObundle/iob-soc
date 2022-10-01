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
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpcieav_dma_wr_readmem_2 # (
   parameter dma_use_scfifo                  = 2,
   parameter DMA_WIDTH                       = 256,
   parameter DMA_BE_WIDTH                    = 5,
   parameter DMA_BRST_CNT_W                  = 5,
   parameter WRDMA_AVL_ADDR_WIDTH            = 20,
   parameter WRDMA_RXDATA_WIDTH              = 160,
   parameter RXFIFO_DATA_WIDTH               = 266,
   parameter TX_FIFO_WIDTH                   = (DMA_WIDTH == 256) ? 260 : 131   //Data+Sop+Eop+Empty
   )
   (
   input    logic                     Clk_i,
   input    logic                     Srst_i,

   // Avalon-MM Interface
   // Upstream PCIe Write DMA master port

   output   logic                     WrDmaRead_o,
   output   logic[63:0]               WrDmaAddress_o,
   output   logic [31:0]              WrDmaReadByteEnable_o,
   output   logic[4:0]                WrDmaBurstCount_o,
   input    logic                     WrDmaWaitRequest_i,
   input    logic                     WrDmaReadDataValid_i,
   input    logic[255:0]              WrDmaReadData_i,

   /// AST Inteface
   // Write DMA AST Rx port
   input    logic[WRDMA_RXDATA_WIDTH-1:0] WrDmaRxData_i,
   input    logic                         WrDmaRxValid_i,
   output   logic                         WrDmaRxReady_o,
   
   /// Data Buffer Interface
   input    logic                     RawBuffRelease_i,
   input    logic [8:0]               RawBuffReleaseSize_i,
   input    logic [8:0]               DataRamReadAddr_i,
   output   logic [255:0]             DataRamReadData_o,
   
   input    logic                     TLPGenDescFifoRdReq_i,
   output   logic [159:0]             TLPGenDescFifoDataq_o,
   output   logic [2:0]               TLPGenDescFifoCount_o, 
   
   output   logic [9:0]               TLPGenBuffLimit_o,   
   
   /// desc all data available (done) flag
   input    logic                     DescDataCompleteFifoRdReq_i,          
   output   logic [4:0]               DescDataCompleteFifoCount_o        

 //  input    logic[15:0]               BusDev_i,
 //  input    logic[31:0]               DevCsr_i,
 //  input    logic                     MasterEnable
  // input    logic[VF_COUNT-1:0]       vf_MasterEnable_i  // SR-IOV VF Master Enable
   );
   
 
logic                           desc_fifo_wrreq;   
logic  [159:0]                  desc_fifo_wrdat; 
logic  [159:0]                  desc_head;
logic  [3:0]                    desc_fifo_count;
logic                           desc_fifo_empty;
logic  [63:0]                   cur_dest_addr_reg;
logic  [63:0]                   cur_src_addr_reg;
logic  [31:0]                   hold_src_addr_reg;
logic  [17:0]                   remain_desc_dw_reg;
logic  [17:0]                   desc_dw_reg;
logic  [4:0]                    wrdma_rd_state;
logic  [4:0]                    wrdma_rd_nxt_state;
logic                           buffer_ok;
logic                           buffer_ok_reg;
logic                           pop_desc_state;  
logic                           send_head_state; 
logic                           send_max_state;  
logic                           send_last_state; 
logic                           send_tail_state; 
logic                           adder_pipe_state;  


logic  [4:0]                    burst_count;
logic  [1:0]                    bcnt_sel;
logic  [5:0]                    bytes_to_32B;
logic  [3:0]                    dw_to_32B;
logic  [3:0]                    dw_to_32B_reg;
logic  [7:0]                    max_dw_size;    
logic  [7:0]                    last_dw_size;
logic  [7:0]                    head_dw_size;
logic  [7:0]                    tail_dw_size;
logic  [7:0]                    rd_dw_size;
logic  [63:0]                   addr_adder_out;
logic  [8:0]                    data_wraddr;
logic  [8:0]                    data_rdaddr;    
logic                           read_data_valid_reg;    
logic                           read_data_valid_reg2;    
logic  [255:0]                  read_data_reg;
logic  [9:0]                    buffer_limit_cntr;
logic  [9:0]                    buffer_consume_cntr;
logic  [9:0]                    tlpgen_buffer_limit_cntr;
logic  [9:0]                    buffer_available_sub;
logic  [15:0]                   total_desc_bcnt;       

logic                           total_desc_bcnt_fifo_rdreq;
logic  [15:0]                   total_desc_bcnt_q;            
logic  [4:0]                    total_desc_bcnt_usedw;      

logic                           cpl_data_termimal_count;
logic  [15:0]                   cpl_data_count;    
logic                           desc_data_done_fifo_wrreq;             
logic                           desc_data_done_fifo_rdreq;                
logic  [4:0]                    desc_data_done_fifo_count;            
 
logic                           tlp_gen_desc_fifo_rdreq;    
logic  [159:0]                  tlp_gen_desc_fifo_dataq;  
logic  [159:0]                  tlp_gen_desc_fifo_data;   
logic  [3:0]                    tlp_gen_desc_fifo_count;    
logic                           tlp_gen_desc_fifo_full; 
logic  [7:0]                    cur_desc_id_reg; 
logic                           pop_desc_state_reg;
logic                           pop_desc_state_reg1;
logic                           pop_desc_state_reg2;
logic [17:0]                    adjusted_dw;
logic [17:0]                    adjusted_dw_reg;
logic                           all_dw_done;

logic                           raw_buff_release_reg; 
logic [8:0]                     raw_buff_release_size_reg;     
logic                           wr_dma_read_rise;
logic                           wr_dma_read_reg;
logic [9:0]                     raw_buff_limit_counter;
logic [9:0]                     raw_buff_consume_counter;
logic [9:0]                     raw_buffer_sub;
logic                           raw_buffer_ok;
logic                           immwr_descriptor_reg;    
logic [31:0]                    head_read_be;
logic [31:0]                    tail_read_be;    
logic                           desc_size_lt_8_reg;



localparam   WRDMA_RD_IDLE        = 0;
localparam   WRDMA_RD_POP_DESC    = 1;
localparam   WRDMA_RD_CHECK_DESC  = 2;
localparam   WRDMA_RD_SEND_HEAD   = 3;  
localparam   WRDMA_RD_SEND_MAX    = 4; 
localparam   WRDMA_RD_SEND_LAST   = 5;
localparam   WRDMA_RD_SEND_TAIL   = 6; 
localparam   WRDMA_RD_ADDER_PIPE  = 7; 
localparam   WRDMA_RD_UPDATE_DESC = 8;

   //synthesis translate_off
 initial begin
      cur_dest_addr_reg = 0;
      cur_src_addr_reg = 0;
      hold_src_addr_reg = 0;
      remain_desc_dw_reg = 0;
      desc_dw_reg = 0;
      buffer_ok_reg = 0;
      dw_to_32B_reg = 0;
      read_data_valid_reg = 0;    
      read_data_valid_reg2 = 0;    
      read_data_reg = 0;
      cur_desc_id_reg = 0; 
      pop_desc_state_reg = 0;
      pop_desc_state_reg1 = 0;
      pop_desc_state_reg2 = 0;
      adjusted_dw_reg = 0;
      raw_buff_release_reg = 0; 
      raw_buff_release_size_reg = 0;     
      wr_dma_read_reg = 0;
      immwr_descriptor_reg = 0;    
   end
     //synthesis translate_on
 
  // Descriptor FIFO
   altpcie_fifo
   #(
    .FIFO_DEPTH(6),
    .DATA_WIDTH(160)
    )
 write_desc_fifo
(
      .clk(Clk_i),
      .rstn(1'b1),
      .srst(Srst_i ),
      .wrreq(desc_fifo_wrreq),
      .rdreq(pop_desc_state),
      .data(desc_fifo_wrdat),
      .q(desc_head),
      .fifo_count(desc_fifo_count)
);

assign WrDmaRxReady_o = desc_fifo_count < 3;
assign desc_fifo_empty = (desc_fifo_count == 0);
assign desc_fifo_wrreq   = WrDmaRxValid_i;
assign desc_fifo_wrdat   = WrDmaRxData_i;

 always @ (posedge Clk_i)
       if(pop_desc_state)  
           cur_dest_addr_reg <= desc_head[127:64];

 always @ (posedge Clk_i)
     begin
      if(pop_desc_state)   
           cur_src_addr_reg <= desc_head[63:0];
      else if(adder_pipe_state)
           cur_src_addr_reg <= addr_adder_out[63:0];
     end
	  
always @ (posedge Clk_i)
      if(pop_desc_state)   
        begin
           hold_src_addr_reg <= desc_head[31:0];
           desc_dw_reg       <= desc_head[145:128];
           immwr_descriptor_reg <= desc_head[159];
        end
           

 always @ (posedge Clk_i)
      if(pop_desc_state)
         cur_desc_id_reg  <= desc_head[153:146];

always @ (posedge Clk_i)
  begin
      if(pop_desc_state)
         remain_desc_dw_reg  <= desc_head[145:128];
      else if(send_head_state & ~WrDmaWaitRequest_i)
         remain_desc_dw_reg <= remain_desc_dw_reg - head_dw_size;
      else if(send_max_state & ~WrDmaWaitRequest_i)
         remain_desc_dw_reg <= remain_desc_dw_reg - max_dw_size;  
      else if(send_last_state & ~WrDmaWaitRequest_i)
         remain_desc_dw_reg <= remain_desc_dw_reg - last_dw_size;   
      else if(send_tail_state & ~WrDmaWaitRequest_i)
         remain_desc_dw_reg <= remain_desc_dw_reg - tail_dw_size;
  end
 

         assign all_dw_done  = remain_desc_dw_reg <= dw_to_32B_reg; 

 /// state machine to generate AVMM read requests for a descriptor
 
 always @ (posedge Clk_i) 
       if(Srst_i)
          wrdma_rd_state <= 4'h0;
       else 
          wrdma_rd_state <= wrdma_rd_nxt_state;
 
always_comb
  begin
    case(wrdma_rd_state)
      WRDMA_RD_IDLE :
        if(~desc_fifo_empty & ~tlp_gen_desc_fifo_full)
          wrdma_rd_nxt_state <= WRDMA_RD_POP_DESC;
        else
          wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
          
      WRDMA_RD_POP_DESC:
        wrdma_rd_nxt_state <= WRDMA_RD_CHECK_DESC;
          
      WRDMA_RD_CHECK_DESC:
        if(immwr_descriptor_reg)
           wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
        else if(cur_src_addr_reg[4:0] != 0 & buffer_ok_reg)
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_HEAD;
        else if(remain_desc_dw_reg >= 128 & buffer_ok_reg)
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_MAX;
        else if(remain_desc_dw_reg < 8 & buffer_ok_reg)
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_TAIL;
        else if(buffer_ok_reg)
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_LAST;
        else
          wrdma_rd_nxt_state <= WRDMA_RD_CHECK_DESC;
      
      WRDMA_RD_SEND_HEAD:
        if(~WrDmaWaitRequest_i & all_dw_done)
          wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
        else if(~WrDmaWaitRequest_i)
          wrdma_rd_nxt_state <= WRDMA_RD_ADDER_PIPE;
        else
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_HEAD;
          
      WRDMA_RD_SEND_MAX:
        if(~WrDmaWaitRequest_i)
          wrdma_rd_nxt_state <= WRDMA_RD_ADDER_PIPE;
        else
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_MAX;
           
      WRDMA_RD_SEND_LAST:
         if(~WrDmaWaitRequest_i)
             wrdma_rd_nxt_state <= WRDMA_RD_ADDER_PIPE;
         else
            wrdma_rd_nxt_state <= WRDMA_RD_SEND_LAST;  
          
       WRDMA_RD_SEND_TAIL:
        if(~WrDmaWaitRequest_i )
          wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
        else
          wrdma_rd_nxt_state <= WRDMA_RD_SEND_TAIL;
          
      WRDMA_RD_ADDER_PIPE:
        if(remain_desc_dw_reg == 18'h0)
          wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
        else
         wrdma_rd_nxt_state <= WRDMA_RD_UPDATE_DESC;
         
      WRDMA_RD_UPDATE_DESC:
        wrdma_rd_nxt_state <= WRDMA_RD_CHECK_DESC;
      
     default:
       wrdma_rd_nxt_state <= WRDMA_RD_IDLE;
  endcase
end

// state machine assignments
assign pop_desc_state  =  (wrdma_rd_state == WRDMA_RD_POP_DESC);
assign send_head_state =  (wrdma_rd_state == WRDMA_RD_SEND_HEAD);
assign send_max_state  =  (wrdma_rd_state == WRDMA_RD_SEND_MAX);
assign send_last_state =  (wrdma_rd_state == WRDMA_RD_SEND_LAST); 
assign send_tail_state =  (wrdma_rd_state == WRDMA_RD_SEND_TAIL);
assign adder_pipe_state = (wrdma_rd_state == WRDMA_RD_ADDER_PIPE);    

 



///AVMM burst count 
assign bcnt_sel = {send_last_state,send_max_state};

always_comb
  begin
  	case(bcnt_sel)
  		 2'b01:    burst_count = 5'h10; // 512B
  		 2'b10:    burst_count = remain_desc_dw_reg[7:3]; // last remain
  		 default:  burst_count = 5'h1;         // head or tail with Byte enable
    endcase
  end

assign bytes_to_32B[5:0] = (cur_src_addr_reg[4:0] == 5'h0)? 6'h20 : (6'h20 - cur_src_addr_reg[4:0]);
assign dw_to_32B[3:0] =  bytes_to_32B[5:2]; 

always @ (posedge Clk_i)
  begin
    dw_to_32B_reg[3:0] <= dw_to_32B[3:0];                 
    desc_size_lt_8_reg <= desc_dw_reg[17:0] < 18'h8;
end
                    
assign head_dw_size = desc_size_lt_8_reg & (desc_dw_reg[17:0] < dw_to_32B_reg )? desc_dw_reg[7:0] : dw_to_32B_reg;     
assign max_dw_size  = 8'd128;   // 512B 
assign last_dw_size = {remain_desc_dw_reg[7:3], 3'h000};    
assign tail_dw_size = {5'h0,remain_desc_dw_reg[2:0]};

assign rd_dw_size = send_head_state? head_dw_size :  send_last_state? last_dw_size : max_dw_size;


// AVMM Address
        lpm_add_sub     LPM_DEST_ADD_SUB_component (
                                .clken (1'b1),
                                .clock (Clk_i),
                                .dataa (cur_src_addr_reg),
                                .datab ({54'h0,rd_dw_size, 2'b00}),
                                .result (addr_adder_out)
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


///// 32KB buffer to hold data completion data

/// data write address counter
  always@ (posedge Clk_i)
  begin
  	if(Srst_i)
  	  data_wraddr <= 9'h0;
  	else if(read_data_valid_reg)
  	 data_wraddr <= data_wraddr + 1'b1;
  end
  
assign data_rdaddr = DataRamReadAddr_i;


always @ (posedge Clk_i)
  begin
    read_data_valid_reg <= WrDmaReadDataValid_i;    
    read_data_reg       <= WrDmaReadData_i;
  end
  
        altsyncram
        #(
                        .intended_device_family("Stratix V"),
                        .operation_mode("DUAL_PORT"),
                        .width_a(256),
                        .widthad_a(9),
                        .numwords_a(512),
                        .width_b(256),
                        .widthad_b(9),
                        .numwords_b(512),
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


        wr_data_buff (
                                        .wren_a (read_data_valid_reg),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (data_wraddr),
                                        .address_b (data_rdaddr),
                                        .data_a (read_data_reg),
                                        .q_b (DataRamReadData_o),
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
  		

//// Buffer Credit Management
/// Credit to throtle internal SM sending reads out to AVMM


  
 /// credit return acumulator
  always @(posedge Clk_i)
      begin
         read_data_valid_reg2 <= read_data_valid_reg;
         raw_buff_release_reg <= RawBuffRelease_i;
         raw_buff_release_size_reg[8:0] <= RawBuffReleaseSize_i; 
      end
 
  
 
 /// new credit logic
 always @(posedge Clk_i)
      begin
        if(Srst_i)
          raw_buff_limit_counter <= 9'h1BF; // leave some margin 
        else if(raw_buff_release_reg)
          raw_buff_limit_counter <= raw_buff_limit_counter + raw_buff_release_size_reg; 
      end 
 
 always @(posedge Clk_i)
      begin
        if(Srst_i)
          raw_buff_consume_counter <= 9'h0; 
        else if(wr_dma_read_rise)
          raw_buff_consume_counter <= raw_buff_consume_counter + WrDmaBurstCount_o; 
      end 

assign raw_buffer_sub = raw_buff_limit_counter - raw_buff_consume_counter;
assign raw_buffer_ok = raw_buffer_sub <= 10'd512;
  
 
  always @(posedge Clk_i)
    buffer_ok_reg <= raw_buffer_ok;
        
 
 /// Credit to allow the TLP gen module sending reading the data buffer but not overun it
 
  always @(posedge Clk_i)
      begin
        if(Srst_i)
          tlpgen_buffer_limit_cntr <= 10'h0; 
        else if (read_data_valid_reg)
          tlpgen_buffer_limit_cntr <= tlpgen_buffer_limit_cntr + 10'h1;
      end 
  assign TLPGenBuffLimit_o = tlpgen_buffer_limit_cntr;
          
 /// keep track of total bcnt read for each descriptor
 
 // calculate # of lines for each descriptor
 always_comb
  begin
    case(cur_src_addr_reg[4:0])
        5'h4:  adjusted_dw = desc_dw_reg + 1;
        5'h8:  adjusted_dw = desc_dw_reg + 2;
        5'hC:  adjusted_dw = desc_dw_reg + 3;
        5'h10: adjusted_dw = desc_dw_reg + 4;
        5'h14: adjusted_dw = desc_dw_reg + 5;
        5'h18: adjusted_dw = desc_dw_reg + 6;
        5'h1C: adjusted_dw = desc_dw_reg +  7;
        default: adjusted_dw = desc_dw_reg;
     endcase
  end
  
always @(posedge Clk_i)
  adjusted_dw_reg <= adjusted_dw;
  
always @(posedge Clk_i)  
  total_desc_bcnt[15:0] =(adjusted_dw_reg[2:0] == 3'b000)? {adjusted_dw_reg[17:3]} :  adjusted_dw_reg[17:3] + 8'h1;
 

/// storing total bcnt in a FIFO
  altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(16)
    )
 total_desc_bcnt_fifo
(
      .clk(Clk_i),
      .rstn(1'b1),
      .srst(Srst_i),
      .wrreq(pop_desc_state_reg2 & ~immwr_descriptor_reg),
      .rdreq(total_desc_bcnt_fifo_rdreq),
      .data(total_desc_bcnt),
      .q(total_desc_bcnt_q),
      .fifo_count(total_desc_bcnt_usedw)
);                



always @(posedge Clk_i)
 begin
   pop_desc_state_reg <= pop_desc_state;
   pop_desc_state_reg1 <= pop_desc_state_reg;
   pop_desc_state_reg2 <= pop_desc_state_reg1;
 end
/// generating a done flag for each descriptor
/// to indicate to the tlp gen module that the current descriptor has 
/// all the payload available

always @(posedge Clk_i)
      begin
        if (Srst_i)
          cpl_data_count <= 16'h0;
        else if(cpl_data_termimal_count & read_data_valid_reg)
          cpl_data_count <= 16'h1;
        else if(cpl_data_termimal_count)
          cpl_data_count <= 16'h0;
        else if(read_data_valid_reg)
          cpl_data_count <= cpl_data_count + 1;
      end 

assign cpl_data_termimal_count = (cpl_data_count == total_desc_bcnt_q) & read_data_valid_reg2;
assign total_desc_bcnt_fifo_rdreq = cpl_data_termimal_count;
assign desc_data_done_fifo_wrreq  = cpl_data_termimal_count;

///store the all data available for each descriptor

 altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(1)
    )
 desc_data_done_fifo
(
      .clk(Clk_i),
      .rstn(1'b1),
      .srst(Srst_i ),
      .wrreq(desc_data_done_fifo_wrreq),
      .rdreq(desc_data_done_fifo_rdreq),
      .data(1'b1),
      .q(),
      .fifo_count(desc_data_done_fifo_count)
);

assign desc_data_done_fifo_rdreq = DescDataCompleteFifoRdReq_i;   
assign DescDataCompleteFifoCount_o = desc_data_done_fifo_count;

/// passing modified descriptors to the tlp gen

assign tlp_gen_desc_fifo_data = {immwr_descriptor_reg,5'h0,cur_desc_id_reg, desc_dw_reg[17:0],cur_dest_addr_reg[63:0] ,16'h0,total_desc_bcnt[15:0], hold_src_addr_reg[31:0]};

altpcie_fifo
   #(
    .FIFO_DEPTH(4),
    .DATA_WIDTH(160)
    )
 tlp_gen_desc_fifo
(
      .clk(Clk_i),
      .rstn(1'b1),
      .srst(Srst_i),
      .wrreq(pop_desc_state_reg2),
      .rdreq(tlp_gen_desc_fifo_rdreq),
      .data(tlp_gen_desc_fifo_data),
      .q(tlp_gen_desc_fifo_dataq),
      .fifo_count(tlp_gen_desc_fifo_count)
);


assign tlp_gen_desc_fifo_rdreq = TLPGenDescFifoRdReq_i;
assign TLPGenDescFifoDataq_o = tlp_gen_desc_fifo_dataq;
assign TLPGenDescFifoCount_o = tlp_gen_desc_fifo_count;
assign tlp_gen_desc_fifo_full = tlp_gen_desc_fifo_count >= 3;

// AVMM ports   
assign WrDmaRead_o    =  send_head_state |
                         send_max_state  |
                         send_last_state |
                         send_tail_state        ;

assign WrDmaAddress_o = cur_src_addr_reg;       
assign WrDmaBurstCount_o = burst_count;


always @(posedge Clk_i)
  begin
     wr_dma_read_reg <= WrDmaRead_o;
  end
  
 assign wr_dma_read_rise = WrDmaRead_o & ~wr_dma_read_reg;


/// Read Byte enable
/*
always_comb
  begin
    case(head_dw_size[2:0])
    	3'd1 : head_read_be = 32'hF000_0000;
    	3'd2 : head_read_be = 32'hFF00_0000;
    	3'd3 : head_read_be = 32'hFFF0_0000;
    	3'd4 : head_read_be = 32'hFFFF_0000;
    	3'd5 : head_read_be = 32'hFFFF_F000;
    	3'd6 : head_read_be = 32'hFFFF_FF00;
    	3'd7 : head_read_be = 32'hFFFF_FFF0;
    	default: head_read_be = 32'hFFFF_FFFF; 
    endcase
  end
*/
always_comb
  begin
    case(hold_src_addr_reg[4:0])
        5'h0:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h0000_000F;
              3'd2 :  head_read_be[31:0] = 32'h0000_00FF;
              3'd3 :  head_read_be[31:0] = 32'h0000_0FFF;
              3'd4 :  head_read_be[31:0] = 32'h0000_FFFF;
              3'd5 :  head_read_be[31:0] = 32'h000F_FFFF;
              3'd6 :  head_read_be[31:0] = 32'h00FF_FFFF;
              3'd7 :  head_read_be[31:0] = 32'h0FFF_FFFF;
              default: head_read_be[31:0] = 32'hFFFF_FFFF;
            endcase
        5'h4:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h0000_00F0;
              3'd2 :  head_read_be[31:0] = 32'h0000_0FF0;
              3'd3 :  head_read_be[31:0] = 32'h0000_FFF0;
              3'd4 :  head_read_be[31:0] = 32'h000F_FFF0;
              3'd5 :  head_read_be[31:0] = 32'h00FF_FFF0;
              3'd6 :  head_read_be[31:0] = 32'h0FFF_FFF0;
              3'd7 :  head_read_be[31:0] = 32'hFFFF_FFF0;
              default: head_read_be[31:0] = 32'hFFFF_FFF0;
            endcase
         5'h8:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h0000_0F00;
              3'd2 :  head_read_be[31:0] = 32'h0000_FF00;
              3'd3 :  head_read_be[31:0] = 32'h000F_FF00;
              3'd4 :  head_read_be[31:0] = 32'h00FF_FF00;
              3'd5 :  head_read_be[31:0] = 32'h0FFF_FF00;
              3'd6 :  head_read_be[31:0] = 32'hFFFF_FF00;
              default: head_read_be[31:0] = 32'hFFFF_FF00;
            endcase
          5'hC:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h0000_F000;
              3'd2 :  head_read_be[31:0] = 32'h000F_F000;
              3'd3 :  head_read_be[31:0] = 32'h00FF_F000;
              3'd4 :  head_read_be[31:0] = 32'h0FFF_F000;
              3'd5 :  head_read_be[31:0] = 32'hFFFF_F000;
              default: head_read_be[31:0] = 32'hFFFF_F000;
            endcase
          5'h10:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h000F_0000;
              3'd2 :  head_read_be[31:0] = 32'h00FF_0000;
              3'd3 :  head_read_be[31:0] = 32'h0FFF_0000;
              3'd4 :  head_read_be[31:0] = 32'hFFFF_0000;
              default: head_read_be[31:0] = 32'hFFFF_0000;
            endcase
          5'h14:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h00F0_0000;
              3'd2 :  head_read_be[31:0] = 32'h0FF0_0000;
              3'd3 :  head_read_be[31:0] = 32'hFFF0_0000;
              default: head_read_be[31:0] = 32'hFFF0_0000;
            endcase
          5'h18:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'h0F00_0000;
              3'd2 :  head_read_be[31:0] = 32'hFF00_0000;
              default: head_read_be[31:0] = 32'hFF00_0000;
            endcase
         5'h1C:
            case (head_dw_size[2:0])
              3'd1 :  head_read_be[31:0] = 32'hF000_0000;
              default: head_read_be[31:0] = 32'hF000_0000;
            endcase
       default: head_read_be[31:0] = 32'hFFFF_FFFF;
      endcase
  end


  
always_comb
  begin
    case(tail_dw_size[2:0])
    	3'd1 : tail_read_be = 32'h0000_000F;
    	3'd2 : tail_read_be = 32'h0000_00FF;
    	3'd3 : tail_read_be = 32'h0000_0FFF;
    	3'd4 : tail_read_be = 32'h0000_FFFF;
    	3'd5 : tail_read_be = 32'h000F_FFFF;
    	3'd6 : tail_read_be = 32'h00FF_FFFF;
    	3'd7 : tail_read_be = 32'h0FFF_FFFF;
    	default: tail_read_be = 32'hFFFF_FFFF; 
    endcase
  end
  
 assign WrDmaReadByteEnable_o = send_head_state? head_read_be : send_tail_state? tail_read_be : 32'hFFFF_FFFF;
 

endmodule


