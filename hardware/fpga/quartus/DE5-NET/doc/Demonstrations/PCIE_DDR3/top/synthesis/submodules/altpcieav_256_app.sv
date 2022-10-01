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

module altpcieav_256_app
#(
     //----------------------------------------------------
     //------------- TOP LEVEL PARAMETERS -----------------
     //----------------------------------------------------
     parameter DEVICE_FAMILY               = "Stratix V",
     parameter DMA_WIDTH                   = 256,
     parameter ENABLE_HPRXM                = 0,
     parameter DMA_BE_WIDTH                = 32,
     parameter DMA_BRST_CNT_W              = 6,
     parameter RDDMA_AVL_ADDR_WIDTH        = 64,
     parameter WRDMA_AVL_ADDR_WIDTH        = 64,
     parameter TX_S_ADDR_WIDTH             = 31,
     parameter COMPLETER_ONLY_HWTCL        = 0,
     parameter enable_rxm_burst_hwtcl      = 0,
     parameter enable_cra_hwtcl            = 1,
     parameter dma_use_scfifo_ext          = 0,

     parameter BAR0_SIZE_MASK              = 10,
     parameter BAR1_SIZE_MASK              = 1,
     parameter BAR2_SIZE_MASK              = 1,
     parameter BAR3_SIZE_MASK              = 1,
     parameter BAR4_SIZE_MASK              = 1,
     parameter BAR5_SIZE_MASK              = 1,
     parameter BAR0_TYPE                   = 64,
     parameter BAR1_TYPE                   = 1,
     parameter BAR2_TYPE                   = 32,
     parameter BAR3_TYPE                   = 32,
     parameter BAR4_TYPE                   = 32,
     parameter BAR5_TYPE                   = 32,
     parameter WRDMA_VERSION_2             = 1,

     // SRIOV
     parameter SRIOV_EN               = 0,
     parameter ARI_EN                 = 0,
     parameter PHASE1                 = 0,  // Indicate phase1 of SR-IOV
     parameter RXDATA_WIDTH          = 160,
     parameter RXFIFO_DATA_WIDTH     = 266,
     parameter EXTENDED_TAG_ENABLE   = 0
)


