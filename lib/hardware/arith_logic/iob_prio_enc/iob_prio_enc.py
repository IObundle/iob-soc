# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "W",
                "type": "P",
                "val": "21",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "MODE",
                "type": "P",
                "val": '"LOW"',
                "min": "NA",
                "max": "NA",
                "descr": "'LOW' = Prioritize smaller index",
            },
        ],
        "ports": [
            {
                "name": "unencoded_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "unencoded",
                        "width": "W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "encoded_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "encoded",
                        "width": "$clog2(W)",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
         integer pos;
   generate
      if (MODE == "LOW") begin : gen_low_prio
         always @* begin
            encoded_o = {$clog2(W) {1'd0}};  //In case input is 0
            for (pos = W - 1; pos != -1; pos = pos - 1) begin
               if (unencoded_i[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end else begin : gen_highest_prio  //MODE == "HIGH"
         always @* begin
            encoded_o = {$clog2(W) {1'd0}};  //In case input is 0
            for (pos = {W{1'd0}}; pos < W; pos = pos + 1) begin
               if (unencoded_i[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end
   endgenerate    
         """,
            },
        ],
    }

    return attributes_dict
