# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "EXP_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "EXP width",
            },
            {
                "name": "MAN_W",
                "type": "F",
                "val": "DATA_W-EXP_W",
                "min": "NA",
                "max": "NA",
                "descr": "MAN width",
            },
            {
                "name": "BIAS",
                "type": "F",
                "val": "2**(EXP_W-1)-1",
                "min": "NA",
                "max": "NA",
                "descr": "BIAS width",
            },
            {
                "name": "EXTRA",
                "type": "F",
                "val": 3,
                "min": "NA",
                "max": "NA",
                "descr": "EXTRA",
            },
            {
                "name": "END_COUNT",
                "type": "F",
                "val": "MAN_W+EXTRA-1+4",
                "min": "NA",
                "max": "NA",
                "descr": "END_COUNT",
            },
            {
                "name": "COUNT_W",
                "type": "F",
                "val": "$clog2(END_COUNT+1)",
                "min": "NA",
                "max": "NA",
                "descr": "COUNT width",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "rst_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "rst",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "start_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "start",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "op_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "op",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "done_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "done",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "overflow_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "overflow",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "underflow_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "underflow",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "exception_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "exception",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "res_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "res",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "A_Mantissa",
                "descr": "A_Mantissa wire",
                "signals": [
                    {"name": "A_Mantissa", "width": "MAN_W"},
                ],
            },
            {
                "name": "A_Exponent",
                "descr": "A_Exponent wire",
                "signals": [
                    {"name": "A_Exponent", "width": "EXP_W"},
                ],
            },
            {
                "name": "A_sign",
                "descr": "A_sign wire",
                "signals": [
                    {"name": "A_sign", "width": 1},
                ],
            },
            {
                "name": "Temp_Mantissa",
                "descr": "Temp_Mantissa wire",
                "signals": [
                    {"name": "Temp_Mantissa", "width": "MAN_W+1"},
                ],
            },
            {
                "name": "Temp_Computed_Exponent",
                "descr": "Temp_Computed_Exponent wire",
                "signals": [
                    {"name": "Temp_Computed_Exponent", "width": "EXP_W"},
                ],
            },
            {
                "name": "Mantissa",
                "descr": "Mantissa wire",
                "signals": [
                    {"name": "Mantissa", "width": "MAN_W-1"},
                ],
            },
            {
                "name": "Exponent",
                "descr": "Exponent wire",
                "signals": [
                    {"name": "Exponent", "width": "EXP_W"},
                ],
            },
            {
                "name": "Sign",
                "descr": "Sign wire",
                "signals": [
                    {"name": "Sign", "width": 1},
                ],
            },
            {
                "name": "iob_fp_sqrt_int",
                "descr": "iob_fp_sqrt_int wire",
                "signals": [
                    {"name": "iob_fp_sqrt_int", "width": 26},
                ],
            },
            {
                "name": "Do_start_int",
                "descr": "Do_start wire",
                "signals": [
                    {"name": "Do_start", "width": 1},
                ],
            },
            {
                "name": "Equal_zero_reg",
                "descr": "Equal_zero_reg wire",
                "signals": [
                    {"name": "Equal_zero_reg", "width": 1},
                ],
            },
            {
                "name": "A_Exponent_diff_reg",
                "descr": "A_Exponent_diff_reg wire",
                "signals": [
                    {"name": "A_Exponent_diff_reg", "width": "EXP_W"},
                ],
            },
            {
                "name": "A_sign_reg",
                "descr": "A_sign_reg wire",
                "signals": [
                    {"name": "A_sign_reg", "width": 1},
                ],
            },
            {
                "name": "A_Exponent_reg",
                "descr": "A_Exponent_reg wire",
                "signals": [
                    {"name": "A_Exponent_reg", "width": "EXP_W"},
                ],
            },
            {
                "name": "A_Mantissa_reg",
                "descr": "A_Mantissa_reg wire",
                "signals": [
                    {"name": "A_Mantissa_reg", "width": "EXP_W"},
                ],
            },
            {
                "name": "Temp_Exponent_reg",
                "descr": "Temp_Exponent_reg wire",
                "signals": [
                    {"name": "Temp_Exponent_reg", "width": "EXP_W"},
                ],
            },
            {
                "name": "Temp_Mantissa_reg",
                "descr": "Temp_Mantissa_reg wire",
                "signals": [
                    {"name": "Temp_Mantissa_reg", "width": "EXP_W"},
                ],
            },
            {
                "name": "counter",
                "descr": "counter wire",
                "signals": [
                    {"name": "counter", "width": 1},
                ],
            },
            {
                "name": "done_int",
                "descr": "done wire",
                "signals": [
                    {"name": "done_int", "width": 1},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_int_sqrt",
                "instance_name": "int_sqrt",
                "parameters": {"DATA_W": "MAN_W+2", "FRACTIONAL_W": "MAN_W"},
                "connect": {
                    "clk_i": "clk_i",
                    "rst_i": "rst_i",
                    "start_i": "Do_start_int",
                    "done_o": "done_int",
                    "op_i": "iob_fp_sqrt_int",
                    "res_o": "Temp_Mantissa",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        assign iob_fp_sqrt_int=A_Exponent_diff_reg[0] ? {2'b00,A_Mantissa_reg} : {1'b0,A_Mantissa_reg,1'b0};
        assign done_o = (counter == END_COUNT[COUNT_W-1:0])? 1'b1: 1'b0;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         counter <= END_COUNT[COUNT_W-1:0];
      end else if (start_i) begin
         counter <= 0;
      end else if (~done_o) begin
         counter <= counter + 1'b1;
      end
   end
   always @(posedge clk_i) begin
      if (rst_i) begin
         A_sign_reg <= 1'b0;
         A_Exponent_reg <= {EXP_W{1'b0}};
         A_Mantissa_reg <= {MAN_W{1'b0}};
         A_Exponent_diff_reg <= 0;
         Equal_zero_reg <= 1'b0;

         Do_start <= 1'b0;
      end else begin
         if(start_i) begin // This unit is not fully pipelinable, due to the use of int_sqrt, so just register at the start and reuse when needed
            A_sign_reg <= A_sign;
            A_Exponent_reg <= A_Exponent;
            A_Mantissa_reg <= A_Mantissa;
            A_Exponent_diff_reg <= A_Exponent - BIAS;
            Equal_zero_reg <= (A_Exponent == 0) && (op_i[MAN_W-2:0] == 0);
         end

         Do_start <= start_i;
      end
   end
   always @(posedge clk_i) begin
      if (rst_i) begin
         Temp_Exponent_reg <= {EXP_W{1'b0}};
         Temp_Mantissa_reg <= {(MAN_W-1){1'b0}};
      end else begin

         if(A_sign_reg || Equal_zero_reg) begin
            Temp_Exponent_reg <= 0;
            Temp_Mantissa_reg <= 0;
         end else begin
            Temp_Exponent_reg <= BIAS + Temp_Computed_Exponent;
            Temp_Mantissa_reg <= A_Exponent_diff_reg[0] ? Temp_Mantissa[MAN_W-2:0] : Temp_Mantissa[MAN_W-1:1];
         end
      end
   end
   // pipeline stage 4
   always @(posedge clk_i) begin
      if (rst_i) begin
         res_o <= {DATA_W{1'b0}};
      end else begin
         res_o <= {Sign, Exponent, Mantissa};
      end
   end

   assign overflow_o = 1'b0;
   assign underflow_o = 1'b0;
   assign exception_o = A_sign_reg; // Cannot perform sqrt of negative numbers
            """,
            },
        ],
    }

    return attributes_dict
