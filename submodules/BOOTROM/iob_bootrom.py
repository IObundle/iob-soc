def setup(py_params_dict):
    VERSION = "0.1"
    BOOTROM_ADDR_W = (
        py_params_dict["bootrom_addr_w"] if "bootrom_addr_w" in py_params_dict else 12
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
                "min": "0",
                "max": "32",
            },
            {
                "name": "ADDR_W",
                "descr": "Address bus width",
                "type": "F",
                "val": BOOTROM_ADDR_W - 2,
                "min": "0",
                "max": "32",
            },
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "4",
            },
        ],
        #
        # Ports
        #
        "ports": [
            {
                "name": "clk_en_rst_s",
                "descr": "Clock and reset",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
            },
            {
                "name": "cbus_s",
                "descr": "Front-end control interface",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": "cbus_",
                    "ADDR_W": BOOTROM_ADDR_W,
                    "DATA_W": "DATA_W",
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
                "name": "csrs_iob",
                "descr": "Internal iob interface",
                "interface": {
                    "type": "iob",
                    "wire_prefix": "csrs_",
                    "ADDR_W": BOOTROM_ADDR_W,
                    "DATA_W": "DATA_W",
                },
            },
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
                "csr_if": "axi",
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "control_if_s": "cbus_s",
                    "csrs_iob_o": "csrs_iob",
                    # Register interfaces
                    "rom": "rom",
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
                    "clk_en_rst_s": "clk_en_rst_s",
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
   assign ext_rom_en_o   = rom_ren_rd;
   assign ext_rom_addr_o = csrs_iob_addr[{BOOTROM_ADDR_W}-1:2];
   assign rom_rdata_rd   = ext_rom_rdata_i;
   assign rom_rready_rd  = 1'b1;  // ROM is always ready
""",
            },
        ],
    }

    return attributes_dict
