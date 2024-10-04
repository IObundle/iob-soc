// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps
`include "iob_axistream_out_conf.vh"
`include "iob_axistream_out_csrs_def.vh"

module iob_axistream_out #(
   `include "iob_axistream_out_params.vs"
) (
   `include "iob_axistream_out_io.vs"
);

   localparam R = DATA_W / TDATA_W;
   localparam RAM_ADDR_W = FIFO_ADDR_W - $clog2(R);

   //rst and enble synced to axis_clk
   wire                  axis_sw_rst;
   wire                  axis_sw_enable;

   //fifo write
   wire                  fifo_write;
   wire [    DATA_W-1:0] fifo_wdata;

   //fifo read
   wire                  axis_fifo_empty;
   reg                   axis_fifo_read;
   wire                  axis_pc;
   reg                   axis_pc_nxt;
   wire [   TDATA_W-1:0] axis_tdata;
   reg                   axis_tvalid;

   //word counter
   wire [    DATA_W-1:0] axis_word_count;
   wire [    DATA_W-1:0] axis_nwords;

   //fifo ram
   wire                  ext_mem_w_clk;
   wire [         R-1:0] ext_mem_w_en;
   wire [RAM_ADDR_W-1:0] ext_mem_w_addr;
   wire [    DATA_W-1:0] ext_mem_w_data;
   wire                  ext_mem_r_clk;
   wire [         R-1:0] ext_mem_r_en;
   wire [RAM_ADDR_W-1:0] ext_mem_r_addr;
   wire [    DATA_W-1:0] ext_mem_r_data;

   `include "iob_axistream_out_wires.vs"

   // configuration control and status register file.
   `include "iob_axistream_out_blocks.vs"

   //AXI Stream interface
   assign axis_tvalid_o = axis_tvalid;
   assign axis_tdata_o = axis_tdata;
   assign axis_tlast_o = (axis_word_count == axis_nwords) & axis_tvalid_o;

   //CPU interface
   assign data_wready_wr = ~fifo_full_rd;
   assign interrupt_o = fifo_level_rd <= fifo_threshold_wr;

   //DMA data ready
   assign sys_tready_o = ~fifo_full_rd & axis_sw_enable & (mode_wr == 1'b1);

   //FIFO write
   assign fifo_write     = ((data_wen_wr & (mode_wr == 1'b0)) |
                           (sys_tvalid_i & (mode_wr == 1'b1))) &
                           axis_sw_enable;
   assign fifo_wdata = sys_tvalid_i == 1'b1 ? sys_tdata_i : data_wdata_wr;

   //FIFO read
   always @* begin
      axis_pc_nxt    = axis_pc + 1'b1;
      axis_fifo_read = 1'b0;
      axis_tvalid    = 1'b0;

      case (axis_pc)
         0: begin
            if (axis_fifo_empty) begin
               axis_pc_nxt = axis_pc;
            end else begin
               axis_fifo_read = 1'b1;
            end
         end
         default: begin
            if (axis_word_count <= axis_nwords) begin  // Not in padding
               axis_tvalid = axis_sw_enable;
               axis_pc_nxt = axis_pc;
               if (axis_tready_i && axis_sw_enable) begin
                  if (axis_fifo_empty) begin
                     axis_pc_nxt = 1'b0;
                  end else begin
                     axis_fifo_read = 1'b1;
                  end
               end
            end else begin  // In padding bytes (read them whithout tvalid and not waiting for tready)
               if (axis_fifo_empty) begin
                  axis_pc_nxt = 1'b0;
               end else begin
                  axis_pc_nxt    = axis_pc;
                  axis_fifo_read = 1'b1;
               end
            end
         end
      endcase
   end

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
      .data_i(axis_pc_nxt),
      .data_o(axis_pc)
   );

   // sent words counter
   iob_counter #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) word_count_inst (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_fifo_read),
      .data_o(axis_word_count)
   );


   //Synchronizers from sw_regs to axis domain
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_rst (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(soft_reset_wr),
      .signal_o(axis_sw_rst)
   );

   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_enable (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(enable_wr),
      .signal_o(axis_sw_enable)
   );

   iob_sync #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) fifo_threshold (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(nwords_wr),
      .signal_o(axis_nwords)
   );

   //FIFOs RAMs
   genvar p;
   generate
      for (p = 0; p < R; p = p + 1) begin : gen_fifo_ram
         // fifo memories
         iob_ram_at2p #(
            .DATA_W(TDATA_W),
            .ADDR_W(RAM_ADDR_W)
         ) iob_ram_at2p (
            .w_clk_i (ext_mem_w_clk),
            .w_en_i  (ext_mem_w_en[p]),
            .w_addr_i(ext_mem_w_addr),
            .w_data_i(ext_mem_w_data[p*TDATA_W+:TDATA_W]),

            .r_clk_i (ext_mem_r_clk),
            .r_en_i  (ext_mem_r_en[p]),
            .r_addr_i(ext_mem_r_addr),
            .r_data_o(ext_mem_r_data[p*TDATA_W+:TDATA_W])
         );
      end
   endgenerate

   //async fifo
   iob_fifo_async #(
      .W_DATA_W(DATA_W),
      .R_DATA_W(TDATA_W),
      .ADDR_W  (FIFO_ADDR_W)
   ) data_fifo (
      //memory write port
      .ext_mem_w_clk_o (ext_mem_w_clk),
      .ext_mem_w_en_o  (ext_mem_w_en),
      .ext_mem_w_addr_o(ext_mem_w_addr),
      .ext_mem_w_data_o(ext_mem_w_data),
      //memory read port
      .ext_mem_r_clk_o (ext_mem_r_clk),
      .ext_mem_r_en_o  (ext_mem_r_en),
      .ext_mem_r_addr_o(ext_mem_r_addr),
      .ext_mem_r_data_i(ext_mem_r_data),
      //read port (axis clk domain)
      .r_clk_i         (axis_clk_i),
      .r_cke_i         (axis_cke_i),
      .r_arst_i        (axis_arst_i),
      .r_rst_i         (axis_sw_rst),
      .r_en_i          (axis_fifo_read),
      .r_data_o        (axis_tdata),
      .r_empty_o       (axis_fifo_empty),
      .r_full_o        (),
      .r_level_o       (),
      //write port (sys clk domain)
      .w_clk_i         (clk_i),
      .w_cke_i         (cke_i),
      .w_arst_i        (arst_i),
      .w_rst_i         (soft_reset_wr),
      .w_en_i          (fifo_write),
      .w_data_i        (fifo_wdata),
      .w_empty_o       (fifo_empty_rd),
      .w_full_o        (fifo_full_rd),
      .w_level_o       (fifo_level_rd)
   );

endmodule


