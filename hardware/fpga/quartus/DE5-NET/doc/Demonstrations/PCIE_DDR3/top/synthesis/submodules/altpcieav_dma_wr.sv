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
module altpcieav_dma_wr # (
   parameter DEVICE_FAMILY                   = "Stratix V",
   parameter dma_use_scfifo_ext              = 2,
   parameter SRIOV_EN                        = 0,
   parameter ARI_EN                          = 0,
   parameter PHASE1                          = 1,   // Indicate phase1 of SR-IOV
   parameter VF_COUNT                        = 32,  // Total Number of Virtual Functions
   parameter DMA_WIDTH                       = 256,
   parameter DMA_BE_WIDTH                    = 5,
   parameter DMA_BRST_CNT_W                  = 5,
   parameter WRDMA_AVL_ADDR_WIDTH            = 20,
   parameter WRDMA_RXDATA_WIDTH              = (SRIOV_EN == 1) ? 168 : 160,
   parameter RXFIFO_DATA_WIDTH               = (SRIOV_EN == 1) ? 274 : 266,
   parameter TX_FIFO_WIDTH                   = (DMA_WIDTH == 256) ? 260 : 131   //Data+Sop+Eop+Empty
   )
   (
   input    logic                     Clk_i,
   input    logic                     Rstn_i,

   // Avalon-MM Interface
   // Upstream PCIe Write DMA master port

   output   logic                     WrDmaRead_o,
   output   logic[63:0]               WrDmaAddress_o,
   output   logic[DMA_BRST_CNT_W-1:0] WrDmaBurstCount_o,
   input    logic                     WrDmaWaitRequest_i,
   input    logic                     WrDmaReadDataValid_i,
   input    logic[DMA_WIDTH-1:0]      WrDmaReadData_i,

   /// AST Inteface
   // Write DMA AST Rx port
   input    logic[WRDMA_RXDATA_WIDTH-1:0] WrDmaRxData_i,
   input    logic                     WrDmaRxValid_i,
   output   logic                     WrDmaRxReady_o,

   // Write DMA AST Tx port
   output   logic[31:0]               WrDmaTxData_o,
   output   logic                     WrDmaTxValid_o,

   // Rx fifo Interface
   output   logic                     RxFifoRdReq_o,
   input    logic[RXFIFO_DATA_WIDTH-1:0] RxFifoDataq_i,
   input    logic[3:0]                RxFifoCount_i,

   // Tx fifo Interface
   output   logic                     TxFifoWrReq_o,
   output   logic[TX_FIFO_WIDTH-1:0]  TxFifoData_o,
   input    logic[3:0]                TxFifoCount_i,

   // General CRA interface
   input    logic                     WrDMACntrlLoad_i,
   input    logic[31:0]               WrDMACntrlData_i,
   output   logic[31:0]               WrDMAStatus_o,

   // Arbiter Interface
   output   logic                     WrDmaLPArbReq_o,
   output   logic                     WrDmaHPArbReq_o,
   input    logic                     WrDmaLPArbReq_i,
   input    logic                     WrDmaHPArbReq_i,
   input    logic                     WrDmaArbGranted_i,

   input    logic[15:0]               BusDev_i,
   input    logic[31:0]               DevCsr_i,
   input    logic                     MasterEnable,
   input    logic[VF_COUNT-1:0]       vf_MasterEnable_i  // SR-IOV VF Master Enable
   );

   logic        wd_align_fifo_wrreq;
   logic        wd_align_fifo_full;
   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_wdata;

   logic        update_credit;
   logic[7:0]   data_sent;

   logic        send_desc_fifo_wrreq;
   logic        send_desc_fifo_full;
   logic[4:0]   send_desc_fifo_count;
   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_wdata;

   logic        desc_fifo_full;

   logic[DMA_WIDTH-1:0] send_data_fifo_wdata;
   logic        send_data_fifo_wrreq;
   logic[17:0]  send_data_fifo_wrcnt;
   logic        send_data_fifo_full;

   logic        data_fifo_rdreq;
   logic        data_fifo_empty;
   logic[DMA_WIDTH-1:0] data_fifo_data;
   logic[8:0] data_fifo_count;

   logic        desc_error;
   logic[7:0]   cur_req_func;
   logic        avst_file_end;
   logic[7:0]   avst_file_num;
   logic        wr_idle_state;

// Unused Outputs
assign RxFifoRdReq_o = 1'b0;

// Descriptor Status Register
assign WrDMAStatus_o  = (SRIOV_EN == 1) ? {cur_req_func, 5'h0, desc_error, 8'h0, !wr_idle_state, avst_file_end, avst_file_num} :
                                          {8'h0, 5'h0, desc_error, 8'h0, !wr_idle_state, avst_file_end, avst_file_num};
assign WrDmaTxData_o  = (SRIOV_EN == 1) ? {cur_req_func, 5'h0, desc_error, 8'h0, !wr_idle_state, avst_file_end, avst_file_num} :
                                          {8'h0, 5'h0, desc_error, 8'h0, !wr_idle_state, avst_file_end, avst_file_num};
assign WrDmaTxValid_o = avst_file_end;

// Back pressure to descriptor controller to send descriptors
// Send desc fifo slightly shallower to allow the wd align sm to pre read the desc always
assign WrDmaRxReady_o  = ~desc_fifo_full && ~wd_align_fifo_full && (send_desc_fifo_count <= 5'h1D);

// Select the appripriate fifo depending on device family

localparam dma_use_scfifo = (DEVICE_FAMILY == "Stratix V") ? 2 : ((DEVICE_FAMILY == "Arria 10") ? 1 : 0);

   altpcieav_dma_wr_readmem # (
      .dma_use_scfifo               (dma_use_scfifo        ),
      .SRIOV_EN                     (SRIOV_EN              ),
      .ARI_EN                       (ARI_EN                ),
      .PHASE1                       (PHASE1                ),
      .VF_COUNT                     (VF_COUNT              ),
      .DMA_WIDTH                    (DMA_WIDTH             ),
      .DMA_BE_WIDTH                 (DMA_BE_WIDTH          ),
      .DMA_BRST_CNT_W               (DMA_BRST_CNT_W        ),
      .WRDMA_AVL_ADDR_WIDTH         (WRDMA_AVL_ADDR_WIDTH  )
      ) altpcieav_dma_wr_readmem_inst (
      .Clk_i(Clk_i),
      .Rstn_i(Rstn_i),
      .WrDmaRead_o(WrDmaRead_o),
      .WrDmaAddress_o(WrDmaAddress_o),
      .WrDmaBurstCount_o(WrDmaBurstCount_o),
      .WrDmaWaitRequest_i(WrDmaWaitRequest_i),
      .WrDmaReadDataValid_i(WrDmaReadDataValid_i),
      .WrDmaReadData_i(WrDmaReadData_i),
      .WrDmaRxData_i(WrDmaRxData_i),
      .WrDmaRxValid_i(WrDmaRxValid_i),
      .BusDev_i(BusDev_i),
      .DevCsr_i(DevCsr_i),
      .MasterEnable(MasterEnable),
      .vf_MasterEnable_i(vf_MasterEnable_i),
      .wd_align_fifo_wdata_o(wd_align_fifo_wdata),
      .wd_align_fifo_wrreq_o(wd_align_fifo_wrreq),
      .wd_align_fifo_full_i(wd_align_fifo_full),
      .send_desc_fifo_full_i(send_desc_fifo_full),
      .data_fifo_rdreq_i(data_fifo_rdreq),
      .data_fifo_empty_o(data_fifo_empty),
      .data_fifo_data_o(data_fifo_data),
      .data_fifo_count_o(data_fifo_count),
      .desc_fifo_full_o(desc_fifo_full),
      .update_credit_i(update_credit),
      .data_sent_i(data_sent),
      .desc_error_o(desc_error)
   );


   altpcieav_dma_wr_wdalign # (
      .dma_use_scfifo               (dma_use_scfifo        ),
      .SRIOV_EN                     (SRIOV_EN              ),
      .ARI_EN                       (ARI_EN                ),
      .PHASE1                       (PHASE1                ),
      .VF_COUNT                     (VF_COUNT              ),
      .DMA_WIDTH                    (DMA_WIDTH             ),
      .DMA_BE_WIDTH                 (DMA_BE_WIDTH          ),
      .DMA_BRST_CNT_W               (DMA_BRST_CNT_W        ),
      .WRDMA_AVL_ADDR_WIDTH         (WRDMA_AVL_ADDR_WIDTH  )
      ) altpcieav_dma_wr_wdalign_inst (
      .Clk_i(Clk_i),
      .Rstn_i(Rstn_i),
      .wd_align_fifo_wdata_i(wd_align_fifo_wdata),
      .wd_align_fifo_wrreq_i(wd_align_fifo_wrreq),
      .wd_align_fifo_full_o(wd_align_fifo_full),
      .data_fifo_rdreq_o(data_fifo_rdreq),
      .data_fifo_empty_i(data_fifo_empty),
      .data_fifo_data_i(data_fifo_data),
      .send_desc_fifo_full_i(send_desc_fifo_full),
      .send_desc_fifo_wdata_o(send_desc_fifo_wdata),
      .send_desc_fifo_wrreq_o(send_desc_fifo_wrreq),
      .send_data_fifo_full_i(send_data_fifo_full),
      .send_data_fifo_wdata_o(send_data_fifo_wdata),
      .send_data_fifo_wrreq_o(send_data_fifo_wrreq),
      .send_data_fifo_wrcnt_o(send_data_fifo_wrcnt)
   );

   altpcieav_dma_wr_tlpgen # (
      .dma_use_scfifo               (dma_use_scfifo        ),
      .SRIOV_EN                     (SRIOV_EN              ),
      .ARI_EN                       (ARI_EN                ),
      .PHASE1                       (PHASE1                ),
      .VF_COUNT                     (VF_COUNT              ),
      .DMA_WIDTH                    (DMA_WIDTH             ),
      .DMA_BE_WIDTH                 (DMA_BE_WIDTH          ),
      .DMA_BRST_CNT_W               (DMA_BRST_CNT_W        ),
      .WRDMA_AVL_ADDR_WIDTH         (WRDMA_AVL_ADDR_WIDTH  )
      ) altpcieav_dma_wr_tlpgen_inst (
      .Clk_i(Clk_i),
      .Rstn_i(Rstn_i),
      .send_desc_fifo_wdata_i(send_desc_fifo_wdata),
      .send_desc_fifo_wrreq_i(send_desc_fifo_wrreq),
      .send_desc_fifo_full_o(send_desc_fifo_full),
      .send_desc_fifo_count_o(send_desc_fifo_count),
      .send_data_fifo_wdata_i(send_data_fifo_wdata),
      .send_data_fifo_wrreq_i(send_data_fifo_wrreq),
      .send_data_fifo_full_o(send_data_fifo_full),
      .cur_req_func_o(cur_req_func),
      .avst_file_end_o(avst_file_end),
      .avst_file_num_o(avst_file_num),
      .wr_idle_state_o(wr_idle_state),
      .TxFifoWrReq_o(TxFifoWrReq_o),
      .TxFifoData_o(TxFifoData_o),
      .TxFifoCount_i(TxFifoCount_i),
      .WrDmaLPArbReq_o(WrDmaLPArbReq_o),
      .WrDmaHPArbReq_o(WrDmaHPArbReq_o),
      .WrDmaLPArbReq_i(WrDmaLPArbReq_i),
      .WrDmaHPArbReq_i(WrDmaHPArbReq_i),
      .WrDmaArbGranted_i(WrDmaArbGranted_i),
      .update_credit_o(update_credit),
      .data_sent_o(data_sent),
      .BusDev_i(BusDev_i),
      .DevCsr_i(DevCsr_i),
      .MasterEnable(MasterEnable),
      .vf_MasterEnable_i(vf_MasterEnable_i)
   );


//wrdma_assertions wrdma_assertions_inst(
//   );

endmodule

//program wrdma_assertions(
//   );

//endprogram

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpcieav_dma_wr_readmem # (
   parameter dma_use_scfifo                  = 2,
   parameter SRIOV_EN                        = 0,
   parameter ARI_EN                          = 0,
   parameter PHASE1                          = 1,   // Indicate phase1 of SR-IOV
   parameter VF_COUNT                        = 32,  // Total Number of Virtual Functions
   parameter DMA_WIDTH                       = 256,
   parameter DMA_BE_WIDTH                    = 5,
   parameter DMA_BRST_CNT_W                  = 5,
   parameter WRDMA_AVL_ADDR_WIDTH            = 20,
   parameter WRDMA_RXDATA_WIDTH              = (SRIOV_EN == 1) ? 168 : 160,
   parameter RXFIFO_DATA_WIDTH               = (SRIOV_EN == 1) ? 274 : 266,
   parameter TX_FIFO_WIDTH                   = (DMA_WIDTH == 256) ? 260 : 131   //Data+Sop+Eop+Empty
   )
   (
   input    logic                     Clk_i,
   input    logic                     Rstn_i,

   // Avalon-MM Interface
   // Upstream PCIe Write DMA master port

   output   logic                     WrDmaRead_o,
   output   logic[63:0]               WrDmaAddress_o,
   output   logic[DMA_BRST_CNT_W-1:0] WrDmaBurstCount_o,
   input    logic                     WrDmaWaitRequest_i,
   input    logic                     WrDmaReadDataValid_i,
   input    logic[DMA_WIDTH-1:0]      WrDmaReadData_i,

   /// AST Inteface
   // Write DMA AST Rx port
   input    logic[WRDMA_RXDATA_WIDTH-1:0] WrDmaRxData_i,
   input    logic                     WrDmaRxValid_i,

   input    logic[15:0]               BusDev_i,
   input    logic[31:0]               DevCsr_i,
   input    logic                     MasterEnable,
   input    logic[VF_COUNT-1:0]       vf_MasterEnable_i,  // SR-IOV VF Master Enable

   // Word Align FIFO interface signals
   output   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_wdata_o,
   output   logic                     wd_align_fifo_wrreq_o,
   input    logic                     data_fifo_rdreq_i,
   output   logic                     data_fifo_empty_o,
   output   logic[DMA_WIDTH-1:0]      data_fifo_data_o,
   output   logic[8:0]                data_fifo_count_o,

   // FIFO back pressure signal
   input    logic                     wd_align_fifo_full_i,
   input    logic                     send_desc_fifo_full_i,
   output   logic                     desc_fifo_full_o,

   // Signals for credit calculation
   input    logic                     update_credit_i,
   input    logic[7:0]                data_sent_i,

   // Error signals
   output   logic                     desc_error_o
   );

   localparam  RD_IDLE     = 6'h00;
   localparam  RD_FIFO_RD  = 6'h01;
   localparam  RD_DEASSERT = 6'h02;
   localparam  RD_CONT     = 6'h03;

   localparam  FILE_SIZE_WIDTH = 18;
   localparam  DATA_FIFO_WIDTH = (DMA_WIDTH == 256) ? 260 : 140;

   logic        desc_fifo_rdreq;
   logic[1:0]   desc_fifo_rdreq_reg;
   logic        desc_fifo_wrreq;
   logic        desc_fifo_rst;
   logic[WRDMA_RXDATA_WIDTH-1:0] desc_fifo_data;
   logic[WRDMA_RXDATA_WIDTH-1:0] desc_fifo_data_int;
   logic[WRDMA_RXDATA_WIDTH-1:0] desc_fifo_data_reg;
   logic[3:0]   desc_fifo_count;
   logic        desc_fifo_empty;

   logic[63:0]  cur_dest_addr_reg;
   logic[63:0]  cur_src_addr_reg;
   logic[17:0]  cur_dma_dw_count_reg;
   logic[7:0]   cur_desc_id_reg;

   logic[5:0]   rdmem_sm;
   logic[63:0]  WrDmaAddress_reg;

   logic        WrDmaReadDataValid_reg;
   logic[DMA_WIDTH-1:0] WrDmaReadData_reg;

   logic[3:0]   dw_cnt_offset;
   logic[17:0]  dw_cnt_write;
   logic[63:0]  cur_src_addr;

   logic[7:0]   max_payld_size;


   logic[FILE_SIZE_WIDTH-1:0] file_size_remain; // number of DWs remaining to be transferred
   logic[7:0]   max_payld_size_reg;            // input pipe reg for fmax
   logic[FILE_SIZE_WIDTH:0] total_desc_dw;

   logic[3:0]   dw_cnt_in_word;

   // SRIOV signals
   logic        cur_MasterEnable;
   logic        vf_active;
   logic[7:0]   cur_req_func;
   logic        error_status;
   logic        error_status_reg;
   logic        vf_master_en;

   // Credit calculation signals
   logic        update_credit_latched;
   logic[7:0]   data_sent_latched;
   logic[8:0]   credit_available;


