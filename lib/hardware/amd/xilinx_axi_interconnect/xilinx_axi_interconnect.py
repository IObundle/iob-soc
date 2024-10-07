# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


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
                "name": "AXI_LEN_W",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "8",
                "descr": "AXI burst length width",
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
                "name": "clk_rst_s",
                "descr": "Clock and reset inputs",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
            },
        ],
    }
    for i in range(N_SLAVES):
        attributes_dict["ports"] += [
            {
                "name": f"s{i}_clk_rst",
                "descr": f"Slave {i} clock reset interface",
                "signals": [
                    {"name": f"s{i}_clk", "direction": "input", "width": "1"},
                    {"name": f"s{i}_arstn", "direction": "output", "width": "1"},
                ],
            },
            {
                "name": f"s{i}_axi_s",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": f"s{i}_",
                    "ID_W": "AXI_ID_W",
                    "LEN_W": "AXI_LEN_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                },
                "descr": f"Slave {i} interface",
            },
        ]
    for i in range(N_MASTERS):
        attributes_dict["ports"] += [
            {
                "name": f"m{i}_clk_rst",
                "descr": f"Master {i} clock reset output interface",
                "signals": [
                    {"name": f"m{i}_clk", "direction": "input", "width": "1"},
                    {"name": f"m{i}_arstn", "direction": "output", "width": "1"},
                ],
            },
            {
                "name": f"m{i}_axi_m",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": f"m{i}_",
                    "ID_W": "AXI_ID_W",
                    "LEN_W": "AXI_LEN_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LOCK_W": 1,
                },
                "descr": f"Master {i} axi interface",
            },
        ]
    #
    # Snippets
    #
    attributes_dict["snippets"] = [
        {
            "verilog_code": """
    axi_interconnect_0 axi_interconnect_inst (
""",
        },
    ]

    for i in range(N_SLAVES):
        attributes_dict["snippets"][-1][
            "verilog_code"
        ] += f"""
        //
        // Slave interface {i}
        //
        .S{i:02d}_AXI_ARESET_OUT_N(s{i}_arstn_o),
        .S{i:02d}_AXI_ACLK        (s{i}_clk_i),

        //Write address
        .S{i:02d}_AXI_AWID   (s{i}_axi_awid_i[0]),
        .S{i:02d}_AXI_AWADDR (s{i}_axi_awaddr_i),
        .S{i:02d}_AXI_AWLEN  (s{i}_axi_awlen_i),
        .S{i:02d}_AXI_AWSIZE (s{i}_axi_awsize_i),
        .S{i:02d}_AXI_AWBURST(s{i}_axi_awburst_i),
        .S{i:02d}_AXI_AWLOCK (s{i}_axi_awlock_i[0]),
        .S{i:02d}_AXI_AWCACHE(s{i}_axi_awcache_i),
        .S{i:02d}_AXI_AWPROT (s{i}_axi_awprot_i),
        .S{i:02d}_AXI_AWQOS  (s{i}_axi_awqos_i),
        .S{i:02d}_AXI_AWVALID(s{i}_axi_awvalid_i),
        .S{i:02d}_AXI_AWREADY(s{i}_axi_awready_o),

        //Write data
        .S{i:02d}_AXI_WDATA (s{i}_axi_wdata_i),
        .S{i:02d}_AXI_WSTRB (s{i}_axi_wstrb_i),
        .S{i:02d}_AXI_WLAST (s{i}_axi_wlast_i),
        .S{i:02d}_AXI_WVALID(s{i}_axi_wvalid_i),
        .S{i:02d}_AXI_WREADY(s{i}_axi_wready_o),

        //Write response
        .S{i:02d}_AXI_BID   (s{i}_axi_bid_o[0]),
        .S{i:02d}_AXI_BRESP (s{i}_axi_bresp_o),
        .S{i:02d}_AXI_BVALID(s{i}_axi_bvalid_o),
        .S{i:02d}_AXI_BREADY(s{i}_axi_bready_i),

        //Read address
        .S{i:02d}_AXI_ARID   (s{i}_axi_arid_i[0]),
        .S{i:02d}_AXI_ARADDR (s{i}_axi_araddr_i),
        .S{i:02d}_AXI_ARLEN  (s{i}_axi_arlen_i),
        .S{i:02d}_AXI_ARSIZE (s{i}_axi_arsize_i),
        .S{i:02d}_AXI_ARBURST(s{i}_axi_arburst_i),
        .S{i:02d}_AXI_ARLOCK (s{i}_axi_arlock_i[0]),
        .S{i:02d}_AXI_ARCACHE(s{i}_axi_arcache_i),
        .S{i:02d}_AXI_ARPROT (s{i}_axi_arprot_i),
        .S{i:02d}_AXI_ARQOS  (s{i}_axi_arqos_i),
        .S{i:02d}_AXI_ARVALID(s{i}_axi_arvalid_i),
        .S{i:02d}_AXI_ARREADY(s{i}_axi_arready_o),

        //Read data
        .S{i:02d}_AXI_RID   (s{i}_axi_rid_o[0]),
        .S{i:02d}_AXI_RDATA (s{i}_axi_rdata_o),
        .S{i:02d}_AXI_RRESP (s{i}_axi_rresp_o),
        .S{i:02d}_AXI_RLAST (s{i}_axi_rlast_o),
        .S{i:02d}_AXI_RVALID(s{i}_axi_rvalid_o),
        .S{i:02d}_AXI_RREADY(s{i}_axi_rready_i),
"""

    for i in range(N_MASTERS):
        attributes_dict["snippets"][-1][
            "verilog_code"
        ] += f"""
        //
        // Master interface {i}
        //

        .M{i:02d}_AXI_ARESET_OUT_N(m{i}_arstn_o),
        .M{i:02d}_AXI_ACLK        (m{i}_clk_i),

        //Write address
        .M{i:02d}_AXI_AWID   (m{i}_axi_awid_o),
        .M{i:02d}_AXI_AWADDR (m{i}_axi_awaddr_o),
        .M{i:02d}_AXI_AWLEN  (m{i}_axi_awlen_o),
        .M{i:02d}_AXI_AWSIZE (m{i}_axi_awsize_o),
        .M{i:02d}_AXI_AWBURST(m{i}_axi_awburst_o),
        .M{i:02d}_AXI_AWLOCK (m{i}_axi_awlock_o),
        .M{i:02d}_AXI_AWCACHE(m{i}_axi_awcache_o),
        .M{i:02d}_AXI_AWPROT (m{i}_axi_awprot_o),
        .M{i:02d}_AXI_AWQOS  (m{i}_axi_awqos_o),
        .M{i:02d}_AXI_AWVALID(m{i}_axi_awvalid_o),
        .M{i:02d}_AXI_AWREADY(m{i}_axi_awready_i),

        //Write data
        .M{i:02d}_AXI_WDATA (m{i}_axi_wdata_o),
        .M{i:02d}_AXI_WSTRB (m{i}_axi_wstrb_o),
        .M{i:02d}_AXI_WLAST (m{i}_axi_wlast_o),
        .M{i:02d}_AXI_WVALID(m{i}_axi_wvalid_o),
        .M{i:02d}_AXI_WREADY(m{i}_axi_wready_i),

        //Write response
        .M{i:02d}_AXI_BID   (m{i}_axi_bid_i),
        .M{i:02d}_AXI_BRESP (m{i}_axi_bresp_i),
        .M{i:02d}_AXI_BVALID(m{i}_axi_bvalid_i),
        .M{i:02d}_AXI_BREADY(m{i}_axi_bready_o),

        //Read address
        .M{i:02d}_AXI_ARID   (m{i}_axi_arid_o),
        .M{i:02d}_AXI_ARADDR (m{i}_axi_araddr_o),
        .M{i:02d}_AXI_ARLEN  (m{i}_axi_arlen_o),
        .M{i:02d}_AXI_ARSIZE (m{i}_axi_arsize_o),
        .M{i:02d}_AXI_ARBURST(m{i}_axi_arburst_o),
        .M{i:02d}_AXI_ARLOCK (m{i}_axi_arlock_o),
        .M{i:02d}_AXI_ARCACHE(m{i}_axi_arcache_o),
        .M{i:02d}_AXI_ARPROT (m{i}_axi_arprot_o),
        .M{i:02d}_AXI_ARQOS  (m{i}_axi_arqos_o),
        .M{i:02d}_AXI_ARVALID(m{i}_axi_arvalid_o),
        .M{i:02d}_AXI_ARREADY(m{i}_axi_arready_i),

        //Read data
        .M{i:02d}_AXI_RID   (m{i}_axi_rid_i),
        .M{i:02d}_AXI_RDATA (m{i}_axi_rdata_i),
        .M{i:02d}_AXI_RRESP (m{i}_axi_rresp_i),
        .M{i:02d}_AXI_RLAST (m{i}_axi_rlast_i),
        .M{i:02d}_AXI_RVALID(m{i}_axi_rvalid_i),
        .M{i:02d}_AXI_RREADY(m{i}_axi_rready_o),
"""
    attributes_dict["snippets"][-1][
        "verilog_code"
    ] += """
        .INTERCONNECT_ACLK   (clk_i),
        .INTERCONNECT_ARESETN(~arst_i)
    );
"""

    return attributes_dict
