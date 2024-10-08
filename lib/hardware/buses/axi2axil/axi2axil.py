# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    """AXI to AXI-Lite converter
    This converter has the same limitations as AXI-Lite:
    - No Burst Support: burst-related signals (like AWLEN, AWSIZE, ARBURST, etc.) are ignored.
    """
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "P",
                "val": "4",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "P",
                "val": "4",
                "min": "1",
                "max": "4",
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
            },
        ],
        "ports": [
            {
                "name": "axi_s",
                "descr": "AXI slave interface to connect to external master",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
            {
                "name": "axil_m",
                "descr": "AXI Lite master interface to connect to external slave",
                "interface": {
                    "type": "axil",
                    "subtype": "master",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
   // Write Address Channel
   assign axil_awaddr_o = axi_awaddr_i;
   assign axil_awprot_o = axi_awprot_i;
   assign axil_awvalid_o = axi_awvalid_i;
   assign axi_awready_o = axil_awready_i;
   // Write Data Channel
   assign axil_wdata_o = axi_wdata_i;
   assign axil_wstrb_o = axi_wstrb_i;
   assign axil_wvalid_o = axi_wvalid_i;
   assign axi_wready_o = axil_wready_i;
   // Write Response Channel
   assign axi_bresp_o = axil_bresp_i;
   assign axi_bvalid_o = axil_bvalid_i;
   assign axil_bready_o = axi_bready_i;
   // Read Address Channel
   assign axil_araddr_o = axi_araddr_i;
   assign axil_arprot_o = axi_arprot_i;
   assign axil_arvalid_o = axi_arvalid_i;
   assign axi_arready_o = axil_arready_i;
   // Read Data Channel
   assign axi_rdata_o = axil_rdata_i;
   assign axi_rresp_o = axil_rresp_i;
   assign axi_rvalid_o = axil_rvalid_i;
   assign axil_rready_o = axi_rready_i;

   // Unused axi outputs
   assign axi_bid_o = 1'b0;
   assign axi_rid_o = 1'b0;
   assign axi_rlast_o = 1'b1;

   // Unused axi inputs
   // axi_awid_i
   // axi_awlen_i
   // axi_awsize_i
   // axi_awburst_i
   // axi_awlock_i
   // axi_awcache_i
   // axi_awqos_i
   // axi_wlast_i
   // axi_arid_i
   // axi_arlen_i
   // axi_arsize_i
   // axi_arburst_i
   // axi_arlock_i
   // axi_arcache_i
   // axi_arqos_i
"""
            }
        ],
    }

    return attributes_dict
