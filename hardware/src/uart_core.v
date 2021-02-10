`timescale 1ns/1ps
`include "iob_uart.vh"

module uart_core 
  (
   input                     clk,
   input                     rst,
   input                     rst_soft,
   input                     tx_en,
   input                     rx_en,
   input [7:0]               tx_data,
   output reg [7:0]          rx_data,
   output reg                tx_ready,
   output reg                rx_ready,
   input                     rxd,
   output                    txd,
   input                     cts,
   output reg                rts,
   input                     data_write_en,
   input                     data_read_en,
   input [`UART_WDATA_W-1:0] bit_duration
   );
   
                  
   //COMBINED SOFT/HARD RESET
   wire       rst_int = rst | rst_soft;
  
   ////////////////////////////////////////////////////////
   // TX
   ////////////////////////////////////////////////////////

   //clear to send (cts) synchronizer
   reg [1:0]  cts_int;
   always @(posedge clk) 
     cts_int <= {cts_int[0], cts};

   
   // sender
   reg [9:0]  tx_pattern; //stop(1) + data(8) + start(1) = 10 bits
   reg [3:0]  tx_bitcnt;
   reg [15:0] tx_cyclecnt;

   //tx bit
   assign txd = tx_pattern[0];
   
   //tx program
   reg  [1:0] tx_pc;   
   always @(posedge clk, posedge rst_int)

     if(rst_int) begin 

        tx_pc <= 1'b0;
        tx_ready <= 1'b0;
        tx_pattern <= ~10'b0;
        tx_bitcnt <= 1'b0;
        tx_cyclecnt <= 1'b0;

     end else if(tx_en && cts_int[1]) begin

        tx_pc <= tx_pc + 1'b1; //increment pc by default

        case (tx_pc)

          0: begin //wait for data to send
             tx_ready <= 1'b1;
             tx_bitcnt <= 1'b0;
             tx_cyclecnt <= 1'b1;   
             tx_pattern <= ~9'b0;
             if(!data_write_en)
               tx_pc <= tx_pc;
             else
                tx_ready <= 1'b0;
          end

          1: begin //load tx pattern to send
             tx_pattern <= {1'b1, tx_data[7:0], 1'b0}; //{stop, data, start}>>
          end

          2: begin //send pattern
             tx_pc <= tx_pc; //stay here util pattern sent
             tx_cyclecnt <= tx_cyclecnt + 1'b1; //increment cycle counter
             if (tx_cyclecnt == bit_duration)
               if (tx_bitcnt == 4'd9) begin //stop bit sent sent
                  tx_pc <= 1'b0; //restart program 
               end else begin//data bit sent
                  tx_pattern <= tx_pattern >> 1;
                  tx_bitcnt <= tx_bitcnt + 1'b1; //send next bit
                  tx_cyclecnt <= 1'b1;
               end
          end
          
          default:;
          
        endcase

     end else begin              
        
        tx_pc <= 1'b0;
        tx_ready <= 1'b0;
        tx_pattern <= ~10'b0;
        tx_bitcnt <= 1'b0;
        tx_cyclecnt <= 1'b0;

     end


   ////////////////////////////////////////////////////////
   // RX
   ////////////////////////////////////////////////////////

   // receiver program
   reg [2:0] rx_pc;
   reg [15:0] rx_cyclecnt;
   reg [3:0]  rx_bitcnt;
   reg [7:0]  rx_pattern;

   always @(posedge clk, posedge rst_int) begin

      if (rst_int) begin

         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b1;
         rx_bitcnt <= 1'b0;
         rx_ready <= 1'b0;
         rts <= 1'b0;
         
         
      end else if(rx_en) begin

         rx_pc <= rx_pc + 1'b1; //increment pc by default

         case (rx_pc)
           
           0: begin //sync up
              rts <= 1'b1;
              rx_ready <= 1'b0;
              rx_cyclecnt <= 1'b1;
              rx_bitcnt <= 1'b0;
              if (!rxd) //line is low, wait until it is high
                 rx_pc <= rx_pc;
           end

           1: begin //line is high
              rx_cyclecnt <= rx_cyclecnt + 1'b1;
              if(rx_cyclecnt != bit_duration)
                 rx_pc <= rx_pc;
              else if(!rxd) //error: line returned to low early
                 rx_pc <= 1'b0; //go back and resync
           end
           
           2: begin //wait for start bit
              rx_cyclecnt <= 1'b1;
              if (rxd) //start bit (low) has not arrived, wait
                 rx_pc <= rx_pc;
           end

           3: begin //start bit is here
              rx_cyclecnt <= rx_cyclecnt + 1'b1;
              if(rx_cyclecnt != bit_duration/2) // wait half bit period
                 rx_pc <= rx_pc;
              else if(rxd) //error: line returned to high unexpectedly 
                rx_pc <= 1'b0; //go back and resync
              else
                rx_cyclecnt <= 1'b1;
           end
           
           4: begin // receive data
              rx_cyclecnt <= rx_cyclecnt + 1'b1;
              if (rx_cyclecnt == bit_duration) begin
                 rx_cyclecnt <= 1'b1;
                 rx_bitcnt <= rx_bitcnt + 1'b1;
                 rx_pattern <= {rxd, rx_pattern[7:1]}; //sample rx line
                 if (rx_bitcnt == 4'd8) begin //stop bit is here
                    rx_pattern <= rx_pattern; //unsample rx line
                    rx_data <= rx_pattern; //unsample rx line
                    rx_ready <= 1'b1;
                    rx_bitcnt <= 1'b0;
                    rx_pc <= 2'd2;
                 end else begin
                    rx_pc <= rx_pc; //wait for more bits
                 end 
              end else begin
                 rx_pc <= rx_pc; //wait for more cycles
              end
           end

           default: ;

         endcase

         if (data_read_en) begin
            rx_ready <= 1'b0;
         end
         
      end else begin 
         
         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b1;
         rx_bitcnt <= 1'b0;
         rx_ready <= 1'b0;
      
      end

   end
   
endmodule