assign wd_align_fifo_wdata_o = desc_fifo_data_reg;
assign wd_align_fifo_wrreq_o = desc_fifo_rdreq_reg[1];

// SR-IOV: decode cur_MasterEnable associate with the current requestor function
// For phase1, VF function number starts at 32   => cur_req_func[5]
// For phase2, VF function number starts at 128  => cur_req_func[7]

generate
  begin
    if ((SRIOV_EN == 1) & (PHASE1 ==1)) begin
        assign vf_active = cur_req_func[5];
    end else if ((SRIOV_EN == 1) & (PHASE1 ==0)) begin
        assign vf_active = cur_req_func[7];
    end else begin
        assign vf_active = 0;
    end
  end
endgenerate

generate if(SRIOV_EN == 1)
  begin
     altpcieav_sriov_vf_mux #(VF_COUNT, 1)  vf_master_en_sel_i (vf_MasterEnable_i, cur_req_func[4:0], vf_master_en);
  end
  else begin
     assign vf_master_en = 1'b0;
  end
endgenerate

assign cur_MasterEnable = vf_active ? vf_master_en : MasterEnable;


always_comb
begin
   case(DevCsr_i[7:5])
      3'b000  : max_payld_size = 8'h20;  //128b
      3'b001  : max_payld_size = 8'h40;  //256b
      3'b010  : max_payld_size = 8'h80;  //512b
      default : max_payld_size = 8'h80;  //512b
   endcase
end

// Desc FIFO signals
assign desc_fifo_wrreq = WrDmaRxValid_i;
assign desc_fifo_rst   = ~Rstn_i;


/// current descriptor
always_ff @ (posedge Clk_i)
   if(desc_fifo_rdreq_reg[0]) begin
      cur_dest_addr_reg    <= desc_fifo_data[127:64];
      cur_src_addr_reg     <= desc_fifo_data[63:0];
      cur_dma_dw_count_reg <= desc_fifo_data[145:128];
      cur_desc_id_reg      <= desc_fifo_data[153:146];
      cur_req_func         <= (SRIOV_EN == 1) ? desc_fifo_data[167:160] : 8'h0;
      desc_fifo_data_reg   <= desc_fifo_data;
   end

assign dw_cnt_offset = (DMA_WIDTH == 256) ? cur_src_addr_reg[4:2] : cur_src_addr_reg[3:2];
assign total_desc_dw = cur_dma_dw_count_reg + dw_cnt_offset;

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      WrDmaReadDataValid_reg <= 1'b0;
   end
   else begin
      WrDmaReadDataValid_reg <= WrDmaReadDataValid_i;
      WrDmaReadData_reg      <= WrDmaReadData_i;
   end
end

generate begin : g_wrfifo
   if (dma_use_scfifo>0) begin
      reg [2:0] Rst_i_sync;
      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
         if(~Rstn_i) begin
            Rst_i_sync <= 3'h7;
         end
         else begin
            Rst_i_sync[2] <= Rst_i_sync[1];
            Rst_i_sync[1] <= Rst_i_sync[0];
            Rst_i_sync[0] <= 1'b0;
         end
      end

