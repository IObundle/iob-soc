# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    CSR_IF = py_params_dict["csr_if"] if "csr_if" in py_params_dict else "iob"
    NAME = py_params_dict["name"] if "name" in py_params_dict else "iob_uart"
    attributes_dict = {
        "name": NAME,
        "version": "0.1",
        "board_list": ["cyclonev_gt_dk", "aes_ku040_db_g"],
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width.",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "3",  # Same as `IOB_UART_CSRS_ADDR_W
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
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
                "name": "cbus_s",
                "interface": {
                    "type": CSR_IF,
                    "subtype": "slave",
                    "ADDR_W": "3",  # Same as `IOB_UART_CSRS_ADDR_W
                    "DATA_W": "DATA_W",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "rs232_m",
                "interface": {
                    "type": "rs232",
                },
                "descr": "RS232 interface",
            },
        ],
        "wires": [
            {
                "name": "csrs_iob",
                "descr": "Internal iob interface",
                "interface": {
                    "type": "iob",
                    "wire_prefix": "csrs_",
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
            },
            {
                "name": "softreset",
                "descr": "",
                "signals": [
                    {"name": "softreset_wr", "width": 1},
                ],
            },
            {
                "name": "div",
                "descr": "",
                "signals": [
                    {"name": "div_wr", "width": 16},
                ],
            },
            {
                "name": "txdata",
                "descr": "",
                "signals": [
                    {"name": "txdata_wdata_wr", "width": 8},
                    {"name": "txdata_wen_wr", "width": 1},
                    {"name": "txdata_wready_wr", "width": 1},
                ],
            },
            {
                "name": "txen",
                "descr": "",
                "signals": [
                    {"name": "txen_wr", "width": 1},
                ],
            },
            {
                "name": "rxen",
                "descr": "",
                "signals": [
                    {"name": "rxen_wr", "width": 1},
                ],
            },
            {
                "name": "txready",
                "descr": "",
                "signals": [
                    {"name": "txready_rd", "width": 1},
                ],
            },
            {
                "name": "rxready",
                "descr": "",
                "signals": [
                    {"name": "rxready_rd", "width": 1},
                ],
            },
            {
                "name": "rxdata",
                "descr": "",
                "signals": [
                    {"name": "rxdata_rdata_rd", "width": 8},
                    {"name": "rxdata_rvalid_rd", "width": 1},
                    {"name": "rxdata_ren_rd", "width": 1},
                    {"name": "rxdata_rready_rd", "width": 1},
                ],
            },
            # RXDATA reg
            {
                "name": "iob_reg_rvalid_data_i",
                "descr": "",
                "signals": [
                    {"name": "rxdata_rvalid_nxt", "width": 1},
                ],
            },
            {
                "name": "iob_reg_rvalid_data_o",
                "descr": "",
                "signals": [
                    {"name": "rxdata_rvalid_rd"},
                ],
            },
            # uart core
            {
                "name": "clk_rst",
                "descr": "Clock and reset",
                "signals": [
                    {"name": "clk"},
                    {"name": "arst"},
                ],
            },
            {
                "name": "uart_core_reg_interface",
                "descr": "",
                "signals": [
                    {"name": "softreset_wr"},
                    {"name": "txen_wr"},
                    {"name": "rxen_wr"},
                    {"name": "txready_rd"},
                    {"name": "rxready_rd"},
                    {"name": "txdata_wdata_wr"},
                    {"name": "rxdata_rdata_rd"},
                    {"name": "txdata_wen_wr"},
                    {"name": "rxdata_ren_rd"},
                    {"name": "div_wr"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_inst",
                "instance_description": "Control/Status Registers",
                "autoaddr": False,
                "rw_overlap": True,
                "csrs": [
                    {
                        "name": "uart",
                        "descr": "UART software accessible registers.",
                        "regs": [
                            {
                                "name": "softreset",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "addr": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Soft reset.",
                            },
                            {
                                "name": "div",
                                "type": "W",
                                "n_bits": 16,
                                "rst_val": 0,
                                "addr": 2,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Bit duration in system clock cycles.",
                            },
                            {
                                "name": "txdata",
                                "type": "W",
                                "n_bits": 8,
                                "rst_val": 0,
                                "addr": 4,
                                "log2n_items": 0,
                                "autoreg": False,
                                "descr": "TX data.",
                            },
                            {
                                "name": "txen",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "addr": 5,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "TX enable.",
                            },
                            {
                                "name": "rxen",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "addr": 6,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "RX enable.",
                            },
                            {
                                "name": "txready",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "addr": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "TX ready to receive data.",
                            },
                            {
                                "name": "rxready",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "addr": 1,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "RX data is ready to be read.",
                            },
                            # NOTE: RXDATA needs to be the only Read register in a CPU Word
                            # RXDATA_ren access is used to change UART state machine
                            {
                                "name": "rxdata",
                                "type": "R",
                                "n_bits": 8,
                                "rst_val": 0,
                                "addr": 4,
                                "log2n_items": 0,
                                "autoreg": False,
                                "descr": "RX data.",
                            },
                        ],
                    }
                ],
                "csr_if": CSR_IF,
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "control_if_s": "cbus_s",
                    "csrs_iob_o": "csrs_iob",
                    # Register interfaces
                    "softreset": "softreset",
                    "div": "div",
                    "txdata": "txdata",
                    "txen": "txen",
                    "rxen": "rxen",
                    "txready": "txready",
                    "rxready": "rxready",
                    "rxdata": "rxdata",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_rvalid",
                "instance_description": "Register for rxdata rvalid",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": "1'b0",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "iob_reg_rvalid_data_i",
                    "data_o": "iob_reg_rvalid_data_o",
                },
            },
            {
                "core_name": "uart_core",
                "instance_name": "uart_core_inst",
                "instance_description": "UART core driver",
                "connect": {
                    "clk_rst_s": "clk_rst",
                    "reg_interface": "uart_core_reg_interface",
                    "rs232_m": "rs232_m",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    // txdata Manual logic
    assign txdata_wready_wr = 1'b1;

    // rxdata Manual logic
    assign rxdata_rready_rd = 1'b1;

    // rxdata rvalid is iob_valid registered
    assign rxdata_rvalid_nxt = csrs_iob_valid & rxdata_ren_rd;
""",
            },
        ],
    }

    return attributes_dict
