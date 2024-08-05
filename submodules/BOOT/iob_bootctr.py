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
                "val": "32",
                "min": "?",
                "max": "32",
                "descr": "Address bus width",
            },
            {
                "name": "BOOT_ROM_ADDR_W",
                "type": "F",
                "val": "12",
                "min": "?",
                "max": "24",
                "descr": "Bootloader ROM address width",
            },
            {
                "name": "PREBOOT_ROM_ADDR_W",
                "type": "F",
                "val": "8",
                "min": "?",
                "max": "24",
                "descr": "Preboot ROM address width",
            },
        ],
        "ports": [
            {
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "ADDR_W": "ADDR_W",
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
                "name": "swregs_read_out",
                "signals": [
                    {
                        "name": "CPU_RST_r",
                        "direction": "output",
                        "width": 1,
                        "descr": "CPU sync reset.",
                    },
                    {
                        "name": "CTR_r",
                        "direction": "output",
                        "width": 2,
                        "descr": "Boot controller external link.",
                    },
                ],
            },
        ],
        "csrs": [
            {
                "name": "boot",
                "descr": "Boot control register.",
                "regs": [
                    {
                        "name": "ROM",
                        "type": "R",
                        "n_bits": "DATA_W",
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": "BOOT_ROM_ADDR_W - 2",
                        "autoreg": False,
                        "descr": "Bootloader ROM.",
                    },
                    {
                        "name": "CTR",
                        "type": "W",
                        "n_bits": 2,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Boot control register (write). The register has the following values: 0: select preboot, 1: select bootloader, 2: select firmware",
                    },
                    {
                        "name": "CPU_RST",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "CPU reset control register (write). 1 to reset the CPU, 0 to release the CPU from reset.",
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
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
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
