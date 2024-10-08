# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    params = py_params_dict["iob_system_params"]

    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "F",
                "val": "1",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "F",
                "val": "4",
                "min": "1",
                "max": "8",
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "F",
                "val": "`DDR_ADDR_W" if params["use_extmem"] else "15",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "F",
                "val": "`DDR_DATA_W",
                "min": "1",
                "max": "32",
            },
        ],
    }
    #
    # Ports
    #
    attributes_dict["ports"] = [
        {
            "name": "clk_rst_i",
            "descr": "Clock and reset",
            "signals": [
                {"name": "clk", "direction": "input", "width": "1"},
                {"name": "resetn", "direction": "input", "width": "1"},
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
                "name": "ddr3",
                "descr": "External DDR3 memory interface",
                "signals": [
                    {"name": "ddr3b_a", "direction": "output", "width": "14"},
                    {"name": "ddr3b_ba", "direction": "output", "width": "3"},
                    {"name": "ddr3b_rasn", "direction": "output", "width": "1"},
                    {"name": "ddr3b_casn", "direction": "output", "width": "1"},
                    {"name": "ddr3b_wen", "direction": "output", "width": "1"},
                    {"name": "ddr3b_dm", "direction": "output", "width": "2"},
                    {"name": "ddr3b_dq", "direction": "inout", "width": "16"},
                    {"name": "ddr3b_clk_n", "direction": "output", "width": "1"},
                    {"name": "ddr3b_clk_p", "direction": "output", "width": "1"},
                    {"name": "ddr3b_cke", "direction": "output", "width": "1"},
                    {"name": "ddr3b_csn", "direction": "output", "width": "1"},
                    {"name": "ddr3b_dqs_n", "direction": "inout", "width": "2"},
                    {"name": "ddr3b_dqs_p", "direction": "inout", "width": "2"},
                    {"name": "ddr3b_odt", "direction": "output", "width": "1"},
                    {"name": "ddr3b_resetn", "direction": "output", "width": "1"},
                ],
            },
            {
                "name": "rzqin_i",
                "descr": "",
                "signals": [
                    {"name": "rzqin", "direction": "input", "width": "1"},
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
    attributes_dict["wires"] = [
        {
            "name": "clk_en_rst",
            "descr": "Clock, clock enable and reset",
            "signals": [
                {"name": "clk"},
                {"name": "cke", "width": "1"},
                {"name": "arst", "width": "1"},
            ],
        },
        {
            "name": "rs232_int",
            "descr": "iob-system uart interface",
            "signals": [
                {"name": "rxd"},
                {"name": "txd"},
                {"name": "rs232_rts", "width": "1"},
                {"name": "high", "width": "1"},
            ],
        },
        {
            "name": "axi",
            "descr": "AXI interface to connect SoC to memory",
            "interface": {
                "type": "axi",
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
        },
        {
            "name": "reset_sync_clk_rst",
            "descr": "Reset synchronizer inputs",
            "signals": [
                {"name": "clk"},
                {
                    "name": "rst_int" if params["use_extmem"] else "resetn_inv",
                    "width": "1",
                },
            ],
        },
        {
            "name": "reset_sync_arst_out",
            "descr": "Reset synchronizer output",
            "signals": [
                {"name": "arst"},
            ],
        },
        {
            "name": "clk",
            "descr": "Clock signal",
            "signals": [
                {"name": "clk"},
            ],
        },
    ]

    if params["use_extmem"]:
        attributes_dict["wires"] += [
            # DDR3 ctrl
            {
                "name": "ddr3_ctr_clk_rst",
                "descr": "DDR3 controller clock and areset inputs",
                "signals": [
                    {"name": "clk"},
                    {"name": "resetn"},
                ],
            },
            {
                "name": "ddr3_ctr_general",
                "descr": "DDR3 controller general signals",
                "signals": [
                    {"name": "rzqin"},
                    {"name": "pll_locked"},
                    {"name": "init_done"},
                ],
            },
        ]
    if not params["use_extmem"]:
        attributes_dict["wires"] += [
            {
                "name": "memory_axi",
                "descr": "AXI bus to connect interconnect and memory",
                "interface": {
                    "type": "axi",
                    "wire_prefix": "mem_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
        ]
    if params["use_ethernet"]:
        attributes_dict["wires"] += [
            # eth clock
            {
                "name": "rxclk_buf_io",
                "descr": "rxclkbuf io",
                "signals": [
                    {"name": "enet_rx_clk"},
                    {"name": "eth_clk", "width": "1"},
                ],
            },
            {
                "name": "ddio_out_clkbuf_io",
                "descr": "DDIO clock buffer io",
                "signals": [
                    {
                        "name": "enet_resetn_inv",
                        "width": "1",
                    },  # TODO: Connect and invert enet_resetn
                    {"name": "low", "width": "1"},
                    {"name": "high"},
                    {"name": "eth_clk"},
                    {"name": "enet_gtx_clk"},
                ],
            },
        ]
    #
    # Blocks
    #
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_system_mwrap",
            "instance_name": "iob_system_mwrap",
            "instance_description": "IOb-SoC memory wrapper",
            "parameters": {
                "AXI_ID_W": "AXI_ID_W",
                "AXI_LEN_W": "AXI_LEN_W",
                "AXI_ADDR_W": "AXI_ADDR_W",
                "AXI_DATA_W": "AXI_DATA_W",
            },
            "connect": {
                "clk_en_rst_s": "clk_en_rst",
                "rs232_m": "rs232_int",
                "axi_m": "axi",
            },
            "dest_dir": "hardware/common_src",
            "iob_system_params": params,
        },
        {
            "core_name": "iob_reset_sync",
            "instance_name": "rst_sync",
            "instance_description": "Reset synchronizer",
            "connect": {
                "clk_rst_s": "reset_sync_clk_rst",
                "arst_o": "reset_sync_arst_out",
            },
        },
    ]
    if params["use_extmem"]:
        # DDR3 controller
        attributes_dict["blocks"] += [
            {
                "core_name": "altera_alt_ddr3",
                "instance_name": "ddr3_ctrl",
                "instance_description": "DDR3 controller",
                "parameters": {
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_LEN_W": "AXI_LEN_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                "connect": {
                    "clk_rst_i": "ddr3_ctr_clk_rst",
                    "general": "ddr3_ctr_general",
                    "ddr3": "ddr3",
                    "s0_axi_s": "axi",
                },
            },
        ]
    if not params["use_extmem"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "axi_interconnect_wrapper",
                "name": "fpga_axi_interconnect_wrapper",
                "instance_name": "axi_interconnect",
                "instance_description": "Interconnect instance",
                "parameters": {
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                "connect": {
                    "clk_i": "clk",
                    "rst_i": "reset_sync_arst_out",
                    "s0_axi_s": "axi",
                    "m0_axi_m": "memory_axi",
                },
                "num_slaves": 1,
            },
            {
                "core_name": "axi_ram",
                "instance_name": "ddr_model_mem",
                "instance_description": "DDR model memory",
                "parameters": {
                    "ID_WIDTH": "AXI_ID_W",
                    "ADDR_WIDTH": "AXI_ADDR_W",
                    "DATA_WIDTH": "AXI_DATA_W",
                    "READ_ON_WRITE": "0",
                },
                "connect": {
                    "clk_i": "clk",
                    "rst_i": "reset_sync_arst_out",
                    "axi_s": "memory_axi",
                },
            },
        ]
        if params["init_mem"]:
            attributes_dict["blocks"][-1]["parameters"].update(
                {
                    "FILE": f'"{params["name"]}_firmware"',
                }
            )
    if params["use_ethernet"]:
        # Eth clock
        attributes_dict["blocks"] += [
            {
                "core_name": "altera_clk_buf_altclkctrl",
                "instance_name": "rxclk_buf",
                "instance_description": "RX clock buffer",
                "connect": {
                    "io": "rxclk_buf_io",
                },
            },
            {
                "core_name": "altera_ddio_out_clkbuf",
                "instance_name": "ddio_out_clkbuf_inst",
                "instance_description": "DDIO out clock buffer",
                "connect": {
                    "io": "ddio_out_clkbuf_io",
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
    if params["use_extmem"]:
        attributes_dict["snippets"] += [
            {
                "verilog_code": """
    assign rst_int = ~resetn_i | ~pll_locked | ~init_done;
""",
            },
        ]
    else:  # Not use_extmem
        attributes_dict["snippets"] += [
            {
                "verilog_code": """
    assign resetn_inv = ~resetn_i;
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

    return attributes_dict


# TODO: Add slave ports to alt_ddr3.qsys, based on number of extmem connections
#
# def modify_alt_ddr3_qsys(qsys_path, num_extmem_connections):
#     with open(qsys_path, "r") as f:
#         lines = f.readlines()
#     new_lines = []
#
#     for line in lines:
#         new_lines.append(line)
#         if "element clk_0" in line:
#             for i in range(1, num_extmem_connections):
#                 new_lines.insert(
#                     -1,
#                     f"""
#        element axi_bridge_{i}
#        {{
#           datum _sortIndex
#           {{
#              value = "{i+2}";
#              type = "int";
#           }}
#        }}
#                              \n""",
#                 )
#         elif 'interface name="clk"' in line:
#             for i in range(1, num_extmem_connections):
#                 new_lines.insert(
#                     -1,
#                     f"""
#  <interface
#    name="axi_bridge_{i}_s0"
#    internal="axi_bridge_{i}.s0"
#    type="axi4"
#    dir="end" />
#                              \n""",
#                 )
#         elif 'module name="clk_0"' in line:
#             for i in range(1, num_extmem_connections):
#                 new_lines.insert(
#                     -1,
#                     f"""
#  <module
#    name="axi_bridge_{i}"
#    kind="altera_axi_bridge"
#    version="20.1"
#    enabled="1">
#   <parameter name="ADDR_WIDTH" value="28" />
#   <parameter name="AXI_VERSION" value="AXI4" />
#   <parameter name="COMBINED_ACCEPTANCE_CAPABILITY" value="16" />
#   <parameter name="COMBINED_ISSUING_CAPABILITY" value="16" />
#   <parameter name="DATA_WIDTH" value="32" />
#   <parameter name="M0_ID_WIDTH" value="1" />
#   <parameter name="READ_ACCEPTANCE_CAPABILITY" value="16" />
#   <parameter name="READ_ADDR_USER_WIDTH" value="64" />
#   <parameter name="READ_DATA_REORDERING_DEPTH" value="1" />
#   <parameter name="READ_DATA_USER_WIDTH" value="64" />
#   <parameter name="READ_ISSUING_CAPABILITY" value="16" />
#   <parameter name="S0_ID_WIDTH" value="1" />
#   <parameter name="USE_M0_ARBURST" value="1" />
#   <parameter name="USE_M0_ARCACHE" value="1" />
#   <parameter name="USE_M0_ARID" value="1" />
#   <parameter name="USE_M0_ARLEN" value="1" />
#   <parameter name="USE_M0_ARLOCK" value="1" />
#   <parameter name="USE_M0_ARQOS" value="0" />
#   <parameter name="USE_M0_ARREGION" value="0" />
#   <parameter name="USE_M0_ARSIZE" value="1" />
#   <parameter name="USE_M0_ARUSER" value="0" />
#   <parameter name="USE_M0_AWBURST" value="1" />
#   <parameter name="USE_M0_AWCACHE" value="1" />
#   <parameter name="USE_M0_AWID" value="1" />
#   <parameter name="USE_M0_AWLEN" value="1" />
#   <parameter name="USE_M0_AWLOCK" value="1" />
#   <parameter name="USE_M0_AWQOS" value="0" />
#   <parameter name="USE_M0_AWREGION" value="0" />
#   <parameter name="USE_M0_AWSIZE" value="1" />
#   <parameter name="USE_M0_AWUSER" value="0" />
#   <parameter name="USE_M0_BID" value="1" />
#   <parameter name="USE_M0_BRESP" value="1" />
#   <parameter name="USE_M0_BUSER" value="0" />
#   <parameter name="USE_M0_RID" value="1" />
#   <parameter name="USE_M0_RLAST" value="1" />
#   <parameter name="USE_M0_RRESP" value="1" />
#   <parameter name="USE_M0_RUSER" value="0" />
#   <parameter name="USE_M0_WSTRB" value="1" />
#   <parameter name="USE_M0_WUSER" value="0" />
#   <parameter name="USE_PIPELINE" value="1" />
#   <parameter name="USE_S0_ARCACHE" value="1" />
#   <parameter name="USE_S0_ARLOCK" value="1" />
#   <parameter name="USE_S0_ARPROT" value="1" />
#   <parameter name="USE_S0_ARQOS" value="0" />
#   <parameter name="USE_S0_ARREGION" value="0" />
#   <parameter name="USE_S0_ARUSER" value="0" />
#   <parameter name="USE_S0_AWCACHE" value="1" />
#   <parameter name="USE_S0_AWLOCK" value="1" />
#   <parameter name="USE_S0_AWPROT" value="1" />
#   <parameter name="USE_S0_AWQOS" value="0" />
#   <parameter name="USE_S0_AWREGION" value="0" />
#   <parameter name="USE_S0_AWUSER" value="0" />
#   <parameter name="USE_S0_BRESP" value="1" />
#   <parameter name="USE_S0_BUSER" value="0" />
#   <parameter name="USE_S0_RRESP" value="1" />
#   <parameter name="USE_S0_RUSER" value="0" />
#   <parameter name="USE_S0_WLAST" value="1" />
#   <parameter name="USE_S0_WUSER" value="0" />
#   <parameter name="WRITE_ACCEPTANCE_CAPABILITY" value="16" />
#   <parameter name="WRITE_ADDR_USER_WIDTH" value="64" />
#   <parameter name="WRITE_DATA_USER_WIDTH" value="64" />
#   <parameter name="WRITE_ISSUING_CAPABILITY" value="16" />
#   <parameter name="WRITE_RESP_USER_WIDTH" value="64" />
#  </module>
#                              \n""",
#                 )
#         elif 'end="axi_bridge_0.clk"' in line:
#             for i in range(1, num_extmem_connections):
#                 new_lines.insert(
#                     -1,
#                     f"""
#  <connection
#    kind="avalon"
#    version="20.1"
#    start="axi_bridge_{i}.m0"
#    end="mem_if_ddr3_emif_0.avl">
#   <parameter name="arbitrationPriority" value="1" />
#   <parameter name="baseAddress" value="0x0000" />
#   <parameter name="defaultConnection" value="false" />
#  </connection>
#  <connection kind="clock" version="20.1" start="clk_0.clk" end="axi_bridge_{i}.clk" />
#                              \n""",
#                 )
#         elif 'name="qsys_mm.clockCrossingAdapter"' in line:
#             for i in range(1, num_extmem_connections):
#                 new_lines.insert(
#                     -1,
#                     f"""
#  <connection
#    kind="reset"
#    version="20.1"
#    start="clk_0.clk_reset"
#    end="axi_bridge_{i}.clk_reset" />
#                              \n""",
#                 )
#
#     with open(qsys_path, "w") as f:
#         f.writelines(new_lines)
