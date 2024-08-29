AXI_IN_SIGNAL_NAMES = [
    ("araddr", "AXI_ADDR_W"),
    ("arprot", 3),
    ("arvalid", 1),
    ("rready", 1),
    ("arid", "AXI_ID_W"),
    ("arlen", 8),
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
    ("awlen", 8),
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
    # Number of slave interfaces (number of masters to connect to)
    N_SLAVES = (
        int(py_params_dict["num_slaves"]) if "num_slaves" in py_params_dict else 1
    )
    # Number of master interfaces (number of slaves to connect to)
    N_MASTERS = (
        int(py_params_dict["num_masters"]) if "num_masters" in py_params_dict else 1
    )

    attributes_dict = {
        "original_name": "axi_interconnect_wrapper",
        "name": "axi_interconnect_wrapper",
        "version": "0.1",
        #
        # AXI Parameters
        #
        "confs": [
            {
                "name": "AXI_ID_W",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": "AXI ID bus width",
            },
            {
                "name": "AXI_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": "AXI address bus width",
            },
            {
                "name": "AXI_DATA_W",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": "AXI data bus width",
            },
        ],
        #
        # Ports
        #
        "ports": [
            {
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "rst",
                "descr": "Synchronous reset",
                "signals": [
                    {
                        "name": "rst",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
        ],
    }
    slave_axi_ports = []
    for i in range(N_SLAVES):
        slave_axi_ports += [
            {
                "name": f"s{i}_axi",
                "descr": f"Slave {i} interface",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": f"s{i}_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LOCK_W": 1,
                },
            },
        ]
    master_axi_ports = []
    for i in range(N_MASTERS):
        master_axi_ports += [
            {
                "name": f"m{i}_axi",
                "descr": f"Master {i} axi interface",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": f"m{i}_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LOCK_W": 1,
                },
            },
        ]
    attributes_dict["ports"] += slave_axi_ports + master_axi_ports
    #
    # Wires
    #
    attributes_dict["wires"] = [
        {
            "name": "interconnect_s_axi",
            "descr": "AXI slave bus for interconnect",
            "interface": {
                "type": "axi",
                "wire_prefix": "intercon_s_",
                "mult": N_SLAVES,
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LOCK_W": 1,
            },
            "signals": [
                {"name": "intercon_s_axi_awuser", "width": N_SLAVES},
                {"name": "intercon_s_axi_wuser", "width": N_SLAVES},
                {"name": "intercon_s_axi_aruser", "width": N_SLAVES},
            ],
        },
        {
            "name": "interconnect_m_axi",
            "descr": "AXI master bus for interconnect",
            "interface": {
                "type": "axi",
                "wire_prefix": "intercon_m_",
                "mult": N_MASTERS,
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LOCK_W": 1,
            },
            "signals": [
                {"name": "intercon_m_axi_buser", "width": N_MASTERS},
                {"name": "intercon_m_axi_ruser", "width": N_MASTERS},
            ],
        },
    ]
    #
    # Blocks
    #
    attributes_dict["blocks"] = [
        {
            "core_name": "axi_interconnect",
            "instance_name": "axi_interconnect_core",
            "instance_description": "Interconnect core",
            "parameters": {
                "ID_WIDTH": "AXI_ID_W",
                "DATA_WIDTH": "AXI_DATA_W",
                "ADDR_WIDTH": "AXI_ADDR_W",
                "M_ADDR_WIDTH": "AXI_ADDR_W",
                "S_COUNT": N_SLAVES,
                "M_COUNT": N_MASTERS,
            },
            "connect": {
                "clk": "clk",
                "rst": "rst",
                "s_axi": "interconnect_s_axi",
                "m_axi": "interconnect_m_axi",
            },
        },
    ]

    # Connect all Slave AXI interfaces to interconnect
    verilog_code = "    // Connect all slave AXI interfaces to interconnect\n"
    for sig_name, _ in AXI_IN_SIGNAL_NAMES:
        verilog_code += f"    assign intercon_s_axi_{sig_name} = {{"
        for port in slave_axi_ports:
            prefix = ""
            if "port_prefix" in port["interface"]:
                prefix = port["interface"]["port_prefix"]
            suffix = ""
            if sig_name in ["awlock", "arlock"]:
                suffix = "[0]"
            verilog_code += f"{prefix}axi_{sig_name}_i{suffix}, "
        verilog_code = verilog_code[:-2] + "};\n"

    for sig_name, sig_size in AXI_OUT_SIGNAL_NAMES:
        for idx, port in enumerate(slave_axi_ports):
            prefix = ""
            if "port_prefix" in port["interface"]:
                prefix = port["interface"]["port_prefix"]
            bit_select = ""
            if type(sig_size) is not int or sig_size > 1:
                bit_select = f"[{idx}*{sig_size}+:{sig_size}]"
            verilog_code += f"    assign {prefix}axi_{sig_name}_o = intercon_s_axi_{sig_name}{bit_select}; \n"

    # Connect all Master AXI interfaces to interconnect
    verilog_code += "    // Connect all master AXI interfaces to interconnect\n"
    for sig_name, _ in AXI_OUT_SIGNAL_NAMES:
        verilog_code += f"    assign intercon_m_axi_{sig_name} = {{"
        for port in master_axi_ports:
            prefix = ""
            if "port_prefix" in port["interface"]:
                prefix = port["interface"]["port_prefix"]
            suffix = ""
            if sig_name in ["awlock", "arlock"]:
                suffix = "[0]"
            verilog_code += f"{prefix}axi_{sig_name}_i{suffix}, "
        verilog_code = verilog_code[:-2] + "};\n"

    for sig_name, sig_size in AXI_IN_SIGNAL_NAMES:
        for idx, port in enumerate(master_axi_ports):
            prefix = ""
            if "port_prefix" in port["interface"]:
                prefix = port["interface"]["port_prefix"]
            bit_select = ""
            if type(sig_size) is not int or sig_size > 1:
                bit_select = f"[{idx}*{sig_size}+:{sig_size}]"
            verilog_code += f"    assign {prefix}axi_{sig_name}_o = intercon_m_axi_{sig_name}{bit_select}; \n"

    attributes_dict["snippets"] = [
        {
            "verilog_code": verilog_code,
        }
    ]

    return attributes_dict
