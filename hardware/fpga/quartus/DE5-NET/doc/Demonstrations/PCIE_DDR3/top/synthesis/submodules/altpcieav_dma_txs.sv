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

module altpcieav_dma_txs # (
      parameter TX_S_ADDR_WIDTH              = 31,
      parameter DMA_WIDTH                    = 256,
      parameter RXFIFO_DATA_WIDTH            = 266,
      parameter EXTENDED_TAG_ENABLE          = 0
   )
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,

   // TXS Slave Port
      input   logic                               TxsChipSelect_i,
      input  logic                                TxsWrite_i,
      input  logic  [TX_S_ADDR_WIDTH+8-1:0]       TxsAddress_i,
      input  logic  [31:0]                        TxsWriteData_i,
      input  logic  [3:0]                         TxsByteEnable_i,
      output logic                                TxsWaitRequest_o,
      input  logic                                TxsRead_i,
      output logic  [31:0]                        TxsReadData_o,
      output logic                                TxsReadDataValid_o,

       // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [RXFIFO_DATA_WIDTH-1:0]                         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,

          // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [259:0]                         TxFifoData_o,
      input  logic [3:0]                           TxFifoCount_i,

     // Arbiter Interface
      output logic                                 TxsArbReq_o,
      input logic                                  TxsArbGranted_i,

      input                                        MasterEnable_i,
      input  logic [12:0]                          BusDev_i

  );

      //state machine encoding
     localparam  TXS_IDLE                  = 6'h01;
     localparam  TXS_ARB_REQ               = 6'h02;
     localparam  TXS_WRITE_HEADER          = 6'h04;
     localparam  TXS_READ_HEADER           = 6'h08;
     localparam  TXS_WAIT_CPL              = 6'h10;
     localparam  TXS_RDATA_VALID           = 6'h20;


   logic                                             tx_fifo_ok;
   logic                                             rx_fifo_empty;
   logic    [5:0]                                    txs_state;
   logic    [5:0]                                    txs_nxt_state;
   logic                                             rx_sop;
   logic                                             rx_eop;
   logic                                             rx_eop_reg;
   logic                                             rx_eop_d;
   logic                                             is_cpl_wd;
   logic    [7:0]                                    cpl_tag;
   logic    [TX_S_ADDR_WIDTH-1:0]                 txs_address_reg;
   logic    [31:0]                                   txs_data_reg;
   logic                                             is_avrd_reg;
   logic                                             is_avwr_reg;
   logic    [3:0]                                    fbe_reg;
   logic    [7:0]                                    rx_func_reg;
   logic    [63:0]                                   full_tlp_address;
   logic                                             is_64_req;
   logic    [15:0]                                   requestor_id;
   logic    [31:0]                                   tlp_dw2;
   logic    [31:0]                                   tlp_dw3;
   logic    [31:0]                                   tlp_dw4;
   logic    [7:0]                                    cmd;
   logic    [DMA_WIDTH-1:0]                          tx_tlp_data;
   logic                                             tx_tlp_sop;
   logic                                             tx_tlp_eop;
   logic    [1:0]                                    tx_tlp_emp;
   logic    [259:0]                                  tx_fifo_wrdata;
   logic                                             tx_fifo_wrreq;
   logic                                             cpl_addr_bit2;
   logic                                             cpl_addr_bit2_reg;
   logic    [31:0]                                   cpl_data;

   logic    [31:0]                                   cpl_data_reg;
   logic                                             txs_write_header_st;
   logic                                             txs_read_header_st;
   logic    [63:0]                                   req_header1;
   logic    [63:0]                                   req_header2;
   logic                                             txs_ready;
   logic                                             txs_wait_cnt;
   logic    [7:0]                                    cpl_func;
   logic                                             rdata_valid_st;
   logic                                             txs_wait_cpl_st;
   logic    [7:0]                                    read_tag;
   logic    [7:0]                                    expected_cpl_tag;


 assign read_tag = (EXTENDED_TAG_ENABLE)? 8'd252 : 8'd32;
 assign expected_cpl_tag = (EXTENDED_TAG_ENABLE)? 8'd252 : 8'd32; 


 assign tx_fifo_ok    = (TxFifoCount_i <= 4'd12);
 assign rx_fifo_empty = (RxFifoCount_i == 4'h0);


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           txs_state <= TXS_IDLE;
         else
           txs_state <= txs_nxt_state;
         end

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           txs_wait_cnt <= 1'b1;
       else if (txs_state == TXS_IDLE)
           txs_wait_cnt <= 1'b0;
       else if (txs_write_header_st)
           txs_wait_cnt <= 1'b1;
      end

always_comb
  begin
    case(txs_state)
      TXS_IDLE :
       if(TxsChipSelect_i & MasterEnable_i & (TxsWrite_i | TxsRead_i))
          txs_nxt_state <= TXS_ARB_REQ;
        else
          txs_nxt_state <= TXS_IDLE;

      TXS_ARB_REQ :
        if(TxsArbGranted_i & TxsWrite_i & tx_fifo_ok)
          txs_nxt_state <= TXS_WRITE_HEADER;
        else if(TxsArbGranted_i & TxsRead_i & tx_fifo_ok)
          txs_nxt_state <= TXS_READ_HEADER;
        else
           txs_nxt_state <= TXS_ARB_REQ;

      TXS_WRITE_HEADER:
         if (DMA_WIDTH == 256)
            txs_nxt_state <= TXS_IDLE;
         else begin
            if(txs_wait_cnt == 1'b1)
               txs_nxt_state <= TXS_IDLE;
            else
               txs_nxt_state <= TXS_WRITE_HEADER;
         end

      TXS_READ_HEADER:
         txs_nxt_state <= TXS_WAIT_CPL;

      TXS_WAIT_CPL:
        if(rx_sop & is_cpl_wd & cpl_tag == expected_cpl_tag & ~rx_fifo_empty)
          txs_nxt_state <= TXS_RDATA_VALID;
        else
          txs_nxt_state <= TXS_WAIT_CPL;

      TXS_RDATA_VALID:
        if (DMA_WIDTH == 256)
            txs_nxt_state <= TXS_IDLE;
        else begin
           if (rx_eop_reg)
             txs_nxt_state <= TXS_IDLE;
           else
             txs_nxt_state <= TXS_RDATA_VALID;
        end

      default:
        txs_nxt_state <= TXS_IDLE;
    endcase
end

  assign rdata_valid_st        =  txs_state[5];
  assign txs_write_header_st =  txs_state[2];
  assign txs_read_header_st  =  txs_state[3];
  assign txs_wait_cpl_st =  txs_state[4];
  assign txs_ready =   (DMA_WIDTH == 256) ? (txs_write_header_st | rdata_valid_st) : ((txs_write_header_st & txs_wait_cnt) | (rdata_valid_st & rx_eop_reg));
  assign TxsWaitRequest_o = ~txs_ready;
  assign TxsArbReq_o = (DMA_WIDTH == 256) ? txs_state[1] : (txs_state[1] | (~txs_wait_cnt & (txs_write_header_st)));

//  Latch the address and data from AVMM

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           txs_address_reg <= 0;
           txs_data_reg    <= 32'h0;
           is_avrd_reg     <= 1'b0;
           is_avwr_reg     <= 1'b0;
           fbe_reg         <= 4'h0;

         end
       else if(TxsChipSelect_i & (TxsWrite_i | TxsRead_i))
         begin
           txs_address_reg  <= TxsAddress_i[TX_S_ADDR_WIDTH-1:0];
           txs_data_reg     <= TxsWriteData_i;
           is_avrd_reg      <= TxsRead_i;
           is_avwr_reg      <= TxsWrite_i;
           fbe_reg          <= TxsByteEnable_i;
         end
      end

 //===========================================================================================
 // For SRIOV: Borrow the upper 8 bit of the address field to represent the function number
 //
       assign rx_func_reg = 8'h0;

 //===========================================================================================
// forming the Request TLP

assign full_tlp_address = {{(64-TX_S_ADDR_WIDTH){1'b0}}, txs_address_reg[TX_S_ADDR_WIDTH-1:0]};
assign is_64_req        = (full_tlp_address[63:32] != 32'h0);
assign requestor_id     = {BusDev_i, 3'b000};
assign tlp_dw2          = ~is_64_req? full_tlp_address[31:0] : full_tlp_address[63:32];
assign tlp_dw3          = ~is_64_req? txs_data_reg : full_tlp_address[31:0];
assign tlp_dw4          = txs_data_reg;


always_comb
  begin
    case({is_64_req, is_avwr_reg, is_avrd_reg})
      3'b001  : cmd = 8'h00;
      3'b010  : cmd = 8'h40;
      3'b101  : cmd = 8'h20;
      default : cmd = 8'h60;
    endcase
 end

assign req_header1 = {requestor_id[15:0], read_tag, 4'h0, fbe_reg, cmd[7:0], 8'h0, 16'h1};
assign req_header2 = { tlp_dw3, tlp_dw2 };

generate if(DMA_WIDTH == 256)
  assign tx_tlp_data = {64'h0, tlp_dw4,tlp_dw4, req_header2, req_header1};
else
   assign tx_tlp_data = ((txs_wait_cnt == 1'b0) ? {req_header2, req_header1} : {64'h0, tlp_dw4,tlp_dw4});        
endgenerate                     
                     
                     
                     
assign tx_tlp_sop  = (DMA_WIDTH == 256) ? (txs_write_header_st | txs_read_header_st) : ((~txs_wait_cnt & txs_write_header_st) | txs_read_header_st);
assign tx_tlp_eop  = (DMA_WIDTH == 256) ? (txs_write_header_st | txs_read_header_st) :
                                          (((~is_64_req & full_tlp_address[2]) ? txs_write_header_st :
                                                                                 (txs_wait_cnt & txs_write_header_st)) | txs_read_header_st);
assign tx_tlp_emp[1:0] = (DMA_WIDTH == 256) ? ((is_avrd_reg | (is_avwr_reg & full_tlp_address[2] & ~is_64_req)) ? 2'b10 : 2'b01) :
                                              ( ((txs_write_header_st && (is_64_req | ~full_tlp_address[2])) & tx_tlp_eop ) ? 2'b01 : 2'b00);

// Tx fifo interface

assign   tx_fifo_wrdata[259:0] = (DMA_WIDTH == 256) ? {tx_tlp_emp, tx_tlp_eop, tx_tlp_sop, tx_tlp_data} :
                                  {128'h0, tx_tlp_emp, tx_tlp_eop, tx_tlp_sop, tx_tlp_data[127:0]};

assign   tx_fifo_wrreq  = (DMA_WIDTH == 256) ? (txs_read_header_st | txs_write_header_st) :
                                               (txs_read_header_st | ((is_64_req | ~full_tlp_address[2]) ? txs_write_header_st : (txs_write_header_st & ~txs_wait_cnt)));
assign   TxFifoWrReq_o = tx_fifo_wrreq;
assign   TxFifoData_o  = tx_fifo_wrdata;

/// Completion Data path
assign RxFifoRdReq_o = (DMA_WIDTH == 256) ? ((rx_sop & is_cpl_wd & cpl_tag == expected_cpl_tag & ~rx_fifo_empty) & txs_wait_cpl_st) :
                                            (((rx_sop & is_cpl_wd & cpl_tag == expected_cpl_tag & ~rx_fifo_empty) & txs_wait_cpl_st) |
                                             (rdata_valid_st & rx_eop_reg & ~cpl_addr_bit2_reg & ~rx_fifo_empty));
assign rx_sop        = RxFifoDataq_i[256];
assign rx_eop        = RxFifoDataq_i[257];

assign is_cpl_wd     = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b01010);
assign cpl_tag       = RxFifoDataq_i[79:72];
assign cpl_addr_bit2 = RxFifoDataq_i[66];
assign cpl_data      = cpl_addr_bit2 ? RxFifoDataq_i[127:96] : ((DMA_WIDTH == 256) ? RxFifoDataq_i[159:128] : RxFifoDataq_i[31:0]);
assign cpl_func      = 8'h0;

// latching the cpl information
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin

           cpl_data_reg       <= 32'h0;
           cpl_addr_bit2_reg  <= 1'b0;
         end
       else if(~rx_fifo_empty & is_cpl_wd & rx_sop & cpl_tag == expected_cpl_tag & (cpl_func == rx_func_reg))
       begin

           cpl_data_reg       <= cpl_data;
           cpl_addr_bit2_reg  <= cpl_addr_bit2;
       end
     end

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         rx_eop_d         <= 1'b0;
       else
         rx_eop_d         <= rx_eop;
     end

assign rx_eop_reg = cpl_addr_bit2_reg ? rx_eop_d : rx_eop;

assign TxsReadData_o    =  (DMA_WIDTH == 256) ? cpl_data_reg : (cpl_addr_bit2_reg ? cpl_data_reg : cpl_data);
assign TxsReadDataValid_o = (DMA_WIDTH == 256) ? rdata_valid_st : (rdata_valid_st & rx_eop_reg);

endmodule






