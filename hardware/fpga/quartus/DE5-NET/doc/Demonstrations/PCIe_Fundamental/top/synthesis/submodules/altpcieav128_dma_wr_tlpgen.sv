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


// synthesis translate_off                                                                                     
`timescale 1ns / 1ps                                                                                           
// synthesis translate_on                                                                                      
module altpcieav128_dma_wr_tlpgen                                                          

(
   input    logic                        Clk_i,
   input    logic                        Srst_i,
   
   /// Aligned RAM input
   output   logic  [9:0]                 AlignedRamRdAddr_o,
   input    logic  [129:0]               AlignedRamData_i,
   
   input    logic  [10:0]                 TLPGenBuffLimit_i,
                                                                                                                                                
   output   logic                        TLPHeaderFifoRdReq_o,
   input    logic                        TLPHeaderFifoEmpty_i,
   input    logic   [138:0]              TLPHeaderFifoData_i,
   
   /// Side FIFO
   input    logic  [130:0]               SideFifoData_i,
   input    logic  [3:0]                 SideFifoCount_i,
   output   logic                        SideFifoRdreq_o,
  
   /// HPRXM Request 
   input    logic                        HPRxmPending_i,
   
   /// Arbitration interface
   output   logic                        WrDmaArbReq_o,                                
   input    logic                        WrDmaGrant_i,
  
  /// Tx output FIFO Status
  input     logic   [5:0]                TxFifoCount_i, 
  output    logic   [130:0]              TxFifoData_o,
  output    logic                        TxFifoWrReq_o,
  
  /// Descriptor Done status
  output   logic                         WrDMADescDone_o,
  output   logic    [31:0]               WrDmaDescID_o,
  
  /// sending update credit
  
    output                                TlpGenCreditUp_o,     
    output    logic [10:0]                 TlpGenCred_o      
    
   );
   
   
   
   
   
logic   [10:0]                            mps_water_mark_cntr;   
logic   [10:0]                            mps_available_sub; 
logic   [10:0]                            buffer_consume_cntr;
logic   [10:0]                            buffer_required_pointer;
logic   [5:0]                            adjusted_lines_count_reg;
logic   [10:0]                            buffer_available_sub;
logic                                    mps_ok_reg; 
logic                                    mps_ok;
logic                                    payload_ok_reg;
logic                                    payload_ok;
logic   [3:0]                            tlpgen_state;
logic   [3:0]                            tlpgen_nxt_state;
logic                                    tlpgen_send_state; 
logic                                    tlpgen_hdr_state;

logic                                    tlpgen_side_fifo_state;   
logic                                    tlpgen_side_fifo_state2;    
logic                                    tlpgen_arb_req;
logic                                    sm_exit_send;
logic                                    tlp_header_rdreq;        
logic                                    tlp_header_rdreq_reg;        

logic   [138:0]                          tlp_header_reg;
logic   [138:0]                          header_fifo_reg;
logic                                    tlp_wr64;
logic                                    eop_flag;
logic                                    eop_flag_reg;
logic                                    empty;   
logic   [7:0]                            desc_id; 
logic   [7:0]                            dw_size;
logic                                    address_bit2;   
logic                                    descriptor_done;      
logic                                    descriptor_done_sreg;                 

logic   [31:0]                           header_in_dw0;  
logic   [31:0]                           header_in_dw1;  
logic   [31:0]                           header_in_dw2;  
logic   [31:0]                           header_in_dw3;  
logic   [31:0]                           data_in_dw0;    
logic   [31:0]                           data_in_dw1;    
logic   [31:0]                           data_in_dw2;    
logic   [31:0]                           data_in_dw3;    
logic   [31:0]                           tlp_dw0; 
logic   [31:0]                           tlp_dw1; 
logic   [31:0]                           tlp_dw2; 
logic   [31:0]                           tlp_dw3; 
logic   [9:0]                            ram_read_address_counter;
logic                                    tx_mwr_fifo_wrreq;
logic   [130:0]                          tx_mwr_fifo_data;
logic                                    tx_side_fifo_wrreq;
logic   [130:0]                          tx_side_fifo_data;
logic                                    tx_output_fifo_wrreq;
logic   [130:0]                          tx_output_fifo_data;
logic                                    tx_output_fifo_wrreq_reg;
logic   [130:0]                          tx_output_fifo_data_reg; 
logic                                    tlpgen_send_state_reg;   
logic                                    tlp_send_state_fall;
           
logic                                    desc_completed;   
logic                                    add_3_sel;
logic                                    add_1_sel;
logic  [1:0]                             adjust_dw_sel;
logic  [7:0]                             adjusted_dw_count;
logic  [7:0]                             adjusted_dw_size_reg;                    
logic  [5:0]                             adjusted_lines_count;    
logic                                    buffer_read_enable;         
logic                                    side_fifo_pending;
logic                                    tlpgen_idle_state; 
logic  [9:0]                             ram_addr_reg;
logic                                    tlp_hdr_empty_reg;
logic                                    tx_output_fifo_almost_full_reg;
logic [10:0]                              credit_accumulator;
logic                                    accumulator_unload;
logic [2:0]                              arb_weight_cntr;
logic                                    tlp_in_one_clk;
logic                                    data_in_hdr_state;        
logic                                    tx_side_fifo_eop;

localparam DMA_WR_ARBITER_WEIGH = 7;

 
localparam	TLPGEN_IDLE                = 4'h0;                                          
localparam  TLPGEN_ARB_REQ             = 4'h1;                          
localparam  TLPGEN_SEND                = 4'h2;                          
localparam  TLPGEN_CREDIT_PIPE         = 4'h3;
localparam  TLPGEN_CREDIT_PIPE2        = 4'h9;
localparam  TLPGEN_CREDIT_PIPE3        = 4'hA;
localparam  TLPGEN_CHECK_PAYLOAD       = 4'h4;                         
localparam  TLPGEN_YIELD_SIDE_FIFO     = 4'h5;
localparam  TLPGEN_ARB_REQ_FOR_SIDE_FIFO = 4'h6;
localparam  TLPGEN_HDR                   = 4'h7;
localparam  TLPGEN_YIELD_SIDE_FIFO2       = 4'h8;

always @(posedge Clk_i)
  tx_output_fifo_almost_full_reg <= TxFifoCount_i >= 32;
   
 /// Credit Handling
  always @(posedge Clk_i)
      begin
        if(Srst_i)
          mps_water_mark_cntr <= 11'd32;  /// 1 MPS  512B or 256B
        else if (buffer_read_enable)
          mps_water_mark_cntr <= mps_water_mark_cntr + 10'h1;
      end 
 
assign mps_available_sub = TLPGenBuffLimit_i - mps_water_mark_cntr; 
 
  always @(posedge Clk_i)
      begin
        if(Srst_i)
          buffer_consume_cntr <= 11'h0; 
        else if (buffer_read_enable) 
          buffer_consume_cntr <= buffer_consume_cntr + 11'h1;
      end 

always @(posedge Clk_i)      
   buffer_required_pointer <= buffer_consume_cntr + adjusted_lines_count_reg;


assign buffer_available_sub = TLPGenBuffLimit_i - buffer_required_pointer; // 2's complement

assign mps_ok = mps_available_sub <= 1024;  
assign payload_ok = buffer_available_sub <= 1024;

assign  tlp_in_one_clk =  ((~tlp_wr64 & address_bit2) & dw_size == 8'h1);


always @(posedge Clk_i)
  begin
    mps_ok_reg <= mps_ok;
    payload_ok_reg <= payload_ok;
    tlp_hdr_empty_reg <= TLPHeaderFifoEmpty_i;
  end
   
   /// main state machine
always @(posedge Clk_i)            
  begin
  	if(Srst_i)
  	   tlpgen_state <= 4'h0;
  	else
  	   tlpgen_state <= tlpgen_nxt_state;
  end




 always_comb
  begin
    case(tlpgen_state)
    	TLPGEN_IDLE:     
    	  if((side_fifo_pending & (arb_weight_cntr == 3'b001)) & ~tx_output_fifo_almost_full_reg)
    	    tlpgen_nxt_state <= TLPGEN_ARB_REQ_FOR_SIDE_FIFO;
    	  else if(~tlp_hdr_empty_reg & ~tx_output_fifo_almost_full_reg)
           tlpgen_nxt_state <= TLPGEN_ARB_REQ;
        else
           tlpgen_nxt_state <= TLPGEN_IDLE;
           
      TLPGEN_ARB_REQ_FOR_SIDE_FIFO:
        if(WrDmaGrant_i)
          tlpgen_nxt_state <= TLPGEN_YIELD_SIDE_FIFO;
        else
          tlpgen_nxt_state <= TLPGEN_ARB_REQ_FOR_SIDE_FIFO;
          
      TLPGEN_ARB_REQ:
       if(WrDmaGrant_i & mps_ok_reg & ~tx_output_fifo_almost_full_reg)
          tlpgen_nxt_state <= TLPGEN_HDR;  /// main stream 
        else if(WrDmaGrant_i & ~mps_ok_reg)   // pay load is low, slow down and check
          tlpgen_nxt_state <= TLPGEN_CREDIT_PIPE;
        else
          tlpgen_nxt_state <= TLPGEN_ARB_REQ;
     TLPGEN_HDR:
        if(tlp_in_one_clk)                     
           tlpgen_nxt_state <= TLPGEN_IDLE;
        else
           tlpgen_nxt_state <= TLPGEN_SEND;
          
      TLPGEN_SEND:
        if(side_fifo_pending & eop_flag)
          tlpgen_nxt_state <= TLPGEN_YIELD_SIDE_FIFO;
        else if(eop_flag & (descriptor_done | ~mps_ok_reg | HPRxmPending_i | tlp_hdr_empty_reg | tx_output_fifo_almost_full_reg) )
          tlpgen_nxt_state <= TLPGEN_IDLE;
        else if(eop_flag)
          tlpgen_nxt_state <= TLPGEN_HDR;
        else
          tlpgen_nxt_state <= TLPGEN_SEND;
                        
      TLPGEN_CREDIT_PIPE:   /// pipeline credit calculation
          tlpgen_nxt_state <= TLPGEN_CREDIT_PIPE2;
      
        TLPGEN_CREDIT_PIPE2:   /// pipeline credit calculation
         tlpgen_nxt_state <= TLPGEN_CREDIT_PIPE3;                           
                        
      TLPGEN_CREDIT_PIPE3:   /// pipeline credit calculation
         tlpgen_nxt_state <= TLPGEN_CHECK_PAYLOAD;         
            
      TLPGEN_CHECK_PAYLOAD:
        if(payload_ok_reg)
          tlpgen_nxt_state <= TLPGEN_HDR;
        else
          tlpgen_nxt_state <= TLPGEN_CHECK_PAYLOAD;
     
     TLPGEN_YIELD_SIDE_FIFO: /// read can transmit on this clock
       if(~tlp_hdr_empty_reg & mps_ok_reg & ~tx_output_fifo_almost_full_reg & tx_side_fifo_eop)
         tlpgen_nxt_state <= TLPGEN_CHECK_PAYLOAD;
       else if(~tx_side_fifo_eop)   /// TLP with data --- 2 clocks)
           tlpgen_nxt_state <= TLPGEN_YIELD_SIDE_FIFO2;     
       else
         tlpgen_nxt_state <= TLPGEN_IDLE;                  
    
     TLPGEN_YIELD_SIDE_FIFO2:
        if(~tlp_hdr_empty_reg & mps_ok_reg & ~tx_output_fifo_almost_full_reg)
           tlpgen_nxt_state <= TLPGEN_CHECK_PAYLOAD;
        else
         tlpgen_nxt_state <= TLPGEN_IDLE;  
     
     default:
       tlpgen_nxt_state <= TLPGEN_IDLE;
   endcase
 end

assign tlpgen_idle_state = (tlpgen_state == TLPGEN_IDLE );  
assign side_fifo_pending = SideFifoCount_i != 0;
assign tlpgen_send_state =  (tlpgen_state == TLPGEN_SEND );  
assign tlpgen_hdr_state =  (tlpgen_state == TLPGEN_HDR );   

assign data_in_hdr_state = (~tlp_wr64 & address_bit2) & dw_size <= 8'h3;

assign buffer_read_enable = tlpgen_send_state | tlpgen_hdr_state & data_in_hdr_state;
assign tlpgen_side_fifo_state = (tlpgen_state == TLPGEN_YIELD_SIDE_FIFO );     
assign tlpgen_side_fifo_state2 = (tlpgen_state == TLPGEN_YIELD_SIDE_FIFO2 );    
assign tlpgen_arb_req = ~tlpgen_idle_state;
assign sm_exit_send = tlp_hdr_empty_reg | ~mps_ok_reg | HPRxmPending_i | side_fifo_pending | descriptor_done;

assign tlp_header_rdreq = (tlpgen_idle_state &~((side_fifo_pending & arb_weight_cntr == 3'b001) & ~tx_output_fifo_almost_full_reg) & (~tlp_hdr_empty_reg & ~tx_output_fifo_almost_full_reg)) |
                          (tlpgen_send_state & eop_flag & ~sm_exit_send & ~tx_output_fifo_almost_full_reg) |
                          ( tlpgen_side_fifo_state & (~tlp_hdr_empty_reg & mps_ok_reg & ~tx_output_fifo_almost_full_reg & tx_side_fifo_eop)) |      
                          ( tlpgen_side_fifo_state2 & (~tlp_hdr_empty_reg & mps_ok_reg & ~tx_output_fifo_almost_full_reg))       ;


always @ (posedge Clk_i)
  tlp_header_rdreq_reg <=  tlp_header_rdreq;
  
always @ (posedge Clk_i)
  if(Srst_i)
     eop_flag_reg <=  1'b0;
  else if (buffer_read_enable & eop_flag)
     eop_flag_reg <=  1'b1;
  else
    eop_flag_reg <=  1'b0; 
     
always @ (posedge Clk_i )
begin
    if(Srst_i)
      descriptor_done_sreg <= 1'b0;
    else if(tlp_header_rdreq_reg  & descriptor_done)
       descriptor_done_sreg <= 1'b1;
    else if(eop_flag_reg)
       descriptor_done_sreg <= 1'b0;   
 end         
 
assign TLPHeaderFifoRdReq_o =  tlp_header_rdreq;

/// Credit update send logic
always @ (posedge Clk_i)
   begin
	   if(Srst_i)
	     credit_accumulator <= 11'h0;
	   else if(tlpgen_send_state)
	     credit_accumulator <= credit_accumulator + 10'h1;
	   else if(accumulator_unload)
	     credit_accumulator <=  10'h0;
	end

assign accumulator_unload = tlp_send_state_fall;

assign tlp_send_state_fall = tlpgen_send_state_reg & ~tlpgen_send_state;

assign TlpGenCreditUp_o = accumulator_unload;
assign TlpGenCred_o = credit_accumulator;

/// end credit update send logic

// latching the TLP header


always @ (posedge Clk_i)
begin
    header_fifo_reg[138:0] <= TLPHeaderFifoData_i[138:0];
end

always @ (posedge Clk_i)
begin
	if(Srst_i)
	   tlp_header_reg[138:0] <= 139'h0;
  else if(tlp_header_rdreq)
    tlp_header_reg[138:0] <= header_fifo_reg[138:0];
end
           
assign tlp_wr64 =   tlp_header_reg[29];
assign eop_flag =  AlignedRamData_i[129]; 
assign empty    = (eop_flag & ~tlpgen_hdr_state)? tlp_header_reg[128]:1'b0;
assign desc_id  =  tlp_header_reg[137:130];
assign dw_size[7:0]  = tlp_header_reg[7:0];
assign address_bit2 = tlp_wr64? tlp_header_reg[98] : tlp_header_reg[66];
assign descriptor_done = tlp_header_reg[138];
assign header_in_dw0 = tlp_header_reg[31:0];    
assign header_in_dw1 = tlp_header_reg[63:32];   
assign header_in_dw2 = tlp_header_reg[95:64];   
assign header_in_dw3 = tlp_header_reg[127:96];  
assign data_in_dw0 = AlignedRamData_i[31:0];    
assign data_in_dw1 = AlignedRamData_i[63:32];   
assign data_in_dw2 = AlignedRamData_i[95:64];   
assign data_in_dw3 = AlignedRamData_i[127:96];  


        always @ *
            begin
              case (tlpgen_hdr_state)  
                 1'b1: /// sop, mux in the header
                    case(tlp_wr64)
                    	 1'b0:
                    	  begin
                    	   tlp_dw0 <= header_in_dw0;       
                         tlp_dw1 <= header_in_dw1;
                         tlp_dw2 <= header_in_dw2;
                         tlp_dw3 <= data_in_dw3;
                        end
                       default:
                        begin
                          tlp_dw0 <= header_in_dw0;       
                          tlp_dw1 <= header_in_dw1;
                          tlp_dw2 <= header_in_dw2;
                          tlp_dw3 <= header_in_dw3;
                        end
                    endcase
                          
                 default:  /// not sop
                   begin
                     tlp_dw0 <= data_in_dw0;       
                     tlp_dw1 <= data_in_dw1;
                     tlp_dw2 <= data_in_dw2;
                     tlp_dw3 <= data_in_dw3;
                   end  
              endcase
            end
    
 
 //// Ram address counter
 /// Buffer address pointer
 
 assign AlignedRamRdAddr_o[9:0] = (buffer_read_enable)? (ram_addr_reg + 1'b1) : ram_addr_reg;
 
always @ (posedge Clk_i)
begin
  if(Srst_i)
    ram_addr_reg[9:0] <= 10'h0;
  else
     ram_addr_reg <= AlignedRamRdAddr_o;
 end          
                        
 /// Tx output FIFO interface
 assign tx_mwr_fifo_wrreq =  tlpgen_send_state | tlpgen_hdr_state;
 assign tx_mwr_fifo_data  = { empty, (tlp_in_one_clk | eop_flag & ~tlpgen_hdr_state), tlpgen_hdr_state, tlp_dw3, tlp_dw2, tlp_dw1, tlp_dw0};
 
assign tx_side_fifo_wrreq = tlpgen_side_fifo_state | tlpgen_side_fifo_state2; // Squeeze in one additional TLP 
 assign tx_side_fifo_data  = SideFifoData_i;    
 assign tx_side_fifo_eop   = SideFifoData_i[129];
 
 assign tx_output_fifo_wrreq = tx_mwr_fifo_wrreq | tx_side_fifo_wrreq;
 assign tx_output_fifo_data  = (tlpgen_side_fifo_state | tlpgen_side_fifo_state2)? tx_side_fifo_data : tx_mwr_fifo_data;                    
always @ (posedge Clk_i)
   begin
     tx_output_fifo_wrreq_reg <= tx_output_fifo_wrreq;
     tx_output_fifo_data_reg  <= tx_output_fifo_data;
     tlpgen_send_state_reg    <= tlpgen_send_state;

   end                                   
 
assign TxFifoWrReq_o = tx_output_fifo_wrreq_reg;  
assign TxFifoData_o  = tx_output_fifo_data_reg;
     assign SideFifoRdreq_o = tlpgen_side_fifo_state | tlpgen_side_fifo_state2;
/// descriptor completion status
 
 assign desc_completed = eop_flag_reg & descriptor_done_sreg;
 assign WrDmaDescID_o = {23'h0,1'b1,desc_id};
 assign WrDmaArbReq_o = tlpgen_arb_req;
 assign WrDMADescDone_o = desc_completed;
 
 
 /// caculate the total lines needed for current header
 // to decide to start transmitting
 
 assign add_1_sel = (tlp_wr64 & address_bit2);
 assign add_3_sel = (~tlp_wr64 & address_bit2);
 
 assign adjust_dw_sel = {add_3_sel, add_1_sel};
 
 always @ *
   case(adjust_dw_sel)
   	  2'b01: adjusted_dw_count  = dw_size + 2'h1;
   	  2'b10: adjusted_dw_count  = dw_size + 2'h3;
   	  default: adjusted_dw_count = dw_size;
   endcase
        	 	
 
always @ (posedge Clk_i)
   adjusted_dw_size_reg[7:0] <= adjusted_dw_count[7:0];
   
assign adjusted_lines_count = adjusted_dw_size_reg[7:2] + |adjusted_dw_size_reg[1:0];

always @ (posedge Clk_i)
   adjusted_lines_count_reg[5:0] <=adjusted_lines_count;

/// arbitration weight counter

always @(posedge Clk_i)
 begin
  if(Srst_i)
    arb_weight_cntr <= 3'b000;
  else if(arb_weight_cntr == DMA_WR_ARBITER_WEIGH)
    arb_weight_cntr <= 3'b000;
  else
    arb_weight_cntr <= arb_weight_cntr + 1'b1;
 end
    //synthesis translate_off
 initial begin
    adjusted_lines_count_reg = 0;
    mps_ok_reg = 0; 
    payload_ok_reg = 0;
    tlp_header_reg = 0;
    tx_output_fifo_wrreq_reg = 0;
    tx_output_fifo_data_reg = 0; 
    tlpgen_send_state_reg = 0;   
           
    adjusted_dw_size_reg = 0;                    
    ram_addr_reg = 0;
    tlp_hdr_empty_reg = 0;
    tx_output_fifo_almost_full_reg = 0;
   end
     //synthesis translate_on
    
   	
endmodule
 
         
       
              