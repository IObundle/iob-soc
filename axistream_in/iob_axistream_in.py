#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_ram_2p_be import iob_ram_2p_be

class iob_axistream_in(iob_module):
    name='iob_axistream_in'
    version = "V0.10"
    flows = "emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Hardware headers & modules
        iob_module.generate("iob_s_port")
        iob_module.generate("iob_s_portmap")
        iob_reg.setup()
        iob_reg_e.setup()
        iob_ram_2p_be.setup()

        # Verilog modules instances
        # TODO

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs([
            # Macros
            # Parameters
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "32",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "`IOB_AXISTREAM_IN_SWREG_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "TDATA_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "DATA_W",
                "descr": "Width of tdata interface (can be up to DATA_W)",
            },
            {
                "name": "FIFO_DEPTH_LOG2",
                "type": "P",
                "val": "4",
                "min": "NA",
                "max": "16",
                "descr": "Depth of FIFO",
            },
        ])

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "GENERAL INTERFACE SIGNALS",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, asynchronous and active high",
                    },
                    {
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock enable signal.",
                    },
                ],
            },
            {
                "name": "axistream",
                "descr": "",
                "ports": [
                    {
                        "name": "tdata_i",
                        "type": "I",
                        "n_bits": "TDATA_W",
                        "descr": "TData input interface",
                    },
                    {
                        "name": "tvalid_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "TValid input interface",
                    },
                    {
                        "name": "tready_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "TReady output interface",
                    },
                    {
                        "name": "tlast_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "TLast input interface",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "axistream",
                "descr": "Axistream software accessible registers.",
                "regs": [
                    {
                        "name": "OUT",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "32 bits: Get next FIFO output (Reading from this register makes it pop the next value from FIFO)",
                    },
                    {
                        "name": "EMPTY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "1 bit: Return if FIFO is empty (May be empty due to waiting for more data or because it received a TLAST signal)",
                    },
                    {
                        "name": "LAST",
                        "type": "R",
                        "n_bits": 5,
                        "rst_val": 0,
                        "addr": 8,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "1+4 bits: [Bit 4] Signals if FIFO is empty due to receiving a TLAST signal; [Bit 3-0] Tells which bytes (from latest value of AXISTREAMIN_OUT) are valid (similar to WSTRB signal of AXI Stream). (Reading from this register makes it reset and starts filling FIFO with next frame)",
                    },
                    {
                        "name": "SOFTRESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 12,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "ENABLE",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 1,
                        "addr": 13,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Enable peripheral.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