(

/// System Clock and Reset
   input  logic                               Clk_i,
   input  logic    [9:0]                      Rstn_i,

// HIP Interface
   // Rx port interface to PCI Exp HIP
   output logic                               HipRxStReady_o,
   output logic                               HipRxStMask_o,
   input  logic  [DMA_WIDTH-1:0]              HipRxStData_i,
   input  logic  [DMA_BE_WIDTH-1:0]           HipRxStBe_i,
   input  logic  [1:0]                        HipRxStEmpty_i,
   input  logic                               HipRxStErr_i,
   input  logic                               HipRxStSop_i,
   input  logic                               HipRxStEop_i,
   input  logic                               HipRxStValid_i,
   input  logic  [7:0]                        HipRxStBarDec1_i,
   // Tx application interface
   input   logic                              HipTxStReady_i  ,
   output  logic  [DMA_WIDTH-1:0]             HipTxStData_o   ,
   output  logic                              HipTxStSop_o    ,
   output  logic                              HipTxStEop_o    ,
   output  logic  [1:0]                       HipTxStEmpty_o  ,
   output  logic                              HipTxStValid_o  ,
   output  logic                              HipCplPending_o,

   //==========================
   // SR-IOV Cfg_Status Interface
   //==========================

// Upstream PCIe Write DMA master port

   output  logic                              AvWrDmaRead_o,
   output  logic  [63:0]                      AvWrDmaAddress_o,
   output  logic  [DMA_BRST_CNT_W-1:0]        AvWrDmaBurstCount_o,
   output  logic  [DMA_BE_WIDTH-1:0]          AvWrDmaReadByteEnable_o,
   input   logic                              AvWrDmaWaitRequest_i,
   input   logic                              AvWrDmaReadDataValid_i,
   input   logic [DMA_WIDTH-1:0]              AvWrDmaReadData_i,


// Upstream PCIe Read DMA master port

   output  logic                               AvRdDmaWrite_o,
   output  logic  [63:0]                       AvRdDmaAddress_o,
   output  logic  [DMA_WIDTH-1:0]              AvRdDmaWriteData_o,
   output  logic  [DMA_BRST_CNT_W-1:0]         AvRdDmaBurstCount_o,
   output  logic  [DMA_BE_WIDTH-1:0]           AvRdDmaWriteEnable_o,
   input   logic                               AvRdDmaWaitRequest_i,

 // RXM Master Port, one for each BAR
      // Avalon Rx Master interface 0
  output logic                                 AvRxmWrite_0_o,
  output logic [BAR0_TYPE-1:0]                 AvRxmAddress_0_o,
  output logic [31:0]                          AvRxmWriteData_0_o,
  output logic [3:0]                           AvRxmByteEnable_0_o,
  input  logic                                 AvRxmWaitRequest_0_i,
  output logic                                 AvRxmRead_0_o,
  input  logic [31:0]                          AvRxmReadData_0_i,
  input  logic                                 AvRxmReadDataValid_0_i,

  // Avallogic on Rx Master interface 1
  output logic                                 AvRxmWrite_1_o,
  output logic [BAR1_TYPE-1:0]                 AvRxmAddress_1_o,
  output logic [31:0]                          AvRxmWriteData_1_o,
  output logic [3:0]                           AvRxmByteEnable_1_o,
  input  logic                                 AvRxmWaitRequest_1_i,
  output logic                                 AvRxmRead_1_o,
  input  logic [31:0]                          AvRxmReadData_1_i,
  input  logic                                 AvRxmReadDataValid_1_i,

  // Aval on Rx Master interface 2
  output logic                                 AvRxmWrite_2_o,
  output logic [BAR2_TYPE-1:0]                 AvRxmAddress_2_o,
  output logic [31:0]                          AvRxmWriteData_2_o,
  output logic [3:0]                           AvRxmByteEnable_2_o,
  input  logic                                 AvRxmWaitRequest_2_i,
  output logic                                 AvRxmRead_2_o,
  input  logic [31:0]                          AvRxmReadData_2_i,
  input  logic                                 AvRxmReadDataValid_2_i,

  // Aval on Rx Master interface 3
  output logic                                 AvRxmWrite_3_o,
  output logic [BAR3_TYPE-1:0]                 AvRxmAddress_3_o,
  output logic [31:0]                          AvRxmWriteData_3_o,
  output logic [3:0]                           AvRxmByteEnable_3_o,
  input  logic                                 AvRxmWaitRequest_3_i,
  output logic                                 AvRxmRead_3_o,
  input  logic [31:0]                          AvRxmReadData_3_i,
  input  logic                                 AvRxmReadDataValid_3_i,

  // Avallogic on Rx Master interface 4
  output logic                                 AvRxmWrite_4_o,
  output logic [BAR4_TYPE-1:0]                 AvRxmAddress_4_o,
  output logic [31:0]                          AvRxmWriteData_4_o,
  output logic [3:0]                           AvRxmByteEnable_4_o,
  input  logic                                 AvRxmWaitRequest_4_i,
  output logic                                 AvRxmRead_4_o,
  input  logic [31:0]                          AvRxmReadData_4_i,
  input  logic                                 AvRxmReadDataValid_4_i,

  // Aval on Rx Master interface 5
  output logic                                 AvRxmWrite_5_o,
  output logic [BAR5_TYPE-1:0]                 AvRxmAddress_5_o,
  output logic [31:0]                          AvRxmWriteData_5_o,
  output logic [3:0]                           AvRxmByteEnable_5_o,
  input  logic                                 AvRxmWaitRequest_5_i,
  output logic                                 AvRxmRead_5_o,
  input  logic [31:0]                          AvRxmReadData_5_i,
  input  logic                                 AvRxmReadDataValid_5_i,

// Avalon HP Rx Master interface
  output logic                                 AvHPRxmWrite_o,
  output logic [BAR2_TYPE-1:0]                 AvHPRxmAddress_o,
  output logic [DMA_WIDTH-1:0]                 AvHPRxmWriteData_o,
  output logic [(DMA_WIDTH/8)-1:0]             AvHPRxmByteEnable_o,
  output logic [DMA_BRST_CNT_W-1:0]            AvHPRxmBurstCount_o,
  input  logic                                 AvHPRxmWaitRequest_i,
  output logic                                 AvHPRxmRead_o,
  input  logic [DMA_WIDTH-1:0]                 AvHPRxmReadData_i,
  input  logic                                 AvHPRxmReadDataValid_i,

//=================
// TXS Slave Port
  input   logic                                AvTxsChipSelect_i,
  input   logic                                AvTxsWrite_i,
  input   logic  [TX_S_ADDR_WIDTH+8-1:0]       AvTxsAddress_i,  // {func_no, address}
  input   logic  [31:0]                        AvTxsWriteData_i,
  input   logic  [3:0]                         AvTxsByteEnable_i,
  output  logic                                AvTxsWaitRequest_o,
  input   logic                                AvTxsRead_i,
  output  logic  [31:0]                        AvTxsReadData_o,
  output  logic                                AvTxsReadDataValid_o,


// CRA Slave Port
 input   logic                                 AvCraChipSelect_i,
 input   logic                                 AvCraRead_i,
 input   logic                                 AvCraWrite_i,
 input   logic  [31:0]                         AvCraWriteData_i,
 input   logic  [9:0]                          AvCraAddress_i,
 input   logic  [3:0]                          AvCraByteEnable_i,
 output  logic  [31:0]                         AvCraReadData_o,
 output  logic                                 AvCraWaitRequest_o,

// Read DMA AST Rx port
input   logic  [RXDATA_WIDTH-1:0]              AvRdDmaRxData_i,
input   logic                                  AvRdDmaRxValid_i,
output  logic                                  AvRdDmaRxReady_o,


// Read DMA AST Tx port
output   logic  [31:0]                         AvRdDmaTxData_o,
output   logic                                 AvRdDmaTxValid_o,

// Write DMA AST Rx port
input   logic  [RXDATA_WIDTH-1:0]              AvWrDmaRxData_i,
input   logic                                  AvWrDmaRxValid_i,
output   logic                                 AvWrDmaRxReady_o,

// Write DMA AST Tx port
output   logic  [31:0]                         AvWrDmaTxData_o,
output   logic                                 AvWrDmaTxValid_o,

output  logic  [81:0]                          AvMsiIntfc_o,
output  logic  [15:0]                          AvMsixIntfc_o,
input   logic                                  IntxReq_i,
output  logic                                  IntxAck_o,
input   logic  [3:0]                           HipCfgAddr_i,
input   logic  [31:0]                          HipCfgCtl_i,

input   logic  [15:0]                          TLCfgSts_i,

input  logic  [4:0]                            Ltssm_i,
input  logic  [1:0]                            CurrentSpeed_i,
input  logic  [3:0]                            LaneAct_i,     

/// rx completion space
input  logic [7:0]                             ko_cpl_spc_header,
input  logic [11:0]                            ko_cpl_spc_data  
);

assign IntxAck_o = 1'b0;

localparam HPRXM_BAR_TYPE                    = (enable_rxm_burst_hwtcl== 1)? BAR2_TYPE : 1;
localparam RXM_BAR2_TYPE                     = (enable_rxm_burst_hwtcl== 1)?  1 : BAR2_TYPE;
localparam RXM_BAR3_TYPE                     = (enable_rxm_burst_hwtcl== 1)?  1 : BAR3_TYPE;

    //define the clogb2 constant function
   function integer clogb2;
      input [31:0] depth;
      begin
         depth = depth - 1 ;
         for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
           depth = depth >> 1 ;
      end
   endfunction // clogb2

  localparam NUM_TAG = (EXTENDED_TAG_ENABLE == 1)? 256 : 16;
  localparam NUM_TAG_WIDTH = clogb2(NUM_TAG) ;

