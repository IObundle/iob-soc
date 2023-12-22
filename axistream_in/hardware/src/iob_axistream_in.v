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

   //rst and enble synced to axis_clk
   wire                 axis_sw_rst;
   wire                 axis_sw_enable;
   
   //FIFO-memory connections
   wire                 ext_mem_w_clk;
   wire                 ext_mem_w_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_tdata_w_addr;
   wire [DATA_W-1:0]      ext_mem_w_data;
   wire                   ext_mem_tdata_r_clk;
   wire                   ext_mem_tdata_r_en;
   wire [FIFO_ADDR_W-1:0] ext_mem_tdata_r_addr;
   wire                   ext_mem_tdata_r_data;

   //fifo write
   reg                    fifo_write;

   //fifo read
   wire                   fifo_read;
   reg                    pcounter, pcounter_nxt;

   //word counter
   wire [DATA_W-1:0]      word_count;
   
   //connect iob signals to ports
   assign iob_valid = iob_valid_i;
   assign iob_addr = iob_addr_i;
   assign iob_wdata = iob_wdata_i;
   assign iob_wstrb = iob_wstrb_i;
   assign iob_rvalid_o = iob_rvalid;
   assign iob_rdata_o = iob_rdata;
   assign iob_ready_o = iob_ready;


   //CPU data ready and interrupt
   assign DATA_rready_rd = ~FIFO_EMPTY_rd;
   assign interrupt_o = FIFO_LEVEL_rd >= FIFO_THRESHOLD_wr;
   

   //FIFO write
   assign fifo_read = (DATA_ren_rd | dma_ready_i) & ~FIFO_EMPTY_rd;
 
   //FIFO write
   always @* begin
      pc_counter_nxt = pc_counter+1'b1;
      axis_fifo_read = 1'b0;
      
      if (pc_counter == 0) begin
         if (axis_fifo_empty) begin
            pc_counter_nxt = pc_counter;
         end else begin
            axis_fifo_read = 1'b1;
         end
      end else begin
         if (!tready_i) begin
            pc_counter_nxt = pc_counter;
         end else if (axis_fifo_empty) begin
               pc_counter_nxt = 0;
         end else begin
            axis_fifo_read = 1'b1;
         end
      end
   end


   //AXI stream
   assign axis_tdata_o = axis_data[TDATA_W-1:0];
   assign axis_tvalid_o = axis_fifo_read_q;
   assign axis_tlast_o = (axis_fifo_level == word_count) & axis_tvalid_o;


   //
   // Submodules
   //

   // configuration control and status register file.
`include "iob_axistream_in_swreg_inst.vs"
   
   // fifo read register
   iob_reg_re #(
                .DATA_W (1),
                .RST_VAL(1'd0)
                ) tvalid_reg (
                              .clk_i (axis_clk_i),
                              .cke_i (axis_cke_i),
                              .arst_i(axis_arst_i),
                              .rst_i (axis_sw_rst),
                              .en_i  (axis_sw_enable),
                              .data_i(axis_fifo_read),
                              .data_o(fifo_read_q)
                              );

   // program counter
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



   iob_counter #(
                 .DATA_W (FIFO_ADDR_W),
                 .RST_VAL(0)
                 ) word_count_inst (
                                    .clk_i (axis_clk_i),
                                    .cke_i (axis_sw_enable),
                                    .arst_i(axis_arst_i),
                                    .rst_i (axis_sw_rst),
                                    .en_i  (axis_fifo_read_q),
                                    .data_o(word_count)
                                    );

   
   //Synchronizers from sw_regs to axis domain
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

   //DATA FIFO
   iob_fifo_async #(
                    .W_DATA_W(DATA_W+WSTRB_W+2),
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
                                 .r_clk_i         (clk_i),
                                 .r_cke_i         (cke_i),
                                 .r_arst_i        (arst_i),
                                 .w_rst_i         (SOFT_RESET_wr),
                                 .r_en_i          (fifo_read),
                                 .r_data_o        (DATA_rdata_rd),
                                 .r_empty_o       (EMPTY_rd),
                                 .r_full_o        (FULL_rd),
                                 .r_level_o       (fifo_level),
                                 //write port
                                 .w_clk_i         (axis_clk_i),
                                 .w_cke_i         (axis_cke_i),
                                 .w_arst_i        (axis_arst_i),
                                 .r_rst_i         (axis_sw_rst),
                                 .w_en_i          (axis_tvalid_i),
                                 .w_data_i        (axis_tdata_i),
                                 .w_empty_o       (),
                                 .w_full_o        (axis_fifo_full),
                                 .w_level_o       (),
                                 );
   
   iob_ram_t2p #(
                 .DATA_W(TDATA_W),
                 .ADDR_W(RAM_ADDR_W)
                 ) tdata_fifo_ram_t2p (
                                       .w_clk_i (ext_mem_tdata_w_clk),
                                       .w_en_i  (ext_mem_tdata_w_en),
                                       .w_addr_i(ext_mem_tdata_w_addr),
                                       .w_data_i(ext_mem_tdata_w_data),
                                       .r_clk_i (ext_mem_tdata_r_clk),
                                       .r_en_i  (ext_mem_tdata_r_en),
                                       .r_addr_i(ext_mem_tdata_r_addr),
                                       .r_data_o(ext_mem_tdata_r_data)
                                       );
   
endmodule



