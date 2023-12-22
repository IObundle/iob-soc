`timescale 1ns / 1ps
`include "iob_utils.vh"
`include "iob_axistream_out_conf.vh"
`include "iob_axistream_out_swreg_def.vh"

module iob_axistream_out #(
   `include "iob_axistream_out_params.vs"
) (
   `include "iob_axistream_out_io.vs"
);

   localparam WSTRB_W = DATA_W / 8;   
   localparam RATIO = DATA_W / TDATA_W;
   localparam FIFO_DATA_W = TDATA_W * N;

   //
   // Configuration control and status register file.
   //
   `include "iob_wire.vs"

   assign iob_valid = iob_valid_i;
   assign iob_addr = iob_addr_i;
   assign iob_wdata = iob_wdata_i;
   assign iob_wstrb = iob_wstrb_i;
   assign iob_rvalid_o = iob_rvalid;
   assign iob_rdata_o = iob_rdata;
   assign iob_ready_o = iob_ready;
   `include "iob_axistream_out_swreg_inst.vs"

   //Synchronizers from sw_regs to axis domain
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
   wire ext_mem_w_clk;
   wire ext_mem_w_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_tdata_w_addr;
   wire [DATA_W-1:0]      ext_mem_w_data;
   wire                   ext_mem_tdata_r_clk;
   wire                   ext_mem_tdata_r_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_tdata_r_addr;
   wire                   ext_mem_tdata_r_data;

   //FIFO write
   wire                  write_fifo;
   assign write_fifo = DATA_wen_wr | dma_tvalid_i;

   //FIFO read
   reg                   read_fifo, tvalid_int;
   reg                   pcounter, pcounter_nxt;
   
   //program counter
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) tvalid_reg (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_sw_enable),
      .data_i(pc_counter_nxt),
      .data_o(pc_counter),
   );

   //tvalid compute program
   always @* begin
      pc_counter_nxt = pc_counter+1'b1;
      read_fifo = 1'b0;
      tvalid_int = 1'b0;
      
      if (pc_counter = 1'b1) begin
         if (fifo_empty) begin
            pc_counter_nxt = pc_counter;
         end else begin
            read_fifo = 1'b1;
         end
      else begin
         if (!tready_i) begin
            pc_counter_nxt = pc_counter;
         end else if (fifo_empty) begin
            pc_counter_nxt = 0;
         end else begin
            tvalid_int = 1'b1;
         end
      end


   end

   //Mux CPU and DMA data
   wire [DATA_W-1:0]     cpu_data, dma_data;

   genvar i;
   generate
      for (i=0, i < RATIO, i=i+1) begin : wstrb_mux
         assign cpu_data[i*10 +: 10] = {DATA_wstrb_wr[i], DATA_wdata_wr[i*8 +: 8], tlast};
         assign dma_data[i*10 +: 10] = {dma_tstrb_i[i], dma_tdata_i[i*8 +: 8], tlast};
      end
   endgenerate

   wire [DATA_W-1:0] fifo_wdata;
   assign fifo_wdata = dma_tvalid_i==1'b1 ? dma_tdata_i : iob_wdata_i;

   wire [WSTRB_W-1:0] fifo_wstrb;
   assign fifo_wstrb = dma_tvalid_i==1'b1 ? dma_tstrb_i : iob_wstrb_i;

   wire [FIFO_ADDR_W:0] fifo_level;
   assign fifo_level = FIFO_LEVEL_rd;

   wire word_count;
   iob_counter #(
      .DATA_W (FIFO_ADDR_W),
      .RST_VAL(0)
   ) word_count_inst (
      .clk_i (axis_clk_i),
      .cke_i  (axis_sw_enable),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (fifo_read),
      .data_o(word_count)
   );

   wire tlast;
   assign tlast = fifo_level == word_count;
   
   //DATA FIFO
   iob_fifo_async #(
      .W_DATA_W(DATA_W+WSTRB_W+1),
      .R_DATA_W(TDATA_W+2),
      .ADDR_W  (FIFO_ADDR_W),
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
      .r_en_i          (read_fifo),
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
      .w_level_o       (fifo_level),
   );

   assign DATA_wready_wr = ~FULL_rd;

   // DMA tready_o signal
   assign dma_tready_o =  ~FULL_rd;

   assign fifo_threshold_o = FIFO_LEVEL_rd <= FIFO_THRESHOLD_wr;

endmodule


