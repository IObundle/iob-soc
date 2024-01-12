`timescale 1ns / 1ps

module iob_pack #(
   parameter R_DATA_W = 21,
   parameter W_DATA_W = 21
) (
`include "clk_en_rst_s_port.vs"
   input                      rst_i,
   
   input [$clog2(R_DATA_W):0] word_width_i,
   input                      wrap_i,

   input [ W_DATA_W-1:0]      r_data_i,
   input                      r_ready_i,
   output                     r_read_o,

   output [R_DATA_W-1:0]      w_data_o,
   output                     w_write_o,
   input                      w_ready_i
   );

   //read and write fifos
   reg read_fifo;
   reg write_fifo;

   // word register
   wire [(2*R_DATA_W)-1:0] data;
   reg [(2*R_DATA_W)-1:0]  data_nxt;
   
   
   // shift data to write and read
   wire [2*W_DATA_W-1:0]   w_data_shifted;
   
   //program counter (fsm state)
   reg [1:0]               pcnt_nxt;
   wire [1:0]              pcnt;
   
   //word width accumulator
   wire [$clog2(R_DATA_W):0] acc;
   reg [$clog2(R_DATA_W):0]  acc_nxt;
   
   //shift value
   wire [$clog2(R_DATA_W)-1:0] shift_val;
   reg [$clog2(R_DATA_W)-1:0]  shift_val_nxt;
   
   
   //output data
   assign w_data_shifted = data >> (wrap_i? 1'b0: shift_val);
   assign w_data_o = w_data_shifted[R_DATA_W-1-:W_DATA_W];
   assign w_write_o = write_fifo;
   assign r_read_o = read_fifo; 
   
   
   //program
   always @* begin

      pcnt_nxt = pcnt + 1'b1;
      read_fifo = 1'b0;
      data_nxt = data;
      shift_val_nxt = shift_val;
      write_fifo = 1'b0;
      acc_nxt = acc;

      case (pcnt)
        
        0: begin //read data from input FIFO
           if (!r_ready_i) begin
              pcnt_nxt = pcnt;
           end else begin
              read_fifo = 1'b1;
           end
        end

        1: begin //shift and load data until word width is reached
           if (acc < W_DATA_W ) begin
              acc_nxt = acc + word_width_i;
              data_nxt = (data << word_width_i) | r_data_i;           
              pcnt_nxt = 2'd0;
           end else begin
              //restart accumulator
              acc_nxt =  wrap_i? {$clog2(R_DATA_W)+1{1'b0}}: acc -(1'b1 << $clog2(R_DATA_W));
              //save shift value
              shift_val_nxt = (wrap_i? {$clog2(R_DATA_W){1'b0}} : acc -(1'b1 << $clog2(R_DATA_W)));
           end
        end

        default: begin //write data to output FIFO
           if (!w_ready_i) begin
              pcnt_nxt = pcnt;
           end else begin
              write_fifo = 1'b1;
              pcnt_nxt = 2'd1; //go process next word
           end
        end
      endcase
      
   end

   
   //word width accumulator register
   iob_reg_r #(
      .DATA_W ($clog2(R_DATA_W)+1),
      .RST_VAL({$clog2(R_DATA_W)+1{1'b0}})
   ) acc_reg (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i     (rst_i),
      .data_i    (acc_nxt),
      .data_o    (acc)
   );

   //data word register
   iob_reg_r #(
      .DATA_W(2*R_DATA_W),
      .RST_VAL({2*R_DATA_W{1'b0}})
   ) data_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(data_nxt),
      .data_o(data)
   );

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
   
    //shift value register
   iob_reg_r #(
      .DATA_W($clog2(R_DATA_W)),
      .RST_VAL({$clog2(R_DATA_W){1'b0}})
   ) shift_val_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(shift_val_nxt),
      .data_o(shift_val)
   );

endmodule

 
