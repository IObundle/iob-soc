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
                "min": "0",
                "max": "32",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "4",  # Same as `IOB_NCO_CSRS_ADDR_W
                "min": "0",
                "max": "32",
                "descr": "Address bus width",
            },
            {
                "name": "FRAC_W",
                "type": "P",
                "val": "8",
                "min": "0",
                "max": "32",
                "descr": "Bit-width of the fractional part of the period value. Used to differentiate between the integer and fractional parts of the period. ",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "clock, clock enable and reset",
            },
            {
                "name": "iob_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "ADDR_W": "4",  # Same as `IOB_NCO_CSRS_ADDR_W
                    "DATA_W": "DATA_W",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "clk_src_i",
                "descr": "Source clock interface",
                "signals": [
                    {
                        "name": "clk_in",
                        "direction": "input",
                        "width": "1",
                        "descr": "Source clock input",
                    },
                ],
            },
            {
                "name": "clk_gen_o",
                "descr": "Output generated clock interface",
                "signals": [
                    {
                        "name": "clk_out",
                        "direction": "output",
                        "width": "1",
                        "descr": "Generated clock output",
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
            # Register wires
            {
                "name": "softreset",
                "descr": "",
                "signals": [
                    {"name": "softreset_wr", "width": 1},
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
                "name": "period",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_wr", "width": 32},
                    {"name": "period_wen_wr", "width": 1},
                    {"name": "period_wready_wr", "width": 1},
                ],
            },
            # nco sync wires
            {
                "name": "period_wdata_sync_in",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_wr"},
                ],
            },
            {
                "name": "period_wen_sync_in",
                "descr": "",
                "signals": [
                    {"name": "period_wen_wr"},
                ],
            },
            {
                "name": "period_wdata_sync_out",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_wr"},
                ],
            },
            {
                "name": "period_wen_sync_out",
                "descr": "",
                "signals": [
                    {"name": "period_wen_wr"},
                ],
            },
            # clk src domain wires
            {
                "name": "softreset_clk_src",
                "descr": "",
                "signals": [
                    {"name": "softreset_clk_src", "width": 1},
                ],
            },
            {
                "name": "enable_clk_src",
                "descr": "",
                "signals": [
                    {"name": "enable_clk_src", "width": 1},
                ],
            },
            {
                "name": "period_clk_src",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_clk_src", "width": 32},
                    {"name": "period_wen_clk_src", "width": 1},
                ],
            },
            # per_reg
            {
                "name": "per_reg_en_rst",
                "descr": "",
                "signals": [
                    {"name": "period_wen_clk_src"},
                    {"name": "softreset_clk_src"},
                ],
            },
            {
                "name": "per_reg_data_i",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_clk_src"},
                ],
            },
            {
                "name": "per_reg_data_o",
                "descr": "",
                "signals": [
                    {"name": "period_r", "width": "DATA_W"},
                ],
            },
            # clk_out_reg
            {
                "name": "clk_out_reg_en_rst",
                "descr": "",
                "signals": [
                    {"name": "enable_clk_src"},
                    {"name": "softreset_clk_src"},
                ],
            },
            {
                "name": "clk_out_reg_data_i",
                "descr": "",
                "signals": [
                    {"name": "clk_int", "width": "1"},
                ],
            },
            # acc_ld
            {
                "name": "acc_ld_clk_en_rst",
                "descr": "",
                "signals": [
                    {"name": "clk_in"},
                    {"name": "cke"},
                    {"name": "arst"},
                ],
            },
            {
                "name": "acc_ld_ld",
                "descr": "",
                "signals": [
                    {"name": "period_wen_clk_src"},
                ],
            },
            {
                "name": "acc_ld_ld_val",
                "descr": "",
                "signals": [
                    {"name": "period_wdata_clk_src"},
                ],
            },
            {
                "name": "acc_ld_incr",
                "descr": "",
                "signals": [
                    {"name": "diff", "width": "DATA_W"},
                ],
            },
            {
                "name": "acc_ld_data",
                "descr": "",
                "signals": [
                    {"name": "acc_out", "width": "DATA_W"},
                ],
            },
            # modcnt
            {
                "name": "modcnt_en_rst",
                "descr": "",
                "signals": [
                    {"name": "enable_clk_src"},
                    {"name": "period_wen_clk_src"},
                ],
            },
            {
                "name": "modcnt_mod",
                "descr": "",
                "signals": [
                    {"name": "quant", "width": "DATA_W-FRAC_W", "isvar": True},
                ],
            },
            {
                "name": "modcnt_data",
                "descr": "",
                "signals": [
                    {"name": "cnt", "width": "DATA_W-FRAC_W"},
                ],
            },
            {
                "name": "clk_rst",
                "descr": "",
                "signals": [
                    {"name": "clk"},
                    {"name": "arst"},
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
                        "name": "nco",
                        "descr": "NCO software accessible registers.",
                        "regs": [
                            {
                                "name": "softreset",
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
                                "descr": "NCO enable",
                            },
                            {
                                "name": "period",
                                "type": "W",
                                "n_bits": 32,
                                "rst_val": 5,
                                "log2n_items": 0,
                                "autoreg": False,
                                "descr": "Period of the generated clock in terms of the number of system clock cycles + 1 implicit clock cycle. The period value is divided into integer and fractional parts where the lower FRAC_W bits represent the fractional part, and the remaining upper bits represent the integer part.",
                            },
                        ],
                    }
                ],
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "control_if_s": "iob_s",
                    "csrs_iob_o": "csrs_iob",
                    # Register interfaces
                    "softreset": "softreset",
                    "enable": "enable",
                    "period": "period",
                },
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "per_reg",
                "instance_description": "Fractional period value register",
                "parameters": {
                    "DATA_W": "DATA_W",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "en_rst_i": "per_reg_en_rst",
                    "data_i": "per_reg_data_i",
                    "data_o": "per_reg_data_o",
                },
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "clk_out_reg",
                "instance_description": "Output clock register",
                "parameters": {
                    "DATA_W": "1",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "en_rst_i": "clk_out_reg_en_rst",
                    "data_i": "clk_out_reg_data_i",
                    "data_o": "clk_gen_o",
                },
            },
            {
                "core_name": "iob_acc_ld",
                "instance_name": "acc_ld",
                "instance_description": "Modulator accumulator",
                "parameters": {
                    "DATA_W": "DATA_W",
                },
                "connect": {
                    "clk_en_rst_s": "acc_ld_clk_en_rst",
                    "en_rst_i": "clk_out_reg_en_rst",
                    "ld_i": "acc_ld_ld",
                    "ld_val_i": "acc_ld_ld_val",
                    "incr_i": "acc_ld_incr",
                    "data_o": "acc_ld_data",
                },
            },
            {
                "core_name": "iob_modcnt",
                "instance_name": "modcnt",
                "instance_description": "Output period counter",
                "parameters": {
                    "DATA_W": "DATA_W - FRAC_W",
                },
                "connect": {
                    "clk_en_rst_s": "acc_ld_clk_en_rst",
                    "en_rst_i": "modcnt_en_rst",
                    "mod_i": "modcnt_mod",
                    "data_o": "modcnt_data",
                },
            },
            {
                "core_name": "iob_nco_sync",
                "instance_name": "nco_sync_inst",
                "instance_description": "Syncronize from CSR domain to clk_src domain",
                "parameters": {
                    "PERIOD_W": "DATA_W",
                },
                "connect": {
                    "clk_rst_s": "clk_rst",
                    "clk_i": "clk_src_i",
                    "soft_reset_i": "softreset",
                    "enable_i": "enable",
                    "period_wdata_i": "period_wdata_sync_in",
                    "period_wen_i": "period_wen_sync_in",
                    "soft_reset_o": "softreset_clk_src",
                    "enable_o": "enable_clk_src",
                    "period_wdata_o": "period_wdata_sync_out",
                    "period_wen_o": "period_wen_sync_out",
                },
            },
            # For simulation
            {
                "core_name": "iob_tasks",
                "instance_name": "iob_tasks_inst",
                "dest_dir": "hardware/simulation/src",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    // PERIOD Manual logic
    assign period_wready_wr = 1'b1;

    assign diff    = period_r - {quant, {FRAC_W{1'b0}}};
    assign clk_int = (cnt > (quant / 2));

    always @* begin
        if (acc_out[FRAC_W-1:0] == {1'b1, {FRAC_W - 1{1'b0}}})
            quant = acc_out[DATA_W-1:FRAC_W] + ^acc_out[DATA_W-1:FRAC_W];
        else if (acc_out[FRAC_W-1]) quant = acc_out[DATA_W-1:FRAC_W] + 1'b1;
        else quant = acc_out[DATA_W-1:FRAC_W];
    end
""",
            },
        ],
    }

    return attributes_dict
