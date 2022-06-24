`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in 
  # (
     parameter TDATA_W = 8, //PARAM axi stream tdata width
     parameter FIFO_DEPTH_LOG2 = 10, //PARAM depth of FIFO
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_axistream_in_swreg_ADDR_W //MACRO CPU address section width
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs
   `IOB_INPUT(tdata, TDATA_W),
   `IOB_INPUT(tvalid, 1),
   `IOB_OUTPUT(tready, 1),
   `IOB_INPUT(tlast, 1), 
`include "iob_gen_if.vh"
   );

//BLOCK Register File & Configuration control and status register file.
`include "iob_axistream_in_swreg_gen.vh"
      
   `IOB_WIRE(fifo_full, 1)
   //FIFO RAM
   `IOB_WIRE(ext_mem_w_en, 1)
   `IOB_WIRE(ext_mem_w_data, TDATA_W)
   `IOB_WIRE(ext_mem_w_addr, FIFO_DEPTH_LOG2)
   `IOB_WIRE(ext_mem_r_en, 1)
   `IOB_WIRE(ext_mem_r_data, TDATA_W)
   `IOB_WIRE(ext_mem_r_addr, FIFO_DEPTH_LOG2)
   //Delay rst by one clock, because tvalid signal after rested may come delayed from AXISTREAMOUT peripheral
   `IOB_VAR(rst_delayed, 1)
   `IOB_REG(clk, rst_delayed, rst)

   // Set unused rdata bits to 0
   `IOB_WIRE2WIRE({(`AXISTREAMIN_EMPTY_W-1){1'b0}}, AXISTREAMIN_EMPTY_rdata[`AXISTREAMIN_EMPTY_W-1:1])
   `IOB_WIRE2WIRE({(`AXISTREAMIN_LAST_W-5){1'b0}}, AXISTREAMIN_LAST_rdata[`AXISTREAMIN_LAST_W-1:5])

   //Reset register when it is read and FIFO is empty
   `IOB_WIRE(reset_register_last, 1)
   `IOB_WIRE2WIRE(valid & !wstrb & (address == `AXISTREAMIN_LAST_ADDR) & AXISTREAMIN_EMPTY_rdata[0],reset_register_last)

	//Keep track of valid bytes in lastest word of FIFO and
	//keep filling rstrb_int after receiving TLAST to count how many random
	//bytes to fill word in FIFO.
   `IOB_VAR(rstrb_int, 4)
   `IOB_REG_RE(clk, rst | &rstrb_int | reset_register_last, 1'b1, tvalid & !(AXISTREAMIN_LAST_rdata[4] & rstrb_int == 4'b1), rstrb_int, (rstrb_int<<TDATA_W/8)+(TDATA_W/8){1'b1})

	//Store rstrb at the moment TLAST was received 
   `IOB_VAR(rstrb, 4)
   `IOB_REG_RE(clk, rst | reset_register_last, 1'b0, tlast, rstrb, rstrb_int)
   `IOB_WIRE2WIRE(rstrb,AXISTREAMIN_LAST_rdata[3:0]) //Set bits [3:0] of AXISTREAMIN_LAST register as rstrb

   iob_reg #(.DATA_W(1))
   axistreamin_last (
       .clk        (clk),
       .arst       (rst),
       .arst_val   (1'b0),
	    .rst        (reset_register_last), 
       .rst_val    (1'b0),
       .en         (tlast), //Set this register when receives TLAST signal
       .data_in    (1'b1),
       .data_out   (AXISTREAMIN_LAST_rdata[4]) //Set bit 4 of AXISTREAMIN_LAST register as signal of received TLAST
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
      .w_en            ((tvalid & !AXISTREAMIN_LAST_rdata[4]) | (AXISTREAMIN_LAST_rdata[4] & rstrb_int == 4'b1)), //Fill FIFO if is valid OR fill with dummy values to complete 32bit word
      .w_data          (tdata),
      .w_full          (fifo_full),
      .level           ()
      );
  
   `IOB_WIRE2WIRE(~fifo_full & !AXISTREAMIN_LAST_rdata[4], tready) //Only ready for more data when fifo not full and CPU read AXISTREAMIN_LAST data

   //FIFO RAM
   iob_ram_2p #(
      .DATA_W (TDATA_W),
      .ADDR_W (FIFO_DEPTH_LOG2)
    )
   fifo_memory
   (
      .clk      (clk),
      .w_en     (ext_mem_w_en),
      .w_data   (ext_mem_w_data),
      .w_addr   (ext_mem_w_addr),
      .r_en     (ext_mem_r_en),
      .r_data   (ext_mem_r_data),
      .r_addr   (ext_mem_r_addr)
   );
   
endmodule


