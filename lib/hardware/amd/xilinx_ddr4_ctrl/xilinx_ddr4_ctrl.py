# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            #
            # AXI Parameters
            #
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
        "ports": [
            #
            # Ports
            #
            {
                "name": "clk_rst_i",
                "signals": [
                    {"name": "clk_p", "direction": "input", "width": "1"},
                    {"name": "clk_n", "direction": "input", "width": "1"},
                    {"name": "arst", "direction": "input", "width": "1"},
                ],
            },
            {
                "name": "ui_clk_o",
                "signals": [
                    {"name": "clkout", "direction": "output", "width": "1"},
                ],
            },
            {
                "name": "axi_clk_rst",
                "descr": "",
                "signals": [
                    {"name": "axi_clk", "direction": "output", "width": "1"},
                    {"name": "axi_clk_rst", "direction": "output", "width": "1"},
                    {"name": "axi_arstn", "direction": "input", "width": "1"},
                ],
            },
            {
                "name": "axi_s",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "ID_W": "AXI_ID_W",
                    "LEN_W": "AXI_LEN_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LOCK_W": 1,
                },
                "descr": "AXI interface",
            },
            {
                "name": "ddr4",
                "descr": "DDR4 interface",
                "signals": [
                    {"name": "ddr4_act_n", "direction": "output", "width": "1"},
                    {"name": "ddr4_adr", "direction": "output", "width": "17"},
                    {"name": "ddr4_ba", "direction": "output", "width": "2"},
                    {"name": "ddr4_bg", "direction": "output", "width": "1"},
                    {"name": "ddr4_cke", "direction": "output", "width": "1"},
                    {"name": "ddr4_odt", "direction": "output", "width": "1"},
                    {"name": "ddr4_cs_n", "direction": "output", "width": "1"},
                    {"name": "ddr4_ck_t", "direction": "output", "width": "1"},
                    {"name": "ddr4_ck_c", "direction": "output", "width": "1"},
                    {"name": "ddr4_reset_n", "direction": "output", "width": "1"},
                    {"name": "ddr4_dm_dbi_n", "direction": "inout", "width": "4"},
                    {"name": "ddr4_dq", "direction": "inout", "width": "32"},
                    {"name": "ddr4_dqs_c", "direction": "inout", "width": "4"},
                    {"name": "ddr4_dqs_t", "direction": "inout", "width": "4"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    ddr4_0 ddr4_ctrl (
        .sys_rst     (arst_i),
        .c0_sys_clk_p(clk_p_i),
        .c0_sys_clk_n(clk_n_i),

        .dbg_clk(),
        .dbg_bus(),

        //USER LOGIC CLOCK
        .addn_ui_clkout1        (clkout_o),

        //AXI INTERFACE         (slave)
        .c0_ddr4_ui_clk         (axi_clk_o),
        .c0_ddr4_ui_clk_sync_rst(axi_clk_rst_o),
        .c0_ddr4_aresetn        (axi_arstn_i),

        //address write
        .c0_ddr4_s_axi_awid   (axi_awid_i),
        .c0_ddr4_s_axi_awaddr (axi_awaddr_i),
        .c0_ddr4_s_axi_awlen  (axi_awlen_i),
        .c0_ddr4_s_axi_awsize (axi_awsize_i),
        .c0_ddr4_s_axi_awburst(axi_awburst_i),
        .c0_ddr4_s_axi_awlock (axi_awlock_i),
        .c0_ddr4_s_axi_awprot (axi_awprot_i),
        .c0_ddr4_s_axi_awcache(axi_awcache_i),
        .c0_ddr4_s_axi_awqos  (axi_awqos_i),
        .c0_ddr4_s_axi_awvalid(axi_awvalid_i),
        .c0_ddr4_s_axi_awready(axi_awready_o),

        //write
        .c0_ddr4_s_axi_wvalid(axi_wvalid_i),
        .c0_ddr4_s_axi_wready(axi_wready_o),
        .c0_ddr4_s_axi_wdata (axi_wdata_i),
        .c0_ddr4_s_axi_wstrb (axi_wstrb_i),
        .c0_ddr4_s_axi_wlast (axi_wlast_i),

        //write response
        .c0_ddr4_s_axi_bready(axi_bready_i),
        .c0_ddr4_s_axi_bid   (axi_bid_o),
        .c0_ddr4_s_axi_bresp (axi_bresp_o),
        .c0_ddr4_s_axi_bvalid(axi_bvalid_o),

        //address read
        .c0_ddr4_s_axi_arid   (axi_arid_i),
        .c0_ddr4_s_axi_araddr (axi_araddr_i),
        .c0_ddr4_s_axi_arlen  (axi_arlen_i),
        .c0_ddr4_s_axi_arsize (axi_arsize_i),
        .c0_ddr4_s_axi_arburst(axi_arburst_i),
        .c0_ddr4_s_axi_arlock (axi_arlock_i),
        .c0_ddr4_s_axi_arcache(axi_arcache_i),
        .c0_ddr4_s_axi_arprot (axi_arprot_i),
        .c0_ddr4_s_axi_arqos  (axi_arqos_i),
        .c0_ddr4_s_axi_arvalid(axi_arvalid_i),
        .c0_ddr4_s_axi_arready(axi_arready_o),

        //read
        .c0_ddr4_s_axi_rready(axi_rready_i),
        .c0_ddr4_s_axi_rid   (axi_rid_o),
        .c0_ddr4_s_axi_rdata (axi_rdata_o),
        .c0_ddr4_s_axi_rresp (axi_rresp_o),
        .c0_ddr4_s_axi_rlast (axi_rlast_o),
        .c0_ddr4_s_axi_rvalid(axi_rvalid_o),

        //DDR4 INTERFACE (master of external DDR4 module)
        .c0_ddr4_act_n         (ddr4_act_n_o),
        .c0_ddr4_adr           (ddr4_adr_o),
        .c0_ddr4_ba            (ddr4_ba_o),
        .c0_ddr4_bg            (ddr4_bg_o),
        .c0_ddr4_cke           (ddr4_cke_o),
        .c0_ddr4_odt           (ddr4_odt_o),
        .c0_ddr4_cs_n          (ddr4_cs_n_o),
        .c0_ddr4_ck_t          (ddr4_ck_t_o),
        .c0_ddr4_ck_c          (ddr4_ck_c_o),
        .c0_ddr4_reset_n       (ddr4_reset_n_o),
        .c0_ddr4_dm_dbi_n      (ddr4_dm_dbi_n_io),
        .c0_ddr4_dq            (ddr4_dq_io),
        .c0_ddr4_dqs_c         (ddr4_dqs_c_io),
        .c0_ddr4_dqs_t         (ddr4_dqs_t_io),
        .c0_init_calib_complete()
    );
""",
            },
        ],
    }

    return attributes_dict