logic                                          rx_fifo_rdreq;
logic  [RXFIFO_DATA_WIDTH-1:0]                 rx_fifo_dataq;
logic  [3:0]                                   rx_fifo_count;
logic                                          tx_fifo_wrreq;
logic                                          tx_fifo_wrreq_from_rxm;
logic                                          tx_fifo_wrreq_from_txs;
logic  [259:0]                                 tx_fifo_data;
logic  [259:0]                                 tx_fifo_data_from_rxm;
logic  [259:0]                                 tx_fifo_data_from_txs;
logic  [5:0]                                   tx_fifo_count;
logic                                          rxm_req;
logic                                          txs_req;
logic                                          rxm_granted;
logic                                          txs_granted;
logic  [12:0]                                  cfg_bus_dev;
logic  [31:0]                                  cfg_dev_csr;
logic                                          rx_fifo_rdreq_from_rxm;
logic                                          rx_fifo_rdreq_from_txs;
logic                                          rx_fifo_rdreq_from_rd_dma  ;
logic                                          tx_fifo_wrreq_from_rd_dma  ;
logic   [259:0]                                tx_fifo_data_from_rd_dma   ;
logic                                          rx_fifo_rdreq_from_wr_dma  ;
logic                                          tx_fifo_wrreq_from_wr_dma  ;
logic   [259:0]                                tx_fifo_data_from_wr_dma   ;
logic                                          rd_cntrl_ld  ;
logic   [31:0]                                 wr_cntrl_data;
logic                                          wr_cntrl_ld  ;
logic   [31:0]                                 rd_cntrl_data;
logic   [31:0]                                 rd_dma_status_to_cra;
logic   [31:0]                                 wr_dma_status_to_cra;
logic                                          rd_dma_req;
logic                                          lp_wr_dma_req;
logic                                          hp_wr_dma_req;
logic                                          rd_dma_granted;
logic                                          wr_dma_granted;
logic                                          cra_rd_cntrl_clear;
logic  [31:0]                                  msi_data_cntrl;
logic  [31:0]                                  pci_cmd_reg;
logic                                          predecode_tag_rd_req;
logic  [7:0]                                   predecode_tag;
logic  [NUM_TAG_WIDTH-1:0]                     predecode_tag_count;

// Side Fifo
logic                                          tx_side_fifo_wrreq;
logic                                          tx_side_fifo_wrreq_r;
logic                                          tx_side_fifo_rdreq;
logic  [259:0]                                 tx_side_fifo_input_r;
logic  [259:0]                                 tx_side_fifo_input;
logic  [259:0]                                 tx_side_fifo_output;
logic  [3:0]                                   tx_side_fifo_count;
logic                                          rx_fifo_rdreq_from_hprxm;
logic                                          tx_fifo_wrreq_from_hprxm;
logic  [259:0]                                 tx_fifo_data_from_hprxm;
logic                                          hprxm_req;
logic                                          hprxm_granted;
logic  [3:0]                                   HipCfgAddr_i_r;
logic  [31:0]                                  HipCfgCtl_i_r;
logic                                          dma_wr_tx_side_fifo_rdreq;


always @ (posedge Clk_i or negedge Rstn_i[1])
  begin
     if (~Rstn_i[1])
       begin
       HipCfgAddr_i_r <= 4'h0;
       HipCfgCtl_i_r <= 32'h0;
       end
     else
       begin
     HipCfgAddr_i_r <= HipCfgAddr_i;
       HipCfgCtl_i_r  <= HipCfgCtl_i;
       end
end

/// RXM module instantiation

