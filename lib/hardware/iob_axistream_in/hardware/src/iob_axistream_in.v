`timescale 1ns / 1ps
`include "iob_axistream_in_conf.vh"
`include "iob_axistream_in_csrs_def.vh"

module iob_axistream_in #(
   `include "iob_axistream_in_params.vs"
) (
   `include "iob_axistream_in_io.vs"
);

   localparam R = DATA_W / TDATA_W;
   localparam R_W = $clog2(R);
   localparam RAM_ADDR_W = FIFO_ADDR_W - $clog2(R);

   //rst and enable synced to axis_clk
   wire                  axis_sw_rst;
   wire                  axis_sw_enable;

   //fifo write
   wire                  axis_fifo_write;
   wire                  axis_fifo_full;

   //tlast detected
   wire                  axis_tlast;
   wire                  axis_tlast_detected;

   //word counter
   wire [    DATA_W-1:0] axis_word_count;
   wire                  axis_word_count_en;


   //fifo read
   reg                   fifo_read;
   wire [    DATA_W-1:0] fifo_data;

   //fifo RAM
   wire                  ext_mem_w_clk;
   wire [         R-1:0] ext_mem_w_en;
   wire [RAM_ADDR_W-1:0] ext_mem_w_addr;
   wire [    DATA_W-1:0] ext_mem_w_data;
   wire                  ext_mem_r_clk;
   wire [         R-1:0] ext_mem_r_en;
   wire [RAM_ADDR_W-1:0] ext_mem_r_addr;
   wire [    DATA_W-1:0] ext_mem_r_data;

   reg                   sys_tvalid;

   // configuration control and status register file.
   `include "iob_axistream_in_csrs_inst.vs"

   wire tlast_detected_reg;

   //CPU INTERFACE
   assign DATA_rready_rd = ~FIFO_EMPTY_rd | sys_tvalid;
   assign interrupt_o    = FIFO_LEVEL_rd >= FIFO_THRESHOLD_wr;
   assign DATA_rvalid_rd = sys_tvalid;

   //System Stream output interface
   // System output valid only if in system stream mode
   assign sys_tvalid_o   = sys_tvalid & MODE_wr;
   assign sys_tdata_o    = fifo_data;

   //FIFO read
   wire fifo_read_pc;
   reg  fifo_read_pc_nxt;
   always @* begin
      //FIFO read FSM
      fifo_read_pc_nxt = fifo_read_pc + 1'b1;
      fifo_read        = 1'b0;
      sys_tvalid       = 1'b0;

      case (fifo_read_pc)
         0: begin
            if (FIFO_EMPTY_rd) begin
               fifo_read_pc_nxt = fifo_read_pc;
            end else begin
               fifo_read = 1'b1;
            end
         end
         default: begin
            sys_tvalid       = 1'b1;
            fifo_read_pc_nxt = fifo_read_pc;
            if ((sys_tready_i && MODE_wr) || (DATA_ren_rd && !MODE_wr)) begin
               if (FIFO_EMPTY_rd) begin
                  fifo_read_pc_nxt = 1'b0;
               end else begin
                  fifo_read = 1'b1;
               end
            end
         end
      endcase
   end

   wire ready_int;
   // Ready if not full and, if in CSR mode, tlast not detected
   assign ready_int          = ~axis_fifo_full & axis_sw_enable & ~(~MODE_wr & tlast_detected_reg);

   //word count enable
   assign axis_word_count_en = axis_fifo_write & ~tlast_detected_reg;

   generate
      if (R == 1) begin : gen_no_padding
         //AXI Stream input interface
         assign axis_tready_o   = ready_int;
         //FIFO write
         assign axis_fifo_write = axis_tvalid_i & axis_tready_o;
      end else begin : gen_padding
         //FIFO write FSM
         reg  fifo_write_state_nxt;
         wire fifo_write_state;
         always @* begin
            fifo_write_state_nxt = fifo_write_state;
            case (fifo_write_state)
               0: begin  // Idle
                  // If tvalid, fifo not full, tlast,  and the write wont fill the DATA_W with TDATA_W
                  if (((axis_tvalid_i & ~axis_fifo_full) & axis_tlast_i) &
                           axis_word_count[0+:R_W] != {R_W{1'd1}}) begin
                     fifo_write_state_nxt = 1'b1;
                  end
               end
               default: begin  // Padding
                  if (axis_word_count[0+:R_W] == {R_W{1'd1}} && ~axis_fifo_full) begin
                     fifo_write_state_nxt = 1'b0;
                  end
               end
            endcase
         end

         iob_reg_re #(
            .DATA_W (1),
            .RST_VAL(1'd0)
         ) fifo_write_state_reg (
            .clk_i (axis_clk_i),
            .cke_i (axis_cke_i),
            .arst_i(axis_arst_i),
            .rst_i (axis_sw_rst),
            .en_i  (axis_sw_enable),
            .data_i(fifo_write_state_nxt),
            .data_o(fifo_write_state)
         );

         // Ready if not full, if in CSR mode, tlast not detected and not in padding state
         assign axis_tready_o   = ready_int & ~fifo_write_state;
         //FIFO write if tvalid, tlast, not full or in padding state
         assign axis_fifo_write = (axis_tvalid_i & axis_tready_o) | fifo_write_state;
      end
   endgenerate

   //tlast
   assign axis_tlast = axis_tlast_i & axis_fifo_write;

   //FIFO read program counter
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) fifo_read_pc_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_sw_enable),
      .data_i(fifo_read_pc_nxt),
      .data_o(fifo_read_pc)
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


   //Synchronizers from clk (csrs) to axis domain
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
      .signal_i(tlast_detected_reg),
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

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) tlast_detect_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(axis_tlast_detected),
      .data_o(tlast_detected_reg)
   );

   //FIFOs RAM
   genvar p;
   generate
      for (p = 0; p < R; p = p + 1) begin : gen_fifo_ram
         iob_ram_t2p #(
            .DATA_W(TDATA_W),
            .ADDR_W(RAM_ADDR_W)
         ) iob_ram_t2p (
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



