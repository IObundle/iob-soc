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
                "name": "clk_en_rst",
                "descr": "Clock and reset",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
            },
            {
                "name": "rom_bus",
                "descr": "Boot ROM bus",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "ADDR_W": BOOTROM_ADDR_W - 2,
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
                "name": "rom_rvalid_i",
                "descr": "Register input",
                "signals": [
                    {"name": "rom_ren", "width": 1},
                ],
            },
            {
                "name": "rom_rvalid_o",
                "descr": "Register output",
                "signals": [
                    {"name": "axi_rvalid"},
                ],
            },
        ],
        #
        # Blocks
        #
        "blocks": [
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
                    "data_i": "rom_rvalid_i",
                    "data_o": "rom_rvalid_o",
                },
            },
        ],
        #
        # Snippets
        #
        "snippets": [
            {
                "verilog_code": f"""
   assing rom_ren = axi_arvalid_i;
   assign ext_rom_en_o   = rom_ren;
   assign ext_rom_addr_o = axi_arddr_i[{BOOTROM_ADDR_W}:2];
   assign axi_rdata_o  = ext_rom_rdata_i;
   assign axi_arready_o  = 1'b1;  // ROM is always ready

   // Unused outputs
   assign axi_awready_o = 1'b0;
   assign axi_wready_o  = 1'b0;
   assign axi_bid_o  = {{AXI_ID{{1'b0}}}};
   assign axi_bresp_o  = 2'b0;
   assign axi_bvalid_o = 1'b0;
   assign axi_rid_o  = {{AXI_ID{{1'b0}}}};
   assign axi_rresp_o  = 2'b0;
   assign axi_rlast_o = 1'b0;
""",
            },
        ],
    }

    return attributes_dict
