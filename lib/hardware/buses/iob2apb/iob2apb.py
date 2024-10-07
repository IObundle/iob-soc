# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "APB_ADDR_W",
                "type": "P",
                "val": "22",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "APB_DATA_W",
                "type": "P",
                "val": "22",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "APB_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "APB_DATA_W",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
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
                "name": "iob_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "apb_m",
                "interface": {
                    "type": "apb",
                    "subtype": "master",
                },
                "descr": "APB interface",
            },
        ],
        "wires": [
            {
                "name": "pc_int",
                "descr": "pc_int wire",
                "signals": [
                    {"name": "pc_int", "width": 2},
                ],
            },
            {
                "name": "pc_nxt_int",
                "descr": "pc_nxt_int wire",
                "signals": [
                    {"name": "pc_nxt_int", "width": 2},
                ],
            },
            {
                "name": "apb_rdata_int",
                "descr": "apb_rdata_int wire",
                "signals": [
                    {"name": "apb_rdata_int", "width": 32},
                ],
            },
            {
                "name": "iob_rdata_int",
                "descr": "iob_rdata_int wire",
                "signals": [
                    {"name": "iob_rdata_int", "width": 32},
                ],
            },
            {
                "name": "apb_ready_int",
                "descr": "apb_ready_int wire",
                "signals": [
                    {"name": "apb_ready_int", "width": 1},
                ],
            },
            {
                "name": "iob_rvalid_int",
                "descr": "iob_rvalid_int wire",
                "signals": [
                    {"name": "iob_rvalid_int", "width": 1},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "pc_reg",
                "parameters": {
                    "DATA_W": 2,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "pc_nxt_int",
                    "data_o": "pc_int",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "iob_rdata_reg",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "apb_rdata_int",
                    "data_o": "iob_rdata_int",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "iob_rvalid_reg",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "apb_ready_int",
                    "data_o": "iob_rvalid_int",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        reg  [1:0] pc_nxt;
        reg  [1:0] apb_enable;
        always @* begin
    pc_nxt_int    = pc_int + 1'b1;
    apb_enable = 1'b0;

    case (pc_int)
      WAIT_VALID: begin
        if (!iob_valid_i) begin
          pc_nxt_int = pc_int;
        end else begin
          apb_enable = 1'b1;
        end
      end
      WAIT_READY: begin
        apb_enable = 1'b1;
        if (!apb_ready_i) begin
          pc_nxt_int = pc_int;
        end else if (apb_write_o) begin  // No need to wait for rvalid
          pc_nxt_int = WAIT_VALID;
        end
      end
      default: begin
        pc_nxt_int = WAIT_VALID;
      end
    endcase
  end
            """,
            },
        ],
    }

    return attributes_dict
