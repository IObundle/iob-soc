`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_pack #(
   parameter PACKED_DATA_W   = 21,
   parameter UNPACKED_DATA_W = 21
) (
   `include "clk_en_rst_s_port.vs"

   input                             rst_i,
   input [$clog2(UNPACKED_DATA_W):0] len_i,
   input                             wrap_i,

   //read unpacked data to be packed
   output                            read_o,
   input                             rready_i,
   input [UNPACKED_DATA_W-1:0]       rdata_i,

   //write packed data
   output                            write_o,
   input                             wready_i,
   output [PACKED_DATA_W-1:0]        wdata_o
);

   //bfifo size
   localparam BFIFO_REG_W = 2 *
   `IOB_MAX(UNPACKED_DATA_W, PACKED_DATA_W);

   //packed data width as a bit vector
   localparam [$clog2(PACKED_DATA_W):0] PACKED_DATA_W_INT = {1'b1, {$clog2(PACKED_DATA_W) {1'b0}}};

   //data register
   wire                             data_read;
   reg                              data_read_nxt;

   //bit fifo control
   wire [    $clog2(BFIFO_REG_W):0] push_level;
   reg                              push;
   reg  [$clog2(UNPACKED_DATA_W):0] push_len;
   reg  [      UNPACKED_DATA_W-1:0] push_data;

   wire [    $clog2(BFIFO_REG_W):0] pop_level;
   reg                              pop;
   //pop length is always the unpacked data width

   //external fifo control
   reg                              read;
   reg                              write;

   //wrapping control accumulator
   wire [$clog2(PACKED_DATA_W):0] wrap_acc_nxt;
   wire [$clog2(PACKED_DATA_W):0] wrap_acc;
   wire [$clog2(PACKED_DATA_W)-1:0] wrap_rem;
   wire                             wrap_now;

   //read unpacked data from external input fifo
   assign read_o       = read;
   //write packed data to external output fifo
   assign write_o      = write;

   //wrapping control
   assign wrap_now     = wrap_i & (wrap_acc > PACKED_DATA_W_INT);
   assign wrap_rem     = wrap_acc - PACKED_DATA_W_INT;
   assign wrap_acc_nxt = read? wrap_acc + len_i: wrap_now? 0: wrap_acc;

   //control logic
   always @* begin
      pop           = 1'b0;
      //pop length is always the unpacked data width

      push          = 1'b0;
      push_len      = len_i;
      push_data     = rdata_i << (UNPACKED_DATA_W - len_i);

      read          = 1'b0;
      write         = 1'b0;

      data_read_nxt = data_read;

      if (data_read && (push_level >= len_i)) begin  //push and read unpacked data from pin
         push = 1'b1;
         if (rready_i) begin
            read = 1'b1;
         end else begin
            data_read_nxt = 1'b0;
         end
         read = 1'b1;

         if(wrap_now) begin
            push_len = wrap_rem;
         end else
           read = 1'b1;
      end else if ((pop_level >= PACKED_DATA_W_INT) && wready_i) begin //pop and write packed data to output fifo
         pop   = 1'b1;
         write = 1'b1;
      end else if ((!data_read) && rready_i) begin  //read new unpacked data from pin
         read          = 1'b1;
         data_read_nxt = 1'b1;
      end
   end

   iob_bfifo #(
      .WDATA_W(UNPACKED_DATA_W),
      .RDATA_W(PACKED_DATA_W),
      .REG_W  (BFIFO_REG_W)
   ) bfifo (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i   (rst_i),
      //push unpacked data to be packed
      .write_i (push),
      .wlen_i  (push_len),
      .wdata_i (push_data),
      .wlevel_o(push_level),
      //pop packed data to be output
      .read_i  (pop),
      .rlen_i  (PACKED_DATA_W_INT),
      .rdata_o (wdata_o),
      .rlevel_o(pop_level)
   );

   //data read flag (data is present at the input)
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) data_loaded_valid_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(data_read_nxt),
      .data_o(data_read)
   );

   //wrap control accumulator
   iob_reg_r #(
      .DATA_W ($clog2(PACKED_DATA_W)+1),
      .RST_VAL({$clog2(PACKED_DATA_W)+1{1'b0}})
   ) wrap_acc_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(wrap_acc_nxt),
      .data_o(wrap_acc)
   );

endmodule


