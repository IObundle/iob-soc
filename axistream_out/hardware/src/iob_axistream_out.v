`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_axistream_out_swreg_def.vh"

module iob_axistream_out 
  # (
     parameter TDATA_W = 8, //PARAM axi stream tdata width
     parameter FIFO_DEPTH_LOG2 = 4, //PARAM depth of FIFO
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_axistream_out_swreg_ADDR_W //MACRO CPU address section width
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs
   `IOB_OUTPUT(tdata, TDATA_W),
   `IOB_OUTPUT(tvalid, 1),
   `IOB_INPUT(tready, 1),
   `IOB_OUTPUT(tlast, 1), 
`include "iob_gen_if.vh"
   );
	// FIFO Input width / Ouput width
	localparam N=32/TDATA_W;

//BLOCK Register File & Configuration control and status register file.
`include "iob_axistream_out_swreg_gen.vh"
   
   `IOB_WIRE(fifo_empty, 1)
   `IOB_WIRE(fifo_full, 1)
   `IOB_VAR(tvalid_int, 1)
   `IOB_VAR(tlast_int, 1)
   `IOB_VAR(storing_tlast_word, 1)
   //FIFO RAM
   `IOB_WIRE(ext_mem_w_en, N)
   `IOB_WIRE(ext_mem_w_data, 32)
   `IOB_WIRE(ext_mem_w_addr, (FIFO_DEPTH_LOG2-$clog2(N))*(N))
   `IOB_WIRE(ext_mem_r_en, 1)
   `IOB_WIRE(ext_mem_r_data, 32)
   `IOB_WIRE(ext_mem_r_addr, (FIFO_DEPTH_LOG2-$clog2(N))*(N))
	
   // Set unused rdata bits to 0
   `IOB_WIRE2WIRE({(`AXISTREAMOUT_FULL_W-1){1'b0}}, AXISTREAMOUT_FULL_rdata[`AXISTREAMOUT_FULL_W-1:1])

	//Register to store tlast wstrb
   `IOB_WIRE(last_wstrb, N)
   iob_reg #(.DATA_W(N))
   axistreamout_wstrb_next_word_last (
       .clk        (clk),
       .arst       (rst),
       .arst_val   ({N{1'b0}}),
	    .rst        (fifo_empty & storing_tlast_word), //Reset when TLAST word is sent
       .rst_val    ({N{1'b0}}),
       .en         (AXISTREAMOUT_WSTRB_NEXT_WORD_LAST_en), 
       .data_in    (AXISTREAMOUT_WSTRB_NEXT_WORD_LAST_wdata[0+:N]),
       .data_out   (last_wstrb) 
   );

   //Signal if tlast word is stored.
	//Enable when TLAST word wstrb has been defined (in the last_wstrb register) 
	//and a value has been inserted word.
	//Reset when TLAST word is sent.
   `IOB_REG_RE(clk, fifo_empty & storing_tlast_word, 1'b0, last_wstrb & AXISTREAMOUT_IN_en, storing_tlast_word, 1'b1) 
  
   `IOB_WIRE(fifo_level, FIFO_DEPTH_LOG2+1)
   iob_fifo_sync
     #(
       .W_DATA_W (32),
       .R_DATA_W (TDATA_W),
       .ADDR_W (FIFO_DEPTH_LOG2)
       )
   fifo
     (
      .arst            (rst),
      .rst             (1'd0),
      .clk             (clk),
      .ext_mem_w_en    (ext_mem_w_en),                                                                                                                                                                                                                                  
      .ext_mem_w_data  (ext_mem_w_data),
      .ext_mem_w_addr  (ext_mem_w_addr),
      .ext_mem_r_en    (ext_mem_r_en),
      .ext_mem_r_addr  (ext_mem_r_addr),
      .ext_mem_r_data  (ext_mem_r_data),
      //read port
      .r_en            (tready),
      .r_data          (tdata),
      .r_empty         (fifo_empty),
      //write port
      .w_en            (AXISTREAMOUT_IN_en),
      .w_data          (AXISTREAMOUT_IN_wdata),
      .w_full          (fifo_full),
      .level           (fifo_level)
      );
  
   //Set FIFO full register when it is full or is waiting to send TLAST word.
   `IOB_WIRE2WIRE(fifo_full | |last_wstrb, AXISTREAMOUT_FULL_rdata[0])

	//Next is valid if: 
	//    is valid now and receiver is not ready
	//    or
	//    fifo is not empty, receiver is ready and:
	//          TLAST word is not stored
	//        or
	//          TLAST word is stored and is not on the last word
	//        or
	//          TLAST word is stored, is on the last word and on a valid
	//          portion of wstrb
   `IOB_REG(clk, tvalid_int, (tvalid_int & ~tready) | (~fifo_empty & tready & (!storing_tlast_word | fifo_level>N | last_wstrb[N-fifo_level]))) 
   `IOB_VAR2WIRE(tvalid_int, tvalid)

	//Next is tlast if: 
	//    is tlast now and receiver is not ready
	//    or
	//    fifo is not empty, receiver is ready and TLAST word is stored, is on the last word and:
	//        next portion of wstrb is zero (meaning this is the last portion of wstrb) (can only happen if fifo_level>1)
	//        or
	//        fifo_level is 1 (only reaches this value when wstrb is all ones)
   `IOB_REG(clk, tlast_int, (tlast_int & ~tready) | (~fifo_empty & tready & storing_tlast_word & fifo_level<=N & (fifo_level>1?~last_wstrb[N-fifo_level+1]:fifo_level==1))) 
	// TLAST active only while data is valid
   `IOB_VAR2WIRE(tlast_int & tvalid_int, tlast)

	//Convert ext_mem_w_en signal to byte enable signal
	localparam num_bytes_per_output = TDATA_W/8;
   `IOB_WIRE(ext_mem_w_en_be, 32/8)
   genvar c;
   generate
      for (c = 0; c < N; c = c + 1) begin
         assign ext_mem_w_en_be[c*num_bytes_per_output+:num_bytes_per_output] = {num_bytes_per_output{ext_mem_w_en[c]}};
      end
   endgenerate

   //FIFO RAM
   iob_ram_2p_be #(
      .DATA_W (32),
      .ADDR_W ((FIFO_DEPTH_LOG2-$clog2(N))*(N))
    )
   fifo_memory
   (
      .clk      (clk),
      .w_en     (ext_mem_w_en_be),
      .w_data   (ext_mem_w_data),
      .w_addr   (ext_mem_w_addr),
      .r_en     (ext_mem_r_en),
      .r_data   (ext_mem_r_data),
      .r_addr   (ext_mem_r_addr)
   );
   
endmodule


