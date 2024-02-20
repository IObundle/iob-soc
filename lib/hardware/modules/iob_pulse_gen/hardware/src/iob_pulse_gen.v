`timescale 1ns / 1ps


module iob_pulse_gen #(
   parameter START    = 0,
   parameter DURATION = 0
) (
   `include "clk_en_rst_s_port.vs"
   input  start_i,
   output pulse_o
);

   localparam WIDTH = $clog2(START + DURATION + 2);
   // compensate extra cycle to register output
   localparam START_INT = (START <= 0) ? 0 : START - 1;
   localparam FINISH = START_INT + DURATION;

   //start detect
   wire start_detected;
   wire start_detected_nxt;
   assign start_detected_nxt = start_detected | start_i;

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) start_detected_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(start_detected_nxt),
      .data_o(start_detected)
   );

   //counter
   wire [    1-1:0] cnt_en;
   wire [WIDTH-1:0] cnt;

   //counter enable
   assign cnt_en = start_detected & (cnt <= FINISH);

   //counter
   iob_counter #(
      .DATA_W (WIDTH),
      .RST_VAL({WIDTH{1'b0}})
   ) cnt0 (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (start_i),
      .en_i  (cnt_en),
      .data_o(cnt)
   );

   //pulse
   wire pulse_nxt;
   assign pulse_nxt = cnt_en & (cnt < FINISH) & (cnt >= START_INT);

   // register pulse
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   ) pulse_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .data_i(pulse_nxt),
      .data_o(pulse_o)
   );

endmodule

