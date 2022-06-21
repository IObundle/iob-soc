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
   `IOB_INPUT(tdata, 8),
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
   `IOB_WIRE(ext_mem_w_data, TDATA_W+1)
   `IOB_WIRE(ext_mem_w_addr, FIFO_DEPTH_LOG2)
   `IOB_WIRE(ext_mem_r_en, 1)
   `IOB_WIRE(ext_mem_r_data, TDATA_W+1)
   `IOB_WIRE(ext_mem_r_addr, FIFO_DEPTH_LOG2)
   //Delay rst by one clock, because tvalid signal after rested may come delayed from AXISTREAMOUT peripheral
   `IOB_VAR(rst_delayed, 1)
   `IOB_REG(clk, rst_delayed, rst)


   // Set unused rdata bits to 0
   `IOB_WIRE2WIRE({(`AXISTREAMIN_OUT_W-9){1'b0}}, AXISTREAMIN_OUT_rdata[`AXISTREAMIN_OUT_W-1:9])
   `IOB_WIRE2WIRE({(`AXISTREAMIN_EMPTY_W-1){1'b0}}, AXISTREAMIN_EMPTY_rdata[`AXISTREAMIN_EMPTY_W-1:1])
  
   iob_fifo_sync
     #(
       .W_DATA_W (TDATA_W+1),
       .R_DATA_W (9),
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
      .r_data          (AXISTREAMIN_OUT_rdata[8:0]),
      .r_empty         (AXISTREAMIN_EMPTY_rdata[0]),
      //write port
      .w_en            (tvalid),
      .w_data          ({tlast, tdata}), //Store TLAST signal in msb
      .w_full          (fifo_full),
      .level           ()
      );
  
   `IOB_WIRE2WIRE(~fifo_full, tready)

   //FIFO RAM
   iob_ram_2p #(
      .DATA_W (TDATA_W+1),
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


