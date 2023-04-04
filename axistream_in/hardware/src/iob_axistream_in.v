`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_axistream_in_conf.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in # (
    `include "iob_axistream_in_params.vh"
  ) (
    `include "iob_axistream_in_io.vh"
  );
  // FIFO Output width / Input width
  localparam num_inputs_per_output=32/TDATA_W;

  // This mapping is required because "iob_axistream_in_swreg_inst.vh" uses "iob_s_portmap.vh" (This would not be needed if mkregs used "iob_s_s_portmap.vh" instead)
  wire [1-1:0] iob_avalid = iob_avalid_i; //Request valid.
  wire [ADDR_W-1:0] iob_addr = iob_addr_i; //Address.
  wire [DATA_W-1:0] iob_wdata = iob_wdata_i; //Write data.
  wire [(DATA_W/8)-1:0] iob_wstrb = iob_wstrb_i; //Write strobe.
  wire [1-1:0] iob_rvalid; assign iob_rvalid_o = iob_rvalid; //Read data valid.
  wire [DATA_W-1:0] iob_rdata; assign iob_rdata_o = iob_rdata; //Read data.
  wire [1-1:0] iob_ready; assign iob_ready_o = iob_ready; //Interface ready.

  //BLOCK Register File & Configuration control and status register file.
  `include "iob_axistream_in_swreg_inst.vh"
    
  wire [1-1:0] fifo_full;
  //FIFO RAM
  wire [num_inputs_per_output-1:0] ext_mem_w_en;
  wire [32-1:0] ext_mem_w_data;
  wire [(FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))*(num_inputs_per_output)-1:0] ext_mem_w_addr;
  wire [1-1:0] ext_mem_r_en;
  wire [32-1:0] ext_mem_r_data;
  wire [(FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))*(num_inputs_per_output)-1:0] ext_mem_r_addr;
  //Delay rst by one clock, because tvalid signal after rested may come delayed from AXISTREAMOUT peripheral
  //wire rst_delayed;
  //iob_reg #(1,0) rst_delayed_reg (clk_i, arst_i, cke_i, 1'b0, rst_delayed);

  // EMPTY Manual logic
  assign EMPTY_ready = 1'b1;
  assign EMPTY_rvalid = 1'b1;

  // LAST Manual logic
  assign LAST_ready = 1'b1;
  assign LAST_rvalid = 1'b1;

  //Reset register when it is read and FIFO is empty
  wire [1-1:0] reset_register_last;
  assign reset_register_last = iob_avalid & !iob_wstrb & (iob_addr == (`IOB_AXISTREAM_IN_LAST_ADDR >> 2)) & EMPTY[0] & received_tlast;

  //output of TLAST register
  wire [1-1:0] received_tlast;

  wire [3:0] rstrb;

  //Save output of tlast register until the next read of the 'empty' register
  //by the CPU
  wire [5-1:0] saved_last_rstrb_register;
  iob_reg_e #(5,0) saved_last_rstrb_reg (clk_i, arst_i, cke_i, EMPTY_ren, {received_tlast,rstrb}, saved_last_rstrb_register);

  //Set bit 4 of AXISTREAMIN_LAST register as signal of received TLAST
  //Set bits [3:0] of AXISTREAMIN_LAST register as rstrb
  assign LAST[4:0] = saved_last_rstrb_register;

  localparam default_rstrb_value = {TDATA_W/8{1'b1}};
  wire [3:0] rstrb_int;
  wire [1-1:0] rstrb_int_en;
  wire [4-1:0] rstrb_int_next_val;
  
  //Keep track of valid bytes in lastest word of FIFO and
  //keep filling rstrb_int after receiving TLAST to count how many random
  //bytes to completly fill word in FIFO.
  //Reset value is zero (no bytes valid) when receives reset signal
  //Reset due to &rstrb_int (rstrb has all bytes valid) is the default_rstrb_value (to go to next word).
  assign  rstrb_int_en = (tvalid_i & !received_tlast) | (received_tlast & rstrb_int != 4'hf);
  assign  rstrb_int_next_val = ((&rstrb_int) ? 4'd0 : rstrb_int<<TDATA_W/8) + default_rstrb_value;
  iob_reg_re #(4,4'd0) rstrb_int_reg (clk_i, arst_i, cke_i, reset_register_last, rstrb_int_en, rstrb_int_next_val, rstrb_int);

  //Delay TLAST by one clock
  wire [1-1:0] tlast_delayed;
  iob_reg #(1,0) tlast_delayed_reg (clk_i, arst_i, cke_i, tlast_i, tlast_delayed);

  //Store rstrb one clock after TLAST was received 
  iob_reg_re #(4,1'b0) rstrb_reg (clk_i, arst_i, cke_i, reset_register_last, tlast_delayed, rstrb_int, rstrb);

  iob_reg_re #(
    .RST_VAL(1'b0),
    .DATA_W(1))
  axistreamin_last (
      .clk_i        (clk_i),
      .arst_i       (arst_i),
      .cke_i        (cke_i),
      .rst_i        (reset_register_last), 
      .en_i         (tvalid_i & tready_o), //Store tlast value if signal is valid and ready for new one
      .data_i    (tlast_i),
      .data_o   (received_tlast)
  );

  // OUT Manual logic
  assign OUT_ready = 1'b1;
  assign OUT_rvalid = 1'b1;

  iob_fifo_sync
    #(
      .W_DATA_W (TDATA_W),
      .R_DATA_W (32),
      .ADDR_W (FIFO_DEPTH_LOG2)
      )
  fifo
    (
     .arst_i            (arst_i),
     .rst_i             (1'd0),
     .clk_i             (clk_i),
     .cke_i             (cke_i),
     .ext_mem_w_en_o    (ext_mem_w_en),
     .ext_mem_w_data_o  (ext_mem_w_data),
     .ext_mem_w_addr_o  (ext_mem_w_addr),
     .ext_mem_r_en_o    (ext_mem_r_en),
     .ext_mem_r_addr_o  (ext_mem_r_addr),
     .ext_mem_r_data_i  (ext_mem_r_data),
     //read port
     .r_en_i            (OUT_ren),
     .r_data_o          (OUT),
     .r_empty_o         (EMPTY[0]),
     //write port
     .w_en_i            ((tvalid_i & !received_tlast) | (received_tlast & rstrb_int != 4'hf)), //Fill FIFO if is valid OR fill with dummy values to complete 32bit word
     .w_data_i          (tdata_i),
     .w_full_o          (fifo_full),
     .level_o          ()
     );
  
  assign tready_o = ~fifo_full & !received_tlast;  //Only ready for more data when fifo not full and CPU read AXISTREAMIN_LAST data

  //Convert ext_mem_w_en signal to byte enable signal
  localparam num_bytes_per_input = TDATA_W/8;
  wire [32/8-1:0] ext_mem_w_en_be;
  genvar c;
  generate
     for (c = 0; c < num_inputs_per_output; c = c + 1) begin
        assign ext_mem_w_en_be[c*num_bytes_per_input+:num_bytes_per_input] = {num_bytes_per_input{ext_mem_w_en[c]}};
     end
  endgenerate

  //FIFO RAM
  iob_ram_2p_be #(
     .DATA_W (32),
     .ADDR_W ((FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))*(num_inputs_per_output))
   )
  fifo_memory
  (
     .clk_i      (clk_i),
     .w_en_i     (ext_mem_w_en_be),
     .w_data_i   (ext_mem_w_data),
     .w_addr_i   (ext_mem_w_addr),
     .r_en_i     (ext_mem_r_en),
     .r_addr_i   (ext_mem_r_addr),
     .r_data_o   (ext_mem_r_data)
  );
   
endmodule


