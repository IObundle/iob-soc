// SPDX-FileCopyrightText: 2014-2018 Alex Forencich
// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Priority encoder module
 */
module priority_encoder #(
   parameter WIDTH        = 4,
   // LSB priority: "LOW", "HIGH"
   parameter LSB_PRIORITY = "LOW"
) (
   input  wire [        WIDTH-1:0] input_unencoded,
   output wire                     output_valid,
   output wire [$clog2(WIDTH)-1:0] output_encoded,
   output wire [        WIDTH-1:0] output_unencoded
);

   // power-of-two width
   parameter W1 = 2 ** $clog2(WIDTH);
   parameter W2 = W1 / 2;

   generate
      if (WIDTH == 1) begin : g_width_1
         // one input
         assign output_valid   = input_unencoded;
         assign output_encoded = 0;
      end else if (WIDTH == 2) begin : g_width_2
         // two inputs - just an OR gate
         assign output_valid = |input_unencoded;
         if (LSB_PRIORITY == "LOW") begin : g_width_2_lsb_priority_low
            assign output_encoded = input_unencoded[1];
         end else begin : g_width_2_lsb_priority_high
            assign output_encoded = ~input_unencoded[0];
         end
      end else begin : g_width_other
         // more than two inputs - split into two parts and recurse
         // also pad input to correct power-of-two width
         wire [$clog2(W2)-1:0] out1, out2;
         wire valid1, valid2;
         wire [W2-1:0] in2;
         assign in2[WIDTH-W2-1:0] = input_unencoded[WIDTH-1:W2];
         if (WIDTH - W2 < W2) assign in2[W2-1:WIDTH-W2] = 0;
         priority_encoder #(
            .WIDTH       (W2),
            .LSB_PRIORITY(LSB_PRIORITY)
         ) priority_encoder_inst1 (
            .input_unencoded (input_unencoded[W2-1:0]),
            .output_valid    (valid1),
            .output_encoded  (out1),
            .output_unencoded()
         );
         priority_encoder #(
            .WIDTH       (W2),
            .LSB_PRIORITY(LSB_PRIORITY)
         ) priority_encoder_inst2 (
            .input_unencoded (in2),
            .output_valid    (valid2),
            .output_encoded  (out2),
            .output_unencoded()
         );
         // multiplexer to select part
         assign output_valid = valid1 | valid2;
         if (LSB_PRIORITY == "LOW") begin : g_width_other_lsb_priority_low
            assign output_encoded = valid2 ? {1'b1, out2} : {1'b0, out1};
         end else begin : g_width_other_lsb_priority_high
            assign output_encoded = valid1 ? {1'b0, out1} : {1'b1, out2};
         end
      end
   endgenerate

   // unencoded output
   assign output_unencoded = 1 << output_encoded;

endmodule
