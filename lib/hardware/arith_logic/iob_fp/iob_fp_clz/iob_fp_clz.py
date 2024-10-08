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
                "name": "BIT_W",
                "type": "F",
                "val": "$clog2(DATA_W+1)",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
        ],
        "ports": [
            {
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "data",
                        "width": "$clog2(DATA_W+1)",
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        integer                         i;

   always @* begin
      data_o = DATA_W[BIT_W-1:0];
      for (i=0; i < DATA_W; i=i+1) begin
         if (data_i[i]) begin
            data_o = (DATA_W[BIT_W-1:0] - i[BIT_W-1:0] - 1);
         end
      end
   end
            """,
            },
        ],
    }

    return attributes_dict
