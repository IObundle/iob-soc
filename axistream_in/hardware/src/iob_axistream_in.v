`timescale 1ns / 1ps
`include "iob_axistream_in_conf.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in #(
   `include "iob_axistream_in_params.vs"
) (
   `include "iob_axistream_in_io.vs"
);
   // FIFO Input width / Ouput width
   localparam N = 32 / TDATA_W;
   localparam RAM_ADDR_W = FIFO_DEPTH_LOG2 - $clog2(N);

   //FSM states
   localparam STATE_WRITE = 1'd0;
   localparam STATE_PADDING = 1'd1;

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt_o;
   wire iob_rvalid_nxt_o;

   // Configuration control and status register file.
   `include "iob_axistream_in_swreg_inst.vs"

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

   wire                  fifo_full;
   assign DATA_ready = ~EMPTY & ENABLE;

   reg  [$clog2(N)-1:0] writen_words_nxt;
   wire [$clog2(N)-1:0] writen_words;
   reg                  state_nxt;
   wire                 state;

   //Synchronizers for the sw_regs
   wire                 axis_sw_rst;
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_rst (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(SOFT_RESET),
      .signal_o(axis_sw_rst)
   );

   wire axis_sw_enable;
   iob_sync #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) sw_enable (
      .clk_i   (axis_clk_i),
      .arst_i  (axis_arst_i),
      .signal_i(ENABLE),
      .signal_o(axis_sw_enable)
   );

   wire read_fifos;
   // DATA_ren edge detection so that only one word is read from FIFO
   iob_edge_detect #(
      .CLKEDGE("posedge")
   ) READ_edge_detect (
      `include "clk_en_rst_s_s_portmap.vs"
      .bit_i     (DATA_ren),
      .detected_o(read_fifos)
   );

   // Add padding words after the last word to fill packet
   always @* begin
      state_nxt        = state;
      writen_words_nxt = writen_words;
      case (state)
         STATE_WRITE: begin
            if (axis_tvalid_i) begin
               if (writen_words == N - 1) begin  // Last word in the packet
                  writen_words_nxt = 0;
               end else begin
                  writen_words_nxt = writen_words + 1;
                  if (axis_tlast_i) begin
                     state_nxt = STATE_PADDING;
                  end
               end
            end
         end
         STATE_PADDING: begin
            if (writen_words == N - 1) begin  // Last word in the packet
               writen_words_nxt = 0;
               state_nxt        = STATE_WRITE;
            end else begin
               writen_words_nxt = writen_words + 1;
            end
         end
      endcase
   end

   // Write data to FIFOs when valid, enable or in padding state
   wire wren_int = (axis_tvalid_i | (state == STATE_PADDING)) & axis_sw_enable;

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0),
      .CLKEDGE("posedge")
   ) reg_DATA_valid (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (SOFT_RESET),
      .en_i  (ENABLE),
      .data_i(read_fifos),
      .data_o(DATA_rvalid)
   );

   iob_fifo_async #(
      .W_DATA_W(TDATA_W),
      .R_DATA_W(32),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) data_fifo (
      .ext_mem_w_clk_o (ext_mem_tdata_w_clk),
      .ext_mem_w_en_o  (ext_mem_tdata_w_en),
      .ext_mem_w_data_o(ext_mem_tdata_w_data),
      .ext_mem_w_addr_o(ext_mem_tdata_w_addr),
      .ext_mem_r_clk_o (ext_mem_tdata_r_clk),
      .ext_mem_r_en_o  (ext_mem_tdata_r_en),
      .ext_mem_r_addr_o(ext_mem_tdata_r_addr),
      .ext_mem_r_data_i(ext_mem_tdata_r_data),
      //read port
      .r_clk_i         (clk_i),
      .r_cke_i         (cke_i),
      .r_arst_i        (arst_i),
      .r_rst_i         (SOFT_RESET),
      .r_en_i          (read_fifos),
      .r_data_o        (DATA),
      .r_empty_o       (EMPTY),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (axis_clk_i),
      .w_cke_i         (axis_cke_i),
      .w_arst_i        (axis_arst_i),
      .w_rst_i         (axis_sw_rst),
      .w_en_i          (wren_int),
      .w_data_i        (axis_tdata_i),
      .w_empty_o       (),
      .w_full_o        (fifo_full),
      .w_level_o       ()
   );

   iob_fifo_async #(
      .W_DATA_W(1),
      .R_DATA_W(N),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) strb_fifo (
      .ext_mem_w_clk_o (ext_mem_strb_w_clk),
      .ext_mem_w_en_o  (ext_mem_strb_w_en),
      .ext_mem_w_data_o(ext_mem_strb_w_data),
      .ext_mem_w_addr_o(ext_mem_strb_w_addr),
      .ext_mem_r_clk_o (ext_mem_strb_r_clk),
      .ext_mem_r_en_o  (ext_mem_strb_r_en),
      .ext_mem_r_addr_o(ext_mem_strb_r_addr),
      .ext_mem_r_data_i(ext_mem_strb_r_data),
      //read port
      .r_clk_i         (clk_i),
      .r_cke_i         (cke_i),
      .r_arst_i        (arst_i),
      .r_rst_i         (SOFT_RESET),
      .r_en_i          (read_fifos),
      .r_data_o        (RSTRB),
      .r_empty_o       (),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (axis_clk_i),
      .w_cke_i         (axis_cke_i),
      .w_arst_i        (axis_arst_i),
      .w_rst_i         (axis_sw_rst),
      .w_en_i          (wren_int),
      .w_data_i        (axis_tvalid_i),
      .w_empty_o       (),
      .w_full_o        (),
      .w_level_o       ()
   );

   wire [N-1:0] tlast_int;

   iob_fifo_async #(
      .W_DATA_W(1),
      .R_DATA_W(N),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) last_fifo (
      .ext_mem_w_clk_o (ext_mem_last_w_clk),
      .ext_mem_w_en_o  (ext_mem_last_w_en),
      .ext_mem_w_data_o(ext_mem_last_w_data),
      .ext_mem_w_addr_o(ext_mem_last_w_addr),
      .ext_mem_r_clk_o (ext_mem_last_r_clk),
      .ext_mem_r_en_o  (ext_mem_last_r_en),
      .ext_mem_r_addr_o(ext_mem_last_r_addr),
      .ext_mem_r_data_i(ext_mem_last_r_data),
      //read port
      .r_clk_i         (clk_i),
      .r_cke_i         (cke_i),
      .r_arst_i        (arst_i),
      .r_rst_i         (SOFT_RESET),
      .r_en_i          (read_fifos),
      .r_data_o        (tlast_int),
      .r_empty_o       (),
      .r_full_o        (),
      .r_level_o       (),
      //write port
      .w_clk_i         (axis_clk_i),
      .w_cke_i         (axis_cke_i),
      .w_arst_i        (axis_arst_i),
      .w_rst_i         (axis_sw_rst),
      .w_en_i          (wren_int),
      .w_data_i        (axis_tlast_i),
      .w_empty_o       (),
      .w_full_o        (),
      .w_level_o       ()
   );

   assign LAST     = |tlast_int;
   // Is not ready when FIFO is full or when it is padding
   wire ready_int = ~fifo_full & axis_sw_enable;
   assign axis_tready_o = ready_int & (state != STATE_PADDING);

   // FSM state register
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(STATE_WRITE),
      .CLKEDGE("posedge")
   ) fsm_state_reg (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (ready_int),
      .data_i(state_nxt),
      .data_o(state)
   );

   // Written words register
   iob_reg_re #(
      .DATA_W ($clog2(N)),
      .RST_VAL({$clog2(N) {1'b0}}),
      .CLKEDGE("posedge")
   ) writen_words_reg (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (ready_int),
      .data_i(writen_words_nxt),
      .data_o(writen_words)
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
