`timescale 1ns / 1ps
`include "iob_utils.vh"
`include "iob_axistream_out_conf.vh"
`include "iob_axistream_out_swreg_def.vh"

module iob_axistream_out #(
   `include "iob_axistream_out_params.vs"
) (
   `include "iob_axistream_out_io.vs"
);
   // FIFO Input width / Ouput width
   localparam N = 32 / TDATA_W;
   localparam RAM_ADDR_W = FIFO_DEPTH_LOG2 - $clog2(N);

   //Register File & Configuration control and status register file.
   `include "iob_axistream_out_swreg_inst.vs"

   //Synchronizers for the sw_regs
   wire axis_sw_rst;
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_rst (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(SOFT_RESET_wr),
      .signal_o(axis_sw_rst)
   );

   wire axis_sw_enable;
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_enable (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(ENABLE_wr),
      .signal_o(axis_sw_enable)
   );

   //FIFOs RAMs
   wire                  ext_mem_tdata_w_clk;
   wire [         N-1:0] ext_mem_tdata_w_en;
   wire [        32-1:0] ext_mem_tdata_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_tdata_w_addr;
   wire                  ext_mem_tdata_r_clk;
   wire [         N-1:0] ext_mem_tdata_r_en;
   wire [        32-1:0] ext_mem_tdata_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_tdata_r_addr;

   wire                  ext_mem_strb_w_clk;
   wire [         N-1:0] ext_mem_strb_w_en;
   wire [         N-1:0] ext_mem_strb_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_strb_w_addr;
   wire                  ext_mem_strb_r_clk;
   wire [         N-1:0] ext_mem_strb_r_en;
   wire [         N-1:0] ext_mem_strb_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_strb_r_addr;

   wire                  ext_mem_last_w_clk;
   wire [         N-1:0] ext_mem_last_w_en;
   wire [         N-1:0] ext_mem_last_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_last_w_addr;
   wire                  ext_mem_last_r_clk;
   wire [         N-1:0] ext_mem_last_r_en;
   wire [         N-1:0] ext_mem_last_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_last_r_addr;

   wire                  fifo_empty;
   wire                  tvalid_int;
   wire                  valid_data;
   //All FIFOs are read and write at the same time
   wire                  read_fifos = (axis_tready_i & axis_sw_enable) & ~fifo_empty;
   // Write if SWreg DATA enable or DMA valid
   wire                  write_fifos = DATA_wen_wr | tvalid_i;

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) tvalid_reg (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_tready_i & axis_sw_enable),
      .data_i(read_fifos),
      .data_o(valid_data)
   );

   //Mux between DMA tdata_i and SWreg iob_wdata_i
   wire [32-1:0] fifo_data_i = tvalid_i==1'b1 ? tdata_i : iob_wdata_i;

   wire [FIFO_DEPTH_LOG2+1-1:0] fifo_level;
   //DATA FIFO
   iob_fifo_async #(
      .W_DATA_W(DATA_W),
      .R_DATA_W(TDATA_W),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) data_fifo (
      .ext_mem_w_clk_o (ext_mem_tdata_w_clk),
      .ext_mem_w_en_o  (ext_mem_tdata_w_en),
      .ext_mem_w_addr_o(ext_mem_tdata_w_addr),
      .ext_mem_w_data_o(ext_mem_tdata_w_data),
      .ext_mem_r_clk_o (ext_mem_tdata_r_clk),
      .ext_mem_r_en_o  (ext_mem_tdata_r_en),
      .ext_mem_r_addr_o(ext_mem_tdata_r_addr),
      .ext_mem_r_data_i(ext_mem_tdata_r_data),
      //read port
      .r_clk_i         (axis_clk_i),
      .r_cke_i         (axis_cke_i),
      .r_arst_i        (axis_arst_i),
      .r_rst_i         (axis_sw_rst),
      .r_en_i          (read_fifos),
      .r_data_o        (axis_tdata_o),
      .r_empty_o       (fifo_empty),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (clk_i),
      .w_cke_i         (cke_i),
      .w_arst_i        (arst_i),
      .w_rst_i         (SOFT_RESET_wr),
      .w_en_i          (write_fifos),
      .w_data_i        (fifo_data_i),
      .w_empty_o       (),
      .w_full_o        (FULL_rd),
      .w_level_o       (fifo_level)
   );

   assign DATA_wready_wr = ~FULL_rd;

   // DMA tready_o signal
   assign tready_o = DATA_wready_wr;

   // Assign unused bits to zero
   assign FIFO_LEVEL_rd[32-1:(FIFO_DEPTH_LOG2+1)] = {(FIFO_DEPTH_LOG2+1){1'b0}};

   assign FIFO_LEVEL_rd[FIFO_DEPTH_LOG2+1-1:0] = fifo_level;

   assign fifo_threshold_o = FIFO_LEVEL_rd <= FIFO_THRESHOLD_wr;

   //WSTRB always set when received from DMA
   wire [N-1:0] wstrb_int = tvalid_i==1'b1 ? {N{1'b1}} : WSTRB_wr;

   iob_fifo_async #(
      .W_DATA_W(N),
      .R_DATA_W(1),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) strb_fifo (
      .ext_mem_w_clk_o (ext_mem_strb_w_clk),
      .ext_mem_w_en_o  (ext_mem_strb_w_en),
      .ext_mem_w_addr_o(ext_mem_strb_w_addr),
      .ext_mem_w_data_o(ext_mem_strb_w_data),
      .ext_mem_r_clk_o (ext_mem_strb_r_clk),
      .ext_mem_r_en_o  (ext_mem_strb_r_en),
      .ext_mem_r_addr_o(ext_mem_strb_r_addr),
      .ext_mem_r_data_i(ext_mem_strb_r_data),
      //read port
      .r_clk_i         (axis_clk_i),
      .r_cke_i         (axis_cke_i),
      .r_arst_i        (axis_arst_i),
      .r_rst_i         (axis_sw_rst),
      .r_en_i          (read_fifos),
      .r_data_o        (tvalid_int),
      .r_empty_o       (),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (clk_i),
      .w_cke_i         (cke_i),
      .w_arst_i        (arst_i),
      .w_rst_i         (SOFT_RESET_wr),
      .w_en_i          (write_fifos),
      .w_data_i        (wstrb_int),
      .w_empty_o       (),
      .w_full_o        (),
      .w_level_o       ()
   );

   assign axis_tvalid_o = (tvalid_int & valid_data) & axis_sw_enable;

   wire [`IOB_MAX($clog2(N),1)-1:0] last_pos;
   generate
      if (N>1) begin: gen_prio_enc
         //Priority encoder to find the position of the last valid bit in the WSTRB
         iob_prio_enc #(
            .W   (N),
            .MODE("HIGH")
         ) prio_enc (
            .unencoded_i(WSTRB_wr),
            .encoded_o  (last_pos)
         );
      end
      else
         assign last_pos = 1'b0;
   endgenerate

   //LAST needs to be shifted according to the WSTRB before being inserted into the FIFO
   wire [N-1:0] tlast_int = ({N{1'd0}} | LAST_wr) << last_pos;
   //LAST always disabled when received from DMA
   wire [N-1:0] tlast_int2 = tvalid_i==1'b1 ? {N{1'b0}} : tlast_int;

   iob_fifo_async #(
      .W_DATA_W(N),
      .R_DATA_W(1),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) last_fifo (
      .ext_mem_w_clk_o (ext_mem_last_w_clk),
      .ext_mem_w_en_o  (ext_mem_last_w_en),
      .ext_mem_w_addr_o(ext_mem_last_w_addr),
      .ext_mem_w_data_o(ext_mem_last_w_data),
      .ext_mem_r_clk_o (ext_mem_last_r_clk),
      .ext_mem_r_en_o  (ext_mem_last_r_en),
      .ext_mem_r_addr_o(ext_mem_last_r_addr),
      .ext_mem_r_data_i(ext_mem_last_r_data),
      //read port
      .r_clk_i         (axis_clk_i),
      .r_cke_i         (axis_cke_i),
      .r_arst_i        (axis_arst_i),
      .r_rst_i         (axis_sw_rst),
      .r_en_i          (read_fifos),
      .r_data_o        (axis_tlast_o),
      .r_empty_o       (),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (clk_i),
      .w_cke_i         (cke_i),
      .w_arst_i        (arst_i),
      .w_rst_i         (SOFT_RESET_wr),
      .w_en_i          (write_fifos),
      .w_data_i        (tlast_int2),
      .w_empty_o       (),
      .w_full_o        (),
      .w_level_o       ()
   );


   //FIFOs RAMs
   genvar p;
   generate
      for (p = 0; p < N; p = p + 1) begin : gen_fifo_ram
         iob_ram_t2p #(
            .DATA_W(TDATA_W),
            .ADDR_W(RAM_ADDR_W)
         ) tdata_fifo_ram_t2p (
            .w_clk_i (ext_mem_tdata_w_clk),
            .w_en_i  (ext_mem_tdata_w_en[p]),
            .w_addr_i(ext_mem_tdata_w_addr),
            .w_data_i(ext_mem_tdata_w_data[p*TDATA_W+:TDATA_W]),
            .r_clk_i (ext_mem_tdata_r_clk),
            .r_en_i  (ext_mem_tdata_r_en[p]),
            .r_addr_i(ext_mem_tdata_r_addr),
            .r_data_o(ext_mem_tdata_r_data[p*TDATA_W+:TDATA_W])
         );

         iob_ram_t2p #(
            .DATA_W(1),
            .ADDR_W(RAM_ADDR_W)
         ) strb_fifo_ram_t2p (
            .w_clk_i (ext_mem_strb_w_clk),
            .w_en_i  (ext_mem_strb_w_en[p]),
            .w_addr_i(ext_mem_strb_w_addr),
            .w_data_i(ext_mem_strb_w_data[p]),
            .r_clk_i (ext_mem_strb_r_clk),
            .r_en_i  (ext_mem_strb_r_en[p]),
            .r_addr_i(ext_mem_strb_r_addr),
            .r_data_o(ext_mem_strb_r_data[p])
         );

         iob_ram_t2p #(
            .DATA_W(1),
            .ADDR_W(RAM_ADDR_W)
         ) last_fifo_ram_2p (
            .w_clk_i (ext_mem_last_w_clk),
            .w_en_i  (ext_mem_last_w_en[p]),
            .w_addr_i(ext_mem_last_w_addr),
            .w_data_i(ext_mem_last_w_data[p]),
            .r_clk_i (ext_mem_last_r_clk),
            .r_en_i  (ext_mem_last_r_en[p]),
            .r_addr_i(ext_mem_last_r_addr),
            .r_data_o(ext_mem_last_r_data[p])
         );
      end
   endgenerate

endmodule


