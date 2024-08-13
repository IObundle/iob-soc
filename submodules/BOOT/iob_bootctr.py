def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_bootctr",
        "name": "iob_bootctr",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "F",
                "val": "32",
                "min": "?",
                "max": "32",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "F",
                "val": "`IOB_BOOTCTR_SWREG_ADDR_W",
                "min": "?",
                "max": "32",
                "descr": "Address bus width",
            },
            # These 2 below are copies of the ones defined in iob-soc.py
            {
                "name": "PREBOOTROM_ADDR_W",
                "type": "F",
                "val": "8",
                "min": "?",
                "max": "24",
                "descr": "Preboot ROM address width",
            },
            {
                "name": "BOOTROM_ADDR_W",
                "type": "F",
                "val": "12",
                "min": "?",
                "max": "24",
                "descr": "Bootloader ROM address width",
            },
        ],
        "ports": [
            {
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "ADDR_W": "`IOB_BOOTCTR_SWREG_ADDR_W",
                    "DATA_W": "DATA_W",
                },
                "descr": "Front-end interface",
            },
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
            {
                "name": "bootctr_i_bus",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "bootctr_i_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "Instruction bus",
            },
            {
                "name": "boot_rom_bus",
                "descr": "Boot ROM bus",
                "signals": [
                    {
                        "name": "boot_rom_en",
                        "direction": "output",
                        "width": "1",
                    },
                    {
                        "name": "boot_rom_addr",
                        "direction": "output",
                        "width": "BOOTROM_ADDR_W",
                    },
                    {
                        "name": "boot_rom_rdata",
                        "direction": "input",
                        "width": "DATA_W",
                    },
                ],
            },
        ],
        "csrs": [
            {
                "name": "rom",
                "descr": "ROM access.",
                "regs": [
                    {
                        "name": "ROM",
                        "type": "R",
                        "n_bits": "DATA_W",
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": "BOOTROM_ADDR_W - 2",
                        "autoreg": False,
                        "descr": "Bootloader ROM (read).",
                    },
                ],
            }
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_pulse_gen",
                "instance_name": "iob_pulse_gen_inst",
            },
            {
                "core_name": "iob_rom_dp",
                "instance_name": "iob_rom_dp_inst",
            },
        ],
    }
    return attributes_dict
