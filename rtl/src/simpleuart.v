/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`include "iob_uart.vh"

module simpleuart (
                   //serial i/f
	           output            ser_tx,
	           input             ser_rx,

	           input             clk,
	           input             resetn,

                   //data bus
                   input [1:0]       address,
	           input             sel,
                   input             we,

	           input [31:0]      dat_di,
	           output reg [31:0] dat_do
                   );

   // internal registers
   wire                              reg_dat_wait;
   wire [31:0]                       reg_dat_do;
   reg [31:0]                        cfg_divider;

  

   // sender
   reg [9:0]                         send_pattern;
   reg [3:0]                         send_bitcnt;
   reg [15:0]                        send_divcnt;

   // register select
   reg                               dat_sel, div_sel;

   // reset
   wire                              rstn_int;
   reg                               rstn_soft;

   //reset hard and soft
   assign rstn_int = resetn & rstn_soft;



   //
   // ADDRESS DECODER
   //

   // register select for writing
   always @* begin
      dat_sel = 1'b0;
      div_sel = 1'b0;
      rstn_soft = 1'b1;
      case (address)
        `UART_DIV: div_sel = sel & we;
        `UART_DATAOUT: dat_sel = sel & we;
        `UART_RESET: rstn_soft = ~(sel & we);
          default:;
        endcase
   end // always @ *

   //output select
   always @*
      case (address)
        `UART_WAIT: dat_do = {31'd0,reg_dat_wait};
        `UART_DIV: dat_do = cfg_divider;
        `UART_DATAOUT: dat_do = reg_dat_do;
        default: dat_do = ~0;
      endcase

   // internal registers
   assign reg_dat_wait = (send_bitcnt != 4'd0);
   assign reg_dat_do = ~0;

   // division factor
   always @(posedge clk, negedge rstn_int) begin
      if (!rstn_int) begin
	 cfg_divider <= 1;
      end else begin
	 if (div_sel) 
           cfg_divider <= dat_di;
      end
   end

   //div free running counter
   always @(posedge clk, negedge rstn_int)
     if(!rstn_int) //reset
        send_divcnt <= 0;
     else if(dat_sel) //set
       send_divcnt <= 1;
     else if(send_divcnt == cfg_divider) //wrap around
        send_divcnt <= 1;
     else if(send_divcnt != 0)       //increment
       send_divcnt <= send_divcnt + 1'b1;

   //send bit counter
   always @(posedge clk)
     if (!rstn_int)
       send_bitcnt <= 4'd0;
     else if (dat_sel)       //load
       send_bitcnt <= 4'd10;
     else if (send_bitcnt && (send_divcnt == cfg_divider))  //decrement
       send_bitcnt <= send_bitcnt - 1'b1;

`ifdef SIM
   reg prchar = 0;
`endif

   // shift register
   always @(posedge clk)
     if (!rstn_int) begin
	send_pattern <= ~10'b0;
     end else if (dat_sel) begin //load
	send_pattern <= {1'b1, dat_di[7:0], 1'b0};
`ifdef SIM
        prchar <= ~prchar;
        if(prchar)
          $write("%c", dat_di[7:0]);
`endif
     end else if (send_bitcnt && send_divcnt == cfg_divider) //shift right
       send_pattern <= {1'b1, send_pattern[9:1]};

   // send serial comm
   assign ser_tx = send_pattern[0];


endmodule
