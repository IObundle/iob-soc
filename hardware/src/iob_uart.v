`timescale 1ns/1ps
`include "iob_uart.vh"

module iob_uart (
	         input             clk,
	         input             rst,

                 //cpu interface 
	         input             valid,
                 input [2:0]       address,
	         input [31:0]      wdata,
                 input             wstrb,
	         output reg [31:0] rdata,
	         output reg        ready,

                 //serial i/f
	         output            txd,
	         input             rxd,
                 input             cts,
                 output            rts
                 );

   // internal registers
   wire                            tx_wait;
   reg [31:0]                      cfg_divider;
   reg                             tx_en;
   reg                             rx_en;
   
   // receiver
   reg [3:0]                       recv_state;
   reg [31:0]                      recv_divcnt;
   reg [7:0]                       recv_pattern;
   reg [7:0]                       recv_buf_data;
   reg                             recv_buf_valid;
   
   // sender
   reg [9:0]                       send_pattern;
   reg [3:0]                       send_bitcnt;
   reg [15:0]                      send_divcnt;
   
   // register access
   reg                             data_write_en;
   wire                            data_read_en;
   reg                             div_write_en;
   reg                             rst_soft_en;
   reg                             tx_en_en;
   reg                             rx_en_en;
   
   // reset
   wire                            rst_int;
   reg                             rst_soft;

   //flow control
   reg [1:0]                       cts_int;
   reg                             rts_en;
   
   
   //soft reset pulse
   always @(posedge clk, posedge rst)
     if(rst)
       rst_soft <= 1'b0;
     else if (rst_soft_en)
       rst_soft <= wdata[0];
     else
       rst_soft <= 1'b0;

   assign rst_int = rst | rst_soft;

   
   // register cpu command and produce ready
   reg [2:0]       address_reg;
   reg             wstrb_reg;
   always @(posedge clk, posedge rst)
     if(rst) begin
       ready <= 1'b0;
      end else begin
         ready <= valid;
         wstrb_reg <= wstrb;
         address_reg <= address;
      end

   //transmit enable
   always @(posedge clk, posedge rst_int)
     if(rst_int)
       tx_en <= 1'b0;
     else if (tx_en_en)
       tx_en <= wdata[0];
   
   //receive enable
   always @(posedge clk, posedge rst_int)
     if(rst_int)
       rx_en <= 1'b0;
     else if (rx_en_en)
       rx_en <= wdata[0];
   
   //request to send me data
   assign rts = rts_en & rx_en;
   
   //cts synchronizer
   always @(posedge clk) 
     cts_int <= {cts_int[0], cts};
   
   
   ////////////////////////////////////////////////////////
   // CPU ACCESS
   ////////////////////////////////////////////////////////

   // WRITE
   always @* begin
      data_write_en = 1'b0;
      div_write_en = 1'b0;
      rst_soft_en = 1'b0;
      rx_en_en = 1'b0;  
      tx_en_en = 1'b0;  
      if(valid & wstrb)
        case (address)
          `UART_DIV: div_write_en = 1'b1;
          `UART_DATA: data_write_en = 1'b1;
          `UART_SOFT_RESET: rst_soft_en = 1'b1;
          `UART_TXEN: tx_en_en = 1'b1;
          `UART_RXEN: rx_en_en = 1'b1;
          default:;
        endcase
   end // always @ *

   //READ
   always @* begin
      rdata = `DATA_W'h0;
      if(ready & ~wstrb_reg)
        case (address_reg)
          `UART_WRITE_WAIT: rdata = {31'd0, tx_wait | ~cts_int[1]};
          `UART_DIV       : rdata = cfg_divider;
          `UART_DATA      : rdata = recv_buf_data;
          `UART_READ_VALID: rdata = {31'd0,recv_buf_valid};
          default         : rdata = `DATA_W'h0;
        endcase
   end

   assign data_read_en = valid & ~wstrb & (address == `UART_DATA);

   // internal registers
   assign tx_wait = (send_bitcnt != 4'd0);

   // division factor
   always @(posedge clk)
     if (rst_int)
       cfg_divider <= 1;
     else if (div_write_en)
       cfg_divider <= wdata;

   ////////////////////////////////////////////////////////
   // Serial RX
   ////////////////////////////////////////////////////////

   always @(posedge clk, posedge rst_int) begin
      if (rst_int) begin
         recv_state <= 0;
         recv_divcnt <= 0;
         recv_pattern <= 0;
         recv_buf_data <= 0;
         recv_buf_valid <= 1'b0;
         rts_en <= 1'b1;
         
      end else begin
         recv_divcnt <= recv_divcnt + 1;
         if (data_read_en) begin
            recv_buf_valid <= 1'b0;
            rts_en <= 1'b1;
         end
         case (recv_state)
           
           // Detect start bit (i.e., when RX line goes to low)
           4'd0: begin
              if (!rxd) begin
                 recv_state <= 1;
                 rts_en <= 1'b0;
              end
              recv_divcnt <= 1;
           end
           
           // Forward in time to the middle of the start bit
           4'd1:
             if ( (2*recv_divcnt) >= cfg_divider) begin
                recv_state <= 2;
                recv_divcnt <= 1;
             end
           
           // Sample the 8 bits from the RX line and put them in the shift register
           default: // states 4'd2 through 4'd9
             if (recv_divcnt >= cfg_divider) begin
                recv_pattern <= {rxd, recv_pattern[7:1]};
                recv_state <= recv_state + 1'b1;
                recv_divcnt <= 1;
             end
           
           // Put the received byte in the output data register; drive read valid to high
           4'd10:
             if (recv_divcnt == cfg_divider) begin
                recv_buf_data <= recv_pattern;
                recv_buf_valid <= 1'b1;
                recv_state <= 0;
             end
           
         endcase // case (recv_state)
      end // else: !if(rst_int)
   end //always @
   
   ////////////////////////////////////////////////////////
   // Serial TX
   ////////////////////////////////////////////////////////
   
   //div counter
   always @(posedge clk, posedge rst_int)
     if(rst_int) //reset
       send_divcnt <= 16'd0;
     else if(data_write_en) //set
       send_divcnt <= 16'd1;
     else if(send_divcnt == cfg_divider) //wrap around
       send_divcnt <= 16'd1;             
     else if(send_divcnt != 16'd0) //increment
       send_divcnt <= send_divcnt + 1'b1;

   //send bit counter
   always @(posedge clk, posedge rst_int)
     if (rst_int) //reset
       send_bitcnt <= 4'd0;
     else if (data_write_en) //load 
       send_bitcnt <= 4'd10;
     else if (send_bitcnt != 0 && send_divcnt == cfg_divider) //decrement
       send_bitcnt <= send_bitcnt - 1'b1;

   // shift register
   always @(posedge clk, posedge rst_int)
     if (rst_int) //reset
       send_pattern <= ~10'b0;
     else if (data_write_en) //load
       send_pattern <= {1'b1, wdata[7:0], 1'b0};
     else if (send_bitcnt && send_divcnt == cfg_divider) 
       //shift right
       send_pattern <= {1'b1, send_pattern[9:1]};

   // send serial comm
   assign txd = send_pattern[0] | ~tx_en;

endmodule

