`timescale 1ns / 1ps
`include "iob_lib.vh"
`include "iob_axistream_out_conf.vh"
`include "iob_axistream_out_swreg_def.vh"

module iob_axistream_out #(
   `include "iob_axistream_out_params.vs"
) (
   `include "iob_axistream_out_io.vs"
);
   // FIFO Input width / Ouput width
   localparam N = 32 / TDATA_W;

   // This mapping is required because "iob_axistream_out_swreg_inst.vh" uses "iob_s_portmap.vh" (This would not be needed if mkregs used "iob_s_s_portmap.vh" instead)
   wire [         1-1:0] iob_avalid = iob_avalid_i;  //Request valid.
   wire [    ADDR_W-1:0] iob_addr = iob_addr_i;  //Address.
   wire [    DATA_W-1:0] iob_wdata = iob_wdata_i;  //Write data.
   wire [(DATA_W/8)-1:0] iob_wstrb = iob_wstrb_i;  //Write strobe.
   wire [         1-1:0]                                              iob_rvalid;
   assign iob_rvalid_o = iob_rvalid;  //Read data valid.
   wire [DATA_W-1:0] iob_rdata;
   assign iob_rdata_o = iob_rdata;  //Read data.
   wire [1-1:0] iob_ready;
   assign iob_ready_o = iob_ready;  //Interface ready.

   //BLOCK Register File & Configuration control and status register file.
   `include "iob_axistream_out_swreg_inst.vs"

   wire [                          1-1:0] fifo_empty;
   wire [                          1-1:0] fifo_full;
   wire [                          1-1:0] tvalid_int;
   wire [                          1-1:0] tlast_int;
   wire [                          1-1:0] storing_tlast_word;
   //FIFO RAM
   wire [                          N-1:0] ext_mem_w_en;
   wire [                         32-1:0] ext_mem_w_data;
   wire [(FIFO_DEPTH_LOG2-$clog2(N))-1:0] ext_mem_w_addr;
   wire [                          N-1:0] ext_mem_r_en;
   wire [                         32-1:0] ext_mem_r_data;
   wire [(FIFO_DEPTH_LOG2-$clog2(N))-1:0] ext_mem_r_addr;

   //Register to store tlast wstrb
   wire [                          N-1:0] last_wstrb;
   iob_reg_re #(
      .RST_VAL({N{1'b0}}),
      .DATA_W (N)
   ) axistreamout_wstrb_next_word_last (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i ((fifo_empty & storing_tlast_word) | SOFTRESET),  //Reset when TLAST word is sent
      .en_i  (WSTRB_NEXT_WORD_LAST_wen),
      .data_i(iob_wdata[0+:N]),
      .data_o(last_wstrb)
   );

   //Signal if tlast word is stored.
   //Enable when TLAST word wstrb has been defined (in the last_wstrb register) 
   //and a value has been inserted word.
   //Reset when TLAST word is sent.
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) storing_tlast_word_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (SOFTRESET | (fifo_empty & storing_tlast_word)),
      .en_i  (&last_wstrb & IN_wen),
      .data_i(1'b1),
      .data_o(storing_tlast_word)
   );

   wire [FIFO_DEPTH_LOG2+1-1:0] fifo_level;
   iob_fifo_sync #(
      .W_DATA_W(32),
      .R_DATA_W(TDATA_W),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) fifo (
      .arst_i          (arst_i),
      .rst_i           (SOFTRESET),
      .clk_i           (clk_i),
      .cke_i           (cke_i),
      .ext_mem_w_en_o  (ext_mem_w_en),
      .ext_mem_w_data_o(ext_mem_w_data),
      .ext_mem_w_addr_o(ext_mem_w_addr),
      .ext_mem_r_en_o  (ext_mem_r_en),
      .ext_mem_r_addr_o(ext_mem_r_addr),
      .ext_mem_r_data_i(ext_mem_r_data),
      //read port
      .r_en_i          (tready_i & ENABLE),
      .r_data_o        (tdata_o),
      .r_empty_o       (fifo_empty),
      //write port
      .w_en_i          (IN_wen),
      .w_data_i        (iob_wdata),
      .w_full_o        (fifo_full),
      .level_o         (fifo_level)
   );

   //Set FIFO full register when it is full or is waiting to send TLAST word.
   assign FULL[0] = fifo_full | (last_wstrb != {N{1'b0}});

   //Next is valid if: 
   //    is valid now and receiver is not ready
   //    or
   //    fifo is not empty, receiver is ready, `ENABLE` register is active, and:
   //          TLAST word is not stored
   //        or
   //          TLAST word is stored and is not on the last word
   //        or
   //          TLAST word is stored, is on the last word and on a valid
   //          portion of wstrb
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(0)
   ) tvalid_int_reg (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .rst_i(SOFTRESET),
      .data_i ((tvalid_int & ~tready_i) | (~fifo_empty & tready_i & ENABLE & (!storing_tlast_word | fifo_level>N | last_wstrb[N-fifo_level]))),
      .data_o(tvalid_int)
   );
   assign tvalid_o = tvalid_int;

   //Next is tlast if: 
   //    is tlast now and receiver is not ready
   //    or
   //    fifo is not empty, receiver is ready, `ENABLE` register is active, and TLAST word is stored, is on the last word and:
   //        next portion of wstrb is zero (meaning this is the last portion of wstrb) (can only happen if fifo_level>1)
   //        or
   //        fifo_level is 1 (only reaches this value when wstrb is all ones)
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(0)
   ) tlast_int_reg (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .rst_i(SOFTRESET),
      .data_i ((tlast_int & ~tready_i) | (~fifo_empty & tready_i & ENABLE & storing_tlast_word & fifo_level<=N & (fifo_level>1?~last_wstrb[N-fifo_level+1]:fifo_level==1))),
      .data_o(tlast_int)
   );
   // TLAST active only while data is valid
   assign tlast_o = tlast_int & tvalid_int;

   //Convert ext_mem_w_en signal to byte enable signal
   localparam num_bytes_per_output = TDATA_W / 8;
   wire [32/8-1:0] ext_mem_w_en_be;
   genvar c;
   generate
      for (c = 0; c < N; c = c + 1) begin : gen_ext_mem_w_en_be
         assign ext_mem_w_en_be[c*num_bytes_per_output+:num_bytes_per_output] = {num_bytes_per_output{ext_mem_w_en[c]}};
      end
   endgenerate

   //FIFO RAM
   iob_ram_2p_be #(
      .DATA_W(32),
      .ADDR_W((FIFO_DEPTH_LOG2 - $clog2(N)))
   ) fifo_memory (
      .clk_i   (clk_i),
      .w_en_i  (ext_mem_w_en_be),
      .w_data_i(ext_mem_w_data),
      .w_addr_i(ext_mem_w_addr),
      .r_en_i  (|ext_mem_r_en),
      .r_addr_i(ext_mem_r_addr),
      .r_data_o(ext_mem_r_data)
   );

endmodule


