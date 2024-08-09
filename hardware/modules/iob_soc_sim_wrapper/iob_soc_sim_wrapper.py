import copy

import iob_soc

AXI_IN_SIGNAL_NAMES = [
    ("araddr", "AXI_ADDR_W"),
    ("arprot", 3),
    ("arvalid", 1),
    ("rready", 1),
    ("arid", "AXI_ID_W"),
    ("arlen", "AXI_LEN_W"),
    ("arsize", 3),
    ("arburst", 2),
    ("arlock", 2),
    ("arcache", 4),
    ("arqos", 4),
    ("awaddr", "AXI_ADDR_W"),
    ("awprot", 3),
    ("awvalid", 1),
    ("wdata", "AXI_DATA_W"),
    ("wstrb", "AXI_DATA_W / 8"),
    ("wvalid", 1),
    ("bready", 1),
    ("awid", "AXI_ID_W"),
    ("awlen", "AXI_LEN_W"),
    ("awsize", 3),
    ("awburst", 2),
    ("awlock", 2),
    ("awcache", 4),
    ("awqos", 4),
    ("wlast", 1),
]

AXI_OUT_SIGNAL_NAMES = [
    ("arready", 1),
    ("rdata", "AXI_DATA_W"),
    ("rresp", 2),
    ("rvalid", 1),
    ("rid", "AXI_ID_W"),
    ("rlast", 1),
    ("awready", 1),
    ("wready", 1),
    ("bresp", 2),
    ("bvalid", 1),
    ("bid", "AXI_ID_W"),
]


