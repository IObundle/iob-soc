import copy

import iob_soc

AXI_SIGNAL_NAMES = [
    "araddr",
    "arprot",
    "arvalid",
    "arready",
    "rdata",
    "rresp",
    "rvalid",
    "rready",
    "arid",
    "arlen",
    "arsize",
    "arburst",
    "arlock",
    "arcache",
    "arqos",
    "rid",
    "rlast",
    "awaddr",
    "awprot",
    "awvalid",
    "awready",
    "wdata",
    "wstrb",
    "wvalid",
    "wready",
    "bresp",
    "bvalid",
    "bready",
    "awid",
    "awlen",
    "awsize",
    "awburst",
    "awlock",
    "awcache",
    "awqos",
    "wlast",
    "bid",
]


def setup(py_params_dict):
    INIT_MEM = py_params_dict["INIT_MEM"] if "INIT_MEM" in py_params_dict else False
    USE_ETHERNET = (
        py_params_dict["USE_ETHERNET"] if "USE_ETHERNET" in py_params_dict else False
    )
    USE_EXTMEM = (
        py_params_dict["USE_EXTMEM"] if "USE_EXTMEM" in py_params_dict else False
    )
    DATA_W = py_params_dict["data_w"] if "data_w" in py_params_dict else 32
    iob_soc_attr = iob_soc.setup(py_params_dict)

    attributes_dict = {
        "original_name": "iob_soc_sim_wrapper",
        "name": "iob_soc_sim_wrapper",
        "version": "0.1",
        "confs": [
            {
                "name": "AXI_ID_W",
                "type": "F",
                "val": "0",
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
            },
            "descr": "Testbench uart swreg interface",
        },
    ]
    if USE_ETHERNET:
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
            "name": "clk_rst",
            "descr": "",
            "signals": [
                {"name": "clk"},
                {"name": "rst"},
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
    if USE_ETHERNET:
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
    if USE_EXTMEM:
        attributes_dict["wires"] += [
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
                },
                "descr": "AXI slave bus for interconnect",
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
            "purpose": "common",
            "data_w": DATA_W,
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
    if USE_ETHERNET:
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
    if USE_EXTMEM:
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
                    "clk_rst": "clk_rst",
                    "s_axi": "interconnect_s_axi",
                    "m_axi": "memory_axi",
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
                    "clk_rst": "clk_rst",
                    "axi": "memory_axi",
                },
            },
        ]
        if INIT_MEM:
            attributes_dict["blocks"][-1]["parameters"].update(
                {
                    "FILE": "init_ddr_contents.hex",
                    "FILE_SIZE": "2 ** (AXI_ADDR_W - 2)",
                }
            )
    attributes_dict["snippets"] = []
    if USE_ETHERNET:
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

    if USE_EXTMEM:
        # Connect all IOb-SoC AXI interfaces to interconnect
        verilog_code = "    // Connect all IOb-SoC AXI interfaces to interconnect\n"
        for sig_name in AXI_SIGNAL_NAMES:
            verilog_code += f"    assign intercon_s_axi_{sig_name} = {{"
            for wire in axi_wires:
                prefix = ""
                if "wire_prefix" in wire["interface"]:
                    prefix = wire["interface"]["wire_prefix"]
                verilog_code += f"{prefix}_axi_{sig_name}, "
            verilog_code = verilog_code[:-2] + "};\n"
        attributes_dict["snippets"] += [
            {
                "verilog_code": verilog_code,
            }
        ]

    return attributes_dict
