# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

interfaces = {
    "iob": [
        ("valid", "output", 1),
        ("addr", "output", "ADDR_W"),
        ("wdata", "output", "DATA_W"),
        ("wstrb", "output", "DATA_W / 8"),
        ("rvalid", "input", 1),
        ("rdata", "input", "DATA_W"),
        ("ready", "input", 1),
    ],
    "axil": [
        ("awaddr", "output", "ADDR_W"),
        ("awprot", "output", "PROT_W"),
        ("awvalid", "output", 1),
        ("awready", "input", 1),
        ("wdata", "output", "DATA_W"),
        ("wstrb", "output", "DATA_W / 8"),
        ("wvalid", "output", 1),
        ("wready", "input", 1),
        ("bresp", "input", "RESP_W"),
        ("bvalid", "input", 1),
        ("bready", "output", 1),
        ("araddr", "output", "ADDR_W"),
        ("arprot", "output", "PROT_W"),
        ("arvalid", "output", 1),
        ("arready", "input", 1),
        ("rdata", "input", "DATA_W"),
        ("rresp", "input", "RESP_W"),
        ("rvalid", "input", 1),
        ("rready", "output", 1),
    ],
    "axi": [
        ("awaddr", "output", "ADDR_W"),
        ("awprot", "output", "PROT_W"),
        ("awvalid", "output", 1),
        ("awready", "input", 1),
        ("wdata", "output", "DATA_W"),
        ("wstrb", "output", "DATA_W / 8"),
        ("wvalid", "output", 1),
        ("wready", "input", 1),
        ("bresp", "input", "RESP_W"),
        ("bvalid", "input", 1),
        ("bready", "output", 1),
        ("araddr", "output", "ADDR_W"),
        ("arprot", "output", "PROT_W"),
        ("arvalid", "output", 1),
        ("arready", "input", 1),
        ("rdata", "input", "DATA_W"),
        ("rresp", "input", "RESP_W"),
        ("rvalid", "input", 1),
        ("rready", "output", 1),
        ("awid", "output", "ID_W"),
        ("awlen", "output", "LEN_W"),
        ("awsize", "output", "SIZE_W"),
        ("awburst", "output", "BURST_W"),
        ("awlock", "output", "LOCK_W"),
        ("awcache", "output", "CACHE_W"),
        ("awqos", "output", "QOS_W"),
        ("wlast", "output", 1),
        ("bid", "input", "ID_W"),
        ("arid", "output", "ID_W"),
        ("arlen", "output", "LEN_W"),
        ("arsize", "output", "SIZE_W"),
        ("arburst", "output", "BURST_W"),
        ("arlock", "output", "LOCK_W"),
        ("arcache", "output", "CACHE_W"),
        ("arqos", "output", "QOS_W"),
        ("rid", "input", "ID_W"),
        ("rlast", "input", 1),
    ],
}


def setup(py_params_dict):
    """Core purely made of wires to convert between two buses with different widths (to suppress verilog warnings).
    Use verilog parameters to define widths of each bus.
    :param str interface: Type of interface of buses.
    """
    INTERFACE = py_params_dict["interface"] if "interface" in py_params_dict else "axil"

    wire_assigns = ""
    parameter_names = []
    verilog_parameters = []
    master_interface_parameters = {}
    slave_interface_parameters = {}
    for signal in interfaces[INTERFACE]:
        name = signal[0]
        direction = signal[1]
        width = signal[2]

        if type(width) is int:
            bit_select = ""
        elif direction == "output":
            bit_select = f"[MASTER_{width}-1:0]"
        else:
            bit_select = f"[SLAVE_{width}-1:0]"

        # Connect both interfaces
        wire_assigns += f"""
   assign {INTERFACE}_{name}_o = {INTERFACE}_{name}_i{bit_select};
"""

        # Only create verilog parameters for strings that represent widths
        if type(width) is int or not width.endswith("_W"):
            continue

        # Don't create a duplicate parameters
        if width in parameter_names:
            continue
        parameter_names.append(width)

        # Set verilog parameters for each interface
        verilog_parameters += [
            {
                "name": f"SLAVE_{width}",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": f"Slave {width[:-2]} bus width",
            },
            {
                "name": f"MASTER_{width}",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": f"Master {width[:-2]} bus width",
            },
        ]
        # Set parameters for if_gen generation of each interface
        slave_interface_parameters[width] = f"SLAVE_{width}"
        master_interface_parameters[width] = f"MASTER_{width}"

    attributes_dict = {
        "name": f"{INTERFACE}_bus_width_converter",
        "version": "0.1",
        "confs": verilog_parameters,
        "ports": [
            {
                "name": "slave",
                "descr": "Slave interface (connects to master)",
                "interface": {
                    "type": INTERFACE,
                    "subtype": "slave",
                    **slave_interface_parameters,
                },
            },
            {
                "name": "master",
                "descr": "Master interface (connects to slave)",
                "interface": {
                    "type": INTERFACE,
                    "subtype": "master",
                    **master_interface_parameters,
                },
            },
        ],
        "snippets": [{"verilog_code": wire_assigns}],
    }

    return attributes_dict
