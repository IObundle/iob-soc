def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_nco",
        "name": "iob_nco",
        "version": "0.1",
        "generate_hw": False,
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
                "val": "`IOB_NCO_SWREG_ADDR_W",
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
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "clock, clock enable and reset",
            },
            {
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "clk_gen",
                "descr": "Output generated clock interface",
                "signals": [
                    {
                        "name": "clk",
                        "direction": "output",
                        "width": "1",
                        "descr": "Generated clock output",
                    },
                ],
            },
        ],
        "csrs": [
            {
                "name": "nco",
                "descr": "NCO software accessible registers.",
                "regs": [
                    {
                        "name": "SOFT_RESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "ENABLE",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "NCO enable",
                    },
                    {
                        "name": "PERIOD",
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
        "blocks": [
            {
                "core_name": "iob_reg_r",
                "instance_name": "iob_reg_r_inst",
            },
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_modcnt",
                "instance_name": "iob_modcnt_inst",
            },
            {
                "core_name": "iob_acc_ld",
                "instance_name": "iob_acc_ld_inst",
            },
            # For simulation
            {
                "core_name": "iob_tasks",
                "instance_name": "iob_tasks_inst",
                "dest_dir": "hardware/simulation/src",
            },
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
                "dest_dir": "hardware/simulation/src",
            },
        ],
    }

    return attributes_dict