/// usedw counter sicne the usedw output is not reflecting real value
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
        if(~Rstn_i) begin
           desc_fifo_count <= 4'h0;
        end
        else begin
           if (desc_fifo_wrreq & ~desc_fifo_rdreq)
              desc_fifo_count <= desc_fifo_count + 1;
           else if (~desc_fifo_wrreq & desc_fifo_rdreq)
              desc_fifo_count <= desc_fifo_count - 1;
        end
     end

   assign desc_fifo_full_o = (desc_fifo_count >= 4'h8);

      if (dma_use_scfifo==1) begin
         altpcie_scfifo_a10   #(
           .WIDTH            (WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
           .NUM_FIFO32       (0)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  write_desc_fifo    (
           .clk            (Clk_i),
           .sclr           (Rst_i_sync[2]|desc_fifo_rst),
           .wdata          (WrDmaRxData_i),
           .wreq           (desc_fifo_wrreq),
           .full           (),
           .rdata          (desc_fifo_data),
           .rreq           (desc_fifo_rdreq),
           .empty          (desc_fifo_empty),
           .used           ()
         );

         altpcie_a10_scfifo_ext       # (
            .add_ram_output_register    ("OFF"                   ),
            .intended_device_family     ("Stratix V"             ),
            .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
            .lpm_numwords               (512                     ),
            .lpm_showahead              ("OFF"                    ),
            .lpm_type                   ("scfifo"                ),
            .lpm_width                  (DATA_FIFO_WIDTH         ),
            .lpm_widthu                 (9                       ),
            .overflow_checking          ("ON"                    ),
            .underflow_checking         ("ON"                    ),
            .use_eab                    ("ON"                    )
         ) write_data_fifo              (
            .aclr                       (~Rstn_i),
            .clock                      (Clk_i),
            .data                       (WrDmaReadData_reg),
            .rdreq                      (data_fifo_rdreq_i),
            .sclr                       (1'b0),
            .wrreq                      (WrDmaReadDataValid_reg),
            .empty                      (data_fifo_empty_o),
            .full                       (),
            .q                          (data_fifo_data_o),
            .usedw                      (data_fifo_count_o),
            .almost_empty               (),
            .almost_full                ()
         );


      end

      else if (dma_use_scfifo==2) begin
         altpcie_scfifo      # (
           .WIDTH            (160), //(WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
           .NUM_FIFO32       (0)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  write_desc_fifo    (
           .clk            (Clk_i),
           .sclr           (Rst_i_sync[2]|desc_fifo_rst),
           .wdata          (WrDmaRxData_i),
           .wreq           (desc_fifo_wrreq),
           .full           (),
           .rdata          (desc_fifo_data),
           .rreq           (desc_fifo_rdreq),
           .empty          (desc_fifo_empty),
           .used           ()
         );

        altpcie_sv_scfifo_ext        # (
            .add_ram_output_register    ("OFF"                   ),
            .intended_device_family     ("Stratix V"             ),
            .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
            .lpm_numwords               (512               ),
            .lpm_showahead              ("OFF"                    ),
            .lpm_type                   ("scfifo"                ),
            .lpm_width                  (DATA_FIFO_WIDTH         ),
            .lpm_widthu                 (9                       ),
            .overflow_checking          ("ON"                    ),
            .underflow_checking         ("ON"                    ),
            .use_eab                    ("ON"                    )
         ) write_data_fifo              (
            .aclr                       (~Rstn_i),
            .clock                      (Clk_i),
            .data                       (WrDmaReadData_reg),
            .rdreq                      (data_fifo_rdreq_i),
            .sclr                       (1'b0),
            .wrreq                      (WrDmaReadDataValid_reg),
            .empty                      (data_fifo_empty_o),
            .full                       (),
            .q                          (data_fifo_data_o),
            .usedw                      (data_fifo_count_o),
            .almost_empty               (),
            .almost_full                ()
         );

      end
   end
   else begin
      // Descriptor FIFO
      altpcie_fifo #(
         .FIFO_DEPTH(16),
         .DATA_WIDTH(WRDMA_RXDATA_WIDTH)
         )
         write_desc_fifo  (
         .clk          (Clk_i),
         .rstn         (Rstn_i),
         .srst         (desc_fifo_rst),
         .wrreq        (desc_fifo_wrreq),
         .rdreq        (desc_fifo_rdreq),
         .data         (WrDmaRxData_i),
         .q            (desc_fifo_data_int),
         .fifo_count   (desc_fifo_count)
      );
      // Data FIFO
      scfifo                       # (
         .add_ram_output_register    ("OFF"                   ),
         .intended_device_family     ("Stratix V"             ),
         .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
         .lpm_numwords               (512                     ),
         .lpm_showahead              ("OFF"                    ),
         .lpm_type                   ("scfifo"                ),
         .lpm_width                  (DATA_FIFO_WIDTH         ),
         .lpm_widthu                 (9                       ),
         .overflow_checking          ("ON"                    ),
         .underflow_checking         ("ON"                    ),
         .use_eab                    ("ON"                    )
      ) write_data_fifo              (
         .aclr                       (~Rstn_i),
         .clock                      (Clk_i),
         .data                       (WrDmaReadData_reg),
         .rdreq                      (data_fifo_rdreq_i),
         .sclr                       (1'b0),
         .wrreq                      (WrDmaReadDataValid_reg),
         .empty                      (data_fifo_empty_o),
         .full                       (),
         .q                          (data_fifo_data_o),
         .usedw                      (data_fifo_count_o),
         .almost_empty               (),
         .almost_full                ()
      );

      assign desc_fifo_empty  = (desc_fifo_count == 0);
      assign desc_fifo_full_o = (desc_fifo_count >= 4'h8);
      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
         if(~Rstn_i)
            desc_fifo_data <= 256'h0;
         else if (desc_fifo_rdreq)
            desc_fifo_data <= desc_fifo_data_int;
      end

   end
end
endgenerate

assign dw_cnt_in_word = (DMA_WIDTH == 256) ? 4'd8 : 4'd4;     //# of DW's in 256 bits=8; in 128 bits=4


//--------------------------------------------------
// Fetch Data from Memory
//---------------------------------------------------

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      rdmem_sm            <= RD_IDLE;
      WrDmaRead_o         <= 1'b0;
      dw_cnt_write        <= 18'h0;
      WrDmaBurstCount_o   <= 5'h0;
      WrDmaAddress_o      <= 64'h0;
      WrDmaAddress_reg    <= 64'h0;
      error_status        <= 1'b0; // SRIOV
      desc_fifo_rdreq     <= 1'b0;
      desc_fifo_rdreq_reg <= 2'b00;
   end
   else begin
      desc_fifo_rdreq_reg <= {desc_fifo_rdreq_reg[0], desc_fifo_rdreq};
      case (rdmem_sm)
         RD_IDLE: begin
            if(~desc_fifo_empty && ~wd_align_fifo_full_i && ~send_desc_fifo_full_i) begin
               desc_fifo_rdreq   <= 1'b1;
               rdmem_sm          <= RD_FIFO_RD;
               WrDmaRead_o       <= 1'b0;
               dw_cnt_write      <= 18'h0;
               WrDmaBurstCount_o <= 5'h0;
               WrDmaAddress_o    <= 64'h0;
            end
            else begin
               desc_fifo_rdreq   <= 1'b0;
               rdmem_sm          <= RD_IDLE;
               WrDmaRead_o       <= 1'b0;
               dw_cnt_write      <= 18'h0;
               WrDmaBurstCount_o <= 5'h0;
               WrDmaAddress_o    <= 64'h0;
            end
         end

         RD_FIFO_RD: begin
            desc_fifo_rdreq <= 1'b0;
            if (desc_fifo_rdreq_reg[1] & cur_MasterEnable) begin
               WrDmaAddress_o  <= cur_src_addr_reg;
               error_status    <= 1'b0;

               if (credit_available >= ((DMA_WIDTH == 256) ? {1'b1, max_payld_size[7:3]} :
                                                         {1'b1, max_payld_size[7:2]})) begin
                  WrDmaRead_o     <= 1'b1;
                  rdmem_sm        <= RD_DEASSERT;
                  if (total_desc_dw <= max_payld_size) begin
                     WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? (total_desc_dw[7:3] + |total_desc_dw[2:0]):      // 8 dw's on 256 bit ifc
                                                               (total_desc_dw[7:2] + |total_desc_dw[1:0]);      // 4 dw's on 128 bit ifc
                     dw_cnt_write      <= 18'h0;
                  end
                  else if (max_payld_size == 8'h80 ) begin
                     WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? max_payld_size[7:3] : max_payld_size[7:2];      // max_payld_size/dw_cnt_in_word
                     dw_cnt_write      <= total_desc_dw - max_payld_size;
                  end
                  else begin
                     if (total_desc_dw <= {max_payld_size[7:0], 1'b0}) begin                                    // max_payld_size*2
                        WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? (total_desc_dw[18:3] + |total_desc_dw[2:0]):  // 8 dw's on 256 bit ifc
                                                                  (total_desc_dw[18:2] + |total_desc_dw[1:0]);  // 4 dw's on 128 bit ifc
                        dw_cnt_write      <= 18'h0;
                     end
                     else begin
                        WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? max_payld_size[7:2] : max_payld_size[7:1];   // 2*(max_payld_size/dw_cnt_in_word);
                        dw_cnt_write      <= total_desc_dw - {max_payld_size[6:0], 1'b0};                      // 2*max_payld_size;
                     end
                  end
               end
               else begin
                  WrDmaRead_o      <= 1'b0;
                  rdmem_sm         <= RD_CONT;
                  dw_cnt_write     <= total_desc_dw;
                  WrDmaAddress_reg <= cur_src_addr_reg;
               end
            end

            else if (desc_fifo_rdreq_reg[1] & !cur_MasterEnable) begin
               rdmem_sm          <= RD_IDLE;
               error_status      <= 1'b1;
               WrDmaRead_o       <= 1'b0;
               dw_cnt_write      <= 18'h0;
               WrDmaBurstCount_o <= 5'h0;
               WrDmaAddress_o    <= 64'h0;
            end
            else begin
               rdmem_sm          <= RD_FIFO_RD;
               WrDmaRead_o       <= 1'b0;
               dw_cnt_write      <= 18'h0;
               WrDmaBurstCount_o <= 5'h0;
               WrDmaAddress_o    <= 64'h0;
            end
         end

         RD_DEASSERT: begin
            if (WrDmaRead_o && ~WrDmaWaitRequest_i) begin
               WrDmaRead_o      <= 1'b0;
               rdmem_sm         <= RD_CONT;
               WrDmaAddress_reg <= WrDmaAddress_o;
            end
            else begin
               WrDmaRead_o      <= 1'b1;
               rdmem_sm         <= RD_DEASSERT;
               WrDmaAddress_reg <= WrDmaAddress_o;
            end
         end

         RD_CONT: begin
            if ((dw_cnt_write != 17'h0) && ~WrDmaRead_o) begin
               rdmem_sm <= RD_CONT;
               if (credit_available >= ((DMA_WIDTH == 256) ? {max_payld_size, 1'b0} :
                                                         {max_payld_size, 1'b0})) begin  // 2*max_payld_size
                  WrDmaAddress_o  <= WrDmaAddress_reg + ((DMA_WIDTH == 256) ? {WrDmaBurstCount_o, 5'b0} :
                                                                              {WrDmaBurstCount_o, 4'b0}); //WrDmaBurstCount_o * byte_cnt_in_word
                  WrDmaRead_o     <= 1'b1;
                  rdmem_sm        <= RD_DEASSERT;
                  if (dw_cnt_write <= max_payld_size) begin
                     WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? (dw_cnt_write[7:3] + |dw_cnt_write[2:0]) :      // 8 dw's on 256 bit ifc
                                                               (dw_cnt_write[7:2] + |dw_cnt_write[1:0]) ;      // 4 dw's on 128 bit ifc
                     dw_cnt_write      <= 17'h0;
                  end
                  else begin
                     WrDmaBurstCount_o <= (DMA_WIDTH == 256) ? max_payld_size[7:3] : max_payld_size[7:2];   //max_payld_size/dw_cnt_in_word;
                     dw_cnt_write      <= dw_cnt_write - max_payld_size;
                  end
               end
               else begin
                  WrDmaRead_o <= 1'b0;
                  rdmem_sm    <= RD_CONT;
               end
            end
            else begin
               WrDmaRead_o <= 1'b0;
               rdmem_sm    <= RD_IDLE;
            end
         end

         default: begin
            rdmem_sm <= RD_IDLE;
         end
      endcase
   end
end

//--------------------------------------------------------
// Credit calculation - Start with entire data FIFO space
// Remove data requested from the AVMM memory
// Add data sent out on the AVST interface
//-------------------------------------------------------
always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      credit_available <= 10'h1FF;
   end
   else begin
      if (credit_available <= 10'h0)
         credit_available <= credit_available;
      else if (WrDmaRead_o & ~WrDmaWaitRequest_i)
         credit_available <= credit_available - WrDmaBurstCount_o;
      else if (update_credit_latched)
         credit_available <= credit_available + data_sent_latched;
   end
end


always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      update_credit_latched <= 1'b0;
      data_sent_latched     <= 8'h0;
   end
   else begin
      if (update_credit_i) begin
         update_credit_latched <= 1'b1;
         data_sent_latched     <= data_sent_i;
      end
      else if (WrDmaRead_o && WrDmaWaitRequest_i) begin
         update_credit_latched <= 1'b0;
         data_sent_latched     <= data_sent_latched;
      end
      else if (~WrDmaRead_o) begin
         update_credit_latched <= 1'b0;
         data_sent_latched     <= data_sent_latched;
      end
   end
end

//========================================================================
// Descriptor Error, set when either of the following conditions are true
// 1. MasterEnable bit is not set for this function in RD_ARB state

 always_ff @ (posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)
      error_status_reg <= 1'b0;
    else if(desc_fifo_rdreq)
      error_status_reg <= 1'b0;
    else
      error_status_reg <= error_status;
 end

assign desc_error_o = ~error_status_reg & error_status;

endmodule

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpcieav_dma_wr_wdalign # (
   parameter dma_use_scfifo                  = 2,
   parameter SRIOV_EN                        = 0,
   parameter ARI_EN                          = 0,
   parameter PHASE1                          = 1,   // Indicate phase1 of SR-IOV
   parameter VF_COUNT                        = 32,  // Total Number of Virtual Functions
   parameter DMA_WIDTH                       = 256,
   parameter DMA_BE_WIDTH                    = 5,
   parameter DMA_BRST_CNT_W                  = 5,
   parameter WRDMA_AVL_ADDR_WIDTH            = 20,
   parameter WRDMA_RXDATA_WIDTH              = (SRIOV_EN == 1) ? 168 : 160,
   parameter RXFIFO_DATA_WIDTH               = (SRIOV_EN == 1) ? 274 : 266,
   parameter TX_FIFO_WIDTH                   = (DMA_WIDTH == 256) ? 260 : 131   //Data+Sop+Eop+Empty
   )
(
   input    logic                     Clk_i,
   input    logic                     Rstn_i,

   // Word Align FIFO interface signals from rdmem block
   input    logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_wdata_i,
   input    logic                     wd_align_fifo_wrreq_i,

   // wd align fifo and send desc fifo back pressure
   output   logic                     wd_align_fifo_full_o,
   input    logic                     send_desc_fifo_full_i,
   input    logic                     send_data_fifo_full_i,

   // Word Align FIFO interface signals from rdmem block
   output   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_wdata_o,
   output   logic                     send_desc_fifo_wrreq_o,
   output   logic                     data_fifo_rdreq_o,
   input    logic                     data_fifo_empty_i,

   // Read data from memory to be aligned and written into data fifo
   input    logic[DMA_WIDTH-1:0]      data_fifo_data_i,

   // Word Align FIFO interface signals to send desc/data block
   output   logic[DMA_WIDTH-1:0]      send_data_fifo_wdata_o,
   output   logic                     send_data_fifo_wrreq_o,
   output   logic[17:0]               send_data_fifo_wrcnt_o
);

   localparam   ALLOW_ANY_FILE_SIZE = 1;
   localparam   FILE_SIZE_WIDTH     = 18;

   localparam   WD_ALIGN_IDLE       = 3'h0;
   localparam   WD_ALIGN_FIFO_RD    = 3'h1;
   localparam   WD_ALIGN_RD_VALID   = 3'h2;
   localparam   WD_ALIGN_WR         = 3'h3;
   localparam   WD_ALIGN_RD_DESC    = 3'h4;

   localparam   RD_FIFO_IDLE        = 3'h0;
   localparam   RD_FIFO_RD          = 3'h1;

   localparam  ZEROS           = 512'h0;

   logic        wd_align_fifo_rdreq;
   logic[1:0]   wd_align_fifo_rdreq_reg;
   logic        wd_align_fifo_wrreq;
   logic        wd_align_fifo_rst;
   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_rdata;
   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_rdata_int;
   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_rdata_reg;
   logic[WRDMA_RXDATA_WIDTH-1:0] wd_align_fifo_wdata;
   logic[4:0]   wd_align_fifo_count;
   logic        wd_align_fifo_empty;

   logic[63:0]  cur_dest_addr_reg;
   logic[63:0]  cur_src_addr;
   logic[63:0]  cur_src_addr_reg;
   logic[17:0]  cur_dma_dw_count;
   logic[17:0]  cur_dma_dw_count_reg;
   logic[7:0]   cur_desc_id;
   logic[7:0]   cur_desc_id_reg;
   logic[7:0]   cur_req_func;

   logic[DMA_WIDTH-1:0] WrDmaReadData_reg;
   logic[DMA_WIDTH-1:0] WrDmaReadData_reg1;
   logic[DMA_WIDTH-1:0] WrDmaReadData_reg2;
   logic[2:0]   WrDmaReadDataValid_reg;
   logic[DMA_WIDTH-1:0] send_data_fifo_wdata;
   logic[DMA_WIDTH-1:0] send_data_fifo_wdata_reg;
   logic        send_data_fifo_wrreq;
   logic        send_data_fifo_wrreq_reg;
   logic[17:0]  send_data_fifo_wrcnt_reg;

   logic[17:0]  data_fifo_wrcnt;
   logic[17:0]  data_fifo_rdcnt;
   logic[17:0]  data_fifo_total_rdcnt_reg;
   logic        data_fifo_rdreq_reg;

   logic[7:0]   max_payld_size;

   logic[FILE_SIZE_WIDTH:0] total_rdcnt;
   logic[FILE_SIZE_WIDTH:0] total_wrcnt;
   logic[FILE_SIZE_WIDTH:0] total_wrcnt_reg;
   logic[FILE_SIZE_WIDTH:0] total_dw_rdcnt;
   logic[FILE_SIZE_WIDTH:0] total_rdcnt_reg;
   logic[FILE_SIZE_WIDTH:0] total_raw_rdcnt;
   logic[FILE_SIZE_WIDTH:0] total_raw_dw_rdcnt;
   logic[2:0]   wd_align_sm;
   logic[1:0]   rdfifo_sm;

   logic[3:0]   dw_cnt_in_word;


generate begin : g_wrfifo
   if (dma_use_scfifo>0) begin
      reg [2:0] Rst_i_sync;
      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
         if(~Rstn_i) begin
            Rst_i_sync <= 3'h7;
         end
         else begin
            Rst_i_sync[2] <= Rst_i_sync[1];
            Rst_i_sync[1] <= Rst_i_sync[0];
            Rst_i_sync[0] <= 1'b0;
         end
      end

      if (dma_use_scfifo==1) begin
         altpcie_scfifo_a10      # (
             .WIDTH            (160), //(WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
             .NUM_FIFO32       (1)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  wd_align_fifo    (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (wd_align_fifo_wdata_i),
               .wreq           (wd_align_fifo_wrreq_i),
               .full           (wd_align_fifo_full_o),
               .rdata          (wd_align_fifo_rdata),
               .rreq           (wd_align_fifo_rdreq),
               .empty          (wd_align_fifo_empty),
               .used           (wd_align_fifo_count)
         );

      end
      else if (dma_use_scfifo==2) begin
         altpcie_scfifo      # (
             .WIDTH            (160), //(WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
             .NUM_FIFO32       (1)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  wd_align_fifo    (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (wd_align_fifo_wdata_i),
               .wreq           (wd_align_fifo_wrreq_i),
               .full           (wd_align_fifo_full_o),
               .rdata          (wd_align_fifo_rdata),
               .rreq           (wd_align_fifo_rdreq),
               .empty          (wd_align_fifo_empty),
               .used           (wd_align_fifo_count)
         );

      end
   end
   else begin
      altpcie_fifo      # (
         .FIFO_DEPTH(32),
         .DATA_WIDTH(WRDMA_RXDATA_WIDTH)
         )  wd_align_fifo    (
            .clk          (Clk_i),
            .rstn         (Rstn_i),
            .srst         (1'b0),
            .wrreq        (wd_align_fifo_wrreq_i),
            .rdreq        (wd_align_fifo_rdreq),
            .data         (wd_align_fifo_wdata_i),
            .q            (wd_align_fifo_rdata_int),
            .fifo_count   (wd_align_fifo_count)
         );
      assign wd_align_fifo_empty  = (wd_align_fifo_count == 0);
      assign wd_align_fifo_full_o = (wd_align_fifo_count == 5'h1F);
      always_ff @ (posedge Clk_i) begin
         if (wd_align_fifo_rdreq)
            wd_align_fifo_rdata <= wd_align_fifo_rdata_int;
      end
   end
end
endgenerate

//-------------------------------------------------
// Align the data to dw address before writing to the FIFO
//-------------------------------------------------


always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      rdfifo_sm <= RD_FIFO_IDLE;
      data_fifo_rdcnt <= 18'h0;
      data_fifo_total_rdcnt_reg <= 18'h0;
   end
   else begin
      case (rdfifo_sm)
      RD_FIFO_IDLE: begin
         if ((!(|WrDmaReadDataValid_reg || data_fifo_rdreq_reg) && (cur_desc_id_reg != cur_desc_id)) ||
            wd_align_fifo_rdreq_reg[1]) begin
            rdfifo_sm <= RD_FIFO_RD;
            data_fifo_rdcnt <= 18'h1;
            data_fifo_total_rdcnt_reg <= total_rdcnt;
         end
         else begin
            rdfifo_sm <= RD_FIFO_IDLE;
            data_fifo_rdcnt <= 18'h0;
            data_fifo_total_rdcnt_reg <= data_fifo_total_rdcnt_reg;
         end
      end
      RD_FIFO_RD: begin
         if (~data_fifo_empty_i && ~send_data_fifo_full_i) begin
            if (data_fifo_rdcnt == data_fifo_total_rdcnt_reg) begin
               if (((data_fifo_total_rdcnt_reg > 18'h3) && (cur_desc_id_reg != cur_desc_id) &&
                  (total_rdcnt > 19'h3)) || wd_align_fifo_rdreq_reg[1]) begin
                  rdfifo_sm <= RD_FIFO_RD;
                  data_fifo_rdcnt <= 18'h1;
                  data_fifo_total_rdcnt_reg <= total_rdcnt;
               end
               else begin
                  rdfifo_sm <= RD_FIFO_IDLE;
                  data_fifo_rdcnt <= 18'h0;
                  data_fifo_total_rdcnt_reg <= data_fifo_total_rdcnt_reg;
               end
            end
            else begin
               data_fifo_rdcnt <= data_fifo_rdcnt + 1;
               rdfifo_sm <= RD_FIFO_RD;
               data_fifo_total_rdcnt_reg <= data_fifo_total_rdcnt_reg;
            end
         end
         else begin
            data_fifo_rdcnt <= data_fifo_rdcnt;
            rdfifo_sm <= RD_FIFO_RD;
            data_fifo_total_rdcnt_reg <= data_fifo_total_rdcnt_reg;
         end
      end
      default: begin
        rdfifo_sm <= RD_FIFO_IDLE;
      end
      endcase
   end
end



/// current descriptor
always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      cur_dest_addr_reg       <= 64'h0;
      cur_src_addr_reg        <= 64'h0;
      cur_dma_dw_count_reg    <= 18'h0;
      cur_desc_id_reg         <= 8'h0;
      cur_req_func            <= 8'h0;
      wd_align_fifo_rdata_reg <= 168'h0;
   end
   else if(wd_align_fifo_rdreq_reg[0]) begin
      cur_dest_addr_reg       <= wd_align_fifo_rdata[127:64];
      cur_src_addr_reg        <= wd_align_fifo_rdata[63:0];
      cur_dma_dw_count_reg    <= wd_align_fifo_rdata[145:128];
      cur_desc_id_reg         <= wd_align_fifo_rdata[153:146];
      cur_req_func            <= (SRIOV_EN == 1) ? wd_align_fifo_rdata[167:160] : 8'h0;
      wd_align_fifo_rdata_reg <= wd_align_fifo_rdata;
   end
end

assign send_data_fifo_wrreq = ((wd_align_sm == WD_ALIGN_WR) && (data_fifo_wrcnt != 5'h0) && (WrDmaReadDataValid_reg[0] ||
                               (WrDmaReadDataValid_reg[1] && (total_wrcnt == data_fifo_wrcnt)) &&
                              (data_fifo_wrcnt == total_rdcnt_reg)));

assign total_dw_rdcnt = (cur_dma_dw_count_reg + ((DMA_WIDTH == 256) ? cur_src_addr_reg[4:2] : cur_src_addr_reg[3:2]));
assign total_rdcnt    = (DMA_WIDTH == 256) ? ({3'h0,total_dw_rdcnt[FILE_SIZE_WIDTH:3]} + {ZEROS[FILE_SIZE_WIDTH:1], |total_dw_rdcnt[2:0]}) :
                                             ({2'h0,total_dw_rdcnt[FILE_SIZE_WIDTH:2]} + {ZEROS[FILE_SIZE_WIDTH:1], |total_dw_rdcnt[1:0]});

assign total_raw_dw_rdcnt = (wd_align_fifo_rdata[145:128] + ((DMA_WIDTH == 256) ? wd_align_fifo_rdata[4:2] : wd_align_fifo_rdata[3:2]));
assign total_raw_rdcnt    = (DMA_WIDTH == 256) ? ({3'h0,total_raw_dw_rdcnt[FILE_SIZE_WIDTH:3]} + {ZEROS[FILE_SIZE_WIDTH:1], |total_raw_dw_rdcnt[2:0]}) :
                                                 ({2'h0,total_raw_dw_rdcnt[FILE_SIZE_WIDTH:2]} + {ZEROS[FILE_SIZE_WIDTH:1], |total_raw_dw_rdcnt[1:0]});

assign total_wrcnt = (DMA_WIDTH == 256) ? ({4'h0,cur_dma_dw_count[FILE_SIZE_WIDTH-1:3]} + {ZEROS[FILE_SIZE_WIDTH:1], |cur_dma_dw_count[2:0]}) :
                                          ({3'h0,cur_dma_dw_count[FILE_SIZE_WIDTH-1:2]} + {ZEROS[FILE_SIZE_WIDTH:1], |cur_dma_dw_count[1:0]});

assign total_wrcnt_reg = (DMA_WIDTH == 256) ? ({4'h0,cur_dma_dw_count_reg[FILE_SIZE_WIDTH-1:3]} + {ZEROS[FILE_SIZE_WIDTH:1], |cur_dma_dw_count_reg[2:0]}) :
                                              ({3'h0,cur_dma_dw_count_reg[FILE_SIZE_WIDTH-1:2]} + {ZEROS[FILE_SIZE_WIDTH:1], |cur_dma_dw_count_reg[1:0]});


always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      WrDmaReadData_reg      <= 256'h0;
      WrDmaReadDataValid_reg <= 3'b0;
   end
   else begin
      WrDmaReadData_reg      <= data_fifo_data_i;
      WrDmaReadDataValid_reg <= {WrDmaReadDataValid_reg[1], WrDmaReadDataValid_reg[0], data_fifo_rdreq_reg};
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i)
      WrDmaReadData_reg1 <= 256'h0;
   else if (WrDmaReadDataValid_reg[0])
      WrDmaReadData_reg1 <= WrDmaReadData_reg;
end

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i)
      WrDmaReadData_reg2 <= 256'h0;
   else if (WrDmaReadDataValid_reg[1])
      WrDmaReadData_reg2 <= WrDmaReadData_reg1;
end


always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      total_rdcnt_reg         <= 18'h0;
      cur_dma_dw_count        <= 18'h0;
      cur_src_addr            <= 64'h0;
      cur_desc_id             <= 8'h0;
      wd_align_sm             <= WD_ALIGN_IDLE;
      data_fifo_wrcnt         <= 5'h0;
      wd_align_fifo_rdreq     <= 1'b0;
      wd_align_fifo_rdreq_reg <= 2'b00;
   end
   else begin
      wd_align_fifo_rdreq_reg <= {wd_align_fifo_rdreq_reg[0], wd_align_fifo_rdreq};
      case (wd_align_sm)
      WD_ALIGN_IDLE: begin
         if(~wd_align_fifo_empty && ~send_desc_fifo_full_i) begin
            total_rdcnt_reg     <= 18'h0;
            cur_dma_dw_count    <= 18'h0;
            cur_src_addr        <= 64'h0;
            cur_desc_id         <= cur_desc_id;
            data_fifo_wrcnt     <= 5'h0;
            wd_align_fifo_rdreq <= 1'b1;
            wd_align_sm         <= WD_ALIGN_FIFO_RD;
         end
         else begin
            total_rdcnt_reg     <= 18'h0;
            cur_dma_dw_count    <= 18'h0;
            cur_src_addr        <= 64'h0;
            cur_desc_id         <= cur_desc_id;
            data_fifo_wrcnt     <= 5'h0;
            wd_align_fifo_rdreq <= 1'b0;
            wd_align_sm         <= WD_ALIGN_IDLE;
         end
      end

      WD_ALIGN_FIFO_RD: begin
         wd_align_fifo_rdreq <= 1'b0;
         if (~wd_align_fifo_rdreq && WrDmaReadDataValid_reg[0]) begin
            total_rdcnt_reg  <= total_rdcnt;
            cur_dma_dw_count <= cur_dma_dw_count_reg;
            cur_src_addr     <= cur_src_addr_reg;
            cur_desc_id      <= cur_desc_id_reg;
            wd_align_sm      <= WD_ALIGN_WR;
            data_fifo_wrcnt  <= 18'h1;

            // Anticipating a small back to back descriptor
            if((((DMA_WIDTH == 256) ? (cur_dma_dw_count_reg[FILE_SIZE_WIDTH-1:3] + |cur_dma_dw_count_reg[2:0]) :
                (cur_dma_dw_count_reg[FILE_SIZE_WIDTH-1:2] + |cur_dma_dw_count_reg[1:0]))  <= 3) &&
                ~wd_align_fifo_empty && ~send_desc_fifo_full_i)
               wd_align_fifo_rdreq <= 1'b1;
            else
               wd_align_fifo_rdreq <= 1'b0;
         end
         else begin
            wd_align_sm <= WD_ALIGN_FIFO_RD;
         end
      end
      WD_ALIGN_WR: begin
         // Pre reading the desc just in case there is data from back to back desc
         // If the next desc is already available
           if (((total_wrcnt - data_fifo_wrcnt) <= 3) && (data_fifo_wrcnt != 0) &&
                ~wd_align_fifo_empty && ~send_desc_fifo_full_i && ~wd_align_fifo_rdreq && ~(|wd_align_fifo_rdreq_reg) &&
                (cur_desc_id_reg == cur_desc_id)) begin
            if ((total_wrcnt == data_fifo_wrcnt) && send_data_fifo_wrreq) begin
               total_rdcnt_reg     <= 18'h0;
               cur_dma_dw_count    <= cur_dma_dw_count;
               cur_src_addr        <= cur_src_addr;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= 5'h0;
               wd_align_sm         <= WD_ALIGN_FIFO_RD;
               wd_align_fifo_rdreq <= 1'b1;
            end

            else if (WrDmaReadDataValid_reg[0]) begin
               total_rdcnt_reg     <= total_rdcnt_reg;
               cur_dma_dw_count    <= cur_dma_dw_count;
               cur_src_addr        <= cur_src_addr;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= data_fifo_wrcnt + 18'h1;
               wd_align_sm         <= WD_ALIGN_WR;
               wd_align_fifo_rdreq <= 1'b1;
            end
            else begin
               total_rdcnt_reg     <= total_rdcnt_reg;
               cur_dma_dw_count    <= cur_dma_dw_count;
               cur_src_addr        <= cur_src_addr;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= data_fifo_wrcnt;
               wd_align_sm         <= WD_ALIGN_WR;
               wd_align_fifo_rdreq <= 1'b1;
            end
         end

         // When the last data has not come yet i.e. the valid deasserts
         // Don't exit this state till all data is available
         else if ((!WrDmaReadDataValid_reg[0]) && (data_fifo_wrcnt != total_rdcnt_reg)) begin
            wd_align_sm         <=  WD_ALIGN_WR;
            wd_align_fifo_rdreq <= 1'b0;
         end

         // When all the data from the current desc has arrived
         else if ((total_wrcnt == data_fifo_wrcnt) && send_data_fifo_wrreq) begin

            //Data from the next descriptor has not been completely read out
            if (((total_wrcnt <= 2) && (cur_desc_id == cur_desc_id_reg)) || wd_align_fifo_rdreq ||
                (wd_align_fifo_rdreq_reg[0])) begin
               total_rdcnt_reg     <= 18'h0;
               cur_dma_dw_count    <= cur_dma_dw_count;
               cur_src_addr        <= cur_src_addr;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= 5'h0;
               wd_align_fifo_rdreq <= 1'b0;
               wd_align_sm         <= WD_ALIGN_RD_DESC;
            end
            // Next descriptor was aready read
            else if ((cur_desc_id != cur_desc_id_reg) || (wd_align_fifo_rdreq_reg[1])) begin
               //Data from the next descriptor has already arrived
               if (data_fifo_rdcnt > 18'h1) begin
                  total_rdcnt_reg     <= total_rdcnt;
                  cur_dma_dw_count    <= cur_dma_dw_count_reg;
                  cur_src_addr        <= cur_src_addr_reg;
                  cur_desc_id         <= cur_desc_id_reg;
                  wd_align_sm         <= WD_ALIGN_WR;
                  wd_align_fifo_rdreq <= 1'b0;
                  // All of the data for a complete word is aready available
                  if ((total_rdcnt_reg == data_fifo_wrcnt) &&
                     ((DMA_WIDTH == 256) ?(((|cur_src_addr_reg[4:2] == 1'b0) && WrDmaReadDataValid_reg[1]) ||
                                           ((|cur_src_addr_reg[4:2] == 1'b1) && &WrDmaReadDataValid_reg[1:0])) :
                                          (((|cur_src_addr_reg[3:2] == 1'b0) && WrDmaReadDataValid_reg[1]) ||
                                           ((|cur_src_addr_reg[3:2] == 1'b1) && &WrDmaReadDataValid_reg[1:0]))))
                     data_fifo_wrcnt <= 18'h1;
                  else
                     data_fifo_wrcnt <= 18'h0;
               end

               //Wait for the data from the next descriptor
               else begin
                  total_rdcnt_reg     <= 18'h0;
                  cur_dma_dw_count    <= 18'h0;
                  cur_src_addr        <= 64'h0;
                  cur_desc_id         <= cur_desc_id;
                  data_fifo_wrcnt     <= 5'h0;
                  wd_align_fifo_rdreq <= 1'b0;
                  wd_align_sm         <= WD_ALIGN_FIFO_RD;
               end
            end
            else begin
               total_rdcnt_reg     <= 18'h0;
               cur_dma_dw_count    <= 18'h0;
               cur_src_addr        <= 64'h0;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= 5'h0;
               wd_align_fifo_rdreq <= 1'b0;
               wd_align_sm         <= WD_ALIGN_IDLE;
            end
         end

         else begin
            wd_align_sm <=  WD_ALIGN_WR;
            wd_align_fifo_rdreq <= 1'b0;
            if (WrDmaReadDataValid_reg[0])
               data_fifo_wrcnt <= data_fifo_wrcnt + 18'h1;
            else
               data_fifo_wrcnt <= data_fifo_wrcnt;
         end
      end

      WD_ALIGN_RD_DESC: begin
         // Desc was not read ahead, go back to idle
         if (cur_desc_id == wd_align_fifo_rdata[153:146]) begin
            total_rdcnt_reg     <= 18'h0;
            cur_dma_dw_count    <= 18'h0;
            cur_src_addr        <= 64'h0;
            cur_desc_id         <= cur_desc_id;
            data_fifo_wrcnt     <= 5'h0;
            wd_align_fifo_rdreq <= 1'b0;
            wd_align_sm         <= WD_ALIGN_IDLE;
         end
         else if (|wd_align_fifo_rdreq_reg) begin
            if (WrDmaReadDataValid_reg[0]) begin
               cur_src_addr        <= wd_align_fifo_rdata[63:0];
               cur_dma_dw_count    <= wd_align_fifo_rdata[145:128];
               cur_desc_id         <= wd_align_fifo_rdata[153:146];
               total_rdcnt_reg     <= total_raw_rdcnt;
               wd_align_sm         <= WD_ALIGN_WR;
               wd_align_fifo_rdreq <= 1'b0;
               data_fifo_wrcnt     <= 18'h1;
            end
            else begin
               total_rdcnt_reg     <= 18'h0;
               cur_dma_dw_count    <= 18'h0;
               cur_src_addr        <= 64'h0;
               cur_desc_id         <= cur_desc_id;
               data_fifo_wrcnt     <= 5'h0;
               wd_align_fifo_rdreq <= 1'b0;
               wd_align_sm         <= WD_ALIGN_FIFO_RD;
            end
         end
         else begin
            total_rdcnt_reg     <= total_rdcnt;
            cur_dma_dw_count    <= cur_dma_dw_count_reg;
            cur_src_addr        <= cur_src_addr_reg;
            cur_desc_id         <= cur_desc_id_reg;
            wd_align_sm         <= WD_ALIGN_WR;
            wd_align_fifo_rdreq <= 1'b0;
            data_fifo_wrcnt     <= 5'h1;
         end
      end
      default : begin
         wd_align_sm <= WD_ALIGN_IDLE;
      end
      endcase
   end
end

generate if (DMA_WIDTH == 256) begin
   always @ (*) begin
      case (cur_src_addr[4:0])
         5'h00: send_data_fifo_wdata = WrDmaReadData_reg1;
         5'h04: send_data_fifo_wdata = {WrDmaReadData_reg[31:0], WrDmaReadData_reg1[DMA_WIDTH-1:32]};
         5'h08: send_data_fifo_wdata = {WrDmaReadData_reg[63:0], WrDmaReadData_reg1[DMA_WIDTH-1:64]};
         5'h0C: send_data_fifo_wdata = {WrDmaReadData_reg[95:0], WrDmaReadData_reg1[DMA_WIDTH-1:96]};
         5'h10: send_data_fifo_wdata = {WrDmaReadData_reg[127:0], WrDmaReadData_reg1[255:128]};
         5'h14: send_data_fifo_wdata = {WrDmaReadData_reg[159:0], WrDmaReadData_reg1[255:160]};
         5'h18: send_data_fifo_wdata = {WrDmaReadData_reg[191:0], WrDmaReadData_reg1[255:192]};
         5'h1C: send_data_fifo_wdata = {WrDmaReadData_reg[223:0], WrDmaReadData_reg1[255:224]};
         default: send_data_fifo_wdata = WrDmaReadData_reg1;
      endcase
   end
end
else begin
   always @ (*) begin
      case (cur_src_addr[3:0])
         4'h00: send_data_fifo_wdata = WrDmaReadData_reg1;
         4'h04: send_data_fifo_wdata = {WrDmaReadData_reg[31:0], WrDmaReadData_reg1[DMA_WIDTH-1:32]};
         4'h08: send_data_fifo_wdata = {WrDmaReadData_reg[63:0], WrDmaReadData_reg1[DMA_WIDTH-1:64]};
         4'h0C: send_data_fifo_wdata = {WrDmaReadData_reg[95:0], WrDmaReadData_reg1[DMA_WIDTH-1:96]};
         default: send_data_fifo_wdata = WrDmaReadData_reg1;
      endcase
   end
end
endgenerate

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      send_data_fifo_wdata_reg <= 256'h0;
      send_data_fifo_wrreq_reg <= 1'b0;
      send_data_fifo_wrcnt_reg <= 18'h0;
      data_fifo_rdreq_reg      <= 1'b0;
   end
   else begin
      send_data_fifo_wdata_reg <= send_data_fifo_wdata;
      send_data_fifo_wrreq_reg <= send_data_fifo_wrreq;
      data_fifo_rdreq_reg      <= data_fifo_rdreq_o;
      if (send_data_fifo_wrreq)
         send_data_fifo_wrcnt_reg <= data_fifo_wrcnt;
      else
         send_data_fifo_wrcnt_reg <= send_data_fifo_wrcnt_reg;
   end
end

//Generate signals to write the data to the send data fifo
assign send_data_fifo_wdata_o = send_data_fifo_wdata_reg;
assign send_data_fifo_wrreq_o = send_data_fifo_wrreq_reg;
assign send_data_fifo_wrcnt_o = send_data_fifo_wrcnt_reg;

// Generate the signals to capture the descriptor in the send desc fifo
// Used by the send data state machines to retrive desc info
assign send_desc_fifo_wdata_o = wd_align_fifo_rdata_reg;
assign send_desc_fifo_wrreq_o = wd_align_fifo_rdreq_reg[1];

// Generate signals to read data from the main data fifo
assign data_fifo_rdreq_o = ~data_fifo_empty_i && ~send_data_fifo_full_i && (rdfifo_sm == RD_FIFO_RD);


endmodule



// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpcieav_dma_wr_tlpgen # (
   parameter dma_use_scfifo                  = 2,
   parameter SRIOV_EN                        = 0,
   parameter ARI_EN                          = 0,
   parameter PHASE1                          = 1,   // Indicate phase1 of SR-IOV
   parameter VF_COUNT                        = 32,  // Total Number of Virtual Functions
   parameter DMA_WIDTH                       = 256,
   parameter DMA_BE_WIDTH                    = 5,
   parameter DMA_BRST_CNT_W                  = 5,
   parameter WRDMA_AVL_ADDR_WIDTH            = 20,
   parameter WRDMA_RXDATA_WIDTH              = (SRIOV_EN == 1) ? 168 : 160,
   parameter RXFIFO_DATA_WIDTH               = (SRIOV_EN == 1) ? 274 : 266,
   parameter TX_FIFO_WIDTH                   = (DMA_WIDTH == 256) ? 260 : 131   //Data+Sop+Eop+Empty
   )
   (
   input    logic                     Clk_i,
   input    logic                     Rstn_i,

   // Word Align FIFO interface signals from rdmem block
   input   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_wdata_i,
   input   logic                      send_desc_fifo_wrreq_i,

   // For desc fifo back preassure
   output  logic                      send_desc_fifo_full_o,
   output  logic[4:0]                 send_desc_fifo_count_o,

   // Word Align FIFO interface signals from rdmem block
   input   logic[DMA_WIDTH-1:0]       send_data_fifo_wdata_i,
   input   logic                      send_data_fifo_wrreq_i,
   output  logic                      send_data_fifo_full_o,

   // Status of desc
   output   logic[7:0]                cur_req_func_o,
   output   logic                     avst_file_end_o,
   output   logic[7:0]                avst_file_num_o,
   output                             wr_idle_state_o,

   // Tx fifo Interface
   output   logic                     TxFifoWrReq_o,
   output   logic[TX_FIFO_WIDTH-1:0]  TxFifoData_o,
   input    logic[3:0]                TxFifoCount_i,

   // Arbiter Interface
   output   logic                     WrDmaLPArbReq_o,
   output   logic                     WrDmaHPArbReq_o,
   input    logic                     WrDmaLPArbReq_i,
   input    logic                     WrDmaHPArbReq_i,
   input    logic                     WrDmaArbGranted_i,

   // Signals for credit calculation
   output    logic                    update_credit_o,
   output    logic[7:0]               data_sent_o,

   input    logic[15:0]               BusDev_i,
   input    logic[31:0]               DevCsr_i,
   input    logic                     MasterEnable,
   input    logic[VF_COUNT-1:0]       vf_MasterEnable_i  // SR-IOV VF Master Enable
   );

   localparam ALLOW_ANY_FILE_SIZE = 1;
   localparam AVST_ADDR_ALIGN     = 1;

   localparam AVST_EMPTY_WIDTH = (DMA_WIDTH == 256) ? 2 : 1;
   localparam DATA_FIFO_WIDTH  = (DMA_WIDTH == 256) ? 260 : 140;

   localparam  WR_IDLE     = 6'h00;
   localparam  WR_RD_DESC  = 6'h01;
   localparam  WR_DATA_RCV = 6'h02;
   localparam  WR_DATA_RD  = 6'h03;
   localparam  WR_SEND     = 6'h04;
   localparam  WR_ARB_RDY  = 6'h05;

   localparam  START_FILE        = 3'h0;
   localparam  CONT_FILE         = 3'h1;
   localparam  WAIT_LASTPKT_PROC = 3'h2;
   localparam  FILE_SIZE_WIDTH   = 18;

   // tlp_gen_sm states
   localparam  INIT       = 3'h0;
   localparam  START_DATA = 3'h1;
   localparam  CONT_DATA  = 3'h2;
   localparam  LAST_DATA  = 3'h3;

   // avst_sm states
   localparam   AVST_START_STATE         = 3'h0;
   localparam   AVST_DATA_STATE          = 3'h1;
   localparam   AVST128_DATA_STATE       = 3'h2;
   localparam   AVST_EXTRA_DATA_STATE    = 3'h3;
   localparam   AVST128_EXTRA_DATA_STATE = 3'h4;

   logic        send_desc_fifo_rdreq;
   logic        send_desc_fifo_rdreq_reg;
   logic        send_desc_fifo_wrreq;
   logic        send_desc_fifo_rst;
   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_rdata;
   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_rdata_int;
   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_rdata_reg;
   logic[WRDMA_RXDATA_WIDTH-1:0] send_desc_fifo_wdata;
   logic        send_desc_fifo_empty;

   logic[63:0]  cur_dest_addr_reg;
   logic[63:0]  cur_src_addr_reg;
   logic[17:0]  cur_dma_dw_count_reg;
   logic[7:0]   cur_desc_id_reg;

   logic[5:0]   wrdma_sm;

   logic        data_fifo_empty;
   logic[8:0]   send_data_fifo_count;
   logic[8:0]   send_data_fifo_count_int;
   logic[8:0]   data_fifo_count;
   logic[DMA_WIDTH-1:0] data_fifo_data;
   logic[DMA_WIDTH-1:0] send_data_fifo_wdata;
   logic[DMA_WIDTH-1:0] send_data_fifo_wdata_reg;
   logic[DMA_WIDTH-1:0] data_fifo_data_r;
   logic        send_data_fifo_empty;
   logic        send_data_fifo_wrreq;
   logic        send_data_fifo_wrreq_reg;
   logic        send_data_fifo_rdreq;
   logic        send_data_fifo_rdreq_r;
   logic        send_data_fifo_full;

   logic[7:0]   max_payld_size;

   logic        hdr_valid;       // means there is a pkt available
   logic        hdr_valid_r;
   logic        hdr_valid_rr;
   logic        hdr_valid_wdata;
   logic        hdr_valid_wdata_reg;
   logic[63:0]  hdr_address;     // pcie target address
   logic[10:0]  hdr_size;        // pcie payload size
   logic[7:0]   hdr_file_num;    // file # being transferred
   logic        hdr_file_end;    // means this tlp is the last for the file
   logic        hdr_advance;
   logic[2:0]   hdr_gen_sm;      // controls break up of file into multiple TLPs
   logic[63:0]  curr_addr;       // start address of current TLP

   logic[FILE_SIZE_WIDTH-1:0] file_size_remain; // number of DWs remaining to be transferred
   logic[7:0]   max_payld_size_reg;            // input pipe reg for fmax
   logic[63:0]  curr_addr_plus_maxpload;
   logic[63:0]  file_addr_plus_maxpload;
   logic[63:0]  curr_addr_plus_filesizerem;
   logic[63:0]  file_addr_plus_filesize;
   logic[FILE_SIZE_WIDTH-1:0] file_size;
   logic[FILE_SIZE_WIDTH-1:0] file_size_reg;
   logic[63:0]  file_addr;
   logic[7:0]   file_num;

   logic        tlp_start;
   logic        tlp_start_r;
   logic[127:0] tlp_desc;
   logic[7:0]   tlp_end;
   logic[7:0]   tlp_end_r;
   logic[7:0]   tlp_file_num;

   logic        tlp_advance;
   logic        tlp_val;             // issues a TLP cycle - rcvr must accept
   logic        tlp_val_r;             // issues a TLP cycle - rcvr must accept
   logic        tlp_read;            // read TLP data from fifo
   logic[DMA_WIDTH-1:0] tlp_data;
   logic        tlp_file_end;
   logic[9:0]   hdr_size_remain;     // number of payload DW remaining to be transferred including this cycle
   logic[1:0]   tlp_gen_sm;          // state machine keeps track of start and end of packet transfer cycles

   logic[7:0]   tlp_byte_ena;        // PciE byte enable field
   logic        tlp_4dw_hdr;         // PciE address requires 4DW header
   logic        tlp_3dw_hdr;         // PciE address requires 4DW header
   logic[7:0]   fmt_type;            // PciE format/type field
   logic        hdr_file_end_hold;

   logic[9:0]   tlp_length_n;

   logic        file_valid;
   logic        arb_ready;

   logic[DMA_WIDTH-1:0] avst_data;      // AVST TX interface:  256bits, 1 beat per cycle (1 TLP per cycle)
   logic        avst_valid;
   logic        avst_sop;
   logic        avst_eop;
   logic[AVST_EMPTY_WIDTH-1:0] avst_empty;
   logic        avst_file_end;
   logic        avst_file_end_size;
   logic[7:0]   avst_file_num;
   logic        avst_ready;

   logic[DMA_WIDTH-1:0] tlp_data_hold;       // hold value from last cycle
   logic[7:0]   tlp_end_hold;        // hold value from last cycle
   logic        tlp_file_end_hold;

   logic[2:0]   avst_sm;             // AVST State machine

   logic        tlp_4dw_hdr_av;      // tlp header is 4DW
   logic        tlp_3dw_hdr_av;      // tlp header is 3DW
   logic        tlp_odd_dwaddr;      // tlp address is an odd DW (- not QW aligned)
   logic        tlp_odd_dwaddr_av;   // tlp address is an odd DW (- not QW aligned)
   logic[DMA_WIDTH-1:0] tlp_data_shifted;  // shifted version of TLP payload (current data + deferred data)
   logic[7:0]   tlp_end_shifted_n;   // shifted version of the TLP end vector (which indicates the last DW of the TLP payload)
   logic[2:0]   payld_shift_n;       // # of DWs of payload shifted in with desc phase
   logic[2:0]   payld_shift;
   logic[2:0]   hdr_partial_word_sel;
   logic[2:0]   hdr_partial_word_en;
   logic[2:0]   avst_partial_word_en;
   logic[10:0]  hdr_size_total_dw;
   logic[10:0]  hdr_size_total;

   logic[3:0]   dw_cnt_in_word;

   logic [8:0] total_credit;
   logic credit_error;
   logic [17:0] total_dw_wrcnt;
   logic [17:0] total_wrcnt;
   logic [17:0] total_rdcnt;
   logic [17:0] send_data_fifo_rdcnt;

   // SRIOV signals
   logic[7:0]   cur_req_func;
   logic[15:0]  requestor_id;  // Requestor ID = {Bus[7:0], Dev[4:0], Func[2:0]}

always_comb
begin
   case(DevCsr_i[7:5])
      3'b000  : max_payld_size = 8'h20;  //128b
      3'b001  : max_payld_size = 8'h40;  //256b
      3'b010  : max_payld_size = 8'h80;  //512b
      default : max_payld_size = 8'h80;  //512b
   endcase
end

// TLP data out to the HIP interface
assign TxFifoWrReq_o   = avst_valid;
assign TxFifoData_o    = {avst_empty, avst_eop, avst_sop, avst_data};


// Data FIFO signals
assign send_data_fifo_rdreq = tlp_read && !send_data_fifo_empty;

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      data_fifo_count <= 9'h0;
   end
   else begin
      if (send_data_fifo_wrreq_i & ~send_data_fifo_rdreq)
         data_fifo_count <= data_fifo_count + 1;
      else if (~send_data_fifo_wrreq_i & send_data_fifo_rdreq)
         data_fifo_count <= data_fifo_count - 1;
   end
end

assign send_data_fifo_count = ((send_data_fifo_count_int == 9'h1F) || (send_data_fifo_count_int > data_fifo_count)) ? data_fifo_count : send_data_fifo_count_int;

assign data_fifo_empty = (data_fifo_count == 9'h0) ? 1'b1 : 1'b0;

// Desc status signals
assign cur_req_func_o  = cur_req_func;
assign avst_file_end_o = avst_file_end;
assign avst_file_num_o = avst_file_num;
assign wr_idle_state_o = ((wrdma_sm == WR_IDLE) && (hdr_gen_sm == START_FILE))  || avst_file_end;

// Credit calculation signals
assign update_credit_o = avst_sop || avst_file_end_size;

assign avst_file_end_size = (avst_file_end && ((DMA_WIDTH == 256) ?
        // When one more word has been requested from memory due to addr alignment and partial word request
       ((cur_dma_dw_count_reg[2:0] == 3'h0) ? (cur_src_addr_reg[4:2] != 3'h0) : (cur_src_addr_reg[4:2] + cur_dma_dw_count_reg[2:0] > 8)) :
       ((cur_dma_dw_count_reg[1:0] == 2'h0) ? (cur_src_addr_reg[3:2] != 2'h0) : (cur_src_addr_reg[3:2] + cur_dma_dw_count_reg[1:0] > 4))));

assign hdr_size_total_dw = avst_data[10:0] - avst_partial_word_en;
assign hdr_size_total    = (DMA_WIDTH ==256) ? (hdr_size_total_dw[10:3] + |hdr_size_total_dw[2:0]) :
                                               (hdr_size_total_dw[10:2] + |hdr_size_total_dw[1:0]);

assign data_sent_o = avst_sop ? ((DMA_WIDTH ==256) ? (hdr_size_total + avst_file_end_size) :
                                                     (hdr_size_total + avst_file_end_size)):
                                (avst_file_end ? avst_file_end_size : 8'h0);

assign total_dw_wrcnt = (cur_dma_dw_count_reg + ((DMA_WIDTH == 256) ? cur_src_addr_reg[4:2] : cur_src_addr_reg[3:2]));
assign total_wrcnt    = (DMA_WIDTH == 256) ? (total_dw_wrcnt[17:3] + |total_dw_wrcnt[2:0]) :
                                             (total_dw_wrcnt[17:2] + |total_dw_wrcnt[1:0]);

assign total_rdcnt    = (DMA_WIDTH == 256) ? (cur_dma_dw_count_reg[17:3] + |cur_dma_dw_count_reg[2:0]) :
                                             (cur_dma_dw_count_reg[17:2] + |cur_dma_dw_count_reg[1:0]);

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      send_data_fifo_rdcnt <= 18'h1;
   end
   else begin
      if ((send_data_fifo_rdcnt >= total_rdcnt) && tlp_file_end)
         send_data_fifo_rdcnt <= 18'h1;
      else if (send_data_fifo_rdreq)
         send_data_fifo_rdcnt <= send_data_fifo_rdcnt + 1;
   end
end


always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      total_credit <= 9'h0;
      credit_error <= 1'b0;
   end
   else begin
      if (send_desc_fifo_rdreq) begin
         total_credit <= 9'h0;
         if (total_credit != total_wrcnt)
            credit_error <= 1'b1;
         else
            credit_error <= 1'b0;
      end
      else if (update_credit_o)
         total_credit <= total_credit + data_sent_o;
   end
end


assign send_data_fifo_full_o = (data_fifo_count > 9'h3A) ? 1'b1 : 1'b0;



generate begin : g_wrfifo
   if (dma_use_scfifo > 0) begin
      reg [2:0] Rst_i_sync;
      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
         if(~Rstn_i) begin
            Rst_i_sync <= 3'h7;
         end
         else begin
            Rst_i_sync[2] <= Rst_i_sync[1];
            Rst_i_sync[1] <= Rst_i_sync[0];
            Rst_i_sync[0] <= 1'b0;
         end
      end

      if (dma_use_scfifo == 1) begin
         altpcie_scfifo_a10      # (
             .WIDTH            (160), //(WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
             .NUM_FIFO32       (1)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  send_desc_fifo    (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (send_desc_fifo_wdata_i),
               .wreq           (send_desc_fifo_wrreq_i),
               .full           (send_desc_fifo_full_o),
               .rdata          (send_desc_fifo_rdata),
               .rreq           (send_desc_fifo_rdreq),
               .empty          (send_desc_fifo_empty),
               .used           (send_desc_fifo_count_o)
         );

         altpcie_a10_scfifo_ext       # (
            .add_ram_output_register    ("OFF"                   ),
            .intended_device_family     ("Stratix V"             ),
            .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
            .lpm_numwords               (64                      ),
            .lpm_showahead              ("OFF"                    ),
            .lpm_type                   ("scfifo"                ),
            .lpm_width                  (DATA_FIFO_WIDTH         ),
            .lpm_widthu                 (9                       ),
            .overflow_checking          ("ON"                    ),
            .underflow_checking         ("ON"                    ),
            .use_eab                    ("ON"                    )
         ) send_data_fifo              (
            .aclr                       (~Rstn_i),
            .clock                      (Clk_i),
            .data                       (send_data_fifo_wdata_i),
            .rdreq                      (send_data_fifo_rdreq),
            .sclr                       (1'b0),
            .wrreq                      (send_data_fifo_wrreq_i),
            .empty                      (send_data_fifo_empty),
            .full                       (send_data_fifo_full),
            .q                          (data_fifo_data),
            .usedw                      (send_data_fifo_count_int),
            .almost_empty               (),
            .almost_full                ()
         );
      end
      else if (dma_use_scfifo == 2) begin
         altpcie_scfifo      # (
             .WIDTH            (160), //(WRDMA_RXDATA_WIDTH), // typical 20,40,60,80
             .NUM_FIFO32       (1)  // Number of 32 DEEP FIFO; Valid Range 1,2,3,4, when 0 only 16 deep
         )  send_desc_fifo    (
               .clk            (Clk_i),
               .sclr           (Rst_i_sync[2]),
               .wdata          (send_desc_fifo_wdata_i),
               .wreq           (send_desc_fifo_wrreq_i),
               .full           (send_desc_fifo_full_o),
               .rdata          (send_desc_fifo_rdata),
               .rreq           (send_desc_fifo_rdreq),
               .empty          (send_desc_fifo_empty),
               .used           (send_desc_fifo_count_o)
         );

         altpcie_sv_scfifo_ext        # (
            .add_ram_output_register    ("OFF"                   ),
            .intended_device_family     ("Stratix V"             ),
            .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
            .lpm_numwords               (64                ),
            .lpm_showahead              ("OFF"                    ),
            .lpm_type                   ("scfifo"                ),
            .lpm_width                  (DATA_FIFO_WIDTH         ),
            .lpm_widthu                 (9                       ),
            .overflow_checking          ("ON"                    ),
            .underflow_checking         ("ON"                    ),
            .use_eab                    ("ON"                    )
         ) send_data_fifo              (
            .aclr                       (~Rstn_i),
            .clock                      (Clk_i),
            .data                       (send_data_fifo_wdata_i),
            .rdreq                      (send_data_fifo_rdreq),
            .sclr                       (1'b0),
            .wrreq                      (send_data_fifo_wrreq_i),
            .empty                      (send_data_fifo_empty),
            .full                       (send_data_fifo_full),
            .q                          (data_fifo_data),
            .usedw                      (send_data_fifo_count_int),
            .almost_empty               (),
            .almost_full                ()
         );

      end
   end
   else begin
      altpcie_fifo      # (
         .FIFO_DEPTH(32),
         .DATA_WIDTH(WRDMA_RXDATA_WIDTH)
         )  send_desc_fifo    (
            .clk          (Clk_i),
            .rstn         (Rstn_i),
            .srst         (1'b0),
            .wrreq        (send_desc_fifo_wrreq_i),
            .rdreq        (send_desc_fifo_rdreq),
            .data         (send_desc_fifo_wdata_i),
            .q            (send_desc_fifo_rdata_int),
            .fifo_count   (send_desc_fifo_count_o)
         );
      assign send_desc_fifo_empty  = (send_desc_fifo_count_o == 0);
      assign send_desc_fifo_full_o = (send_desc_fifo_count_o == 5'h1F);
      always_ff @ (posedge Clk_i or negedge Rstn_i) begin
         if(~Rstn_i)
            send_desc_fifo_rdata <= 256'h0;
         else if (send_desc_fifo_rdreq)
            send_desc_fifo_rdata <= send_desc_fifo_rdata_int;
      end

      // Data FIFO
      scfifo                       # (
         .add_ram_output_register    ("OFF"                   ),
         .intended_device_family     ("Stratix V"             ),
         .lpm_hint                   ("RAM_BLOCK_TYPE  M20K"  ),
         .lpm_numwords               (64                      ),
         .lpm_showahead              ("OFF"                    ),
         .lpm_type                   ("scfifo"                ),
         .lpm_width                  (DATA_FIFO_WIDTH         ),
         .lpm_widthu                 (6                       ),
         .overflow_checking          ("ON"                    ),
         .underflow_checking         ("ON"                    ),
         .use_eab                    ("ON"                    )
      ) send_data_fifo              (
         .aclr                       (~Rstn_i),
         .clock                      (Clk_i),
         .data                       (send_data_fifo_wdata_i),
         .rdreq                      (send_data_fifo_rdreq),
         .sclr                       (1'b0),
         .wrreq                      (send_data_fifo_wrreq_i),
         .empty                      (send_data_fifo_empty),
         .full                       (send_data_fifo_full),
         .q                          (data_fifo_data),
         .usedw                      (send_data_fifo_count_int),
         .almost_empty               (),
         .almost_full                ()
      );
   end
end
endgenerate

//---------------------------------------------------
// Descriptor read and process
// Arbitrate between the other Tx masters/slaves
//---------------------------------------------------

always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      wrdma_sm                 <= WR_IDLE;
      WrDmaLPArbReq_o          <= 1'b0;
      WrDmaHPArbReq_o          <= 1'b0;
      file_valid               <= 1'b0;
      send_desc_fifo_rdreq     <= 1'b0;
      send_desc_fifo_rdreq_reg <= 1'b0;
      arb_ready                <= 1'b0;
   end
   else begin
      send_desc_fifo_rdreq_reg <= send_desc_fifo_rdreq;
      case(wrdma_sm)
         WR_IDLE: begin
            if(~send_desc_fifo_empty && ~data_fifo_empty) begin
               wrdma_sm             <= WR_RD_DESC;
               WrDmaLPArbReq_o      <= 1'b1;
               WrDmaHPArbReq_o      <= 1'b1;
               file_valid           <= 1'b0;
               send_desc_fifo_rdreq <= 1'b1;
               arb_ready            <= 1'b1;
            end
            // When Wr DMA is not active it controls the req/gnt for the side fifo
            // so the side fifo is not starved by the other masters
            else if(hdr_gen_sm == START_FILE) begin
               file_valid <= 1'b0;
               if(WrDmaLPArbReq_i) begin
                  if(WrDmaArbGranted_i & WrDmaHPArbReq_o) begin
                     WrDmaLPArbReq_o <= 1'b0;
                     WrDmaHPArbReq_o <= 1'b1;
                     wrdma_sm        <= WR_IDLE;
                     arb_ready       <= 1'b0;
                  end
                  else begin
                     WrDmaLPArbReq_o <= 1'b1;
                     WrDmaHPArbReq_o <= 1'b1;
                     wrdma_sm        <= WR_IDLE;
                     arb_ready       <= 1'b1;
                  end
               end
               else if(WrDmaHPArbReq_i) begin
                  WrDmaLPArbReq_o <= 1'b1;
                  WrDmaHPArbReq_o <= 1'b0;
                  wrdma_sm        <= WR_IDLE;
                  arb_ready       <= 1'b0;
               end
               else begin
                  WrDmaLPArbReq_o <= 1'b1;
                  WrDmaHPArbReq_o <= 1'b1;
                  wrdma_sm        <= WR_IDLE;
                  arb_ready       <= 1'b1;
               end
            end
            else begin
               wrdma_sm        <= WR_IDLE;
               WrDmaLPArbReq_o <= 1'b1;
               WrDmaHPArbReq_o <= 1'b1;
               file_valid      <= 1'b0;
               arb_ready       <= 1'b1;
            end
         end

         WR_RD_DESC: begin
            WrDmaLPArbReq_o      <= 1'b1;
            WrDmaHPArbReq_o      <= 1'b1;
            arb_ready            <= 1'b1;
            file_valid           <= 1'b0;
            send_desc_fifo_rdreq <= 1'b0;
            if (tlp_advance)
               wrdma_sm <= WR_DATA_RCV;
            else
               wrdma_sm <= WR_RD_DESC;
         end

         WR_DATA_RCV: begin
               if (((send_data_fifo_count) >=  ((DMA_WIDTH == 256) ? max_payld_size[7:3] : max_payld_size[7:2])) ||
                  ((send_data_fifo_count) >=  total_rdcnt)) begin
                  WrDmaLPArbReq_o <= 1'b1;
                  send_desc_fifo_rdreq <= 1'b0;
                  if (WrDmaHPArbReq_i) begin
                     WrDmaHPArbReq_o <= 1'b0;
                     file_valid      <= 1'b0;
                     wrdma_sm        <= WR_DATA_RCV;
                     arb_ready       <= 1'b0;
                  end
                  else begin
                     WrDmaHPArbReq_o <= 1'b1;
                     file_valid      <= 1'b1;
                     wrdma_sm        <= WR_DATA_RD;
                     arb_ready       <= 1'b1;
                  end
               end
               else begin
                  wrdma_sm   <= WR_DATA_RCV;
                  file_valid <= 1'b0;
                  WrDmaLPArbReq_o <= 1'b1;
                  WrDmaHPArbReq_o <= 1'b1;
                  send_desc_fifo_rdreq <= 1'b0;
                  arb_ready       <= 1'b1;
               end
         end

         WR_DATA_RD: begin
            if(WrDmaArbGranted_i) begin
               wrdma_sm   <= WR_SEND;
               file_valid <= 1'b0;
               WrDmaLPArbReq_o <= 1'b1;
               WrDmaHPArbReq_o <= 1'b1;
               send_desc_fifo_rdreq <= 1'b0;
               arb_ready       <= 1'b1;
            end
            else begin
               wrdma_sm   <= WR_DATA_RD;
               file_valid <= 1'b0;
               WrDmaLPArbReq_o <= 1'b1;
               WrDmaHPArbReq_o <= 1'b1;
               send_desc_fifo_rdreq <= 1'b0;
               arb_ready       <= 1'b0;
            end
         end

         WR_SEND: begin
            file_valid           <= 1'b0;
            send_desc_fifo_rdreq <= 1'b0;
            if(avst_file_end) begin
               wrdma_sm <= WR_IDLE;
               if (WrDmaHPArbReq_i & ~WrDmaLPArbReq_i) begin
                  WrDmaHPArbReq_o <= 1'b0;
                  WrDmaLPArbReq_o <= 1'b1;
                  arb_ready       <= 1'b0;
               end
               else begin
                  WrDmaHPArbReq_o <= 1'b1;
                  WrDmaLPArbReq_o <= 1'b0;
                  arb_ready       <= 1'b0;
               end
            end
            else if(WrDmaLPArbReq_i && |tlp_end_hold && !(tlp_val && tlp_start)) begin
               wrdma_sm        <= WR_ARB_RDY;
               WrDmaLPArbReq_o <= 1'b0;
               WrDmaHPArbReq_o <= 1'b1;
               arb_ready       <= 1'b0;
            end
            else begin
               wrdma_sm        <= WR_SEND;
               WrDmaLPArbReq_o <= 1'b1;
               WrDmaHPArbReq_o <= 1'b1;
               arb_ready       <= 1'b1;
            end
         end

         WR_ARB_RDY: begin
            file_valid           <= 1'b0;
            send_desc_fifo_rdreq <= 1'b0;
            if(avst_file_end) begin
               wrdma_sm <= WR_IDLE;
               if (WrDmaHPArbReq_i & ~WrDmaLPArbReq_i) begin
                  WrDmaHPArbReq_o <= 1'b0;
                  WrDmaLPArbReq_o <= 1'b1;
                  arb_ready       <= 1'b0;
               end
               else begin
                  WrDmaHPArbReq_o <= 1'b1;
                  WrDmaLPArbReq_o <= 1'b1;
                  arb_ready       <= 1'b0;
               end
            end
            else begin
               wrdma_sm        <= WR_SEND;
               WrDmaLPArbReq_o <= 1'b1;
               WrDmaHPArbReq_o <= 1'b1;
               arb_ready       <= 1'b0;
            end
         end

         default: begin
            wrdma_sm <= WR_IDLE;
         end
      endcase
   end
end



//-------------------------------------------------
// Align the data to dw address before writing to the FIFO
//-------------------------------------------------

/// current descriptor
always_ff @ (posedge Clk_i or negedge Rstn_i)
begin
   if(~Rstn_i) begin
      cur_dest_addr_reg        <= 64'h0;
      cur_src_addr_reg         <= 64'h0;
      cur_dma_dw_count_reg     <= 18'h0;
      cur_desc_id_reg          <= 8'h0;
      cur_req_func             <= 8'h0;
      send_desc_fifo_rdata_reg <= 168'h0;
   end
   else if(send_desc_fifo_rdreq_reg) begin
      cur_dest_addr_reg        <= send_desc_fifo_rdata[127:64];
      cur_src_addr_reg         <= send_desc_fifo_rdata[63:0];
      cur_dma_dw_count_reg     <= send_desc_fifo_rdata[145:128];
      cur_desc_id_reg          <= send_desc_fifo_rdata[153:146];
      cur_req_func             <= (SRIOV_EN == 1) ? send_desc_fifo_rdata[167:160] : 8'h0;
      send_desc_fifo_rdata_reg <= send_desc_fifo_rdata;
   end
end

assign dw_cnt_in_word = (DMA_WIDTH == 256) ? 4'd8 : 4'd4;     //# of DW's in 256 bits=8; in 128 bits=4

//----------------------------------------------
// Generating the header
//----------------------------------------------
// calculations for detecting 4K address boundary crossing
// - can be simplified if max_payld_size is assumed to be constant
// - or if okay to generate 1 pkt every 2 clocks.

assign file_size = cur_dma_dw_count_reg;
assign file_addr = cur_dest_addr_reg;
assign file_num  = cur_desc_id_reg;

assign curr_addr_plus_filesizerem = curr_addr + {file_size_remain, 2'h0};
assign file_addr_plus_filesize    = file_addr + {file_size, 2'h0};
assign curr_addr_plus_maxpload    = curr_addr + {max_payld_size_reg, 2'h0};
assign file_addr_plus_maxpload    = file_addr + {max_payld_size_reg, 2'h0};


always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      hdr_gen_sm         <= START_FILE;
      hdr_valid          <= 1'b0;
      hdr_size           <= 11'h000;
      hdr_file_num       <= 8'h0;
      hdr_file_end       <= 1'b0;
      max_payld_size_reg <= 8'h00;
      file_size_remain   <= {FILE_SIZE_WIDTH{1'b0}};
   end
   else begin
      max_payld_size_reg    <= max_payld_size;
      //-------------------------------------------
      // break file request down into TLP requests
      //-------------------------------------------

      case (hdr_gen_sm)
         START_FILE: begin
            hdr_valid        <= 1'b0;

            file_size_remain <= {FILE_SIZE_WIDTH{1'b0}};
            if (file_valid) begin
               hdr_file_num <= file_num;
               hdr_address  <= file_addr;
               hdr_valid    <= 1'b1;
               if (ALLOW_ANY_FILE_SIZE & (file_size <= max_payld_size_reg)) begin       // file request fits in one TLP
                  if (file_addr[12] != file_addr_plus_filesize[12]) begin               // handle 4K bound
                     hdr_size <= 11'h400 - {1'h0, file_addr[11:2]};
                     if (file_size == (11'h400 - {1'h0, file_addr[11:2]})) begin       // file ends at 4K boundary, send all
                        hdr_file_end <= 1'b1;
                        hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                     end
                     else begin                                                                // file crosses 4K boundary, send partial
                        hdr_file_end <= 1'b0;
                        hdr_gen_sm   <= CONT_FILE;
                     end
                     // calculate remaining file size and next tlp addr
                     curr_addr        <= {file_addr[63:12], 12'h000} + 64'h00000000_00001000; // 4K boundary
                     file_size_remain <= file_size - (11'h400 - {1'h0, file_addr[11:2]});     // in DWs
                  end
                  else begin                                                                  // no 4K boundary - send entire file in 1 TLP
                     hdr_size     <= file_size;
                     hdr_file_end <= 1'b1;
                     hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                  end
               end
               else begin                                                                     // requires more than one TLP
                  hdr_gen_sm   <= CONT_FILE;
                  hdr_file_end <= 1'b0;
                  if (file_addr[12] != file_addr_plus_maxpload[12]) begin                     // break at 4K bound
                     hdr_size <= 11'h400 - {1'h0, file_addr[11:2]};
                     // advance address,
                     curr_addr        <= {file_addr[63:12], 12'h000} + 64'h00000000_00001000; // 4K boundary address
                     file_size_remain <= file_size - (11'h400 - {1'h0, file_addr[11:2]});
                  end
                  else begin                                                                  // no 4K bound - use max payload packet
                     hdr_size         <= max_payld_size_reg;
                     curr_addr        <= file_addr[63:0] + {max_payld_size_reg, 2'h0};
                     file_size_remain <= file_size - max_payld_size_reg;
                  end
               end
            end
            else begin
               hdr_valid    <= 1'b0;
               hdr_file_end <= 1'b0;
               hdr_gen_sm   <= hdr_gen_sm;
            end
         end

         CONT_FILE: begin
            // file request requires another TLP to complete
            if (hdr_advance) begin
               hdr_address <= curr_addr;
               hdr_valid   <= 1'b1;
               if (file_size_remain <= max_payld_size_reg) begin                                  // could fit remaining file in one TLP
                  // 4K addr bound crossing - break TLP at 4K bound
                  if (curr_addr[12] != curr_addr_plus_filesizerem[12]) begin                      // handle 4K boundary
                     hdr_size     <= (11'h400 - {1'h0, curr_addr[11:2]});
                     if (file_size_remain == (11'h400 - {1'h0, curr_addr[11:2]})) begin           // file ends at 4K boundary, send all in one TLP
                        hdr_file_end <= 1'b1;
                        hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                     end
                     else begin                                                                   // file crosses 4K boundary, send partial
                        hdr_file_end <= 1'b0;
                        hdr_gen_sm   <= CONT_FILE;
                     end
                     // calculate remaining file size and next tlp addr
                     curr_addr        <= {curr_addr[63:12], 12'h000} + 64'h00000000_00001000;    // 4K boundary address
                     file_size_remain <= file_size_remain - (11'h400 - {1'h0, curr_addr[11:2]});
                  end
                  else begin                                                                     // send remaining file in one TLP
                     hdr_size     <= file_size_remain;
                     hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                     hdr_file_end <= 1'b1;
                  end
               end
               else begin                                                                        // remaining file does not fit in one TLP
                  hdr_file_end <= 1'b0;
                  hdr_valid    <= 1'b1;
                  if (curr_addr[12] != curr_addr_plus_maxpload[12]) begin                       // break at 4K boundary
                     hdr_size   <= 11'h400 - {1'h0, curr_addr[11:2]} ;
                     hdr_gen_sm <= CONT_FILE;
                     // calculate remaining file size and next tlp addr
                     curr_addr        <= {curr_addr[63:12], 12'h000} + 64'h00000000_00001000;   // 4K boundary address
                     file_size_remain <= file_size_remain - (11'h400 - {1'h0, curr_addr[11:2]});
                  end
                  else begin                                                                    // no 4K boundary - send max payload
                     hdr_size   <= max_payld_size_reg;
                     hdr_gen_sm <= CONT_FILE;
                     // calculate next tlp size/addr
                     curr_addr        <= curr_addr_plus_maxpload;
                     file_size_remain <= file_size_remain - max_payld_size_reg;
                  end
               end
            end
            else begin
               hdr_valid    <= 1'b0;
            end
         end

         WAIT_LASTPKT_PROC: begin
            hdr_valid    <= 1'b0;
            // wait for last pkt to end processing
            // before requesting new file.
            if (hdr_advance) begin
               hdr_gen_sm   <= START_FILE;
               hdr_valid    <= 1'b0;
            end
         end
         default: begin
            hdr_gen_sm   <= START_FILE;
         end
      endcase  // hdr_gen_sm
   end
end

// Wait till there is enough data for a complete TLP till the
// header valid signal is issued to the TLP generator
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      hdr_valid_r  <= 1'b0;
      hdr_valid_rr <= 1'b0;
   end
   else begin
      if (hdr_valid_wdata)
         hdr_valid_rr <= 1'b0;
      else if (avst_ready || tlp_advance)
         hdr_valid_rr <= hdr_valid_r;
      else
         hdr_valid_rr <= hdr_valid_rr;
      // Latch hrd_valid till enough data is accumulated
      if (hdr_valid_wdata)
         hdr_valid_r <= 1'b0;
      else if (hdr_valid)
         hdr_valid_r <= 1'b1;
      else if (((((send_data_fifo_count)*((DMA_WIDTH == 256) ? 8 : 4))+hdr_partial_word_sel) >= hdr_size) && avst_ready)
         hdr_valid_r <= 1'b0;
   end
end

assign hdr_valid_wdata = (~hdr_valid_r && hdr_valid_rr && ~hdr_valid_wdata_reg) ||
                         ((WrDmaLPArbReq_i & ~file_valid) ?
                         ((DMA_WIDTH == 256) ? (hdr_valid_r && ((((send_data_fifo_count)*((DMA_WIDTH == 256) ? 8 : 4)) + hdr_partial_word_sel) >= hdr_size) && tlp_advance) :
                                               (hdr_valid_rr && ((((send_data_fifo_count)*((DMA_WIDTH == 256) ? 8 : 4)) + hdr_partial_word_sel) >= hdr_size) && tlp_advance)) :
                         (hdr_valid && ((((send_data_fifo_count)*((DMA_WIDTH == 256) ? 8 : 4)) + hdr_partial_word_sel) > hdr_size) && tlp_advance));

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i)
      hdr_valid_wdata_reg <= 1'b0;
   else
      hdr_valid_wdata_reg <= hdr_valid_wdata;
end
//----------------------------------------------
//TLP generator
//----------------------------------------------

// Assign partial word select on next TLP
// It is latched on the previous TLP
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i)
      hdr_partial_word_en <= 3'h0;
   else if (hdr_valid_wdata)
      hdr_partial_word_en <= hdr_partial_word_sel;
end


// convert header size to pcie TLP length field
assign tlp_length_n = hdr_size[10] ? 10'h000 : hdr_size[9:0];


// calculate the fmt_type field
// MEMWR with 4DW or 3DW address
assign tlp_4dw_hdr    = |hdr_address[63:32];
assign tlp_odd_dwaddr = hdr_address[2];
assign fmt_type       = tlp_4dw_hdr ?  8'h60 : 8'h40;
assign tlp_3dw_hdr    = ~tlp_4dw_hdr & tlp_odd_dwaddr;

// calculate PCIe TLP first byte enable field
assign tlp_byte_ena[3:0] = (hdr_address[1:0]==2'h0) ?  4'b1111 :
                           (hdr_address[1:0]==2'h1) ?  4'b1110 :
                           (hdr_address[1:0]==2'h2) ?  4'b1100 : 4'b1000 ;

// calculate PCIe TLP last byte enable field
// - for now restrict file size to whole DWs
assign tlp_byte_ena[7:4] = (hdr_size < 11'h2)       ?  4'b0000 :
                           (hdr_address[1:0]==2'h0) ?  4'b1111 :
                           (hdr_address[1:0]==2'h1) ?  4'b0111 :
                           (hdr_address[1:0]==2'h2) ?  4'b0011 : 4'b0001 ;

// SR-IOV Generate requestor ID
assign requestor_id = (SRIOV_EN == 1) ?
                      ((ARI_EN == 1) ? {BusDev_i[15:8], cur_req_func} :
                                       {BusDev_i[15:3], cur_req_func[2:0]}) : BusDev_i[15:0];

always @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      tlp_val              <= 1'b0;
      tlp_read             <= 1'b0;
      tlp_start            <= 1'b0;
      tlp_end              <= 8'h0;
      tlp_file_num         <= 8'h0;
      tlp_file_end         <= 1'b0;
      tlp_gen_sm           <= INIT;
      hdr_size_remain      <= 10'h0;
      hdr_file_end_hold    <= 1'b0;
      hdr_advance          <= 1'b0;
      hdr_partial_word_sel <= 3'h0;
   end
   else begin
   //-----------------------------------
   // payload state machine
   // - issue desc cycle + data cycles
   // - indicate start + end cycles
   //-----------------------------------
      case (tlp_gen_sm)
         INIT: begin
            tlp_gen_sm           <= START_DATA;
            hdr_partial_word_sel <= 3'h0;
            tlp_val              <= 1'b0;
            tlp_read             <= 1'b0;
         end

         START_DATA: begin
            hdr_partial_word_sel <= tlp_file_end ? 3'h0 : hdr_partial_word_sel;
            if (hdr_valid_wdata) begin
               tlp_file_num <= hdr_file_num;
               tlp_val      <= tlp_advance;
               // Dont read FIFO if partial word is available. Also in 128bit ifc, the first cycle is all header except when 3DW
               tlp_read     <= (hdr_size <= hdr_partial_word_sel) ? 1'b0 : ((DMA_WIDTH == 256) ? (tlp_advance && (send_data_fifo_rdcnt <= total_rdcnt))  :
                               ((tlp_3dw_hdr & AVST_ADDR_ALIGN & (send_data_fifo_rdcnt <= total_rdcnt)) ? tlp_advance : 1'b0));
               tlp_start    <= 1'b1;
               tlp_desc     <= tlp_4dw_hdr ? {fmt_type, 8'h00, 6'h0, tlp_length_n, requestor_id, 8'h0, tlp_byte_ena, hdr_address[63:2], 2'h0} :
                                             {fmt_type, 8'h00, 6'h0, tlp_length_n, requestor_id, 8'h0, tlp_byte_ena, hdr_address[31:2], 34'h0};
               hdr_file_end_hold <= hdr_file_end;
               // more than 1 data phase, allow one more dw when addr alignment required
               if ((DMA_WIDTH == 256) ? ((hdr_size + (tlp_4dw_hdr & tlp_odd_dwaddr & AVST_ADDR_ALIGN)) > 11'h4) :
                                        (hdr_size > tlp_3dw_hdr)) begin
                  tlp_gen_sm      <= tlp_advance ? CONT_DATA : tlp_gen_sm;
                  if ((hdr_size < 11'd9) && (DMA_WIDTH == 256)) begin
                     case (hdr_size)
                        11'h8:   tlp_end <= (DMA_WIDTH == 256) ? 8'b1000_0000 : 8'b0000_0000;
                        11'h7:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0100_0000 : 8'b0000_0000;
                        11'h6:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0010_0000 : 8'b0000_0000;
                        11'h5:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0001_0000 : 8'b0000_0000;
                        11'h4:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_1000 : 8'b0000_1000;
                        11'h3:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0100 : 8'b0000_0100;
                        11'h2:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0010 : 8'b0000_0010;
                        11'h1:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0001 : 8'b0000_0001;
                        default: tlp_end <= 8'b0000_0000;
                     endcase
                     case (hdr_size)
                        10'h8:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                        10'h7:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h1 : 3'h0;
                        10'h6:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h2 : 3'h0;
                        10'h5:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h3 : 3'h0;
                        10'h4:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h4 : 3'h0;
                        10'h3:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h5 : 3'h1;
                        10'h2:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h6 : 3'h2;
                        10'h1:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h7 : 3'h3;
                        10'h0:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                        default: hdr_partial_word_sel <= 3'h0;
                     endcase
                     hdr_size_remain <= hdr_size;
                     tlp_file_end    <= hdr_file_end;
                  end
                  else begin
                     tlp_end         <= 8'h00;
                     // When >256 first cycle is used for header only
                     hdr_size_remain <= (DMA_WIDTH == 256) ? (hdr_size - 11'h8 - hdr_partial_word_sel) : (hdr_size - hdr_partial_word_sel - tlp_3dw_hdr);
                     tlp_file_end    <= 1'b0;
                  end
               end
               else begin                                           // only 1 data phase
                  tlp_gen_sm      <= START_DATA;
                  hdr_advance     <= tlp_advance;
                  tlp_file_end    <= hdr_file_end;
                  hdr_size_remain <= hdr_size;
                  case (hdr_size)
                     11'h8:   tlp_end <= (DMA_WIDTH == 256) ? 8'b1000_0000 : 8'b0000_0000;
                     11'h7:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0100_0000 : 8'b0000_0000;
                     11'h6:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0010_0000 : 8'b0000_0000;
                     11'h5:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0001_0000 : 8'b0000_0000;
                     11'h4:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_1000 : 8'b0000_1000;
                     11'h3:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0100 : 8'b0000_0100;
                     11'h2:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0010 : 8'b0000_0010;
                     11'h1:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0001 : 8'b0000_0001;
                     default: tlp_end <= 8'b0000_0000;
                  endcase
                  case (hdr_size)
                     10'h8:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                     10'h7:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h1 : 3'h0;
                     10'h6:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h2 : 3'h0;
                     10'h5:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h3 : 3'h0;
                     10'h4:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h4 : 3'h0;
                     10'h3:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h5 : 3'h1;
                     10'h2:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h6 : 3'h2;
                     10'h1:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h7 : 3'h3;
                     10'h0:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                     default: hdr_partial_word_sel <= 3'h0;
                  endcase
               end
            end
            else begin
               tlp_start       <= tlp_start;
               tlp_end         <= tlp_end;
               tlp_file_end    <= tlp_file_end;
               tlp_val         <= 1'b0;
               tlp_read        <= 1'b0;
               hdr_advance     <= 1'b0;
            end
         end

         CONT_DATA: begin
            if (tlp_advance && (~data_fifo_empty ||
                               // fifo is empty but all data has been read out
                               (data_fifo_empty && (send_data_fifo_rdcnt >= total_rdcnt)))) begin
               tlp_start       <= 1'b0;
               if(hdr_size_remain + hdr_partial_word_sel < ((DMA_WIDTH == 256) ? 10'h9 : 4'h5)) begin // generating last data cycle of TLP
                  case (hdr_size_remain + hdr_partial_word_sel + ((DMA_WIDTH == 256) ? 1'b0 : tlp_3dw_hdr))
                     10'h8:   tlp_end <= (DMA_WIDTH == 256) ? 8'b1000_0000 : 8'b0000_1000;
                     10'h7:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0100_0000 : 8'b0000_0100;
                     10'h6:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0010_0000 : 8'b0000_0010;
                     10'h5:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0001_0000 : 8'b0000_0001;
                     10'h4:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_1000 : 8'b0000_1000;
                     10'h3:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0100 : 8'b0000_0100;
                     10'h2:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0010 : 8'b0000_0010;
                     10'h1:   tlp_end <= (DMA_WIDTH == 256) ? 8'b0000_0001 : 8'b0000_0001;
                     default: tlp_end <= 8'b0000_0000;
                  endcase
                  case (hdr_size_remain + ((DMA_WIDTH == 256) ? 1'b0 : tlp_3dw_hdr))
                     10'h8:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                     10'h7:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h1 : 3'h1;
                     10'h6:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h2 : 3'h2;
                     10'h5:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h3 : 3'h3;
                     10'h4:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h4 : 3'h0;
                     10'h3:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h5 : 3'h1;
                     10'h2:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h6 : 3'h2;
                     10'h1:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h7 : 3'h3;
                     10'h0:   hdr_partial_word_sel <= (DMA_WIDTH == 256) ? 3'h0 : 3'h0;
                     default: hdr_partial_word_sel <= 3'h0;
                  endcase
                  tlp_gen_sm      <= (DMA_WIDTH == 256) ? START_DATA : (((hdr_size <= hdr_size_remain) || (hdr_size < dw_cnt_in_word+1)) ? LAST_DATA : START_DATA);
                  tlp_val         <= 1'b1;
                  hdr_advance     <= (DMA_WIDTH == 256) ? 1'b1 : (((hdr_size <= hdr_size_remain) || (hdr_size < dw_cnt_in_word+1))? 1'b0 : 1'b1);
                  tlp_file_end    <= hdr_file_end_hold;
                  if (tlp_file_end) begin
                     tlp_read <= 1'b0;
                  end
                  else begin
                     if (send_data_fifo_rdcnt == total_rdcnt) begin
                        if (((DMA_WIDTH == 256) && (hdr_size < dw_cnt_in_word)) || send_data_fifo_rdreq)
                           tlp_read <= 1'b0;
                        else
                           tlp_read <= 1'b1;
                     end
                     else if (send_data_fifo_rdcnt < total_rdcnt) begin
                        if(((DMA_WIDTH == 256) && (hdr_size > dw_cnt_in_word)) ||
                          ((DMA_WIDTH == 128) && (!(tlp_3dw_hdr && (hdr_size_remain < dw_cnt_in_word)))))
                           tlp_read <= 1'b1;
                        else
                           tlp_read <= 1'b0;
                     end
                     else begin
                        tlp_read <= 1'b0;
                     end
                  end
               end
               else begin                               // need more data cycles
                  tlp_end         <= 8'h00;
                  tlp_gen_sm      <= tlp_gen_sm;
                  tlp_file_end    <= 1'b0;
                  hdr_advance     <= 1'b0;
                  tlp_read <= 1'b1;
                  tlp_val  <= (hdr_size < dw_cnt_in_word+1) ? 1'b0 : 1'b1;
                  hdr_size_remain <= hdr_size_remain - dw_cnt_in_word;
               end
            end
            else begin
               hdr_advance     <= 1'b0;
               tlp_read <=  1'b0;
               tlp_val <= 1'b0;
            end
         end

         LAST_DATA: begin
            tlp_gen_sm <= START_DATA;
            hdr_advance     <= 1'b1;
            tlp_val <= tlp_val;
            if (send_data_fifo_rdcnt == total_rdcnt) begin
               if (send_data_fifo_rdreq)
                  tlp_read <= 1'b0;
               else
                  tlp_read <= 1'b1;
            end
            else if (send_data_fifo_rdcnt < total_rdcnt) begin
               if (hdr_size > dw_cnt_in_word)
                  tlp_read <= 1'b1;
               else
                  tlp_read <= 1'b0;
            end
            else
               tlp_read <= 1'b0;
         end

         default: begin
            tlp_gen_sm <= INIT;
         end
      endcase  // tlp_gen_sm
   end
end

//----------------------------------------------------------------
// AVST Fifo Interface
//----------------------------------------------------------------
assign avst_ready        = (TxFifoCount_i < 10);
assign tlp_odd_dwaddr_av = tlp_desc[125] ? tlp_desc[2] : tlp_desc[34];
assign tlp_4dw_hdr_av    = tlp_desc[125];
assign tlp_3dw_hdr_av    = ~tlp_4dw_hdr_av && tlp_odd_dwaddr_av;

// Data to AVST Interface
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      payld_shift       <= 1'b0;
      send_data_fifo_rdreq_r <= 1'b0;
      tlp_val_r         <= 1'b0;
      tlp_start_r       <= 1'b0;
      tlp_end_r         <= 8'h0;
   end
   else begin
      payld_shift       <= payld_shift_n;
      send_data_fifo_rdreq_r <= send_data_fifo_rdreq;
      tlp_val_r         <= tlp_val;
      tlp_start_r       <= tlp_start;
      tlp_end_r         <= tlp_end;
      if (send_data_fifo_rdreq_r)
         data_fifo_data_r <= data_fifo_data;
      else
         data_fifo_data_r <= data_fifo_data_r;
   end
end

//-----------------------------------------------------------------
// Select data appropriately from two 256 bit data words when only
// a part of the word is used in a TLP, the rest of the word needs
// to be used in another TLP
//----------------------------------------------------------------
always @ (*) begin  //(data_fifo_data or data_fifo_data_r or hdr_partial_word_en)
   case (hdr_partial_word_en)
      3'b000:  tlp_data = (DMA_WIDTH == 256) ? data_fifo_data : {128'h0, data_fifo_data[127:0]};
      3'b001:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[223:0], data_fifo_data_r[255:224]} : {data_fifo_data[95:0], data_fifo_data_r[127:96]};
      3'b010:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[191:0], data_fifo_data_r[255:192]} : {data_fifo_data[63:0], data_fifo_data_r[127:64]};
      3'b011:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[159:0], data_fifo_data_r[255:160]} : {data_fifo_data[31:0], data_fifo_data_r[127:32]};
      3'b100:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[127:0], data_fifo_data_r[255:128]} : data_fifo_data;
      3'b101:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[95:0], data_fifo_data_r[255:96]} : {data_fifo_data[95:0], data_fifo_data_r[127:96]};
      3'b110:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[63:0], data_fifo_data_r[255:64]} : {data_fifo_data[63:0], data_fifo_data_r[127:64]};
      3'b111:  tlp_data = (DMA_WIDTH == 256) ? {data_fifo_data[31:0], data_fifo_data_r[255:32]} : {data_fifo_data[31:0], data_fifo_data_r[127:32]};
      default: tlp_data = data_fifo_data;
   endcase
end


//------------------------------------------------------------
// shift payload
// - some payload is sent along with header, the rest are
//   deferred to next cycle.
//------------------------------------------------------------

assign payld_shift_n = ~tlp_val ? payld_shift :
            (AVST_ADDR_ALIGN & tlp_4dw_hdr_av & tlp_odd_dwaddr_av)   ? 3'h3 :        // 4DW hdr, odd addr - fit 3 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & tlp_4dw_hdr_av & ~tlp_odd_dwaddr_av)  ? 3'h4 :        // 4DW hdr, even addr - fit 4 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & ~tlp_4dw_hdr_av & ~tlp_odd_dwaddr_av) ? 3'h4 :        // 3DW hdr, even addr - fit 4 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & ~tlp_4dw_hdr_av & tlp_odd_dwaddr_av)  ? 3'h5 :        // 3DW hdr, odd addr - fit 5 DWs of payld in first cycle
            (~AVST_ADDR_ALIGN & tlp_4dw_hdr_av)                      ? 3'h4 : 3'h5 ; // No addr align

assign tlp_end_shifted_n = (payld_shift == 3'h3) ? {(tlp_end_r[2:0] & {3{tlp_val_r}}), tlp_end_hold[7:3]} :
                           (payld_shift == 3'h4) ? {(tlp_end_r[3:0] & {4{tlp_val_r}}), tlp_end_hold[7:4]} :
                                                   {(tlp_end_r[4:0] & {5{tlp_val_r}}), tlp_end_hold[7:5]} ;

assign tlp_data_shifted = (payld_shift == 3'h3) ? ((DMA_WIDTH == 256) ? {tlp_data[95:0],  tlp_data_hold[255:96]} : {tlp_data[95:0], tlp_data_hold[127:96]}) :
                          (payld_shift == 3'h4) ? ((DMA_WIDTH == 256) ? {tlp_data[127:0], tlp_data_hold[255:128]} :{tlp_data[127:0]}) :
                                                  ((DMA_WIDTH == 256) ? {tlp_data[159:0], tlp_data_hold[255:160]} :{tlp_data[31:0], tlp_data_hold[127:32]}) ;


always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      avst_data         <= 256'h0;
      avst_valid        <= 1'b0;
      avst_sop          <= 1'b0;
      avst_eop          <= 1'b0;
      avst_empty        <= 2'h0;
      avst_file_num     <= 8'h0;
      avst_file_end     <= 1'b0;
      tlp_end_hold      <= 8'h0;
      tlp_file_end_hold <= 1'b0;
      avst_sm           <= AVST_START_STATE;
      tlp_advance       <= 1'b0;
      avst_partial_word_en <= 3'h0;
   end
   else begin
      tlp_data_hold <= tlp_val_r ? tlp_data : tlp_data_hold;

      if (~tlp_desc[126]) begin   // no payloadr
         avst_empty <= 2'h2;
      end
      else begin
         case (tlp_end_shifted_n)
            8'b0000_0000: avst_empty <= 2'h0;
            8'b1000_0000: avst_empty <= 2'h0;
            8'b0100_0000: avst_empty <= 2'h0;
            8'b0010_0000: avst_empty <= 2'h1;
            8'b0001_0000: avst_empty <= 2'h1;
            8'b0000_1000: avst_empty <= 2'h2;
            8'b0000_0100: avst_empty <= 2'h2;
            default:      avst_empty <= 2'h3;
         endcase
      end
      //----------------------------------------------------------
      // this controller processes every tlp_val it receives.
      // it is not throttled by the downstream module.
      // instead, the downstream module directly throttles the
      // tlp generator.
      // this module can also stall the tlp generator when address
      // alignment causes an extra data cycle to be inserted into
      // the datastream.
      //----------------------------------------------------------
      case (avst_sm)
         AVST_START_STATE: begin
            if (tlp_start_r & tlp_val_r) begin
               avst_partial_word_en <= hdr_partial_word_en;
               //----------------------------
               // avst data = desc + data
               //----------------------------
               if (AVST_ADDR_ALIGN) begin
                  case ({tlp_4dw_hdr_av, tlp_odd_dwaddr_av})
                     2'b11:   avst_data <= {tlp_data[95:0], 32'h0, tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                     2'b10:   avst_data <= {tlp_data[127:0], tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                     2'b00:   avst_data <= {tlp_data[127:0], 32'h0, tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                     default: avst_data <= (DMA_WIDTH == 256) ? {tlp_data[159:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]} :
                                                                {tlp_data[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                  endcase
               end
               else begin
                  if (tlp_4dw_hdr_av) begin
                     avst_data <= {tlp_data[127:0], tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                  end
                  else begin
                     avst_data <= {tlp_data[159:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};
                  end
               end
               //------------------------
               // avst control signals
               //------------------------
               avst_sop      <= 1'b1;
               avst_valid    <= 1'b1;
               avst_file_num <= tlp_file_num;
               if (~tlp_desc[126]) begin                       // no payload
                  avst_eop      <= 1'b1;
                  avst_file_end <= tlp_file_end;
                  avst_sm       <= AVST_START_STATE;
                  tlp_end_hold  <= 8'h00;
                  tlp_advance   <= avst_ready;
               end
               else if (|tlp_end_r & ~|tlp_end_shifted_n) begin // rcving end of payload, but needs to be deferred to next cycle
                  avst_eop          <= 1'b0;
                  avst_file_end     <= 1'b0;
                  avst_sm           <= (DMA_WIDTH == 256) ? AVST_EXTRA_DATA_STATE : AVST128_EXTRA_DATA_STATE; // insert extra data cycle for deferred data
                  tlp_end_hold      <= tlp_end_r;
                  tlp_file_end_hold <= tlp_file_end;
                  tlp_advance       <= 1'b0;
               end
               else if (|tlp_end_r) begin                                      // rcving end of payload that can fit in current AVST cycle
                  avst_eop          <= (DMA_WIDTH == 256) ? 1'b1 : (tlp_3dw_hdr_av ? 1'b1 : 1'b0);                 // Can happen in 128 ifc only if 3DW hdr and odd addr
                  avst_file_end     <= (DMA_WIDTH == 256) ? tlp_file_end : (tlp_3dw_hdr_av ? tlp_file_end : 1'b0); // and size = 1DW, otherwise need an extra cycle
                  avst_sm           <= (DMA_WIDTH == 256) ? AVST_START_STATE : (tlp_3dw_hdr_av ? AVST_START_STATE : AVST128_EXTRA_DATA_STATE);
                  tlp_end_hold      <= 8'h00;
                  tlp_advance       <= (DMA_WIDTH == 256) ? avst_ready : 1'b1;   // Send out the last cycle
                  tlp_file_end_hold <= (DMA_WIDTH == 256) ? 1'b0 : tlp_file_end;
               end
               else begin                                     // not rcving end of payload
                  avst_eop      <= 1'b0;
                  avst_file_end <= 1'b0;
                  avst_sm       <= (DMA_WIDTH == 256) ? AVST_DATA_STATE : AVST128_DATA_STATE;
                  tlp_end_hold  <= tlp_end_r;
                  tlp_advance   <= avst_ready;
               end
            end
            else begin
               avst_valid    <= 1'b0;
               avst_sop      <= 1'b0;
               avst_eop      <= 1'b0;
               avst_file_end <= 1'b0;
               tlp_advance   <= avst_ready;
               tlp_end_hold  <= 8'h00;
            end
         end

         AVST128_DATA_STATE: begin
            if (tlp_val_r) begin
               if(|tlp_end_r & |tlp_end_shifted_n) begin
                  avst_valid <= 1'b1;
                  avst_sm <= AVST_START_STATE;
                  avst_eop   <= 1'b1;
                  avst_file_end <= tlp_file_end;
                  tlp_end_hold  <= 2'b00;
               end
               else begin
                  avst_valid <= 1'b1;
                  avst_sm <= AVST_DATA_STATE;
                  avst_eop      <= 1'b0;
                  avst_file_end <= 1'b0;
                  tlp_end_hold  <= tlp_end_r;
               end
            end
            else begin
               avst_valid <= 1'b0;
               avst_sm <= avst_sm;
               avst_eop      <= 1'b0;
               avst_file_end <= 1'b0;
            end

            avst_sop    <= 1'b0;
            tlp_advance   <= avst_ready;
            //----------------------------
            // avst data = 128 bit tlp data
            //----------------------------
            if (AVST_ADDR_ALIGN) begin
               case ({tlp_4dw_hdr_av, tlp_odd_dwaddr_av})
                  2'b11:   avst_data <= {tlp_data[95:0], 32'h0};
                  2'b10:   avst_data <= tlp_data[127:0];
                  2'b00:   avst_data <= tlp_data[127:0];
                  default: avst_data <= {tlp_data[31:0],tlp_data_hold[127:32]};
               endcase
            end
            else begin
               if (tlp_4dw_hdr_av) begin
                  avst_data <= tlp_data[127:0];
               end
               else begin
                  avst_data <= {tlp_data_shifted[31:0],tlp_data[127:32]};
               end
            end
         end

         AVST128_EXTRA_DATA_STATE: begin
            avst_sop    <= 1'b0;
            avst_valid  <= 1'b1;
            avst_eop      <= 1'b1;
            avst_file_end <= tlp_file_end;
            avst_sm       <= AVST_START_STATE;
            tlp_end_hold  <= 2'b00;
            tlp_advance   <= avst_ready;
            //----------------------------
            // avst data = 128 bit tlp data
            //----------------------------
            if (AVST_ADDR_ALIGN) begin
               case ({tlp_4dw_hdr_av, tlp_odd_dwaddr_av})
                  2'b11:   avst_data <= {tlp_data[95:0], 32'h0};
                  2'b10:   avst_data <= tlp_data[127:0];
                  2'b00:   avst_data <= tlp_data[127:0];
                  default: avst_data <= {tlp_data_shifted[31:0],tlp_data[127:32]};
               endcase
            end
            else begin
               if (tlp_4dw_hdr_av) begin
                  avst_data <= tlp_data[127:0];
               end
               else begin
                  avst_data <= {tlp_data_shifted[31:0],tlp_data[127:32]};
               end
            end
         end

         AVST_DATA_STATE: begin
            //----------------------
            // avst data format
            //----------------------
            avst_data <= tlp_data_shifted;
            //------------------------
            // avst conrol signals
            //------------------------
            avst_sop    <= 1'b0;
            avst_valid  <= tlp_val_r;
            if (|tlp_end_r & ~|tlp_end_shifted_n) begin      // rcving end of payload, but needs to be deferred to next cycle
               avst_eop          <= 1'b0;
               avst_file_end     <= 1'b0;
               avst_sm           <= AVST_EXTRA_DATA_STATE; // insert extra data cycle for deferred data
               tlp_end_hold      <= tlp_end_r;
               tlp_file_end_hold <= tlp_file_end;
               tlp_advance       <= avst_ready;
            end
            else if (|tlp_end_r) begin                      // rcving end of payload that can fit in current AVST cycle
               avst_eop      <= 1'b1;
               avst_file_end <= tlp_file_end;
               avst_sm       <= AVST_START_STATE;
               tlp_end_hold  <= tlp_end_r;  //8'h00;
               tlp_advance   <= avst_ready;
            end
            else begin                                    // not rcving end of payload
               avst_eop      <= 1'b0;
               avst_file_end <= 1'b0;
               avst_sm       <= AVST_DATA_STATE;
               tlp_end_hold  <= tlp_end_r;
               tlp_advance   <= avst_ready;
            end
         end

         AVST_EXTRA_DATA_STATE: begin
            // This state is required when Address alignment
            // causes an extra data cycle to be inserted into
            // the data stream.
            //----------------------
            // avst data format
            //----------------------
            avst_data <= tlp_data_shifted;
            //------------------------
            // avst conrol signals
            //------------------------
            avst_valid    <= 1'b1;
            avst_eop      <= 1'b1;
            avst_sop      <= 1'b0;
            avst_file_end <= tlp_file_end_hold;
            tlp_end_hold  <= 8'h00;
            tlp_advance   <= avst_ready;
            avst_sm       <= AVST_START_STATE;
         end
         default: begin
            avst_sm       <= AVST_START_STATE;
         end
      endcase // avst_sm
   end
end

endmodule  // altpcieav_dma_wr_tlpgen

