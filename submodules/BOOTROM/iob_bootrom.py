def setup(py_params_dict):
    VERSION = "0.1"
    BOOTROM_ADDR_W = (
        py_params_dict["bootrom_addr_w"] if "bootrom_addr_w" in py_params_dict else 12
    )
    PREBOOTROM_ADDR_W = (
        py_params_dict["prebootrom_addr_w"]
        if "prebootrom_addr_w" in py_params_dict
        else 7
    )

    attributes_dict = {
        "original_name": "iob_bootrom",
        "name": "iob_bootrom",
        "version": VERSION,
        "confs": [
            {
                "name": "DATA_W",
                "descr": "Data bus width",
                "type": "F",
                "val": "32",
                "min": "?",
                "max": "32",
            },
            {
                "name": "ADDR_W",
                "descr": "Address bus width",
                "type": "F",
                # "val": "`IOB_BOOTROM_CSRS_ADDR_W",
                "val": 13,
                "min": "?",
                "max": "32",
            },
        ],
        #
        # Ports
        #
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock and reset",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
            },
            {
                "name": "cbus",
                "descr": "Front-end control interface",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "cbus_",
                    # "ADDR_W": "`IOB_BOOTROM_CSRS_ADDR_W",
                    "ADDR_W": 13,
                    "DATA_W": "DATA_W",
                },
            },
            {
                "name": "ibus",
                "descr": "Instruction bus",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "ibus_",
                    "DATA_W": "DATA_W",
                    # "ADDR_W": "`IOB_BOOTROM_CSRS_ADDR_W",
                    "ADDR_W": 13,
                },
            },
            {
                "name": "ext_rom_bus",
                "descr": "External ROM signals",
                "signals": [
                    {
                        "name": "ext_rom_en",
                        "direction": "output",
                        "width": "1",
                    },
                    {
                        "name": "ext_rom_addr",
                        "direction": "output",
                        "width": BOOTROM_ADDR_W - 2,
                    },
                    {
                        "name": "ext_rom_rdata",
                        "direction": "input",
                        "width": "DATA_W",
                    },
                ],
            },
        ],
        #
        # Wires
        #
        "wires": [
            {
                "name": "rom",
                "descr": "'rom' register interface",
                "signals": [
                    {"name": "rom_rdata_rd", "width": "DATA_W"},
                    {"name": "rom_rvalid_rd", "width": 1},
                    {"name": "rom_ren_rd", "width": 1},
                    {"name": "rom_rready_rd", "width": 1},
                ],
            },
            {
                "name": "preboot_rom_clk",
                "descr": "Pre-bootloader ROM clock input",
                "signals": [
                    {"name": "clk"},
                ],
            },
            {
                "name": "preboot_rom_if",
                "descr": "Pre-bootloader Memory interface",
                "signals": [
                    {"name": "ibus_iob_valid"},
                    {"name": "prebootrom_addr_i", "width": PREBOOTROM_ADDR_W - 2},
                    {"name": "ibus_iob_rdata"},
                ],
            },
            {
                "name": "ibus_rvalid_data_i",
                "descr": "Register input",
                "signals": [
                    {"name": "ibus_iob_valid"},
                ],
            },
            {
                "name": "ibus_rvalid_data_o",
                "descr": "Register output",
                "signals": [
                    {"name": "ibus_iob_rvalid"},
                ],
            },
            {
                "name": "rom_rvalid_data_i",
                "descr": "Register input",
                "signals": [
                    {"name": "rom_ren_rd"},
                ],
            },
            {
                "name": "rom_rvalid_data_o",
                "descr": "Register output",
                "signals": [
                    {"name": "rom_rvalid_rd"},
                ],
            },
        ],
        #
        # Blocks
        #
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_inst",
                "version": VERSION,
                "csrs": [
                    {
                        "name": "rom",
                        "descr": "ROM access.",
                        "regs": [
                            {
                                "name": "rom",
                                "descr": "Bootloader ROM (read).",
                                "type": "R",
                                "n_bits": "DATA_W",
                                "rst_val": 0,
                                "addr": -1,
                                "log2n_items": BOOTROM_ADDR_W - 2,
                                "autoreg": False,
                            },
                        ],
                    }
                ],
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "control_if": "cbus",
                    # Register interfaces
                    "rom": "rom",
                },
            },
            {
                "core_name": "iob_rom_sp",
                "instance_name": "preboot_rom",
                "instance_description": "Pre-bootloader ROM",
                "parameters": {
                    "ADDR_W": PREBOOTROM_ADDR_W - 2,
                    "DATA_W": "DATA_W",
                    "HEXFILE": '"iob_soc_preboot.hex"',
                },
                "connect": {
                    "clk": "preboot_rom_clk",
                    "rom_if": "preboot_rom_if",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "ibus_rvalid_r",
                "instance_description": "Instruction bus rvalid register",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": "1'b0",
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "data_i": "ibus_rvalid_data_i",
                    "data_o": "ibus_rvalid_data_o",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "rom_rvalid_r",
                "instance_description": "ROM rvalid register",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": "1'b0",
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "data_i": "rom_rvalid_data_i",
                    "data_o": "rom_rvalid_data_o",
                },
            },
        ],
        #
        # Snippets
        #
        "snippets": [
            {
                "verilog_code": f"""
   assign prebootrom_addr_i = ibus_iob_addr_i[{PREBOOTROM_ADDR_W}:2];
   assign ibus_iob_ready_o = 1'b1;
   assign ext_rom_en_o   = rom_ren_rd;
   assign ext_rom_addr_o = cbus_iob_addr_i[{BOOTROM_ADDR_W}:2];
   assign rom_rdata_rd   = ext_rom_rdata_i;
   assign rom_rready_rd  = 1'b1;  // ROM is always ready
""",
            },
        ],
    }

    return attributes_dict
