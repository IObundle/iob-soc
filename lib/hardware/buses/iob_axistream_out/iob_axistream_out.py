# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.3",
        "board_list": ["cyclonev_gt_dk", "aes_ku040_db_g"],
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "32",
                "max": "32",
                "descr": "CPU data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                # "val": "`IOB_AXISTREAM_OUT_CSRS_ADDR_W",
                "val": "5",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "TDATA_W",
                "type": "P",
                "val": "8",
                "min": "1",
                "max": "DATA_W",
                "descr": "AXI stream data width",
            },
            {
                "name": "FIFO_ADDR_W",
                "type": "P",
                "val": "4",
                "min": "NA",
                "max": "16",
                "descr": "FIFO depth (log2)",
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
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "interrupt_o",
                "descr": "Interrupt signal",
                "signals": [
                    {
                        "name": "interrupt",
                        "direction": "output",
                        "width": "1",
                        "descr": "FIFO threshold interrupt signal",
                    },
                ],
            },
            {
                "name": "axistream",
                "descr": "AXI Stream interface signals",
                "signals": [
                    {
                        "name": "axis_clk",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock.",
                    },
                    {
                        "name": "axis_cke",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock enable.",
                    },
                    {
                        "name": "axis_arst",
                        "direction": "input",
                        "width": "1",
                        "descr": "Aynchronous and active high reset.",
                    },
                    {
                        "name": "axis_tdata",
                        "direction": "output",
                        "width": "TDATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "axis_tvalid",
                        "direction": "output",
                        "width": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "axis_tready",
                        "direction": "input",
                        "width": "1",
                        "descr": "Ready.",
                    },
                    {
                        "name": "axis_tlast",
                        "direction": "output",
                        "width": "1",
                        "descr": "Last word.",
                    },
                ],
            },
            {
                "name": "sys_axis",
                "descr": "System AXI Stream interface.",
                "signals": [
                    {
                        "name": "sys_tdata",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "sys_tvalid",
                        "direction": "input",
                        "width": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "sys_tready",
                        "direction": "output",
                        "width": "1",
                        "descr": "Ready.",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "csrs_iob",
                "descr": "Internal CSRs IOb interface",
                "interface": {
                    "type": "iob",
                    "wire_prefix": "csrs_",
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
            },
            {
                "name": "soft_reset",
                "descr": "",
                "signals": [
                    {"name": "soft_reset_wr", "width": 1},
                ],
            },
            {
                "name": "enable",
                "descr": "",
                "signals": [
                    {"name": "enable_wr", "width": 1},
                ],
            },
            {
                "name": "data",
                "descr": "",
                "signals": [
                    {"name": "data_wdata_wr", "width": 32},
                    {"name": "data_wen_wr", "width": 1},
                    {"name": "data_wready_wr", "width": 1},
                ],
            },
            {
                "name": "mode",
                "descr": "",
                "signals": [
                    {"name": "mode_wr", "width": 1},
                ],
            },
            {
                "name": "nwords",
                "descr": "",
                "signals": [
                    {"name": "nwords_wr", "width": "DATA_W"},
                ],
            },
            {
                "name": "fifo_full",
                "descr": "",
                "signals": [
                    {"name": "fifo_full_rd", "width": 1},
                ],
            },
            {
                "name": "fifo_empty",
                "descr": "",
                "signals": [
                    {"name": "fifo_empty_rd", "width": 1},
                ],
            },
            {
                "name": "fifo_threshold",
                "descr": "",
                "signals": [
                    {"name": "fifo_threshold_wr", "width": "FIFO_ADDR_W+1"},
                ],
            },
            {
                "name": "fifo_level",
                "descr": "",
                "signals": [
                    {"name": "fifo_level_rd", "width": "FIFO_ADDR_W+1"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_inst",
                "instance_description": "Control/Status Registers",
                "csrs": [
                    {
                        "name": "axistream",
                        "descr": "AXI Stream software accessible registers.",
                        "regs": [
                            {
                                "name": "soft_reset",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Soft reset.",
                            },
                            {
                                "name": "enable",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Enable peripheral.",
                            },
                            {
                                "name": "data",
                                "type": "W",
                                "n_bits": 32,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": False,
                                "descr": "Data input.",
                            },
                            {
                                "name": "mode",
                                "type": "W",
                                "n_bits": "1",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Sets the operation mode: (0) data is read using CSR; (1) data is read using system axistream interface.",
                            },
                            {
                                "name": "nwords",
                                "type": "W",
                                "n_bits": "DATA_W",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Set the number of words (with TDATA_W bits) to be written to the FIFO.",
                            },
                        ],
                    },
                    {
                        "name": "fifo",
                        "descr": "FIFO related registers",
                        "regs": [
                            {
                                "name": "fifo_full",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Full (1), or non-full (0).",
                            },
                            {
                                "name": "fifo_empty",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Full (1), or non-full (0).",
                            },
                            {
                                "name": "fifo_threshold",
                                "type": "W",
                                "n_bits": "FIFO_ADDR_W+1",
                                "rst_val": 8,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "FIFO threshold level for interrupt signal",
                            },
                            {
                                "name": "fifo_level",
                                "type": "R",
                                "n_bits": "FIFO_ADDR_W+1",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Current FIFO level",
                            },
                        ],
                    },
                ],
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "control_if_s": "iob_s",
                    "csrs_iob_o": "csrs_iob",
                    # Register interfaces
                    "soft_reset": "soft_reset",
                    "enable": "enable",
                    "data": "data",
                    "mode": "mode",
                    "nwords": "nwords",
                    "fifo_full": "fifo_full",
                    "fifo_empty": "fifo_empty",
                    "fifo_threshold": "fifo_threshold",
                    "fifo_level": "fifo_level",
                },
            },
            # TODO: Connect remaining blocks
            {
                "core_name": "iob_fifo_async",
                "instance_name": "iob_fifo_async_inst",
                "instantiate": False,
            },
            {
                "core_name": "iob_sync",
                "instance_name": "iob_sync_inst",
                "instantiate": False,
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
                "instantiate": False,
            },
            {
                "core_name": "iob_ram_at2p",
                "instance_name": "iob_ram_at2p_inst",
                "instantiate": False,
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
                "instantiate": False,
            },
        ],
    }

    return attributes_dict
