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
                "name": "PC_W",
                "type": "F",
                "val": "$clog2(DATA_W + 5) + 1",
                "min": "NA",
                "max": "NA",
                "descr": "PC width",
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
                "name": "en_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "en",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "sign_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "sign",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "dividend_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "dividend",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "divisor_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "divisor",
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
                "name": "quotient_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "quotient",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "remainder_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "remainder",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "rq",
                "descr": "rq wire",
                "signals": [
                    {"name": "rq", "width": "2*DATA_W"},
                ],
            },
            {
                "name": "divisor_reg",
                "descr": "divisor_reg wire",
                "signals": [
                    {"name": "divisor_reg", "width": "DATA_W"},
                ],
            },
            {
                "name": "divident_sign",
                "descr": "divident_sign wire",
                "signals": [
                    {"name": "divident_sign", "width": 1},
                ],
            },
            {
                "name": "divisor_sign",
                "descr": "divisor_sign wire",
                "signals": [
                    {"name": "divisor_sign", "width": 1},
                ],
            },
            {
                "name": "pc",
                "descr": "pc wire",
                "signals": [
                    {"name": "pc", "width": "PC_W"},
                ],
            },
            {
                "name": "subtraend",
                "descr": "subtraend wire",
                "signals": [
                    {"name": "subtraend", "width": "DATA_W"},
                ],
            },
            {
                "name": "tmp",
                "descr": "tmp wire",
                "signals": [
                    {"name": "tmp", "width": "DATA_W+1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            assign quotient_o  = rq[DATA_W-1:0];
            assign remainder_o = rq[2*DATA_W-1:DATA_W];
            assign subtraend = rq[2*DATA_W-2-:DATA_W]; 

   always @(posedge clk_i) begin
      if (en_i) begin
         pc <= pc + 1'b1;

         case (pc)
            0: begin  //load operands and result sign
               if (sign_i) begin
                  divisor_reg    <= divisor_i;
                  divisor_sign   <= divisor_i[DATA_W-1];
                  rq[DATA_W-1:0] <= dividend_i[DATA_W-1] ? -dividend_i : dividend_i;
                  divident_sign  <= dividend_i[DATA_W-1];
               end else begin
                  divisor_reg    <= divisor_i;
                  divisor_sign   <= 1'b0;
                  rq[DATA_W-1:0] <= dividend_i;
                  divident_sign  <= 1'b0;
               end
            end  // case: 0

            1: begin
               if (sign_i) divisor_reg <= divisor_reg[DATA_W-1] ? -divisor_reg : divisor_reg;
            end

            PC_W'(DATA_W + 2): begin  
               rq[DATA_W-1:0] <= (divident_sign^divisor_sign)? -{rq[DATA_W-2], rq[DATA_W-2 : 0]}: {rq[DATA_W-2], rq[DATA_W-2 : 0]};
            end

            PC_W'(DATA_W + 3): begin  
               done_o <= 1'b1;
               rq[2*DATA_W-1:DATA_W] <= divident_sign? -rq[2*DATA_W-1 -: DATA_W] : rq[2*DATA_W-1 -: DATA_W];
            end

            PC_W'(DATA_W + 4): pc <= pc;  

            default: begin  //shift and subtract
               tmp = {1'b0, subtraend} - {1'b0, divisor_reg};
               if (~tmp[DATA_W]) rq <= {tmp, rq[DATA_W-2 : 0], 1'b1};
               else rq <= {rq[2*DATA_W-1 : 0], 1'b0};
            end
         endcase  

      end else begin  // if (en)
         rq     <= 0;
         done_o <= 1'b0;
         pc     <= 0;
      end
   end  
            """,
            },
        ],
    }

    return attributes_dict
