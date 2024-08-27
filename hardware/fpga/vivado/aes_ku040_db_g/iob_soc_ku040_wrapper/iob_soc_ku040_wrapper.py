import copy

import iob_soc


def setup(py_params_dict):

    # user-passed parameters
    params = py_params_dict["iob_soc_params"]

    # setup iob-soc and get all its attributes
    iob_soc_attr = iob_soc.setup(params)

    attributes_dict = {
        "original_name": "iob_soc_ku040_wrapper",
        "name": "iob_soc_fpga_wrapper",
        "version": "0.1",
        #
        # Configuration
        #
        "confs": [
            {
                "name": "AXI_ID_W",
                "type": "F",
                "val": "4",
                "min": "1",
                "max": "32",
                "descr": "AXI ID bus width",
            },
            {
                "name": "AXI_LEN_W",
                "type": "F",
                "val": "8",
                "min": "1",
                "max": "8",
                "descr": "AXI burst length width",
            },
            {
                "name": "AXI_ADDR_W",
                "type": "F",
                "val": "`DDR_ADDR_W",
                "min": "1",
                "max": "32",
                "descr": "AXI address bus width",
            },
            {
                "name": "AXI_DATA_W",
                "type": "F",
                "val": "`DDR_DATA_W",
                "min": "1",
                "max": "32",
                "descr": "AXI data bus width",
            },
        ],
    }
    #
    # Ports
    #
    attributes_dict["ports"] = [
        {
            "name": "clk_rst",
            "descr": "Clock and reset",
            "signals": [
                {"name": "c0_sys_clk_clk_p", "direction": "input", "width": "1"},
                {"name": "c0_sys_clk_clk_n", "direction": "input", "width": "1"},
                {"name": "areset", "direction": "input", "width": "1"},
            ],
        },
        {
            "name": "rs232",
            "descr": "Serial port",
            "signals": [
                {"name": "txd", "direction": "output", "width": "1"},
                {"name": "rxd", "direction": "input", "width": "1"},
            ],
        },
    ]
    if params["use_extmem"]:
        attributes_dict["ports"] += [
            {
                "name": "ddr4_pins",
                "descr": "External DDR4 memory interface",
                "signals": [
                    {"name": "c0_ddr4_act_n", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_adr", "direction": "output", "width": "17"},
                    {"name": "c0_ddr4_ba", "direction": "output", "width": "2"},
                    {"name": "c0_ddr4_bg", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_cke", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_odt", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_cs_n", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_ck_t", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_ck_c", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_reset_n", "direction": "output", "width": "1"},
                    {"name": "c0_ddr4_dm_dbi_n", "direction": "inout", "width": "4"},
                    {"name": "c0_ddr4_dq", "direction": "inout", "width": "32"},
                    {"name": "c0_ddr4_dqs_c", "direction": "inout", "width": "4"},
                    {"name": "c0_ddr4_dqs_t", "direction": "inout", "width": "4"},
                ],
            },
        ]
    if params["use_ethernet"]:
        attributes_dict["ports"] += [
            {
                "name": "mii",
                "descr": "MII ethernet interface",
                "signals": [
                    {"name": "enet_resetn", "direction": "output", "width": "1"},
                    {"name": "enet_rx_clk", "direction": "input", "width": "1"},
                    {"name": "enet_gtx_clk", "direction": "output", "width": "1"},
                    {"name": "enet_rx_d0", "direction": "input", "width": "1"},
                    {"name": "enet_rx_d1", "direction": "input", "width": "1"},
                    {"name": "enet_rx_d2", "direction": "input", "width": "1"},
                    {"name": "enet_rx_d3", "direction": "input", "width": "1"},
                    {"name": "enet_rx_dv", "direction": "input", "width": "1"},
                    # {"name": "enet_rx_err", "direction": "output", "width": "1"},
                    {"name": "enet_tx_d0", "direction": "output", "width": "1"},
                    {"name": "enet_tx_d1", "direction": "output", "width": "1"},
                    {"name": "enet_tx_d2", "direction": "output", "width": "1"},
                    {"name": "enet_tx_d3", "direction": "output", "width": "1"},
                    {"name": "enet_tx_en", "direction": "output", "width": "1"},
                    # {"name": "enet_tx_err", "direction": "output", "width": "1"},
                ],
            },
        ]

    #
    # Wires
    #
    fpga_wrapper_wires = []

    # Declare fpga wrapper wires for IOb-SoC ports
    for port in iob_soc_attr["ports"]:
        if port["name"] not in [
            "rs232",
            "rom_bus",
            "spram_bus",
            "sram_i_bus",
            "sram_d_bus",
        ]:
            wire = copy.deepcopy(port)
            if "interface" in wire and "port_prefix" in wire["interface"]:
                wire["interface"]["wire_prefix"] = wire["interface"]["port_prefix"]
                wire["interface"].pop("port_prefix")
            if "signals" in wire:
                for sig in wire["signals"]:
                    sig.pop("direction")
            fpga_wrapper_wires.append(wire)

    # Declare wires for IOb-SoC AXI interfaces
    axi_wires = []
    for wire in fpga_wrapper_wires:
        # Skip non-AXI wires
        if "interface" not in wire or wire["interface"]["type"] != "axi":
            continue
        axi_wires.append(wire)

    attributes_dict["wires"] = fpga_wrapper_wires + [
        {
            "name": "rs232_int",
            "descr": "iob-soc uart interface",
            "signals": [
                {"name": "rxd"},
                {"name": "txd"},
                {"name": "rs232_rts", "width": "1"},
                {"name": "high", "width": "1"},
            ],
        },
    ]
    for idx, wire in enumerate(axi_wires):
        prefix = ""
        if "wire_prefix" in wire["interface"]:
            prefix = wire["interface"]["wire_prefix"]
        attributes_dict["wires"] += [
            {
                "name": f"s{idx}_clk_rst",
                "descr": f"Interconnect slave {idx} clock reset interface",
                "signals": [
                    {"name": "clk"},
                    {"name": f"s{idx}_arstn", "width": "1"},
                ],
            },
        ]
    if params["use_ethernet"]:
        attributes_dict["wires"] += [
            # eth clock
            {
                "name": "rxclk_buf_io",
                "descr": "IBUFG io",
                "signals": [
                    {"name": "enet_rx_clk"},
                    {"name": "eth_clk", "width": "1"},
                ],
            },
            {
                "name": "oddre1_io",
                "descr": "ODDRE1 io",
                "signals": [
                    {"name": "enet_gtx_clk"},
                    {"name": "eth_clk"},
                    {"name": "high"},
                    {"name": "low", "width": "1"},
                    {
                        "name": "enet_resetn_inv",
                        "width": "1",
                    },  # TODO: Connect and invert enet_resetn
                ],
            },
        ]

    if params["use_extmem"]:
        attributes_dict["wires"] += [
            {
                "name": "intercon_clk_rst",
                "descr": "AXI interconnect clock and reset inputs",
                "signals": [
                    {"name": "intercon_clk", "width": "1"},
                    {"name": "intercon_rst", "width": "1"},
                ],
            },
            {
                "name": "ddr4_axi_clk_rst",
                "descr": "",
                "signals": [
                    {"name": "intercon_clk"},
                    {"name": "ddr4_axi_arstn", "width": "1"},
                ],
            },
            {
                "name": "ddr4_axi",
                "descr": "AXI bus to connect interconnect and memory",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "mem_",
                    "ID_W": "AXI_ID_W",
                    "LEN_W": "AXI_LEN_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LOCK_W": 1,
                },
            },
        ]
    if not params["use_extmem"]:
        attributes_dict["wires"] += [
            {
                "name": "clk_wizard_out",
                "descr": "Connect clock wizard outputs to iob-soc clock and reset",
                "signals": [
                    {"name": "clk", "width": "1"},
                    {"name": "arst", "width": "1"},
                ],
            },
        ]

    #
    # Blocks
    #
    attributes_dict["blocks"] = [
        {
            # IOb-SoC Memory Wrapper
            "core_name": "iob_soc_mwrap",
            "instance_name": "iob_soc_mwrap",
            "instance_description": "IOb-SoC instance",
            "parameters": {
                "AXI_ID_W": "AXI_ID_W",
                "AXI_LEN_W": "AXI_LEN_W",
                "AXI_ADDR_W": "AXI_ADDR_W",
                "AXI_DATA_W": "AXI_DATA_W",
            },
            "connect": {"rs232": "rs232_int"}
            | {i["name"]: i["name"] for i in fpga_wrapper_wires},  # WHAT IS THIS?
            "dest_dir": "hardware/common_src",
            "iob_soc_params": params,
        },
    ]
    if params["use_ethernet"]:
        # Eth clock
        attributes_dict["blocks"] += [
            {
                "core_name": "xilinx_ibufg",
                "instance_name": "rxclk_buf",
                "connect": {
                    "io": "rxclk_buf_io",
                },
            },
            {
                "core_name": "xilinx_oddre1",
                "instance_name": "oddre1_inst",
                "connect": {
                    "io": "oddre1_io",
                },
            },
        ]
    if params["use_extmem"]:
        # Interconnect
        attributes_dict["blocks"] += [
            {
                "core_name": "xilinx_axi_interconnect",
                "instance_name": "axi_async_bridge",
                "instance_description": "Interconnect instance",
                "parameters": {
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_LEN_W": "AXI_LEN_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                "connect": {
                    "clk_rst_i": "clk_rst",
                    "m0_clk_rst": "ddr4_m0_clk_rst",
                    "m0_axi": "ddr4_axi",
                },
                "num_slaves": len(axi_wires),
            },
        ]
        # Connect axi wires to slave interfaces of interconnect
        for idx, wire in enumerate(axi_wires):
            prefix = ""
            if "wire_prefix" in wire["interface"]:
                prefix = wire["interface"]["wire_prefix"]
            attributes_dict["blocks"][-1]["connect"] |= {
                f"s{idx}_clk_rst": f"s{idx}_clk_rst",
                f"s{idx}_axi": f"{prefix}axi",
            }
        # DDR4 controller
        attributes_dict["blocks"] += [
            {
                "core_name": "xilinx_ddr4_ctrl",
                "instance_name": "ddr4_ctrl",
                "instance_description": "DDR4 controller instance",
                "parameters": {
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_LEN_W": "AXI_LEN_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                "connect": {
                    "clk_rst": "intercon_clk_rst",
                    "axi_clk_rst": "ddr4_axi_clk_rst",
                    "axi": "ddr4_axi",
                    "ddr4": "ddr4_pins",
                },
            },
        ]
    if not params["use_extmem"]:
        attributes_dict["blocks"] += [
            # Clock wizard
            {
                "core_name": "xilinx_clock_wizard",
                "instance_name": "clk_250_to_100_MHz",
                "instance_description": "PLL to generate system clock",
                "parameters": {
                    "OUTPUT_PER": 10,
                    "INPUT_PER": 4,
                },
                "connect": {
                    "clk_rst_i": "clk_rst",
                    "clk_rst_o": "clk_wizard_out",
                },
            },
        ]

    #
    # Snippets
    #
    attributes_dict["snippets"] = [
        {
            "verilog_code": """
    // General connections
    assign high = 1'b1;
    assign cke = 1'b1;
""",
        },
    ]
    if params["use_ethernet"]:
        attributes_dict["snippets"] += [
            {
                "verilog_code": """
    // Ethernet connections
    assign low = 1'b0;
""",
            },
        ]
    if params["use_extmem"]:
        attributes_dict["snippets"] += [
            {
                "verilog_code": """
    // External memory connections
    assign arst = ~s0_arstn;
""",
            },
        ]

    return attributes_dict
