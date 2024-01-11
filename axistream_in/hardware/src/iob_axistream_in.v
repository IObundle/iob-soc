`timescale 1ns / 1ps
`include "iob_utils.vh"
`include "iob_axistream_in_conf.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in #(
   `include "iob_axistream_in_params.vs"
) (
   `include "iob_axistream_in_io.vs"
);

   //
   // Connection wires
   //
   `include "iob_wire.vs"

   //rst and enable synced to axis_clk
   wire                   axis_sw_rst;
   wire                   axis_sw_enable;

   //fifo write
   wire                   axis_fifo_write;
   wire                   axis_fifo_full;

   //tlast detected
   wire                   axis_tlast;
   wire                   axis_tlast_detected;

   //word counter
   wire [     DATA_W-1:0] axis_word_count;
   wire                   axis_word_count_en;


   //fifo read
   reg                    fifo_read;
   wire [     DATA_W-1:0] fifo_data;

   //fifo RAM
   wire                   ext_mem_w_clk;
   wire                   ext_mem_w_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_w_addr;
   wire [     DATA_W-1:0] ext_mem_w_data;
   wire                   ext_mem_r_clk;
   wire                   ext_mem_r_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_r_addr;
   wire [     DATA_W-1:0] ext_mem_r_data;

   reg                    dma_tvalid;

   // configuration control and status register file.
   `include "iob_axistream_in_swreg_inst.vs"

   //connect iob signals to ports
   assign iob_valid      = iob_valid_i;
   assign iob_addr       = iob_addr_i;
   assign iob_wdata      = iob_wdata_i;
   assign iob_wstrb      = iob_wstrb_i;
   assign iob_rvalid_o   = iob_rvalid;
   assign iob_rdata_o    = iob_rdata;
   assign iob_ready_o    = iob_ready;

   //AXI Stream input interface
   assign axis_tready_o  = ~axis_fifo_full & axis_sw_enable;

   //CPU INTERFACE
   assign DATA_rready_rd = ~FIFO_EMPTY_rd;
   assign interrupt_o    = FIFO_LEVEL_rd >= FIFO_THRESHOLD_wr;
   assign DATA_rvalid_rd = dma_tvalid;

   //DMA Stream output interface
   assign dma_tvalid_o   = dma_tvalid;
   assign dma_tdata_o    = fifo_data;

   //FIFO read
   wire axis_pc;
   reg  axis_pc_nxt;
   always @* begin
      axis_pc_nxt = axis_pc + 1'b1;
      fifo_read   = 1'b0;
      dma_tvalid  = 1'b0;

      case (axis_pc)
         0: begin
            if (FIFO_EMPTY_rd) begin
               axis_pc_nxt = axis_pc;
            end else begin
               fifo_read = 1'b1;
            end
         end
         default: begin
            dma_tvalid  = 1'b1;
            axis_pc_nxt = axis_pc;
            if (dma_tready_i | DATA_ren_rd) begin
               if (FIFO_EMPTY_rd) begin
                  axis_pc_nxt = 1'b0;
               end else begin
                  fifo_read = 1'b1;
               end
            end
         end
      endcase
   end


   //tlast 
   assign axis_tlast         = axis_tlast_i & axis_tvalid_i;

   //FIFO write
   assign axis_fifo_write    = axis_tvalid_i & axis_tready_o;

   //word count enable
   assign axis_word_count_en = axis_fifo_write & ~axis_tlast_detected;

   //FIFO read program counter
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) axis_pc_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_sw_enable),
      .data_i(axis_pc_nxt),
      .data_o(axis_pc)
   );

   //FIFO data register
   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) fifo_data_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(fifo_data),
      .data_o(DATA_rdata_rd)
   );

   // received words counter
   iob_counter #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) word_count_inst (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_word_count_en),
      .data_o(axis_word_count)
   );


   //Synchronizers from clk (swregs) to axis domain
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_rst (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(SOFT_RESET_wr),
      .signal_o(axis_sw_rst)
   );

   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_enable (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(ENABLE_wr),
      .signal_o(axis_sw_enable)
   );

   //Synchronizers from axis to clk domain (sw_regs)
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) tlast_detected_sync (
      .clk_i   (clk_i),
      .arst_i  (arst_i),
      .signal_i(axis_tlast_detected),
      .signal_o(TLAST_DETECTED_rd)
   );

   iob_sync #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) word_counter_sync (
      .clk_i   (clk_i),
      .arst_i  (arst_i),
      .signal_i(axis_word_count),
      .signal_o(NWORDS_rd)
   );

   //tlast detection
   iob_edge_detect #(
      .EDGE_TYPE("rising"),
      .OUT_TYPE ("step")
   ) tlast_detect (
      .clk_i     (axis_clk_i),
      .cke_i     (axis_cke_i),
      .arst_i    (axis_arst_i),
      .rst_i     (axis_sw_rst),
      .bit_i     (axis_tlast),
      .detected_o(axis_tlast_detected)
   );

   //fifo memory
   iob_ram_t2p #(
      .DATA_W(DATA_W),
      .ADDR_W(FIFO_ADDR_W)
   ) iob_ram_t2p (
      .w_clk_i (ext_mem_w_clk),
      .w_en_i  (ext_mem_w_en),
      .w_addr_i(ext_mem_w_addr),
      .w_data_i(ext_mem_w_data),

      .r_clk_i (ext_mem_r_clk),
      .r_en_i  (ext_mem_r_en),
      .r_addr_i(ext_mem_r_addr),
      .r_data_o(ext_mem_r_data)
   );

   //async fifo
   iob_fifo_async #(
      .W_DATA_W(TDATA_W),
      .R_DATA_W(DATA_W),
      .ADDR_W  (FIFO_ADDR_W)
   ) data_fifo (
      .ext_mem_w_clk_o (ext_mem_w_clk),
      .ext_mem_w_en_o  (ext_mem_w_en),
      .ext_mem_w_addr_o(ext_mem_w_addr),
      .ext_mem_w_data_o(ext_mem_w_data),
      .ext_mem_r_clk_o (ext_mem_r_clk),
      .ext_mem_r_en_o  (ext_mem_r_en),
      .ext_mem_r_addr_o(ext_mem_r_addr),
      .ext_mem_r_data_i(ext_mem_r_data),
      //read port (sys clk domain)
      .r_clk_i         (clk_i),
      .r_cke_i         (cke_i),
      .r_arst_i        (arst_i),
      .r_rst_i         (SOFT_RESET_wr),
      .r_en_i          (fifo_read),
      .r_data_o        (fifo_data),
      .r_empty_o       (FIFO_EMPTY_rd),
      .r_full_o        (FIFO_FULL_rd),
      .r_level_o       (FIFO_LEVEL_rd),
      //write port (axis clk domain)
      .w_clk_i         (axis_clk_i),
      .w_cke_i         (axis_cke_i),
      .w_arst_i        (axis_arst_i),
      .w_rst_i         (axis_sw_rst),
      .w_en_i          (axis_fifo_write),
      .w_data_i        (axis_tdata_i),
      .w_empty_o       (),
      .w_full_o        (axis_fifo_full),
      .w_level_o       ()
   );

endmodule