def setup(py_params_dict):

    params = py_params_dict["iob_soc_params"]

    iob_soc_attr = iob_soc.setup(params)

    attributes_dict = {
        "original_name": "iob_soc_sim_wrapper",
        "name": "iob_soc_sim_wrapper",
        "version": "0.1",
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
    attributes_dict["ports"] = [
        {
            "name": "clk_en_rst",
            "interface": {
                "type": "clk_en_rst",
                "subtype": "slave",
            },
            "descr": "Clock, clock enable and reset",
        },
        {
            "name": "trap",
            "descr": "CPU trap",
            "signals": [
                {"name": "trap", "direction": "output", "width": "1"},
            ],
        },
        {
            "name": "uart",
            "interface": {
                "type": "iob",
                "subtype": "slave",
                "port_prefix": "uart_",
                "ADDR_W": 3,
            },
            "descr": "Testbench uart swreg interface",
        },
    ]
    if params["use_ethernet"]:
        attributes_dict["ports"] += [
            {
                "name": "ethernet",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "ethernet_",
                },
                "descr": "Testbench ethernet swreg interface",
            },
        ]

    # Get all simulation wrapper wires based on IOb-SoC ports
    simwrap_wires = []
    for port in iob_soc_attr["ports"]:
        if port["name"] not in [
            "clk_en_rst",
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
            simwrap_wires.append(wire)

    # Get all IOb-SoC AXI interfaces
    axi_wires = []
    for wire in simwrap_wires:
        # Skip non-AXI wires
        if "interface" not in wire or wire["interface"]["type"] != "axi":
            continue
        axi_wires.append(wire)

    attributes_dict["wires"] = simwrap_wires + [
        {
            "name": "clk",
            "descr": "",
            "signals": [
                {"name": "clk"},
            ],
        },
        {
            "name": "rst",
            "descr": "",
            "signals": [
                {"name": "arst"},
            ],
        },
        # UART
        {
            "name": "rs232_invert",
            "descr": "Invert order of rs232 signals",
            "signals": [
                {"name": "rs232_txd"},
                {"name": "rs232_rxd"},
                {"name": "rs232_cts"},
                {"name": "rs232_rts"},
            ],
        },
    ]
    if params["use_ethernet"]:
        attributes_dict["wires"] += [
            {
                "name": "eth_axi",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "eth_",
                },
                "descr": "Ethernet AXI bus",
            },
            {
                "name": "eth_mii_invert",
                "descr": "Invert order of signals in ethernet MII bus",
                "signals": [
                    {"name": "eth_MTxClk", "width": "1"},
                    {"name": "MRxDv"},
                    {"name": "MRxD"},
                    {"name": "MRxErr"},
                    {"name": "eth_MRxClk", "width": "1"},
                    {"name": "MTxEn"},
                    {"name": "MTxD"},
                    {"name": "MTxErr"},
                    {"name": "eth_MColl", "width": "1"},
                    {"name": "eth_MCrS", "width": "1"},
                    {"name": "eth_MDC", "width": "1"},
                    {"name": "eth_MDIO", "width": "1"},
                ],
            },
            {
                "name": "eth_int",
                "descr": "Ethernet interrupt",
                "signals": [
                    {"name": "eth_interrupt"},
                ],
            },
        ]
    if params["use_extmem"]:
        attributes_dict["wires"] += [
            {
                "name": "interconnect_memory_axi",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "intercon_mem_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
                "descr": "AXI bus to connect interconnect and memory",
                "signals": [
                    {"name": "intercon_mem_m_axi_buser", "width": 1},
                    {"name": "intercon_mem_m_axi_ruser", "width": 1},
                ],
            },
            {
                "name": "memory_axi",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "mem_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
                "descr": "AXI bus to connect interconnect and memory",
            },
            {
                "name": "interconnect_s_axi",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "intercon_s_",
                    "mult": len(axi_wires),
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
                "descr": "AXI slave bus for interconnect",
                "signals": [
                    {"name": "intercon_s_axi_awuser", "width": 1},
                    {"name": "intercon_s_axi_wuser", "width": 1},
                    {"name": "intercon_s_axi_aruser", "width": 1},
                ],
            },
        ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_soc_mwrap",
            "instance_name": "iob_soc_mwrap",
            "parameters": {
                "AXI_ID_W": "AXI_ID_W",
                "AXI_LEN_W": "AXI_LEN_W",
                "AXI_ADDR_W": "AXI_ADDR_W",
                "AXI_DATA_W": "AXI_DATA_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
            }
            | {i["name"]: i["name"] for i in simwrap_wires},
            "dest_dir": "hardware/common_src",
            "iob_soc_params": params,
        },
        {
            "core_name": "iob_uart",
            "instance_name": "uart_tb",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "uart",
                "rs232": "rs232_invert",
            },
        },
    ]
    if params["use_ethernet"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_eth",
                "instance_name": "eth_tb",
                "parameters": {
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_LEN_W": "AXI_LEN_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "iob": "ethernet",
                    "axi": "eth_axi",
                    "mii": "eth_mii_invert",
                    "interrupt": "eth_int",
                },
            },
        ]
    if params["use_extmem"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "axi_interconnect",
                "instance_name": "system_axi_interconnect",
                "parameters": {
                    "ID_WIDTH": "AXI_ID_W",
                    "DATA_WIDTH": "AXI_DATA_W",
                    "ADDR_WIDTH": "AXI_ADDR_W",
                    "M_ADDR_WIDTH": "AXI_ADDR_W",
                    "S_COUNT": len(axi_wires),
                    "M_COUNT": "1",
                },
                "connect": {
                    "clk": "clk",
                    "rst": "rst",
                    "s_axi": "interconnect_s_axi",
                    "m_axi": "interconnect_memory_axi",
                },
            },
            {
                "core_name": "axi_ram",
                "instance_name": "ddr_model_mem",
                "parameters": {
                    "ID_WIDTH": "AXI_ID_W",
                    "ADDR_WIDTH": "AXI_ADDR_W",
                    "DATA_WIDTH": "AXI_DATA_W",
                },
                "connect": {
                    "clk": "clk",
                    "rst": "rst",
                    "axi": "memory_axi",
                },
            },
        ]
        if params["init_mem"]:
            attributes_dict["blocks"][-1]["parameters"].update(
                {
                    "FILE": '"init_ddr_contents.hex"',
                    "FILE_SIZE": "2 ** (AXI_ADDR_W - 2)",
                }
            )
    attributes_dict["snippets"] = []
    if params["use_ethernet"]:
        attributes_dict["snippets"] += [
            {
                "verilog_code": """
    //ethernet clock: 4x slower than system clock
    reg [1:0] eth_cnt = 2'b0;
    reg       eth_clk;

    always @(posedge clk_i) begin
      eth_cnt <= eth_cnt + 1'b1;
      eth_clk <= eth_cnt[1];
    end

    // Set ethernet AXI inputs to low
    assign eth_axi_awready_i = 1'b0;
    assign eth_axi_wready_i  = 1'b0;
    assign eth_axi_bid_i     = {AXI_ID_W{1'b0}};
    assign eth_axi_bresp_i   = 2'b0;
    assign eth_axi_bvalid_i  = 1'b0;
    assign eth_axi_arready_i = 1'b0;
    assign eth_axi_rid_i     = {AXI_ID_W{1'b0}};
    assign eth_axi_rdata_i   = {AXI_DATA_W{1'b0}};
    assign eth_axi_rresp_i   = 2'b0;
    assign eth_axi_rlast_i   = 1'b0;
    assign eth_axi_rvalid_i  = 1'b0;

    // Connect ethernet MII signals
    assign eth_MTxClk       = eth_clk;
    assign eth_MRxClk       = eth_clk;
    assign eth_MColl        = 1'b0;
    assign eth_MCrS         = 1'b0;

""",
            },
        ]

    if params["use_extmem"]:
        # Connect all IOb-SoC AXI interfaces to interconnect
        verilog_code = "    // Connect all IOb-SoC AXI interfaces to interconnect\n"
        for sig_name, _ in AXI_IN_SIGNAL_NAMES:
            verilog_code += f"    assign intercon_s_axi_{sig_name} = {{"
            for wire in axi_wires:
                prefix = ""
                if "wire_prefix" in wire["interface"]:
                    prefix = wire["interface"]["wire_prefix"]
                suffix = ""
                if sig_name in ["awlock", "arlock"]:
                    suffix = "[0]"
                verilog_code += f"{prefix}axi_{sig_name}{suffix}, "
            verilog_code = verilog_code[:-2] + "};\n"

        for sig_name, sig_size in AXI_OUT_SIGNAL_NAMES:
            for idx, wire in enumerate(axi_wires):
                prefix = ""
                if "wire_prefix" in wire["interface"]:
                    prefix = wire["interface"]["wire_prefix"]
                bit_select = ""
                if type(sig_size) is not int or sig_size > 1:
                    bit_select = f"[{idx}*{sig_size}+:{sig_size}]"
                verilog_code += f"    assign {prefix}axi_{sig_name} = intercon_s_axi_{sig_name}{bit_select}; \n"

        # Connect interconnect wires to memory wires
        verilog_code += "    // Connect all interconnect wires to memory\n"
        for sig_name, _ in AXI_IN_SIGNAL_NAMES:
            verilog_code += (
                f"    assign mem_axi_{sig_name} = intercon_mem_axi_{sig_name};\n"
            )
        for sig_name, _ in AXI_OUT_SIGNAL_NAMES:
            verilog_code += (
                f"    assign intercon_mem_axi_{sig_name} = mem_axi_{sig_name};\n"
            )

        attributes_dict["snippets"] += [
            {
                "verilog_code": verilog_code,
            }
        ]

    return attributes_dict
