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

module dma_control #(
      parameter                                    dma_use_scfifo_ext = 0,
      parameter                                    DMA_WIDTH          = 256
  ) (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,

      input logic   [81:0]                         MsiInterface_i,

//// DMA Read Interface
      // AVMM Register Slave Port (Write only)
      input  logic                                  RdDCSChipSelect_i,
      input  logic                                  RdDCSWrite_i,
      input  logic                                  RdDCSRead_i,
      input  logic  [7:0]                           RdDCSAddress_i,
      input  logic  [31:0]                          RdDCSWriteData_i,
      output  logic [31:0]                          RdDCSReadData_o,
      input  logic  [3:0]                           RdDCSByteEnable_i,
      output logic                                  RdDCSWaitRequest_o,


            // AVMM Register Master Port (Write only)

      output   logic [63:0]                         RdDCMAddress_o,
      output                                        RdDCMWrite_o,
      output   logic [31:0]                         RdDCMWriteData_o,
      output                                        RdDCMRead_o,
      output   logic [3:0]                          RdDCMByteEnable_o,
      input    logic                                RdDCMWaitRequest_i,
      input    logic [31:0]                         RdDCMReadData_i,
      input    logic                                RdDCMReadDataValid_i,

      /// DT 256-bit slave interface (Write only)

      input  logic                                  RdDTSChipSelect_i,
      input  logic                                  RdDTSWrite_i,
      input  logic  [4:0]                           RdDTSBurstCount_i,
      input  logic  [7:0]                           RdDTSAddress_i,
      input  logic  [255:0]                         RdDTSWriteData_i,
      output logic                                  RdDTSWaitRequest_o,

      /// DMA programming interface
      output   logic  [159:0]                       RdDmaTxData_o,
      output   logic                                RdDmaTxValid_o,
      input    logic                                RdDmaTxReady_i,

     // DMA Status Interface
      input   logic  [31:0]                         RdDmaRxData_i,
      input   logic                                 RdDmaRxValid_i,

////                DMA Write Interface              ///////////////////////////
 //////////      // AVMM Register Slave Port (Write only)   /////////////////////
      input  logic                                  WrDCSChipSelect_i,
      input  logic                                  WrDCSWrite_i,
      input  logic                                  WrDCSRead_i,
      input  logic  [7:0]                           WrDCSAddress_i,
      input  logic  [31:0]                          WrDCSWriteData_i,
      output logic  [31:0]                          WrDCSReadData_o,
      input  logic  [3:0]                           WrDCSByteEnable_i,
      output logic                                  WrDCSWaitRequest_o,


            // AVMM Register Master Port (Write only)

      output   logic [63:0]                         WrDCMAddress_o,
      output                                        WrDCMWrite_o,
      output   logic [31:0]                         WrDCMWriteData_o,
      output                                        WrDCMRead_o,
      output   logic [3:0]                          WrDCMByteEnable_o,
      input    logic                                WrDCMWaitRequest_i,
      input    logic [31:0]                         WrDCMReadData_i,
      input    logic                                WrDCMReadDataValid_i,

      /// DT 256-bit slave interface (Write only)

      input  logic                                  WrDTSChipSelect_i,
      input  logic                                  WrDTSWrite_i,
      input  logic  [4:0]                           WrDTSBurstCount_i,
      input  logic  [7:0]                           WrDTSAddress_i,
      input  logic  [255:0]                         WrDTSWriteData_i,
      output logic                                  WrDTSWaitRequest_o,

      /// DMA programming interface
      output   logic  [159:0]                       WrDmaTxData_o,
      output   logic                                WrDmaTxValid_o,
      input    logic                                WrDmaTxReady_i,

     // DMA Status Interface
      input   logic  [31:0]                         WrDmaRxData_i,
      input   logic                                 WrDmaRxValid_i
);


logic              wrdesc_tx_ack;
logic              wrdesc_tx_req;
logic  [159:0]     wrdesc_tx_data;
//// Instantiate Read module

