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

   //FIFO RAM
   wire [         N-1:0] ext_mem_tdata_w_en;
   wire [        32-1:0] ext_mem_tdata_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_tdata_w_addr;
   wire [         N-1:0] ext_mem_tdata_r_en;
   wire [        32-1:0] ext_mem_tdata_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_tdata_r_addr;
   wire                  ext_mem_tdata_clk;

   wire [         N-1:0] ext_mem_strb_w_en;
   wire [         N-1:0] ext_mem_strb_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_strb_w_addr;
   wire [         N-1:0] ext_mem_strb_r_en;
   wire [         N-1:0] ext_mem_strb_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_strb_r_addr;
   wire                  ext_mem_strb_clk;

   wire [         N-1:0] ext_mem_last_w_en;
   wire [         N-1:0] ext_mem_last_w_data;
   wire [RAM_ADDR_W-1:0] ext_mem_last_w_addr;
   wire [         N-1:0] ext_mem_last_r_en;
   wire [         N-1:0] ext_mem_last_r_data;
   wire [RAM_ADDR_W-1:0] ext_mem_last_r_addr;
   wire                  ext_mem_last_clk;

   wire                  empty;
   wire                  tvalid_int;
   wire                  valid_data;
   //All FIFOs are read at the same time
   wire                  read_fifos = (tready_i & ENABLE) & ~empty;

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0),
      .CLKEDGE("posedge")
   ) reg_tvalid (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (SOFT_RESET),
      .en_i  (tready_i & ENABLE),
      .data_i(read_fifos),
      .data_o(valid_data)
   );

   iob_fifo_sync #(
      .W_DATA_W(32),
      .R_DATA_W(TDATA_W),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) data_fifo (
      .arst_i          (arst_i),
      .rst_i           (SOFT_RESET),
      .clk_i           (clk_i),
      .cke_i           (cke_i),
      .ext_mem_w_en_o  (ext_mem_tdata_w_en),
      .ext_mem_w_data_o(ext_mem_tdata_w_data),
      .ext_mem_w_addr_o(ext_mem_tdata_w_addr),
      .ext_mem_r_en_o  (ext_mem_tdata_r_en),
      .ext_mem_r_addr_o(ext_mem_tdata_r_addr),
      .ext_mem_r_data_i(ext_mem_tdata_r_data),
      .ext_mem_clk_o   (ext_mem_tdata_clk),
      //read port
      .r_en_i          (read_fifos),
      .r_data_o        (tdata_o),
      .r_empty_o       (empty),
      //write port
      .w_en_i          (DATA_wen),
      .w_data_i        (iob_wdata_i),
      .w_full_o        (FULL),
      .level_o         ()
   );

   assign DATA_ready = ENABLE & ~FULL;

   iob_fifo_sync #(
      .W_DATA_W(N),
      .R_DATA_W(1),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) strb_fifo (
      .arst_i          (arst_i),
      .rst_i           (SOFT_RESET),
      .clk_i           (clk_i),
      .cke_i           (cke_i),
      .ext_mem_w_en_o  (ext_mem_strb_w_en),
      .ext_mem_w_data_o(ext_mem_strb_w_data),
      .ext_mem_w_addr_o(ext_mem_strb_w_addr),
      .ext_mem_r_en_o  (ext_mem_strb_r_en),
      .ext_mem_r_addr_o(ext_mem_strb_r_addr),
      .ext_mem_r_data_i(ext_mem_strb_r_data),
      .ext_mem_clk_o   (ext_mem_strb_clk),
      //read port
      .r_en_i          (read_fifos),
      .r_data_o        (tvalid_int),
      .r_empty_o       (),
      //write port
      .w_en_i          (DATA_wen),
      .w_data_i        (WSTRB),
      .w_full_o        (),
      .level_o         ()
   );

   assign tvalid_o = (tvalid_int & valid_data) & ENABLE;

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

   iob_fifo_sync #(
      .W_DATA_W(N),
      .R_DATA_W(1),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) last_fifo (
      .arst_i          (arst_i),
      .rst_i           (SOFT_RESET),
      .clk_i           (clk_i),
      .cke_i           (cke_i),
      .ext_mem_w_en_o  (ext_mem_last_w_en),
      .ext_mem_w_data_o(ext_mem_last_w_data),
      .ext_mem_w_addr_o(ext_mem_last_w_addr),
      .ext_mem_r_en_o  (ext_mem_last_r_en),
      .ext_mem_r_addr_o(ext_mem_last_r_addr),
      .ext_mem_r_data_i(ext_mem_last_r_data),
      .ext_mem_clk_o   (),
      //read port
      .r_en_i          (read_fifos),
      .r_data_o        (tlast_o),
      .r_empty_o       (),
      //write port
      .w_en_i          (DATA_wen),
      .w_data_i        (tlast_int),
      .w_full_o        (),
      .level_o         ()
   );


   //FIFOs RAMs
   genvar p;
   generate
      for (p = 0; p < N; p = p + 1) begin : gen_fifo_ram
         iob_ram_2p #(
            .DATA_W(TDATA_W),
            .ADDR_W(RAM_ADDR_W)
         ) tdata_fifo_ram_2p (
            .clk_i   (ext_mem_tdata_clk),
            .w_en_i  (ext_mem_tdata_w_en[p]),
            .w_addr_i(ext_mem_tdata_w_addr),
            .w_data_i(ext_mem_tdata_w_data[p*TDATA_W+:TDATA_W]),
            .r_en_i  (ext_mem_tdata_r_en[p]),
            .r_addr_i(ext_mem_tdata_r_addr),
            .r_data_o(ext_mem_tdata_r_data[p*TDATA_W+:TDATA_W])
         );

         iob_ram_2p #(
            .DATA_W(1),
            .ADDR_W(RAM_ADDR_W)
         ) strb_fifo_ram_2p (
            .clk_i   (ext_mem_strb_clk),
            .w_en_i  (ext_mem_strb_w_en[p]),
            .w_addr_i(ext_mem_strb_w_addr),
            .w_data_i(ext_mem_strb_w_data[p]),
            .r_en_i  (ext_mem_strb_r_en[p]),
            .r_addr_i(ext_mem_strb_r_addr),
            .r_data_o(ext_mem_strb_r_data[p])
         );

         iob_ram_2p #(
            .DATA_W(1),
            .ADDR_W(RAM_ADDR_W)
         ) last_fifo_ram_2p (
            .clk_i   (ext_mem_last_clk),
            .w_en_i  (ext_mem_last_w_en[p]),
            .w_addr_i(ext_mem_last_w_addr),
            .w_data_i(ext_mem_last_w_data[p]),
            .r_en_i  (ext_mem_last_r_en[p]),
            .r_addr_i(ext_mem_last_r_addr),
            .r_data_o(ext_mem_last_r_data[p])
         );
      end
   endgenerate

endmodule


