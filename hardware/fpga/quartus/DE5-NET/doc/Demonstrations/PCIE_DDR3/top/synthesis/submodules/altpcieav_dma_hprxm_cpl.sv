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

module altpcieav_dma_hprxm_cpl
 # (

      parameter AVMM_WIDTH                      = 256

   )
   
   
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,
      
    // interface to the Rx pending read FIFO
      input  logic                                 PndgRdFifoEmpty_i,
      input  logic   [56:0]                        PndgRdFifoDato_i,
      output logic                                 PndgRdFifoRdReq_o,
            // Avalon HP Tx Read Data Interface
      input  logic                                 HPRxmReadDataValid_i,
      
        // Interface to the Command Fifo
      output logic   [98:0]                        CmdFifoDatin_o,
      output logic                                 CmdFifoWrReq_o,
      input  logic   [3:0]                         CmdFifoUsedw_i,
  
        // Interface to Completion data buffer                                            
     output logic   [8:0]                          CplRamWrAddr_o,
     
      // cfg signals                                        
 
    input logic   [31:0]                         DevCsr_i
   );
   
localparam      TXRESP_IDLE          = 14'h0;
localparam      TXRESP_RD_FIFO       = 14'h1;
localparam      TXRESP_LD_BCNT       = 14'h2;
localparam      TXRESP_WAIT_DATA     = 14'h3;
localparam      TXRESP_SEND_FIRST    = 14'h4;
localparam      TXRESP_SEND_LAST     = 14'h5;
localparam      TXRESP_SEND_MAX      = 14'h6;
localparam      TXRESP_DONE          = 14'h7;
localparam      TXRESP_WAIT_FIRST    = 14'h8;
localparam      TXRESP_WAIT_MAX      = 14'h9;
localparam      TXRESP_WAIT_LAST     = 14'hA;    
localparam      TXRESP_PIPE_FIRST    = 14'hB;
localparam      TXRESP_PIPE_MAX      = 14'hC;
localparam      TXRESP_PIPE_LAST     = 14'hD;  

localparam      BYTES_PER_CLOCK = (AVMM_WIDTH == 256)? 6'h20 : 6'h10;

logic            sm_rd_fifo;      
logic            sm_ld_bcnt;     
logic            sm_wait_data;   
logic            sm_send_first;  
logic            sm_send_last;
logic   [8:0]    bytes_to_RCB_128MPS;      
logic   [8:0]    bytes_to_RCB_256MPS;
logic            over_rd_2dw;
logic            over_rd_1dw;
logic   [12:0]   first_bytes_sent;
logic   [12:0]   first_bytes_sent_reg;
logic   [12:0]   last_bytes_sent_reg;
logic   [12:0]   max_bytes_sent_reg;
logic   [12:0]   max_bytes_sent;
logic   [12:0]   last_bytes_sent;
logic   [7:0]    tag;        
logic   [15:0]  requester_id; 
logic    [7:0]  rd_addr;      
logic    [10:0] rd_dwlen;     
logic    [1:0]  attr;
logic   [2:0]   tc;
logic    [12:0] remain_bytes;
logic    [12:0] remain_bytes_reg;
logic           is_flush;
logic           is_uns_rd_size;
logic           is_cpl;
logic   [8:0]   dw_len;
logic   [3:0]   first_byte_mask;
logic   [3:0]   last_byte_mask;
logic   [3:0]   laddf_bytes_mask_reg;
logic   [13:0]  txresp_state;
logic   [13:0]  txresp_nxt_state;
logic           first_cpl_sreg;
logic           first_cpl;
logic  [8:0]    bytes_to_RCB_reg;
logic  [12:0]   curr_bcnt_reg;
logic  [12:0]   max_payload;
logic  [13:0]   payload_cntr;  
logic  [14:0]   payload_limit_cntr;
logic  [14:0]   payload_consumed_cntr; 
logic  [14:0]   payload_required_reg;
logic  [14:0]   payload_available_sub;
logic           payload_ok;
logic           payload_ok_reg;
logic  [5:0]    over_rd_bytes;
logic  [5:0]    over_rd_bytes_reg;
logic  [12:0]   bytes_sent;
logic  [12:0]   actual_bytes_sent;
logic  [12:0]   sent_bcnt_reg;
logic  [6:0]    lower_addr;
logic  [6:0]    lower_addr_reg;
logic  [8:0]    cplbuff_addr_cntr;
logic           cmd_fifo_ok;
logic           sm_send_max;
logic           sm_wait_first;
logic           sm_wait_last;
logic           sm_wait_max;
logic           sm_idle;
logic    [6:0]  over_read_sel;
    
 
 generate if(AVMM_WIDTH == 256)
   begin
     logic           rd_dwlen_gte_8;  
   end
 else
   begin
    logic           rd_dwlen_gte_4;  
   end
