def setup(py_params_dict):
    # Number of slave interfaces (number of masters to connect to)
    N_SLAVES = (
        int(py_params_dict["num_slaves"]) if "num_slaves" in py_params_dict else 1
    )

    attributes_dict = {
        "original_name": "altera_alt_ddr3",
        "name": "altera_alt_ddr3",
        "version": "0.1",
        "ports": [
            {
                "name": "clk_rst",
                "descr": "Clock and reset",
                "signals": [
                    {"name": "clk", "direction": "input", "width": "1"},
                    {"name": "resetn", "direction": "input", "width": "1"},
                ],
            },
            {
                "name": "general",
                "descr": "",
                "signals": [
                    {"name": "rzqin", "direction": "input", "width": "1"},
                    {"name": "pll_locked", "direction": "output", "width": "1"},
                    {"name": "init_done", "direction": "output", "width": "1"},
                ],
            },
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
        ],
    }
    for i in range(N_SLAVES):
        attributes_dict["ports"] += [
            {
                "name": f"s{i}_axi",
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
    attributes_dict["snippets"] = [
        {
            "verilog_code": """
    alt_ddr3 ddr3_ctrl (
        .clk_clk      (clk_i),
        .reset_reset_n(resetn_i),
        .oct_rzqin    (rzqin_i),

        .memory_mem_a      (ddr3b_a_o),
        .memory_mem_ba     (ddr3b_ba_o),
        .memory_mem_ck     (ddr3b_clk_p_o),
        .memory_mem_ck_n   (ddr3b_clk_n_o),
        .memory_mem_cke    (ddr3b_cke_o),
        .memory_mem_cs_n   (ddr3b_csn_o),
        .memory_mem_dm     (ddr3b_dm_o),
        .memory_mem_ras_n  (ddr3b_rasn_o),
        .memory_mem_cas_n  (ddr3b_casn_o),
        .memory_mem_we_n   (ddr3b_wen_o),
        .memory_mem_reset_n(ddr3b_resetn_o),
        .memory_mem_dq     (ddr3b_dq_io),
        .memory_mem_dqs    (ddr3b_dqs_p_io),
        .memory_mem_dqs_n  (ddr3b_dqs_n_io),
        .memory_mem_odt    (ddr3b_odt_o),


        .mem_if_ddr3_emif_0_pll_sharing_pll_mem_clk              (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk            (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_locked               (pll_locked_o),
        .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk_pre_phy_clk(),
        .mem_if_ddr3_emif_0_pll_sharing_pll_addr_cmd_clk         (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_avl_clk              (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_config_clk           (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_mem_phy_clk          (),
        .mem_if_ddr3_emif_0_pll_sharing_afi_phy_clk              (),
        .mem_if_ddr3_emif_0_pll_sharing_pll_avl_phy_clk          (),
        .mem_if_ddr3_emif_0_status_local_init_done               (init_done_o),
        .mem_if_ddr3_emif_0_status_local_cal_success             (),
        .mem_if_ddr3_emif_0_status_local_cal_fail                ()
""",
        },
    ]

    for i in range(N_SLAVES):
        attributes_dict["snippets"][-1][
            "verilog_code"
        ] += f"""
        //
        // External memory connection {i}
        //

        //Write address
        .axi_bridge_0_s{i}_awid   (s{i}_axi_awid_o),
        .axi_bridge_0_s{i}_awaddr (s{i}_axi_awaddr_o),
        .axi_bridge_0_s{i}_awlen  (s{i}_axi_awlen_o),
        .axi_bridge_0_s{i}_awsize (s{i}_axi_awsize_o),
        .axi_bridge_0_s{i}_awburst(s{i}_axi_awburst_o),
        .axi_bridge_0_s{i}_awlock (s{i}_axi_awlock_o),
        .axi_bridge_0_s{i}_awcache(s{i}_axi_awcache_o),
        .axi_bridge_0_s{i}_awprot (s{i}_axi_awprot_o),
        .axi_bridge_0_s{i}_awvalid(s{i}_axi_awvalid_o),
        .axi_bridge_0_s{i}_awready(s{i}_axi_awready_i),

        //Write data
        .axi_bridge_0_s{i}_wdata  (s{i}_axi_wdata_o),
        .axi_bridge_0_s{i}_wstrb  (s{i}_axi_wstrb_o),
        .axi_bridge_0_s{i}_wlast  (s{i}_axi_wlast_o),
        .axi_bridge_0_s{i}_wvalid (s{i}_axi_wvalid_o),
        .axi_bridge_0_s{i}_wready (s{i}_axi_wready_i),

        //Write respons{i}
        .axi_bridge_0_s{i}_bid    (s{i}_axi_bid_i),
        .axi_bridge_0_s{i}_bresp  (s{i}_axi_bresp_i),
        .axi_bridge_0_s{i}_bvalid (s{i}_axi_bvalid_i),
        .axi_bridge_0_s{i}_bready (s{i}_axi_bready_o),

        //Read address
        .axi_bridge_0_s{i}_arid   (s{i}_axi_arid_o),
        .axi_bridge_0_s{i}_araddr (s{i}_axi_araddr_o),
        .axi_bridge_0_s{i}_arlen  (s{i}_axi_arlen_o),
        .axi_bridge_0_s{i}_arsize (s{i}_axi_arsize_o),
        .axi_bridge_0_s{i}_arburst(s{i}_axi_arburst_o),
        .axi_bridge_0_s{i}_arlock (s{i}_axi_arlock_o),
        .axi_bridge_0_s{i}_arcache(s{i}_axi_arcache_o),
        .axi_bridge_0_s{i}_arprot (s{i}_axi_arprot_o),
        .axi_bridge_0_s{i}_arvalid(s{i}_axi_arvalid_o),
        .axi_bridge_0_s{i}_arready(s{i}_axi_arready_i),

        //Read data
        .axi_bridge_0_s{i}_rid    (s{i}_axi_rid_i),
        .axi_bridge_0_s{i}_rdata  (s{i}_axi_rdata_i),
        .axi_bridge_0_s{i}_rresp  (s{i}_axi_rresp_i),
        .axi_bridge_0_s{i}_rlast  (s{i}_axi_rlast_i),
        .axi_bridge_0_s{i}_rvalid (s{i}_axi_rvalid_i),
        .axi_bridge_0_s{i}_rready (s{i}_axi_rready_o),

"""
    attributes_dict["snippets"][-1]["verilog_code"] += "    );"

    return attributes_dict
