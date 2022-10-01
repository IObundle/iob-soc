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
module altpcieav_dma_wr_2
 (
   input    logic                        Clk_i,
   input    logic                        Srst_i,
   
    // Upstream PCIe Write DMA master port

   output   logic                     WrDmaRead_o,
   output   logic[63:0]               WrDmaAddress_o,
   output   logic[4:0]                WrDmaBurstCount_o,   
   output   logic[31:0]               WrDmaReadByteEnable_o,
   input    logic                     WrDmaWaitRequest_i,
   input    logic                     WrDmaReadDataValid_i,
   input    logic[255:0]              WrDmaReadData_i,
   
   input    logic[159:0]              WrDmaRxData_i,
   input    logic                     WrDmaRxValid_i,
   output   logic                     WrDmaRxReady_o,
   
      // Write DMA AST Tx port
   output   logic[31:0]               WrDmaTxData_o,
   output   logic                     WrDmaTxValid_o,
   
   /// Side FIFO
   input    logic  [259:0]               SideFifoData_i,
   input    logic  [3:0]                 SideFifoCount_i,
   output   logic                        SideFifoRdreq_o,
   
   /// HPRXM Request 
   input    logic                        HPRxmPending_i,
   
   /// Arbitration interface
   output   logic                        WrDmaArbReq_o,                                
   input    logic                        WrDmaGrant_i,
  
  /// Tx output FIFO Status
  input     logic   [4:0]                TxFifoCount_i, 
  output    logic   [259:0]              TxFifoData_o,
  output    logic                        TxFifoWrReq_o,
  
  
  /// Descriptor Done status
  
  input    logic    [12:0]               BusDev_i,
  input    logic   [31:0]                DevCsr_i

   
   );
 
logic                            raw_buffer_rdreq;                 
logic    [8:0]                   raw_buffer_read_address;                   
logic    [255:0]                 raw_buffer_data_out;                     
logic                            desc_fifo_rdreq;                    
logic    [159:0]                 desc_fifo_data;                    
logic    [3:0]                   desc_fifo_count;              
logic    [9:0]                   raw_buffer_limit;               
logic                            desc_data_complete_fifo_rdreq;
logic    [4:0]                   desc_data_complete_fifo_count;
logic    [8:0]                   aligned_ram_read_address;
logic    [257:0]                 aligned_ram_data_out;     
logic    [9:0]                   aligned_buffer_limit;      
logic                            header_fifo_rdreq;      
logic                            header_fifo_empty;     
logic    [138:0]                 header_fifo_data;       
logic    [8:0]                   raw_buff_release_size;
logic                            raw_buff_release; 
logic    [9:0]                   tlp_gen_cred;
logic                            tlp_gen_cred_up;
  
   
/// instantiate AVMM Read Mem
altpcieav_dma_wr_readmem_2 dma_wr_readmem
 (
.Clk_i(Clk_i),
.Srst_i(Srst_i),
.WrDmaRead_o(WrDmaRead_o),
.WrDmaAddress_o(WrDmaAddress_o),
.WrDmaBurstCount_o(WrDmaBurstCount_o), 
.WrDmaReadByteEnable_o(WrDmaReadByteEnable_o),
.WrDmaWaitRequest_i(WrDmaWaitRequest_i),
.WrDmaReadDataValid_i( WrDmaReadDataValid_i),
.WrDmaReadData_i(WrDmaReadData_i),
.WrDmaRxData_i(WrDmaRxData_i[159:0]),
.WrDmaRxValid_i(WrDmaRxValid_i),
.WrDmaRxReady_o(WrDmaRxReady_o),
.RawBuffRelease_i(raw_buff_release),
.RawBuffReleaseSize_i(raw_buff_release_size),
.DataRamReadAddr_i(raw_buffer_read_address),
.DataRamReadData_o(raw_buffer_data_out),
.TLPGenDescFifoRdReq_i(desc_fifo_rdreq),
.TLPGenDescFifoDataq_o(desc_fifo_data),
.TLPGenDescFifoCount_o(desc_fifo_count), 
.TLPGenBuffLimit_o(raw_buffer_limit),   
.DescDataCompleteFifoRdReq_i(desc_data_complete_fifo_rdreq),          
.DescDataCompleteFifoCount_o(desc_data_complete_fifo_count)
);


/// Instantiate Write Align module
altpcieav_dma_wr_wdalign_2 
#(
 .DMA_WIDTH(256)
)
dma_wr_wdalign
(
 .Clk_i(Clk_i),                            
 .Srst_i(Srst_i),                      
 .RawBufferLimit_i(raw_buffer_limit ),            
 .RawBuffRelease_o(raw_buff_release),
 .RawBuffReleaseSize_o(raw_buff_release_size),        
 .RawRamAddress_o(raw_buffer_read_address ),             
 .RawRamData_i(raw_buffer_data_out ),                
 .DescFifo_i(desc_fifo_data ),                  
 .DescFifoCount_i(desc_fifo_count ),             
 .DescFifoRdreq_o(desc_fifo_rdreq ),             
 .DescDataCompleteFifoRdReq_o(desc_data_complete_fifo_rdreq ), 
 .DescDataCompleteFifoCount_i(desc_data_complete_fifo_count ), 
 .AlignedRamRdAddr_i(aligned_ram_read_address),          
 .AlignedRamData_o(aligned_ram_data_out),            
 .TLPGenBuffLimit_o(aligned_buffer_limit),    
 .TlpGenCreditUp_i(tlp_gen_cred_up),
 .TlpGenCred_i(tlp_gen_cred),       
 .TLPHeaderFifoRdReq_i(header_fifo_rdreq),        
 .TLPHeaderFifoEmpty_o(header_fifo_empty ),        
 .TLPHeaderFifoData_o(header_fifo_data),         
 .BusDev_i(BusDev_i),
 .DevCsr_i(DevCsr_i)
 );
 
 
/// Instantiate the TLP gen module

 altpcieav_dma_wr_tlpgen_2    dma_wr_tlpgen                                                     
                                                                               
(                                                                              
   .Clk_i(Clk_i),                                
   .Srst_i(Srst_i),                               
   .AlignedRamRdAddr_o(aligned_ram_read_address),                   
   .AlignedRamData_i(aligned_ram_data_out),                     
   .TLPGenBuffLimit_i(aligned_buffer_limit),                    
   .TLPHeaderFifoRdReq_o(header_fifo_rdreq),                 
   .TLPHeaderFifoEmpty_i(header_fifo_empty),                 
   .TLPHeaderFifoData_i(header_fifo_data),                  
   .SideFifoData_i(SideFifoData_i),                       
   .SideFifoCount_i(SideFifoCount_i),                      
   .SideFifoRdreq_o(SideFifoRdreq_o),                      
   .HPRxmPending_i(HPRxmPending_i),                       
   .WrDmaArbReq_o(WrDmaArbReq_o),                        
   .WrDmaGrant_i(WrDmaGrant_i),                         
   .TxFifoCount_i(TxFifoCount_i),                        
   .TxFifoData_o(TxFifoData_o),                         
   .TxFifoWrReq_o(TxFifoWrReq_o),                        
   .WrDMADescDone_o(WrDmaTxValid_o),                      
   .WrDmaDescID_o(WrDmaTxData_o),
   .TlpGenCreditUp_o(tlp_gen_cred_up),
   .TlpGenCred_o(tlp_gen_cred)                       
   );  

endmodule

                                                                        