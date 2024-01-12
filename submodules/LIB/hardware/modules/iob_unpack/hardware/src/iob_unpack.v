`timescale 1ns / 1ps

module iob_unpack #(
   parameter WDATA_W = 21,
   parameter RDATA_W = 21,
   parameter WORD_W = 21
) (
`include "clk_en_rst_s_port.vs"
   input                 rst_i,
   
   input [WORD_W:0]      word_width_i,
   input                 wrap_i,

   input [ RDATA_W-1:0] r_data_i,
   input                 r_ready_i,
   output                r_read_o,

   output [WDATA_W-1:0] w_data_o,
   output                w_write_o,
   input                 w_ready_i
   );

   //read data word width with the right number of bits
   localparam [$clog2(RDATA_W):0] RDATA_W_INT = {1'b1, {$clog2(RDATA_W){1'b0}}};

   //read and write fifos
   reg read_fifo;
   reg write_fifo;
   
   // word register
   wire [2*RDATA_W-1:0]      data;
   reg [2*RDATA_W-1:0]       data_nxt;

   // shift data to write and read
   wire [2*RDATA_W-1:0]      data_shifted;

   //program counter (fsm state)
   reg [1:0]                  pcnt_nxt;
   wire [1:0]                 pcnt;

   //word width accumulator
   wire [$clog2(RDATA_W):0]  acc;
   reg [$clog2(RDATA_W):0]   acc_nxt;

   //shift value
   wire [$clog2(RDATA_W)-1:0] shift_val;


   //output data
   assign data_shifted = data >> (wrap_i? 1'b0: -shift_val);
   assign w_data_o = data_shifted[RDATA_W-1-:WDATA_W];
   assign w_write_o = write_fifo;
   assign r_read_o = read_fifo;
   assign shift_val = acc - RDATA_W_INT;

   //program (fsm)
   always @* begin

      pcnt_nxt = pcnt + 1'b1;
      read_fifo = 1'b0;
      data_nxt = data;
      write_fifo = 1'b0;
      acc_nxt = acc;
      
      case (pcnt)
        
        0: begin //wait to read data from input FIFO
           if (!r_ready_i) begin
              pcnt_nxt = 1'b0;
           end else begin
              read_fifo = 1'b1;
           end
        end

        1: begin //load data
           //(re)start accumulator
           acc_nxt =  wrap_i? {$clog2(RDATA_W)+1{1'b0}} : acc - RDATA_W_INT;
           //shift and load data
           data_nxt = (data << (RDATA_W_INT-acc)) | r_data_i;
        end

        default: begin //write data to output FIFO and shift data until all data is written
           if ( acc < RDATA_W_INT ) begin
              pcnt_nxt = pcnt;
              if (w_ready_i) begin
                 write_fifo = 1'b1;
                 acc_nxt = acc + word_width_i;
                 data_nxt = data << word_width_i;
              end
           end else begin
              if (r_ready_i) begin
                 read_fifo = 1'b1;
                 pcnt_nxt = 2'd1;
              end else begin
                 pcnt_nxt = 2'd0;
              end
           end // else: !if( acc < RDATA_W_INT )
        end // default
      endcase
   end // always @ *
   

   //program counter register
   iob_reg_r #(
      .DATA_W(2),
      .RST_VAL(2'b0)
   ) pcnt_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(pcnt_nxt),
      .data_o(pcnt)
   );
   
   //word width accumulator register
   iob_reg_r #(
      .DATA_W ($clog2(RDATA_W)+1),
      .RST_VAL({$clog2(RDATA_W)+1{1'b0}})
   ) acc_reg (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i     (rst_i),
      .data_i    (acc_nxt),
      .data_o    (acc)
   );

   //data word register
   iob_reg_r #(
      .DATA_W(2*RDATA_W),
      .RST_VAL({2*RDATA_W{1'b0}})
   ) data_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(data_nxt),
      .data_o(data)
   );
     
endmodule