endgenerate
 
 
assign tag            = PndgRdFifoDato_i[7:0];
assign requester_id   = PndgRdFifoDato_i[31:16];
assign rd_addr[7:0]   = {PndgRdFifoDato_i[15:10], 2'b00};
assign rd_dwlen       = (PndgRdFifoDato_i[41:32] == 10'h0)? 11'b100_0000_0000 : {1'b0,PndgRdFifoDato_i[41:32]};
assign attr           = PndgRdFifoDato_i[47:46];
assign tc             = PndgRdFifoDato_i[50:48];
assign is_flush       = PndgRdFifoDato_i[15];
assign is_uns_rd_size = PndgRdFifoDato_i[56];

assign dw_len[8:0] = is_uns_rd_size? 9'h0 :  bytes_sent[10:2];


assign cmd_fifo_ok = (CmdFifoUsedw_i < 8);
     
always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      txresp_state <= TXRESP_IDLE;
    else
      txresp_state <= txresp_nxt_state;
  end

// state machine next state gen
always @*
         
  begin
    case(txresp_state)
      TXRESP_IDLE :
        if(~PndgRdFifoEmpty_i)      
          txresp_nxt_state <= TXRESP_RD_FIFO;            
        else
          txresp_nxt_state <= TXRESP_IDLE;            
        
      TXRESP_RD_FIFO : 
          txresp_nxt_state <= TXRESP_LD_BCNT;    
       
      TXRESP_LD_BCNT:  // load byte count reg and calculate the first byte 7 bit of address
           txresp_nxt_state <= TXRESP_WAIT_DATA;
      
      TXRESP_WAIT_DATA:
      
        if(first_cpl_sreg & cmd_fifo_ok & (  is_flush | is_uns_rd_size ))
          txresp_nxt_state <= TXRESP_SEND_LAST;
        else  if(first_cpl_sreg & cmd_fifo_ok &((curr_bcnt_reg > bytes_to_RCB_reg)))
          txresp_nxt_state <= TXRESP_WAIT_FIRST;
        
        else if((first_cpl_sreg & cmd_fifo_ok &(((curr_bcnt_reg <= bytes_to_RCB_reg)) ) ) |
                (~first_cpl_sreg & cmd_fifo_ok &(curr_bcnt_reg <= max_payload) )
                 )
          txresp_nxt_state <= TXRESP_WAIT_LAST;
       
        else if(~first_cpl_sreg & cmd_fifo_ok & (curr_bcnt_reg >  max_payload))
          txresp_nxt_state <= TXRESP_WAIT_MAX;
        else
          txresp_nxt_state <= TXRESP_WAIT_DATA;
          
      TXRESP_WAIT_FIRST:
           txresp_nxt_state <= TXRESP_PIPE_FIRST;
           
      TXRESP_PIPE_FIRST:
           if(payload_ok_reg & cmd_fifo_ok)
             txresp_nxt_state <= TXRESP_SEND_FIRST;  
           else
             txresp_nxt_state <= TXRESP_PIPE_FIRST;   
             
      TXRESP_WAIT_MAX:
                 txresp_nxt_state <= TXRESP_PIPE_MAX;    
         
       TXRESP_PIPE_MAX:                               
         if(payload_ok_reg & cmd_fifo_ok)                                
            txresp_nxt_state <= TXRESP_SEND_MAX;      
          else                                          
            txresp_nxt_state <= TXRESP_PIPE_MAX;   
              
        TXRESP_WAIT_LAST:                                       
                   txresp_nxt_state <= TXRESP_PIPE_LAST;
                       
        TXRESP_PIPE_LAST:                               
         if(payload_ok_reg & cmd_fifo_ok)                                
            txresp_nxt_state <= TXRESP_SEND_LAST;      
          else                                          
            txresp_nxt_state <= TXRESP_PIPE_LAST;   
            
                                                 
       TXRESP_SEND_FIRST:
           txresp_nxt_state <= TXRESP_WAIT_DATA;
           
       TXRESP_SEND_LAST:
         txresp_nxt_state <= TXRESP_DONE;
         
       TXRESP_SEND_MAX:
         if(remain_bytes_reg == 0)
           txresp_nxt_state <= TXRESP_DONE;
         else
           txresp_nxt_state <= TXRESP_WAIT_DATA;
       
       TXRESP_DONE:
           txresp_nxt_state <= TXRESP_IDLE;
       
       default:
         txresp_nxt_state <= TXRESP_IDLE;
      
    endcase
 end

 /// state machine output assignments                       
 assign   sm_idle       = (txresp_state == TXRESP_IDLE);      
 assign   sm_rd_fifo    = (txresp_state == TXRESP_RD_FIFO);   
 assign   sm_ld_bcnt    = (txresp_state == TXRESP_LD_BCNT);   
 assign   sm_wait_data  = (txresp_state == TXRESP_WAIT_DATA); 
 assign   sm_send_first = (txresp_state == TXRESP_SEND_FIRST);
 assign   sm_send_last  = (txresp_state == TXRESP_SEND_LAST); 
 assign   sm_send_max   = (txresp_state == TXRESP_SEND_MAX);  
 assign   sm_wait_first = (txresp_state == TXRESP_WAIT_FIRST);
 assign   sm_wait_max   = (txresp_state == TXRESP_WAIT_MAX);  
 assign   sm_wait_last  = (txresp_state == TXRESP_WAIT_LAST); 
                                                            
 // SR reg to indicate the first completion of a read       
always @(posedge Clk_i)                                     
  begin
     if(sm_ld_bcnt)
       first_cpl_sreg <= 1'b1;
     else if(sm_send_first)
       first_cpl_sreg <= 1'b0;
  end                                                                                                                    

// calculate the bytes to RCB that could be 128 or 256Bytes (6 or 7 zeros in address), for MPS 128, 256 respectively
assign bytes_to_RCB_128MPS = 8'h80 - rd_addr[6:0];
assign bytes_to_RCB_256MPS = 9'h100 - rd_addr[7:0];



always @(posedge Clk_i)
  begin
      bytes_to_RCB_reg <= (max_payload == 128)? bytes_to_RCB_128MPS : bytes_to_RCB_256MPS;
  end

 /// the current byte count register that still need to be sent (completed)
 always @(posedge Clk_i)
  begin
    if(sm_ld_bcnt)
      curr_bcnt_reg <= {rd_dwlen, 2'b00};
    else if(sm_send_first)
      curr_bcnt_reg <= curr_bcnt_reg - bytes_to_RCB_reg;
    else if(sm_send_max)
      curr_bcnt_reg <= curr_bcnt_reg - max_payload;
    else if(sm_send_last)
      curr_bcnt_reg <= 0;
  end

/// the remaining bcnt (for the header)
 assign remain_bytes = is_flush? 13'h1  : curr_bcnt_reg;

always @(posedge Clk_i)         
  begin
      remain_bytes_reg <= remain_bytes;
  end
      
   /// Credit Limit Reg === payload_cntr (count up only by TxReadDatValid))
  /// Credit Consume Reg == updated by send first, max, last (count up only)
  
  // Credit Required = actual byte sent 
  
    always_ff @(posedge Clk_i)
      begin
        if(~Rstn_i)
          payload_limit_cntr <= 15'h0; 
        else if (HPRxmReadDataValid_i)
          payload_limit_cntr <= payload_limit_cntr + BYTES_PER_CLOCK; /// 256 bit data
      end
 
/// Credit Consumed Counter
   always @(posedge Clk_i or negedge Rstn_i)
      begin
        if(~Rstn_i)
          payload_consumed_cntr <= 0; 
        else if(sm_ld_bcnt & ~is_flush & ~is_uns_rd_size)
          payload_consumed_cntr <= payload_consumed_cntr + over_rd_bytes_reg;
        else if (sm_send_first | sm_send_max | sm_send_last)
          payload_consumed_cntr <= payload_consumed_cntr + actual_bytes_sent[9:0];
      end

 always @(posedge Clk_i or negedge Rstn_i)
      begin
        if(~Rstn_i)
          payload_required_reg <= 15'h0;
        else if(sm_wait_first)
          payload_required_reg <= payload_consumed_cntr + first_bytes_sent_reg[9:0];
        else if (sm_wait_last)
         payload_required_reg <= payload_consumed_cntr + last_bytes_sent_reg[9:0];
        else if (sm_wait_max)
         payload_required_reg <= payload_consumed_cntr + max_bytes_sent_reg[9:0];
      end
      
  assign payload_available_sub = (payload_limit_cntr - payload_required_reg);
  
  assign payload_ok = payload_available_sub <= 16384 & ~sm_idle & ~sm_rd_fifo & ~sm_ld_bcnt & ~sm_wait_data & ~sm_wait_first & ~sm_wait_max & ~sm_wait_last;
   
    always @(posedge Clk_i)
      begin
          payload_ok_reg <= payload_ok;
      end
      

/// Calculate over read bytes caculation due to more data being read from the 
// avalon to compensate for the 32-bit to 256-bit address alignment
generate if(AVMM_WIDTH == 256)
     begin
        assign rd_dwlen_gte_8 =   |rd_dwlen[10:3];
        assign over_read_sel = {rd_dwlen_gte_8, rd_addr[4:2], rd_dwlen[2:0]};
            
            always @ *
              begin
                case (over_read_sel)   
                  7'b1_000_000:  over_rd_bytes <= 6'd0;   
                  7'b1_000_001:  over_rd_bytes <= 6'd28;
                  7'b1_000_010:  over_rd_bytes <= 6'd24;  
                  7'b1_000_011:  over_rd_bytes <= 6'd20;   
                  7'b1_000_100:  over_rd_bytes <= 6'd16;
                  7'b1_000_101:  over_rd_bytes <= 6'd12; 
                  7'b1_000_110:  over_rd_bytes <= 6'd8;  
                  7'b1_000_111:  over_rd_bytes <= 6'd4;

                  7'b1_001_000:  over_rd_bytes <= 6'd32;   
                  7'b1_001_001:  over_rd_bytes <= 6'd28;
                  7'b1_001_010:  over_rd_bytes <= 6'd24;  
                  7'b1_001_011:  over_rd_bytes <= 6'd20;   
                  7'b1_001_100:  over_rd_bytes <= 6'd16;
                  7'b1_001_101:  over_rd_bytes <= 6'd12; 
                  7'b1_001_110:  over_rd_bytes <= 6'd8;  
                  7'b1_001_111:  over_rd_bytes <= 6'd4;

                  7'b1_010_000:  over_rd_bytes <= 6'd32;
                  7'b1_010_001:  over_rd_bytes <= 6'd28;
                  7'b1_010_010:  over_rd_bytes <= 6'd24;
                  7'b1_010_011:  over_rd_bytes <= 6'd20;
                  7'b1_010_100:  over_rd_bytes <= 6'd16;
                  7'b1_010_101:  over_rd_bytes <= 6'd12;
                  7'b1_010_110:  over_rd_bytes <= 6'd8 ;
                  7'b1_010_111:  over_rd_bytes <= 6'd36;      

                  7'b1_011_000:  over_rd_bytes <= 6'd32;
                  7'b1_011_001:  over_rd_bytes <= 6'd28;
                  7'b1_011_010:  over_rd_bytes <= 6'd24;
                  7'b1_011_011:  over_rd_bytes <= 6'd20;
                  7'b1_011_100:  over_rd_bytes <= 6'd16;
                  7'b1_011_101:  over_rd_bytes <= 6'd12;
                  7'b1_011_110:  over_rd_bytes <= 6'd40;
                  7'b1_011_111:  over_rd_bytes <= 6'd36;           

                  7'b1_100_000:  over_rd_bytes <= 6'd32;       
                  7'b1_100_001:  over_rd_bytes <= 6'd28;       
                  7'b1_100_010:  over_rd_bytes <= 6'd24;       
                  7'b1_100_011:  over_rd_bytes <= 6'd20;       
                  7'b1_100_100:  over_rd_bytes <= 6'd16;       
                  7'b1_100_101:  over_rd_bytes <= 6'd44;       
                  7'b1_100_110:  over_rd_bytes <= 6'd40;       
                  7'b1_100_111:  over_rd_bytes <= 6'd36;       

                  7'b1_101_000:  over_rd_bytes <= 6'd32;       
                  7'b1_101_001:  over_rd_bytes <= 6'd28;       
                  7'b1_101_010:  over_rd_bytes <= 6'd24;       
                  7'b1_101_011:  over_rd_bytes <= 6'd20;       
                  7'b1_101_100:  over_rd_bytes <= 6'd48;       
                  7'b1_101_101:  over_rd_bytes <= 6'd44;       
                  7'b1_101_110:  over_rd_bytes <= 6'd40;       
                  7'b1_101_111:  over_rd_bytes <= 6'd36;            

                  7'b1_110_000:  over_rd_bytes <= 6'd32;       
                  7'b1_110_001:  over_rd_bytes <= 6'd28;       
                  7'b1_110_010:  over_rd_bytes <= 6'd24;  //    7'b1_110_010:  over_rd_bytes <= 6'd28;    
                  7'b1_110_011:  over_rd_bytes <= 6'd52;       
                  7'b1_110_100:  over_rd_bytes <= 6'd48;       
                  7'b1_110_101:  over_rd_bytes <= 6'd44;       
                  7'b1_110_110:  over_rd_bytes <= 6'd40;       
                  7'b1_110_111:  over_rd_bytes <= 6'd36;      

                  7'b1_111_000:  over_rd_bytes <= 6'd32;       
                  7'b1_111_001:  over_rd_bytes <= 6'd28;       
                  7'b1_111_010:  over_rd_bytes <= 6'd56;       
                  7'b1_111_011:  over_rd_bytes <= 6'd52;       
                  7'b1_111_100:  over_rd_bytes <= 6'd48;       
                  7'b1_111_101:  over_rd_bytes <= 6'd44;       
                  7'b1_111_110:  over_rd_bytes <= 6'd40;       
                  7'b1_111_111:  over_rd_bytes <= 6'd36;                                                 

                  7'b0_000_000:  over_rd_bytes <= 6'd0;   
                  7'b0_000_001:  over_rd_bytes <= 6'd28;
                  7'b0_000_010:  over_rd_bytes <= 6'd24;  
                  7'b0_000_011:  over_rd_bytes <= 6'd20;   
                  7'b0_000_100:  over_rd_bytes <= 6'd16;
                  7'b0_000_101:  over_rd_bytes <= 6'd12; 
                  7'b0_000_110:  over_rd_bytes <= 6'd8;  
                  7'b0_000_111:  over_rd_bytes <= 6'd4; 

                  7'b0_001_000:  over_rd_bytes <= 6'd32;   
                  7'b0_001_001:  over_rd_bytes <= 6'd28;
                  7'b0_001_010:  over_rd_bytes <= 6'd24;  
                  7'b0_001_011:  over_rd_bytes <= 6'd20;   
                  7'b0_001_100:  over_rd_bytes <= 6'd16;
                  7'b0_001_101:  over_rd_bytes <= 6'd12; 
                  7'b0_001_110:  over_rd_bytes <= 6'd8;  
                  7'b0_001_111:  over_rd_bytes <= 6'd4; 

                  7'b0_010_000:  over_rd_bytes <= 6'd32;
                  7'b0_010_001:  over_rd_bytes <= 6'd28;
                  7'b0_010_010:  over_rd_bytes <= 6'd24;
                  7'b0_010_011:  over_rd_bytes <= 6'd20;
                  7'b0_010_100:  over_rd_bytes <= 6'd16;
                  7'b0_010_101:  over_rd_bytes <= 6'd12;
                  7'b0_010_110:  over_rd_bytes <= 6'd8; 
                  7'b0_010_111:  over_rd_bytes <= 6'd32;      

                  7'b0_011_000:  over_rd_bytes <= 6'd32;
                  7'b0_011_001:  over_rd_bytes <= 6'd28;
                  7'b0_011_010:  over_rd_bytes <= 6'd24;
                  7'b0_011_011:  over_rd_bytes <= 6'd20;
                  7'b0_011_100:  over_rd_bytes <= 6'd16;
                  7'b0_011_101:  over_rd_bytes <= 6'd12;
                  7'b0_011_110:  over_rd_bytes <= 6'd40;
                  7'b0_011_111:  over_rd_bytes <= 6'd36;          

                  7'b0_100_000:  over_rd_bytes <= 6'd32;      
                  7'b0_100_001:  over_rd_bytes <= 6'd28;      
                  7'b0_100_010:  over_rd_bytes <= 6'd24;      
                  7'b0_100_011:  over_rd_bytes <= 6'd20;      
                  7'b0_100_100:  over_rd_bytes <= 6'd16;      
                  7'b0_100_101:  over_rd_bytes <= 6'd44;      
                  7'b0_100_110:  over_rd_bytes <= 6'd40;      
                  7'b0_100_111:  over_rd_bytes <= 6'd36;      

                  7'b0_101_000:  over_rd_bytes <= 6'd32;       
                  7'b0_101_001:  over_rd_bytes <= 6'd28;       
                  7'b0_101_010:  over_rd_bytes <= 6'd24;       
                  7'b0_101_011:  over_rd_bytes <= 6'd20;       
                  7'b0_101_100:  over_rd_bytes <= 6'd48;       
                  7'b0_101_101:  over_rd_bytes <= 6'd44;       
                  7'b0_101_110:  over_rd_bytes <= 6'd40;       
                  7'b0_101_111:  over_rd_bytes <= 6'd36;            

                  7'b0_110_000:  over_rd_bytes <= 6'd32;       
                  7'b0_110_001:  over_rd_bytes <= 6'd28;       
                  7'b0_110_010:  over_rd_bytes <= 6'd24;   //          7'b0_110_010:  over_rd_bytes <= 6'd28;
                  7'b0_110_011:  over_rd_bytes <= 6'd52;       
                  7'b0_110_100:  over_rd_bytes <= 6'd48;       
                  7'b0_110_101:  over_rd_bytes <= 6'd44;       
                  7'b0_110_110:  over_rd_bytes <= 6'd40;       
                  7'b0_110_111:  over_rd_bytes <= 6'd36;      

                  7'b0_111_000:  over_rd_bytes <= 6'd32;      
                  7'b0_111_001:  over_rd_bytes <= 6'd28;      
                  7'b0_111_010:  over_rd_bytes <= 6'd56;      
                  7'b0_111_011:  over_rd_bytes <= 6'd52;      
                  7'b0_111_100:  over_rd_bytes <= 6'd48;      
                  7'b0_111_101:  over_rd_bytes <= 6'd44;      
                  7'b0_111_110:  over_rd_bytes <= 6'd40;      
                  7'b0_111_111:  over_rd_bytes <= 6'd36;       
                  
                  default:     over_rd_bytes <= 6'd0;
                endcase
              end  
     end
 else                       /// 128-bit
     begin
         assign rd_dwlen_gte_4 =   |rd_dwlen[10:2];
         assign over_read_sel = {rd_dwlen_gte_4, rd_addr[3:0], rd_dwlen[1:0]};
    
        always @ *
          begin
            case (over_read_sel)   
              7'b1_0000_00:  over_rd_bytes[5:0] <= 6'd0;   
              7'b1_0000_01:  over_rd_bytes[5:0] <= 6'd12;
              7'b1_0000_10:  over_rd_bytes[5:0] <= 6'd8;  
              7'b1_0000_11:  over_rd_bytes[5:0] <= 6'd4; 
                                         
              7'b1_0100_00:  over_rd_bytes[5:0] <= 6'd16; 
              7'b1_0100_01:  over_rd_bytes[5:0] <= 6'd12;   
              7'b1_0100_10:  over_rd_bytes[5:0] <= 6'd8;
              7'b1_0100_11:  over_rd_bytes[5:0] <= 6'd4;
                                        
              7'b1_1000_00:  over_rd_bytes[5:0] <= 6'd16;
              7'b1_1000_01:  over_rd_bytes[5:0] <= 6'd12;
              7'b1_1000_10:  over_rd_bytes[5:0] <= 6'd8;
              7'b1_1000_11:  over_rd_bytes[5:0] <= 6'd20;
                                         
              7'b1_1100_00:  over_rd_bytes[5:0] <= 6'd16;
              7'b1_1100_01:  over_rd_bytes[5:0] <= 6'd12;
              7'b1_1100_10:  over_rd_bytes[5:0] <= 6'd24;
              7'b1_1100_11:  over_rd_bytes[5:0] <= 6'd20;   
              
              7'b0_0000_00:  over_rd_bytes[5:0] <= 6'd0;   
              7'b0_0000_01:  over_rd_bytes[5:0] <= 6'd12;   
              7'b0_0000_10:  over_rd_bytes[5:0] <= 6'd8;  
              7'b0_0000_11:  over_rd_bytes[5:0] <= 6'd4;   
                                         
              7'b0_0100_00:  over_rd_bytes[5:0] <= 6'd0; 
              7'b0_0100_01:  over_rd_bytes[5:0] <= 6'd12;   
              7'b0_0100_10:  over_rd_bytes[5:0] <= 6'd8;
              7'b0_0100_11:  over_rd_bytes[5:0] <= 6'd4;
                                        
              7'b0_1000_00:  over_rd_bytes[5:0] <= 6'd0;
              7'b0_1000_01:  over_rd_bytes[5:0] <= 6'd12;
              7'b0_1000_10:  over_rd_bytes[5:0] <= 6'd8;
              7'b0_1000_11:  over_rd_bytes[5:0] <= 6'd20;
                                         
              7'b0_1100_00:  over_rd_bytes[5:0] <= 6'd0;
              7'b0_1100_01:  over_rd_bytes[5:0] <= 6'd12;
              7'b0_1100_10:  over_rd_bytes[5:0] <= 6'd24;
              7'b0_1100_11:  over_rd_bytes[5:0] <= 6'd20;   
              
              default:     over_rd_bytes[5:0] <= 6'd0;
            endcase
          end

     end
endgenerate         
   

always @(posedge Clk_i)
  begin
      over_rd_bytes_reg <= over_rd_bytes;
  end  
 
// sent_byte count for a cmpletion header
assign first_bytes_sent  =  bytes_to_RCB_reg;
assign max_bytes_sent    =  max_payload;
assign last_bytes_sent   =  curr_bcnt_reg;


/// 
always @(posedge Clk_i)
  begin
     begin
      first_bytes_sent_reg <= first_bytes_sent;
      last_bytes_sent_reg <= last_bytes_sent;
      max_bytes_sent_reg <= max_bytes_sent;
     end
  end  


always @*
  begin
    case({sm_send_first, sm_send_max, sm_send_last, is_flush, is_uns_rd_size})
      5'b00100 : bytes_sent = last_bytes_sent_reg;
      5'b01000 : bytes_sent = max_bytes_sent_reg;
      5'b10000 : bytes_sent = first_bytes_sent_reg;
      5'b00110 : bytes_sent = 4;
      default : bytes_sent = 0;
    endcase
  end

// actual byte sent is less due dummy flush read data
always @*
  begin
    case({sm_send_first, sm_send_max, sm_send_last, is_flush, is_uns_rd_size})
      5'b00100 : actual_bytes_sent = last_bytes_sent_reg;
      5'b01000 : actual_bytes_sent = max_bytes_sent_reg;
      5'b10000 : actual_bytes_sent = first_bytes_sent_reg;
      default :  actual_bytes_sent = 0;
    endcase
  end 
 
// calculate the 7 bit lower address of the first enable byte
// based on the first byte enable
always @(posedge Clk_i)
  begin
    if(sm_send_first)
      lower_addr_reg <= 0;
    else if(sm_ld_bcnt)
      lower_addr_reg <= {rd_addr[6:2], 2'b00};
    end      

///// Assemble the completion headers
// decode the max payload size
always @*
  begin
    case(DevCsr_i[7:5])
      3'b000 : max_payload = 128;
      default : max_payload = 256; // if >= 256 set to 256
    endcase
  end
 
assign CmdFifoDatin_o[98:0] = { 3'b000 ,attr[1:0], dw_len[8:0], tc[2:0], remain_bytes_reg[11:0], is_flush, first_cpl_sreg, 4'h0,       // 3+2+9+3+12+1+5 = 3
                                              32'h0, is_uns_rd_size, requester_id[15:0], tag[7:0], lower_addr_reg[6:0]}; // 32+1+16+8+7 = 64
                                              
assign CmdFifoWrReq_o = sm_send_first | sm_send_last | sm_send_max;

assign PndgRdFifoRdReq_o = sm_rd_fifo;

/// Completion buffer write address

always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      cplbuff_addr_cntr <= 0;
    else if(HPRxmReadDataValid_i)
      cplbuff_addr_cntr <= cplbuff_addr_cntr + 9'h1;
    end


assign CplRamWrAddr_o = cplbuff_addr_cntr;

  
endmodule