altpcieav_dma_rxm           #(
      .BAR0_SIZE_MASK        (BAR0_SIZE_MASK),
      .BAR1_SIZE_MASK        (BAR1_SIZE_MASK),
      .BAR2_SIZE_MASK        (BAR2_SIZE_MASK),
      .BAR3_SIZE_MASK        (BAR3_SIZE_MASK),
      .BAR4_SIZE_MASK        (BAR4_SIZE_MASK),
      .BAR5_SIZE_MASK        (BAR5_SIZE_MASK),
      .BAR0_TYPE             (BAR0_TYPE),
      .BAR1_TYPE             (BAR1_TYPE),
      .BAR2_TYPE             (RXM_BAR2_TYPE),
      .BAR3_TYPE             (RXM_BAR3_TYPE),
      .BAR4_TYPE             (BAR4_TYPE),
      .BAR5_TYPE             (BAR5_TYPE),
      .DMA_WIDTH             (DMA_WIDTH),
      .enable_rxm_burst_hwtcl(enable_rxm_burst_hwtcl)
   ) rxm_master (
      .Clk_i                  (Clk_i  ),
      .Rstn_i                 (Rstn_i[2]  ),
      .RxFifoRdReq_o          (rx_fifo_rdreq_from_rxm ),
      .RxFifoDataq_i          (rx_fifo_dataq),
      .RxFifoCount_i          (rx_fifo_count),
      .TxFifoWrReq_o          (tx_fifo_wrreq_from_rxm),
      .TxFifoData_o           (tx_fifo_data_from_rxm),
      .TxFifoCount_i          (tx_side_fifo_count),
      .CfgBusDev_i            (cfg_bus_dev),
      .RxmArbCplReq_o         (rxm_req),
      .RxmArbGranted_i        (rxm_granted  ),
      .RxmWrite_0_o           (AvRxmWrite_0_o  ),
      .RxmAddress_0_o         (AvRxmAddress_0_o  ),
      .RxmWriteData_0_o       (AvRxmWriteData_0_o  ),
      .RxmByteEnable_0_o      (AvRxmByteEnable_0_o  ),
      .RxmWaitRequest_0_i     (AvRxmWaitRequest_0_i ),
      .RxmRead_0_o            (AvRxmRead_0_o  ),
      .RxmReadData_0_i        (AvRxmReadData_0_i  ),
      .RxmReadDataValid_0_i   (AvRxmReadDataValid_0_i ),
      .RxmWrite_1_o           (AvRxmWrite_1_o  ),
      .RxmAddress_1_o         (AvRxmAddress_1_o  ),
      .RxmWriteData_1_o       (AvRxmWriteData_1_o  ),
      .RxmByteEnable_1_o      (AvRxmByteEnable_1_o  ),
      .RxmWaitRequest_1_i     (AvRxmWaitRequest_1_i  ),
      .RxmRead_1_o            (AvRxmRead_1_o  ),
      .RxmReadData_1_i        (AvRxmReadData_1_i  ),
      .RxmReadDataValid_1_i   (AvRxmReadDataValid_1_i  ),
      .RxmWrite_2_o           (AvRxmWrite_2_o  ),
      .RxmAddress_2_o         (AvRxmAddress_2_o  ),
      .RxmWriteData_2_o       (AvRxmWriteData_2_o  ),
      .RxmByteEnable_2_o      (AvRxmByteEnable_2_o  ),
      .RxmWaitRequest_2_i     (AvRxmWaitRequest_2_i  ),
      .RxmRead_2_o            (AvRxmRead_2_o  ),
      .RxmReadData_2_i        (AvRxmReadData_2_i  ),
      .RxmReadDataValid_2_i   (AvRxmReadDataValid_2_i  ),
      .RxmWrite_3_o           (AvRxmWrite_3_o  ),
      .RxmAddress_3_o         (AvRxmAddress_3_o  ),
      .RxmWriteData_3_o       (AvRxmWriteData_3_o  ),
      .RxmByteEnable_3_o      (AvRxmByteEnable_3_o  ),
      .RxmWaitRequest_3_i     (AvRxmWaitRequest_3_i  ),
      .RxmRead_3_o            (AvRxmRead_3_o  ),
      .RxmReadData_3_i        (AvRxmReadData_3_i  ),
      .RxmReadDataValid_3_i   (AvRxmReadDataValid_3_i  ),
      .RxmWrite_4_o           (AvRxmWrite_4_o  ),
      .RxmAddress_4_o         (AvRxmAddress_4_o  ),
      .RxmWriteData_4_o       (AvRxmWriteData_4_o  ),
      .RxmByteEnable_4_o      (AvRxmByteEnable_4_o  ),
      .RxmWaitRequest_4_i     (AvRxmWaitRequest_4_i  ),
      .RxmRead_4_o            (AvRxmRead_4_o  ),
      .RxmReadData_4_i        (AvRxmReadData_4_i  ),
      .RxmReadDataValid_4_i   (AvRxmReadDataValid_4_i  ),
      .RxmWrite_5_o           (AvRxmWrite_5_o  ),
      .RxmAddress_5_o         (AvRxmAddress_5_o  ),
      .RxmWriteData_5_o       (AvRxmWriteData_5_o  ),
      .RxmByteEnable_5_o      (AvRxmByteEnable_5_o  ),
      .RxmWaitRequest_5_i     (AvRxmWaitRequest_5_i  ),
      .RxmRead_5_o            (AvRxmRead_5_o ),
      .RxmReadData_5_i        (AvRxmReadData_5_i ),
      .RxmReadDataValid_5_i   (AvRxmReadDataValid_5_i )
 );

 /// HP Rxm Interface

