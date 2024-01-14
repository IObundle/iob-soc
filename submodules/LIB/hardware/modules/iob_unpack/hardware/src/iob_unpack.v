`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_unpack #(
   parameter PACKED_DATA_W = 21,
   parameter UNPACKED_DATA_W = 21
) (
   `include "clk_en_rst_s_port.vs"

   input                             rst_i,
   
   input [$clog2(UNPACKED_DATA_W):0] len_i,
   input                             wrap_i,

   //read packed data to be unpacked
   output                            read_o,
   input                             rready_i,
   input [PACKED_DATA_W-1:0]         rdata_i,

   //write unpacked data
   output                            write_o,
   input                             wready_i,
   output [UNPACKED_DATA_W-1:0]      wdata_o
   );

   //bfifo size
   localparam BFIFO_REG_W = `IOB_MAX(PACKED_DATA_W, UNPACKED_DATA_W);

   //packed data width as a bit vector
   localparam [$clog2(PACKED_DATA_W):0] PACKED_DATA_W_INT = {1'b1, {$clog2(PACKED_DATA_W){1'b0}}};

   //data register
   wire                              data_read;
   reg                               data_read_nxt;

   //bit fifo control
   reg                               push;
   wire [$clog2(BFIFO_REG_W):0]      push_level;
   reg                               pop;
   reg [$clog2(UNPACKED_DATA_W):0]   pop_len;
   wire [$clog2(BFIFO_REG_W):0]      pop_level;

   //external fifo control
   reg                               read;
   reg                               write;

   //read unpacked data fifo
   assign read_o = read;
   assign write_o = write;
   
   always @* begin
      pop = 0;
      pop_len = len_i;
      
      push = 0;

      read = 0;
      write = 1'b0;

      data_read_nxt = data_read;
      
      //prioritize pop over push
      if (pop_level >= len_i && wready_i) begin
         pop = 1'b1;
         write = 1'b1;
      end else if (wrap_i && pop_level > 0 && pop_level < len_i) begin //wrap up by discarding data
         pop_len = pop_level;
         pop = 1'b1; 
      end else if (data_read && push_level >= PACKED_DATA_W_INT && rready_i) begin
         push = 1'b1;
         read = 1'b1;
         data_read_nxt = 1'b1;
      end else if (!data_read && rready_i) begin
         read = 1'b1;
         data_read_nxt = 1'b1;
      end
   end
   
   iob_bfifo 
     #(
            .WDATA_W(PACKED_DATA_W),
            .RDATA_W(UNPACKED_DATA_W),
            .REG_W(BFIFO_REG_W)
       ) bfifo (
`include "clk_en_rst_s_s_portmap.vs"
                .rst_i(rst_i),
                
                .write_i(push),
                .wlen_i(PACKED_DATA_W_INT),
                .wdata_i(rdata_i),
                .wlevel_o(push_level),

                .read_i(pop),
                .rlen_i(pop_len),
                .rdata_o(wdata_o),
                .rlevel_o(pop_level)
                );

   //data loaded register
   iob_reg_r #(
      .DATA_W(1),
      .RST_VAL(1'b0)
   ) data_read_valid_reg (
`include "clk_en_rst_s_s_portmap.vs"
     .rst_i(rst_i),
     .data_i(data_read_nxt),
     .data_o(data_read)
   );

endmodule


