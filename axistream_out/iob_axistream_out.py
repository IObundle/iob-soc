#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_ram_2p_be import iob_ram_2p_be
from iob_axistream_in import iob_axistream_in


class iob_axistream_out(iob_module):
    name = "iob_axistream_out"
    version = iob_axistream_in.version
    flows = iob_axistream_in.flows
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            # TODO: Copy submodules from iob_axistream_in. Probably should create a superclass iob_axistream with the base for these
            "iob_s_port",
            "iob_s_portmap",
            iob_reg,
            iob_reg_e,
            iob_ram_2p_be,
        ])

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs(iob_axistream_in.confs)

        # Find ADDR_W from confs and change its val to OUT_SWREG_ADDR_W
        for conf in cls.confs:
            if conf["name"] == "ADDR_W":
                conf["val"] = "`IOB_AXISTREAM_OUT_SWREG_ADDR_W"
                break

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
                        "name": "tdata_o",
                        "type": "O",
                        "n_bits": "TDATA_W",
                        "descr": "TData output interface",
                    },
                    {
                        "name": "tvalid_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "TValid output interface",
                    },
                    {
                        "name": "tready_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "TReady input interface",
                    },
                    {
                        "name": "tlast_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "TLast output interface",
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
                        "name": "IN",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "32 bits: Set next FIFO input (Writing to this register pushes the value into the FIFO)",
                    },
                    {
                        "name": "FULL",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "1 bit: Return if FIFO is full",
                    },
                    {
                        "name": "SOFTRESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "ENABLE",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 1,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Enable peripheral.",
                    },
                    {
                        "name": "WSTRB_NEXT_WORD_LAST",
                        "type": "W",
                        "n_bits": 5,
                        "rst_val": 0,
                        "addr": 8,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "From 1 to 4 bits: Set which output words of the next input word in AXISTREAMOUT_IN are valid and send TLAST signal along with last valid byte. (If this register has value 0, all 4 bytes will be valid and it will not send a TLAST signal with the last byte [MSB]). When the output word width (TDATA) is 8, 16 or 32 bits, this register has size 4, 2 or 1 bits respectively.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
