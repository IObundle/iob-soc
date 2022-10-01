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

module altpcieav_dma_hprxm # (
      parameter dma_use_scfifo_ext   = 0,
      parameter AVMM_WIDTH           = 256,
      parameter DMA_BRST_CNT_W       = 6,
      parameter HPRXM_BAR_TYPE       = 64,
      parameter BAR2_SIZE_MASK       = 20
   ) (
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
      input  logic [AVMM_WIDTH-1:0]                HPRxmReadData_i,
      input  logic                                 HPRxmReadDataValid_i,

     // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [265:0]                         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,

      // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [259:0]                         TxFifoData_o,
      input  logic [3:0]                           TxFifoCount_i,

  //  Arbiter Interface
      input  logic [3:0]                           SideFifoCount_i,
      output logic                                 HPRxmArbReq_o,
      input logic                                  HPRxmArbGranted_i,
  /// CFG
      input logic   [31:0]                         DevCsr_i,
      input logic   [12:0]                         BusDev_i
  );


    logic         [56:0]                           pending_read_fifo_data;
    logic                                          pending_read_fifo_wrreq;
    logic         [3:0]                            pending_read_fifo_count;
    logic                                          pending_read_fifo_empty;
    logic                                          pending_read_fifo_rdreq;


    logic         [98:0]                           cmd_fifo_data;
    logic                                          cmd_fifo_wrreq;
    logic         [4 :0]                           cmd_fifo_count;
    logic         [8:0]                            cpl_ram_wr_addr;
    logic         [8:0]                            cpl_ram_rd_addr;
    logic         [255:0]                          cpl_ram_data_q;
    logic         [98:0]                           cmd_fifo_q;
    logic         [56:0]                           pending_read_fifo_q;
    logic         [7:0]                            read_burstcount_fifo_out;
    logic                                          read_burstcount_fifo_rdreq;
    logic                                          cmd_fifo_rdreq;


 altpcieav_dma_hprxm_rdwr

  #(
       .AVMM_WIDTH(AVMM_WIDTH),
       .HPRXM_BAR_TYPE(HPRXM_BAR_TYPE),
       .BAR2_SIZE_MASK(BAR2_SIZE_MASK)
   )
  hprxm_pcie_rdwr
   (
       .Clk_i(Clk_i),
       .Rstn_i(Rstn_i),
       .HPRxmWrite_o(HPRxmWrite_o),
       .HPRxmAddress_o(HPRxmAddress_o),
       .HPRxmWriteData_o(HPRxmWriteData_o),
       .HPRxmByteEnable_o(HPRxmByteEnable_o),
       .HPRxmBurstCount_o(HPRxmBurstCount_o),
       .HPRxmWaitRequest_i(HPRxmWaitRequest_i),
       .HPRxmRead_o(HPRxmRead_o),
       .RxFifoRdReq_o(RxFifoRdReq_o),
       .RxFifoDataq_i(RxFifoDataq_i),
       .RxFifoCount_i(RxFifoCount_i),
       .PndgRdHeader_o(pending_read_fifo_data),
       .PndgRdFifoWrReq_o(pending_read_fifo_wrreq),
       .PndgRdFifoCount_i(pending_read_fifo_count),
       .ReadBcntFifoRdreq_i(read_burstcount_fifo_rdreq),
       .ReadBcntFifoq_o(read_burstcount_fifo_out),
       .LastTxCplSent_i(read_burstcount_fifo_rdreq)

   );


  altpcieav_dma_hprxm_cpl
  # (
      .AVMM_WIDTH(AVMM_WIDTH)
   )
    hprxm_avl_cpl
     (
        .Clk_i(Clk_i),
        .Rstn_i(Rstn_i),
        .PndgRdFifoEmpty_i(pending_read_fifo_empty),
        .PndgRdFifoDato_i(pending_read_fifo_q),
        .PndgRdFifoRdReq_o(pending_read_fifo_rdreq),
        .HPRxmReadDataValid_i(HPRxmReadDataValid_i),
        .CmdFifoDatin_o(cmd_fifo_data),
        .CmdFifoWrReq_o(cmd_fifo_wrreq),
        .CmdFifoUsedw_i(cmd_fifo_count),
        .CplRamWrAddr_o(cpl_ram_wr_addr),
        .DevCsr_i(DevCsr_i)
     );

 altpcieav_dma_hprxm_txctrl
  #(
     .AVMM_WIDTH(AVMM_WIDTH)
    )

    hprxm_pcie_txctrl
      (
          .Clk_i(Clk_i),
          .Rstn_i(Rstn_i),
          .CmdFifoDat_i(cmd_fifo_q),
          .CmdFifoCount_i(cmd_fifo_count),
          .CmdFifoRdReq_o(cmd_fifo_rdreq),
          .CplBuffRdAddr_o(cpl_ram_rd_addr),
          .TxCplDat_i(cpl_ram_data_q),
          .TxFifoWrReq_o(TxFifoWrReq_o),
          .TxFifoData_o(TxFifoData_o),
          .TxFifoCount_i(TxFifoCount_i),
          .SideFifoCount_i(SideFifoCount_i),
          .HpRxmArbReq_o(HPRxmArbReq_o),
          .HpRxmArbGranted_i(HPRxmArbGranted_i),
          .ReadBcntFifoRdreq_o(read_burstcount_fifo_rdreq),
          .ReadBcntFifoq_i(read_burstcount_fifo_out),
          .BusDev_i(BusDev_i)
      );

 //// Pending Read FIFO
   generate begin : g_pndgtxrd_fifo
      if (dma_use_scfifo_ext==1) begin
         altpcie_a10_scfifo_ext       # (
            .add_ram_output_register    ("ON"          ),
            .intended_device_family     ("Stratix IV"  ),
            .lpm_numwords               (16            ),
            .lpm_showahead              ("OFF"         ),
            .lpm_type                   ("scfifo"      ),
            .lpm_width                  (57            ),
            .lpm_widthu                 (4             ),
            .overflow_checking          ("OFF"         ),
            .underflow_checking         ("OFF"         ),
            .use_eab                    ("ON"          )
          ) pndgtxrd_fifo               (
                     .rdreq             (pending_read_fifo_rdreq),
                     .clock             (Clk_i),
                     .wrreq             (pending_read_fifo_wrreq),
                     .data              (pending_read_fifo_data),
                     .usedw             (pending_read_fifo_count[3:0]),
                     .empty             (pending_read_fifo_empty),
                     .q                 (pending_read_fifo_q),
                     .full              () ,
                     .aclr              (~Rstn_i),
                     .almost_empty      (),
                     .almost_full       (),
                     .sclr              (1'b0)
           );
      end
      else if (dma_use_scfifo_ext==2) begin
         altpcie_sv_scfifo_ext       # (
            .add_ram_output_register    ("ON"          ),
            .intended_device_family     ("Stratix V"   ),
            .lpm_numwords               (16            ),
            .lpm_showahead              ("OFF"         ),
            .lpm_type                   ("scfifo"      ),
            .lpm_width                  (57            ),
            .lpm_widthu                 (4             ),
            .overflow_checking          ("OFF"         ),
            .underflow_checking         ("OFF"         ),
            .use_eab                    ("ON"          )
          ) pndgtxrd_fifo               (
                     .rdreq             (pending_read_fifo_rdreq),
                     .clock             (Clk_i),
                     .wrreq             (pending_read_fifo_wrreq),
                     .data              (pending_read_fifo_data),
                     .usedw             (pending_read_fifo_count[3:0]),
                     .empty             (pending_read_fifo_empty),
                     .q                 (pending_read_fifo_q),
                     .full              () ,
                     .aclr              (~Rstn_i),
                     .almost_empty      (),
                     .almost_full       (),
                     .sclr              (1'b0)
           );
      end
      else begin
         scfifo                        #(
            .add_ram_output_register    ("ON"          ),
            .intended_device_family     ("Stratix IV"  ),
            .lpm_numwords               (16            ),
            .lpm_showahead              ("OFF"         ),
            .lpm_type                   ("scfifo"      ),
            .lpm_width                  (57            ),
            .lpm_widthu                 (4             ),
            .overflow_checking          ("OFF"         ),
            .underflow_checking         ("OFF"         ),
            .use_eab                    ("ON"          )
          ) pndgtxrd_fifo               (
                     .rdreq             (pending_read_fifo_rdreq),
                     .clock             (Clk_i),
                     .wrreq             (pending_read_fifo_wrreq),
                     .data              (pending_read_fifo_data),
                     .usedw             (pending_read_fifo_count[3:0]),
                     .empty             (pending_read_fifo_empty),
                     .q                 (pending_read_fifo_q),
                     .full              () ,
                     .aclr              (~Rstn_i),
                     .almost_empty      (),
                     .almost_full       (),
                     .sclr              (1'b0)
           );
      end
   end
   endgenerate

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


        tx_cpl_buff (
                                        .wren_a (HPRxmReadDataValid_i),
                                        .clocken1 (),
                                        .clock0 (Clk_i),
                                        .clock1 (),
                                        .address_a (cpl_ram_wr_addr),
                                        .address_b (cpl_ram_rd_addr),
                                        .data_a (HPRxmReadData_i),
                                        .q_b (cpl_ram_data_q),
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


/// command FIFO
   altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(99)
    )
 txcpl_cmd_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(cmd_fifo_wrreq),
      .rdreq(cmd_fifo_rdreq),
      .data(cmd_fifo_data),
      .q(cmd_fifo_q),
      .fifo_count(cmd_fifo_count)
);

endmodule
