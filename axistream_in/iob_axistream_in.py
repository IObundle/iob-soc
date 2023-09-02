#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg_re import iob_reg_re
from iob_edge_detect import iob_edge_detect
from iob_ram_t2p import iob_ram_t2p
from iob_fifo_async import iob_fifo_async
from iob_sync import iob_sync


class iob_axistream_in(iob_module):
    name = 'iob_axistream_in'
    version = "V0.20"
    flows = "emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            {"interface": "iob_s_port"},
            {"interface": "iob_s_portmap"},
            iob_fifo_async,
            iob_reg_re,
            iob_edge_detect,
            iob_ram_t2p,
            iob_sync
        ])

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs([
            # Macros
            # Parameters
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "32",
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
            {
                "name": "DMA_TDATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "DATA_W",
                "descr": "Width of DMA tdata interface (can be up to DATA_W)",
            },
        ])

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "System general interface signals",
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
                "descr": "Axistream interface signals",
                "ports": [
                    {
                        "name": "axis_clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Axistream clock input",
                    },
                    {
                        "name": "axis_cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Axistream clock enable signal.",
                    },
                    {
                        "name": "axis_arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Axistream reset, asynchronous and active high",
                    },
                    {
                        "name": "axis_tdata_i",
                        "type": "I",
                        "n_bits": "TDATA_W",
                        "descr": "Axistream data input interface",
                    },
                    {
                        "name": "axis_tvalid_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Axistream valid input interface",
                    },
                    {
                        "name": "axis_tready_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Axistream ready output interface",
                    },
                    {
                        "name": "axis_tlast_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Axistream last input interface",
                    },
                ],
            },
            {
                "name": "interrupt",
                "descr": "",
                "ports": [
                    {
                        "name": "fifo_threshold_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "FIFO threshold interrupt signal",
                    },
                ],
            },
            {
                "name": "dma",
                "descr": "Direct Memory Access via dedicated AXI Stream interface.",
                "ports": [
                    {
                        "name": "tdata_o",
                        "type": "O",
                        "n_bits": "DMA_TDATA_W",
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
                        "name": "SOFT_RESET",
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
                        "name": "DATA",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "Data output (reading from this register sets the RSTRB and LAST registers).",
                    },
                    {
                        "name": "RSTRB",
                        "type": "R",
                        "n_bits": "32/TDATA_W",
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Get which words (with TDATA_W bits) of the previous 32-bits output are valid.",
                    },
                    {
                        "name": "LAST",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Get the tlast bit of the previous 32-bits output word.",
                    },
                    {
                        "name": "EMPTY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Full (1), or non-full (0).",
                    },
                ],
            },
            {
                "name": "fifo",
                "descr": "FIFO related registers",
                "regs": [
                    {
                        "name": "FIFO_THRESHOLD",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 4,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "FIFO threshold level for interrupt signal",
                    },
                    {
                        "name": "FIFO_LEVEL",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Current FIFO level",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
