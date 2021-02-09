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
   output [7:0]              rx_data,
   output reg                tx_ready,
   output reg                rx_ready,
   input                     rxd,
   output                    txd,
   input                     cts,
   output                    rts,
   input                     data_write_en,
   input                     data_read_en,
   input [`UART_WDATA_W-1:0] bit_duration
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
   // TX
   ////////////////////////////////////////////////////////

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
        tx_cyclecnt <= 1'b1;

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
             tx_pattern <= {1'b1, tx_data[7:0], 1'b0};
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
   reg [1:0] rx_pc;
   reg [9:0] rx_pattern; //stop(1) + data(8) + start(1) = 10 bits
   reg [15:0] rx_cyclecnt;
   reg [3:0]  rx_bitcnt;

   assign rx_data = rx_pattern[8:1];
   
   always @(posedge clk, posedge rst_int) begin

      if (rst_int) begin

         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b1;
         rx_bitcnt <= 1'b0;
         rx_ready <= 1'b0;
         
      end else if(rx_en && rts) begin

         rx_pc <= rx_pc + 1'b1; //increment pc by default

         case (rx_pc)
           
           0: begin //wait for start bit 
              rx_ready <= 1'b0;
              rx_cyclecnt <= bit_duration/2; 
              rx_bitcnt <= 1'b0;
              if (rxd) //start bit has not arrived: stay here
                 rx_pc <= rx_pc;
           end

           1: begin // receive data
              rx_cyclecnt <= rx_cyclecnt + 1'b1;
              if (rx_cyclecnt == bit_duration) begin
                 rx_cyclecnt <= 1'b1;
                 rx_bitcnt <= rx_bitcnt + 1'b1;
                 rx_pattern <= {rxd, rx_pattern[9:1]}; //sample rx line
                 if (rx_bitcnt == 4'd9) begin //stop bit is here
                    rx_ready <= 1'b1;
                    rx_bitcnt <= 1'b0;
                 end else begin //one data bit is here
                    rx_pc <= rx_pc; //stay here and wait for more
                 end
              end else
                rx_pc <= rx_pc; //stay here, wait for whole bit
           end
           
           2: begin //wait for word to be read and restart program
              rx_pc <= rx_pc; //stay here
              if (data_read_en)
                rx_pc <= 1'b0;
           end
           
          default: ;
           
           
         endcase // case (rx_pc)
         
      end else begin // if (rx_en && rts)
         rx_pc <= 1'b0;
         rx_cyclecnt <= 1'b1;
         rx_bitcnt <= 1'b0;
         rx_ready <= 1'b0;
      end

   end // always @ (posedge clk, posedge rst_int)
   

endmodule
