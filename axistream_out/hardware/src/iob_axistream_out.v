`timescale 1ns / 1ps
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

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt_o;
   wire iob_rvalid_nxt_o;

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
   //All FIFOs are read at the same time
   wire                  read_fifos = (axis_tready_i & axis_sw_enable) & ~fifo_empty;

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0),
      .CLKEDGE("posedge")
   ) tvalid_reg (
      .clk_i (axis_clk_i),
      .cke_i (axis_cke_i),
      .arst_i(axis_arst_i),
      .rst_i (axis_sw_rst),
      .en_i  (axis_tready_i & axis_sw_enable),
      .data_i(read_fifos),
      .data_o(valid_data)
   );

   //FIFOs
   iob_fifo_async #(
      .W_DATA_W(32),
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
      .w_rst_i         (SOFT_RESET),
      .w_en_i          (DATA_wen),
      .w_data_i        (iob_wdata_i),
      .w_empty_o       (),
      .w_full_o        (FULL),
      .w_level_o       ()
   );

   assign DATA_ready = ENABLE & ~FULL;

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
      .w_rst_i         (SOFT_RESET),
      .w_en_i          (DATA_wen),
      .w_data_i        (WSTRB),
      .w_empty_o       (),
      .w_full_o        (),
      .w_level_o       ()
   );

   assign axis_tvalid_o = (tvalid_int & valid_data) & axis_sw_enable;

   //Priority encoder to find the position of the last valid bit in the WSTRB
   wire [$clog2(N)-1:0] last_pos;
   iob_prio_enc #(
      .W   (N),
      .MODE("HIGH")
   ) prio_enc (
      .unencoded_i(WSTRB),
      .encoded_o  (last_pos)
   );

   //LAST needs to be shifted according to the WSTRB before being inserted into the FIFO
   wire [N-1:0] tlast_int = ({N{1'd0}} | LAST) << last_pos;

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
      .w_rst_i         (SOFT_RESET),
      .w_en_i          (DATA_wen),
      .w_data_i        (tlast_int),
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


