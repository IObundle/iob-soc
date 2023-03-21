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
      
   `IOB_WIRE(fifo_full, 1)
   //FIFO RAM
   `IOB_WIRE(ext_mem_w_en, num_inputs_per_output)
   `IOB_WIRE(ext_mem_w_data, 32)
   `IOB_WIRE(ext_mem_w_addr, (FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))*(num_inputs_per_output))
   `IOB_WIRE(ext_mem_r_en, 1)
   `IOB_WIRE(ext_mem_r_data, 32)
   `IOB_WIRE(ext_mem_r_addr, (FIFO_DEPTH_LOG2-$clog2(num_inputs_per_output))*(num_inputs_per_output))
   //Delay rst by one clock, because tvalid signal after rested may come delayed from AXISTREAMOUT peripheral
   `IOB_VAR(rst_delayed, 1)
    iob_reg #(1,0) rst_delayed_reg (clk_i, arst_i, cke_i, rst, rst_delayed);

   // Set unused rdata bits to 0
   `IOB_WIRE2WIRE({(`AXISTREAMIN_EMPTY_W-1){1'b0}}, AXISTREAMIN_EMPTY_rdata[`AXISTREAMIN_EMPTY_W-1:1])
   `IOB_WIRE2WIRE({(`AXISTREAMIN_LAST_W-5){1'b0}}, AXISTREAMIN_LAST_rdata[`AXISTREAMIN_LAST_W-1:5])

   //Reset register when it is read and FIFO is empty
   `IOB_WIRE(reset_register_last, 1)
   `IOB_WIRE2WIRE(valid & !wstrb & (address == (`AXISTREAMIN_LAST_ADDR >> 2)) & AXISTREAMIN_EMPTY_rdata[0] & received_tlast,reset_register_last)

	//output of TLAST register
   `IOB_WIRE(received_tlast, 1)
	
   //Signal when cpu reads EMPTY register
   `IOB_WIRE(AXISTREAMIN_EMPTY_ren, 1)
   `IOB_WIRE2WIRE(valid & !wstrb & (address == (`AXISTREAMIN_EMPTY_ADDR >> 2)), AXISTREAMIN_EMPTY_ren)

	//Save output of tlast register until the next read of the 'empty' register
	//by the CPU
   `IOB_VAR(saved_last_rstrb_register, 5)
   `IOB_REG_E(clk, AXISTREAMIN_EMPTY_ren, saved_last_rstrb_register, {received_tlast,rstrb})

   //Set bit 4 of AXISTREAMIN_LAST register as signal of received TLAST
   //Set bits [3:0] of AXISTREAMIN_LAST register as rstrb
   `IOB_WIRE2WIRE(saved_last_rstrb_register,AXISTREAMIN_LAST_rdata[4:0])

	localparam default_rstrb_value = {TDATA_W/8{1'b1}};
   wire [3:0] rstrb_int
   `IOB_WIRE(rstrb_int_en, 1)
   `IOB_WIRE(rstrb_int_next_val, 4)
	//Keep track of valid bytes in lastest word of FIFO and
	//keep filling rstrb_int after receiving TLAST to count how many random
	//bytes to completly fill word in FIFO.
	//Reset value is zero (no bytes valid) when receives reset signal
	//Reset due to &rstrb_int (rstrb has all bytes valid) is the default_rstrb_value (to go to next word).
   `IOB_WIRE2WIRE((tvalid & !received_tlast) | (received_tlast & rstrb_int != 4'hf), rstrb_int_en)
   `IOB_WIRE2WIRE(((&rstrb_int) ? 4'd0 : rstrb_int<<TDATA_W/8) + default_rstrb_value, rstrb_int_next_val)
    iob_reg_re #(4,4'd0) rstrb_int_reg (clk_i, arst_i, cke_i, rst | reset_register_last, rstrb_int_en, rstrb_int_next_val, rstrb_int);

	//Delay TLAST by one clock
   `IOB_VAR(tlast_delayed, 1)
    iob_reg #(1,0) tlast_delayed_reg (clk_i, arst_i, cke_i, tlast, tlast_delayed);

	//Store rstrb one clock after TLAST was received 
   `IOB_VAR(rstrb, 4)
   wire [3:0] rstrb
    iob_reg_re #(1,1'b0) rstrb_reg (clk_i, arst_i, cke_i, rst | reset_register_last, tlast_delayed, rstrb_int, rstrb);

   iob_reg #(.DATA_W(1))
   axistreamin_last (
       .clk        (clk),
       .arst       (rst),
       .arst_val   (1'b0),
       .rst        (reset_register_last), 
       .rst_val    (1'b0),
       .en         (tvalid & tready), //Store tlast value if signal is valid and ready for new one
       .data_in    (tlast),
       .data_out   (received_tlast)
   );

   iob_fifo_sync
     #(
       .W_DATA_W (TDATA_W),
       .R_DATA_W (32),
       .ADDR_W (FIFO_DEPTH_LOG2)
       )
   fifo
     (
      .arst            (rst_delayed),
      .rst             (1'd0),
      .clk             (clk),
      .ext_mem_w_en    (ext_mem_w_en),
      .ext_mem_w_data  (ext_mem_w_data),
      .ext_mem_w_addr  (ext_mem_w_addr),
      .ext_mem_r_en    (ext_mem_r_en),
      .ext_mem_r_addr  (ext_mem_r_addr),
      .ext_mem_r_data  (ext_mem_r_data),
      //read port
      .r_en            (AXISTREAMIN_OUT_ren),
      .r_data          (AXISTREAMIN_OUT_rdata),
      .r_empty         (AXISTREAMIN_EMPTY_rdata[0]),
      //write port
      .w_en            ((tvalid & !received_tlast) | (received_tlast & rstrb_int != 4'hf)), //Fill FIFO if is valid OR fill with dummy values to complete 32bit word
      .w_data          (tdata),
      .w_full          (fifo_full),
      .level           ()
      );
  
   `IOB_WIRE2WIRE(~fifo_full & !received_tlast, tready) //Only ready for more data when fifo not full and CPU read AXISTREAMIN_LAST data

	//Convert ext_mem_w_en signal to byte enable signal
	localparam num_bytes_per_input = TDATA_W/8;
   `IOB_WIRE(ext_mem_w_en_be, 32/8)
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
      .clk      (clk),
      .w_en     (ext_mem_w_en_be),
      .w_data   (ext_mem_w_data),
      .w_addr   (ext_mem_w_addr),
      .r_en     (ext_mem_r_en),
      .r_data   (ext_mem_r_data),
      .r_addr   (ext_mem_r_addr)
   );
   
endmodule


