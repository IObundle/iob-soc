`timescale 1ns/1ps
`include "iob_uart.vh"

module uart_core 
  (
   input                         clk,
   input                         rst,
   input                         rst_soft,
   input                         tx_en,
   input                         rx_en,
   input [`UART_DATA_W-1:0]      tx_data,
   output reg [`UART_DATA_W-1:0] rx_data,
   output reg                    tx_ready,
   output reg                    rx_ready,
   input                         rxd,
   output                        txd,
   input                         cts,
   output                        rts,
   input                         data_write_en,
   input                         data_read_en,
   input [`UART_WDATA_W-1:0]     bit_duration
   );
   
                  
   //COMBINED SOFT/HARD RESET
   wire       rst_int = rst | rst_soft;
  
   //FLOW CONTROL
   reg [1:0]  cts_int;
      
   //request to send (rts) me data
   assign rts = rx_en;
   
   //clear to send (cts) synchronizer
   always @(posedge clk) 
     cts_int <= {cts_int[0], cts};


   ////////////////////////////////////////////////////////
   // Serial TX
   ////////////////////////////////////////////////////////

   // sender
   reg [9:0]  tx_pattern; //start(1) + data(8) + stop(1) = 10 bits
   reg [3:0]  tx_bitcnt;
   reg [15:0] tx_cyclecnt;

   // serial tx bit
   assign txd = tx_pattern[0];
   
   //tx program
   reg  tx_pc;   
   always @(posedge clk, posedge rst_int)

     if(rst_int) begin 

        tx_pc <= 1'b0;
        tx_ready <= 1'b1;
        tx_pattern <= ~10'b0;
        tx_bitcnt <= 1'b0;
        tx_cyclecnt <= 1'b0;

     end else if(tx_en && cts_int[1]) begin

        tx_pc <= tx_pc + 1'b1; //increment pc by default

        case (tx_pc)

          0: begin //wait for data to send
             tx_pattern <= {1'b1, tx_data[7:0], 1'b0};
             tx_ready <= 1'b1;
             tx_bitcnt <= 1'b0;
             tx_cyclecnt <= 1'b0;
             if(!data_write_en) begin
                tx_pc <= tx_pc;
                tx_ready <= 1'b0;
             end
          end

          1: begin //send pattern
             tx_pc <= tx_pc; //stay here util pattern sent
             if(tx_bitcnt == 4'd10 && tx_cyclecnt == bit_duration) //pattern sent: restart program 
               tx_pc <= 1'b0;
             else if(tx_cyclecnt == bit_duration) begin //bit sent: send next
                tx_bitcnt <= tx_bitcnt + 1'b1;
                tx_cyclecnt <= 1'b0;
             end else 
                tx_cyclecnt <= tx_cyclecnt + 1'b1; //increment cycle counter
          end
          
          default:;
          
        endcase

     end else begin              
        
        tx_pc <= 1'b0;
        tx_ready <= 1'b1;
        tx_pattern <= ~10'b0;
        tx_bitcnt <= 1'b0;
        tx_cyclecnt <= 1'b0;

     end


   ////////////////////////////////////////////////////////
   // Serial RX
   ////////////////////////////////////////////////////////

   // receiver program
   reg [2:0] rx_pc;
   reg [15:0] rx_cyclecnt;
   reg [3:0]  rx_bitcnt;
   
   always @(posedge clk, posedge rst_int) begin

      if (rst_int) begin

         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b0;
         rx_bitcnt <= 1'b0;
         rx_data <= 1'b0;
         rx_ready <= 1'b0;
         
      end else if(rx_en && rts) begin

         rx_pc <= rx_pc + 1'b1; //increment pc by default

         case (rx_pc)
           
           0: begin //wait for start bit 
              rx_ready <= 1'b0;
              rx_cyclecnt <= 1'b0; 
              rx_bitcnt <= 1'b0;
              if (rxd) //start bit has not arrived: stay here
                 rx_pc <= rx_pc;
           end
           
           1: begin // wait until middle of start bit
             if ( rx_cyclecnt != (bit_duration/2) ) begin
                rx_pc <= rx_pc;
                rx_cyclecnt <= rx_cyclecnt + 1'b1;
             end else 
                rx_cyclecnt <= 1'b0;
           end

           2: begin // receive data
             if (rx_cyclecnt == bit_duration && rx_bitcnt != 4'd8) begin //data bit has arrived
                rx_pc <= rx_pc;
                rx_data <= {rxd, rx_data[7:1]}; //sample rx line
                rx_bitcnt <= rx_bitcnt + 1'b1;
                rx_cyclecnt <= 1'b0;
             end else if (rx_bitcnt == 4'd8) begin //data byte has arrived
                rx_ready <= 1'b1;
                rx_cyclecnt <= 1'b0;
             end
           end

           3: begin //wait for stop bit
              if (rx_cyclecnt != bit_duration) begin 
                rx_pc <= rx_pc;
                rx_cyclecnt <= rx_cyclecnt + 1'b1;
              end
           end

           4: begin //wait for data to be read
              if (!data_read_en) 
                rx_pc <= rx_pc;
              else
                rx_pc <= 1'b0;
           end
           
           endcase // case (rx_pc)
         
      end else begin // if (rx_en && rts)
         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b0;
         rx_bitcnt <= 1'b0;
         rx_data <= 1'b0;
         rx_ready <= 1'b0;
      end

   end // always @ (posedge clk, posedge rst_int)
   

endmodule