generate if (enable_rxm_burst_hwtcl == 1) begin
   altpcieav_dma_hprxm        #(
           .dma_use_scfifo_ext (dma_use_scfifo_ext),
           .HPRXM_BAR_TYPE     (HPRXM_BAR_TYPE),
           .AVMM_WIDTH         (DMA_WIDTH),
           .BAR2_SIZE_MASK     (BAR2_SIZE_MASK)
   ) hprxm_master              (
          .Clk_i               (Clk_i ),
          .Rstn_i              (Rstn_i[3] ),
          .HPRxmWrite_o        (AvHPRxmWrite_o        ),
          .HPRxmAddress_o      (AvHPRxmAddress_o      ),
          .HPRxmWriteData_o    (AvHPRxmWriteData_o    ),
          .HPRxmByteEnable_o   (AvHPRxmByteEnable_o   ),
          .HPRxmBurstCount_o   (AvHPRxmBurstCount_o     ),
          .HPRxmWaitRequest_i  (AvHPRxmWaitRequest_i  ),
          .HPRxmRead_o         (AvHPRxmRead_o         ),
          .HPRxmReadData_i     (AvHPRxmReadData_i     ),
          .HPRxmReadDataValid_i(AvHPRxmReadDataValid_i),
          .RxFifoRdReq_o       (rx_fifo_rdreq_from_hprxm),
          .RxFifoDataq_i       (rx_fifo_dataq ),
          .RxFifoCount_i       (rx_fifo_count ),
          .TxFifoWrReq_o       (tx_fifo_wrreq_from_hprxm ),
          .TxFifoData_o        (tx_fifo_data_from_hprxm ),
          .TxFifoCount_i       (tx_fifo_count),
          .SideFifoCount_i     (tx_side_fifo_count),
          .HPRxmArbReq_o       (hprxm_req ),
          .HPRxmArbGranted_i   (hprxm_granted ),
          .BusDev_i            (cfg_bus_dev),
          .DevCsr_i            (cfg_dev_csr)
   );
   end
   else begin
      assign AvHPRxmWrite_o              = 1'b0;
      assign AvHPRxmRead_o               = 1'b0;
      assign AvHPRxmAddress_o            = {(BAR2_TYPE){1'b0}};
      assign AvHPRxmWriteData_o          = {(DMA_WIDTH){1'b0}};
      assign AvHPRxmByteEnable_o         = {(DMA_WIDTH/8){1'b0}};
      assign AvHPRxmBurstCount_o         = {(DMA_BRST_CNT_W){1'b0}};
      assign rx_fifo_rdreq_from_hprxm    = 1'b0;
      assign tx_fifo_wrreq_from_hprxm    = 1'b0;
      assign tx_fifo_data_from_hprxm     =  260'h0;
      assign hprxm_req                   = 1'b0;
end
endgenerate


 generate if(COMPLETER_ONLY_HWTCL== 0) begin
// Txs instantiation
      altpcieav_dma_txs           #(
           .TX_S_ADDR_WIDTH        (TX_S_ADDR_WIDTH),
           .DMA_WIDTH              (DMA_WIDTH),
           .EXTENDED_TAG_ENABLE    (EXTENDED_TAG_ENABLE)
        ) txs_slave                (
          .Clk_i                   (Clk_i                   ),
          .Rstn_i                  (Rstn_i[4]                  ),
          .TxsChipSelect_i         (AvTxsChipSelect_i       ),
          .TxsWrite_i              (AvTxsWrite_i            ),
          .TxsAddress_i            (AvTxsAddress_i          ),
          .TxsWriteData_i          (AvTxsWriteData_i        ),
          .TxsByteEnable_i         (AvTxsByteEnable_i       ),
          .TxsWaitRequest_o        (AvTxsWaitRequest_o      ),
          .TxsRead_i               (AvTxsRead_i             ),
          .TxsReadData_o           (AvTxsReadData_o         ),
          .TxsReadDataValid_o      (AvTxsReadDataValid_o    ),
          .RxFifoRdReq_o           (rx_fifo_rdreq_from_txs  ),
          .RxFifoDataq_i           (rx_fifo_dataq           ),
          .RxFifoCount_i           (rx_fifo_count           ),
          .TxFifoWrReq_o           (tx_fifo_wrreq_from_txs  ),
          .TxFifoData_o            (tx_fifo_data_from_txs   ),
          .TxFifoCount_i           (tx_side_fifo_count      ),
          .TxsArbReq_o             (txs_req                 ),
          .TxsArbGranted_i         (txs_granted             ),
          .MasterEnable_i          ( pci_cmd_reg[2]         ),
          .BusDev_i                (cfg_bus_dev             )
      );
  end
  else
    begin
      assign  AvTxsWaitRequest_o      = 1'b0;   // TxsWaitRequest_o
      assign  AvTxsReadData_o         = 32'h0;  // TxsReadData_o
      assign  AvTxsReadDataValid_o    = 1'b0;   // TxsReadDataValid_o
      assign  rx_fifo_rdreq_from_txs  = 1'b0;   // RxFifoRdReq_o
      assign  tx_fifo_wrreq_from_txs  = 1'b0;   // TxFifoWrReq_o
      assign  tx_fifo_data_from_txs   = 260'h0; // TxFifoData_o
      assign  txs_req                 = 1'b0;   // TxsArbReq_o
    end
 endgenerate


// HIP interface module

   altpcieav_hip_interface # (
       .dma_use_scfifo_ext   (dma_use_scfifo_ext),
       .DEVICE_FAMILY        (DEVICE_FAMILY),
       .DMA_WIDTH            (DMA_WIDTH),
       .DMA_BE_WIDTH         (DMA_BE_WIDTH),
       .EXTENDED_TAG_ENABLE  (EXTENDED_TAG_ENABLE)
   ) hip_inf                 (
       .Clk_i                (Clk_i ),
       .Rstn_i               (Rstn_i[5] ),
       .RxStReady_o          (HipRxStReady_o  ),
       .RxStData_i           (HipRxStData_i  ),
       .RxStEmpty_i          (HipRxStEmpty_i  ),
       .RxStSop_i            (HipRxStSop_i ),
       .RxStEop_i            (HipRxStEop_i ),
       .RxStValid_i          (HipRxStValid_i  ),
       .RxStBarDec1_i        (HipRxStBarDec1_i ),
       .TxStReady_i          (HipTxStReady_i ),
       .TxStData_o           (HipTxStData_o ),
       .TxStSop_o            (HipTxStSop_o ),
       .TxStEop_o            (HipTxStEop_o ),
       .TxStEmpty_o          (HipTxStEmpty_o ),
       .TxStValid_o          (HipTxStValid_o ),
       .RxFifoRdReq_i        (rx_fifo_rdreq ),
       .RxFifoDataq_o        (rx_fifo_dataq ),
       .RxFifoCount_o        (rx_fifo_count ),
       .PreDecodeTagRdReq_i  (predecode_tag_rd_req),
       .PreDecodeTag_o       (predecode_tag),
       .PreDecodeTagCount_o  (predecode_tag_count),
       .TxFifoWrReq_i        (tx_fifo_wrreq ),
       .TxFifoData_i         (tx_fifo_data ),
       .TxFifoCount_o        (tx_fifo_count),
       .MsiIntfc_o           (AvMsiIntfc_o),
       .MsixIntfc_o          (AvMsixIntfc_o),
       .CfgAddr_i            (HipCfgAddr_i_r),
       .CfgCtl_i             (HipCfgCtl_i_r),
       .CfgBusDev_o          (cfg_bus_dev),
       .DevCsr_o             (cfg_dev_csr),
       .PciCmd_o             (pci_cmd_reg),
       .MsiDataCrl_o         (msi_data_cntrl)
   );


/// DMA read data mover

generate if(COMPLETER_ONLY_HWTCL== 0) begin
   altpcieav_dma_rd               # (  
      .DEVICE_FAMILY                (DEVICE_FAMILY          ),
      .dma_use_scfifo_ext           (dma_use_scfifo_ext     ),
      .DMA_WIDTH                    ( DMA_WIDTH             ),
      .DMA_BE_WIDTH                 ( DMA_BE_WIDTH          ),
      .DMA_BRST_CNT_W               ( DMA_BRST_CNT_W        ),
      .RDDMA_AVL_ADDR_WIDTH         ( RDDMA_AVL_ADDR_WIDTH  ),
      .NUM_TAG                      ( NUM_TAG               ),
      .NUM_TAG_WIDTH                ( NUM_TAG_WIDTH         ),
      .EXTENDED_TAG_ENABLE          (EXTENDED_TAG_ENABLE    )
   ) read_data_mover                (
      .Clk_i                        (  Clk_i                      ),
      .Rstn_i                       (  Rstn_i[6]                     ),
      .RdDmaWrite_o                 (  AvRdDmaWrite_o             ),
      .RdDmaAddress_o               (  AvRdDmaAddress_o           ),
      .RdDmaWriteData_o             (  AvRdDmaWriteData_o         ),
      .RdDmaBurstCount_o            (  AvRdDmaBurstCount_o        ),
      .RdDmaWriteEnable_o           (  AvRdDmaWriteEnable_o       ),
      .RdDmaWaitRequest_i           (  AvRdDmaWaitRequest_i       ),
      .RdDmaRxData_i                (  AvRdDmaRxData_i            ),
      .RdDmaRxValid_i               (  AvRdDmaRxValid_i           ),
      .RdDmaRxReady_o               (  AvRdDmaRxReady_o           ),
      .RdDmaTxData_o                (  AvRdDmaTxData_o            ),
      .RdDmaTxValid_o               (  AvRdDmaTxValid_o           ),
      .RxFifoRdReq_o                (  rx_fifo_rdreq_from_rd_dma  ),
      .RxFifoDataq_i                (  rx_fifo_dataq              ),
      .RxFifoCount_i                (  rx_fifo_count              ),
      .PreDecodeTagRdReq_o          (  predecode_tag_rd_req       ),
      .PreDecodeTag_i               (  predecode_tag              ),
      .PreDecodeTagCount_i          (  predecode_tag_count        ),
      .TxFifoWrReq_o                (  tx_fifo_wrreq_from_rd_dma  ),
      .TxFifoData_o                 (  tx_fifo_data_from_rd_dma   ),
      .TxFifoCount_i                (  tx_side_fifo_count         ),
      .RdDMACntrlLoad_i             (  1'b0                       ),
      .RdDMACntrlData_i             (  32'h0                      ),
      .RdDMAStatus_o                (  rd_dma_status_to_cra       ),
      .RdDMmaArbReq_o               (  rd_dma_req                 ),
      .RdDMmaArbGranted_i           (  rd_dma_granted             ),
      .BusDev_i                     (  cfg_bus_dev                ),
      .DevCsr_i                     (  cfg_dev_csr                ),
      .MasterEnable_i               (  pci_cmd_reg[2]             ),
      .ko_cpl_spc_header            (ko_cpl_spc_header            ),   
      .ko_cpl_spc_data              (ko_cpl_spc_data              )  

   );
end
 else begin
     assign AvRdDmaWrite_o             = 1'b0;                   //RdDmaWrite_o
     assign AvRdDmaAddress_o           = 64'h0;                  //RdDmaAddress_o
     assign AvRdDmaWriteData_o         = {DMA_WIDTH{1'b0}};      //RdDmaWriteData_o
     assign AvRdDmaBurstCount_o        = {DMA_BRST_CNT_W{1'b0}}; //RdDmaBurstCount_o
     assign AvRdDmaWriteEnable_o       = {DMA_BE_WIDTH{1'b0}};   //RdDmaWriteEnable_o
     assign AvRdDmaRxReady_o           = 1'b0;                   //RdDmaRxReady_o
     assign AvRdDmaTxData_o            = 32'h0;                  //RdDmaTxData_o
     assign AvRdDmaTxValid_o           = 1'b0;                   //RdDmaTxValid_o
     assign rx_fifo_rdreq_from_rd_dma  = 1'b0;               //RxFifoRdReq_o
     assign predecode_tag_rd_req       = 1'b0;               //PreDecodeTagRdReq_o
     assign tx_fifo_wrreq_from_rd_dma  = 1'b0;               //TxFifoWrReq_o
     assign tx_fifo_data_from_rd_dma   = 260'h0;             //TxFifoData_o
     assign rd_dma_status_to_cra       = 32'h0;                  //RdDMAStatus_o
     assign rd_dma_req                 = 1'b0;                   //RdDMmaArbReq_o
   end
endgenerate

//DMA write data mover
generate if(DMA_WIDTH == 128 && COMPLETER_ONLY_HWTCL== 0)
   begin
  altpcieav128_dma_wr             
   write_data_mover_128               (
  .Clk_i(Clk_i),
  .Srst_i(~Rstn_i),
  .WrDmaRead_o(AvWrDmaRead_o),
  .WrDmaAddress_o(AvWrDmaAddress_o),
  .WrDmaReadByteEnable_o        (AvWrDmaReadByteEnable_o)   ,
  .WrDmaBurstCount_o(AvWrDmaBurstCount_o),
  .WrDmaWaitRequest_i(AvWrDmaWaitRequest_i),
  .WrDmaReadDataValid_i(AvWrDmaReadDataValid_i),
  .WrDmaReadData_i(AvWrDmaReadData_i),
  .WrDmaRxData_i(AvWrDmaRxData_i),
  .WrDmaRxValid_i(AvWrDmaRxValid_i),
  .WrDmaRxReady_o(AvWrDmaRxReady_o),
  .WrDmaTxData_o(AvWrDmaTxData_o),
  .WrDmaTxValid_o(AvWrDmaTxValid_o),
  .SideFifoData_i(tx_side_fifo_output),
  .SideFifoCount_i(tx_side_fifo_count),
  .SideFifoRdreq_o(dma_wr_tx_side_fifo_rdreq),
  .HPRxmPending_i(hprxm_req),
  .WrDmaArbReq_o(hp_wr_dma_req),                                
  .WrDmaGrant_i(wr_dma_granted),
  .TxFifoCount_i(tx_fifo_count), 
  .TxFifoData_o(tx_fifo_data_from_wr_dma),
  .TxFifoWrReq_o(tx_fifo_wrreq_from_wr_dma),
  .BusDev_i (cfg_bus_dev),
  .DevCsr_i(cfg_dev_csr)
    );

  end
/*  else begin
      assign  AvWrDmaRead_o              = 1'b0;                   //WrDmaRead_o
      assign  AvWrDmaAddress_o           = 64'h0;                  //WrDmaAddress_o
      assign  AvWrDmaBurstCount_o        = {DMA_BRST_CNT_W{1'b0}}; //WrDmaBurstCount_o
      assign  AvWrDmaRxReady_o           = 1'b0;                   //WrDmaRxReady_o
      assign  AvWrDmaTxData_o            = 32'h0;                  //WrDmaTxData_o
      assign  AvWrDmaTxValid_o           = 1'b0;                   //WrDmaTxValid_o
      assign  rx_fifo_rdreq_from_wr_dma  = 1'b0;              //RxFifoRdReq_o
      assign  tx_fifo_wrreq_from_wr_dma  = 1'b0;              //TxFifoWrReq_o
      assign  tx_fifo_data_from_wr_dma   = 260'h0;            //TxFifoData_o
      assign  wr_dma_status_to_cra       = 32'h0;             //WrDMAStatus_o
      assign  lp_wr_dma_req              = 1'b0;              //WrDmaArbReq_o
      assign  hp_wr_dma_req              = 1'b0;              //WrDmaArbReq_o
   end */
endgenerate  /// WRDMA_VERSION 1



//DMA write data mover
generate if(WRDMA_VERSION_2 == 1 && COMPLETER_ONLY_HWTCL== 0)
   begin
   altpcieav_dma_wr_2             
   write_data_mover_2               (
  .Clk_i(Clk_i),
  .Srst_i(~Rstn_i),
  .WrDmaRead_o(AvWrDmaRead_o),
  .WrDmaAddress_o(AvWrDmaAddress_o),
  .WrDmaReadByteEnable_o        (AvWrDmaReadByteEnable_o)   ,
  .WrDmaBurstCount_o(AvWrDmaBurstCount_o),
  .WrDmaWaitRequest_i(AvWrDmaWaitRequest_i),
  .WrDmaReadDataValid_i(AvWrDmaReadDataValid_i),
  .WrDmaReadData_i(AvWrDmaReadData_i),
  .WrDmaRxData_i(AvWrDmaRxData_i),
  .WrDmaRxValid_i(AvWrDmaRxValid_i),
  .WrDmaRxReady_o(AvWrDmaRxReady_o),
  .WrDmaTxData_o(AvWrDmaTxData_o),
  .WrDmaTxValid_o(AvWrDmaTxValid_o),
  .SideFifoData_i(tx_side_fifo_output),
  .SideFifoCount_i(tx_side_fifo_count),
  .SideFifoRdreq_o(dma_wr_tx_side_fifo_rdreq),
  .HPRxmPending_i(hprxm_req),
  .WrDmaArbReq_o(hp_wr_dma_req),                                
  .WrDmaGrant_i(wr_dma_granted),
  .TxFifoCount_i(tx_fifo_count), 
  .TxFifoData_o(tx_fifo_data_from_wr_dma),
  .TxFifoWrReq_o(tx_fifo_wrreq_from_wr_dma),
  .BusDev_i (cfg_bus_dev),
  .DevCsr_i(cfg_dev_csr)
    );

  end

endgenerate

generate if(COMPLETER_ONLY_HWTCL!= 0)
   begin
      assign  AvWrDmaRead_o              = 1'b0;                   //WrDmaRead_o
      assign  AvWrDmaAddress_o           = 64'h0;                  //WrDmaAddress_o
      assign  AvWrDmaBurstCount_o        = {DMA_BRST_CNT_W{1'b0}}; //WrDmaBurstCount_o
      assign  AvWrDmaRxReady_o           = 1'b0;                   //WrDmaRxReady_o
      assign  AvWrDmaTxData_o            = 32'h0;                  //WrDmaTxData_o
      assign  AvWrDmaTxValid_o           = 1'b0;                   //WrDmaTxValid_o
      assign  AvWrDmaReadByteEnable_o    =  {DMA_BE_WIDTH{1'b0}};
      assign  rx_fifo_rdreq_from_wr_dma  = 1'b0;              //RxFifoRdReq_o
      assign  tx_fifo_wrreq_from_wr_dma  = 1'b0;              //TxFifoWrReq_o
      assign  tx_fifo_data_from_wr_dma   = 260'h0;            //TxFifoData_o
      assign  wr_dma_status_to_cra       = 32'h0;             //WrDMAStatus_o
      assign  lp_wr_dma_req              = 1'b0;              //WrDmaArbReq_o
      assign  hp_wr_dma_req              = 1'b0;              //WrDmaArbReq_o
   end
endgenerate  



/// arbiter

   altpcieav_arbiter arbiter_inst (
      .Clk_i                      (Clk_i),
      .Rstn_i                     (Rstn_i[8]),
      .TxsArbReq_i                (txs_req),
      .RxmArbReq_i                (rxm_req),
      .HPRxmArbReq_i              (hprxm_req),
      .DMAWrArbReq_i              (hp_wr_dma_req), // Write DMA does not obey arbiter
      .DMARdArbReq_i              (rd_dma_req),
      .TxsArbGrant_o              (txs_granted),
      .RxmArbGrant_o              (rxm_granted),
      .HPRxmArbGrant_o            (hprxm_granted),
      .DMAWrArbGrant_o            (wr_dma_granted),
      .DMARdArbGrant_o            (rd_dma_granted)
   );

// CRA module

generate if(enable_cra_hwtcl == 1) begin
      altpcieav_cra altpcieav_cra_inst (
         .Clk_i                        (Clk_i ),
         .Rstn_i                       (Rstn_i[8] ),
         .CraChipSelect_i              (AvCraChipSelect_i ),
         .CraRead_i                    (AvCraRead_i ),
         .CraWrite_i                   (AvCraWrite_i ),
         .CraAddress_i                 (AvCraAddress_i ),
         .CraWriteData_i               (AvCraWriteData_i ),
         .CraByteEnable_i              (AvCraByteEnable_i ),
         .CraWaitRequest_o             (AvCraWaitRequest_o ),
         .CraReadData_o                (AvCraReadData_o ),
         .CfgAddr_i                    (HipCfgAddr_i_r ),
         .CfgCtl_i                     (HipCfgCtl_i_r),
         .Ltssm_i                      (Ltssm_i),
         .CurrentSpeed_i               (CurrentSpeed_i),
         .LaneAct_i                    (LaneAct_i)
      );
   end
   else begin
      assign AvCraWaitRequest_o = 1'b1;
      assign AvCraReadData_o    = 32'h0;
   end
endgenerate


assign HipCplPending_o   = 1'b0;
assign rx_fifo_rdreq     = rx_fifo_rdreq_from_rxm | rx_fifo_rdreq_from_txs | rx_fifo_rdreq_from_rd_dma | rx_fifo_rdreq_from_hprxm;
//assign tx_fifo_wrreq     = tx_fifo_wrreq_from_rxm | tx_fifo_wrreq_from_txs | tx_fifo_wrreq_from_rd_dma | tx_fifo_wrreq_from_wr_dma;
//assign tx_fifo_data      = txs_granted? tx_fifo_data_from_txs :  rxm_granted? tx_fifo_data_from_rxm : rd_dma_granted? tx_fifo_data_from_rd_dma : tx_fifo_data_from_wr_dma;
//generate if(WRDMA_VERSION_2 == 0)
// begin
//    assign tx_fifo_wrreq = tx_fifo_wrreq_from_wr_dma | tx_fifo_wrreq_from_hprxm | insert_side_tlp;
//    assign tx_fifo_data = insert_side_tlp ? tx_side_fifo_output : hprxm_granted? tx_fifo_data_from_hprxm : tx_fifo_data_from_wr_dma;
// end
//else
//  begin
    assign tx_fifo_wrreq = tx_fifo_wrreq_from_wr_dma | tx_fifo_wrreq_from_hprxm;
    assign tx_fifo_data  = hprxm_granted? tx_fifo_data_from_hprxm : tx_fifo_data_from_wr_dma;
//end
//endgenerate

/// Tx side buffer to hold TXS and Read TLP for simultaneous operation
/// Leting the write have exclusive right the TX output buffer
/// The side buffer will be emptied into the Tx output buffer when the Write DMA is in idle cycle

generate begin : g_tx_side_fifo
   if (dma_use_scfifo_ext>0) begin
      wire [4:0] tx_side_fifo_count_ext;
      reg [2:0] Rst_i_sync;
      always_ff @ (posedge Clk_i or negedge Rstn_i[2]) begin
         if(~Rstn_i[2]) begin
            Rst_i_sync<=3'h7;
         end
         else begin
            Rst_i_sync[2]<=Rst_i_sync[1];
            Rst_i_sync[1]<=Rst_i_sync[0];
            Rst_i_sync[0]<=1'b0;
         end
      end
      if (dma_use_scfifo_ext==1) begin // Family=A10
         altpcie_scfifo_a10   #(
               .WIDTH          (260), // typical 20,40,60,80
               .NUM_FIFO32     (0)    // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )   tx_side_fifo      (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (tx_side_fifo_input_r),
               .wreq           (tx_side_fifo_wrreq_r),
               .full           (),
               .rdata          (tx_side_fifo_output),
               .rreq           (tx_side_fifo_rdreq),
               .empty          (),
               .used           (tx_side_fifo_count_ext)
         );
      end
      else if (dma_use_scfifo_ext==2) begin // Family=SV
         altpcie_scfifo   #(
               .WIDTH          (260), // typical 20,40,60,80
               .NUM_FIFO32     (0)    // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )   tx_side_fifo      (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (tx_side_fifo_input_r),
               .wreq           (tx_side_fifo_wrreq_r),
               .full           (),
               .rdata          (tx_side_fifo_output),
               .rreq           (tx_side_fifo_rdreq),
               .empty          (),
               .used           (tx_side_fifo_count_ext)
         );
      end
      assign tx_side_fifo_count[3:0] = tx_side_fifo_count_ext[3:0];
   end
   else begin
      altpcie_fifo #(
          .FIFO_DEPTH      ( 16),
          .DATA_WIDTH      ( 260)
          ) tx_side_fifo   (
            .clk           ( Clk_i),
            .rstn          ( Rstn_i[9]),
            .srst          ( 1'b0),
            .wrreq         ( tx_side_fifo_wrreq_r),
            .rdreq         ( tx_side_fifo_rdreq),
            .data          ( tx_side_fifo_input_r),
            .q             ( tx_side_fifo_output),
            .fifo_count    ( tx_side_fifo_count)
      );
   end
end
endgenerate


 always_ff @ (posedge Clk_i or negedge Rstn_i[8])
     begin
       if(~Rstn_i[8])
     begin
         tx_side_fifo_wrreq_r <= 1'h0;
         tx_side_fifo_input_r <= 260'h0;
     end
       else
     begin
         tx_side_fifo_wrreq_r <= tx_side_fifo_wrreq;
         tx_side_fifo_input_r <= tx_side_fifo_input;
      end
     end

assign tx_side_fifo_wrreq =  tx_fifo_wrreq_from_rxm | tx_fifo_wrreq_from_txs | tx_fifo_wrreq_from_rd_dma;
assign tx_side_fifo_input =  txs_granted? tx_fifo_data_from_txs :  rxm_granted? tx_fifo_data_from_rxm : tx_fifo_data_from_rd_dma;


  assign tx_side_fifo_rdreq = dma_wr_tx_side_fifo_rdreq;



//==========================
// Unused outputs
assign HipRxStMask_o = 1'b0;


endmodule

