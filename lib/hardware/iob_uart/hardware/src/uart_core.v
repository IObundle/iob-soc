// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps
`include "iob_uart_csrs_def.vh"
`include "iob_uart_conf.vh"

module uart_core (
   input                            clk_i,
   input                            arst_i,
   input                            rst_soft_i,
   input                            tx_en_i,
   input                            rx_en_i,
   input      [                7:0] tx_data_i,
   output reg [                7:0] rx_data_o,
   output reg                       tx_ready_o,
   output reg                       rx_ready_o,
   input                            rs232_rxd_i,
   output                           rs232_txd_o,
   input                            rs232_cts_i,
   output reg                       rs232_rts_o,
   input                            data_write_en_i,
   input                            data_read_en_i,
   input      [`IOB_UART_DIV_W-1:0] bit_duration_i
);

   ////////////////////////////////////////////////////////
   // TXtxd

   //BLOCK Serial Transmit Controller & This block serializes the data written to the UART\_TXDATA by the CPU, and sends it to the {\tt txd} ouput.

   //clear to send (cts) synchronizer
   reg [1:0] cts_int;
   always @(posedge clk_i) cts_int <= {cts_int[0], rs232_cts_i};

   wire [7:0] tx_data_int;
   iob_reg_e #(
      .DATA_W (8),
      .RST_VAL(8'b0)
   ) txdata_reg (
      // clk_en_rst port
      .clk_i (clk_i),
      .cke_i (1'b1),
      .arst_i(arst_i),
      .en_i  (data_write_en_i),
      // data_i port
      .data_i(tx_data_i),
      // data_o port
      .data_o(tx_data_int)
   );


   // sender
   reg [ 1:0] tx_pc;
   reg [ 9:0] tx_pattern;  //stop(1) + data(8) + start(1) = 10 bits
   reg [ 3:0] tx_bitcnt;
   reg [15:0] tx_cyclecnt;
   // receiver
   reg [ 2:0] rx_pc;
   reg [15:0] rx_cyclecnt;
   reg [ 3:0] rx_bitcnt;
   reg [ 7:0] rx_pattern;

   //tx bit
   assign rs232_txd_o = tx_pattern[0];


   localparam RST_POL = `IOB_UART_RST_POL;

   generate
      if (RST_POL == 1) begin : g_rst_pol_1
         //tx program
         always @(posedge clk_i, posedge arst_i)
            if (arst_i) begin
               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;
            end else if (rst_soft_i) begin
               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;
            end else if (tx_en_i && cts_int[1]) begin

               tx_pc <= tx_pc + 1'b1;  //increment pc by default

               case (tx_pc)

                  0: begin  //wait for data to send
                     tx_ready_o  <= 1'b1;
                     tx_bitcnt   <= 1'b0;
                     tx_cyclecnt <= 1'b1;
                     tx_pattern  <= ~9'b0;
                     if (!data_write_en_i) tx_pc <= tx_pc;
                     else tx_ready_o <= 1'b0;
                  end

                  1: begin  //load tx pattern to send
                     tx_pattern <= {1'b1, tx_data_int[7:0], 1'b0};  //{stop, data, start}>>
                  end

                  2: begin  //send pattern
                     tx_pc       <= tx_pc;  //stay here util pattern sent
                     tx_cyclecnt <= tx_cyclecnt + 1'b1;  //increment cycle counter
                     if (tx_cyclecnt == bit_duration_i)
                        if (tx_bitcnt == 4'd9) begin  //stop bit sent sent
                           tx_pc <= 1'b0;  //restart program 
                        end else begin  //data bit sent
                           tx_pattern  <= tx_pattern >> 1;
                           tx_bitcnt   <= tx_bitcnt + 1'b1;  //send next bit
                           tx_cyclecnt <= 1'b1;
                        end
                  end

                  default: ;

               endcase

            end else begin

               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;

            end


         ////////////////////////////////////////////////////////
         // RX
         ////////////////////////////////////////////////////////

         //BLOCK Serial Reiceive Controller & This block deserializes the data received from the pin {\tt rxd} input, and writes it to the UART\_RXDATA register, so the CPU can read it.


         // receiver program
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;
               rs232_rts_o <= 1'b0;
            end else if (rst_soft_i) begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;
               rs232_rts_o <= 1'b0;
            end else if (rx_en_i) begin
               rx_pc <= rx_pc + 1'b1;  //increment pc by default

               case (rx_pc)

                  0: begin  //sync up
                     rs232_rts_o <= 1'b1;
                     rx_ready_o  <= 1'b0;
                     rx_cyclecnt <= 1'b1;
                     rx_bitcnt   <= 1'b0;
                     if (!rs232_rxd_i)  //line is low, wait until it is high
                        rx_pc <= rx_pc;
                  end

                  1: begin  //line is high
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt != bit_duration_i) rx_pc <= rx_pc;
                     else if (!rs232_rxd_i)  //error: line returned to low early
                        rx_pc <= 1'b0;  //go back and resync
                  end

                  2: begin  //wait for start bit
                     rx_cyclecnt <= 1'b1;
                     if (rs232_rxd_i)  //start bit (low) has not arrived, wait
                        rx_pc <= rx_pc;
                  end

                  3: begin  //start bit is here
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt != bit_duration_i / 2)  // wait half bit period
                        rx_pc <= rx_pc;
                     else if (rs232_rxd_i)  //error: line returned to high unexpectedly 
                        rx_pc <= 1'b0;  //go back and resync
                     else rx_cyclecnt <= 1'b1;
                  end

                  4: begin  // receive data
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt == bit_duration_i) begin
                        rx_cyclecnt <= 1'b1;
                        rx_bitcnt   <= rx_bitcnt + 1'b1;
                        rx_pattern  <= {rs232_rxd_i, rx_pattern[7:1]};  //sample rx line
                        if (rx_bitcnt == 4'd8) begin  //stop bit is here
                           rx_pattern <= rx_pattern;  //unsample rx line
                           rx_data_o  <= rx_pattern;  //unsample rx line
                           rx_ready_o <= 1'b1;
                           rx_bitcnt  <= 1'b0;
                           rx_pc      <= 2'd2;
                        end else begin
                           rx_pc <= rx_pc;  //wait for more bits
                        end
                     end else begin
                        rx_pc <= rx_pc;  //wait for more cycles
                     end
                  end

                  default: ;

               endcase

               if (data_read_en_i) begin
                  rx_ready_o <= 1'b0;
               end
            end else begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;

            end
         end  // always @ (posedge clk_i, posedge arst_i)
      end // block: g_rst_pol_1
      else begin: g_rst_pol_0
         //tx program
         always @(posedge clk_i, negedge arst_i)
            if (!arst_i) begin
               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;
            end else if (rst_soft_i) begin
               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;
            end else if (tx_en_i && cts_int[1]) begin

               tx_pc <= tx_pc + 1'b1;  //increment pc by default

               case (tx_pc)

                  0: begin  //wait for data to send
                     tx_ready_o  <= 1'b1;
                     tx_bitcnt   <= 1'b0;
                     tx_cyclecnt <= 1'b1;
                     tx_pattern  <= ~9'b0;
                     if (!data_write_en_i) tx_pc <= tx_pc;
                     else tx_ready_o <= 1'b0;
                  end

                  1: begin  //load tx pattern to send
                     tx_pattern <= {1'b1, tx_data_int[7:0], 1'b0};  //{stop, data, start}>>
                  end

                  2: begin  //send pattern
                     tx_pc       <= tx_pc;  //stay here util pattern sent
                     tx_cyclecnt <= tx_cyclecnt + 1'b1;  //increment cycle counter
                     if (tx_cyclecnt == bit_duration_i)
                        if (tx_bitcnt == 4'd9) begin  //stop bit sent sent
                           tx_pc <= 1'b0;  //restart program 
                        end else begin  //data bit sent
                           tx_pattern  <= tx_pattern >> 1;
                           tx_bitcnt   <= tx_bitcnt + 1'b1;  //send next bit
                           tx_cyclecnt <= 1'b1;
                        end
                  end

                  default: ;

               endcase

            end else begin

               tx_pc       <= 1'b0;
               tx_ready_o  <= 1'b0;
               tx_pattern  <= ~10'b0;
               tx_bitcnt   <= 1'b0;
               tx_cyclecnt <= 1'b0;

            end


         ////////////////////////////////////////////////////////
         // RX
         ////////////////////////////////////////////////////////

         //BLOCK Serial Reiceive Controller & This block deserializes the data received from the pin {\tt rxd} input, and writes it to the UART\_RXDATA register, so the CPU can read it.


         // receiver program
         always @(posedge clk_i, negedge arst_i) begin
            if (!arst_i) begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;
               rs232_rts_o <= 1'b0;
            end else if (rst_soft_i) begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;
               rs232_rts_o <= 1'b0;
            end else if (rx_en_i) begin
               rx_pc <= rx_pc + 1'b1;  //increment pc by default

               case (rx_pc)

                  0: begin  //sync up
                     rs232_rts_o <= 1'b1;
                     rx_ready_o  <= 1'b0;
                     rx_cyclecnt <= 1'b1;
                     rx_bitcnt   <= 1'b0;
                     if (!rs232_rxd_i)  //line is low, wait until it is high
                        rx_pc <= rx_pc;
                  end

                  1: begin  //line is high
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt != bit_duration_i) rx_pc <= rx_pc;
                     else if (!rs232_rxd_i)  //error: line returned to low early
                        rx_pc <= 1'b0;  //go back and resync
                  end

                  2: begin  //wait for start bit
                     rx_cyclecnt <= 1'b1;
                     if (rs232_rxd_i)  //start bit (low) has not arrived, wait
                        rx_pc <= rx_pc;
                  end

                  3: begin  //start bit is here
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt != bit_duration_i / 2)  // wait half bit period
                        rx_pc <= rx_pc;
                     else if (rs232_rxd_i)  //error: line returned to high unexpectedly 
                        rx_pc <= 1'b0;  //go back and resync
                     else rx_cyclecnt <= 1'b1;
                  end

                  4: begin  // receive data
                     rx_cyclecnt <= rx_cyclecnt + 1'b1;
                     if (rx_cyclecnt == bit_duration_i) begin
                        rx_cyclecnt <= 1'b1;
                        rx_bitcnt   <= rx_bitcnt + 1'b1;
                        rx_pattern  <= {rs232_rxd_i, rx_pattern[7:1]};  //sample rx line
                        if (rx_bitcnt == 4'd8) begin  //stop bit is here
                           rx_pattern <= rx_pattern;  //unsample rx line
                           rx_data_o  <= rx_pattern;  //unsample rx line
                           rx_ready_o <= 1'b1;
                           rx_bitcnt  <= 1'b0;
                           rx_pc      <= 2'd2;
                        end else begin
                           rx_pc <= rx_pc;  //wait for more bits
                        end
                     end else begin
                        rx_pc <= rx_pc;  //wait for more cycles
                     end
                  end

                  default: ;

               endcase

               if (data_read_en_i) begin
                  rx_ready_o <= 1'b0;
               end
            end else begin
               rx_pc       <= 1'b0;
               rx_cyclecnt <= 1'b1;
               rx_bitcnt   <= 1'b0;
               rx_ready_o  <= 1'b0;

            end
         end  // always @ (posedge clk_i, posedge arst_i)
      end
   endgenerate


endmodule
