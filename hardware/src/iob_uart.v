`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_uart.vh"

module iob_uart 
  # (
     parameter ADDR_W = `UART_ADDR_W, //NODOC Address width
     parameter DATA_W = `UART_RDATA_W, //NODOC CPU data width
     parameter WDATA_W = `UART_WDATA_W //NODOC Data word width on writes
     )

  (
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

   `OUTPUT(interrupt, 1),

   `OUTPUT(txd, 1),
   `INPUT(rxd, 1),
   `INPUT(cts, 1),
   `OUTPUT(rts, 1),
`include "gen_if.v"
   );

//BLOCK Register File & Holds the current configuration of the UART as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
`include "UARTsw_reg.v"
`include "UARTsw_reg_gen.v"

   `SIGNAL_OUT(tx_wait, 1)
   `SIGNAL_OUT(rx_wait, 1)

   // read registers
   `COMB UART_WRITE_WAIT = tx_wait;
   `COMB UART_READ_VALID = ~rx_wait;
   
   //ready signal   
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)
   `SIGNAL2OUT(ready, ready_int)

   uart_core uart0 
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(UART_SOFT_RESET),
      .tx_en(UART_TXEN),
      .rx_en(UART_RXEN),
      .tx_wait(tx_wait),
      .rx_wait(rx_wait),
      .tx_data(wdata[DATA_W/4-1:0]),
      .rx_data(rdata),
      .data_write_en(valid & wstrb & (address == `UART_DATA_ADDR)),
      .data_read_en(valid & !wstrb & (address == `UART_DATA_ADDR)),
      .bit_duration(UART_DIV)
      );
   
endmodule

module uart_core 
  (
   input        clk,
   input        rst,
   input        rst_soft,
   input        tx_en,
   input        rx_en,
   input [`UART_W:0]  tx_data,
   output [7:0] rx_data,
   output       tx_wait,
   output       rx_wait,
   input        rxd,
   output       txd,
   input        cts,
   output       rts,
   input        data_write_en,
   input        data_read_en,
   input [15:0] bit_duration
   );
   
                  
   // receiver
   reg [3:0] recv_state;
   reg [15:0] recv_counter;
   reg [7:0]  recv_pattern;
   reg [7:0]  recv_buf_data;
   reg        recv_buf_valid;
   
   // sender
   reg [9:0]  send_pattern;
   reg [3:0]  send_bitcnt;
   reg [15:0] send_counter;
   
  
   //combined soft/hard reset
   wire       rst_int = rst | rst_soft;
  
   //flow control
   reg [1:0]  cts_int;
      
   assign tx_wait = (send_bitcnt != 4'd0) | ~cts_int[1];
   assign rx_wait = ~recv_buf_valid;

   //request to send me data
   assign rts = rx_en;
   
   //cts synchronizer
   always @(posedge clk) 
     cts_int <= {cts_int[0], cts};
      
   ////////////////////////////////////////////////////////
   // Serial TX
   ////////////////////////////////////////////////////////
   
   //div counter
   always @(posedge clk, posedge rst_int)
     if(rst_int) //reset
       send_counter <= 16'd0;
     else if(data_write_en) //set
       send_counter <= 16'd1;
     else if(send_counter == bit_duration) //wrap around
       send_counter <= 16'd1;             
     else if(send_counter != 16'd0) //increment
       send_counter <= send_counter + 1'b1;

   //send bit counter
   always @(posedge clk, posedge rst_int)
     if (rst_int) //reset
       send_bitcnt <= 4'd0;
     else if (data_write_en) //load 
       send_bitcnt <= 4'd10;
     else if (send_bitcnt != 0 && send_counter == bit_duration) //decrement
       send_bitcnt <= send_bitcnt - 1'b1;

   // shift register
   always @(posedge clk, posedge rst_int)
     if (rst_int) //reset
       send_pattern <= ~10'b0;
     else if (data_write_en) //load
       send_pattern <= {1'b1, wdata[7:0], 1'b0};
     else if (send_bitcnt && send_counter == bit_duration) 
       //shift right
       send_pattern <= {1'b1, send_pattern[9:1]};

   // send serial comm
   assign txd = send_pattern[0] | ~tx_en;



   ////////////////////////////////////////////////////////
   // Serial RX
   ////////////////////////////////////////////////////////

   always @(posedge clk, posedge rst_int) begin
      if (rst_int) begin
         recv_state <= 0;
         recv_counter <= 0;
         recv_pattern <= 0;
         recv_buf_data <= 0;
         recv_buf_valid <= 1'b0;
         
      end else begin

         recv_counter <= recv_counter + 1;
         if (data_read_en)
            recv_buf_valid <= 1'b0;


         case (recv_state)
           
           4'd0: begin
              if (!rxd) //start bit received 
                 recv_state <= 1;
              recv_counter <= 1; //start cycle couter
           end
           
           
           4'd1: // wait until middle of start bit
             if ( recv_counter == (bit_duration/2) ) begin
                recv_state <= 2;
                recv_counter <= 1;
             end
           default: // states 4'd2 through 4'd9
             if (recv_counter == bit_duration) begin
                recv_pattern <= {rxd, recv_pattern[7:1]}; //sample rx line
                recv_state <= recv_state + 1'b1;
                recv_counter <= 1;
             end
 
           4'd10:
             if (recv_counter == bit_duration) begin
                recv_buf_data <= recv_pattern;
                recv_buf_valid <= 1'b1;
                recv_state <= 0;
             end
           
         endcase
      end
   end

   
endmodule

