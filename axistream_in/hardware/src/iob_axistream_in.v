`timescale 1ns / 1ps
`include "iob_axistream_in_conf.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in #(
   `include "iob_axistream_in_params.vs"
) (
   `include "iob_axistream_in_io.vs"
);
   // FIFO Output width / Input width
   localparam num_inputs_per_output = 32 / TDATA_W;

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt_o;
   wire iob_rvalid_nxt_o;

   // Configuration control and status register file.
   `include "iob_axistream_in_swreg_inst.vs"

   wire [                                              1-1:0] fifo_full;
   // FIFO RAM
   wire [                          num_inputs_per_output-1:0] ext_mem_w_en;
   wire [                                             32-1:0] ext_mem_w_data;
   wire [(FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))-1:0] ext_mem_w_addr;
   wire [                          num_inputs_per_output-1:0] ext_mem_r_en;
   wire [                                             32-1:0] ext_mem_r_data;
   wire [(FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))-1:0] ext_mem_r_addr;
   //Delay rst by one clock, because tvalid signal after rested may come delayed from AXISTREAMOUT peripheral
   //wire rst_delayed;
   //iob_reg #(1,0) rst_delayed_reg (clk_i, arst_i, cke_i, 1'b0, rst_delayed);

   // EMPTY Manual logic
   assign EMPTY_ready  = 1'b1;
   assign EMPTY_rvalid = 1'b1;

   // LAST Manual logic
   assign LAST_ready   = 1'b1;
   assign LAST_rvalid  = 1'b1;

   //output of TLAST register
   wire [1-1:0] received_tlast;

   //Reset register when it is read and FIFO is empty
   wire [1-1:0] reset_register_last;
   assign reset_register_last = iob_avalid_i & !iob_wstrb_i & iob_addr_i == `IOB_AXISTREAM_IN_LAST_ADDR & EMPTY[0] & received_tlast;

   wire [  3:0] rstrb;

   //Save output of tlast register until the next read of the 'empty' register
   //by the CPU
   wire [5-1:0] saved_last_rstrb_register;
   iob_reg_e #(
      .DATA_W (5),
      .RST_VAL(0)
   ) saved_last_rstrb_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .en_i  (EMPTY_ren),
      .data_i({received_tlast, rstrb}),
      .data_o(saved_last_rstrb_register)
   );

   //Set bit 4 of AXISTREAMIN_LAST register as signal of received TLAST
   //Set bits [3:0] of AXISTREAMIN_LAST register as rstrb
   assign LAST[4:0] = saved_last_rstrb_register;

   localparam default_rstrb_value = {TDATA_W / 8{1'b1}};
   wire [  3:0] rstrb_int;
   wire [1-1:0] rstrb_int_en;
   wire [4-1:0] rstrb_int_next_val;

   //Keep track of valid bytes in lastest word of FIFO and
   //keep filling rstrb_int after receiving TLAST to count how many random
   //bytes to completly fill word in FIFO.
   //Reset value is zero (no bytes valid) when receives reset signal
   //Reset due to &rstrb_int (rstrb has all bytes valid) is the default_rstrb_value (to go to next word).
   assign rstrb_int_en = ((tvalid_i & ~fifo_full) & !received_tlast) | (received_tlast & rstrb_int != 4'hf);
   assign  rstrb_int_next_val = ((&rstrb_int) ? 4'd0 : rstrb_int<<TDATA_W/8) + default_rstrb_value;
   iob_reg_re #(
      .DATA_W (4),
      .RST_VAL(4'd0)
   ) rstrb_int_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (SOFTRESET | reset_register_last),
      .en_i  (rstrb_int_en),
      .data_i(rstrb_int_next_val),
      .data_o(rstrb_int)
   );

   //Delay TLAST by one clock
   wire [1-1:0] tlast_delayed;
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(0)
   ) tlast_delayed_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (SOFTRESET),
      .data_i(tlast_i),
      .data_o(tlast_delayed)
   );

   //Store rstrb one clock after TLAST was received 
   iob_reg_re #(
      .DATA_W (4),
      .RST_VAL(1'b0)
   ) rstrb_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (SOFTRESET | reset_register_last),
      .en_i  (tlast_delayed),
      .data_i(rstrb_int),
      .data_o(rstrb)
   );

   iob_reg_re #(
      .RST_VAL(1'b0),
      .DATA_W (1)
   ) axistreamin_last (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .rst_i(reset_register_last | SOFTRESET),
      .en_i(tvalid_i & tready_o),  //Store tlast value if signal is valid and ready for new one
      .data_i(tlast_i),
      .data_o(received_tlast)
   );

   // OUT Manual logic
   assign OUT_ready  = 1'b1;
   assign OUT_rvalid = 1'b1;

   //Delay OUT_ren by one clock
   wire [1-1:0] out_ren_delayed;
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(0)
   ) out_ren_delayed_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (SOFTRESET),
      .data_i(OUT_ren),
      .data_o(out_ren_delayed)
   );

   iob_fifo_sync #(
      .W_DATA_W(TDATA_W),
      .R_DATA_W(32),
      .ADDR_W  (FIFO_DEPTH_LOG2)
   ) fifo (
      .arst_i(arst_i),
      .rst_i(SOFTRESET),
      .clk_i(clk_i),
      .cke_i(cke_i),
      .ext_mem_w_en_o(ext_mem_w_en),
      .ext_mem_w_data_o(ext_mem_w_data),
      .ext_mem_w_addr_o(ext_mem_w_addr),
      .ext_mem_r_en_o(ext_mem_r_en),
      .ext_mem_r_addr_o(ext_mem_r_addr),
      .ext_mem_r_data_i(ext_mem_r_data),
      .ext_mem_clk_o(),
      //read port
      .r_en_i((OUT_ren & (!out_ren_delayed | iob_rvalid_o)) | (tready_i & ENABLE)),
      .r_data_o(OUT),
      .r_empty_o(EMPTY[0]),
      //write port
      .w_en_i            ((tvalid_i & !received_tlast) | (received_tlast & rstrb_int != 4'hf)), //Fill FIFO if is valid OR fill with dummy values to complete 32bit word
      .w_data_i(tdata_i),
      .w_full_o(fifo_full),
      .level_o(FIFO_LEVEL[FIFO_DEPTH_LOG2+1-1:0])
   );

   // Assign DMA tdata_o and tvalid_o
   assign tdata_o = OUT;

   //Next is valid if: 
   //    is valid now and receiver is not ready
   //    or
   //    fifo is not empty, receiver is ready, `ENABLE` register is active
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(0)
   ) tvalid_int_reg (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .rst_i(SOFTRESET),
      .data_i ((tvalid_o & ~tready_i) | (~EMPTY[0] & tready_i & ENABLE)),
      .data_o(tvalid_o)
   );

   // Assign unused bits to zero
   assign FIFO_LEVEL[32-1:(FIFO_DEPTH_LOG2+1)] = {(FIFO_DEPTH_LOG2+1){1'b0}};

   assign fifo_threshold_o = FIFO_LEVEL >= FIFO_THRESHOLD;

   //Only ready for more data when fifo not full, CPU has read AXISTREAMIN_LAST data, and `ENABLE` register is active
   assign tready_o = ~fifo_full & !received_tlast & ENABLE;

   //Convert ext_mem_w_en signal to byte enable signal
   localparam num_bytes_per_input = TDATA_W / 8;
   wire [32/8-1:0] ext_mem_w_en_be;
   genvar c;
   generate
      for (c = 0; c < num_inputs_per_output; c = c + 1) begin : gen_ext_mem_w_en_be
         assign ext_mem_w_en_be[c*num_bytes_per_input+:num_bytes_per_input] = {num_bytes_per_input{ext_mem_w_en[c]}};
      end
   endgenerate

   //FIFO RAM
   iob_ram_2p_be #(
      .DATA_W(32),
      .ADDR_W((FIFO_DEPTH_LOG2 - $clog2(num_inputs_per_output)))
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