altpcie_dynamic_control # (
   .dma_use_scfifo_ext    (dma_use_scfifo_ext),
   .READ_CONTROL          (1)
) read_control            (
   .Clk_i                 (Clk_i),
   .Rstn_i                (Rstn_i),
   .DCSChipSelect_i       ( RdDCSChipSelect_i      )      ,
   .DCSWrite_i            ( RdDCSWrite_i           )      ,
   .DCSAddress_i          ( RdDCSAddress_i         )      ,
   .DCSWriteData_i        ( RdDCSWriteData_i       )      ,
   .DCSByteEnable_i       ( RdDCSByteEnable_i      )      ,
   .DCSWaitRequest_o      ( RdDCSWaitRequest_o     )      ,
   .DCSRead_i             ( RdDCSRead_i            )      ,
   .DCSReadData_o         ( RdDCSReadData_o        )      ,
   .DCMAddress_o          ( RdDCMAddress_o         )      ,
   .DCMWrite_o            ( RdDCMWrite_o           )      ,
   .DCMWriteData_o        ( RdDCMWriteData_o       )      ,
   .DCMRead_o             ( RdDCMRead_o            )      ,
   .DCMByteEnable_o       ( RdDCMByteEnable_o      )      ,
   .DCMWaitRequest_i      ( RdDCMWaitRequest_i     )      ,
   .DCMReadData_i         ( RdDCMReadData_i        )      ,
   .DCMReadDataValid_i    ( RdDCMReadDataValid_i   )      ,
   .DTSChipSelect_i       ( RdDTSChipSelect_i      )      ,
   .DTSWrite_i            ( RdDTSWrite_i           )      ,
   .DTSBurstCount_i       ( RdDTSBurstCount_i      )      ,
   .DTSAddress_i          ( RdDTSAddress_i         )      ,
   .DTSWriteData_i        ( RdDTSWriteData_i       )      ,
   .DTSWaitRequest_o      ( RdDTSWaitRequest_o     )      ,
   .DmaTxData_o           ( RdDmaTxData_o          )      ,
   .DmaTxValid_o          ( RdDmaTxValid_o         )      ,
   .DmaTxReady_i          ( RdDmaTxReady_i         )      ,
   .DmaRxData_i           ( RdDmaRxData_i          )      ,
   .DmaRxValid_i          ( RdDmaRxValid_i         )      ,
   .WrDescTxData_o        (                        )      ,
   .WrDescTxReq_o         (                        )      ,
   .WrDescTxAck_i         (1'b0                    )      ,
   .WrDescTxAck_o         (wrdesc_tx_ack           )      ,
   .WrDescTxReq_i         (wrdesc_tx_req)                 ,
   .WrDescTxData_i        (wrdesc_tx_data)                ,
   .MsiInterface_i        (MsiInterface_i)
);

//// Instantiate Read module

altpcie_dynamic_control  # (
   .dma_use_scfifo_ext     (dma_use_scfifo_ext),
   .READ_CONTROL           (0)
) write_control            (
   .Clk_i (Clk_i),
   .Rstn_i (Rstn_i),
   .DCSChipSelect_i       ( WrDCSChipSelect_i         )      ,
   .DCSWrite_i            ( WrDCSWrite_i              )      ,
   .DCSAddress_i          ( WrDCSAddress_i            )      ,
   .DCSWriteData_i        ( WrDCSWriteData_i          )      ,
   .DCSByteEnable_i       ( WrDCSByteEnable_i         )      ,
   .DCSWaitRequest_o      ( WrDCSWaitRequest_o        )      ,
   .DCMAddress_o          ( WrDCMAddress_o            )      ,
   .DCSRead_i             ( WrDCSRead_i               )      ,
   .DCSReadData_o         ( WrDCSReadData_o           )      ,
   .DCMWrite_o            ( WrDCMWrite_o              )      ,
   .DCMWriteData_o        ( WrDCMWriteData_o          )      ,
   .DCMRead_o             ( WrDCMRead_o               )      ,
   .DCMByteEnable_o       ( WrDCMByteEnable_o         )      ,
   .DCMWaitRequest_i      ( WrDCMWaitRequest_i        )      ,
   .DCMReadData_i         ( WrDCMReadData_i           )      ,
   .DCMReadDataValid_i    ( WrDCMReadDataValid_i      )      ,
   .DTSChipSelect_i       ( WrDTSChipSelect_i         )      ,
   .DTSWrite_i            ( WrDTSWrite_i              )      ,
   .DTSBurstCount_i       ( WrDTSBurstCount_i         )      ,
   .DTSAddress_i          ( WrDTSAddress_i            )      ,
   .DTSWriteData_i        ( WrDTSWriteData_i          )      ,
   .DTSWaitRequest_o      ( WrDTSWaitRequest_o        )      ,
   .DmaTxData_o           ( WrDmaTxData_o             )      ,
   .DmaTxValid_o          ( WrDmaTxValid_o            )      ,
   .DmaTxReady_i          ( WrDmaTxReady_i            )      ,
   .DmaRxData_i           ( WrDmaRxData_i             )      ,
   .DmaRxValid_i          ( WrDmaRxValid_i            )      ,
   .WrDescTxData_o        (wrdesc_tx_data)                   ,
   .WrDescTxReq_o         (wrdesc_tx_req)                    ,
   .WrDescTxAck_i         (wrdesc_tx_ack               )     ,
   .WrDescTxAck_o         (             )                    ,
   .WrDescTxReq_i         (1'b0)                             ,
   .WrDescTxData_i        (160'h0)                           ,
   .MsiInterface_i        (MsiInterface_i)
);



endmodule


