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
                "val": "21",
                "min": "NA",
                "max": "NA",
                "descr": "Width of data interface",
            },
            {
                "name": "N",
                "type": "P",
                "val": "21",
                "min": "NA",
                "max": "NA",
                "descr": "Number of inputs",
            },
        ],
        "ports": [
            {
                "name": "sel_i",
                "descr": "Selector interface",
                "signals": [
                    {
                        "name": "sel",
                        "width": "($clog2(N)+($clog2(N)==0))",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data",
                        "width": "N*DATA_W",
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
                        "width": "DATA_W",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            integer input_sel;
        always @* begin
            data_o = {DATA_W{1'b0}};
            for (input_sel = 0; input_sel < N; input_sel = input_sel + 1) begin : gen_mux
                if (input_sel == sel_i) begin
                     data_o = data_i[input_sel*DATA_W+:DATA_W];
                end
            end
        end
            """,
            },
        ],
    }

    return attributes_dict
