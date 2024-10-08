# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "START",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "DURATION",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "WIDTH",
                "type": "F",
                "val": "$clog2(START + DURATION + 2)",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "START_INT",
                "type": "F",
                "val": "(START <= 0) ? 0 : START - 1",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "FINISH",
                "type": "F",
                "val": "START_INT + DURATION",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "start_i",
                "descr": "Input port",
                "signals": [
                    {"name": "start", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "pulse_o",
                "descr": "Output port",
                "signals": [
                    {"name": "pulse", "width": 1, "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "start_detected",
                "descr": "Start detect wire",
                "signals": [
                    {"name": "start_detected", "width": 1},
                ],
            },
            {
                "name": "start_detected_nxt",
                "descr": "Start detect next wire",
                "signals": [
                    {"name": "start_detected_nxt", "width": 1},
                ],
            },
            {
                "name": "iob_pulse_gen_int",
                "descr": "iob_pulse_gen_int wire",
                "signals": [
                    {"name": "cnt_en", "width": 1},
                    {"name": "start"},
                ],
            },
            {
                "name": "cnt",
                "descr": "",
                "signals": [
                    {"name": "cnt", "width": "WIDTH"},
                ],
            },
            {
                "name": "pulse_nxt",
                "descr": "",
                "signals": [
                    {"name": "pulse_nxt", "width": 1},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "start_detected_inst",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "start_detected_nxt",
                    "data_o": "start_detected",
                },
            },
            {
                "core_name": "iob_counter",
                "instance_name": "cnt0",
                "parameters": {
                    "DATA_W": "WIDTH",
                    "RST_VAL": "{WIDTH{1'b0}}",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "en_rst_i": "iob_pulse_gen_int",
                    "data_o": "cnt",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "pulse_reg",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "pulse_nxt",
                    "data_o": "pulse_o",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    assign start_detected_nxt = start_detected | start_i;
    assign cnt_en = start_detected & (cnt <= FINISH);
    assign pulse_nxt = cnt_en & (cnt < FINISH) & (cnt >= START_INT);
                """,
            },
        ],
    }

    return attributes_dict
